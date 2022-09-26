public class OSF_UpdateAccountKPIs_Batch implements Database.Batchable<sObject>, Database.Stateful{
	// instance member to retain state across transactions
	public Integer recordsProcessed = 0;
    
	public Database.QueryLocator start(Database.BatchableContext bc){
		return Database.getQueryLocator('SELECT Id, Nr_of_Orders_this_year__c, Total_sum_of_Orders_this_year__c FROM Account');
	}

	public void execute(Database.BatchableContext bc, List<Account> scope){
        Integer currentYear = System.Today().year();
		List<Account> accountsToBeUpdated = new List<Account>();

		Set<Id> accountIds = new Set<Id>();
		for (Account account : scope){
			accountIds.add(account.Id);
		}

		List<AggregateResult> orderCalculation = [SELECT AccountId, count(Id)orderCount, SUM(TotalAmount)orderTotalAmount
		                                          FROM Order
		                                          WHERE isOrderthisyear__c = 1 AND AccountId IN :accountIds
		                                          GROUP BY AccountId];


		for (AggregateResult result : orderCalculation){

			ID accountID = (Id)result.get('AccountId');
			Account tempAccount = new Account();
			tempAccount.Id = accountID;
			tempAccount.Nr_of_Orders_this_year__c = (decimal)result.get('orderCount');
			tempAccount.Total_sum_of_Orders_this_year__c = (decimal)result.get('orderTotalAmount');

			accountsToBeUpdated.add(tempAccount);
		}

		update accountsToBeUpdated;
	}

	public void finish(Database.BatchableContext bc){
	}
}