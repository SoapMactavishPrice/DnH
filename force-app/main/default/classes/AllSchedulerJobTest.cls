@isTest
public class AllSchedulerJobTest {
    @isTest
    static void testAllSchedulerJob() {
        // Test setup
        Test.startTest();
        
        // Schedule the job
        String cronExpression = '0 0 12 * * ?'; // Example CRON for testing (runs at 12:00 PM daily)
        System.schedule('Test AllSchedulerJob', cronExpression, new AllSchedulerJob());
       // System.schedule('Test AllSchedulerJob', cronExpression, new AllSchedulerJob1());
        
        Test.stopTest();
        
        // Validate that the job was scheduled
        List<CronTrigger> scheduledJobs = [SELECT Id, CronExpression, State FROM CronTrigger WHERE State = 'WAITING'];
        System.assert(scheduledJobs.size() > 0, 'The job should be scheduled.');
    }
}