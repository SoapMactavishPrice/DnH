@isTest
public class SampleOrderTriggerTest {
    @testSetup
    static void setup() {
        // Create test data for Service_5_Sample_Request__c
        List<Service_5_Sample_Request__c> sampleRequests = new List<Service_5_Sample_Request__c>();

        for (Integer i = 1; i <= 5; i++) {
            sampleRequests.add(new Service_5_Sample_Request__c(
                Name = 'Sample Request ' + i,
                Status__c = 'Draft By Sales Person',
                Sample_Order_Number__c = null
            ));
        }

        insert sampleRequests;
    }

    @isTest
    static void testTriggerWithValidSampleOrderNumber() {
        // Fetch the sample records created in the setup
        List<Service_5_Sample_Request__c> sampleRequests = [SELECT Id, Status__c, Sample_Order_Number__c FROM Service_5_Sample_Request__c];

        // Update the Status__c to 'Approved by TSD Exe' and add a valid Sample_Order_Number__c
        for (Service_5_Sample_Request__c request : sampleRequests) {
            request.Status__c = 'Approved by TSD Exe';
            request.Sample_Order_Number__c = 'SMO/12345';
        }

        Test.startTest();

        // Mock the CreateSampleRequest_ToNav methods
        //CreateSampleRequest_ToNav mockNav = new CreateSampleRequest_ToNav();
        //Test.setMock(CreateSampleRequest_ToNav.class, mockNav);

        // Update the records
        update sampleRequests;

        Test.stopTest();

        // Assertions (replace with your mock assertions if applicable)
        System.assertEquals('Approved by TSD Exe', sampleRequests[0].Status__c);
        // Add additional asserts to verify the behavior
    }

    @isTest
    static void testTriggerWithoutValidSampleOrderNumber() {
        // Fetch the sample records created in the setup
        List<Service_5_Sample_Request__c> sampleRequests = [SELECT Id, Status__c, Sample_Order_Number__c FROM Service_5_Sample_Request__c];

        // Update the Status__c to 'Approved by TSD Exe' without a valid Sample_Order_Number__c
        for (Service_5_Sample_Request__c request : sampleRequests) {
            request.Status__c = 'Approved by TSD Exe';
            request.Sample_Order_Number__c = 'InvalidSampleNumber';
        }

        Test.startTest();

        // Mock the CreateSampleRequest_ToNav methods
        //CreateSampleRequest_ToNav mockNav = new CreateSampleRequest_ToNav();
        //Test.setMock(CreateSampleRequest_ToNav.class, mockNav);

        // Update the records
        update sampleRequests;

        Test.stopTest();

        // Assertions (replace with your mock assertions if applicable)
        System.assertEquals('Approved by TSD Exe', sampleRequests[0].Status__c);
        // Add additional asserts to verify the behavior
    }
}