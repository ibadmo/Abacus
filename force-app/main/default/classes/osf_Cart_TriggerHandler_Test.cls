@IsTest
public class osf_Cart_TriggerHandler_Test {
    
    @IsTest
    public static void testAfterUpdate() {
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz__E_Cart__c cart;
        Account account = testUtility.getDefaultAccount();
        Contact contact = testUtility.getContactByEmail().get(osf_testUtility.CONTACT_EMAIL1);
        System.runAs(user) {
            cart = testUtility.getDefaultCart();
            cart.ccrz__CartStatus__c = 'Closed';
            update cart;
            List<ccrz__E_Cart__c> cartList = [SELECT Id, ccrz__ActiveCart__c, ccrz__CartStatus__c, ccrz__Storefront__c, ccrz__Name__c, ccrz__CartType__c, ccrz__CurrencyISOCode__c, ccrz__User__c, OwnerId, ccrz__Contact__c, ccrz__Account__c FROM ccrz__E_Cart__c WHERE ccrz__User__c = :user.Id AND ccrz__CartStatus__c = :osf_constant_strings.CART_STATUS_OPEN];
            System.assertEquals(1, cartList.size());
            ccrz__E_Cart__c newCart = cartList[0];
            System.assertEquals(osf_constant_strings.DEFAULT_STORE, newCart.ccrz__Storefront__c);
            System.assertEquals(osf_constant_strings.NEW_CART, newCart.ccrz__Name__c);
            System.assertEquals(osf_constant_strings.CART_TYPE_CART, newCart.ccrz__CartType__c);
            System.assertEquals(osf_constant_strings.DEFAULT_STORE, newCart.ccrz__Storefront__c);
            System.assertEquals(osf_constant_strings.CURRENCY_EUR, newCart.ccrz__CurrencyISOCode__c);
            System.assertEquals(user.Id, newCart.OwnerId);
            System.assertEquals(contact.Id, newCart.ccrz__Contact__c);
            System.assertEquals(account.Id, newCart.ccrz__Account__c);
            System.assert(newCart.ccrz__ActiveCart__c);
        }
    }

    @IsTest
    public static void testAfterDelete() {
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz__E_Cart__c cart;
        Account account = testUtility.getDefaultAccount();
        Contact contact = testUtility.getContactByEmail().get(osf_testUtility.CONTACT_EMAIL1);
        System.runAs(user) {
            cart = testUtility.getDefaultCart();
            delete cart;
            List<ccrz__E_Cart__c> cartList = [SELECT Id, ccrz__ActiveCart__c, ccrz__CartStatus__c, ccrz__Storefront__c, ccrz__Name__c, ccrz__CartType__c, ccrz__CurrencyISOCode__c, ccrz__User__c, OwnerId, ccrz__Contact__c, ccrz__Account__c FROM ccrz__E_Cart__c WHERE ccrz__User__c = :user.Id AND ccrz__CartStatus__c = :osf_constant_strings.CART_STATUS_OPEN];
            System.assertEquals(1, cartList.size());
            ccrz__E_Cart__c newCart = cartList[0];
            System.assertEquals(osf_constant_strings.DEFAULT_STORE, newCart.ccrz__Storefront__c);
            System.assertEquals(osf_constant_strings.NEW_CART, newCart.ccrz__Name__c);
            System.assertEquals(osf_constant_strings.CART_TYPE_CART, newCart.ccrz__CartType__c);
            System.assertEquals(osf_constant_strings.DEFAULT_STORE, newCart.ccrz__Storefront__c);
            System.assertEquals(osf_constant_strings.CURRENCY_EUR, newCart.ccrz__CurrencyISOCode__c);
            System.assertEquals(user.Id, newCart.OwnerId);
            System.assertEquals(contact.Id, newCart.ccrz__Contact__c);
            System.assertEquals(account.Id, newCart.ccrz__Account__c);
            System.assert(newCart.ccrz__ActiveCart__c);
        }
    }
}