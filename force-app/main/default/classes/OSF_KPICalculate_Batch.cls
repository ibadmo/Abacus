/**
* File:        OSF_KPICalculate_Batch.cls
* Project:     Abacus
* Date:        July 22, 2021
* Created By:  Ali Ozdemir
* *************************************************************************
* Description:  Order Rollups on Account when an order is created, updated or deleted, Update last purchase date on Account, Update StorePurchase on Account
* *************************************************************************
* History:
* Date:                Modified By:             Description:
*/
public with sharing class OSF_KPICalculate_Batch implements Database.Batchable<sObject>, Database.Stateful {
    // for custom cache mechanism
    public Set<Id> accIds = new Set<Id>();

    /**
    * @author Ali Ozdemir
    * @date  July 22, 2021
    * @name start
    * @description get query locator
    * @return Database.QueryLocator
    */  
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, AccountId, isOrderthisyear__c, TotalAmount, EffectiveDate, Store_Purchase__c, 
                                            Store_Delivery__c, Interest_As_Purchase__c, In_Store_Order__c, Status FROM Order]);
    }
    
    /**
    * @author Ali Ozdemir
    * @date  July 22, 2021
    * @name execute
    * @description process data to prepare batches and prepare control set for accounts
    * @return void
    */ 
    public void execute(Database.BatchableContext BC, List<Order> ordList){
        Set<Id> accountIds = new Set<Id>();
        Map<String, List<Order>> ordersMap = new Map<String, List<Order>>();
        for(Order o : ordList) {
            accountIds.add(o.AccountId);
            if(ordersMap.containsKey(o.AccountId)) {
                List<Order> tempList = new List<Order>();
                tempList = ordersMap.get(o.AccountId);
                tempList.add(o);
                ordersMap.put(o.AccountId, tempList);
            } else {
                List<Order> tempList = new List<Order>();
                tempList.add(o);
                ordersMap.put(o.AccountId, tempList);
            }
        }
        List<Account> accList = [SELECT Id, Nr_of_Orders__c, Total_Amount_Orders__c, Nr_of_Orders_this_year__c, Reference_Store_Cache__c, Interest_As_Purchase_Cache__c,
                                Store_Delivery_Cache__c, Total_sum_of_Orders_this_year__c, Last_purchase_date__c FROM Account WHERE Id IN :accountIds];
        if(!accList.isEmpty()) {
            OSF_OrderTriggerHandler.doRollUpsOnAccount(accList, ordersMap, accIds);
            accIds.addAll(accountIds);
        }
    }
    
    /**
    * @author Ali Ozdemir
    * @date  July 22, 2021
    * @name finish
    * @description 
    * @return void
    */ 
    public void finish(Database.BatchableContext BC) {
    }
}
