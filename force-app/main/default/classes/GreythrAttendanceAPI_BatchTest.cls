@isTest
public class GreythrAttendanceAPI_BatchTest {
    @testSetup
    static void setupTestData() {
        User emp = new User(
            FirstName = 'Test',
            LastName = 'Employee',
            Username = 'testemployeenewnew@example.com',
            Email = 'testemployeenewnew@example.com',
            Alias = 'testemp',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert emp;
        
        Employee_Login__c login = new Employee_Login__c(
            Name = 'Test Login',
            Employee__c = emp.Id,
            Check_In__c = System.now(),
            Check_Out__c = System.now().addHours(8)
        );
        insert login;
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        GreythrAttendanceAPI_Batch batch = new GreythrAttendanceAPI_Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        // Add assertions if needed
    }
    @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        GreythrAttendanceAPI_Batch batch = new GreythrAttendanceAPI_Batch();
        String cronExp = '0 0 0 * * ? *'; // Runs daily at midnight
        String jobId = System.schedule('Test Schedule Job', cronExp, batch);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
    }
    
}