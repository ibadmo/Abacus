@IsTest
public class osf_logicCartValidate_Test {
    
    @IsTest
    public static void testProcessValidate() {
        osf_testUtility testUtility = new osf_testUtility();
        Contact contact = testUtility.getContactByEmail().get(osf_testUtility.CONTACT_EMAIL1);
        contact.osf_allow_checkout__c = false;
        update contact;
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        System.runAs(user) {
            ccrz__E_Cart__c cart = testUtility.getDefaultCart();
            osf_LogicCartValidate logicCartValidate = new osf_LogicCartValidate();
            Test.startTest();
            Map<String, Object> inputData = new Map<String, Object> {
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                ccrz.ccAPICart.CART_ID => cart.Id,
                ccrz.ccAPICart.BYSTOREFRONT => osf_testUtility.STOREFRONT,
                ccrz.ccAPICart.BYOWNER => user.Id,
                ccrz.ccAPICART.BYUSER => user.Id,
                ccrz.ccAPICart.CARTTYPE => osf_testUtility.CART_TYPE,
                ccrz.ccAPICart.CARTSTATUS => osf_testUtility.OPEN_STATUS,
                ccrz.ccAPICart.ALLOW_CHECKOUT => true
            };
            Map<String, Object> outputData = logicCartValidate.processValidate(inputData);
            Test.stopTest();
            System.assert(!(Boolean) outputData.get(ccrz.ccAPICart.ALLOW_CHECKOUT));
        }
    }
}