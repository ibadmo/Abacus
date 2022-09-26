/**
 * File:        absisOrder_test.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Mar 19, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: cover additional classes that generated with wsdl
  ************************************************************************
 * History:
 */

@IsTest
private class absisOrder_test{

	@IsTest
    static void webserviceclasses_test(){
        absisOrders.toStringResponse stringResponse = new absisOrders.toStringResponse();
        absisOrders.crearComandaWebResponse comandaResponse = new absisOrders.crearComandaWebResponse();
        absisOrders.toString tostring = new absisOrders.toString();
        absisOrders.crearComandaWeb createWebOrder = new absisOrders.crearComandaWeb();
        absisOrders.ComandesWSPort orderWsPort = new absisOrders.ComandesWSPort();
    }
}