global class CreateSalesRegisterFromNAV_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts, Schedulable {

    global database.QueryLocator start(database.BatchableContext bc) {
        string todayDate = Datetime.now().format();

        if (Test.isRunningTest()) {
            return database.getQueryLocator([
                SELECT Id, Account__c, Sales_Person__c
                FROM Customer_Sales_Person_Mapping__c
                WHERE Account__c != null
                AND Sales_Person__c != null
                ORDER BY Account__c
                LIMIT 1
            ]);
        } else {
            return database.getQueryLocator([
                SELECT Id, Account__c, Sales_Person__c
                FROM Customer_Sales_Person_Mapping__c
                WHERE Account__c != null
                AND Sales_Person__c != null
                ORDER BY Account__c
                LIMIT 1
            ]);
        }
    }

    global void Execute(database.BatchableContext bc, List < Customer_Sales_Person_Mapping__c > scope) {

        List<Customer_Sales_Person_Mapping__c> cspMappingList = new List<Customer_Sales_Person_Mapping__c>();
        cspMappingList.addAll(scope);

        if (!cspMappingList.isEmpty()) {
            // Start processing the first invoice using Queueable
            System.enqueueJob(new CreateSalesRegisterQableCallout(cspMappingList, 0));
        }

    }

    global void finish(Database.BatchableContext BC) {}

    // Implement Schedulable
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CreateSalesRegisterFromNAV_Batch(), 1); // Set batch size to 1
    }

}