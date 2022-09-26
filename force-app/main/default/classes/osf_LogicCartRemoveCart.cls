/**
 * File:        osf_LogicCartRemoveCart.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 25, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Deletes cart
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global without sharing class osf_LogicCartRemoveCart extends ccrz.ccLogicCartRemoveCart {

    /* 
    * @description  : Delete Cart
    * @author       : Ozgun Eser
    * @createdDate  : Mar 25, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> removeCart(Map<String, Object> inputData) {
        String cartId = (String) inputData.get(ccrz.ccAPICart.CART_ID);
        ccrz__E_Cart__c cart = [SELECT Id, OwnerId FROM ccrz__E_Cart__c WHERE Id = :cartId];
        if(cart.OwnerId != ccrz.cc_CallContext.currUserId) {
            cart.OwnerId = ccrz.cc_CallContext.currUserId;
            update cart;
        }
        Map<String, Object> outputData = super.removeCart(inputData);
        return outputData;
    }
}