/**
 * File:        osf_ctrl_contactus_test.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 16, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Test calss for osf_ctrl_contactus
  ************************************************************************
 * History:
 */

@isTest
public class osf_ctrl_contactus_test {

    /**********************************************************************************************
    * @Name         : testCreateCase
    * @Description  : test createCase
    * @Created By   : Alina Craciunel
    * @Created Date : Mar 16, 2020
    * @Param        : 
    * @Return       : 
    *********************************************************************************************/
    @isTest
    public static void testCreateCase() {
        osf_testUtility setup = new osf_testUtility();
        Map<String, User> usermap = setup.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Map<String, Contact> contactmap = setup.getContactByEmail();
        Contact contact = contactmap.get(osf_testUtility.CONTACT_EMAIL1);
        ccrz.cc_RemoteActionContext context = setup.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Map<String, Object> formData = new Map<String, Object>{osf_constant_strings.MYUSERS_NAME => 'Test Name', osf_constant_strings.EMAIL => 'test@test.com', osf_constant_strings.PHONE => '123456789', osf_constant_strings.COMMENT => 'Test comment'};
        ccrz.cc_RemoteActionResult result;
        Test.startTest();
        result = osf_ctrl_contactus.createCase(context, formData);
        Test.stopTest();
        List<Case> lstCases = [SELECT Id, osf_name__c, osf_email__c, osf_phone__c, Description FROM Case];
        system.assertEquals(1, lstCases.size());
        system.assertEquals(formData.get(osf_constant_strings.MYUSERS_NAME), lstCases[0].osf_name__c);
        system.assertEquals(formData.get(osf_constant_strings.EMAIL), lstCases[0].osf_email__c);
        system.assertEquals(formData.get(osf_constant_strings.PHONE), lstCases[0].osf_phone__c);
        system.assertEquals(formData.get(osf_constant_strings.COMMENT), lstCases[0].Description);
    }
}