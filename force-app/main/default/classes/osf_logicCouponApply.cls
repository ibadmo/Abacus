/**
 * File:        osf_logicCouponApply.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        jan 21, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Applies directly negotiated coupons if the cart has no coupon at all
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global without sharing class osf_logicCouponApply extends ccrz.ccLogicCouponApply {
    
    /* 
    * @description  : Applies negotiated coupon if the cart has no coupon at all
    * @author       : Ozgun Eser
    * @createdDate  : Jan 21, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> addCoupon(Map<String, Object> inputData) {
        Map<String, Object> outputData = new Map<String, Object> ();
        try {
            ccrz__E_Cart__c cart = (ccrz__E_Cart__c) inputData.get(ccrz.ccAPICoupon.CART_HEADER);
            cart = [SELECT osf_coupon_removed_manually__c, (SELECT Id FROM ccrz__E_CartCoupons__r LIMIT 1) FROM ccrz__E_Cart__c WHERE Id = :cart.Id];
            String couponCode = (String) inputData.get(ccrz.ccAPICoupon.CODE);
            if(String.isBlank(couponCode) && !ccrz.cc_CallContext.isGuest && cart.ccrz__E_CartCoupons__r.isEmpty() && !cart.osf_coupon_removed_manually__c) {
                Set<String> productIdSet = new Set<String> ();
                for(ccrz__E_CartItem__c cartItem : (List<ccrz__E_CartItem__c>) inputData.get(ccrz.ccAPICoupon.CART_ITEMS)) {
                    productIdSet.add(cartItem.ccrz__Product__c);
                }
                inputData.put(ccrz.ccAPICoupon.CODE, getCouponByProduct(productIdSet));                        
            }
            outputData = super.addCoupon(inputData);
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:logicCouponApply:addCoupon:Error', e);
        }
        return outputData;
    }

    /* 
    * @description  : Creates a map of product Id to coupon code and returns it to specify if there is any productCode that will be applied
    * @author       : Ozgun Eser
    * @createdDate  : Jan 21, 2020
    * @param        : Set<String> productIdSet, productIdSet that discounts will apply
    * @return       : String coupon code to apply
    */
    private String getCouponByProduct(Set<String> productIdSet) {
        String couponCode = osf_utility.getNegotiatedCouponByProduct(productIdSet);
        if(String.isBlank(couponCode)) {
            Set<String> catalogIdSet = new Set<String> ();
            for(ccrz__E_Product__c product : [SELECT osf_catalog_id__c FROM ccrz__E_Product__c WHERE Id IN :productIdSet]) {
                if(String.isNotBlank(product.osf_catalog_id__c)) {
                    catalogIdSet.add(product.osf_catalog_id__c.substringBefore(osf_constant_strings.LINE));
                }
            }
            if(!catalogIdSet.isEmpty()) {
                couponCode = osf_utility.getNegotiatedCouponByCatalog(catalogIdSet);
            }
        }
        return couponCode; 
    }

    /* 
    * @description  : applyCoupons 
    * @author       : Alina Craciunel
    * @createdDate  : Apr 29, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> applyCoupons(Map<String, Object> inputData) {
        Map<String, Object> outputData = new Map<String, Object> ();
        try {
            outputData = super.applyCoupons(inputData);
            List<ccrz__E_CartItem__c> cartItemList = (List<ccrz__E_CartItem__c>) outputData.get(osf_constant_strings.COUPON_CART_ITEMS);
            for(ccrz__E_CartItem__c cartItem : cartItemList) {
                if (cartItem.ccrz__ProductType__c == osf_constant_strings.PRODUCT_TYPE_PRODUCT) {
                    Decimal absoluteDiscount = cartItem.ccrz__AbsoluteDiscount__c == null ? 0 : cartItem.ccrz__AbsoluteDiscount__c;
                    Decimal negotiatedDiscount = cartItem.osf_negotiated_discount__c == null ? 0 : cartItem.osf_negotiated_discount__c;
                    cartItem.ccrz__AdjustmentAmount__c = -negotiatedDiscount/100 * (cartItem.ccrz__Price__c * cartItem.ccrz__Quantity__c - absoluteDiscount); 
                }
            }
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:logicCouponApply:applyCoupons:Error', e);
        }
        return outputData;
    }
}