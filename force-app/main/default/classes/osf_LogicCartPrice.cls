/**
 * File:        osf_LogicCartPrice.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 31, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Overrides Out of Box B2B Commerce Functionality of cart pricing.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */
global with sharing class osf_LogicCartPrice extends ccrz.ccLogicCartPrice {
    
    /* 
    * @description  : Overrides pricing to apply negotiated prices
    * @author       : Ozgun Eser
    * @createdDate  : Mar 31, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> applyPricing(Map<String, Object> inputData) { //prepareCartItems
        Map<String, Object> outputData = super.applyPricing(inputData);
        try {
            ccrz__E_Cart__c cart = (ccrz__E_Cart__c) outputData.get(osf_constant_strings.CART_TO_PRICE);
            Set<String> cartItemIdSet = new Set<String> ();
            Map<Id, ccrz__E_CartItem__c> cartItemMap = new Map<Id, ccrz__E_CartItem__c> ([SELECT Id, ccrz__AdjustmentAmount__c, ccrz__ProductType__c, osf_negotiated_discount__c, ccrz__Quantity__c, ccrz__Price__c, ccrz__SubAmount__c, ccrz__Product__c, ccrz__AbsoluteDiscount__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :cart.Id]); 
            Set<String> productIdSet = new Set<String> ();
            for(ccrz__E_CartItem__c cartItem : cartItemMap.values()) {
                productIdSet.add(cartItem.ccrz__Product__c);
            }
            Map<String, Decimal> ccProductIdToDiscountMap = osf_utility.getDiscountByProduct(productIdSet);
            List<ccrz__E_CartItem__c> cartItemToPriceList = (List<ccrz__E_CartItem__c>) outputData.get(osf_constant_strings.CART_ITEMS_TO_PRICE);
            calculate(cartItemToPriceList, ccProductIdToDiscountMap, cartItemMap);
            List<ccrz__E_CartItem__c> cartItemList = (List<ccrz__E_CartItem__c>) outputData.get(ccrz.ccAPICart.CILIST);
            calculate(cartItemList, ccProductIdToDiscountMap, cartItemMap);
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:logicCartPrice:prepareCartItems:Error', e);
        }
        return outputData;
    }

    /* 
    * @description  : Overrides pricing to apply negotiated prices
    * @author       : Ozgun Eser
    * @createdDate  : Mar 31, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> applyCoupons(Map<String, Object> inputData) { //prepareCartItems
        Map<String, Object> outputData = super.applyCoupons(inputData);
        try {
            List<ccrz__E_CartItem__c> cartItemToPriceList = (List<ccrz__E_CartItem__c>) outputData.get(osf_constant_strings.CART_ITEMS_TO_PRICE);
            calculateCoupons(cartItemToPriceList);
            List<ccrz__E_CartItem__c> cartItemList = (List<ccrz__E_CartItem__c>) outputData.get(ccrz.ccAPICart.CILIST);
            calculateCoupons(cartItemList);
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:logicCartPrice:prepareCartItems:Error', e);
        }
        return outputData;
    }

    /* 
    * @description  : calculates amounts
    * @author       : Alina Craciunel
    * @createdDate  : Apr 29, 2020
    * @param        : List<ccrz__E_CartItem__c> cartItemList
    * @param        : Map<String, Decimal> ccProductIdToDiscountMap
    * @return       : 
    */
    private void calculate(List<ccrz__E_CartItem__c> cartItemList, Map<String, Decimal> ccProductIdToDiscountMap, Map<Id, ccrz__E_CartItem__c> cartItemMap) {
        for(ccrz__E_CartItem__c cartItem : cartItemList) {
            if (cartItemMap.get(cartItem.Id).ccrz__ProductType__c == osf_constant_strings.PRODUCT_TYPE_PRODUCT) {
                if(ccProductIdToDiscountMap.containsKey(cartItem.ccrz__Product__c)) {
                    cartItem.osf_negotiated_discount__c = ccProductIdToDiscountMap.get(cartItem.ccrz__Product__c);
                } else {
                    cartItem.osf_negotiated_discount__c = 0;
                }
                Decimal absoluteDiscount = cartItem.ccrz__AbsoluteDiscount__c == null ? 0 : cartItem.ccrz__AbsoluteDiscount__c;
                cartItem.ccrz__AdjustmentAmount__c = -cartItem.osf_negotiated_discount__c/100 * (cartItem.ccrz__Price__c * cartItem.ccrz__Quantity__c - absoluteDiscount); 
                //cartItem.ccrz__AdjustmentAmount__c = -cartItem.osf_negotiated_discount__c/100 * cartItemMap.get(cartItem.Id).ccrz__SubAmount__c; 
                //cartItem.ccrz__AdjustmentAmount__c = cartItemMap.get(cartItem.Id).osf_negotiated_discount__c != null ? -cartItemMap.get(cartItem.Id).osf_negotiated_discount__c/100 * cartItemMap.get(cartItem.Id).ccrz__SubAmount__c : 0; 
                //cartItem.osf_negotiated_discount__c = cartItemMap.get(cartItem.Id).osf_negotiated_discount__c;
            }
        }
    }

    /* 
    * @description  : calculates ccrz__AdjustmentAmount__c
    * @author       : Alina Craciunel
    * @createdDate  : Apr 29, 2020
    * @param        : List<ccrz__E_CartItem__c> cartItemList
    * @return       : 
    */
    private void calculateCoupons(List<ccrz__E_CartItem__c> cartItemList) {
        for(ccrz__E_CartItem__c cartItem : cartItemList) {
            if (cartItem.ccrz__ProductType__c == osf_constant_strings.PRODUCT_TYPE_PRODUCT) {
                Decimal absoluteDiscount = cartItem.ccrz__AbsoluteDiscount__c == null ? 0 : cartItem.ccrz__AbsoluteDiscount__c;
                Decimal negotiatedDiscount = cartItem.osf_negotiated_discount__c == null ? 0 : cartItem.osf_negotiated_discount__c;
                cartItem.ccrz__AdjustmentAmount__c = -negotiatedDiscount/100 * (cartItem.ccrz__Price__c * cartItem.ccrz__Quantity__c - absoluteDiscount); 
            }
        }
    }
}