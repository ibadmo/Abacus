/**
 * File:        osf_ServiceAccount.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 1, 2020
 * Created By:  Cansu Asli Asci
  ************************************************************************
 * Description: Extension for Service Provider of Account Object
  ************************************************************************
 * History:
 */
global with sharing class osf_ServiceAccount extends ccrz.ccServiceAccount{
    
    @TestVisible private static final List<String> FIELD_LIST = new List<String> {'osf_validPaymentTypes__c'};
    

    /**********************************************************************************************
    * @Name         : getFieldsMap
    * @Description  : adds custom fields
    * @Created By   : Cansu Asli Asci
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> getFieldsMap (Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFieldsMap(inputData);
        String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
        fields += osf_constant_strings.COMMA + String.join(FIELD_LIST, osf_constant_strings.COMMA);
        outputData.put(ccrz.ccService.OBJECTFIELDS, fields);
        return outputData;
    }

    /**********************************************************************************************
    * @Name         : prepReturn
    * @Description  : Modifying returned JSON model of Account Service.
    * @Created By   : Cansu Asli Asci
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> prepReturn(Map<String, Object> inputData) {
        Map<String,Object> outputData = super.prepReturn(inputData);
        try {
            if(ccrz.cc_CallContext.currPageName.contains(osf_constant_strings.MY_ACCOUNT_PAGE)){
                Map<String,osf_province_list__c> provinceMap = osf_province_list__c.getall();
                Set<String> provinceNameSet = provinceMap.keySet();
                List<String> provinceNames = new List<String>(provinceNameSet);
                provinceNames.sort();
                
                List<Object> accountList = (List<Object>) outputData.get(ccrz.ccApiAccount.ACCOUNTS);
                for(Object acc : accountList) {
                    Map<String, Object> account = (Map<String, Object>)acc;
                    account.put(osf_constant_strings.ACCOUNT_PROVINCE_LIST, provinceNames);
                }
            }
                
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:ServiceAccount:prepReturn:Error', e);
        }
        return outputData;
    }
}