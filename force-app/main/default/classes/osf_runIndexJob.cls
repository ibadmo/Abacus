/**
 * @description       : run Reindex Job every day
 * @author            : Daniel Boca
 * @last modified on  : 09-30-2020
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-30-2020   Daniel Boca                          Initial Version
**/
public inherited sharing class osf_runIndexJob implements Schedulable{
    
    public static String SCH_NAME = 'osf_product_index_sch';
    
    public osf_runIndexJob() { }

    public void execute(SchedulableContext sctx){
        // Refresh product indices for only outdated products
        refreshProductIndexing(TRUE);
    }

    public void refreshProductIndexing(Boolean CLEAN_ONLY){
          ccrz.ccProductIndexBuilder.build(
              new Map<String,Object>{
                ccrz.ccAPIProductIndex.LOCALES => new Set<String>{'ca_ES', 'es_ES'},
                ccrz.ccAPIProductIndex.CLEAN_ONLY => CLEAN_ONLY
              }
          );
    }

    public static String scheduleThisJob(String CRON_EXP){
        String jobId = System.schedule(SCH_NAME, CRON_EXP, new osf_runIndexJob());
        return jobId;
    }
}