trigger LeadTrigger on Lead__c (before insert, before update){
    
    if (Trigger.isBefore) {
        LeadTriggerHandler.updateLeadAddresses(Trigger.new);
    }
    
    if (Trigger.isInsert || Trigger.isUpdate) {
       LeadTriggerHandler.handleStatusDate(Trigger.new, Trigger.oldMap);
       LeadTriggerHandler.addCountryCodeToMobile(Trigger.new);
    }
}