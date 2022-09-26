@IsTest
private class osf_ctrl_myaccount_addressbook_test {
    
    @IsTest
    static void testgetProvinceListSuccess(){
        List<osf_province_list__c> testprovincelist = new List<osf_province_list__c>();
        testprovincelist.add(new osf_province_list__c(Name ='province1'));
        testprovincelist.add(new osf_province_list__c(Name ='province2'));
        insert testprovincelist;

        osf_testUtility testUtility = new osf_testUtility();

        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);

        ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_myaccount_manage_addressbook.getProvinceList(context);
        Test.stopTest();

        System.assert(result.success);
        Map<String, Object> data = (Map<String, Object>) result.data;
        System.assert(data.containsKey(osf_constant_strings.ADDRESSBOOK_PROVINCELIST));
        List<Map<String,Object>> provincedata = (List<Map<String,Object>>)data.get(osf_constant_strings.ADDRESSBOOK_PROVINCELIST);
        System.assertNotEquals(0, provincedata.size());
    }

    @IsTest
    static void testgetProvinceListFail(){
        osf_testUtility testUtility = new osf_testUtility();

        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);

        ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_myaccount_manage_addressbook.getProvinceList(context);
        Test.stopTest();

        System.assert(!result.success);
        Map<String, Object> data = (Map<String, Object>) result.data;
        System.assert(!data.containsKey(osf_constant_strings.ADDRESSBOOK_PROVINCELIST));
    }

    @IsTest
    static void testgetPaymentMethods(){
        osf_testUtility testUtility = new osf_testUtility();

        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);

        Account account = testUtility.getDefaultAccount();
        account.osf_validPaymentTypes__c = 'Credit Card;Bank Transfer';
        update account;

        ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_myaccount_manage_addressbook.getAccountPaymentMethods(context);
        Test.stopTest();

        System.assert(result.success);
        Map<String, Object> data = (Map<String, Object>) result.data;
        System.assert(data.containsKey(osf_constant_strings.ADDRESSBOOK_PAYMENTMETHODS));
        String paymentMethods = (String)data.get(osf_constant_strings.ADDRESSBOOK_PAYMENTMETHODS);
        System.assertEquals('Credit Card;Bank Transfer', paymentMethods);
    }
}