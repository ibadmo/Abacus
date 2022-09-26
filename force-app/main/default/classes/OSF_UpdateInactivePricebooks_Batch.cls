public class OSF_UpdateInactivePricebooks_Batch implements Database.Batchable<sObject>, Database.Stateful{
        
	public Database.QueryLocator start(Database.BatchableContext bc){
		return Database.getQueryLocator('SELECT Id, IsActive FROM PricebookEntry WHERE IsActive = false');
	}

	public void execute(Database.BatchableContext bc, List<PricebookEntry> scope){
        
		for (PricebookEntry priceBook : scope){
			priceBook.IsActive = true;
		}
		
		update scope;
	}

	public void finish(Database.BatchableContext bc){
	}
}