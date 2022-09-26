global class OSF_UpdateInactivePricebooks_Scheduled  implements Schedulable {
   global void execute(SchedulableContext SC) {
      OSF_UpdateInactivePricebooks_Batch priceBookBatch = new OSF_UpdateInactivePricebooks_Batch(); 
      database.executeBatch(priceBookBatch);
   }
}