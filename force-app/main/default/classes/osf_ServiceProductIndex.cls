/**
 * File:        osf_ServiceProductIndex.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        May 31, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Extension for Service Provider of CC Product Index Object
  ************************************************************************
 * History:
 */

global with sharing class osf_ServiceProductIndex extends ccrz.ccServiceProductIndex {

    @TestVisible private static final String FILTER_PRODUCT_TYPE =  'productType';
    @TestVisible private static final String PRODUCT_TYPE_WHERE_CLAUSE = ' AND Product__r.ProductType__c != \'Aggregated\' ';
    @TestVisible private static final String QUERY_END = 'Storefront__c INCLUDES (:piStorefront)';
    
    /**********************************************************************************************
    * @Name         : getFilterMap
    * @Description  : adds custom filters to CC Product Index Query's Where Clause.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> getFilterMap(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFilterMap(inputData);
        outputData.put(FILTER_PRODUCT_TYPE, PRODUCT_TYPE_WHERE_CLAUSE);
        return outputData;
    }

    /**********************************************************************************************
    * @Name         : buildSearchQuery
    * @Description  : adds custom filters to CC Product Index Search Query's Where Clause.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> buildSearchQuery(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.buildSearchQuery(inputData);
        String queryString = (String) outputData.get(ccrz.ccService.QUERYSTRING);
        queryString = queryString.replace(QUERY_END, QUERY_END + PRODUCT_TYPE_WHERE_CLAUSE);
        outputData.put(ccrz.ccService.QUERYSTRING, queryString);
        return outputData;
    }
}