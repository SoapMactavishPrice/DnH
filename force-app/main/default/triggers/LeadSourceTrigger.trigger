trigger LeadSourceTrigger on Lead_Source__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        LeadSourceHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}