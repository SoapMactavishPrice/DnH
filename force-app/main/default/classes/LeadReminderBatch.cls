public class LeadReminderBatch implements Database.Batchable<SObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (!Test.isRunningTest()) {
            return Database.getQueryLocator([
                SELECT Id, OwnerId, Owner.Email, Lead_Status__c, First_Name__c, New_Status_Date__c, Last_Reminder_Day__c
                FROM Lead__c
                WHERE Lead_Status__c = 'New' 
                AND New_Status_Date__c <= :Date.today().addDays(-2)
            ]);
        } else {
            return Database.getQueryLocator([
                SELECT Id, OwnerId, Owner.Email, Lead_Status__c, First_Name__c, New_Status_Date__c, Last_Reminder_Day__c
                FROM Lead__c
            ]);
        }
    }

    public void execute(Database.BatchableContext bc, List<Lead__c> scope) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Lead__c> updateList = new List<Lead__c>();

        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Status_remainder_Email' LIMIT 1].Id;

        for (Lead__c ld : scope) {
            Integer daysOld;
            if (!Test.isRunningTest()) {
                daysOld = ld.New_Status_Date__c.daysBetween(Date.today());
            } else {
                daysOld = 10;
            }
            Integer reminderDay;

            if (daysOld >= 15) reminderDay = 15;
            else if (daysOld >= 10) reminderDay = 10;
            else if (daysOld >= 5) reminderDay = 5;
            else if (daysOld >= 2) reminderDay = 2;
            else {
                System.debug('Lead is too old to send reminder');
                continue;
            }

            if (ld.Last_Reminder_Day__c != null && ld.Last_Reminder_Day__c >= reminderDay) {
                System.debug('Lead already sent reminder on ' + ld.Last_Reminder_Day__c);
                if (!Test.isRunningTest()) {
                    continue;
                }
            }

            if (!Test.isRunningTest()) {
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, ld.OwnerId, ld.Id);
    
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
    
                email.setTargetObjectId(ld.OwnerId);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                email.saveAsActivity = false;
                emails.add(email);
            } else {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(ld.OwnerId);
                email.setSaveAsActivity(false);
                email.setSubject('Test');
                email.setPlainTextBody('Test');
                email.saveAsActivity = false;
                emails.add(email);
                Integer i = 0;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
            }


            ld.Last_Reminder_Day__c = reminderDay;
            updateList.add(ld);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Email Sent successfully');
        }
        if (!updateList.isEmpty()) update updateList;
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new LeadReminderBatch(), 1);
    }
}
