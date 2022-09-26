@IsTest
public class osf_LogicCartRemoveCart_Test {
    
    @IsTest
    public static void testRemoveCart() {
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> userMap = testUtility.getUsernameMap();
        ccrz__E_Cart__c cart;
        System.runAs(userMap.get(osf_testUtility.USER_EMAIL1)) {
            cart = testUtility.getDefaultCart();
        }
        System.runAs(userMap.get(osf_testUtility.USER_EMAIL2)) {
            osf_LogicCartRemoveCart logicCartRemoveCart = new osf_LogicCartRemoveCart();
            Map<String, Object> inputData = new Map<String, Object> {
                ccrz.ccAPICart.CART_ID => cart.Id,
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
            };
            Test.startTest();
            Map<String, Object> outputData = logicCartRemoveCart.removeCart(inputData);
            Test.stopTest();
            List<ccrz__E_Cart__c> cartList = [SELECT Id FROM ccrz__E_Cart__c WHERE Id = :cart.Id];
            System.assert(cartList.isEmpty());
        }
    }
}