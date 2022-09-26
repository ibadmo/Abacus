/**
 * File:        osf_ctrl_creditCardpayment_test.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 17, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Test calss for osf_ctrl_creditCardpayment
  ************************************************************************
 * History:
 */

@isTest
global with sharing class osf_ctrl_creditCardpayment_test implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('<response timestamp=\'20200213172645\'><result>506</result><message>Something wrong</message></response>');
        response.setStatusCode(200);
        return response; 
    }
    
    /* 
    * @description  : test makeCCPayment method
    * @author       : Alina Craciunel
    * @createdDate  : Feb 17, 2020
    * @param        : the HttpResponse
    * @return       : the error message as a string
    */
    @isTest
    static void testMakeCCPayment() {
        osf_Abacus_B2B_config__c config = new osf_Abacus_B2B_config__c(AddonPayment_Endpoint__c = 'testkey'); 
        insert config;
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        ccrz.cc_RemoteActionResult result;
        osf_ctrl_creditCardpayment.PaymentModel paymentModel = new osf_ctrl_creditCardpayment.PaymentModel();
        System.runAs(user) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new osf_ctrl_creditCardpayment_test()); 
            result = osf_ctrl_creditCardpayment.makeCCPayment(context, JSON.serialize(paymentModel));
            Test.stopTest();
        }
        System.assertEquals(false, result.success);
    }    
}