/**
 * File:        osf_logicCouponRemove.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        jan 22, 2020
 * Created By:  Ozgun Eser
  ************************************************************************
 * Description: Putting a flag to remove coupon to prevent it to be applied again automatically.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */

global without sharing class osf_logicCouponRemove extends ccrz.ccLogicCouponRemove {
    
    /* 
    * @description  : Flagging the coupon so that it will not be applied automatically 
    * @author       : Ozgun Eser
    * @createdDate  : Jan 22, 2020
    * @param        : Map<String, Object> inputData
    * @return       : Map<String, Object> outputData
    */
    global override Map<String, Object> remove(Map<String, Object> inputData) {
        Map<String, Object> outputData = super.remove(inputData);
        try {
            String cartId = (String) outputData.get(ccrz.ccAPICart.CART_ID);
            ccrz__E_Cart__c cart = [SELECT Id, osf_coupon_removed_manually__c FROM ccrz__E_Cart__c WHERE Id = :cartId];
            if(!cart.osf_coupon_removed_manually__c) {
                cart.osf_coupon_removed_manually__c = true;
                update cart;
            }
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'osf:logicCouponRemove:remove:Error', e);
        }
        return outputData;
    }
}