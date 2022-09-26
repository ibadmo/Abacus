/**
 * File:        osf_ctrl_checkout_shipping.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 25, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Controller class osf_cartdetail_shipping component.
  ***********************************************************************
 * History:
 * Date:                Modified By:            Description:
 */
global without sharing class osf_ctrl_checkout_shipping {

    private static final String SHIP_TO_ID = 'shipToId';

    private static final String BILL_TO_ID = 'billToId';

    private static Map<String, SObjectField> contactAddressFrontendFieldNamesToRealFields = new Map<String, SObjectField> {
        'address1' => ccrz__E_ContactAddr__c.ccrz__AddressFirstline__c,
        'address2' => ccrz__E_ContactAddr__c.ccrz__AddressSecondline__c,
        'address3' => ccrz__E_ContactAddr__c.ccrz__AddressThirdline__c,
        'city' => ccrz__E_ContactAddr__c.ccrz__City__c,
        'companyName' => ccrz__E_ContactAddr__c.ccrz__CompanyName__c,
        'country' => ccrz__E_ContactAddr__c.ccrz__Country__c,
        'countryCode' => ccrz__E_ContactAddr__c.ccrz__CountryISOCode__c,
        'firstName' => ccrz__E_ContactAddr__c.ccrz__FirstName__c,
        'lastName' => ccrz__E_ContactAddr__c.ccrz__LastName__c,
        'partnerId' => ccrz__E_ContactAddr__c.ccrz__Partner_Id__c,
        'postalCode' => ccrz__E_ContactAddr__c.ccrz__PostalCode__c,
        'state' => ccrz__E_ContactAddr__c.ccrz__State__c
    };


    /* 
    * @description  : Calculate Shipping Cost
    * @author       : Ozgun Eser
    * @createdDate  : Feb 25, 2020
    * @param        : ccrz.cc_RemoteActionContext context, 
    * @param        : Decimal taxAmount,
    * @param        : Id shippingAddressId, Salesforce Id of the selected Shipping Address
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult calculateShippingCost (ccrz.cc_RemoteActionContext context, Decimal taxAmount, Id shippingAddressId) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        data.put(osf_constant_strings.SHIPPING_CHARGE, osf_utility.calculateShippingCost(context.currentCartId, taxAmount, shippingAddressId));
        result.success = true;
        return result;
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveBillingAddress(
        ccrz.cc_RemoteActionContext context,
        Map<String, Object> billToAddress
    ) {
        Id userId =  String.isBlank(context.portalUserId) ? UserInfo.getUserId() : context.portalUserId;
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object>();

        try {

            ccrz__E_Cart__c cart = queryCart(context.currentCartId);

            if (String.isBlank(cart.ccrz__BillTo__c)) {

                // In case the BillTo address is blank a copy of the default BillTo address will be saved
                ccrz__E_ContactAddr__c defaultShipToAddress = getDefaultAddressCopyForUser(userId, osf_constant_strings.ADDRESS_TYPE_SHIPPING);
                insert defaultShipToAddress;

                cart.ccrz__ShipTo__c = defaultShipToAddress.Id;
            }

            // Saving a copy of the passed shipping address because if we are just linking the existing one it is deleted as soon as the cart is deleted - for unknown reasons
            ccrz__E_ContactAddr__c billingAddress = convertAddressToCcrzContactAddress(billToAddress);
            insert billingAddress;

            cart.ccrz__BillTo__c = billingAddress.Id;
            update cart;

            // cleanup of orphaned records will be skipped for the time being due to "we are not running into the limits with it" - sad but true

            data.put(SHIP_TO_ID, cart.ccrz__ShipTo__c);
            data.put(BILL_TO_ID, cart.ccrz__BillTo__c);

            result.success = true;
            result.data = data;
            return result;

        } catch (Exception e) {
            result.success = false;
            result.data = new Map<String, Object> {
                'message' => e.getMessage(),
                'stackTrace' => e.getStackTraceString(),
                'lineNumber' => e.getLineNumber()
            };
            return result;
        }
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveShippingAddress(
        ccrz.cc_RemoteActionContext context,
        Map<String, Object> shipToAddress
    ) {
        Id userId =  String.isBlank(context.portalUserId) ? UserInfo.getUserId() : context.portalUserId;
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object>();

        try {

            ccrz__E_Cart__c cart = queryCart(context.currentCartId);

            if (String.isBlank(cart.ccrz__BillTo__c)) {

                // In case the BillTo address is blank a copy of the default BillTo address will be saved
                ccrz__E_ContactAddr__c defaultBillToAddress = getDefaultAddressCopyForUser(userId, osf_constant_strings.ADDRESS_TYPE_BILLING);
                insert defaultBillToAddress;

                cart.ccrz__BillTo__c = defaultBillToAddress.Id;
            }

            // Saving a copy of the passed shipping address because if we are just linking the existing one it is deleted as soon as the cart is deleted - for unknown reasons
            ccrz__E_ContactAddr__c shippingAddress = convertAddressToCcrzContactAddress(shipToAddress);
            insert shippingAddress;

            cart.ccrz__ShipTo__c = shippingAddress.Id;
            update cart;

            // cleanup of orphaned records will be skipped for the time being due to "we are not running into the limits with it" - sad but true

            data.put(SHIP_TO_ID, cart.ccrz__ShipTo__c);
            data.put(BILL_TO_ID, cart.ccrz__BillTo__c);

            result.success = true;
            result.data = data;
            return result;

        } catch (Exception e) {
            result.success = false;
            result.data = new Map<String, Object> {
                'message' => e.getMessage(),
                'stackTrace' => e.getStackTraceString(),
                'lineNumber' => e.getLineNumber()
            };
            return result;
        }
    }


    private static ccrz__E_ContactAddr__c getDefaultAddressCopyForUser(Id userId, String addressType) {

        List<ccrz__E_AccountAddressBook__c> defaultAddresses = queryDefaultAddresses(userId);
        for (ccrz__E_AccountAddressBook__c defaultAddress : defaultAddresses) {
            if (defaultAddress.ccrz__AddressType__c == addressType) {
                return defaultAddress.ccrz__E_ContactAddress__r.clone();
            }
        }

        return null;
    }


    private static List<ccrz__E_AccountAddressBook__c> queryDefaultAddresses (Id userId) {

        return [
            SELECT
                Id,
                ccrz__AddressType__c,
                ccrz__E_ContactAddress__r.ccrz__AddressFirstline__c,
                ccrz__E_ContactAddress__r.ccrz__AddressSecondline__c,
                ccrz__E_ContactAddress__r.ccrz__AddressThirdline__c,
                ccrz__E_ContactAddress__r.ccrz__City__c,
                ccrz__E_ContactAddress__r.ccrz__CompanyName__c,
                ccrz__E_ContactAddress__r.ccrz__Country__c,
                ccrz__E_ContactAddress__r.ccrz__CountryISOCode__c,
                ccrz__E_ContactAddress__r.ccrz__FirstName__c,
                ccrz__E_ContactAddress__r.ccrz__LastName__c,
                ccrz__E_ContactAddress__r.ccrz__Partner_Id__c,
                ccrz__E_ContactAddress__r.ccrz__PostalCode__c,
                ccrz__E_ContactAddress__r.ccrz__State__c,
                ccrz__E_ContactAddress__r.osf_is_baelaric_island__c
            FROM
                ccrz__E_AccountAddressBook__c
            WHERE
                ccrz__Account__c IN (
                    SELECT
                        AccountId
                    FROM
                        User
                    WHERE Id = :userId
                )
                AND ccrz__Default__c = TRUE
        ];
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult calculateShippingCosts(
        ccrz.cc_RemoteActionContext context,
        Id shipToId,
        Decimal currentTax
    ) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object>();

        if (String.isNotBlank(context.currentCartId)) {
            Decimal shippingCosts = calculateShippingCost(context.currentCartId, currentTax, shipToId);
            data.put('shipAmount', shippingCosts);
        }

        result.success = true;
        result.data = data;

        return result;
    }


    private static Decimal calculateShippingCost (String cartEncryptedId, Decimal taxAmount, Id shipToId) {

        ccrz__E_Cart__c cart = [
            SELECT
                Id,
                ccrz__ShipAmount__c,
                ccrz__Account__r.osf_free_shipment__c,
                ccrz__SubtotalAmount__c,
                ccrz__ShipTo__c
            FROM
                ccrz__E_Cart__c
            WHERE
                ccrz__EncryptedId__c = :cartEncryptedId
        ];

        ccrz__E_ContactAddr__c shippingAddress = [
            SELECT
                osf_free_shipping_limit__c,
                osf_shipping_cost__c
            FROM
                ccrz__E_ContactAddr__c
            WHERE
                Id = :shipToId
        ];

        Decimal totalAmount = cart.ccrz__SubtotalAmount__c + taxAmount;
        cart.ccrz__TaxAmount__c = taxAmount;
        cart.ccrz__ShipAmount__c = cart.ccrz__Account__r.osf_free_shipment__c || totalAmount >= shippingAddress.osf_free_shipping_limit__c ? 0 : shippingAddress.osf_shipping_cost__c;

        update cart;
        return cart.ccrz__ShipAmount__c;
    }


    private static ccrz__E_ContactAddr__c convertAddressToCcrzContactAddress(Map<String, Object> billToAddress) {

        ccrz__E_ContactAddr__c contactAddress = new ccrz__E_ContactAddr__c();

        for(String key : billToAddress.keySet()) {
            if (!contactAddressFrontendFieldNamesToRealFields.containsKey(key)) {
                continue;
            }

            contactAddress.put(
                contactAddressFrontendFieldNamesToRealFields.get(key),
                billToAddress.get(key)
            );
        }

        return contactAddress;
    }


    private static ccrz__E_Cart__c queryCart(String encryptedCartId) {

        return [
            SELECT
                Id,
                ccrz__BillTo__c,
                ccrz__BillTo__r.osf_account__c,
                ccrz__ShipTo__c,
                ccrz__ShipTo__r.osf_account__c
            FROM
                ccrz__E_Cart__c
            WHERE
                ccrz__EncryptedId__c = :encryptedCartId
        ];
    }


    private static ccrz__E_ContactAddr__c queryContactAddress(Id contactAddressId) {
        return [
                SELECT
                    Id,
                    ccrz__AddressFirstline__c,
                    ccrz__AddressSecondline__c,
                    ccrz__AddressThirdline__c,
                    ccrz__City__c,
                    ccrz__CompanyName__c,
                    ccrz__Country__c,
                    ccrz__CountryISOCode__c,
                    ccrz__FirstName__c,
                    ccrz__LastName__c,
                    ccrz__Partner_Id__c,
                    ccrz__PostalCode__c,
                    ccrz__State__c
                FROM
                    ccrz__E_ContactAddr__c
                WHERE
                    Id = :contactAddressId
        ];
    }

    /* 
    * @description  : calculate Longest Delivery Time 
    * @author       : Cansu Asli Asci
    * @createdDate  : Feb 24, 2020
    * @param        : ccrz.cc_RemoteActionContext ctx
    * @return       : ccrz.cc_RemoteActionResult
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult calculateLongestDeliveryTime(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;

        try{
            List<ccrz__E_CartItem__c> cartItems = [SELECT ccrz__Product__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Quantity__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c =: ctx.currentCartId];
            Map<Id, Decimal> productId_Quantity_Map = new Map<Id, Decimal>();
            Map<Id, String> productId_SKU_Map = new Map<Id, String>();
            Set<String> productIdSet = new Set<String>();

            for(ccrz__E_CartItem__c cartItem : cartItems){
                    productId_Quantity_Map.put(cartItem.ccrz__Product__c, cartItem.ccrz__Quantity__c);
                    productId_SKU_Map.put(cartItem.ccrz__Product__c, cartItem.ccrz__Product__r.ccrz__SKU__c);
                    productIdSet.add(cartItem.ccrz__Product__c);
            }
            //update products according to web service call
            osf_utility.updateStock(productId_Quantity_Map, productId_SKU_Map);
            //calculate delivery time 
            String deliveryTime = calculate(productIdSet);
            
            data.put(osf_constant_strings.DELIVERY_TIME, deliveryTime);
            data.put(osf_constant_strings.STANDARD_DELIVERY_TIME, osf_constant_strings.STANDARD_DELIVERY_TIME_CHECKOUT);
            result.success = true;
        }catch(Exception ex){
            result.success = false;
            result.messages.add(osf_Utility.createBeanMessage(ex));
            result.data = ex.getStackTraceString();
        }
        return result;
    }

    private static String calculate(Set<String> productIds){
        String calculatedTime = '';
        // retrieve products after updating stock values
        osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
        List<ccrz__E_Product__c> updatedProducts = [SELECT osf_provider_delivery_time__c, osf_in_stock_checkout__c, osf_in_stock__c FROM ccrz__E_Product__c WHERE Id IN: productIds];
        List<Decimal> providerTimes = new List<Decimal>();
        Boolean hasOutOfStock = false;

        for(ccrz__E_Product__c prod : updatedProducts){
            if(!prod.osf_in_stock_checkout__c){
                if(prod.osf_provider_delivery_time__c == null){
                    prod.osf_provider_delivery_time__c = config.osf_providertime_plus__c;
                }else{
                    prod.osf_provider_delivery_time__c += config.osf_providertime_plus__c;
                }
                providerTimes.add(prod.osf_provider_delivery_time__c);
                hasOutOfStock = true;
            }
        }
        
        if(hasOutOfStock){
            Decimal longestTime = 0;
            for(Decimal ptime : providerTimes){
                if(ptime > longestTime){
                    longestTime = ptime;
                }
            }
            if(longestTime > 0){
                calculatedTime = String.valueOf(longestTime);
            }else{
                calculatedTime = osf_constant_strings.STANDARD_DELIVERY_TIME_CHECKOUT;
            }
            
        }else{
            calculatedTime = osf_constant_strings.STANDARD_DELIVERY_TIME_CHECKOUT;
        }

        return calculatedTime;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult checkDefaultAddresses(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;

        Boolean hasDefaultBilling = false;
        Boolean hasDefaultShipping = false;
        List<ccrz__E_AccountAddressBook__c> addressBookList = new List<ccrz__E_AccountAddressBook__c>();
        Set<String> addressIdList = new Set<String>();
        try{
            // check default addresses 
            // List<ccrz__E_ContactAddr__c> contactAddresses = [SELECT Id FROM ccrz__E_ContactAddr__c WHERE OwnerId =: ccrz.cc_CallContext.currUserId];
            // if(contactAddresses.size() > 0){
            //     for(ccrz__E_ContactAddr__c con : contactAddresses){
            //         addressIdList.add(con.Id);
            //     }
            //     addressBookList =  [SELECT ccrz__AddressType__c FROM ccrz__E_AccountAddressBook__c WHERE ccrz__E_ContactAddress__c IN: addressIdList AND ccrz__Default__c = true];
            // }
            // ccrz.ccLog.log(LoggingLevel.DEBUG, 'addressBookList -----> ', addressBookList);
            // if(addressBookList.size() > 0){
            //     for(ccrz__E_AccountAddressBook__c addrbook : addressBookList){
            //         if(addrbook.ccrz__AddressType__c == osf_constant_strings.ADDRESS_TYPE_SHIPPING){
            //             hasDefaultShipping = true;
            //         }else if(addrbook.ccrz__AddressType__c == osf_constant_strings.ADDRESS_TYPE_BILLING){
            //             hasDefaultBilling = true;
            //         }
            //     }
            // }
            addressBookList = [SELECT ccrz__AddressType__c FROM ccrz__E_AccountAddressBook__c WHERE ccrz__Default__c = true AND ccrz__AccountId__c = :ccrz.cc_CallContext.currAccountId];
            for(ccrz__E_AccountAddressBook__c addressBook : addressBookList) {
                if(addressBook.ccrz__AddressType__c == osf_constant_strings.ADDRESS_TYPE_SHIPPING) {
                    hasDefaultShipping = true;
                } else if(addressBook.ccrz__AddressType__c == osf_constant_strings.ADDRESS_TYPE_BILLING) {
                    hasDefaultBilling = true;
                }
                if(hasDefaultBilling && hasDefaultShipping) {
                    break;
                }
            }
            
            result.success = true;
            data.put(osf_constant_strings.HAS_DEFAULT_SHIPPING, hasDefaultShipping);
            data.put(osf_constant_strings.HAS_DEFAULT_BILLING, hasDefaultBilling);
        }catch(Exception ex){
            result.success = false;
            result.messages.add(osf_Utility.createBeanMessage(ex));
            result.data = ex.getStackTraceString();
        }
        return result;
    }
}