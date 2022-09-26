/**
 * File:        osf_ctrl_creditCardpayment.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 17, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Controller class for osf_paymentCCpage
  ************************************************************************
 * History:
 */

global with sharing class osf_ctrl_creditCardpayment {
    
    /* 
    * @description  : make the payment
    * @author       : Alina Craciunel
    * @createdDate  : Feb 17, 2020
    * @param        : ccrz.cc_RemoteActionContext ctx
    * @param        : serialized paymentDetails
    * @return       : ccrz.cc_RemoteActionResult
    */
    @RemoteAction
    global static ccrz.cc_RemoteActionResult makeCCPayment(ccrz.cc_RemoteActionContext ctx, String paymentDetails) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        try {
            PaymentModel paymentModel = (PaymentModel)JSON.deserialize(paymentDetails, PaymentModel.class);
            
            /*Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApiCart.CART_ENCIDLIST => new Set<String>{ctx.currentCartId},
                ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
                ccrz.ccApi.SIZING => new Map<String, Object>{
                    ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                        ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_L
                    }
                }
            };
            Map<String, Object> outputData = ccrz.ccAPICart.fetch(inputData);
            if (outputData.get(ccrz.ccAPICart.CART_OBJLIST) != null) {
                List<Map<String, Object>> outputCartList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPICart.CART_OBJLIST);
                paymentModel.amount = osf_utility.formatDecimal(((Decimal) outputCartList[0].get('totalAmount')) * 100);
                paymentModel.orderCurrency = (String) outputCartList[0].get('currencyISOCode');
            }*/
            osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(config.AddonPayment_Endpoint__c);
            request.setMethod(osf_constant_strings.ADDON_PAYMENT_POST);
            request.setHeader(osf_constant_strings.ADDON_PAYMENT_CONTENT_TYPE, osf_constant_strings.ADDON_PAYMENT_CONTENT_TYPE_VALUE);
            
            List<ccrz__E_Cart__c> lstCarts = new List<ccrz__E_Cart__c>([SELECT Id, ccrz__CurrencyISOCode__c, ccrz__TotalAmount__c 
                                                                        FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c =: ccrz.cc_CallContext.currCartId]);   
            paymentModel.amount = osf_utility.formatDecimal(lstCarts[0].ccrz__TotalAmount__c * 100);
            paymentModel.orderCurrency = lstCarts[0].ccrz__CurrencyISOCode__c;
            
            String body = osf_utility.getXmlRequest(config, paymentModel);
            request.setBody(body);
            HttpResponse response = http.send(request);
            String errorMsg = getErrorMsg(response);
            if (String.isNotBlank(errorMsg)) {
                result.data = errorMsg;
                result.success = false;
            } else {
                result.success = true;
            }
        } catch(Exception ex){
            result.success = false;
            result.messages.add(osf_Utility.createBeanMessage(ex));
            result.data = ex.getStackTraceString();
        } finally {
           ccrz.ccLog.close(result);
        }
        return result;
    }

    /* 
    * @description  : parse the response message and return the error
    * @author       : Alina Craciunel
    * @createdDate  : Feb 17, 2020
    * @param        : the HttpResponse
    * @return       : the error message as a string
    */
    private static String getErrorMsg(HttpResponse response) {
        String message = '';
        DOM.Document doc = response.getBodyDocument();
        for(Dom.XmlNode responseNode: doc.getRootElement().getChildElements()) {
            String nodeName = responseNode.getName();
            String nodeText = responseNode.getText();
            if (nodeName == osf_constant_strings.RESULT && nodeText == osf_constant_strings.SUCCESS_RESULT) {
                break;
            }
            if (nodeName == osf_constant_strings.MESSAGE) {
                message = nodeText;
            }
        }
        return message;
    }

    /* 
    * @description  : model class for payment info from UI
    * @author       : Alina Craciunel
    * @createdDate  : Feb 17, 2020
    */
    global with sharing class PaymentModel {
        public String orderCurrency {get; set;}
        public String amount {get; set;}
        public String orderNo {get; set;}
        public String cardNumber {get; set;}
        public String expDate {get; set;}
        public String cardType {get; set;}
        public String cvn {get; set;}
        public String name {get; set;}
        public PaymentModel() {}
    }
}