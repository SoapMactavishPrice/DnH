@isTest
public class LeadSourceHandlerTest {

    @isTest
    static void testHandleAfterUpdate() {
        // Create test data for User, Lead, and Lead_Source__c
        User testUser1 = new User(
            Username = 'testusersdgddgdg1@domain.com', 
            LastName = 'Testhbbjaldfdsfdskansl',
            Email = 'testusesdfdssdfr1@domain.com', 
            Alias = 'tuser1', 
            ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
        insert testUser1;

        User testUser2 = new User(
            Username = 'testuser2fgsfa@domain.com',
            LastName = 'Testhbbjagsgsddflkansl',
            Email = 'testusergsdgdsgs2@domain.com', 
            Alias = 'tuser2', 
            ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
        insert testUser2;
        
        // Create a State record (assuming object name is State__c)
    State__c testState = new State__c(
        Name = 'Maharashtra'
    );
    insert testState;

        // Create test Lead
        Lead testLead = new Lead(
            FirstName = 'John', 
            LastName = 'Doe', 
            Company = 'Acme Corp',
            State__c= testState.Id
        );
        insert testLead;
        
        Lead__c testLead1 = new Lead__c(
            First_Name__c = 'John', 
            Last_Name__c = 'Doe'
        );
        insert testLead1;


        // Create Lead_Source__c record
        Lead_Source__c testLeadSource = new Lead_Source__c(
            Lead__c = testLead1.Id,
            OwnerId = testUser1.Id,
            Mobile_No__c = '123-456-7890',
            Subject__c = 'Test Subject',
            Product_Name__c = 'Test Product',
            Message__c = 'Test message'
        );
        insert testLeadSource;

        // Update Lead_Source__c record to simulate OwnerId change
        testLeadSource.OwnerId = testUser2.Id;
        update testLeadSource;

        // Create oldMap and newList as needed for the trigger context
        List<Lead_Source__c> newList = new List<Lead_Source__c>{testLeadSource};
        Map<Id, Lead_Source__c> oldMap = new Map<Id, Lead_Source__c>{
            testLeadSource.Id => [SELECT Id, OwnerId, Lead__c FROM Lead_Source__c WHERE Id = :testLeadSource.Id LIMIT 1]
        };

        // Call the handler method to simulate trigger behavior
        Test.startTest();
        LeadSourceHandler.handleAfterUpdate(newList, oldMap);
        Test.stopTest();

        // Verify that the email was sent by checking the Messaging.sendEmail method
      //  List<Messaging.SingleEmailMessage> sentEmails = [SELECT ToAddress, Subject, HtmlBody FROM Messaging.SingleEmailMessage];

      

        // Verify email details
      //  Messaging.SingleEmailMessage sentEmail = sentEmails[0];
        
    }
}