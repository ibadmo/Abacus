@isTest
public class osf_ctrl_footer_test {
   @TestSetup
   static void makeData(){
       osf_Abacus_B2B_config__c config = new osf_Abacus_B2B_config__c(License__c = 'testlicense', Server__c = 'test.com', site_key__c = 'testkey'); 
       insert config;
   }
   @isTest
   public static void testgetConfig(){
        osf_Abacus_B2B_config__c testConfig = [SELECT License__c, Server__c, site_key__c FROM osf_Abacus_B2B_config__c LIMIT 1];
        Test.startTest();

        osf_ctrl_footer controller = new osf_ctrl_footer();

        Test.stopTest();

        System.assertEquals(testConfig.License__c,controller.getLicense());
        System.assertEquals(testConfig.Server__c,controller.getServer());
        System.assertEquals(testConfig.site_key__c,controller.getSitekey());
   }
}