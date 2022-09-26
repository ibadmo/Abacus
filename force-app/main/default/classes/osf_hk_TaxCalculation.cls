/**
 * File:        osf_hk_TaxCalculation.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 12, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Calculates the tax 
  ************************************************************************
 * History:
 */

global with sharing class osf_hk_TaxCalculation extends ccrz.cc_hk_TaxCalculation {
    
    /**********************************************************************************************
    * @Name         : getTaxAmount
    * @Description  : Overrides the OOTB getTaxAmount
    * @Created By   : Alina Craciunel
    * @Created Date : Feb 12, 2020
    * @param inputData: the B2B OOTB input data
    * @Return       : the total cart tax, as decimal
    *********************************************************************************************/
    global override Decimal getTaxAmount(Map<String, Object> inputData) {
        Decimal totalTaxAmount = 0;
        Id cartId = (Id) inputData.get(ccrz.cc_hk_TaxCalculation.PARAM_CARTID);
        try {
            Set<String> setCartItemIds = new Set<String>();
            List<ccrz__E_CartItem__c> lstCartItemsToUpdate = new List<ccrz__E_CartItem__c>();
            for (ccrz__E_CartItem__c cartItem : [SELECT Id, ccrz__Price__c, ccrz__Quantity__c, ccrz__Product__r.osf_tax_rate__c, ccrz__AbsoluteDiscount__c, 
                                                ccrz__ItemTotal__c, ccrz__PercentDiscount__c, osf_negotiated_discount__c 
                                                FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c =: cartId AND ccrz__Product__r.osf_tax_class__c != null]) {    
                Decimal negotiatedPrice = cartItem.osf_negotiated_discount__c != null ? cartItem.ccrz__Price__c - cartItem.ccrz__Price__c * cartItem.osf_negotiated_discount__c/100 : cartItem.ccrz__Price__c;
                Decimal tax = cartItem.ccrz__Product__r.osf_tax_rate__c != null ? negotiatedPrice * cartItem.ccrz__Product__r.osf_tax_rate__c/100 : 0;
                totalTaxAmount += tax * cartItem.ccrz__Quantity__c; 
            }    
            totalTaxAmount = totalTaxAmount.setScale(2, RoundingMode.HALF_EVEN); 
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:osf_hk_TaxCalculation:getTaxAmount:Error', e);
        }
        osf_utility.calculateShippingCost(cartId, totalTaxAmount);
        return totalTaxAmount;
    }
}