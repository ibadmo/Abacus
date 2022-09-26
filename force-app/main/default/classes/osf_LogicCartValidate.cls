/**
 * File:        osf_LogicCartValidate.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 10, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: override logic provider to allow or prevent proceeding to Checkout 
  ************************************************************************
 * History:
 */

global with sharing class osf_LogicCartValidate extends ccrz.ccLogicCartValidate {
    
    /**********************************************************************************************
    * @Name             : processValidate
    * @Description      : override validate method and check osf_allow_checkout__c from contact
    * @Created By       : Ozgun Eser
    * @Created Date     : Feb 10, 2020
    * @param inputData  : Map<String, Object> inputDate
    * @Return           : Map<String, Object> outputData
    *********************************************************************************************/
    global override Map<String, Object> processValidate(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.processValidate(inputData);
        if(!ccrz.cc_CallContext.isGuest) {
            Contact contact = [SELECT osf_allow_checkout__c FROM Contact WHERE Id = :ccrz.cc_CallContext.currContact.Id];
            outputData.put(ccrz.ccAPICart.ALLOW_CHECKOUT, contact.osf_allow_checkout__c);
        }
        return outputData;       
    }
}