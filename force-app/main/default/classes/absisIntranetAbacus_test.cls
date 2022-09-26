/**
 * File:        absisIntranetAbacus_test.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Apr 14, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: cover additional classes that generated with wsdl
  ************************************************************************
 * History:
 */

@IsTest
global class absisIntranetAbacus_test implements WebServiceMock {
    private static final String NIF = 'G59816991';
    private static final String CODI_CLIENT = '0000801024';
    private static final String CLIENT_NAME = 'Test Test';
    private static final String PAYMENT = 'Test Payment';

    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (requestName == 'init') {
            absisIntranetAbacus.initResponse resp = new absisIntranetAbacus.initResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'actualitzarClient') {
            absisIntranetAbacus.actualitzarClientResponse resp = new absisIntranetAbacus.actualitzarClientResponse();
            absisIntranetAbacus.resultatClientWeb resultat = new absisIntranetAbacus.resultatClientWeb();
            resultat.actualitzacioOK = true;
            resp.resultat = resultat;
            response.put('response_x', resp); 
        } else if (requestName == 'getAbacs') {
            absisIntranetAbacus.getAbacsResponse resp = new absisIntranetAbacus.getAbacsResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'consultarClientsB2BSalesforce') {
            absisIntranetAbacus.consultarClientsB2BSalesforceResponse resp = new absisIntranetAbacus.consultarClientsB2BSalesforceResponse();
            absisIntranetAbacus.resultatConsultarClientsB2BSalesforce resultatConsultarClientsB2BSalesforce = new absisIntranetAbacus.resultatConsultarClientsB2BSalesforce();
            absisIntranetAbacus.direccioClient direccioClient = new absisIntranetAbacus.direccioClient();
            absisIntranetAbacus.direccioClient[] direccioClientArray = new absisIntranetAbacus.direccioClient[]{direccioClient};
            resultatConsultarClientsB2BSalesforce.llistaDireccions = direccioClientArray;
            resultatConsultarClientsB2BSalesforce.condicioPagament = PAYMENT;
            resp.ResultatConsultarClientsB2BSalesforce = resultatConsultarClientsB2BSalesforce;
            response.put('response_x', resp); 
        } else if (requestName == 'consultarClient') {
            absisIntranetAbacus.consultarClientResponse resp = new absisIntranetAbacus.consultarClientResponse();
            resp.client = new absisIntranetAbacus.clientWeb[]{};
            response.put('response_x', resp); 
        } else if (requestName == 'toString') {
            absisIntranetAbacus.toStringResponse resp = new absisIntranetAbacus.toStringResponse();
            resp.return_x = CLIENT_NAME;
            response.put('response_x', resp);  
        } 
    }

    @IsTest
    static void webserviceclasses_test(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new absisIntranetAbacus_test());
        absisIntranetAbacus.consultarClientsB2BSalesforceResponse consultarClientsB2BSalesforceResponse = new absisIntranetAbacus.consultarClientsB2BSalesforceResponse();
        absisIntranetAbacus.clientWeb clientWeb = new absisIntranetAbacus.clientWeb();
        absisIntranetAbacus.provincia provincia = new absisIntranetAbacus.provincia();
        absisIntranetAbacus.interessos_element interessos_element = new absisIntranetAbacus.interessos_element();
        absisIntranetAbacus.direccioClient direccioClient = new absisIntranetAbacus.direccioClient();
        absisIntranetAbacus.persistenceAuditableObject persistenceAuditableObject = new absisIntranetAbacus.persistenceAuditableObject();
        absisIntranetAbacus.actualitzarClient actualitzarClient = new absisIntranetAbacus.actualitzarClient();
        absisIntranetAbacus.toStringResponse toStringResponse = new absisIntranetAbacus.toStringResponse();
        absisIntranetAbacus.consultarClientsB2BSalesforce consultarClientsB2BSalesforce = new absisIntranetAbacus.consultarClientsB2BSalesforce();
        absisIntranetAbacus.actes_element actes_element = new absisIntranetAbacus.actes_element();
        absisIntranetAbacus.resultatClientWeb resultatClientWeb = new absisIntranetAbacus.resultatClientWeb();
        absisIntranetAbacus.getAbacsResponse getAbacsResponse = new absisIntranetAbacus.getAbacsResponse();
        absisIntranetAbacus.poblacio poblacio = new absisIntranetAbacus.poblacio();
        absisIntranetAbacus.init init = new absisIntranetAbacus.init();
        absisIntranetAbacus.direccions_element direccions_element = new absisIntranetAbacus.direccions_element();
        absisIntranetAbacus.initResponse initResponse = new absisIntranetAbacus.initResponse();
        absisIntranetAbacus.consultarClientResponse consultarClientResponse = new absisIntranetAbacus.consultarClientResponse();
        absisIntranetAbacus.persistenceObject persistenceObject = new absisIntranetAbacus.persistenceObject();
        absisIntranetAbacus.actualitzarClientResponse actualitzarClientResponse = new absisIntranetAbacus.actualitzarClientResponse();
        absisIntranetAbacus.resultatAbacs resultatAbacs = new absisIntranetAbacus.resultatAbacs();
        absisIntranetAbacus.direccioClientWeb direccioClientWeb = new absisIntranetAbacus.direccioClientWeb();
        absisIntranetAbacus.getAbacs getAbacs = new absisIntranetAbacus.getAbacs();
        absisIntranetAbacus.consultarClient consultarClient = new absisIntranetAbacus.consultarClient();
        absisIntranetAbacus.toString toString = new absisIntranetAbacus.toString();
        absisIntranetAbacus.interes interes = new absisIntranetAbacus.interes();
        absisIntranetAbacus.ClientsWebWSPort clientWSPort = new absisIntranetAbacus.ClientsWebWSPort();
        clientWSPort.init();
        clientWeb.nom = CLIENT_NAME;
        absisIntranetAbacus.resultatClientWeb resultat = clientWSPort.actualitzarClient(null, CODI_CLIENT, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, NIF, osf_constant_strings.EMPTY_STRING, osf_constant_strings.CLIENT_WS_CREATE_OPERACION, clientWeb);
        resultatAbacs = clientWSPort.getAbacs(CODI_CLIENT);
        absisIntranetAbacus.resultatConsultarClientsB2BSalesforce resultatConsultarClientsB2BSalesforce = clientWSPort.consultarClientsB2BSalesforce(CODI_CLIENT, CLIENT_NAME, NIF, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING);  
        absisIntranetAbacus.clientWeb[] clientWebArray = clientWSPort.consultarClient(CODI_CLIENT, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, NIF, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING);
        String clientString = clientWSPort.toString();
        system.assertEquals(true, resultat.actualitzacioOK);
        system.assertEquals(PAYMENT, resultatConsultarClientsB2BSalesforce.condicioPagament);
        Test.stopTest();
    }
}