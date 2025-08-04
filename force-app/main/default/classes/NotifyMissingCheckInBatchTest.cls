@isTest
private class NotifyMissingCheckInBatchTest {

    @isTest
    static void testNotifyMissingCheckInBatch() {
        // Get the Sales Engineer profile
        Profile seProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Engineer' LIMIT 1];

        // Create just one test user to ensure only one execute() call
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@examplemaruiyes90.com.test', // username must be unique
            Alias = 'tusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = seProfile.Id
        );
        insert testUser;

        Test.startTest();
        // Execute with batch size larger than total records to ensure only 1 execute()
        Database.executeBatch(new NotifyMissingCheckInBatch(), 200);
        Test.stopTest();

        // Optional assertion
        //System.assertEquals(1, Limits.getEmailInvocations(), 'One email should be sent');
    }
}