@isTest
public class OSF_RollUpAndPurchaseDateUptAccCntrlTest {
    @isTest static void createOrderRecordsWithAccount() {
        Id id1 = [select id, name from profile where name = 'SCC Integration User'].id;
        user u = new user (lastName = 'Test RollUps',profileId = id1,Alias = 'uscci',
                           Email = 'abacus-pj+test@osf.digital',
                           UserName = 'abacus-pj+test@osf.digital',
                           EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/Chicago');
        system.RunAs(u) {
            Test.startTest();
            RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');
            Account act = new Account(firstName = 'Steve', lastName = 'Smith', recordTypeId = recordType.Id);
            insert act;
            list<Order> ordList = new list<Order>();
            ordList.add(new order (effectiveDate = system.today()-265 , Status = 'Completed', SFCC_Order_Total__c = 18.19, Order_SCCSync_Status__c = 'Synchronised', SFCC_Order_Number__c = '00000101', accountId = act.Id));
            ordList.add(new order (effectiveDate = system.today()-263 , Status = 'Completed', SFCC_Order_Total__c = 12.19, Order_SCCSync_Status__c = 'Synchronised', SFCC_Order_Number__c = '00000102', accountId = act.Id));
            insert ordList;
            ordList[0].SFCC_Order_Total__c+=ordList[0].SFCC_Order_Total__c;
            update ordList;
            delete ordList[0];
            Test.stopTest();
        }
        
    }
}