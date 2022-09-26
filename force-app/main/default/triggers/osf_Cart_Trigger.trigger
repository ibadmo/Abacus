trigger osf_Cart_Trigger on ccrz__E_Cart__c (after update, after delete) {
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            osf_Cart_TriggerHandler.doAfterUpdate(Trigger.newMap, Trigger.oldMap);
        } else if(Trigger.isDelete) {
            osf_Cart_TriggerHandler.doAfterDelete(Trigger.old);
        }
    }
}