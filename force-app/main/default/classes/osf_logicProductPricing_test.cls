@IsTest
public class osf_logicProductPricing_test {
    
    @IsTest
    public static void testPrepReturnData() {
        osf_testUtility testUtility = new osf_testUtility();
        Account account = testUtility.getDefaultAccount();

        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        product.osf_catalog_id__c = '01-123';
        insert product;

        osf_negotiated_discount__c negotiatedDiscount = osf_TestUtility.createNegotiatedDiscount(account, 50, null, '01', null);
        insert negotiatedDiscount;

        ccrz__E_Pricelist__c pricelist = testUtility.getDefaultPricelist();

        ccrz__E_PricelistItem__c pricelistItem = osf_testUtility.createPricelistItem(pricelist, product, 1000);
        insert pricelistItem;

        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);

        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPIProduct.PRODUCTIDLIST => new Set<String> {String.valueOf(product.Id)},
            ccrz.ccAPIProduct.PRODUCTSTOREFRONT => osf_testUtility.STOREFRONT,
            ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true,
            ccrz.ccAPIProduct.TYPES => new Set<String> {osf_testUtility.PRODUCT_TYPE}
        };

        Map<String, Object> outputData = new Map<String, Object> ();
        Test.startTest();
        System.runAs(user) {
            outputData = ccrz.ccAPIProduct.fetch(inputData);
        }
        Test.stopTest();
        List<Map<String, Object>> productList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPIProduct.PRODUCTLIST);
        Map<String, Object> productData = productList[0];
        System.debug('productData -----> ' + productData);
        System.assertEquals(500, (Decimal) productData.get(osf_constant_strings.DISCOUNTED_PRICE));
        System.assertEquals(500, (Decimal) productData.get(osf_constant_strings.DISCOUNT_AMOUNT));
    }    
    
    @IsTest
    public static void testPrepReturnData_tieredPrice(){
        osf_testUtility setup = new osf_testUtility();
        ccrz__E_Pricelist__c pricelist = setup.getDefaultPricelist(); 
        User user = setup.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz.cc_CallContext.currPageName = osf_constant_strings.PDP_PAGE;
        osf_tax_class__c testTaxClass = osf_testUtility.createTaxClass('test tax class', 10);
        insert testTaxClass;
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        product.osf_tax_class__c = testTaxClass.Id;
        insert product;
        String tierJSON = '{"tiers":[{"q":10,"p":15},{"q":20,"p":10}],"pT":"tAbsPrice"}';
        ccrz__E_PricelistItem__c pricelistItem = osf_testUtility.createPricelistItem(pricelist, product, 100.00);
        pricelistItem.ccrz__PricingTiers__c = tierJSON;
        insert pricelistItem;
        
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPIProduct.PRODUCTIDLIST => new Set<String> {String.valueOf(product.Id)},
            ccrz.ccAPIProduct.PRODUCTSTOREFRONT => osf_testUtility.STOREFRONT,
            ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true,
            ccrz.ccAPIProduct.TYPES => new Set<String> {osf_testUtility.PRODUCT_TYPE},
            ccrz.ccAPIProduct.INCLUDE_TIER_PRICING => true
        };
        
        Map<String, Object> outputData = new Map<String, Object> ();
        Test.startTest();
        System.runAs(user) {
            outputData = ccrz.ccAPIProduct.fetch(inputData);
        }
        Test.stopTest();

        List<Map<String, Object>> productList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPIProduct.PRODUCTLIST);
        Map<String, Object> productData = productList[0];
        System.assertEquals(product.ccrz__SKU__c, productData.get(osf_constant_strings.SKU));
    }
}