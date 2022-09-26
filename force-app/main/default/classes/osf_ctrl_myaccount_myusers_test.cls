@isTest
private class osf_ctrl_myaccount_myusers_test {
    @isTest
    static void testgetContacts(){
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        Map<String, Contact> mapContact = testUtility.getContactByEmail();

        Contact contact1 = mapContact.get(osf_testUtility.CONTACT_EMAIL1);
        contact1.osf_role__c = 'Account Administrator';
        contact1.osf_allow_checkout__c = true;

        Contact contact2 = mapContact.get(osf_testUtility.CONTACT_EMAIL2);
        contact2.osf_role__c = 'Supervisor';
        contact2.osf_allow_checkout__c = false;
        contact2.osf_supervisor__c = contact1.Id;

        update new List<Contact>{ contact1, contact2 };
		
        String isAdmin = 'true'; // hardcoded because contact is already updated as administrator above
        ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_myaccount_myusers.getContacts(context,isAdmin);
        Test.stopTest();

        System.assert(result.success);
        Map<String, Object> data = (Map<String, Object>) result.data;
        System.assert(data.containsKey(osf_constant_strings.MYUSERS_CONTACTS));
        List<Map<String,Object>> contactdata = (List<Map<String,Object>>)data.get(osf_constant_strings.MYUSERS_CONTACTS);
        System.assertNotEquals(0, contactdata.size());
    }
}