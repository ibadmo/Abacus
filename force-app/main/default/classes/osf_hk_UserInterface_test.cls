@isTest
public class osf_hk_UserInterface_test {
    @isTest
    static void testEndContent(){
        Map<String,Object> inputData = new Map<String,Object>();

        osf_hk_UserInterface hook = new osf_hk_UserInterface();
		String EOB_CONTENT = 'eobContent';
        Test.startTest();
        Map<String,Object> outputData = hook.endContent(inputData);
        Test.stopTest();
		
        String endContent = (String)outputData.get(EOB_CONTENT);
        System.assertNotEquals(null,endContent);
    }

    @isTest
    static void testMetaContent(){
        osf_hk_UserInterface hook = new osf_hk_UserInterface();
        String metaContentResult = '';

        Test.startTest();
        metaContentResult = hook.metaContent();
        Test.stopTest();

        System.assertNotEquals(null,metaContentResult);
    }
}