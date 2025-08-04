@isTest
public class IndiaMart_Scheduler_Test {
    @isTest
    static void testSchedulerExecution() {
        // Schedule the job
        String cronExp = '0 0 12 * * ?'; // Every day at 12 PM
        Test.startTest();
        String jobId = System.schedule('Test IndiaMart Scheduler', cronExp, new IndiaMart_Scheduler());
        Test.stopTest();

        // System.assertNotEquals(null, jobId, 'Job Id should not be null after scheduling');
    }
}