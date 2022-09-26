/**
 * File:        osf_utilityERP.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Apr 09, 2020
 * Created By:  Alina Craciunel
  ************************************************************************
 * Description: Contains ERP Utility methods for whole the project.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

public inherited sharing class osf_utilityERP { 

    /**********************************************************************************************
    * @Name         : checkCustomerExistsInERP
    * @Description  : check if a customer exists or not in the ERP
    * @Created By   : Alina Craciunel
    * @Created Date : Apr 14, 2020
    * @param        : String vat(nif)
    * @param        : String clientId(codiClient)
    * @Return       : the result as absisIntranetAbacus.resultatConsultarClientsB2BSalesforce
    *********************************************************************************************/
    public static absisIntranetAbacus.resultatConsultarClientsB2BSalesforce checkCustomerExistsInERP(String vat, String clientId) {
        absisIntranetAbacus.ClientsWebWSPort clientWSPort = new absisIntranetAbacus.ClientsWebWSPort();
        return clientWSPort.consultarClientsB2BSalesforce(clientId, osf_constant_strings.EMPTY_STRING, vat, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING); 
    }

    /**********************************************************************************************
    * @Name         : actualitzarClientInERP
    * @Description  : create client in the ERP
    * @Created By   : Alina Craciunel
    * @Created Date : Apr 14, 2020
    * @param        : String accountName
    * @Return       : the result as absisIntranetAbacus.resultatActualitzarClient
    *********************************************************************************************/
    public static absisIntranetAbacus.resultatClientWeb actualitzarClientInERP(Contact contact, String nif, String accountId) {
        absisIntranetAbacus.ClientsWebWSPort clientWSPort = new absisIntranetAbacus.ClientsWebWSPort();
        absisIntranetAbacus.clientWeb client = new absisIntranetAbacus.clientWeb();
        absisIntranetAbacus.direccions_element direccions_element = new absisIntranetAbacus.direccions_element();
        direccions_element.direccioClient = getAccountAddresses(accountId);
        client.nom = contact.Name;
        client.emailUsuari = contact.Email;
        client.direccions = direccions_element;
        client.nif = nif;
        return clientWSPort.actualitzarClient(null, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, osf_constant_strings.EMPTY_STRING, nif, osf_constant_strings.EMPTY_STRING, osf_constant_strings.CLIENT_WS_CREATE_OPERACION, client);
    }

     /**********************************************************************************************
    * @Name         : createOrder
    * @Description  : send the order to the ERP
    * @Created By   : Alina Craciunel
    * @Created Date : Mar 02, 2020
    * @param        : ccrz__E_Order__c order
    * @param        : List<ccrz__E_OrderItem__c> lstOrderItems
    * @Return       : the result as resultat.ResultatOperacioComanda
    *********************************************************************************************/
    public static resultat.ResultatOperacioComanda createOrder(ccrz__E_Order__c order, List<ccrz__E_OrderItem__c> lstOrderItems, String clientCode, String paymentCondition) {
        osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
        String orderNumber = order.osf_order_number__c; 
        String dataServei;
        if (order.ccrz__RequestDate__c != null) {
            String month = order.ccrz__RequestDate__c.month() < 10 ? '0' + order.ccrz__RequestDate__c.month() : String.valueOf(order.ccrz__RequestDate__c.month());
            String day = order.ccrz__RequestDate__c.day() < 10 ? '0' + order.ccrz__RequestDate__c.day() : String.valueOf(order.ccrz__RequestDate__c.day());
            dataServei = String.valueOf(order.ccrz__RequestDate__c.year()) + month + day;
        }
        String orderType = config.osf_order_type__c;
        String clientName =  order.ccrz__Account__r.Name;
        String clientEmail = order.ccrz__Contact__r.Email; 
        String clientPhone = order.ccrz__Contact__r.Phone; 
        String sku = osf_constant_strings.EMPTY_STRING;
        String shippingFirstLine = order.ccrz__ShipTo__r.ccrz__AddressFirstline__c == null ? '' : order.ccrz__ShipTo__r.ccrz__AddressFirstline__c;
        String shippingSecondLine = order.ccrz__ShipTo__r.ccrz__AddressSecondline__c == null ? '' : ',' + order.ccrz__ShipTo__r.ccrz__AddressSecondline__c;
        String shippingThirdLine = order.ccrz__ShipTo__r.ccrz__AddressThirdline__c == null ? '' : ',' + order.ccrz__ShipTo__r.ccrz__AddressThirdline__c;
        String shippingAddress = shippingFirstLine +  shippingSecondLine + shippingThirdLine; 
        String shippingPostalCode = order.ccrz__ShipTo__r.ccrz__PostalCode__c;
        String shippingCity = order.ccrz__ShipTo__r.ccrz__City__c; 
        String billingFirstLine = order.ccrz__BillTo__r.ccrz__AddressFirstline__c == null ? '' : order.ccrz__BillTo__r.ccrz__AddressFirstline__c;
        String billingSecondLine = order.ccrz__BillTo__r.ccrz__AddressSecondline__c == null ? '' : ',' + order.ccrz__BillTo__r.ccrz__AddressSecondline__c;
        String billingThirdLine = order.ccrz__BillTo__r.ccrz__AddressThirdline__c == null ? '' : ',' + order.ccrz__BillTo__r.ccrz__AddressThirdline__c;
        String billingAddress = billingFirstLine  + billingSecondLine + billingThirdLine;
        String billingPostalCode = order.ccrz__BillTo__r.ccrz__PostalCode__c; 
        String billingCity = order.ccrz__BillTo__r.ccrz__City__c; 
        String orderComments = order.ccrz__Note__c;
        absisOrders.ComandesWSPort comandesWSPort = new absisOrders.ComandesWSPort();
        linies.LiniaComandaWebB2B[] orderLines = getOrderLines(order, lstOrderItems, config);
        if (!Test.isRunningTest()) {
            return comandesWSPort.crearComandaWebB2BSalesforce(orderNumber, dataServei, orderType, clientCode, clientName, clientEmail, clientPhone, sku, shippingAddress,  shippingPostalCode, shippingCity, billingAddress, billingPostalCode, billingCity, orderComments, orderLines, paymentCondition);
        }
        resultat.ResultatOperacioComanda resultat = new resultat.ResultatOperacioComanda();
        resultat.actualitzacioOK = true;
        return resultat;
    }

    /**********************************************************************************************
    * @Name         : getOrderLines
    * @Description  : create order lines for the request
    * @Created By   : Alina Craciunel
    * @Created Date : Mar 02, 2020
    * @param        : ccrz__E_Order__c order
    * @param        : List<ccrz__E_OrderItem__c> lstOrderItems
    * @param        : osf_Abacus_B2B_config__c config
    * @Return       : array of linies.LiniaComandaWeb
    *********************************************************************************************/
    private static linies.LiniaComandaWebB2B[] getOrderLines(ccrz__E_Order__c order, List<ccrz__E_OrderItem__c> lstOrderItems, osf_Abacus_B2B_config__c config) {
        linies.LiniaComandaWebB2B[] lstLines = new linies.LiniaComandaWebB2B[]{};
        linies.LiniaComandaWebB2B line;
        Decimal orderAbsoluteDiscount = 0;// absolute discount of the entire order (coupon absolute)
        Decimal totalAmount = 0;
        Decimal orderPercentDiscount = 0; //used for calculate the percent discount based on order absolute discount
        for (ccrz__E_OrderItem__c orderItem : lstOrderItems) {
            if (orderItem.ccrz__Product__r.ccrz__ProductType__c == osf_constant_strings.PRODUCT_TYPE_COUPON) {
                orderAbsoluteDiscount += -orderItem.ccrz__Price__c  * orderItem.ccrz__Quantity__c;
            } else {
                totalAmount += orderItem.osf_negotiated_price_with_tax__c * orderItem.ccrz__Quantity__c;
            }
        }
        if (orderAbsoluteDiscount > 0) {
            orderPercentDiscount = 100 * orderAbsoluteDiscount/totalAmount;
        } 
        for (ccrz__E_OrderItem__c orderItem : lstOrderItems) {
            if (orderItem.ccrz__Product__r.ccrz__ProductType__c != osf_constant_strings.PRODUCT_TYPE_COUPON) {
                line = new linies.LiniaComandaWebB2B();
                line.codiArticle = orderItem.ccrz__Product__r.ccrz__SKU__c;
                line.unitats = orderItem.ccrz__Quantity__c.intValue();
                Decimal lineAbsoluteDiscount = 0;
                Decimal linePercentDiscount = 0;
                if (orderPercentDiscount > 0) {
                    lineAbsoluteDiscount = orderPercentDiscount/100 * orderItem.osf_negotiated_price_with_tax__c * orderItem.ccrz__Quantity__c;
                } else if (orderItem.ccrz__PercentDiscount__c > 0) {
                    lineAbsoluteDiscount = orderItem.osf_line_absolute_discount__c;
                    linePercentDiscount = orderItem.ccrz__Coupon__r.ccrz__DiscountAmount__c;
                }
                line.descompteValorAbsolut = String.valueOf(lineAbsoluteDiscount.setScale(2, RoundingMode.HALF_EVEN));
                line.descomptePercentual = String.valueOf(linePercentDiscount.setScale(2, RoundingMode.HALF_EVEN));
                line.preu = orderItem.osf_negotiated_price_with_tax__c.setScale(2, RoundingMode.HALF_EVEN);
                lstLines.add(line);
            }
        } 
        if (order.ccrz__ShipAmount__c != null && order.ccrz__ShipAmount__c > 0) {
            linies.LiniaComandaWebB2B lineShipping = new linies.LiniaComandaWebB2B();
            lineShipping.codiArticle = config.osf_shipping_line_sku__c;
            lineShipping.preu = order.ccrz__ShipAmount__c;
            lineShipping.unitats = 1;
            lstLines.add(lineShipping);
        }
        return lstLines;
    }

    /**********************************************************************************************
    * @Name         : getAccountAddresses
    * @Description  : get cc account address books for an account
    * @Created By   : Alina Craciunel
    * @Created Date : Apr 21, 2020
    * @param        : accountId
    * @Return       : the result as absisIntranetAbacus.direccioClientWeb[]
    *********************************************************************************************/
    public static absisIntranetAbacus.direccioClientWeb[] getAccountAddresses(String accountId) {
        absisIntranetAbacus.direccioClientWeb[] direccioClientWebArray = new absisIntranetAbacus.direccioClientWeb[]{};
        Map<String,Object> inputData = (new Map<String,Object>{
            ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION,
            ccrz.ccAPIAddressBook.ACCOUNTID => accountId
        });
        Map<String, Object> outputData = ccrz.ccAPIAddressBook.fetch(inputData);
        if (outputData.get(ccrz.ccAPIAddressBook.ADDRESSBOOKS) != null) {
            List<Map<String, Object>> addressBookList = (List<Map<String, Object>>)outputData.get(osf_constant_strings.ADDRESS_LIST);
            for (Map<String, Object> addressBook : addressBookList) {
                absisIntranetAbacus.direccioClientWeb direccioClientWeb = new absisIntranetAbacus.direccioClientWeb(); 
                direccioClientWeb.direccio = (String)addressBook.get(osf_constant_strings.ADDRESS_FIRST_LINE);
                direccioClientWeb.restaDireccio = (String)addressBook.get(osf_constant_strings.ADDRESS_SECOND_LINE) + ', ' + (String)addressBook.get(osf_constant_strings.ADDRESS_THIRD_LINE);
                direccioClientWeb.codiPostal = (String)addressBook.get(osf_constant_strings.POSTAL_CODE);
                direccioClientWeb.poblacio = (String)addressBook.get(osf_constant_strings.CITY);
                direccioClientWebArray.add(direccioClientWeb);
            }
        }
        return direccioClientWebArray;
    }
}