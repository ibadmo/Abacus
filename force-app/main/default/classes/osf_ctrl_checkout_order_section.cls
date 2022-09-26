/**
 * File:        osf_ctrl_checkout_order_section.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Feb 21, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Test class for osf_hk_TaxCalculation
  ************************************************************************
 * History:
 */

global with sharing class osf_ctrl_checkout_order_section {

    /**********************************************************************************************
    * @Name         : getPrices
    * @Description  : Getting Price fields for Order Summary Section in Checkout
    * @Created By   : Ozgun Eser
    * @Created Date : Feb 21, 2020
    * @param        : ccrz.cc_RemoteActionContext context
    * @return       : ccrz.cc_remoteActionResult result, containing returned pricing data from CC Cart
    *********************************************************************************************/    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPrices(ccrz.cc_RemoteActionContext context) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(context);
        Map<String, Object> data = new Map<String, Object> ();
        result.data = data;
        try {
            ccrz__E_Cart__c ccCart = [SELECT ccrz__SubtotalAmount__c, ccrz__TaxSubTotalAmount__c, ccrz__TaxAmount__c, ccrz__ShipAmount__c, ccrz__TotalAmount__c,
            (SELECT osf_vat_rate_total__c FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :context.currentCartId];
            data.put(osf_constant_strings.SUBTOTAL_AMOUNT, ccCart.ccrz__SubtotalAmount__c);
            data.put(osf_constant_strings.TAX_SUBTOTAL_AMOUNT, ccCart.ccrz__TaxSubTotalAmount__c);
            Decimal totalTaxAmount = 0;
            for (ccrz__E_CartItem__c cartItem : ccCart.ccrz__E_CartItems__r) {
                totalTaxAmount += cartItem.osf_vat_rate_total__c;
            }
            data.put(osf_constant_strings.TAX, totalTaxAmount);
            data.put(osf_constant_strings.SHIPPING_CHARGE, ccCart.ccrz__ShipAmount__c == null ? 0.00 : ccCart.ccrz__ShipAmount__c);
            data.put(osf_constant_strings.TOTAL_AMOUNT, ccCart.ccrz__TotalAmount__c);
            result.success = true;
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:ctrl:checkout_order_section:getShippingAmount:Error', e);
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }
}