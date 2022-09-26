/**
 * File:        osf_servicePromotion.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Jan 8, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Extension for Service Provider of CC Promotion Object
  ************************************************************************
 * History:
 */

global with sharing class osf_servicePromotion extends ccrz.ccServicePromotion {
    
    /**********************************************************************************************
    * @Name         : getFilterMap
    * @Description  : adds custom filters to CC Promotion Query's Where Clause.
    * @Created By   : Ozgun Eser
    * @param        : Map<String, Object>, inputData
    * @Return       : Map<String, Object>, outputData
    *********************************************************************************************/
    global override Map<String, Object> getFilterMap(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.getFilterMap(inputData);
        try {
            Set<String> promotionIdSet = new Set<String> ();
            for(osf_account_promotion__c accountPromotion : [SELECT Id, osf_promotion__c FROM osf_account_promotion__c WHERE osf_account__c = :ccrz.cc_CallContext.currAccountId]) {
                promotionIdSet.add(accountPromotion.osf_promotion__c);
            }
            if(promotionIdSet.isEmpty()) {
                outputData.put(osf_constant_strings.DEFAULT_PROMOTIONS, osf_constant_strings.ACCOUNT_PROMOTION_DEFAULT_FILTER);
            } else {
                String queryFilter = osf_constant_strings.ACCOUNT_PROMOTION_FILTER_BEGIN;
                for(String promotionId : promotionIdSet) {
                    queryFilter += osf_constant_strings.ACCOUNT_PROMOTION_FILTER_ID + promotionId + osf_constant_strings.ACCOUNT_PROMOTION_FILTER_OR;
                }
                queryFilter = queryFilter.removeEnd(osf_constant_strings.QUERY_OR + osf_constant_strings.EMPTY_SPACE);
                queryFilter += osf_constant_strings.CLOSE_PARANTHESIS;
                outputData.put(osf_constant_strings.ACCOUNT_SPECIFIC_PROMOTIONS, queryFilter);
            }
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:servicePromotion:getFilterMap:Error', e);
        }
        return outputData;
    }

}