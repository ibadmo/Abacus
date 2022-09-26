@isTest
global class osf_ctrl_cartdetail_test implements WebServiceMock{
    
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        absis.consultarEstocCentreDistribucioB2BSalesforceResponse resultat = new absis.consultarEstocCentreDistribucioB2BSalesforceResponse();
        absis.estocCL[] lstStock = new absis.estocCL[]{};
        absis.estocCL stock1 = new absis.estocCL();
        stock1.codiArticle = 'SKU1';
        stock1.unitats = 2;
		
        //do not return the sku 
        /*absis.estocCL stock2 = new absis.estocCL();
        stock2.codiArticle = 'SKU2';
        stock2.unitats = 6;*/

        lstStock.add(stock1);
        //lstStock.add(stock2);
        resultat.llistaEstoc = lstStock;
        response.put('response_x', resultat); 
    }
    
    @isTest static void teststockCheck(){
        osf_testUtility setup = new osf_testUtility();
        Map<String, User> usermap = setup.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);

        osf_Abacus_B2B_config__c config = new osf_Abacus_B2B_config__c(osf_providertime_plus__c = 72); 
        insert config;

        ccrz__E_Product__c Product1 = osf_testUtility.createCCProduct('SKU1', 'Product 1');
        Product1.osf_provider_delivery_time__c = 20;
        ccrz__E_Product__c Product2 = osf_testUtility.createCCProduct('SKU2', 'Product 2');
        Product2.osf_provider_delivery_time__c = 30;
        insert new List<ccrz__E_Product__c> {Product1, Product2};
        
        String serialized = '[{"SKU":"SKU1","quantity":10},{"SKU":"SKU2","quantity":2}]';
        ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        ccrz.cc_RemoteActionResult result;
        Test.setMock(WebServiceMock.class, new osf_ctrl_cartdetail_test());
        Test.startTest();
        result = osf_ctrl_cartdetail.stockCheck(context, serialized);
        Test.stopTest();
        System.assertEquals(true, result.success);
    }
}