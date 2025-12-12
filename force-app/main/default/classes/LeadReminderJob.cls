public class LeadReminderJob {

    public static void sendReminders() {

        Datetime nowDt = Datetime.now();

        List<Lead__c> leads = [
            SELECT Id, Name, OwnerId, CreatedDate, Lead_Status__c,
                   Company_Name__c, Email__c, Mobile_Number__c, Lead_Source__c,
                   Day2_Reminder_Sent__c, Day5_Reminder_Sent__c,
                   Day10_Reminder_Sent__c, Day15_Reminder_Sent__c
            FROM Lead__c
            WHERE Lead_Status__c = 'New'
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Lead__c> updates = new List<Lead__c>();

        for (Lead__c l : leads) {

            Integer diffDays = l.CreatedDate.date().daysBetween(nowDt.date());
            String ownerName = [SELECT Name FROM User WHERE Id = :l.OwnerId].Name;
            String leadUrl = System.URL.getOrgDomainUrl().toExternalForm() + '/' + l.Id;


            // ⬇ FORMATTED EMAIL BODY
            String emailBody =
                'Hi ' + ownerName + ',\n\n' +
                'A new lead has been assigned to you in Salesforce. Here are the details:\n\n' +
                'Lead Name: ' + l.Name + '\n' +
                'Company: ' + l.Company_Name__c + '\n' +
                'Email: ' + l.Email__c + '\n' +
                'Phone: ' + l.Mobile_Number__c + '\n' +
                'Lead Source: ' + l.Lead_Source__c + '\n\n' +
                'Please follow up with this lead at the earliest to ensure timely engagement.\n\n' +
                'View Lead in Salesforce: ' + leadUrl + '\n\n' +
                'Thanks,\nSalesforce System Notification';

            // 📌 Day-by-day logic
            if (diffDays >= 2 && !l.Day2_Reminder_Sent__c) {
                send(l, 'New Lead Assigned to You – ' + l.Name, emailBody, emails);
                updates.add(new Lead__c(Id = l.Id, Day2_Reminder_Sent__c=true));
            }
           
            if (diffDays >= 5 && !l.Day5_Reminder_Sent__c) {
                send(l, 'New Lead Assigned to You – ' + l.Name, emailBody, emails);
                updates.add(new Lead__c(Id = l.Id, Day5_Reminder_Sent__c=true));
            }
            if (diffDays >= 10 && !l.Day10_Reminder_Sent__c) {
                send(l, 'New Lead Assigned to You – ' + l.Name, emailBody, emails);
                updates.add(new Lead__c(Id = l.Id, Day10_Reminder_Sent__c=true));
            }
            if (diffDays >= 15 && !l.Day15_Reminder_Sent__c) {
                send(l, 'New Lead Assigned to You – ' + l.Name, emailBody, emails);
                updates.add(new Lead__c(Id = l.Id, Day15_Reminder_Sent__c=true));
            }
           
        }

        if (!emails.isEmpty()) Messaging.sendEmail(emails);
        if (!updates.isEmpty()) update updates;
    }

    private static void send(Lead__c l, String subject, String body, List<Messaging.SingleEmailMessage> emails) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(l.OwnerId);
        email.setSaveAsActivity(false);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        emails.add(email);
    }
}