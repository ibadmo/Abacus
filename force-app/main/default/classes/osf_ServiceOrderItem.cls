/**
 * File:        osf_ServiceOrderItem.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Apr 30, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Extension for Service Provider of CC Order item
  ************************************************************************
 * History:
 */

global with sharing class osf_ServiceOrderItem extends ccrz.ccServiceOrderItem {

    @TestVisible private static final List<String> FIELD_LIST = new List<String> {'osf_negotiated_price__c', 'osf_total_negotiated_price__c', 'osf_total_tax__c', 'osf_total__c'};
    
    /**********************************************************************************************
    * @Name         : getFieldsMap
    * @Description  : adds custom fields to CC Cart Item Query.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFieldsMap(inputData);
        String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
        fields += osf_constant_strings.COMMA + String.join(FIELD_LIST, osf_constant_strings.COMMA);
        outputData.put(ccrz.ccService.OBJECTFIELDS, fields);
        return outputData;
    }
}