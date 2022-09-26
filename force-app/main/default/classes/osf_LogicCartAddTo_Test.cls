@IsTest
public class osf_LogicCartAddTo_Test {
    
    @IsTest
    public static void testHandlePricing() {
        osf_logicCartAddTo logic = new osf_logicCartAddTo();

        Account account = osf_testUtility.createAccount('Test Company');
        insert account;

        Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        insert contact;

        User user = osf_testUtility.createCommunityUser(contact);
        insert user;

        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product');
        insert product;

        ccrz__E_Cart__c cart = osf_testUtility.createCart(null, null, 0, 0, account, user, contact);
        insert cart;

        ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 100);
        insert cartItem;

        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPICart.CURR_CARTITEM => cartItem,
            ccrz.ccAPICart.CURR_PRODUCT => new Map<String, Object> {
                osf_constant_strings.DISCOUNT_AMOUNT => 10
            }
        };

        Map<String, Object> outputData = logic.handlePricing(inputData);
        System.assert(!outputData.isEmpty());
    }
}