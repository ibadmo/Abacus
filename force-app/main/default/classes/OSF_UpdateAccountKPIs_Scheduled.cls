global class OSF_UpdateAccountKPIs_Scheduled implements Schedulable {
   global void execute(SchedulableContext SC) {
      OSF_UpdateAccountKPIs_Batch kpiBatch = new OSF_UpdateAccountKPIs_Batch(); 
      database.executeBatch(kpiBatch);
   }
}