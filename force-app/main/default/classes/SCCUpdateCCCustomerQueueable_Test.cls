@isTest
private class SCCUpdateCCCustomerQueueable_Test {
    @isTest
    private static void testQueueableClass() {
        Id personAccountRecordTypeId = [SELECT Id FROM RecordType WHERE IsPersonType = true AND SobjectType = 'Account' LIMIT 1].Id;
        Account acc = new Account(LastName='TestAcc', RecordTypeId = personAccountRecordTypeId);
        insert acc;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        SCCCommerceCloudConnect.siteBaseUrl = 'https://xxxx-dw.demandware.net';
        SCCCommerceCloudConnect.listId = 'SiteGenesis';
        System.enqueueJob(new SCCUpdateCCCustomerQueueable(acc.id, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613'));
        Test.stopTest();
    }
}