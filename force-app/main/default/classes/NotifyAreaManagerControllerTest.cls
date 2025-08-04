@isTest
public class NotifyAreaManagerControllerTest {

    @isTest
    static void testSendEmail() {
        // Create and insert test data (Lead and User records)
        User testUser = new User(
            Username = 'testurCreateandinsertestdata@example.com',
            Email = 'testuser@example.com',
            Alias = 'test1',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'zxcv'
        );
        insert testUser;

        // Create Manager User
        User managerUser = new User(
            Username ='alex1278556321@example.co',
            Email = 'manageruser@example.com',
            Alias = 'manag',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            ManagerId = testUser.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName ='xcvb'
        );
        insert managerUser;

        // Create a Lead record
        Lead__c testLead = new Lead__c(
            Name = 'Test Lead',
            Last_Name__c = 'Doe',
     //       Industry__c = 'Technology',
            Company_Name__c = 'Test Company',
            Territory__c = 'Local',
            Mobile_Number__c = '1234567890',
            Email__c = 'testlead@example.com',
            Lead_Status__c = 'New',
            Lead_Type__c = 'Export',
            OwnerId = testUser.Id
        );
        insert testLead;

        // Set the Lead ID in the current page parameters
        Test.setCurrentPage(new PageReference('/apex/NotifyAreaManager')); // Dummy PageReference, doesn't need to exist
        ApexPages.currentPage().getParameters().put('id', testLead.Id);

        // Instantiate the controller
        NotifyAreaManagerController controller = new NotifyAreaManagerController();

        // Mock the behavior of the email sending functionality (Send the email)
        Test.startTest();
        controller.sendEmail();
        Test.stopTest();
    }

    @isTest
    static void testGetSomething() {
        // Create and insert test data (Lead record)
        Lead__c testLead = new Lead__c(
            Name = 'Test Lead',
            Last_Name__c = 'Doe',
          //  Industry__c = 'Technology',
            Company_Name__c = 'Test Company',
            Territory__c = 'Local',
            Mobile_Number__c = '1234567890',
            Email__c = 'testlead@example.com',
            Lead_Status__c = 'New',
            Lead_Type__c = 'Export',
            OwnerId = UserInfo.getUserId()
        );
        insert testLead;

        // Set the Lead ID in the current page parameters
        Test.setCurrentPage(new PageReference('/apex/NotifyAreaManager')); // Dummy PageReference, doesn't need to exist
        ApexPages.currentPage().getParameters().put('id', testLead.Id);

        // Instantiate the controller
        NotifyAreaManagerController controller = new NotifyAreaManagerController();

        // Call the getSomething method to simulate page navigation
        Test.startTest();
        controller.getSomething();
        Test.stopTest();
    }
}