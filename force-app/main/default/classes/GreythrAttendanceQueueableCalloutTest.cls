@isTest
public class GreythrAttendanceQueueableCalloutTest {
    @testSetup
    static void setupTestData() {
        User emp = new User(
            FirstName = 'Test',
            LastName = 'Employee',
            Username = 'testemployee@example.com',
            Email = 'testemployee@example.com',
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
    static void testQueueableExecution() {
        Test.startTest();
        
        List<Employee_Login__c> loginList = [SELECT Id, Check_In__c, Check_Out__c, Employee__r.Code__c FROM Employee_Login__c];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        System.enqueueJob(new GreythrAttendanceQueueableCallout(loginList, 0));
        
        Test.stopTest();
        
        // Add assertions if needed
    }
}