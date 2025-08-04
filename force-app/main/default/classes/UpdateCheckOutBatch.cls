global class UpdateCheckOutBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Check_In__c, Check_Out__c, CreatedDate 
            FROM Employee_Login__c 
            WHERE CreatedDate = TODAY AND Check_In__c != null AND Check_Out__c = null
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Employee_Login__c> toUpdate = new List<Employee_Login__c>();
        
        for (SObject s : scope) {
            Employee_Login__c login = (Employee_Login__c)s;
            login.Check_Out__c = System.now(); // sets current date/time
            toUpdate.add(login);
        }
        
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optional logging or notifications
    }
    
    // Make the class schedulable
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, 1); // specify batch size if needed
    }
}