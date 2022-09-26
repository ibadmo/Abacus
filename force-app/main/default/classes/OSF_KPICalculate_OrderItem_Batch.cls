/**
* File:        OSF_KPICalculate_OrderItem_Batch.cls
* Project:     Abacus
* Date:        July 22, 2021
* Created By:  Ali Ozdemir
* *************************************************************************
* Description:  Order Rollups on Account when an order is created, updated or deleted, Update last purchase date on Account, Update StorePurchase on Account
* *************************************************************************
* History:
* Date:                Modified By:             Description:
*/
public with sharing class OSF_KPICalculate_OrderItem_Batch implements Database.Batchable<sObject> {

    /**
    * @author Ali Ozdemir
    * @date  July 22, 2021
    * @name start
    * @description get query locator
    * @return Database.QueryLocator
    */  
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Interests_as_purchases__c FROM Account]);
    }
    
    /**
    * @author Ali Ozdemir
    * @date  July 22, 2021
    * @name execute
    * @description process data to prepare batches and prepare control set for accounts
    * @return void
    */ 
    public void execute(Database.BatchableContext BC, List<Account> scope){ 
        OSF_OrderProductTriggerHandler.updateInterestAsPurschaseOnAccount(scope);
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