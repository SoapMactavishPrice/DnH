@isTest
public class CheckSampleOrdInv_BatchSchedulerTest {
    
/*    // Test method to verify the scheduler execution
    @isTest
    static void testSchedulerExecution() {
        // Create a mock batch class if needed (you could use a simple implementation)
        Test.startTest();
        
        // Schedule the batch job using a valid cron expression
        String cronExp = '0 0 * * * ?';  // Every hour on the hour (valid cron expression)
        CheckSampleOrdInv_BatchScheduler scheduler = new CheckSampleOrdInv_BatchScheduler();
        String jobID = System.schedule('Test Batch Job', cronExp, scheduler);
        
        // Verify that the job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobID LIMIT 1];
        System.assertNotEquals(null, ct, 'Scheduled job should exist');
        System.assertEquals(cronExp, ct.CronExpression, 'Cron expression should match');
        
        Test.stopTest();

        // After Test.stopTest(), check if the batch job was executed (you can check logs or create assertions based on the batch job behavior)
        // You can query the batch job results or verify any updates made by the batch job
        // For example, querying the async job results
     //   AsyncApexJob job = [SELECT Status FROM AsyncApexJob WHERE Id = :jobID LIMIT 1];
     //   System.assertEquals('Completed', job.Status, 'Batch job should complete successfully');
    } */
}