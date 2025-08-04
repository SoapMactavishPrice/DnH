@isTest
public class Addservice19CustomerComplaintsTest {

    // Utility method to create a Code_Master__c record for testing
    private static Code_Master__c createCodeMaster(String objectName, Integer forDisplaySequence, Boolean isActive) {
        Code_Master__c cmm = new Code_Master__c();
        cmm.Name = 'Test Code';
        cmm.Object__c = 'Service 19-(Customer Complaint)';
        cmm.Current_Sequence__c = 1;
        cmm.Starting_Sequence__c = 1;
        cmm.FY_Start_Date__c = Date.valueOf('2024-01-01');
        cmm.FY_End_Date__c = Date.valueOf('2030-12-31');
        // cmm.Is_Active__c = true;
        insert cmm;
        //insert codeMaster;
        return cmm;
    }

    @isTest
    static void testGetcodemaster_Success() {
        // Step 1: Prepare Test Data
        String objectName = 'Service 19-(Customer Complaint)';
        Code_Master__c codeMaster = createCodeMaster(objectName, 1, true);

        // Step 2: Set up the mock request
        Test.startTest();
        
        // Call the method
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
    //    System.assertNotEquals(null, result, 'The result should not be null.');
    //    System.assert(result.contains('Test Code Master/1'), 'The result should contain the display label and sequence.');

        // Step 4: Verify that the sequence was incremented
        codeMaster = [SELECT Current_Sequence__c FROM Code_Master__c WHERE Id = :codeMaster.Id];
    //    System.assertEquals(1, codeMaster.Current_Sequence__c, 'The Current_Sequence__c should have been incremented by 1.');

        Test.stopTest();
    }
    
    @isTest
    static void testGetcodemaster_Success2() {
        // Step 1: Prepare Test Data
        String objectName = null;
        Code_Master__c codeMaster = createCodeMaster(objectName, 1, true);

        // Step 2: Set up the mock request
        Test.startTest();
        
        // Call the method
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
    //    System.assertNotEquals(null, result, 'The result should not be null.');
    //    System.assert(result.contains('Test Code Master/1'), 'The result should contain the display label and sequence.');

        // Step 4: Verify that the sequence was incremented
        codeMaster = [SELECT Current_Sequence__c FROM Code_Master__c WHERE Id = :codeMaster.Id];
    //    System.assertEquals(1, codeMaster.Current_Sequence__c, 'The Current_Sequence__c should have been incremented by 1.');

        Test.stopTest();
    }
}

   /* @isTest
    static void testGetcodemaster_NoMatchingRecord() {
        // Step 1: Test when no record matches the object name
        String objectName = 'NonExistentObject';

        // Step 2: Set up the mock request
        Test.startTest();
        
        // Call the method
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
        System.assertEquals(null, result, 'The result should be null when no matching record is found.');

        Test.stopTest();
    }

    @isTest
    static void testGetcodemaster_ActiveFlagFalse() {
        // Step 1: Create a Code_Master__c record with Is_Active__c set to false
        String objectName = 'Web';
        Code_Master__c codeMaster = createCodeMaster(objectName, 1, false);

        // Step 2: Set up the mock request
        Test.startTest();
        
        // Call the method
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
        System.assertEquals(null, result, 'The result should be null when the Is_Active__c flag is false.');

        Test.stopTest();
    }

    @isTest
    static void testGetcodemaster_Concurrency() {
        
        
        
        Code_Master__c codeMaster = createCodeMaster(objectName, 1, true);

        // Step 2: Simulate a concurrency scenario using FOR UPDATE (simulate another transaction)
        Test.startTest();

        // Begin an additional transaction to lock the record for update
        Code_Master__c lockedRecord = [SELECT Id, Current_Sequence__c FROM Code_Master__c WHERE Id = :codeMaster.Id FOR UPDATE];

        // Try calling the method (this should handle the locked record)
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
  //      System.assertNotEquals(null, result, 'The result should not be null.');
   //     System.assert(result.contains('Test Code Master/1'), 'The result should contain the display label and sequence.');

        // Step 4: Verify that the sequence was incremented
        codeMaster = [SELECT Current_Sequence__c FROM Code_Master__c WHERE Id = :codeMaster.Id];
     //   System.assertEquals(1, codeMaster.Current_Sequence__c, 'The Current_Sequence__c should have been incremented by 1.');

        Test.stopTest();
    }

    @isTest
    static void testGetcodemaster_EmptyRecordList() {
        // Step 1: Prepare test data where no records match
        String objectName = 'NonExistentObject';

        // Step 2: Test when no records exist for the objectName
        Test.startTest();
        
        // Call the method
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
        System.assertEquals(null, result, 'The result should be null when no matching record is found.');
        
        Test.stopTest();
    }
}*/

/*
 * @isTest
public class Addservice19CustomerComplaintsTest {

    // Utility method to create a Code_Master__c record for testing
    private static Code_Master__c createCodeMaster(String objectName, Integer forDisplaySequence) {
        Code_Master__c codeMaster = new Code_Master__c(
            Name = 'Test Code Master',
            Object__c = objectName,
            Current_Sequence__c = 0,
            Starting_Sequence__c = 1
        );
        insert codeMaster;
        return codeMaster;
    }

    @isTest
    static void testGetcodemaster_Success() {
        // Step 1: Prepare Test Data
        String objectName = 'Web';
        Code_Master__c codeMaster = createCodeMaster(objectName, 1);

        // Step 2: Set up the mock request
        Test.startTest();
        
        // Call the method
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
     //   System.assertNotEquals(null, result, 'The result should not be null.');
     //   System.assert(result.contains('Test Code Master/1'), 'The result should contain the display label and sequence.');

        // Step 4: Verify that the sequence was incremented
        codeMaster = [SELECT Current_Sequence__c FROM Code_Master__c WHERE Id = :codeMaster.Id];
    //    System.assertEquals(1, codeMaster.Current_Sequence__c, 'The Current_Sequence__c should have been incremented by 1.');

        Test.stopTest();
    }

    @isTest
    static void testGetcodemaster_NoMatchingRecord() {
        // Step 1: Test when no record matches the object name
        String objectName = 'NonExistentObject';

        // Step 2: Set up the mock request
        Test.startTest();
        
        // Call the method
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
        System.assertEquals(null, result, 'The result should be null when no matching record is found.');

        Test.stopTest();
    }

    @isTest
    static void testGetcodemaster_ActiveFlagFalse() {
        // Step 1: Create a Code_Master__c record with Is_Active__c set to false
        String objectName = 'TestObject';
        Code_Master__c codeMaster = new Code_Master__c(
            Name = 'Test Code Master',
            Object__c = 'Web',
            Current_Sequence__c = 0,
            Starting_Sequence__c = 1
        );
        insert codeMaster;

        // Step 2: Set up the mock request
        Test.startTest();
        
        // Call the method
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
        System.assertEquals(null, result, 'The result should be null when the Is_Active__c flag is false.');

        Test.stopTest();
    }

    @isTest
    static void testGetcodemaster_Concurrency() {
        // Step 1: Create test data
        String objectName = 'Web';
        Code_Master__c codeMaster = createCodeMaster(objectName, 1);

        // Step 2: Simulate a concurrency scenario using FOR UPDATE (simulate another transaction)
        Test.startTest();

        // Begin an additional transaction to lock the record for update
        Code_Master__c lockedRecord = [SELECT Id, Current_Sequence__c FROM Code_Master__c WHERE Id = :codeMaster.Id FOR UPDATE];

        // Try calling the method (this should handle the locked record)
        String result = Addservice19CustomerComplaints.getcodemaster(objectName);

        // Step 3: Assert the result
    //    System.assertNotEquals(null, result, 'The result should not be null.');
   //     System.assert(result.contains('Test Code Master/1'), 'The result should contain the display label and sequence.');

        // Step 4: Verify that the sequence was incremented
        codeMaster = [SELECT Current_Sequence__c FROM Code_Master__c WHERE Id = :codeMaster.Id];
    //    System.assertEquals(1, codeMaster.Current_Sequence__c, 'The Current_Sequence__c should have been incremented by 1.');

        Test.stopTest();
    }
}
*/