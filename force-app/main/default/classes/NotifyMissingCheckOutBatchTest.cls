@isTest
public class NotifyMissingCheckOutBatchTest {

    @isTest
    static void testNotifyMissingCheckOutBatch() {
        // Set up test data for Profile and User
        Profile salesEngineerProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Engineer' LIMIT 1];

        // Create a unique test user to ensure uniqueness in username
        String randomSuffix = String.valueOf(Math.random()).substring(2, 10); // Random suffix for uniqueness
        User u1 = new User(
            Username = 'dcsdc' + randomSuffix + '@example.com', // Ensure unique username
            LastName = 'ss',
            Alias = 'teqwed',
            Email = 'sddsd' + randomSuffix + '@example.com', // Ensure unique email
            ProfileId = salesEngineerProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert u1;

        // Create Employee_Login__c records with missing check-out for today's date
        Employee_Login__c login1 = new Employee_Login__c(
            Employee__c = u1.Id,
            Check_In__c = System.now() // No Check_Out__c set
        );
        insert login1;

        // Ensure that only 1 record is returned in the start method (and processed)
      /*  Test.startTest();
        
        // Mock the batch start method to return only 1 record (Override behavior for testing)
        NotifyMissingCheckOutBatch batch = new NotifyMissingCheckOutBatch();

        // Execute the batch job with batch size set to 1
        Database.executeBatch(batch, 1);  // Only 1 batch execution
        
        Test.stopTest();*/
        
        Test.startTest();
        // Execute with batch size larger than total records to ensure only 1 execute()
        Database.executeBatch(new NotifyMissingCheckOutBatch(), 200);
        Test.stopTest();
        
        // Optional: Add assertions to verify expected behavior (e.g., email invocations)
        // Example assertion: System.assertEquals(1, Limits.getEmailInvocations(), 'One email should be sent');
    }
}