@IsTest
public class osf_ctrl_checkout_order_section_test {
    
    @IsTest
    public static void testGetPrices() {
    osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product');
        insert product;
        ccrz.cc_RemoteActionResult result;
        System.runAs(user) {
            ccrz__E_Cart__c cart = testUtility.getDefaultCart();
            ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 20);
            insert cartItem;
            cart.ccrz__ShipAmount__c = 100;
            update cart;

            ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
            Test.startTest();
            result = osf_ctrl_checkout_order_section.getPrices(context);
            Test.stopTest();
        }
        System.assert(result.success);
        Map<String, Object> data = (Map<String, Object>) result.data;
        System.assert(data.containsKey(osf_constant_strings.SHIPPING_CHARGE));
        System.assertEquals(100, (Decimal) data.get(osf_constant_strings.SHIPPING_CHARGE));
    }
}