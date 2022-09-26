trigger OSF_OpportunityProduct_Trigger on OpportunityLineItem (before insert) {
    if(Trigger.isInsert && Trigger.isBefore) {
        OSF_OpportunityProduct_Handler.processLineItems(trigger.new);
    }
}