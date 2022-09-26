/**
 * File:        osf_ServiceCart.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 1, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Extension for Service Provider of CC Cart Object
  ************************************************************************
 * History:
 */

global with sharing class osf_ServiceCart extends ccrz.ccServiceCart {

    @TestVisible private static final List<String> FIELD_LIST = new List<String> {'ccrz__Account__r.osf_free_shipment__c', 'osf_submitted_to__c', 'osf_submitted_to_2__c', 'CreatedBy.Name', 'osf_is_submitted__c', 'osf_status__c', 'LastModifiedBy.Name'};

    global override Map<String, Object> getFieldsMap (Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFieldsMap(inputData);
        String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
        fields += osf_constant_strings.COMMA + String.join(FIELD_LIST, osf_constant_strings.COMMA);
        outputData.put(ccrz.ccService.OBJECTFIELDS, fields);
        return outputData;
    }

    /**********************************************************************************************
    * @Name         : getFilterMap
    * @Description  : adds custom filters to CC Cart Query's Where Clause.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> getFilterMap(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFilterMap(inputData);
        Object ownerIdFilter = outputData.remove(ccrz.ccAPICart.BYOWNER);
        return outputData;
    }

    /**********************************************************************************************
    * @Name         : prepReturn
    * @Description  : Modifying returned JSON model of CC Cart Service.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> prepReturn(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.prepReturn(inputData);
        try {
            if(ccrz.cc_CallContext.currPageName.contains(osf_constant_strings.CART_PAGE) || ccrz.cc_CallContext.currPageName.contains(osf_constant_strings.CHECKOUT_PAGE)) {
                outputData = calculateTax(outputData);
            } else if(ccrz.cc_CallContext.currPageName.contains(osf_constant_strings.MY_ACCOUNT_PAGE)) {
                outputData = prepareMyCartsModel(outputData);
            }
            if(ccrz.cc_CallContext.currPageName.contains(osf_constant_strings.CART_PAGE)) {
                outputData = updateAvailabilityInformation(outputData);
            }
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:serviceCart:prepReturn:Error', e);
        }
        return outputData;
    }

    /**********************************************************************************************
    * @Name         : calculateTax
    * @Description  : Calculate tax for Cart and Checkout Shipping page.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, outputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    private static Map<String, Object> calculateTax(Map<String, Object> outputData) {
        Decimal totalVat = 0.00;
        List<Map<String, Object>> cartMapList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICart.CART_OBJLIST);
        Map<String, Object> cartMap = cartMapList[0];
        for(Map<String, Object> cartItemMap : (List<Map<String, Object>>) cartMap.get(osf_constant_strings.CART_ITEMS)) {
            Decimal vat = cartItemMap.containsKey(osf_constant_strings.OSF_VAT_RATE_TOTAL) ? (Decimal) cartItemMap.get(osf_constant_strings.OSF_VAT_RATE_TOTAL) : 0.00;
            totalVat += vat;
        }
        cartMap.put(osf_constant_strings.TAX, totalVat);
        Decimal shipAmount = osf_utility.calculateShippingCost((String) cartMap.get(osf_constant_strings.SFID), totalVat);
        cartMap.put(osf_constant_strings.SHIP_AMOUNT, shipAmount);
        Decimal subtotalAmount = (Decimal) cartMap.get(osf_constant_strings.SUBTOTAL_AMOUNT);
        Decimal shipDiscountAmount = cartMap.get(osf_constant_strings.SHIP_DISCOUNT_AMOUNT) != null ? (Decimal) cartMap.get(osf_constant_strings.SHIP_DISCOUNT_AMOUNT) : 0;
        Decimal adjustmentAmount = cartMap.get(osf_constant_strings.ADJUSTMENT_AMOUNT) != null ? (Decimal) cartMap.get(osf_constant_strings.ADJUSTMENT_AMOUNT) : 0;
        Decimal surchargeAmount = cartMap.get(osf_constant_strings.SURCHARGE_AMOUNT) != null ? (Decimal) cartMap.get(osf_constant_strings.SURCHARGE_AMOUNT) : 0;
        Decimal totalAmount = shipAmount + subtotalAmount + totalVat + shipDiscountAmount + adjustmentAmount + surchargeAmount;
        cartMap.put(osf_constant_strings.TOTAL_AMOUNT, totalAmount);
        return outputData;
    }

    /**********************************************************************************************
    * @Name         : prepareMyCartsModel
    * @Description  : Prepares My Carts page Model by adding required values.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, outputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    private static Map<String, Object> prepareMyCartsModel(Map<String, Object> outputData) {
        //prepare cart name
        Set<String> cartSFIDs = new Set<String>();
        List<ccrz__E_Cart__c> carts = new List<ccrz__E_Cart__c>();
        Map<String, String> cartSFIDcartNameMap = new  Map<String, String>();
        for(Map<String, Object> cartMap : (List<Map<String, Object>>) outputData.get(ccrz.ccAPICart.CART_OBJLIST)) {
            cartSFIDs.add((String)cartMap.get(osf_constant_strings.SFID));
        }
        carts = [SELECT Name, Id FROM ccrz__E_Cart__c WHERE Id IN:cartSFIDs];
        for(ccrz__E_Cart__c cart : carts){
            cartSFIDcartNameMap.put(cart.Id, cart.Name);
        }
        for(Map<String, Object> cartMap : (List<Map<String, Object>>) outputData.get(ccrz.ccAPICart.CART_OBJLIST)) {
            
            String cartName = osf_constant_strings.EMPTY_STRING;
            cartName = osf_constant_strings.CART_NAME_TAG + cartSFIDcartNameMap.get((String)cartMap.get(osf_constant_strings.SFID));
            cartMap.put(osf_constant_strings.MYUSERS_NAME,(String)cartName);
            Boolean disableButtons = false;
            Boolean isSubmitted = (Boolean) cartMap.get(osf_constant_strings.IS_SUBMITTED);
            String submittedTo = (String) cartMap.get(osf_constant_strings.SUBMITTED_TO);
            String submittedTo2 = (String) cartMap.get(osf_constant_strings.SUBMITTED_TO_2);
            String currentContactId = ccrz.cc_CallContext.currContact.Id;
            if(isSubmitted && currentContactId != submittedTo && currentContactId != submittedTo2) {
                disableButtons = true;
            }
            cartMap.put(osf_constant_strings.DISABLE_BUTTONS, disableButtons);
        }
        return outputData;
    }

    /**********************************************************************************************
    * @Name         : updateAvailabilityInformation
    * @Description  : update in stock information for each product
    * @Created By   : Alina Craciunel
    * @param        : Map<String, Object> outputData
    * @Return       : Map<String, Object> outputData
    *********************************************************************************************/
    private static Map<String, Object> updateAvailabilityInformation(Map<String, Object> outputData) {
        Map<Id, Decimal> mapProductIdQuantity = new Map<Id, Decimal>();
        Map<Id, String> mapProductIdSku = new Map<Id, String>();
        List<Map<String, Object>> cartMapList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICart.CART_OBJLIST);
        Map<String, Object> cartMap = cartMapList[0];
        for(Map<String, Object> cartItemMap : (List<Map<String, Object>>) cartMap.get(osf_constant_strings.CART_ITEMS)) {
            Map<String, Object> mapProduct = (Map<String, Object>)cartItemMap.get(osf_constant_strings.PRODUCT_RELATIONSHIP);
            mapProductIdQuantity.put((String) mapProduct.get(osf_constant_strings.SFID), (Decimal) cartItemMap.get(osf_constant_strings.QUANTITY));
            mapProductIdSku.put((String) mapProduct.get(osf_constant_strings.SFID), (String) mapProduct.get(osf_constant_strings.SKU));
        }
        Map<String, Boolean> mapInStock = osf_utility.getStockInfo(mapProductIdQuantity, mapProductIdSku);
        List<Map<String, Object>> lstCartItems = new List<Map<String, Object>>();
        osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
        Decimal standardDeliveryTime = config.Standard_delivery_time__c;
        for(Map<String, Object> cartItemMap : (List<Map<String, Object>>) cartMap.get(osf_constant_strings.CART_ITEMS)) {
            Map<String, Object> mapProduct = (Map<String, Object>)cartItemMap.get(osf_constant_strings.PRODUCT_RELATIONSHIP);
            Decimal providertime_plus3 = (Decimal) cartItemMap.get(osf_constant_strings.PROVIDER_DELIVERY);
            providertime_plus3 = providertime_plus3 + config.osf_providertime_plus__c;//FSD requires 3 days to be added to provider time in cart detail
            cartItemMap.put(osf_constant_strings.IN_STOCK, mapInStock.get((String) mapProduct.get(osf_constant_strings.SKU)) ? String.valueOf(standardDeliveryTime) + osf_constant_strings.DELIVERY_TIME_IN_HOURS : (integer)(providertime_plus3/24).round(system.RoundingMode.CEILING) + osf_constant_strings.DELIVERY_TIME_IN_DAYS);  
            lstCartItems.add(cartItemMap);
        }
        cartMap.put(osf_constant_strings.CART_ITEMS, lstCartItems);
        return outputData;
    }
}