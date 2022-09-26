/**
 * File:        osf_hk_Order_Test.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 27, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Test calss for osf_hk_Order
  ************************************************************************
 * History:
 */

@isTest
global class osf_hk_Order_Test implements WebServiceMock { 
    private static final String PAYMENT = 'Test Payment';
    
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (requestName == 'consultarClientsB2BSalesforce') { 
            absisIntranetAbacus.consultarClientsB2BSalesforceResponse resp = new absisIntranetAbacus.consultarClientsB2BSalesforceResponse();
            absisIntranetAbacus.resultatConsultarClientsB2BSalesforce resultatConsultarClientsB2BSalesforce = new absisIntranetAbacus.resultatConsultarClientsB2BSalesforce();
            absisIntranetAbacus.direccioClient direccioClient = new absisIntranetAbacus.direccioClient();
            absisIntranetAbacus.direccioClient[] direccioClientArray = new absisIntranetAbacus.direccioClient[]{direccioClient};
            resultatConsultarClientsB2BSalesforce.llistaDireccions = direccioClientArray;
            resultatConsultarClientsB2BSalesforce.condicioPagament = PAYMENT;
            resp.ResultatConsultarClientsB2BSalesforce = resultatConsultarClientsB2BSalesforce;
            response.put('response_x', resp); 
        } else if (requestName == 'actualitzarClient') {
            absisIntranetAbacus.actualitzarClientResponse resp = new absisIntranetAbacus.actualitzarClientResponse();
            absisIntranetAbacus.resultatClientWeb resultat = new absisIntranetAbacus.resultatClientWeb();
            resultat.actualitzacioOK = true;
            resp.resultat = resultat;
            response.put('response_x', resp); 
        } else if (requestName == 'crearComandaWebB2BSalesforce'){
            resultat.ResultatOperacioComanda resultat = new resultat.ResultatOperacioComanda();
            resultat.actualitzacioOK = true;
            response.put('response_x', resultat); 
        }
   }

    /* 
    * @description  : test testPlace method
    * @author       : Alina Craciunel
    * @createdDate  : Feb 27, 2020
    * @param        : 
    * @return       : 
    */
    @isTest
    static void testPlace() {
        osf_hk_Order hook = new osf_hk_Order();
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product');
        insert product;
        ccrz__E_Order__c order;
        Map<String, Object> inputData;
        System.runAs(user) {
            ccrz__E_Cart__c cart = testUtility.getDefaultCart();
            ccrz__E_ContactAddr__c contactAddress1 = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress1;
            ccrz__E_ContactAddr__c contactAddress2 = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress2;
            cart.ccrz__ShipTo__c = contactAddress1.Id;
            cart.ccrz__BillTo__c = contactAddress2.Id;
            update cart;
            ccrz__E_CartItem__c ci1 = osf_testUtility.createCartItem(product, cart, 1, 20);
            insert ci1;
            order = osf_testUtility.createCCOrder(cart);
            order.ccrz__Account__c = account.Id;
            insert order;
            ccrz__E_OrderItem__c orderItem = osf_testUtility.createCCOrderItem(order, product, 1, 20);
            insert orderItem;
            inputData = new Map<String, Object> {
                ccrz.cc_hk_Order.PARAM_CART_ID => cart.Id,
                ccrz.cc_hk_Order.PARAM_CART => cart,
                ccrz.cc_hk_Order.PARAM_CART_ITEMS => new List<ccrz__E_CartItem__c> {ci1},
                ccrz.cc_hk_Order.PARAM_ORDER => order,
                ccrz.cc_hk_Order.PARAM_ORDER_ITEMS => new List<ccrz__E_OrderItem__c> {orderItem},
                ccrz.cc_hk_Order.PARAM_PLACE_STEP => ccrz.cc_hk_Order.STEP_END
            };
            Test.startTest();
            Test.setMock(WebServiceMock.class, new osf_hk_Order_Test());
            hook.place(inputData);
            Test.stopTest();
        }
        order = [SELECT osf_processed__c FROM ccrz__E_Order__c WHERE Id =: order.Id];
        system.assertEquals(true, order.osf_processed__c);
    }

    @IsTest
    public static void testPlaceEnd() {
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        Account account = testUtility.getDefaultAccount();
        Map<String, Contact> mapContact = testUtility.getContactByEmail();
        Contact contact = mapContact.get(osf_testUtility.CONTACT_EMAIL1);
        contact contact2 = mapContact.get(osf_testUtility.CONTACT_EMAIL2);
        contact.osf_supervisor__c = contact2.Id;
        update contact;
        ccrz__E_Cart__c cart;
        ccrz__E_Order__c order;
        System.runAs(user) {
            cart = [SELECT Id, ccrz__EncryptedId__c, ccrz__ShipTo__c, ccrz__BillTo__c FROM ccrz__E_Cart__c WHERE Id = :testUtility.getDefaultCart().Id];
            order = osf_testUtility.createCCOrder(cart);
            insert order;
        }
        ccrz.cc_RemoteActionContext context = testutility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        ccrz.cc_RemoteActionResult result = osf_ctrl_cartdetail_actionstotal.submitCart(context);
        osf_hk_Order orderHook = new osf_hk_Order();
        Test.startTest();
        Map<String, Object> inputData = new Map<String, Object> {
            ccrz.cc_hk_Order.PARAM_CART => cart,
            ccrz.cc_hk_Order.PARAM_ORDER => order,
            ccrz.cc_hk_Order.PARAM_PLACE_STEP => ccrz.cc_hk_Order.STEP_END
        };
        Map<String, Object> outputData = orderHook.place(inputData);
        Test.stopTest();
        List<ccrz__E_Order__Share> orderShareList = [SELECT Id FROM ccrz__E_Order__Share WHERE AccessLevel = :osf_constant_strings.ACCESS_LEVEL_EDIT AND ParentId = :order.Id];
        System.assertEquals(1, orderShareList.size());
    }

    @IsTest
    public static void testPlaceOrderItemPre() {
        osf_hk_Order hook = new osf_hk_Order();
        osf_testUtility testUtility = new osf_testUtility();
        Map<String, User> usermap = testUtility.getUsernameMap();
        User user = usermap.get(osf_testUtility.USER_EMAIL1);
        ccrz__E_Product__c product = osf_testUtility.createCCProduct('Test SKU', 'Test Product');
        insert product;
        ccrz__E_Order__c order;
        Map<String, Object> inputData;
        System.runAs(user) {
            ccrz__E_Cart__c cart = testUtility.getDefaultCart();
            ccrz__E_ContactAddr__c contactAddress1 = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress1;
            ccrz__E_ContactAddr__c contactAddress2 = osf_testUtility.createContactAddress(user.FirstName, user.LastName, 'Test Address', 'Majorca', 'Test State', 'Spain', 'SP', '07125', 'Test Company');
            insert contactAddress2;
            cart.ccrz__ShipTo__c = contactAddress1.Id;
            cart.ccrz__BillTo__c = contactAddress2.Id;
            update cart;
            ccrz__E_CartItem__c ci1 = osf_testUtility.createCartItem(product, cart, 1, 20);
            ci1.ccrz__AdjustmentAmount__c = 10;
            ci1.osf_negotiated_discount__c = 5;
            insert ci1;
            order = osf_testUtility.createCCOrder(cart);
            insert order;
            ccrz__E_OrderItem__c orderItem = osf_testUtility.createCCOrderItem(order, product, 1, 20);
            inputData = new Map<String, Object> {
                ccrz.cc_hk_Order.PARAM_CART_ID => cart.Id,
                ccrz.cc_hk_Order.PARAM_CART => cart,
                ccrz.cc_hk_Order.PARAM_CART_ITEMS => new List<ccrz__E_CartItem__c> {ci1},
                ccrz.cc_hk_Order.PARAM_ORDER => order,
                ccrz.cc_hk_Order.PARAM_ORDER_ITEMS => new List<ccrz__E_OrderItem__c> {orderItem},
                ccrz.cc_hk_Order.PARAM_PLACE_STEP => ccrz.cc_hk_Order.STEP_CREATE_ORDER_ITEMS_PRE
            };
            Test.startTest();
            Map<String, Object> outputData = hook.place(inputData);
            Test.stopTest();
            List<ccrz__E_OrderItem__c> orderItemlist = (List<ccrz__E_OrderItem__c>) outputData.get(ccrz.cc_hk_Order.PARAM_ORDER_ITEMS);
            ccrz__E_OrderItem__c newOrderItem = orderItemList[0];
            System.assertEquals(10, newOrderItem.ccrz__AdjustmentAmount__c);
            System.assertEquals(5, newOrderItem.osf_negotiated_discount__c);
        }
    }
}