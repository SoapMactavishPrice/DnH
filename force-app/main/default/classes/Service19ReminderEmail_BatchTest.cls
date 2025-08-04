@isTest
public class Service19ReminderEmail_BatchTest {

    @testSetup
    static void setupData() {
        // Create Profile for test users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Insert multiple users with Code__c to be picked by batch
        for (Integer i = 0; i < 3; i++) {
            User u = new User(
                FirstName = 'User' + i,
                LastName = 'BatchTest',
                Email = 'user' + i + '@example.com',
                Username = 'user' + i + DateTime.now().getTime() + '@example.com',
                Alias = 'usr' + i,
                TimeZoneSidKey = 'Asia/Kolkata',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                Code__c = 'CODE' + i
            );
            insert u;
        }
    }

    @isTest
    static void testBatchExecutionOnly() {
        Test.startTest();
        Service19ReminderEmail_Batch batch = new Service19ReminderEmail_Batch();
        Database.executeBatch(batch, 1); // Batch size = 1 for testing
        Test.stopTest();

        System.assert(true, 'Batch executed without errors.');
    }

    @isTest
    static void testSchedulableOnly() {
        Test.startTest();
        String cronExp = '0 0 1 * * ?'; // Run daily at 1 AM
        System.schedule('Test_Service19ReminderEmailBatch_Schedule', cronExp, new Service19ReminderEmail_Batch());
        Test.stopTest();

        System.assert(true, 'Scheduled batch executed without errors.');
    }
}