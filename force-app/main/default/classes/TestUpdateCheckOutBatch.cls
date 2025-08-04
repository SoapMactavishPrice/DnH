@isTest
public class TestUpdateCheckOutBatch {
    
    @testSetup
    static void setupData() {
        // Create a record with today's Check-In (should be picked up by the batch)
        Employee_Login__c todayCheckIn = new Employee_Login__c(
            Check_In__c = System.now().addMinutes(-30)  // within today
        );
        
        // Create a record with yesterday's Check-In (should NOT be picked up)
        Employee_Login__c yesterdayCheckIn = new Employee_Login__c(
            Check_In__c = System.now().addDays(-1)
        );
        
        insert new List<Employee_Login__c>{ todayCheckIn, yesterdayCheckIn };
            }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        UpdateCheckOutBatch batch = new UpdateCheckOutBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Query records again to verify Check_Out__c is set correctly for today's record
        List<Employee_Login__c> updatedLogins = [
            SELECT Id, Check_In__c, Check_Out__c 
            FROM Employee_Login__c 
            WHERE Check_In__c >= :Date.today()
            AND Check_In__c < :Date.today().addDays(1)
        ];
        
        System.assertEquals(1, updatedLogins.size(), 'Only one record should be updated');
        System.assertNotEquals(null, updatedLogins[0].Check_Out__c, 'Check_Out__c should be populated');
    }
}