global class Service19ReminderEmail_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        string todayDate = Datetime.now().format();

        if (Test.isRunningTest()) {
            return database.getQueryLocator([
                SELECT Id, Name, Code__c, Email
                FROM User
                WHERE Code__c != null
                ORDER BY Code__c ASC LIMIT 1
            ]);
        } else {
            return database.getQueryLocator([
                SELECT Id, Name, Code__c, Email
                FROM User
                WHERE Code__c != null
                // ORDER BY Code__c ASC LIMIT 1
            ]);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope) {

        List<User> userList = new List<User>();
        userList.addAll(scope);

        if (!userList.isEmpty()) {
            // Start processing the first invoice using Queueable
            System.enqueueJob(new Service19ReminderEmailQueueable(userList, 0));
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Completed.');
    }

    global void execute(SchedulableContext sc) {
        // Service19ReminderEmail_Batch batch = new Service19ReminderEmail_Batch();
        Database.executeBatch(new Service19ReminderEmail_Batch(), 1);
    }
}