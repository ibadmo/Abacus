/**
 * File:        OSF_ProductTrigger.cls
 * Project:     ABACUS
 * Date:        May 3, 2021
 * Created By:  Ali Ozdemir
 * *************************************************************************
 * Description:  Product trigger
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 */
trigger OSF_ProductTrigger on Product2 (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            OSF_ProductTrigger_Handler.createStandardPricebookEntries(trigger.new);
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            OSF_ProductTrigger_Handler.createStandardPricebookEntries(trigger.new);
        }
    }
}