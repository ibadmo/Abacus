/**
 * File:        osf_ServiceCartItem.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 21, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Extension for Service Provider of CC Cart item
  ************************************************************************
 * History:
 */

global with sharing class osf_ServiceCartItem extends ccrz.ccServiceCartItem {

    @TestVisible private static final List<String> FIELD_LIST = new List<String> {'osf_vat_rate_total__c', 'osf_provider_delivery_time__c', 'osf_negotiated_discount__c', 'osf_total_unit_price_with_discounts__c', 'osf_total_up_with_discounts_and_vat__c', 'osf_unit_price_with_discounts__c'};
    
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