/**
 * File:        osf_ServiceOrder.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 25, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Extension for Service Provider of CC Order Object
  ************************************************************************
 * History:
 */

global with sharing class osf_ServiceOrder extends ccrz.ccServiceOrder {

    @TestVisible private static final List<String> FIELD_LIST = new List<String> {'ccrz__Contact__r.Name', 'osf_placed_in_b2b_website__c', 'Owner.FirstName', 'Owner.LastName', 'osf_order_number__c'};

    /**********************************************************************************************
    * @Name         : getFieldsMap
    * @Description  : adds custom fields to CC Order Query.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFieldsMap(inputData);
        String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
        fields += osf_constant_strings.COMMA + String.join(FIELD_LIST, osf_constant_strings.COMMA);
        outputData.put(ccrz.ccService.OBJECTFIELDS, fields);
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'osf:serviceOrder:getFieldsMap:fields', fields);
        return outputData;
    }

    /**********************************************************************************************
    * @Name         : getFilterMap
    * @Description  : adds custom filters to CC Order Query's Where Clause.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> getFilterMap(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFilterMap(inputData);
        Object ownerIdFilter = outputData.remove(ccrz.ccAPICart.BYOWNER);
        return outputData;
    }
}