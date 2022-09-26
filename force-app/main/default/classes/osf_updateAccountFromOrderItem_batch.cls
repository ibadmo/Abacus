public class osf_updateAccountFromOrderItem_batch implements Database.Batchable<sObject> {
    public final String Query;
    public final Boolean interestAsPurchase;
    
    public final Set<id> accountIds;
    public osf_updateAccountFromOrderItem_batch(String Query, Set<Id> accountIds, Boolean interestAsPurchase){
        
        this.Query=Query; this.interestAsPurchase = interestAsPurchase; this.accountIds = accountIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> ordList){
        if(interestAsPurchase) {
            OSF_OrderProductTriggerHandler.updateInterestAsPurschaseOnAccount(ordList);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
    }
}