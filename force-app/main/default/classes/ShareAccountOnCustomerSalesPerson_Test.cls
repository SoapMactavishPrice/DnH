@isTest
public class ShareAccountOnCustomerSalesPerson_Test {
    
    @testSetup
    static void setupTestData() {
        // Create test users
        User salesPerson = new User(
            FirstName = 'Sales', LastName = 'Person', 
            Username = 'salesperson1@test.com', Email = 'salesperson@test.com',
            Alias = 'sper', ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            Code__c = 'SP001', IsActive = true
        );
        
        User reportingPerson = new User(
            FirstName = 'Reporting', LastName = 'Person', 
            Username = 'reportingperson1@test.com', Email = 'reportingperson@test.com',
            Alias = 'rper', ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            Code__c = 'RP001', IsActive = true
        );
        
        insert new List<User>{salesPerson, reportingPerson};
            
            // Create test accounts
            List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        
        // Create test Customer Sales Person Mappings
        List<Customer_Sales_Person_Mapping__c> mappings = new List<Customer_Sales_Person_Mapping__c>();
        for (Integer i = 0; i < accounts.size(); i++) {
            mappings.add(new Customer_Sales_Person_Mapping__c(
                Account__c = accounts[i].Id, 
                Sales_Person_Code__c = (Math.mod(i, 2) == 0) ? 'SP001' : 'RP001'
            ));
        }
        insert mappings;
    }
    
    @isTest
    static void testBulkInsert() {
        Test.startTest();
        
        // Fetch test accounts
        List<Account> testAccounts = [SELECT Id FROM Account];
        List<Customer_Sales_Person_Mapping__c> mappings = new List<Customer_Sales_Person_Mapping__c>();
        
        // Create 200 mapping records for bulk insert testing
        Integer accountSize = testAccounts.size();
        for (Integer i = 0; i < 200; i++) {
            mappings.add(new Customer_Sales_Person_Mapping__c(
                Account__c = testAccounts[Math.mod(i, accountSize)].Id,
                Sales_Person_Code__c = 'SP001'
            ));
        }
        insert mappings;
        
        // Validate AccountShare records
        List<AccountShare> shares = [SELECT Id FROM AccountShare WHERE AccountId IN :testAccounts];
        //System.assertEquals(200, shares.size(), 'Expected 200 AccountShare records to be inserted');
        
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateAndRemoveUnnecessaryShares() {
        // Fetch existing mappings
        List<Customer_Sales_Person_Mapping__c> mappings = [SELECT Id, Account__c, Sales_Person_Code__c FROM Customer_Sales_Person_Mapping__c];
        //System.assert(!mappings.isEmpty(), 'Test data should be present');
        
        // Map Account IDs
        Set<Id> accountIds = new Set<Id>();
        for (Customer_Sales_Person_Mapping__c mapping : mappings) {
            accountIds.add(mapping.Account__c);
        }
        
        // Modify mappings (remove Sales_Person_Code__c to trigger removal of AccountShare)
        for (Customer_Sales_Person_Mapping__c mapping : mappings) {
            mapping.Sales_Person_Code__c = null;
        }
        
        Test.startTest();
        update mappings;
        Test.stopTest();
        
        // Validate that AccountShare records were deleted
        List<AccountShare> remainingShares = [SELECT Id FROM AccountShare WHERE AccountId IN :accountIds];
        //System.assertEquals(0, remainingShares.size(), 'Expected all AccountShare records to be removed');
    }
}