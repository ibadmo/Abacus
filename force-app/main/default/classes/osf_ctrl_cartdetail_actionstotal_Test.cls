@IsTest
public class osf_ctrl_cartdetail_actionstotal_Test {

    @IsTest
    public static void testSubmitCart(){
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        Map<String, Contact> mapContact = testUtility.getContactByEmail();
        Contact contact = mapContact.get(osf_testUtility.CONTACT_EMAIL1);
        contact contact2 = mapContact.get(osf_testUtility.CONTACT_EMAIL2);
        Contact contact3 = osf_testUtility.createContact('Test3', 'Test3', account, 'test3@email.com');
        insert contact3;
        User user3 = osf_testUtility.createCommunityUser(contact3);
        insert user3;
        contact.osf_supervisor__c = contact2.Id;
        contact.osf_supervisor_2__c = contact3.Id;
        update contact;
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        Database.insert(product);
        ccrz__E_Cart__c cart;
        System.runAs(user) {
            cart = testutility.getDefaultCart();
        }
        ccrz.cc_RemoteActionContext context = testutility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_cartdetail_actionstotal.submitCart(context);
        Test.stopTest();
        System.assert(result.success);
    } 
}