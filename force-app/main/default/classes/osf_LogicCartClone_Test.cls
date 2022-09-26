@IsTest
public class osf_LogicCartClone_Test {
    
    @IsTest
    public static void testDoDML() {
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        Contact contact = testUtility.getContactByEmail().get(osf_testUtility.CONTACT_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        System.runAs(user) {
            ccrz__E_Cart__c cart = osf_testUtility.createCart(null, null, 10, 10, account, user, contact);
            osf_LogicCartClone logicCartClone = new osf_LogicCartClone();
            Test.startTest();
            Map<String, Object> inputData = new Map<String, Object> {
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                ccrz.ccLogicCartClone.CART_TO_INSERT => cart
            };
            Map<String, Object> outputData = logicCartClone.doDML(inputData);
            Test.stopTest();
            System.assert(!outputData.isEmpty());
        }
    }
}