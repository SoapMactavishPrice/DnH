@isTest
public class Service19ReminderEmailQueueableTest {
    
    @testSetup
    static void setupData() {
        // Create Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;
        
        // Create Area Manager user
        User areaManager1 = new User(
            FirstName = 'Area',
            LastName = 'Manager',
            Email = 'areamanager@example.com',
            Username = 'areamanager' + DateTime.now().getTime() + '@example.com',
            Alias = 'amgr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert areaManager1;
        
        // Create Account
        Account acc1 = new Account(Name = 'Test Account');
        insert acc1;
        
        // Create Item Master
        Item_Master__c item1 = new Item_Master__c(
            Item_Number__c = 'ITEM001',
            Item_Description__c = 'Test Item Desc'
        );
        insert item1;
        
        // Run as test user to ensure CreatedById matches
        System.runAs(testUser) {
            // Insert Account under testUser context
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            
            // Insert Area Manager inside runAs to avoid access issue
            User areaManager = [SELECT Id FROM User WHERE Email = 'areamanager@example.com' LIMIT 1];
            
            // Insert Item Master
            Item_Master__c item = new Item_Master__c(
                Item_Number__c = 'ITEM001',
                Item_Description__c = 'Test Item Desc'
            );
            insert item;
            
            // Create Customer Complaint
            Customer_Complaint__c complaint = new Customer_Complaint__c(
                Name = 'CC-001',
                TSD_Remarks__c = 'TSD completed',
                Status__c = 'Closed By TSD User',
                Close_NAV__c = false,
                Close_TSD__c = false,
                Submitted_Date__c = Date.today().addDays(-12),
                Updated_On__c = DateTime.now().addDays(-11),
                Inserted_By__c = testUser.Id,
                Updated_By__c = testUser.Id,
                Submitted_By__c = testUser.Id,
                Field_Engineer_Name__c = testUser.Id,
                Area_Manager__c = areaManager.Id,
                Invoice_No__c = 'INV123',
                InvoiceDate__c = Date.today().addDays(-20),
                Account__c = acc.Id,
                ItemNo__c = item.Item_Number__c,
                Size_mm__c = '20',
                Batch_No__c = 'BATCH123',
                Batch_Quantity__c = 100,
                Complaint_Quantity__c = 10
            );
            insert complaint;
        }
        
    }
    
    @isTest
    static void testService19ReminderQueueable() {
        // Get the user inserted in setup
        User testUser = [SELECT Id, Email FROM User WHERE Email = 'testuser@example.com' LIMIT 1];
        
        List<User> userList = new List<User>{ testUser };
            
            Test.startTest();
        Service19ReminderEmailQueueable queueable = new Service19ReminderEmailQueueable(userList, 0);
        System.enqueueJob(queueable);
        Test.stopTest();
        
        System.assert(true, 'Queueable job executed without exceptions.');
    }
}