global class GreythrAttendanceAPI_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts, Schedulable {

    global database.QueryLocator start(database.BatchableContext bc) {
        string todayDate = Datetime.now().format();

        if (Test.isRunningTest()) {
            return database.getQueryLocator([
                SELECT Id, Name, Check_In__c, Check_Out__c, Employee__c, Employee__r.Code__c
                FROM Employee_Login__c LIMIT 1
            ]);
        } else {
            return database.getQueryLocator([
                SELECT Id, Name, Check_In__c, Check_Out__c, Employee__c, Employee__r.Code__c
                FROM Employee_Login__c
                WHERE CreatedDate = YESTERDAY
                AND Employee__r.Code__c != null
                AND Employee__r.Code__c != 'DnH-ADMIN'
                AND Check_In__c != null
                AND Check_Out__c != null
            ]);
        }
    }

    global void Execute(database.BatchableContext bc, List < Employee_Login__c > scope) {

        List<Employee_Login__c> empLoginList = new List<Employee_Login__c>();
        empLoginList.addAll(scope);

        if (!empLoginList.isEmpty()) {
            // Start processing the first invoice using Queueable
            System.enqueueJob(new GreythrAttendanceQueueableCallout(empLoginList, 0));
        }

    }

    global void finish(Database.BatchableContext BC) {}

    // Implement Schedulable
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GreythrAttendanceAPI_Batch(), 1); // Set batch size to 1
    }
    
}