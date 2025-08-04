@isTest
public class addService7SampleRequestcontrollerTest {

    @isTest
    public static void testGetSampleFeedbacks() {
        
        Sam_Req_Brand_Name__c srbn = new Sam_Req_Brand_Name__c();
        srbn.Name = 'ABC';
        srbn.Code__c = 'AUTOTHERME -410L';
        insert srbn;
        
        Service_5_Sample_Request__c sampleRequest = new Service_5_Sample_Request__c(
            Customer_Name__c = 'Test Customer',
            Address_1__c = 'Test Address 1',
            Address_2__c = 'Test Address 2',
            Name = 'Sample Request 2'
        );
        insert sampleRequest;

        Sample_Request_Product__c product1 = new Sample_Request_Product__c(
            Sample_Request__c = sampleRequest.Id,
            Quantity_2__c = '20',
            Sam_Req_Brand_Name__c = srbn.Id
        );
        insert product1;
                
        Service_7_Sample_Feedbacks__c feedback = new Service_7_Sample_Feedbacks__c();
        feedback.Sample_Request_Product__c = product1.id;
        insert feedback;

        List<Id> feedbackIds = new List<Id>{feedback.Id};
        List<Service_7_Sample_Feedbacks__c> results = addService7SampleRequestcontroller.getSampleFeedbacks(feedbackIds);
    }
}