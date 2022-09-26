/**
 * File:        osf_ctrl_myaccount_mycarts.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 28, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Controller class osf_myaccount_mycarts component.
  ***********************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global with sharing class osf_ctrl_myaccount_mycarts {
    
    /* 
    * @description  : Fetch Cart Items
    * @author       : Ozgun Eser
    * @createdDate  : Feb 28, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @param        : String cartId
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult fetchCartItems(ccrz.cc_RemoteActionContext context, String cartId) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        try {
            ccrz__E_Cart__c cart = [SELECT Id, ccrz__SubtotalAmount__c, ccrz__AdjustmentAmount__c, ccrz__TaxAmount__c, ccrz__ShipAmount__c FROM ccrz__E_Cart__c WHERE Id = :cartId];
            Map<String, Object> cartItemInput = new Map<String, Object> {
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                ccrz.ccAPI.SIZING => new Map<String, Object> {
                    new osf_ServiceCart().ENTITYNAME => new Map<String, Object> {
                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                    }
                },
                ccrz.ccAPICart.CART_IDLIST => new Set<String> {cartId}
            };
            Map<String, Object> cartItemMap = ccrz.ccAPICart.fetchCartItems(cartItemInput);
            Map<String, Object> productMap = osf_utility.fetchProducts((Set<String>) cartItemMap.get(ccrz.ccAPICart.CARTITEMPRODUCTIDS), true, true);
            Map<String, Map<String, Object>> productIdToProductMap = new Map<String, Map<String, Object>> ();
            if(productMap.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {
                for(Map<String, Object> productData : (List<Map<String, Object>>) productMap.get(ccrz.ccAPIProduct.PRODUCTLIST)) {
                    productData.put('sku', productData.get('SKU'));
                    productIdToProductMap.put((String) productData.get(osf_constant_strings.SFID), productData);
                }
            }
            Map<String, List<Map<String, Object>>> cartItemsById = (Map<String, List<Map<String, Object>>>) cartItemMap.get(ccrz.ccAPICart.CARTITEMSBYID);
            Decimal totalVat = 0;
            for(List<Map<String, Object>> cartItemList : cartItemsById.values()) {
                for(Map<String, Object> cartItemData : cartItemList) {
                    cartItemData.put(osf_constant_strings.PRODUCT_DATA, productIdToProductMap.get((String) cartItemData.get(ccrz.ccAPIProduct.PRODUCT)));
                    Decimal vat = (Decimal) cartItemData.get(osf_constant_strings.OSF_VAT_RATE_TOTAL);
                    totalVat += vat == null ? 0 : vat;
                }
            }
            data.put(osf_constant_strings.CART_ITEMS, cartItemsById.values());
            cart.ccrz__TaxAmount__c = totalVat;
            cart.ccrz__ShipAmount__c = osf_utility.calculateShippingCost(cartId, totalVat);
            if(cart.ccrz__ShipAmount__c == null) {
                cart.ccrz__ShipAmount__c = 0;
            }
            if(cart.ccrz__AdjustmentAmount__c == null) {
                cart.ccrz__AdjustmentAmount__c = 0;
            }
            Decimal totalAmount = cart.ccrz__ShipAmount__c + cart.ccrz__SubtotalAmount__c + totalVat + cart.ccrz__AdjustmentAmount__c;
            data.put(osf_constant_strings.CART_TYPE_CART, cart);
            data.put(osf_constant_strings.TOTAL_AMOUNT, totalAmount);
            result.success = true;
        } catch (Exception e) {
            System.debug('Exception is -----> ' + e.getMessage() + osf_constant_strings.ERROR_STACKTRACE + e.getStackTraceString());
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }

    /* 
    * @description  : Sets the cart as active and deactive current cart.
    * @author       : Ozgun Eser
    * @createdDate  : Mar 24, 2020
    * @param        : ccrz.cc_RemoteActionContext context, 
    * @param        : String cartId
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult changeActiveCart(ccrz.cc_RemoteActionContext context, String cartId) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        try {
            List<ccrz__E_Cart__c> cartList = [SELECT Id, ccrz__ActiveCart__c, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :cartId OR ccrz__EncryptedId__c = :context.currentCartId];
            for(ccrz__E_Cart__c cart : cartList) {
                cart.ccrz__ActiveCart__c = cart.ccrz__EncryptedId__c == cartId;
            }
            update cartList;
            result.success = true;
        } catch (Exception e) {
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }
}