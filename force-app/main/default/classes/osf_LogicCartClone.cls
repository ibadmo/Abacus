/**
 * File:        osf_LogicCartClone.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 25, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Clones the cart
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global with sharing class osf_LogicCartClone extends ccrz.ccLogicCartClone {
    
    /* 
    * @description  : Making sure that the current user will be the owner of the cloned cart to prevent any errors for submitted carts.
    * @author       : Ozgun Eser
    * @createdDate  : Mar 25, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> doDML(Map<String, Object> inputData) {
        ccrz__E_Cart__c cart = (ccrz__E_Cart__c) inputData.get(ccrz.ccLogicCartClone.CART_TO_INSERT);
        cart.OwnerId = ccrz.cc_CallContext.currUserId;
        cart.osf_submitted_to__c = null;
        cart.osf_submitted_to_2__c = null;
        cart.ccrz__User__c = ccrz.cc_CallContext.currUserId;
        cart.ccrz__Contact__c = ccrz.cc_CallContext.currContact.Id;
        inputData.put(ccrz.ccLogicCartClone.CART_TO_INSERT, cart);
        return super.doDML(inputData);
    }
}