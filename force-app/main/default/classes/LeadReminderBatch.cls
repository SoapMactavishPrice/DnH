public class LeadReminderBatch implements Database.Batchable<SObject>, Schedulable {
    
    // ----------- BATCH START -----------
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, OwnerId, Lead_Status__c,First_Name__c, New_Status_Date__c, Last_Reminder_Day__c
            FROM Lead__c
            WHERE Lead_Status__c = 'New' and Id = 'a01F300000G4i1sIAB' 
            AND New_Status_Date__c <= :Date.today().addDays(-2)
        ]);
    }
    
    // ----------- BATCH EXECUTE -----------
    public void execute(Database.BatchableContext bc, List<Lead__c> scope) {
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Lead__c> updateList = new List<Lead__c>();
        
        for (Lead__c ld : scope) {
            
            Integer daysOld = ld.New_Status_Date__c.daysBetween(Date.today());
            Integer reminderDay;
            
            if (daysOld >= 15)       reminderDay = 15;
            else if (daysOld >= 10) reminderDay = 10;
            else if (daysOld >= 5)  reminderDay = 5;
            else if (daysOld >= 2)  reminderDay = 2;
            else continue;
            
            // Avoid duplicate reminders
            if (ld.Last_Reminder_Day__c != null && ld.Last_Reminder_Day__c >= reminderDay) {
                continue;
            }
            
            // Email notification
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(ld.OwnerId);
            mail.setSubject('Lead Reminder (' + reminderDay + ' days)');
            mail.setPlainTextBody(
                'Lead ' + ld.First_Name__c + 
                ' has been in New status for ' + reminderDay + 
                ' days. Please take action.'
            );
            mail.setSaveAsActivity(false);
            
            emails.add(mail);
            
            // Update reminder day
            ld.Last_Reminder_Day__c = reminderDay;
            updateList.add(ld);
        }
        
        if (!emails.isEmpty()) Messaging.sendEmail(emails);
        if (!updateList.isEmpty()) update updateList;
    }
    
    // ----------- BATCH FINISH -----------
    public void finish(Database.BatchableContext bc) {}
    
    
    // ----------- SCHEDULER EXECUTE -----------
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new LeadReminderBatch(), 1);
    }
}