global class NotifyMissingCheckInBatch implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Email 
            FROM User 
            WHERE IsActive = TRUE 
            AND Profile.Name = 'Sales Engineer' and Email != 'arnav.maheshwari@dnhsecheron.net' AND Email != 'ganeshkumar@dnhsecheron.net'
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        Set<Id> salesEngineerIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        
        for (User u : (List<User>)scope) {
            salesEngineerIds.add(u.Id);
            userMap.put(u.Id, u);
        }
        
        Set<Id> usersCheckedInToday = new Set<Id>();
        for (Employee_Login__c login : [
            SELECT Id, Employee__c 
            FROM Employee_Login__c 
            WHERE CreatedDate = TODAY
            AND Employee__c IN :salesEngineerIds
        ]) {
            usersCheckedInToday.add(login.Employee__c);
        }
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Id userId : salesEngineerIds) {
            if (!usersCheckedInToday.contains(userId)) {
                User u = userMap.get(userId);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { u.Email });
                email.setBccAddresses(new String[] { 'vaibhav.bhosale@dnhsecheron.net' });
                email.setSubject('Reminder: Please Check-In Today');
                email.setPlainTextBody('Hi ' + u.Name + ',\n\nOur records show you haven’t checked in yet today. Please remember to check in.\n\nRegards,\nAdmin');
                emailsToSend.add(email);
            }
        }
        
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend, false);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optional logging or summary
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, 50); // adjust batch size if needed
    }
}