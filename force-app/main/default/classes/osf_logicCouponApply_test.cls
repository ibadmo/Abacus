@IsTest
public class osf_logicCouponApply_test {

    @TestSetup
    public static void createTestData(){
        Account account = osf_testUtility.createAccount('Test Company');
        insert account;

        Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        insert contact;

        User user = osf_testUtility.createCommunityUser(contact);
        insert user;

        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        product.osf_catalog_id__c = '01-123';
        insert product;
        
        ccrz__E_Coupon__c coupon = osf_testUtility.createCoupon('Test Coupon', 'CartTotal', 'Absolute', 10);
        insert coupon;

        osf_negotiated_discount__c negotiatedDiscount = osf_TestUtility.createNegotiatedDiscount(account, 50, null, '01', coupon.Id);
        insert negotiatedDiscount;

        System.runAs(user) {
            ccrz__E_Cart__c cart = osf_testUtility.createCart(null, null, 0, 0, account, user, contact);
            insert cart;

            ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 1000);
            insert cartItem;
        }
    }    

    @IsTest
    public static void testAddCoupon() {
        User user = [SELECT Id, LanguageLocaleKey FROM User WHERE Username = 'test@email.com' LIMIT 1];
        Map<String, Object> outputData = new Map<String, Object> ();
        osf_logicCouponApply logicCouponApply = new osf_logicCouponApply();
        System.runAs(user) {
            ccrz__E_Cart__c cart = [SELECT Id, ccrz__EncryptedId__c, (SELECT Id, ccrz__Price__c, ccrz__SubAmount__c, ccrz__Quantity__c, ccrz__Product__c, ccrz__Cart__c, ccrz__AdjustmentAmount__c FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c WHERE ccrz__User__c = :user.Id LIMIT 1];
            Test.startTest();
            Map<String, Object> inputData = new Map<String, Object> {
                ccrz.ccAPICoupon.CART_HEADER => cart,
                ccrz.ccAPICoupon.CART_ITEMS => cart.ccrz__E_CartItems__r,
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
            };
            outputData = logicCouponApply.addCoupon(inputData);
            Test.stopTest();
        }
        System.assertEquals('Test Coupon', (String) outputData.get(ccrz.ccAPICoupon.CODE));
    }

    @IsTest
    public static void testAddCouponCatchBlock() {
        osf_logicCouponApply logicCouponApply = new osf_logicCouponApply();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
        };
        Map<String, Object> outputData = logicCouponApply.addCoupon(inputData);
        Test.stopTest();
        System.assert(outputData.isEmpty());
    }
}