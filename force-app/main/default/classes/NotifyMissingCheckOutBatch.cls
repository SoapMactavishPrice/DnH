global class NotifyMissingCheckOutBatch implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Email 
            FROM User 
            WHERE IsActive = TRUE 
            AND Profile.Name = 'Sales Engineer' and Email != 'arnav.maheshwari@dnhsecheron.net' AND Email != 'ganeshkumar@dnhsecheron.net'
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        
        for (User u : (List<User>)scope) {
            userIds.add(u.Id);
            userMap.put(u.Id, u);
        }
        
        // Get today’s check-ins
        Map<Id, Employee_Login__c> todaysLogins = new Map<Id, Employee_Login__c>();
        for (Employee_Login__c login : [
            SELECT Id, Employee__c, Check_Out__c
            FROM Employee_Login__c
            WHERE CreatedDate = TODAY
            AND Employee__c IN :userIds
        ]) {
            // Only pick if no check-out yet
            if (login.Check_Out__c == null) {
                todaysLogins.put(login.Employee__c, login);
            }
        }
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Id userId : userIds) {
            if (todaysLogins.containsKey(userId)) {
                User u = userMap.get(userId);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { u.Email });
                email.setBccAddresses(new String[] { 'vaibhav.bhosale@dnhsecheron.net' });
                email.setSubject('Reminder: Please Check-Out Today');
                email.setPlainTextBody('Hi ' + u.Name + ',\n\nIt looks like you haven’t checked out today. Please remember to do so before the day ends.\n\nRegards,\nAdmin');
                emailsToSend.add(email);
            }
        }
        
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend, false);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optional logging
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, 1);
    }
}