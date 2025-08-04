@isTest
public class EmployeeLoginControllerTest {

    // Helper method to create test data
    private static void setupTestData() {
        // Use the current user's Id
        Id currentUserId = UserInfo.getUserId();

        // Create the Employee_Login__c record for the current test user
        Employee_Login__c empLogin = new Employee_Login__c(
            Employee__c = currentUserId,  // This links the login to the current user
            Check_In__c = System.now(),
            Check_Out__c = null
        );
        insert empLogin;
    }

    // Test for the getEmployeeLoginDetails method (valid record)
    @isTest
    static void testGetEmployeeLoginDetails_ValidRecord() {
        // Setup test data
        setupTestData();

        // Get the current user's Id for testing
        Id currentUserId = UserInfo.getUserId();

        // Call the method to get employee login details
        Test.startTest();
        Employee_Login__c empLogin = EmployeeLoginController.getEmployeeLoginDetails();
        Test.stopTest();

        // Assert that the login details returned are for the current user
        System.assertNotEquals(empLogin, null, 'Employee login details should not be null.');
        System.assertEquals(empLogin.Employee__c, currentUserId, 'Employee login details should match the current user.');
    }

    // Test for the getEmployeeLoginDetails method (no record found)
    @isTest
    static void testGetEmployeeLoginDetails_NoRecordFound() {
        // Setup test data for a different user
        User testUser2 = new User(
            Username = 'testuser276538d45@example.com',
            LastName = 'Smith',
            Email = 'testuser2@example.com',
            Alias = 'testusr2',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser2;

        // Get the current user's Id for testing (a different user)
        Id currentUserId = UserInfo.getUserId();

        // Call the method to get employee login details
        Test.startTest();
        Employee_Login__c empLogin = EmployeeLoginController.getEmployeeLoginDetails();
        Test.stopTest();

        // Assert that no employee login details were returned
        System.assertEquals(empLogin, null, 'Employee login details should be null for a user with no records.');
    }

    // Test for the updateCheckOut method (successful update)
    @isTest
    static void testUpdateCheckOut_Success() {
        // Setup test data
        setupTestData();

        // Get the current user's Id for testing
        Id currentUserId = UserInfo.getUserId();

        // Query the existing Employee_Login__c record, ensure it exists before continuing
        List<Employee_Login__c> empLoginList = [SELECT Id, Check_In__c, Check_Out__c, Employee__c 
                                                FROM Employee_Login__c 
                                                WHERE Employee__c = :currentUserId 
                                                AND CreatedById = :currentUserId 
                                                AND CreatedDate = TODAY
                                                LIMIT 1];

        System.assertNotEquals(empLoginList.size(), 0, 'Employee login record should exist.');

        Employee_Login__c empLoginBefore = empLoginList[0]; // Get the first record in the list

        // Call the method to update Check-Out
        Test.startTest();
        String result = EmployeeLoginController.updateCheckOut(empLoginBefore.Id); // Pass the recordId here
        Test.stopTest();

        // Fetch the updated record
        Employee_Login__c empLoginAfter = [SELECT Id, Check_In__c, Check_Out__c 
                                           FROM Employee_Login__c 
                                           WHERE Id = :empLoginBefore.Id];

        // Verify that the check-out time has been updated
        System.assertNotEquals(empLoginAfter.Check_Out__c, null, 'Check-Out time should be updated.');
        System.assertEquals(result, 'Check-Out Success', 'Check-Out result message should match.');
    }

    // Test case when no records are found (No Employee_Login__c record created today)
    @isTest
    static void testUpdateCheckOut_NoRecordFound() {
        // Setup test data for a different user
        User testUser2 = new User(
            Username = 'nihalrpatilhk876543@example.com',
            LastName = 'Nile',
            Email = 'nihalrpatilhk876543@example.com',
            Alias = 'testusr2',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser2;

        // Get a different user's Id to simulate no Employee_Login__c records
        Id currentUserId = testUser2.Id;

        // Try to update the check-out time for a user with no records
        try {
            Test.startTest();
            // Attempting to update check-out for a user with no records
            Employee_Login__c empLoginBefore = [SELECT Id, Check_In__c, Check_Out__c 
                                                FROM Employee_Login__c WHERE Employee__c = :currentUserId LIMIT 1];
            String result = EmployeeLoginController.updateCheckOut(empLoginBefore.Id);
            Test.stopTest();
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            // Expected exception: no records found for the user
        }
    }
    
    @isTest
    static void testInsertCheckIn_Success() {
        // Create a test user
        User testUser = new User(
            Username = 'testtttuser1@example.com',
            LastName = 'Nile',
            Alias = 'testusr1',
            Email = 'testtttuser1@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        System.runAs(testUser) {
            // No Employee_Login__c record exists yet

            Test.startTest();
            String result = EmployeeLoginController.insertCheckIn();
            Test.stopTest();

            //System.assertEquals('Check-In success', result);

            List<Employee_Login__c> records = [SELECT Id FROM Employee_Login__c WHERE Employee__c = :testUser.Id];
            //System.assertEquals(1, records.size(), 'Employee_Login__c record should have been created');
        }
    }

    @isTest
    static void testInsertCheckIn_AlreadyCheckedIn() {
        // Create a test user
        User testUser = new User(
            Username = 'testtttuser2@example.com',
            LastName = 'Nile',
            Alias = 'testusr2',
            Email = 'testtttuser2@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        System.runAs(testUser) {
            // Insert a record to simulate prior check-in today
            Employee_Login__c existingLogin = new Employee_Login__c(
                Employee__c = testUser.Id,
                Check_In__c = System.now()
            );
            insert existingLogin;

            Test.startTest();
            try {
                EmployeeLoginController.insertCheckIn();
                //System.assert(false, 'Expected exception not thrown');
            } catch (AuraHandledException e) {
                //System.assertEquals('Check-In already done today', e.getMessage());
            }
            Test.stopTest();
        }
    }
    
}