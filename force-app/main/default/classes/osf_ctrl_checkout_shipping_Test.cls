@IsTest
public class osf_ctrl_checkout_shipping_Test {
    
    @IsTest
    public static void testCalculateShippingCost() {
        insert new osf_Abacus_B2B_config__c (
            osf_balearic_island_free_shipping_limit__c = 50,
            osf_balearic_island_shipping_cost__c = 7,
            osf_free_shipping_limit__c = 35,
            osf_shipping_cost__c = 4.95
        );
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        Map<String, Contact> mapContact = testUtility.getContactByEmail();
        Contact contact = mapContact.get(osf_testUtility.CONTACT_EMAIL1);
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        Database.insert(product);
        ccrz__E_Cart__c cart;
        System.runAs(user) {
            cart = testutility.getDefaultCart();
            ccrz__E_ContactAddr__c contactAddress = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress;
            cart.ccrz__ShipTo__c = contactAddress.Id;
            cart.ccrz__BillTo__c = contactAddress.Id;
            update cart;
            ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 1000);
            Database.insert(cartItem);
        }

        ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_checkout_shipping.calculateShippingCost(context, 100, cart.ccrz__ShipTo__c);
        Test.stopTest();
        System.assert(result.success);
        Map<String, Object> data = (Map<String, Object>) result.data;
        System.assert(data.containsKey(osf_constant_strings.SHIPPING_CHARGE));
        System.assertEquals(0, (Decimal) data.get(osf_constant_strings.SHIPPING_CHARGE));
    }

    @IsTest
    public static void testcalculateLongestDeliveryTime(){
        insert new osf_Abacus_B2B_config__c (Standard_delivery_time__c = 48);

        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);

        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        insert product;

        ccrz__E_Cart__c cart;
        System.runAs(user) {
            cart = testutility.getDefaultCart();
            ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 1000);
            insert cartItem;
        }

        ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_checkout_shipping.calculateLongestDeliveryTime(context);
        Test.stopTest();

        System.assert(result.success);
        Map<String, Object> data = (Map<String, Object>) result.data;
        System.assert(data.containsKey(osf_constant_strings.DELIVERY_TIME));

    }

    @IsTest
    public static void testCheckDefaultAddresses() {
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        Map<String, Contact> mapContact = testUtility.getContactByEmail();
        Contact contact = mapContact.get(osf_testUtility.CONTACT_EMAIL1);
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product Name');
        Database.insert(product);
        ccrz__E_Cart__c cart;
        System.runAs(user) {
            cart = testutility.getDefaultCart();
            ccrz__E_ContactAddr__c contactAddress = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress;
            cart.ccrz__ShipTo__c = contactAddress.Id;
            cart.ccrz__BillTo__c = contactAddress.Id;
            update cart;
            ccrz__E_CartItem__c cartItem = osf_testUtility.createCartItem(product, cart, 1, 1000);
            Database.insert(cartItem);
            insert new List<ccrz__E_AccountAddressBook__c> {
                osf_testUtility.createAccountAddressBook('Test Billing', account, contactAddress, 'Billing', true),
                osf_testUtility.createAccountAddressBook('Test Shipping', account, contactAddress, 'Shipping', true)
            };
        }
        ccrz.cc_CallContext.currAccountId = account.Id;
        ccrz.cc_RemoteActionContext context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        Test.startTest();
        ccrz.cc_RemoteActionResult result = osf_ctrl_checkout_shipping.checkDefaultAddresses(context);
        Test.stopTest();
        System.assert(result.success);

        Map<String, Object> data = (Map<String, Object>) result.data;
        System.assert((Boolean) data.get(osf_constant_strings.HAS_DEFAULT_SHIPPING));
        System.assert((Boolean) data.get(osf_constant_strings.HAS_DEFAULT_BILLING));
    }

}