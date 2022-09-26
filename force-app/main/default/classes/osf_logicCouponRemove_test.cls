@IsTest
public class osf_logicCouponRemove_test {

    @TestSetup
    public static void createTestData(){
        Account account = osf_testUtility.createAccount('Test Company');
        insert account;

        Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        insert contact;

        User user = osf_testUtility.createCommunityUser(contact);
        insert user;

        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        insert product;
        
        ccrz__E_Coupon__c coupon = osf_testUtility.createCoupon('Test Coupon', 'CartTotal', 'Absolute', 10);
        insert coupon;

        System.runAs(user) {
            ccrz__E_Cart__c cart = osf_testUtility.createCart(null, null, 0, 0, account, user, contact);
            cart.osf_coupon_removed_manually__c = false;
            insert cart;

            ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 1000);
            insert cartItem;

            ccrz__E_CartCoupon__c cartCoupon = osf_testUtility.createCartCoupon(cart, coupon);
            insert cartCoupon;
        }
    }    

    @IsTest
    public static void testRemove() {
        User user = [SELECT Id, LanguageLocaleKey FROM User WHERE Username = 'test@email.com' LIMIT 1];
        Map<String, Object> outputData = new Map<String, Object> ();
        osf_logicCouponRemove logicCouponRemove = new osf_logicCouponRemove();
        System.runAs(user) {
            ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c, (SELECT Id, ccrz__Price__c, ccrz__SubAmount__c, ccrz__Quantity__c, ccrz__Product__c, ccrz__Cart__c, ccrz__AdjustmentAmount__c FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c WHERE ccrz__User__c = :user.Id LIMIT 1];
            Test.startTest();
            Map<String, Object> inputData = new Map<String, Object> {
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                'ccLogicCouponRemove.fetchCartData' => cart,
                ccrz.ccAPICart.CART_ENCID => cart.ccrz__EncryptedId__c,
                'ccLogicCouponRemove.dmlCartItems' => cart.ccrz__E_CartItems__r,
                ccrz.ccAPICart.CART_ID => cart.Id

            };
            outputData = logicCouponRemove.remove(inputData);
            Test.stopTest();
            cart = [SELECT osf_coupon_removed_manually__c FROM ccrz__E_Cart__c WHERE Id = :cart.Id];
            System.assert(cart.osf_coupon_removed_manually__c);
        }
    }

    @IsTest
    public static void testRemoveCatchBlock() {
        osf_logicCouponRemove logicCouponRemove = new osf_logicCouponRemove();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
        };
        Map<String, Object> outputData = logicCouponRemove.remove(inputData);
        Test.stopTest();
        System.assert(!outputData.isEmpty());
    }
}