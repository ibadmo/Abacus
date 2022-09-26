@IsTest
public class osf_ctrl_Login_Test {

    @IsTest
    public static void testCheckDuplicateUser() {
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz.cc_RemoteActionContext context;
        System.runAs(user) {
            context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        }
        Test.startTest();
        ccrz.cc_RemoteActionResult resultTrue = osf_ctrl_Login.checkDuplicateUser(context, osf_testUtility.USER_EMAIL1);
        ccrz.cc_RemoteActionResult resultFalse = osf_ctrl_Login.checkDuplicateUser(context, 'test@email.com');
        Test.stopTest();
        System.assert(resultTrue.success);
        Map<String, Object> dataTrue = (Map<String, Object>) resultTrue.data;
        System.assertEquals(1, dataTrue.size());
        System.assert(dataTrue.containsKey(osf_constant_strings.DUPLICATE_USERNAME));
        System.assert((Boolean) dataTrue.get(osf_constant_strings.DUPLICATE_USERNAME));

        System.assert(resultFalse.success);
        Map<String, Object> dataFalse = (Map<String, Object>) resultFalse.data;
        System.assertEquals(1, dataFalse.size());
        System.assert(dataFalse.containsKey(osf_constant_strings.DUPLICATE_USERNAME));
        System.assert(!(Boolean) dataFalse.get(osf_constant_strings.DUPLICATE_USERNAME));
    }
}