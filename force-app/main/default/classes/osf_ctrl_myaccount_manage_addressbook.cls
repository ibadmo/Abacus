/**
 * File:        osf_ctrl_myaccount_manage_addressbook.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 5, 2020
 * Created By:  Cansu Asli Asci
  ************************************************************************
 * Description: Controller class osf_myaccount_manage_address_book component.
  ***********************************************************************
 * History:
 * Date:                Modified By:            Description:
 */
global with sharing class osf_ctrl_myaccount_manage_addressbook {
    
   /* 
    * @description  : getProvinceList
    * @author       : Cansu Asli Asci
    * @createdDate  : Mar 5, 2020
    * @param        : ccrz.cc_RemoteActionContext context, 
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getProvinceList(ccrz.cc_RemoteActionContext context) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        try{
            List<osf_province_list__c> provinceList = osf_province_list__c.getall().values();
            if(provinceList.size() > 0){
                data.put(osf_constant_strings.ADDRESSBOOK_PROVINCELIST,transformProvinces(provinceList));
                result.success = true;
            }else{
                result.success = false;
                result.messages.add(new ccrz.cc_bean_Message('No province found', ccrz.cc_bean_Message.MessageSeverity.ERROR));
            }
            
        }catch(Exception ex){
            result.success = false;
            result.messages.add(osf_utility.createBeanMessage(ex));
        }
        return result;
    } 
    
    /* 
    * @description  : getAccountPaymentMethods
    * @author       : Cansu Asli Asci
    * @createdDate  : Mar 5, 2020
    * @param        : ccrz.cc_RemoteActionContext context, 
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getAccountPaymentMethods(ccrz.cc_RemoteActionContext context) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        try{
            Account account = [SELECT osf_validPaymentTypes__c FROM Account WHERE Id =: ccrz.cc_CallContext.currAccountId];
            data.put(osf_constant_strings.ADDRESSBOOK_PAYMENTMETHODS, account.osf_validPaymentTypes__c);
            result.success = true;
        }catch(Exception ex){
            result.success = false;
            result.messages.add(osf_utility.createBeanMessage(ex));
        }
        return result;
    } 

    private static List<Map<String, Object>> transformProvinces(List<osf_province_list__c> provincelist){
        List<Map<String, Object>> data = new List<Map<String, Object>> ();
        
        for(osf_province_list__c province : provincelist){
            data.add(
                new Map<String, Object>{
                    osf_constant_strings.ADDRESSBOOK_PROVINCENAME => province.Name
                }
            );
        }
        return data;
    }
}