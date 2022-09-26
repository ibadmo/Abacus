@isTest
private class osf_ctrl_pdp_test {

  @isTest
  static void testAddToCart_relatedProducts(){
    osf_testUtility setup = new osf_testUtility();

    Map<String, User> usermap = setup.getUsernameMap();
    User user = usermap.get(osf_testUtility.USER_EMAIL1);
  
    ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test Product', '123');
    insert product;

    ccrz__E_Pricelist__c pricelist = setup.getDefaultPricelist();

    ccrz__E_PricelistItem__c pricelistItem = osf_testUtility.createPricelistItem(pricelist, product, 100.00);
	  insert pricelistItem;
      
    ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
    ccrz.cc_RemoteActionResult result;
      
      
    Test.startTest();
    result = osf_ctrl_pdp.addToCart_relatedProducts(context, '1', product.ccrz__SKU__c);
    Test.stopTest();

    System.assert(result.success);
      
  }

  @isTest
  static void testAddToCart_relatedProducts_error(){
      ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
      
      Test.startTest();
      ccrz.cc_RemoteActionResult result = osf_ctrl_pdp.addToCart_relatedProducts(ctx,'1', '123');
      Test.stopTest();
      
      System.assert(!result.success);
  }

  @isTest
  static void testProductInfoRequestGuest(){
        osf_testUtility setup = new osf_testUtility();
        Map<String, User> usermap = setup.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Map<String, Contact> contactmap = setup.getContactByEmail();
        Contact contact = contactmap.get(osf_testUtility.CONTACT_EMAIL1);
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test Product', '123');
        insert product;

        ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Map<String, Object> formData = new Map<String, Object>{osf_constant_strings.FIRSTNAME => 'Test Name', 
                                                               osf_constant_strings.LASTNAME => 'Test Last Name',
                                                               osf_constant_strings.GUEST_EMAIL => 'test@test.com', 
                                                               osf_constant_strings.COMPANY => 'testcompany', 
                                                               osf_constant_strings.PHONE => '123456789', 
                                                               osf_constant_strings.GUEST_COMMENT => 'Test comment'};
        ccrz.cc_RemoteActionResult result;
        Test.startTest();
        result = osf_ctrl_pdp.createProductInfoRequest(context, formData, product.Id);
        String name = formData.get(osf_constant_strings.FIRSTNAME) + osf_constant_strings.EMPTY_SPACE + formData.get(osf_constant_strings.LASTNAME);
        Test.stopTest();
        List<Case> lstCases = [SELECT Id, osf_name__c, osf_email__c, osf_phone__c, osf_company__c, Description FROM Case];
        System.assertEquals(1, lstCases.size());
        System.assertEquals(name, lstCases[0].osf_name__c);
        System.assertEquals(formData.get(osf_constant_strings.GUEST_EMAIL), lstCases[0].osf_email__c);
        System.assertEquals(formData.get(osf_constant_strings.PHONE), lstCases[0].osf_phone__c);
        System.assertEquals(formData.get(osf_constant_strings.COMPANY), lstCases[0].osf_company__c);
        System.assertEquals(formData.get(osf_constant_strings.GUEST_COMMENT), lstCases[0].Description);
  }

  @isTest
  static void testProductInfoRequest_error(){
      ccrz.cc_RemoteActionContext context = new ccrz.cc_RemoteActionContext();
      
	    Account account = osf_testUtility.createAccount('Test Account');
      insert account;
      
      Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
      insert contact;

      Map<String, Object> formData = new Map<String, Object>{osf_constant_strings.FIRSTNAME => 'Test Name', 
                                                              osf_constant_strings.LASTNAME => 'Test Last Name',
                                                              osf_constant_strings.GUEST_EMAIL => 'test@test.com', 
                                                              osf_constant_strings.COMPANY => 'testcompany', 
                                                              osf_constant_strings.PHONE => '123456789', 
                                                              osf_constant_strings.GUEST_COMMENT => 'Test comment'};
      
      Test.startTest();
      ccrz.cc_RemoteActionResult result = osf_ctrl_pdp.createProductInfoRequest(context, formData, 'invalid id to cause error');
      Test.stopTest();

      System.assert(!result.success);
  }

  @isTest
  static void testgetSiteKey(){
      osf_testUtility setup = new osf_testUtility();

      Map<String, User> usermap = setup.getUsernameMap();
      User user = usermap.get(osf_testUtility.USER_EMAIL1);

      ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
      ccrz.cc_RemoteActionResult result;

      osf_Abacus_B2B_config__c testconfig = new osf_Abacus_B2B_config__c(site_key__c = 'testkey');
      insert testconfig;

      Test.startTest();
      result = osf_ctrl_pdp.getSiteKey(context);
      Test.stopTest();

      Map<String, Object> data = (Map<String, Object>) result.data;
      
      System.assert(result.success);
      System.assertNotEquals(result.data, null);
	    System.assertEquals(testconfig.site_key__c, (String) data.get(osf_constant_strings.RECAPTCHA_SITE_KEY));
  }

   /**********************************************************************************************
  * @Name         : testAddToCart_compositeProducts
  * @Description  : test addToCart_compositeProducts on pdp  page
  * @Created By   : Alina Craciunel
  * @Created Date : Mar 18, 2020
  * @Param        : 
  * @Return       : 
  *********************************************************************************************/
  @isTest
  static void testAddToCart_compositeProducts(){
    osf_testUtility setup = new osf_testUtility();
    Map<String, User> usermap = setup.getUsernameMap();
    User user = usermap.get(osf_testUtility.USER_EMAIL1);
    ccrz__E_Product__c parentProduct = osf_testUtility.createCCProduct('parentSKU', 'Parent Product');
		parentProduct.ccrz__ProductType__c = osf_testUtility.PRODUCT_TYPE_AGGREGATED;
    ccrz__E_Product__c childProduct1 = osf_testUtility.createCCProduct('childSKU1', 'Child Product 1');
    ccrz__E_Product__c childProduct2 = osf_testUtility.createCCProduct('childSKU2', 'Child Product 2');
		insert new List<ccrz__E_Product__c> {childProduct1, childProduct2, parentProduct};
    ccrz__E_CompositeProduct__c compositeProduct1 = osf_testUtility.createCompositeProduct(parentProduct, childProduct1);
    ccrz__E_CompositeProduct__c compositeProduct2 = osf_testUtility.createCompositeProduct(parentProduct, childProduct2);
    insert new List<ccrz__E_CompositeProduct__c> {compositeProduct1, compositeProduct2};
    ccrz__E_Pricelist__c pricelist = setup.getDefaultPricelist();
    ccrz__E_PricelistItem__c pricelistItem1 = osf_testUtility.createPricelistItem(pricelist, childProduct1, 100.00);
    ccrz__E_PricelistItem__c pricelistItem2 = osf_testUtility.createPricelistItem(pricelist, childProduct2, 50.00);
	  insert new List<ccrz__E_PricelistItem__c> {pricelistItem1, pricelistItem2};
    ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
    ccrz.cc_RemoteActionResult result;
    Map<String, Object> mapSkuQuantities = new Map<String, Object>{'childSKU1' => '10', 'childSKU2' => '5'};
    Test.startTest();
    result = osf_ctrl_pdp.addToCart_compositeProducts(context, JSON.serialize(mapSkuQuantities));
    Test.stopTest();
    System.assertEquals(true, result.success);
    System.assertNotEquals(null, result.data);
    System.assertNotEquals(null, ((Map<String, Object>)result.data).get(osf_constant_strings.CART_ENC_ID));
  }

  /**********************************************************************************************
  * @Name         : testGetCompositeProductsFromVariation
  * @Description  : test getCompositeProductsFromVariation on pdp  page
  * @Created By   : Alina Craciunel
  * @Created Date : Mar 18, 2020
  * @Param        : 
  * @Return       : 
  *********************************************************************************************/
  @isTest
  static void testGetCompositeProductsFromVariation(){
    osf_testUtility setup = new osf_testUtility();
    Map<String, User> usermap = setup.getUsernameMap();
    User user = usermap.get(osf_testUtility.USER_EMAIL1);
    ccrz__E_Product__c parentProduct = osf_testUtility.createCCProduct('parentSKU', 'Parent Product');
		parentProduct.ccrz__ProductType__c = osf_testUtility.PRODUCT_TYPE_AGGREGATED;
    ccrz__E_Product__c childProduct1 = osf_testUtility.createCCProduct('childSKU1', 'Child Product 1');
    ccrz__E_Product__c childProduct2 = osf_testUtility.createCCProduct('childSKU2', 'Child Product 2');
		insert new List<ccrz__E_Product__c> {childProduct1, childProduct2, parentProduct};
    ccrz__E_CompositeProduct__c compositeProduct1 = osf_testUtility.createCompositeProduct(parentProduct, childProduct1);
    ccrz__E_CompositeProduct__c compositeProduct2 = osf_testUtility.createCompositeProduct(parentProduct, childProduct2);
    insert new List<ccrz__E_CompositeProduct__c> {compositeProduct1, compositeProduct2};
    ccrz__E_Pricelist__c pricelist = setup.getDefaultPricelist();
    ccrz__E_PricelistItem__c pricelistItem1 = osf_testUtility.createPricelistItem(pricelist, childProduct1, 100.00);
    ccrz__E_PricelistItem__c pricelistItem2 = osf_testUtility.createPricelistItem(pricelist, childProduct2, 50.00);
	  insert new List<ccrz__E_PricelistItem__c> {pricelistItem1, pricelistItem2};
    ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
    ccrz.cc_RemoteActionResult result;
    Test.startTest();
    result = osf_ctrl_pdp.getCompositeProductsFromVariation(context, childProduct1.Id);
    Test.stopTest();
    // System.assertEquals(true, result.success);
    // System.assertNotEquals(null, result.data);
  }

  /**********************************************************************************************
  * @Name         : testGetCompositeProductsFromVariation_noChildProduct
  * @Description  : test getCompositeProductsFromVariation on pdp  page
  * @Created By   : Alina Craciunel
  * @Created Date : Mar 18, 2020
  * @Param        : 
  * @Return       : 
  *********************************************************************************************/
  @isTest
  static void testGetCompositeProductsFromVariation_noChildProduct(){
    osf_testUtility setup = new osf_testUtility();
    Map<String, User> usermap = setup.getUsernameMap();
    User user = usermap.get(osf_testUtility.USER_EMAIL1);
    ccrz__E_Product__c parentProduct = osf_testUtility.createCCProduct('parentSKU', 'Parent Product');
		parentProduct.ccrz__ProductType__c = osf_testUtility.PRODUCT_TYPE_AGGREGATED;
		insert new List<ccrz__E_Product__c> {parentProduct};
    ccrz__E_Pricelist__c pricelist = setup.getDefaultPricelist();
    ccrz__E_PricelistItem__c pricelistItem = osf_testUtility.createPricelistItem(pricelist, parentProduct, 100.00);
	  insert new List<ccrz__E_PricelistItem__c> {pricelistItem};
    ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
    ccrz.cc_RemoteActionResult result;
    Test.startTest();
    result = osf_ctrl_pdp.getCompositeProductsFromVariation(context, parentProduct.Id);
    Test.stopTest();
    System.assertEquals(true, result.success);

  }
}