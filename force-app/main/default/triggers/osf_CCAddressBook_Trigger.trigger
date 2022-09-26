trigger osf_CCAddressBook_Trigger on ccrz__E_AccountAddressBook__c (before insert, after insert, before update, after update) {
    if (Trigger.IsAfter && osf_CCAddressBook_TriggerHandler.isFirstTime) {
        osf_CCAddressBook_TriggerHandler.isFirstTime = false;
        if (Trigger.IsInsert || Trigger.IsUpdate) {
            osf_CCAddressBook_TriggerHandler.afterInsertUpdate(Trigger.newMap);
        }
    }
}