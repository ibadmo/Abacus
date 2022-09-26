/**
 * File:        osf_ctrl_prominentProducts.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Jan 6, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Controller class for 3 Sections in Homepage.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global with sharing class osf_ctrl_prominentProducts {
    /* 
    * @description  : Return All Prominent Products
    * @author       : Ozgun Eser
    * @createdDate  : Jan 6, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getAllProminentProducts(ccrz.cc_RemoteActionContext context) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        try {
            List<osf_prominent_product__c> bestSellerProductList = osf_utility.getPromintnProductsByType(osf_constant_strings.PROMINENT_TYPE_BESTSELLERS, 4);
            List<osf_prominent_product__c> recommendedProductList = osf_utility.getPromintnProductsByType(osf_constant_strings.PROMINENT_TYPE_RECOMMENDED, 4);
            List<osf_prominent_product__c> newProductList = osf_utility.getPromintnProductsByType(osf_constant_strings.PROMINENT_TYPE_NEW, 4);

            List<Map<String, Object>> outputDataBestSeller = transformProminentProducts(bestSellerProductList);
            List<Map<String, Object>> outputDataRecommended = transformProminentProducts(recommendedProductList);
            List<Map<String, Object>> outputDataNew = transformProminentProducts(newProductList);

            data.put(osf_constant_strings.BESTSELLER_PRODUCTS, outputDataBestSeller);
            data.put(osf_constant_strings.RECOMMENDED_PRODUCTS, outputDataRecommended);
            data.put(osf_constant_strings.NEW_PRODUCTS, outputDataNew);
            result.success = true;
        } catch (Exception e) {
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }

    
    /* 
    * @description  : add prominent product to cart
    * @author       : Cansu Aslı Asci
    * @createdDate  : Jan 21, 2020
    * @param        : String sku, sku of product
    * @param        : String qty, quantity per unit of product 
    * @return       : ccrz.cc_RemoteActionResult result, containing return data
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult addToCart_prominentProducts(ccrz.cc_RemoteActionContext context, String sku, String qty) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        try{
            ccrz__E_Cart__c cart = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =: context.currentCartId];
            Decimal quantity = Decimal.valueOf(String.valueOf(qty));
            String  CartSFID = cart.Id;
            
            Map<String, Object> addResults = osf_Utility.addToCart(sku, quantity, CartSFID);
        	result.success = (Boolean)addResults.get(ccrz.ccApi.SUCCESS);
        }catch(Exception ex){
            result.messages.add(osf_utility.createBeanMessage(ex));
        }finally{
            ccrz.ccLog.close(result);
        }
        return result;
    }

    /* 
    * @description  : transform prominent product data for Backbone Model
    * @author       : Ozgun Eser
    * @createdDate  : Jan 6, 2020
    * @param        : List<osf_prominent_product__c> prominentProductList, product list to transform
    * @return       : List<Map<String, Object>> data, transformed data
    */
    private static List<Map<String, Object>> transformProminentProducts(List<osf_prominent_product__c> prominentProductList) {
        Set<String> productIdSet = new Set<String> ();
        for(osf_prominent_product__c prominentProduct : prominentProductList) {
            productIdSet.add(prominentProduct.osf_product__c);
        }
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPIProduct.PRODUCTIDLIST => productIdSet,
            ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true,
            ccrz.ccAPIProduct.PARAM_INCLUDE_SELLERS => false,
            ccrz.ccAPIProduct.MEDIAFILTER => new Set<String> {osf_constant_strings.PRODUCT_SEARCH_IMAGE},
            ccrz.ccAPIProduct.TYPES => new Set<String> {osf_constant_strings.PRODUCT_TYPE_PRODUCT}
        };
        Map<String, Object> outputData = ccrz.ccAPIProduct.fetch(inputData);
        if(!(Boolean) outputData.get(ccrz.ccAPI.SUCCESS)) {
            throw new osf_prominentProductException(osf_constant_strings.PROMINENT_PRODUCT_ERROR);
        }
        List<Map<String, Object>> productData = (List<Map<String, Object>>) outputData.get(ccrz.ccAPIProduct.PRODUCTLIST);
        return productData;
    }

    public class osf_prominentProductException extends Exception {}
}