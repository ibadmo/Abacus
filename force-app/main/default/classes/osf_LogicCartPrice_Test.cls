@IsTest
public with sharing class osf_LogicCartPrice_Test {
    
    @IsTest
    public static void testPrepareCartItems() {
        osf_LogicCartPrice logicCartPrice = new osf_LogicCartPrice();

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
        cartItem.ccrz__AdjustmentAmount__c = -10;
        cartItem.ccrz__ProductType__c = osf_constant_strings.PRODUCT_TYPE_PRODUCT;
        insert cartItem;

        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            osf_constant_strings.CART_TO_PRICE => cart,
            osf_constant_strings.CART_ITEMS_TO_PRICE => new List<ccrz__E_CartItem__c> {cartItem},
            ccrz.ccAPICart.CILIST => new List<ccrz__E_CartItem__c> {cartItem}
        };
        Map<String, Object> outputData = logicCartPrice.prepareCartItems(inputData);
        List<ccrz__E_CartItem__c> cartItemList = (List<ccrz__E_CartItem__c>) outputData.get(ccrz.ccAPICart.CILIST);
        System.assertEquals(-10, cartItemList[0].ccrz__AdjustmentAmount__c);
    }
}