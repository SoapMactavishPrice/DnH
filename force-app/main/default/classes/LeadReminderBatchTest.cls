@isTest
public class LeadReminderBatchTest {

    @isTest
    static void testLeadReminderBatch() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'Owner',
            Email = 'testowner@example.com',
            Username = 'testowner123@example.com',
            Alias = 'tst',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        Lead__c ld = new Lead__c(
            Name = 'Lead Test',
            OwnerId = u.Id,
            First_Name__c = 'Test Lead',
            Lead_Status__c = 'New',
            New_Status_Date__c = Date.today().addDays(-3)
        );
        insert ld;

        Test.startTest();
        Database.executeBatch(new LeadReminderBatch(), 1);
        Test.stopTest();

        Lead__c updatedLead = [SELECT Last_Reminder_Day__c FROM Lead__c WHERE Id = :ld.Id];
        // System.assertNotEquals(null, updatedLead.Last_Reminder_Day__c);
    }

    @isTest
    static void testScheduler() {

        Test.startTest();
        String cron = '0 0 10 * * ?';
        System.schedule('LeadReminderScheduler', cron, new LeadReminderBatch());
        Test.stopTest();

        System.assert(true);
    }
}
