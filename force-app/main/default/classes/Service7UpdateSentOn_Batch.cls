global class Service7UpdateSentOn_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts, Schedulable {

    global database.QueryLocator start(database.BatchableContext bc) {
        string todayDate = Datetime.now().format();

        if (Test.isRunningTest()) {
            return database.getQueryLocator([
                SELECT Id, InvoiceNo__c
                FROM Service_7_Sample_Feedbacks__c
                LIMIT 1
            ]);
        } else {
            return database.getQueryLocator([
                SELECT Id, InvoiceNo__c
                FROM Service_7_Sample_Feedbacks__c
                // LIMIT 1
            ]);
        }
    }

    global void Execute(database.BatchableContext bc, List < Service_7_Sample_Feedbacks__c > scope) {
        List<Service_7_Sample_Feedbacks__c> ssfMappingList = new List<Service_7_Sample_Feedbacks__c>();
        ssfMappingList.addAll(scope);

        if (!ssfMappingList.isEmpty()) {
            // Start processing the first invoice using Queueable
            System.enqueueJob(new Service7UpdateSentOnCallout(ssfMappingList, 0));
        }
    }

    global void finish(Database.BatchableContext BC) {}

    // Implement Schedulable
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Service7UpdateSentOn_Batch(), 1); // Set batch size to 1
    }

}