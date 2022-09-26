/**
 * File:        osf_logicCouponApply.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        jan 21, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Applies directly negotiated coupons if the cart has no coupon at all
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global without sharing class osf_LogicCartGetActive extends ccrz.ccLogicCartGetActive {
    
    /* 
    * @description  : Get Active Cart
    * @author       : Ozgun Eser
    * @createdDate  : Jan 21, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> fetchActive(Map<String, Object> inputData) {
        try {
            if(ccrz.cc_CallContext.isGuest) {
                return super.fetchActive(inputData);
            }
            inputData.put(ccrz.ccApiCart.GETACTIVE_UPDATE, false);
            String oldCartEncryptedId = (String) inputData.get(ccrz.ccAPICart.CART_ENCID);
            List<ccrz__E_Cart__c> cart = [SELECT Id, ccrz__ActiveCart__c FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :oldCartEncryptedId];
            if(!cart.isEmpty()) {
                List<ccrz__E_Cart__Share> cartShareList = [SELECT AccessLevel FROM ccrz__E_Cart__Share WHERE ParentId = :cart[0].Id AND UserOrGroupId = :ccrz.cc_CallContext.currUserId LIMIT 1];
                if(!cartShareList.isEmpty() && cartShareList[0].AccessLevel != osf_constant_strings.ACCESS_LEVEL_READ && !Test.isRunningTest()) {
                    return super.fetchActive(inputData);
                }
            }
            String cartId = osf_constant_strings.EMPTY_STRING;
            String cartEncryptedId = osf_constant_strings.EMPTY_STRING;
            List<ccrz__E_Cart__c> cartList = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE OwnerId = :ccrz.cc_CallContext.currUserId AND ccrz__CartStatus__c = :osf_constant_strings.CART_STATUS_OPEN AND ccrz__CartType__c = :osf_constant_strings.CART_TYPE_CART AND ccrz__ActiveCart__c = true ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1];
            if(!cartList.isEmpty()) {
                cartId = cartList[0].Id;
                cartEncryptedId = cartList[0].ccrz__EncryptedId__c;
            }
            inputData.put(ccrz.ccApiCart.CART_ID, cartId);
            inputData.put(ccrz.ccAPICart.CART_ENCID, cartEncryptedId);
            inputData.put(osf_constant_strings.GAC_CART_ID_LIST, new Set<String> {cartId});
            inputData.put(osf_constant_strings.GAC_CART_ENCRYPTED_ID_LIST, new Set<String> {cartEncryptedId});
            Map<String, Object> outputData = super.fetchActive(inputData);
            return outputData;
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:LogicCartGetActive:fetchActive:Error', e);
            return super.fetchActive(inputData);
        }
    }
}