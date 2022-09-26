/**
 * File:        osf_cc_hk_Order.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 25, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Extension for Order hook class
  ************************************************************************
 * History:
 */

global without sharing class osf_hk_Order extends ccrz.cc_hk_Order {
    /**********************************************************************************************
    * @Name         : place
    * @Description  : Place the order
    * @Created By   : Ozgun Eser
    * @Created Date : Feb 25, 2020
    * @param        : Map<String, Object> inputData; the input data
    * @Return       : inputData, Map<String, Object>
    *********************************************************************************************/
    global override Map<String, Object> place(Map<String, Object> inputData) {
        try{
            String currentStep = (String) inputData.get(ccrz.cc_hk_Order.PARAM_PLACE_STEP);
            if (ccrz.cc_hk_Order.STEP_END.equals(currentStep)) {
                ccrz__E_Cart__c cart = (ccrz__E_Cart__c) inputData.get(ccrz.cc_hk_Order.PARAM_CART);
                ccrz__E_Order__c order = (ccrz__E_Order__c) inputData.get(ccrz.cc_hk_Order.PARAM_ORDER);
                List<ccrz__E_OrderItem__c> orderItemList = (List<ccrz__E_OrderItem__c>) inputData.get(ccrz.cc_hk_Order.PARAM_ORDER_ITEMS);
                Boolean isSucchessfullyShared = osf_CartSharingHelper.shareOrderWithSupervisor(order, cart);
                Id jobId = System.enqueueJob(new osf_processOrders_quable(order, orderItemList));
                sendOrderConfirmationEmail(order.Id, Site.getBaseURL() + osf_constant_strings.MY_ORDERS_LINK);
            } else if (ccrz.cc_hk_Order.STEP_CREATE_ORDER_ITEMS_PRE.equals(currentStep)) {
                Set<String> cartItemIdSet = new Set<String> ();
                Map<String, ccrz__E_CartItem__c> productIdToCartItemMap = new Map<String, ccrz__E_CartItem__c> ();
                for(ccrz__E_CartItem__c cartItem : (List<ccrz__E_CartItem__c>) inputData.get(ccrz.cc_hk_Order.PARAM_CART_ITEMS)) {
                    cartItemIdSet.add(cartItem.Id);
                }

                for(ccrz__E_CartItem__c cartItem : [SELECT Id, osf_negotiated_discount__c, ccrz__AdjustmentAmount__c, ccrz__Product__c FROM ccrz__E_CartItem__c WHERE Id IN :cartItemIdSet]) {
                    productIdToCartItemMap.put(cartItem.ccrz__Product__c, cartItem);
                }

                for(ccrz__E_OrderItem__c orderItem : (List<ccrz__E_OrderItem__c>) inputData.get(ccrz.cc_hk_Order.PARAM_ORDER_ITEMS)) {
                    if(productIdToCartItemMap.containsKey(orderItem.ccrz__Product__c)) {
                        ccrz__E_CartItem__c cartItem = productIdToCartItemMap.get(orderItem.ccrz__Product__c);
                        orderItem.ccrz__AdjustmentAmount__c = cartItem.ccrz__AdjustmentAmount__c;
                        orderItem.osf_negotiated_discount__c = cartItem.osf_negotiated_discount__c;
                    }
                }
            }
        } catch(Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:osf_hk_Order:place:Error', e);
        }
        return inputData;
    }

    @future
    private static void sendOrderConfirmationEmail(Id orderId, String myOrdersLink) {
        List<String> emailList = new List<String> ();
        for(ccrz__E_Order__Share orderShare : [SELECT UserOrGroup.Email FROM ccrz__E_Order__Share WHERE ParentId = :orderId AND UserOrGroup.Email != NULL]) {
            emailList.add(orderShare.UserOrGroup.Email);
        }

        ccrz__E_Order__c order = [
            SELECT
                ccrz__Account__r.osf_payment_condition__c,
                ccrz__OrderNumber__c,
                ccrz__OriginatedCart__r.Name,
                ccrz__PaymentMethod__c,
                ccrz__ShipAmount__c,
                ccrz__ShipTo__r.ccrz__AddressFirstline__c,
                ccrz__ShipTo__r.ccrz__AddressSecondline__c,
                ccrz__ShipTo__r.ccrz__AddressThirdline__c,
                ccrz__ShipTo__r.ccrz__City__c,
                ccrz__ShipTo__r.ccrz__FirstName__c,
                ccrz__ShipTo__r.ccrz__LastName__c,
                ccrz__SubtotalAmount__c,
                ccrz__TaxAmount__c,
                ccrz__TotalAmount__c,
                CreatedBy.LocaleSidKey,
                CreatedBy.Name,
                Id,
                Name,
                osf_order_number__c, (
                    SELECT
                        ccrz__ExtSKU__c,
                        ccrz__Price__c,
                        ccrz__Product_Name__c,
                        ccrz__Quantity__c,
                        Id
                    FROM
                        ccrz__E_OrderItems__r
                ), (
                    SELECT
                        ccrz__PaymentType__c,
                        Id
                    FROM
                        ccrz__TransactionPayments__r
                )
            FROM
                ccrz__E_Order__c
            WHERE
                Id = :orderId
        ];


        String emailTemplateName = order.CreatedBy.LocaleSidKey == osf_constant_strings.SPANISH_LOCALE ? osf_constant_strings.ORDER_CONFIRMATION_EMAIL_TEMPLATE : osf_constant_strings.ORDER_CONFIRMATION_EMAIL_TEMPLATE_CATALAN;
        List<EmailTemplate> emailTemplateList = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Name = :emailTemplateName LIMIT 1];
        if(emailTemplateList.isEmpty()) {
            return;
        }
        if(emailList.isEmpty()) {
            if(!String.isBlank(order.ccrz__Contact__r.Email)) {
                emailList.add(order.ccrz__Contact__r.Email);
            }
        }
        EmailTemplate emailTemplate = emailTemplateList[0];
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace(osf_constant_strings.ORDER_CONFIRMATION_EMAIL_CREATED_BY, order.CreatedBy.Name);

        List<ccrz__E_TransactionPayment__c> transactionItems = order.ccrz__TransactionPayments__r;

        if(transactionItems.size() > 0) {

            ccrz__E_TransactionPayment__c firstTransactionPayment = transactionItems.get(0);

            if (firstTransactionPayment.ccrz__PaymentType__c != null) {
                htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__PaymentMethod__c}', firstTransactionPayment.ccrz__PaymentType__c);
            }

        }

        if(order.ccrz__ShipTo__r.ccrz__FirstName__c != null) {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__FirstName__c}', order.ccrz__ShipTo__r.ccrz__FirstName__c);
        }
        else {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__FirstName__c}', '');
        }

        if(order.ccrz__ShipTo__r.ccrz__LastName__c != null) {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__LastName__c}', order.ccrz__ShipTo__r.ccrz__LastName__c);
        }
        else {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__LastName__c}', '');
        }

        if(order.ccrz__ShipTo__r.ccrz__AddressFirstline__c != null) {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__AddressFirstline__c}', order.ccrz__ShipTo__r.ccrz__AddressFirstline__c + '<br>');
        }
        else {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__AddressFirstline__c}', '');
        }

        if(order.ccrz__ShipTo__r.ccrz__AddressSecondline__c != null) {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__AddressSecondline__c}', order.ccrz__ShipTo__r.ccrz__AddressSecondline__c + '<br>');
        }
        else {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__AddressSecondline__c}', '');
        }

        if(order.ccrz__ShipTo__r.ccrz__AddressThirdline__c != null) {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__AddressThirdline__c}', order.ccrz__ShipTo__r.ccrz__AddressThirdline__c + '<br>');
        }
        else {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__AddressThirdline__c}', '');
        }

        if(order.ccrz__ShipTo__r.ccrz__City__c != null) {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__City__c}', order.ccrz__ShipTo__r.ccrz__City__c);
        }
        else {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__ShipTo__c.ccrz__City__c}', '');
        }

        if(order.ccrz__SubtotalAmount__c != null) {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__SubtotalAmount__c}', String.valueOf(order.ccrz__SubtotalAmount__c));
        }

        if(order.ccrz__TotalAmount__c != null) {
            htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__TotalAmount__c}', String.valueOf(order.ccrz__TotalAmount__c));
        }
        htmlBody = htmlBody.replace(osf_constant_strings.ORDER_CONFIRMATION_EMAIL_CART_NAME, order.ccrz__OriginatedCart__r.Name);
        htmlBody = htmlBody.replace('{!ccrz__E_Order__c.osf_order_number__c}', order.osf_order_number__c);
        htmlBody = htmlBody.replace(osf_constant_strings.ORDER_CONFIRMATION_EMAIL_MY_ORDERS_LINK, myOrdersLink);

        String orderItems = '';

        List<ccrz__E_OrderItem__c> items = order.ccrz__E_OrderItems__r;

        for (ccrz__E_OrderItem__c item : items) {

            List<ccrz__E_Product__c> products = [SELECT Id, ccrz__SKU__c FROM ccrz__E_Product__c  WHERE Name = :item.ccrz__Product_Name__c];

            orderItems += '<tr width="100%" style="width: 100%">';
            orderItems += '<td style="width: 150px;" align="left" width="150" valign="top">';
            orderItems += '<span style="font-weight:bold;font-family:Helvetica,Arial,sans-serif;font-size:14px;color:#000000;line-height:1.8;">';
            if(products.size() > 0) {

                ccrz__E_Product__c product = products.get(0);

                if(product.ccrz__SKU__c != null) {
                    orderItems += product.ccrz__SKU__c;
                }
            }
            orderItems += '</span>';
            orderItems += '</td>';
            orderItems += '<td style="width: 350px;" align="left" width="350" valign="top">';
            orderItems += '<span style="font-weight:bold;font-family:Helvetica,Arial,sans-serif;font-size:14px;color:#000000;line-height:1.8;">';
            if(item.ccrz__Product_Name__c != null) {
                orderItems += item.ccrz__Product_Name__c;
            }
            orderItems += '</span>';
            orderItems += '</td>';
            orderItems += '<td style="width: 100px;" align="left" width="100" valign="top">';
            orderItems += '<span style="font-weight:bold;font-family:Helvetica,Arial,sans-serif;font-size:14px;color:#000000;line-height:1.8;">';
            if(item.ccrz__Quantity__c != null) {
                orderItems += String.valueOf(item.ccrz__Quantity__c);
            }
            orderItems += '</span>';
            orderItems += '</td>';
            orderItems += '</tr>';
        }

        htmlBody = htmlBody.replace('{!ccrz__E_Order__c.ccrz__items}', orderItems);

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName('Abacus Material Escolar');
        mail.setCharset(osf_constant_strings.CHARSET_UTF_8);
        mail.setToAddresses(emailList);
        mail.setSubject(emailTemplate.Subject.replace(osf_constant_strings.ORDER_CONFIRMATION_EMAIL_ORDER_NAME, order.osf_order_number__c));
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
}