@IsTest
global class osf_realtime_stockcheck_test implements WebServiceMock{

    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (requestName == 'consultarEstocBotiga') {
            absis.consultarEstocBotigaResponse resp = new absis.consultarEstocBotigaResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'cercarArticles') {
            absis.cercarArticlesResponse resp = new absis.cercarArticlesResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'consultarEstocBotigaPerLlista') {
            absis.consultarEstocBotigaPerLlistaResponse resp = new absis.consultarEstocBotigaPerLlistaResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'toString') {
            absis.toStringResponse resp = new absis.toStringResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'consultarEstocCentreDistribucioB2BSalesforce') {
            absis.consultarEstocCentreDistribucioB2BSalesforceResponse resp = new absis.consultarEstocCentreDistribucioB2BSalesforceResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'init') {
            absis.initResponse resp = new absis.initResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'consultaLotsB2C') {
            absis.consultaLotsB2CResponse resp = new absis.consultaLotsB2CResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'consultarDiesEstimatsEnviament') {
            absis.consultarDiesEstimatsEnviamentResponse resp = new absis.consultarDiesEstimatsEnviamentResponse();
            response.put('response_x', resp); 
        } else if (requestName == 'consultarEstocProveidor') {
            absis.consultarEstocProveidorResponse resp = new absis.consultarEstocProveidorResponse();
            response.put('response_x', resp); 
        }
   }
    
    //cover additional classes that generated with wsdl
	@IsTest
    static void webserviceclasses_test(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new osf_realtime_stockcheck_test());
        estocs.EstocBotiga estoc = new estocs.EstocBotiga();
        estocs.EstocBotigaPerArticle estocarticle = new estocs.EstocBotigaPerArticle();
        absis.consultarEstocProveidorResponse consultarEstocProveidorResponse = new absis.consultarEstocProveidorResponse();
        absis.consultarEstocBotiga consultarEstocBotiga = new absis.consultarEstocBotiga();
        absis.cercarArticles cercarArticles = new absis.cercarArticles();
        absis.registreMinMax registreMinMax = new absis.registreMinMax();
        absis.centresAmbTransport centresAmbTransport = new absis.centresAmbTransport();
        absis.ean ean = new absis.ean();
        absis.persistenceAuditableObject a = new absis.persistenceAuditableObject();
        absis.consultaLotsB2C b = new absis.consultaLotsB2C();
        absis.tarifaPVP c = new absis.tarifaPVP();
        absis.toStringResponse d = new absis.toStringResponse();
        absis.cercarArticlesResponse e = new absis.cercarArticlesResponse();
        absis.tarifa f	= new absis.tarifa();
        absis.init g = new absis.init();
        absis.consultarEstocProveidor h = new absis.consultarEstocProveidor();
        absis.estocProveidor i = new absis.estocProveidor();
        absis.initResponse j = new absis.initResponse();
        absis.tarifaPSoci k = new absis.tarifaPSoci();
        absis.centre l = new absis.centre();
        absis.tipusCentre m =  new absis.tipusCentre();
        absis.aprovisionament n = new absis.aprovisionament();
        absis.componentLot p = new absis.componentLot();
        absis.comandesServidesPerCentre r = new absis.comandesServidesPerCentre();
        absis.article s = new absis.article();
        absis.persistenceObject t = new absis.persistenceObject();
        absis.caracteristicaLot u = new absis.caracteristicaLot();
        absis.consultarEstocBotigaResponse v = new absis.consultarEstocBotigaResponse();
        absis.resultatConsultaLotsB2C y = new absis.resultatConsultaLotsB2C();
        absis.toString q = new absis.toString();
        absis.tarifaAbacs a1 = new absis.tarifaAbacs();
        absis.consultaLotsB2CResponse b1 = new absis.consultaLotsB2CResponse();
        absis.consultarEstocCentreDistribucioB2BSalesforce consultar = new absis.consultarEstocCentreDistribucioB2BSalesforce();
        absis.paramArticle paramArticle = new absis.paramArticle();
        absis.consultarDiesEstimatsEnviamentResponse response = new absis.consultarDiesEstimatsEnviamentResponse();
        absis.transportista transportista = new absis.transportista();
        absis.consultarDiesEstimatsEnviament consultarDiesEstimats = new absis.consultarDiesEstimatsEnviament();
        absis.consultarEstocBotigaPerLlista consultarBotiga = new absis.consultarEstocBotigaPerLlista();
        absis.resultatDiesEstimats resultatDies = new absis.resultatDiesEstimats();
        absis.consultarEstocBotigaPerLlistaResponse consultarEstoc = new absis.consultarEstocBotigaPerLlistaResponse();
        absis.nouTarifa nouTarifa = new absis.nouTarifa();
        absis.llistaArticles llistaArticles = new absis.llistaArticles();
        absis.diesEstimats diesEstimats = new absis.diesEstimats();
        absis.ArticleWSPort articleWSPort = new absis.ArticleWSPort();
        absis.consultarEstocCentreDistribucioB2BSalesforceResponse consultarEstocCentreDistribucio = new absis.consultarEstocCentreDistribucioB2BSalesforceResponse();
        absis.estocCL estoCL = new absis.estocCL();
        articleWSPort.consultarEstocBotiga('123', 1);
        articleWSPort.cercarArticles('','es', 100);
        articleWSPort.consultarEstocBotigaPerLlista(new absis.llistaArticles());
        articleWSPort.toString();
        articleWSPort.consultarEstocCentreDistribucioB2BSalesforce('', new String[]{});
        articleWSPort.init();
        articleWSPort.consultaLotsB2C('', '', '', '');
        articleWSPort.consultarDiesEstimatsEnviament(new absis.llistaArticles(), '', '');
        articleWSPort.consultarEstocProveidor('', '', 1);
        Test.stopTest();
    }
}