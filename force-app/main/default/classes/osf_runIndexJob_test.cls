/**
 * @description       : test class for osf_runIndexJob.cls
 * @author            : Daniel Boca
 * @last modified on  : 09-30-2020
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-30-2020   Daniel Boca                          Initial Version
**/
@isTest
class osf_runIndexJob_test {
    @isTest
    static void test_scheduleProductIndexingMethod(){
        Test.startTest();
            osf_runIndexJob.SCH_NAME = 'test_osf_product_index_sch';
            String CRON_EXP = '0 0 0 14 2 ? 2023';
            String jobId = osf_runIndexJob.scheduleThisJob(CRON_EXP);
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

            System.assert(String.isNotEmpty(jobId));
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}