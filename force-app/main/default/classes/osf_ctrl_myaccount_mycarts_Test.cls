@IsTest
public class osf_ctrl_myaccount_mycarts_Test {
    
    @IsTest
    public static void testFetchCartItems() {
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        insert product;
        System.runAs(user) {
            ccrz__E_Cart__c cart = testUtility.getDefaultCart();
            ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 1000);
            insert cartItem;
            ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
            Test.startTest();
            ccrz.cc_RemoteActionResult result = osf_ctrl_myaccount_mycarts.fetchCartItems(context, cart.Id);
            Test.stopTest();
            System.assert(result.success);
            Map<String, Object> data = (Map<String, Object>) result.data;
            List<List<Map<String, Object>>> cartItems = (List<List<Map<String, Object>>>) data.get(osf_constant_strings.CART_ITEMS);
            List<Map<String, Object>> cartItemMapList = cartItems[0];
            System.assertEquals(1, cartItemMapList.size());
            Map<String, Object> cartItemData = cartItemMapList[0];
            String cartItemId = (String) cartItemData.get(osf_constant_strings.SFID);
            System.assertEquals(cartItem.Id, cartItemId);
        }
    }

    @IsTest
    public static void testChangeActiveCart() {
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        Contact contact = testUtility.getContactByEmail().get(osf_testUtility.CONTACT_EMAIL1);
        System.runAs(user) {
            ccrz__E_Cart__c cart = testUtility.getDefaultCart();
            ccrz__E_Cart__c cart2 = osf_testUtility.createCart(null, null, 10, 10, account, user, contact);
            cart2.ccrz__ActiveCart__c = true;
            insert cart2;
            cart2 = [SELECT Id, ccrz__EncryptedId__c FROM ccrz__E_Cart__c WHERE Id = :cart2.Id];
            ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
            Test.startTest();
            ccrz.cc_RemoteActionResult result = osf_ctrl_myaccount_mycarts.changeActiveCart(context, cart2.ccrz__EncryptedId__c);
            Test.stopTest();

            List<ccrz__E_Cart__c> cartList = [SELECT Id, ccrz__ActiveCart__c FROM ccrz__E_Cart__c WHERE Id = :cart.Id OR Id = :cart2.Id];
            for(ccrz__E_Cart__c changedCart : cartList) {
                if(cart.Id == changedCart.Id) {
                    System.assert(!changedCart.ccrz__ActiveCart__c);
                } else {
                    System.assert(changedCart.ccrz__ActiveCart__c);
                }
            }
        }
    }
}