/**
 * File:        osf_processOrders_quable.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 26, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Queueable class for sending orders to ERP
  ************************************************************************
 * History:
 */

global without sharing class osf_processOrders_quable implements Queueable, Database.AllowsCallouts {
    private List<ccrz__E_OrderItem__c> lstOrderItems; 
    private ccrz__E_Order__c order;

    /**********************************************************************************************
    * @Name         : osf_processOrders_quable
    * @Description  : constructor
    * @Created By   : Alina Craciunel
    * @Created Date : Feb 26, 2020
    * @param        : List<ccrz__E_OrderItem__c> lstOrderItems to process
    * @Return       : 
    *********************************************************************************************/
    public osf_processOrders_quable(ccrz__E_Order__c order, List<ccrz__E_OrderItem__c> lstOrderItems){
        this.lstOrderItems = lstOrderItems ;  
        this.order = order;
    }

    /**********************************************************************************************
    * @Name         : execute
    * @Description  : execute method
    * @Created By   : Alina Craciunel
    * @Created Date : Feb 26, 2020
    * @param        : QueueableContext qc
    * @Return       : 
    *********************************************************************************************/
    public void execute(QueueableContext qc) {
        order = [SELECT Id, osf_order_number__c, ccrz__Account__c, ccrz__Account__r.Name, ccrz__Account__r.osf_client_code__c, ccrz__Account__r.osf_cif_number__c, ccrz__Account__r.osf_payment_condition__c, ccrz__Contact__r.Name, ccrz__Contact__r.Email, ccrz__Contact__r.Phone, ccrz__ShipAmount__c, ccrz__Note__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondline__c, ccrz__ShipTo__r.ccrz__AddressThirdline__c, ccrz__ShipTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__City__c, ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondline__c, ccrz__BillTo__r.ccrz__AddressThirdline__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__BillTo__r.ccrz__City__c, ccrz__RequestDate__c, ccrz__TotalAmount__c, (SELECT ccrz__PaymentType__c FROM ccrz__TransactionPayments__r) FROM ccrz__E_Order__c WHERE Id =: order.Id];
        lstOrderItems = [SELECT ccrz__Product__r.ccrz__SKU__c, ccrz__ItemTotal__c, ccrz__PercentDiscount__c, ccrz__AbsoluteDiscount__c, ccrz__Quantity__c, ccrz__Price__c, ccrz__Product__r.osf_tax_rate__c, ccrz__Product__r.ccrz__ProductType__c, osf_negotiated_discount__c, ccrz__Coupon__r.ccrz__DiscountAmount__c, osf_negotiated_price__c, osf_negotiated_price_with_tax__c, osf_line_absolute_discount__c FROM ccrz__E_OrderItem__c WHERE ccrz__Order__c =: order.Id];
        Boolean createCustomerInERP = false;
        String clientCode = order.ccrz__Account__r.osf_client_code__c;
        osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
        String paymentCondition = config.osf_default_payment_condition__c;
        String error;
        try {
            absisIntranetAbacus.resultatConsultarClientsB2BSalesforce resultatConsultarClientsB2BSalesforce = osf_utilityERP.checkCustomerExistsInERP(order.ccrz__Account__r.osf_cif_number__c, order.ccrz__Account__r.osf_client_code__c); 
            createCustomerInERP = resultatConsultarClientsB2BSalesforce.llistaDireccions == null;
            if (createCustomerInERP) {
                absisIntranetAbacus.resultatClientWeb resultatActualizarClient = osf_utilityERP.actualitzarClientInERP(order.ccrz__Contact__r, order.ccrz__Account__r.osf_cif_number__c, order.ccrz__Account__c);
                if (resultatActualizarClient.actualitzacioOK) {
                    clientCode = resultatActualizarClient.client.codi;
                } else {
                    error = resultatActualizarClient.error;
                }
            } 
            if (!string.isBlank(resultatConsultarClientsB2BSalesforce.condicioPagament)) {
                paymentCondition = resultatConsultarClientsB2BSalesforce.condicioPagament;
            }
        } catch(Exception ex) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:execute:absisIntranetAbacus:Error', ex);
        }
        resultat.ResultatOperacioComanda resultat = osf_utilityERP.createOrder(order, lstOrderItems, clientCode, paymentCondition);
        if (resultat.actualitzacioOK) {
            order.osf_processed__c = true;
        } else {
            order.osf_error__c = resultat.error;
            order.osf_order_error__c = true;
        }
        order.osf_number_of_attempts__c = 1;
        Database.update(order);
        if ((createCustomerInERP && (order.ccrz__Account__r.osf_client_code__c != clientCode || String.isNotBlank(error))) || order.ccrz__Account__r.osf_payment_condition__c != paymentCondition) {
            Database.update(new Account(
                Id = order.ccrz__Account__c,
                osf_client_code__c = clientCode,
                osf_error__c = error,
                osf_payment_condition__c = paymentCondition
            ));
        }
    }
}