@IsTest
public class osf_ctrl_prominentProducts_test {
    

    @TestSetup
    public static void createTestData() {
        Account account = osf_testUtility.createAccount('Test Company');
        insert account;

        Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        insert contact;

        User user = osf_testUtility.createCommunityUser(contact);
        insert user;

        ccrz__E_Cart__c cart = osf_testUtility.createCart(null, null, 0, 0, account, user, contact);
        insert cart;

        ccrz__E_Product__c bestSellerProduct = osf_testUtility.createCCProduct('Test BestSeller SKU', 'Test BestSeller Name');
        ccrz__E_Product__c recommendedProduct = osf_testUtility.createCCProduct('Test Recommended SKU', 'Test Recommended Name');
        ccrz__E_Product__c newProduct = osf_testUtility.createCCProduct('Test New SKU', 'Test New Name');
        insert new List<ccrz__E_Product__c> {bestSellerProduct, recommendedProduct, newProduct};

        osf_prominent_product__c bestSellerProminentProduct = osf_testUtility.createProminentProduct(bestSellerProduct, osf_constant_strings.PROMINENT_TYPE_BESTSELLERS);
        osf_prominent_product__c recommendedProminentProduct = osf_testUtility.createProminentProduct(recommendedProduct, osf_constant_strings.PROMINENT_TYPE_RECOMMENDED);
        osf_prominent_product__c newProminentProduct = osf_testUtility.createProminentProduct(newProduct, osf_constant_strings.PROMINENT_TYPE_NEW);
        insert new List<osf_prominent_product__c> {bestSellerProminentProduct, recommendedProminentProduct, newProminentProduct};
    }

    @IsTest
    public static void testGetAllProminentProducts() {
        osf_testUtility.setupStorefront();
        User user = [SELECT Id, LanguageLocaleKey FROM User WHERE Username = 'test@email.com'];
        ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE ccrz__User__c = :user.Id];
        ccrz.cc_RemoteActionContext context = osf_testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT, cart);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_prominentProducts.getAllProminentProducts(context);
        Test.stopTest();
        System.assert(result.success);
    }  

    @IsTest
    public static void testaddToCart_prominentProducts(){
        osf_testUtility setup = new osf_testUtility();

        Map<String, User> usermap = setup.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
      
        ccrz__E_Product__c product = [SELECT Id, ccrz__SKU__c FROM ccrz__E_Product__c LIMIT 1];
    
        ccrz__E_Pricelist__c pricelist = setup.getDefaultPricelist();
    
        ccrz__E_PricelistItem__c pricelistItem = osf_testUtility.createPricelistItem(pricelist, product, 100.00);
        insert pricelistItem;
          
        ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        ccrz.cc_RemoteActionResult result;
      
      
        Test.startTest();
        result = osf_ctrl_prominentProducts.addToCart_prominentProducts(context, product.ccrz__SKU__c, '1' );
        Test.stopTest();
        
        System.assert(result.success);
        
    } 
}