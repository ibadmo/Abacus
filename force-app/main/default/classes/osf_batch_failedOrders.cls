/**
 * File:        osf_batch_failedOrders.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        June 30, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Batch calss in order to process failed order
  ***********************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global without sharing class osf_batch_failedOrders implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {
    public String ORDER_QUERY;
    private final Integer INTERVAL_MINUTES = 5;
    private static final Integer SCOPE_SIZE = 100;
    List<ccrz__E_Order__c> lstOrdersToUpdate;
    
    /* 
    * @description  : class constructor
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @return       : 
    */
    public osf_batch_failedOrders() {
        lstOrdersToUpdate = new List<ccrz__E_Order__c>();
        osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
        ORDER_QUERY = 'SELECT Id, osf_number_of_attempts__c, osf_order_number__c, ccrz__Account__c, ccrz__Account__r.Name, ccrz__Account__r.osf_client_code__c, ccrz__Account__r.osf_cif_number__c, ccrz__Account__r.osf_payment_condition__c, ccrz__Contact__r.Name, ccrz__Contact__r.Email, ccrz__Contact__r.Phone, ccrz__ShipAmount__c, ccrz__Note__c, ccrz__ShipTo__r.ccrz__AddressFirstline__c, ccrz__ShipTo__r.ccrz__AddressSecondline__c, ccrz__ShipTo__r.ccrz__AddressThirdline__c, ccrz__ShipTo__r.ccrz__PostalCode__c, ccrz__ShipTo__r.ccrz__City__c, ccrz__BillTo__r.ccrz__AddressFirstline__c, ccrz__BillTo__r.ccrz__AddressSecondline__c, ccrz__BillTo__r.ccrz__AddressThirdline__c, ccrz__BillTo__r.ccrz__PostalCode__c, ccrz__BillTo__r.ccrz__City__c, ccrz__RequestDate__c, ccrz__TotalAmount__c, (SELECT ccrz__Product__r.ccrz__SKU__c, ccrz__ItemTotal__c, ccrz__PercentDiscount__c, ccrz__AbsoluteDiscount__c, ccrz__Quantity__c, ccrz__Price__c, ccrz__Product__r.osf_tax_rate__c, ccrz__Product__r.ccrz__ProductType__c, osf_negotiated_discount__c, ccrz__Coupon__r.ccrz__DiscountAmount__c, osf_negotiated_price__c, osf_negotiated_price_with_tax__c, osf_line_absolute_discount__c FROM ccrz__E_OrderItems__r), (SELECT ccrz__PaymentType__c FROM ccrz__TransactionPayments__r) FROM ccrz__E_Order__c WHERE osf_order_error__c = true AND (osf_number_of_attempts__c < ' + config.order_resending_attempts__c + ' OR osf_number_of_attempts__c = null)';
    }

    /* 
    * @description  : start method of the Database.Batchable interface
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @Param        : Database.BatchableContext BC
    * @return       : Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext ctx){
        try {
            return Database.getQueryLocator(ORDER_QUERY);
        } catch (Exception e) {
            ccrz.ccLog.log(Logginglevel.ERROR, 'osf:osf_batch_failedOrders:Error', e);
            return null;
        }
    }

    /* 
    * @description  : execute method of the Database.Batchable interface
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @Param        : Database.BatchableContext BC
    * @Param        : List<sObject> scope
    * @return       : 
    */
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        if(scope == NULL || scope.isEmpty() ) return;
        List<ccrz__E_Order__c> lstOrders = (List<ccrz__E_Order__c>)scope;
        try {
            resendFailedOrders(lstOrders); 
        } catch (Exception ex) {
           ccrz.ccLog.log(Logginglevel.ERROR, 'osf:osf_batch_failedOrders:Error', ex);
        } 
    }

    /* 
    * @description  : finish method of the Database.Batchable interface
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @Param        : Database.BatchableContext BC
    * @return       : 
    */
    global void finish(Database.BatchableContext BC){
        try {
            if (!lstOrdersToUpdate.isEmpty()) {
                update lstOrdersToUpdate;
                scheduleBatch(INTERVAL_MINUTES);
            }
        }catch(Exception ex){ 
            ccrz.ccLog.log(Logginglevel.ERROR, 'osf:osf_batch_failedOrders:Error', ex);
        }
    }

    /* 
    * @description  : schedule batch calss
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @Param        : Integer intervalMin
    * @return       : String jobID
    */
    private static String scheduleBatch(Integer intervalMin){
        Datetime nowT = DateTime.now();
        String jobId = System.scheduleBatch(new osf_batch_failedOrders(), osf_batch_failedOrders.class.getName()+'-'+nowT.getTime() , intervalMin, SCOPE_SIZE);
        return jobId;
    }

    /* 
    * @description  : method used for resending the failed orders
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @Param        : List<ccrz__E_Order__c> lstOrders
    * @return       : 
    */
    private void resendFailedOrders(List<ccrz__E_Order__c> lstOrders){  
        for (ccrz__E_Order__c order : lstOrders) {
            List<ccrz__E_OrderItem__c> lstOrderItems = order.ccrz__E_OrderItems__r;
            if( Limits.getCallouts() < Limits.getLimitCallouts()) {
                resultat.ResultatOperacioComanda resultat = osf_utilityERP.createOrder(order, lstOrderItems, order.ccrz__Account__r.osf_client_code__c, order.ccrz__Account__r.osf_payment_condition__c);
                if (resultat.actualitzacioOK) {
                    order.osf_processed__c = true;
                    order.osf_order_error__c = false;
                    order.osf_error__c = '';
                } else {
                    order.osf_error__c = resultat.error;
                    order.osf_order_error__c = true;
                }
                order.osf_number_of_attempts__c = order.osf_number_of_attempts__c == null ? 1 : order.osf_number_of_attempts__c + 1;
                lstOrdersToUpdate.add(order);
            }
        }
    }

    /* 
    * @description  : execute method of the Database.Schedulable interface
    * @author       : Alina Craciunel
    * @createdDate  : June 30, 2020
    * @Param        : SchedulableContext SC
    * @return       : 
    */
	global void execute(SchedulableContext SC) {
		Database.executeBatch(new osf_batch_failedOrders(), SCOPE_SIZE);
	}
}