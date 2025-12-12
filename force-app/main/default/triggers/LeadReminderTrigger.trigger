trigger LeadReminderTrigger on Lead__c (before insert) {
    LeadReminderHandler.initializeFlags(Trigger.new);
}