@isTest
public class osf_ctrl_header_test {
    
    @TestSetup
    static void makeData(){
       Account account = osf_testUtility.createAccount('Test Account');
        insert account;

        Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        insert contact;

        User user = osf_testUtility.createCommunityUser(contact);
        insert user;
    }

    @isTest
    static void testgetAccountInfo(){
        User user = [SELECT Id FROM User WHERE Username = 'test@email.com'];
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ccrz.cc_RemoteActionResult result;
        
        System.runAs(user) {
            Test.startTest();
            result = osf_ctrl_header.getAccountInfo(ctx);
            Test.stopTest();
        }

        System.assert(result.success);
    }

}