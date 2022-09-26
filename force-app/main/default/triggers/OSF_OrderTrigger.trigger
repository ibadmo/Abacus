/**
* File:        OSF_OrderTrigger.Trigger
* Project:     Abacus
* Date:        March 30, 2021
* Created By:  Fahad Farrukh
* *************************************************************************
* Description:  Order Rollups on Account when an order is created, updated or deleted, Update last purchase date on Account, Update StorePurchase on Account, Truncates fields more than 40 chars long
* *************************************************************************
* History:
* Date:                Modified By:             Description:
*/
trigger OSF_OrderTrigger on Order (before insert,before update, after insert, after update, after delete) {
    if(Trigger.isBefore) {        
        final Integer truncateLength = 40;
        Map<String, String> truncationMap = new Map<String, String>();
        List<String> fieldsToTruncate = new List<String> {'Billing_Address_Text__c', 'Shipping_Address_Text__c'};             
        OSF_TruncateUtilityClass.truncateOrderFields(truncationMap, Trigger.New, truncateLength, fieldsToTruncate);
    }   
}