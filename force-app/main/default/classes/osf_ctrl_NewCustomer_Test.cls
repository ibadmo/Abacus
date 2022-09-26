@IsTest
public class osf_ctrl_NewCustomer_Test implements WebServiceMock {
    private static final String PAYMENT = 'Test Payment';

    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        absisIntranetAbacus.consultarClientsB2BSalesforceResponse resp = new absisIntranetAbacus.consultarClientsB2BSalesforceResponse();
        absisIntranetAbacus.resultatConsultarClientsB2BSalesforce resultatConsultarClientsB2BSalesforce = new absisIntranetAbacus.resultatConsultarClientsB2BSalesforce();
        absisIntranetAbacus.direccioClient direccioClient = new absisIntranetAbacus.direccioClient();
        direccioClient.nom = 'Test Company';
        direccioClient.id = 0;
        absisIntranetAbacus.poblacio poblacio = new absisIntranetAbacus.poblacio();
        absisIntranetAbacus.provincia provincia = new absisIntranetAbacus.provincia();
        provincia.nom = 'Barcelona';
        direccioClient.poblacio = poblacio;
        absisIntranetAbacus.direccioClient[] direccioClientArray = new absisIntranetAbacus.direccioClient[]{direccioClient};
        resultatConsultarClientsB2BSalesforce.llistaDireccions = direccioClientArray;
        resultatConsultarClientsB2BSalesforce.condicioPagament = PAYMENT;
        resp.ResultatConsultarClientsB2BSalesforce = resultatConsultarClientsB2BSalesforce;
        response.put('response_x', resp);
   }

   @TestSetup
   public static void createTestData(){
       insert osf_testUtility.createCCAccountGroup('10');
   }
    
    @IsTest
    public static void testCreateNewCustomer() {
        osf_testUtility testUtility = new osf_TestUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz.cc_RemoteActionContext context;
        System.runAs(user) {
            context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        }
        Test.startTest();
        Test.setMock(WebServiceMock.class, new osf_ctrl_NewCustomer_Test());
        Map<String, Object> formData = new Map<String, Object> {
            osf_constant_strings.FIRST_NAME => 'John',
            osf_constant_strings.LAST_NAME => 'Doe',
            osf_constant_strings.USER_NAME => 'test@email.com',
            osf_constant_strings.CIF => 'Test CIF',
            osf_constant_strings.COMPANY_NAME => 'Test Company'
        };
        ccrz.cc_RemoteActionResult result = osf_ctrl_NewCustomer.registerCustomer(context, formData, true);
        Test.stopTest();
        System.assert(!result.success);
    }

    @IsTest
    public static void testCreateExistingCustomer() {
        Account account = osf_testUtility.createAccount('Test Company');
        account.osf_client_code__c = 'Test Client';
        account.osf_cif_number__c = 'Test CIF';
        insert account;
        Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        insert contact;
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz.cc_RemoteActionContext context;
        System.runAs(user) {
            context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        }
        Test.startTest();
        Test.setMock(WebServiceMock.class, new osf_ctrl_NewCustomer_Test());
        Map<String, Object> formData = new Map<String, Object> {
            osf_constant_strings.FIRST_NAME => 'John',
            osf_constant_strings.LAST_NAME => 'Doe',
            osf_constant_strings.USER_NAME => 'test@email.com',
            osf_constant_strings.CIF => 'Test CIF',
            osf_constant_strings.CLIENT_ID => 'Test Client'
        };
        ccrz.cc_RemoteActionResult result = osf_ctrl_NewCustomer.registerCustomer(context, formData, true);
        Test.stopTest();
        System.assert(!result.success);
    }

    @IsTest
    public static void testCreateExistingCustomerInERP() {
        // Account account = osf_testUtility.createAccount('Test Company');
        // account.osf_client_code__c = 'Test Client';
        // account.osf_cif_number__c = 'Test CIF';
        // insert account;
        // Contact contact = osf_testUtility.createContact('John', 'Doe', account, 'test@email.com');
        // insert contact;
        osf_testUtility testUtility = new osf_testUtility();
        User user = testUtility.getUsernameMap().get(osf_testUtility.USER_EMAIL1);
        ccrz.cc_RemoteActionContext context;
        System.runAs(user) {
            context = testUtility.getRemoteActionContext(user, osf_testUtility.STOREFRONT);
        }
        Test.startTest();
        Test.setMock(WebServiceMock.class, new osf_ctrl_NewCustomer_Test());
        Map<String, Object> formData = new Map<String, Object> {
            osf_constant_strings.FIRST_NAME => 'John',
            osf_constant_strings.LAST_NAME => 'Doe',
            osf_constant_strings.USER_NAME => 'test@email.com',
            osf_constant_strings.CIF => 'Test CIF',
            osf_constant_strings.CLIENT_ID => 'Test Client'
        };
        ccrz.cc_RemoteActionResult result = osf_ctrl_NewCustomer.registerCustomer(context, formData, true);
        Test.stopTest();
        System.assert(!result.success);
    }
}