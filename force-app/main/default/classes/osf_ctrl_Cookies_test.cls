@isTest
public class osf_ctrl_Cookies_test {
    @isTest
    static void testCheckShowCookies(){
        osf_testUtility setup = new osf_testUtility();

        Map<String, User> usermap = setup.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);

        ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        ccrz.cc_RemoteActionResult result;
        
        Test.startTest();
        result = osf_ctrl_Cookies.checkShowCookies(context);
        Test.stopTest();

        System.assert(result.success);
    }

    @isTest
    static void testAcceptCookies(){
        ccrz.cc_RemoteActionContext context = new ccrz.cc_RemoteActionContext();
        ccrz.cc_RemoteActionResult result;

        Test.startTest();
        result = osf_ctrl_Cookies.acceptCookies(context);
        Test.stopTest();

        System.assert(result.success);
    }
}