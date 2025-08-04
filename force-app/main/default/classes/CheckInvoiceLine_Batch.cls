global class CheckInvoiceLine_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts, Schedulable {
    
    global database.QueryLocator start(database.BatchableContext bc) {

        DateTime now = DateTime.now();
        DateTime last24Hours = now.addHours(-24);
        
        return database.getQueryLocator([
            SELECT Id, Name
            FROM Invoice__c
            WHERE CreatedDate >= :last24Hours
        ]);

    }

    global void Execute(database.BatchableContext bc, List < Invoice__c > scope) {

        List<Invoice__c> invoiceList = new List<Invoice__c>();
        invoiceList.addAll(scope);

        if (!invoiceList.isEmpty()) {
            // Start processing the first invoice using Queueable
            System.enqueueJob(new Service7QueueableCallout('S7_SalesInvoiceLine', invoiceList, 0));
        }

    }

    global void finish(Database.BatchableContext BC) {}

    // Implement Schedulable
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CheckInvoiceLine_Batch(), 1); // Set batch size to 1
    }

}