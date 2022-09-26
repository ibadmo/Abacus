/**
 * File:        osf_batch_failedOrders_test
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        June 30, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Test calss for osf_batch_failedOrders
  ************************************************************************
 * History:
 */

@isTest
global without sharing class osf_batch_failedOrders_test implements WebServiceMock {
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (requestName == 'crearComandaWebB2BSalesforce'){
            resultat.ResultatOperacioComanda resultat = new resultat.ResultatOperacioComanda();
            resultat.actualitzacioOK = true;
            response.put('response_x', resultat); 
        }
   }

    /* 
    * @description  : create test data
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @param        : 
    * @return       : 
    */
    @TestSetup
    private static void createTestData(){
        insert new osf_Abacus_B2B_config__c (
            order_resending_attempts__c = 5
        );
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        System.runAs(user) {
            ccrz__E_Cart__c cart = testUtility.getDefaultCart();
            ccrz__E_ContactAddr__c contactAddress1 = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress1;
            ccrz__E_ContactAddr__c contactAddress2 = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress2;
            cart.ccrz__ShipTo__c = contactAddress1.Id;
            cart.ccrz__BillTo__c = contactAddress2.Id;
            update cart;
            ccrz__E_Order__c order1 = osf_testUtility.createCCOrder(cart);
            order1.osf_order_error__c = true;
            ccrz__E_Order__c order2 = osf_testUtility.createCCOrder(cart);
            order2.osf_order_error__c = true;
            ccrz__E_Order__c order3 = osf_testUtility.createCCOrder(cart);
            order3.osf_order_error__c = true;
            ccrz__E_Order__c order4 = osf_testUtility.createCCOrder(cart);
            order4.osf_order_error__c = true;
            ccrz__E_Order__c order5 = osf_testUtility.createCCOrder(cart);
            order5.osf_order_error__c = true;
            insert new List<ccrz__E_Order__c> {order1, order2, order3, order4, order5};
        }
    }
    
    /* 
    * @description  : test failed order batch
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @param        : 
    * @return       : 
    */
    @IsTest
    private static void testFailedOrderBatch() {
        List<ccrz__E_Order__c> lstOrdersBeforeUpdate = new List<ccrz__E_Order__c>([SELECT Id FROM ccrz__E_Order__c WHERE osf_order_error__c = true]);
        System.assertEquals(5, lstOrdersBeforeUpdate.size());
        Test.startTest();
        Test.setMock(WebServiceMock.class, new osf_batch_failedOrders_test());
        Database.executeBatch(new osf_batch_failedOrders(), 100);
        Test.stopTest();
        List<ccrz__E_Order__c> lstOrdersAfterUpdate = new List<ccrz__E_Order__c>([SELECT Id FROM ccrz__E_Order__c WHERE osf_order_error__c = true]);
        System.assertEquals(0, lstOrdersAfterUpdate.size());
    }
}