/**
 * File:        osf_LogicCartAddTo.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 31, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Overrides Out of Box B2B Commerce Functionality to add item to cart.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global with sharing class osf_LogicCartAddTo extends ccrz.ccLogicCartAddTo {

    /* 
    * @description  : Overrides pricing to apply negotiated prices
    * @author       : Ozgun Eser
    * @createdDate  : Mar 31, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> handlePricing(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.handlePricing(inputData);
        if(ccrz.cc_CallContext.isGuest) {
            return outputData;
        }
        try {
            ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) outputData.get(ccrz.ccAPICart.CURR_CARTITEM);
            Map<String, Object> product = (Map<String, Object>) outputData.get(ccrz.ccAPICart.CURR_PRODUCT);
            Decimal discountAmount = (Decimal) product.get(osf_constant_strings.DISCOUNT_AMOUNT);
            Decimal discountRate = (Decimal) product.get(osf_constant_strings.DISCOUNT_RATE);
            if(discountAmount != null) {
                cartItem.ccrz__AdjustmentAmount__c = -(discountAmount * cartItem.ccrz__OriginalQuantity__c);
            }
            if(discountRate != null) {
                cartItem.osf_negotiated_discount__c = discountRate;
            }
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:logicCartAddTo:handlePricing:Error', e);
        }    
        return outputData;   
    } 
}