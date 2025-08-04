@isTest
public class TestShareAccountsQueueable {
    
    @testSetup
    static void setupTestData() {
        // Create test users with required fields
        List<User> users = new List<User>();
        
        for (Integer i = 1; i <= 3; i++) {
            users.add(new User(
                Alias = 'test' + i,
                LastName = 'Bal',
                Email = 'test' + i + '@example.com',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name != 'System Administrator' LIMIT 1].Id,
                TimeZoneSidKey = 'America/New_York',
                UserName = 'testuser111ef' + i + '@example1.com',
                Code__c = 'CODE' + i
            ));
        }
        insert users;
        
        // Create test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= 2; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        
        // Create initial Customer_Sales_Person_Mapping__c records
        List<Customer_Sales_Person_Mapping__c> mappings = new List<Customer_Sales_Person_Mapping__c>();
        
        mappings.add(new Customer_Sales_Person_Mapping__c(
            Account__c = accounts[0].Id,
            Sales_Person_Code__c = 'CODE1',
            Reporting_person_ID__c = 'CODE2',
            Zonal_manager_ID__c = 'CODE3'
        ));
        
        insert mappings;
    }
    
    @isTest
    static void testShareAccountsQueueable() {
        // Retrieve inserted mappings
        List<Customer_Sales_Person_Mapping__c> mappings = [
            SELECT Id, Account__c, Sales_Person_Code__c, Reporting_person_ID__c, Zonal_manager_ID__c 
            FROM Customer_Sales_Person_Mapping__c 
            LIMIT 1
        ];
        
        Test.startTest();
        System.enqueueJob(new ShareAccountsQueueable(mappings));
        Test.stopTest();
        
        // Verify AccountShare records were created
        List<AccountShare> shares = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare];
        System.assert(!shares.isEmpty(), 'AccountShare records should be created.');
    }
}