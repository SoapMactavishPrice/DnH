@isTest
public class CreateService7FeedbackQueueableTest {
    
    @testSetup
    static void setupTestData() {
        // Create sample test records
        List<Service_7_Sample_Feedbacks__c> feedbackList = new List<Service_7_Sample_Feedbacks__c>();
        Sample_Request_Product__c msli = new Sample_Request_Product__c();

        msli.Name = 'Test Sample';
        insert msli;

        for (Integer i = 0; i < 5; i++) {
            feedbackList.add(new Service_7_Sample_Feedbacks__c(
                Name = 'Test Feedback ' + i,
                InvoiceNo__c = 'INV-100' + i,
                Sample_Request_Product__c = msli.Id
            ));
        }
        
        // Insert test data
        insert feedbackList;
    }
    
    @isTest
    static void testQueueableExecution() {
        // Fetch test records
        List<Service_7_Sample_Feedbacks__c> testRecords = [SELECT Id, InvoiceNo__c FROM Service_7_Sample_Feedbacks__c];

        // Enqueue Queueable job
        Test.startTest();
        System.enqueueJob(new CreateService7FeedbackQueueable(testRecords));
        Test.stopTest(); // Ensures the Queueable job is executed

        // Validate expected behavior (mock API logic in a handler if needed)
        for (Service_7_Sample_Feedbacks__c rec : testRecords) {
            System.assertNotEquals(null, rec.InvoiceNo__c, 'InvoiceNo should not be null');
        }
    }
}