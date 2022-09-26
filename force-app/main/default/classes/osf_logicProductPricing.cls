/**
 * File:        osf_logicProductPricing.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        jan 20, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Overrides Out of Box B2B Commerce Pricing Functionality to Apply Negotiated Discount
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global with sharing class osf_logicProductPricing extends ccrz.ccLogicProductPricing {

    /* 
    * @description  : Overrides pricing to apply negotiated prices
    * @author       : Ozgun Eser
    * @createdDate  : Mar 31, 2020
    * @param        : Map<String, Object> inputData, B2B Commerce OOTB Input Data
    * @return       : Map<String, Object> output data
    */
    global override Map<String, Object> prepReturnData(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.prepReturnData(inputData);
        try {
            Set<String> productIdSet = new Set<String> ();
            List<Map<String, Object>> productList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPIProduct.PRODUCTLIST);
            List<Map<String, Object>> lstCompositeProducts;
            for(Map<String, Object> productMap : productList) {
                productIdSet.add((String) productMap.get(osf_constant_strings.SFID));
                if (productMap.containsKey(osf_constant_strings.COMPOSITE_PRODUCTS_S)) {
                    lstCompositeProducts = (List<Map<String, Object>>)productMap.get(osf_constant_strings.COMPOSITE_PRODUCTS_S);
                }
            }
            Map<String, Decimal> ccProductIdToDiscountMap = osf_utility.getDiscountByProduct(productIdSet);
            for(Map<String, Object> productMap : productList) {
                String productId = (String) productMap.get('sfid');
                if(ccProductIdToDiscountMap.containsKey(productId)) {
                    Decimal discountRate = ccProductIdToDiscountMap.get(productId);
                    Decimal price = (Decimal) productMap.get(osf_constant_strings.PRICE);                    
                    Decimal discountedPrice = price * (1 - discountRate / 100);
                    Decimal discountAmount = price - discountedPrice;
                    productMap.put(osf_constant_strings.DISCOUNT_RATE, discountRate.setScale(2, System.RoundingMode.HALF_UP));
                    productMap.put(osf_constant_strings.DISCOUNTED_PRICE, discountedPrice.setScale(2, System.RoundingMode.HALF_UP));
                    productMap.put(osf_constant_strings.DISCOUNT_AMOUNT, discountAmount.setScale(2, System.RoundingMode.HALF_UP));
                }
            }
            if(ccrz.cc_CallContext.currPageName.contains(osf_constant_strings.PDP_PAGE)){
                Map<String,Object> pricingData = (Map<String,Object>)outputData.get(osf_constant_strings.PRODUCT_PRICING_DATA);
                productIdSet.clear();
                ccProductIdToDiscountMap.clear();
                for(String pid : pricingData.keySet()){
                    productIdSet.add(pid);
                }
                ccProductIdToDiscountMap = osf_utility.getDiscountByProduct(productIdSet);
                Map<String, Decimal> mapProductDiscountedPrice = new Map<String, Decimal>();
                Map<String, Decimal> mapProductDiscountedPriceWithTax = new Map<String, Decimal>();
                for(String pid : pricingData.keySet()){
                    Map<String,Object> prices = (Map<String,Object>)pricingData.get(pid);
                    Map<String,Object> productPrice = (Map<String,Object>)prices.get(osf_constant_strings.PRODUCT_PRICE);
                    //get product tax rate from price list item
                    String PLIsfid = (String)productPrice.get(osf_constant_strings.SFID);
                    ccrz__E_PriceListItem__c pli = [SELECT ccrz__Price__c, ccrz__Product__r.osf_tax_rate__c FROM ccrz__E_PriceListItem__c WHERE ID =: PLIsfid];         
                    Decimal taxRate = (Decimal)pli.ccrz__Product__r.osf_tax_rate__c;
                    Decimal listPrice =(Decimal)pli.ccrz__Price__c;
                    //calculated negotiated discount and tax rate
                    Decimal price = (Decimal)productPrice.get(osf_constant_strings.PRICE);
                    Decimal discountRate = ccProductIdToDiscountMap.get(pid) != null ? ccProductIdToDiscountMap.get(pid) : 0;
                    Decimal discountedPrice = price * (1 - discountRate / 100);
                    Decimal priceWithTax = discountedPrice *(1 + taxRate / 100);
                    mapProductDiscountedPrice.put(pid, discountedPrice.setScale(2, System.RoundingMode.HALF_EVEN));
                    mapProductDiscountedPriceWithTax.put(pid, priceWithTax.setScale(2, System.RoundingMode.HALF_EVEN));
                    //get tiered prices
                    Map<String,Object> pricingTiers = (Map<String,Object>)productPrice.get(osf_constant_strings.PRICING_TIERS);
                    List<Map<String,Object>> tiers = new List<Map<String,Object>>();
                    List<Object> tierdataList = pricingTiers != null ? (List<Object>)pricingTiers.get(osf_constant_strings.TIERS) : null;
                    //add price with VAT to tier price data
                    if (tierdataList != null) {
                        for(Object tierdata : tierdataList){
                            Map<String,Object> onetier = (Map<String,Object>)tierdata;
                            Decimal unitPrice = (Decimal)onetier.get(osf_constant_strings.UNIT_PRICE);
                            Decimal priceWithVat = unitPrice + unitPrice * taxRate / 100;
                            Decimal tierDiscountRate = ((listPrice - unitPrice) * 100) / listPrice;
                            priceWithVat = priceWithVat.setScale(2, System.RoundingMode.HALF_EVEN);
                            tierDiscountRate = tierDiscountRate.setScale(0, System.RoundingMode.HALF_UP);
                            onetier.put(osf_constant_strings.PRICE_WITH_VAT,priceWithVat);
                            onetier.put(osf_constant_strings.DISCOUNT_RATE,tierDiscountRate);
                            tiers.add(onetier);
                        }
                    }
                }

                for(Map<String, Object> mapComposite : lstCompositeProducts) {
                    String componentId = (String)mapComposite.get(osf_constant_strings.COMPONENT);
                    Map<String, Object> mapComponentR = (Map<String, Object>)mapComposite.get(osf_constant_strings.COMPONENT_R);
                    mapComponentR.put(osf_constant_strings.DISCOUNTED_PRICE_LIST, mapProductDiscountedPrice.get(componentId));
                    mapComponentR.put(osf_constant_strings.DISCOUNTED_PRICE_LIST_WITH_TAX, mapProductDiscountedPriceWithTax.get(componentId));
                }
            }
        } catch (Exception e) {
            system.debug('e = ' + e.getStackTraceString());
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:logicProductPricing:prepReturnData:Error', e);
        }
        return outputData;
    } 
}