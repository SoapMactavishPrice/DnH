trigger LeadTrigger on Lead__c (before insert, before update){
    
    if (Trigger.isBefore) {
        LeadTriggerHandler.updateLeadAddresses(Trigger.new);
    }
}