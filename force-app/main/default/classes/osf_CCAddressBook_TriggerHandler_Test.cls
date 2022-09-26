/**
* File:        osf_CCAddressBook_TriggerHandler_Test.cls
* Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
* Date:        June 26, 2020
* Created By:  Alina Craciunel
************************************************************************
* Description: Test class for osf_CCAddressBook_TriggerHandler
************************************************************************
* History:
*/
@isTest
public without sharing class osf_CCAddressBook_TriggerHandler_Test {
    
    /* 
    * @description  : create test data
    * @author       : Alina Craciunel
    * @createdDate  : Jun 26, 2020
    * @param        : 
    * @return       : 
    */
    @TestSetup
    static void createTestData() {
        osf_testUtility testUtility = new osf_testUtility();
        ccrz__E_ContactAddr__c shipTo1 = osf_testUtility.createContactAddress('John', 'Doe', 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
        ccrz__E_ContactAddr__c shipTo2 = osf_testUtility.createContactAddress('John', 'Doe', 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
        insert new List<ccrz__E_ContactAddr__c> {shipTo1, shipTo2};

        ccrz__E_ContactAddr__c billTo1 = osf_testUtility.createContactAddress('John', 'Doe', 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
        ccrz__E_ContactAddr__c billTo2 = osf_testUtility.createContactAddress('John', 'Doe', 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
        insert new List<ccrz__E_ContactAddr__c> {billTo1, billTo2};

        Account account = testUtility.getDefaultAccount();
        
        insert new List<ccrz__E_AccountAddressBook__c> {
            osf_testUtility.createAccountAddressBook('Test Billing1', account, billTo1, 'Billing', false),
            osf_testUtility.createAccountAddressBook('Test Billing2', account, billTo2, 'Billing', true),
            osf_testUtility.createAccountAddressBook('Test Shipping1', account, shipTo1, 'Shipping', false),
            osf_testUtility.createAccountAddressBook('Test Shipping2', account, shipTo2, 'Shipping', true)
        };
    }
    
    /* 
    * @description  : test method for afterInsertUpdate
    * @author       : Alina Craciunel
    * @createdDate  : Jun 26, 2020
    * @param        : 
    * @return       : 
    */
    @isTest   
    public static void testMakeAddressDefaultShipping() {
        List<ccrz__E_AccountAddressBook__c> shipAddr = [SELECT Name, ccrz__AddressType__c, ccrz__Default__c FROM ccrz__E_AccountAddressBook__c WHERE ccrz__AddressType__c = 'Shipping' AND ccrz__Default__c = false];
        shipAddr[0].ccrz__Default__c = true;
        update shipAddr[0];           
        List<ccrz__E_AccountAddressBook__c> shipAddrRes = [SELECT ccrz__AddressType__c, ccrz__Default__c FROM ccrz__E_AccountAddressBook__c WHERE ccrz__AddressType__c = 'Shipping' AND ccrz__Default__c = true];
        system.assertEquals(1, shipAddrRes.size());      
    }
    
    /* 
    * @description  : test method for afterInsertUpdate
    * @author       : Alina Craciunel
    * @createdDate  : Jun 26, 2020
    * @param        : 
    * @return       : 
    */
    @isTest   
    public static void testMakeAddressDefaultBilling() {
        List<ccrz__E_AccountAddressBook__c> billAddr = [SELECT Name, ccrz__AddressType__c, ccrz__Default__c FROM ccrz__E_AccountAddressBook__c WHERE ccrz__AddressType__c = 'Billing' AND ccrz__Default__c = false];
        billAddr[0].ccrz__Default__c = true;
        update billAddr[0];           
        List<ccrz__E_AccountAddressBook__c> billAddrRes = [SELECT ccrz__AddressType__c, ccrz__Default__c FROM ccrz__E_AccountAddressBook__c WHERE ccrz__AddressType__c = 'Billing' AND ccrz__Default__c = true];
        system.assertEquals(1, billAddrRes.size());      
    }
}