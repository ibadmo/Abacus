/**
 * File:        osf_ctrl_cartdetail.cls
 * Project:     Abacus B2B (SP-ABCS-IFB-Abacus B2B Implementation (CCRZ))
 * Date:        Apr 8, 2020
 * Created By:  Cansu Asci
  ************************************************************************
 * Description: Controller class for osf_cartdetail component.
  ************************************************************************
 * History:
 * Date:                Modified By:            Description:
 */
global with sharing class osf_ctrl_cartdetail {

    /**********************************************************************************************
    * @Name         : stockCheck
    * @Description  : This method does stock check for cart item product
    * @Created By   : Cansu Asci
    * @Created Date : Apr 8, 2020
    * @Param        : ccrz.cc_RemoteActionContext ctx
    * @Return       : ccrz.cc_RemoteActionResult
     
    *********************************************************************************************/
    @RemoteAction
    global static ccrz.cc_RemoteActionResult stockCheck(ccrz.cc_RemoteActionContext ctx, String productData){
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        List<Map<String, String>> data = new List<Map<String, String>>();
        result.data = data;
        try {
            List<Object> dataList = (List<Object>)JSON.deserializeUntyped(productData);
            Map<String, Integer> productSKUQuantityMap = new Map<String, Integer>();
            if(dataList.size() > 0){
                for (Object onedata : dataList) {
                    Map<String, Object> item = (Map<String, Object>)oneData;
                    productSKUQuantityMap.put(String.valueOf(item.get('SKU')), Integer.valueOf(item.get('quantity'))); 
                }
                data = osf_utility.fetchDeliveryTime(productSKUQuantityMap);
            }
            //check if sku returned 
            //retrieve provider time data if not returned
            Set<String> notReturnedSkuList = new Set<String>();
            Set<String> allReturnedSkuList = new Set<String>();
            
            for(Map<String, String> mapdata : data){
                   allReturnedSkuList.add(mapdata.get(osf_constant_strings.SKU)); 
            }
            
            for(String inputsku : productSKUQuantityMap.keySet()){
                if(!allReturnedSkuList.contains(inputsku)){
                    notReturnedSkuList.add(inputsku);
                }
            }
            osf_Abacus_B2B_config__c config = osf_Abacus_B2B_config__c.getOrgDefaults();
            List<ccrz__E_Product__c> prodList = [SELECT ccrz__SKU__c, osf_provider_delivery_time__c FROM ccrz__E_Product__c WHERE ccrz__SKU__c IN: notReturnedSkuList];
            if(prodList.size()>0){
                for(ccrz__E_Product__c prod : prodList){
                    Map<String, String> dataitem = new Map<String, String>();
                    if(prod.osf_provider_delivery_time__c == null){
                        prod.osf_provider_delivery_time__c = config.osf_providertime_plus__c;
                    }else{
                        prod.osf_provider_delivery_time__c = prod.osf_provider_delivery_time__c + config.osf_providertime_plus__c;
                    }
                    dataitem.put(osf_constant_strings.SKU, prod.ccrz__SKU__c);
                    String timestring = String.valueOf(prod.osf_provider_delivery_time__c) + osf_constant_strings.EMPTY_STRING + osf_constant_strings.DELIVERY_TIME_IN_DAYS;
                    dataitem.put(osf_constant_strings.DELIVERY_TIME,timestring);
                    data.add(dataitem);
                }
            }
            result.data = data;
            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.messages.add(osf_utility.createBeanMessage(e));
        } finally {
            ccrz.ccLog.close(result);
        }
        return result;
    }

}