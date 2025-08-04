trigger ShareAccountOnCustomerSalesPersonMapping on Customer_Sales_Person_Mapping__c (after insert, after update) {
    
    if (ShareAccountTriggerHelper.hasEnqueued) {
        return; // Prevents multiple Queueables in same transaction
    }
    
    List<Customer_Sales_Person_Mapping__c> relevantMappings = new List<Customer_Sales_Person_Mapping__c>();
    
    for (Customer_Sales_Person_Mapping__c mapping : Trigger.new) {
        Boolean shouldProcess = false;
        
        if (Trigger.isInsert) {
            shouldProcess = true;
        } else if (Trigger.isUpdate) {
            Customer_Sales_Person_Mapping__c oldMapping = Trigger.oldMap.get(mapping.Id);
            if (
                mapping.Sales_Person_Code__c != oldMapping.Sales_Person_Code__c ||
                mapping.Reporting_person_ID__c != oldMapping.Reporting_person_ID__c ||
                mapping.Zonal_manager_ID__c != oldMapping.Zonal_manager_ID__c
            ) {
                shouldProcess = true;
            }
        }
        
        if (shouldProcess) {
            relevantMappings.add(mapping);
        }
    }
    
    if (!relevantMappings.isEmpty()) {
        ShareAccountTriggerHelper.hasEnqueued = true; // Mark as enqueued
        System.enqueueJob(new ShareAccountsQueueable(relevantMappings));
    }
}