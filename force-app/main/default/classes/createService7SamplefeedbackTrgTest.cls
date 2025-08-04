@isTest
public class createService7SamplefeedbackTrgTest {

    @isTest
    static void testHandleAfterInsert() {
        Code_Master__c codeMaster = new Code_Master__c(
            Name = 'Sample Feedback',
            Object__c = 'Service 7-(Sample Feedbacks)',
            Current_Sequence__c = 1,
            Starting_Sequence__c = 1,
            FY_Start_Date__c = Date.today().addDays(-30),
            FY_End_Date__c = Date.today().addDays(30)
        );
        insert codeMaster;

        Service_5_Sample_Request__c sampleRequest = new Service_5_Sample_Request__c(
            Name = 'Sample Request 1'
        );
        insert sampleRequest;

        Item_Master__c item1 = new Item_Master__c(
            Name = 'AUTOTHERME GRADE-B 2.00 MM - 25KGS - REG'
        );
        Item_Master__c item2 = new Item_Master__c(
            Name = 'ULTRATENSAL-MH 2.50 X 350 MM - 100PCS - HDPE'
        );
        insert new List<Item_Master__c>{ item1, item2 };

        List<Sample_Request_Product__c> sampleRequests = new List<Sample_Request_Product__c>{
            new Sample_Request_Product__c(
                Sample_Request__c = sampleRequest.Id,
                Item_No__c = item1.Id,
                Description__c = 'Sample Item 1',
                Brand_Name__c = 'None',
                Quantity__c = 10,
                UOM__c = 'BOX'
            ),
            new Sample_Request_Product__c(
                Sample_Request__c = sampleRequest.Id,
                Item_No__c = item2.Id,
                Description__c = 'Sample Item 2',
                Brand_Name__c = 'None',
                Quantity__c = 20,
                UOM__c = 'BOX'
            )
        };
        insert sampleRequests;

        Test.startTest();
        createService7SamplefeedbackTrigHandler.handleAfterInsert(sampleRequests);
        Test.stopTest();

        List<Service_7_Sample_Feedbacks__c> feedbacks = [
            SELECT Id, Name, Sample_Request_Product__c, Item_No__c, Item_Description__c, Brand_Name__c, Size_mm__c, Qty_Pcs_Kgs__c, UOM__c
            FROM Service_7_Sample_Feedbacks__c
        ];

        Integer feedbackCount = feedbacks.size();
        for (Integer i = 0; i < feedbackCount; i++) {
          //  Service_7_Sample_Feedbacks__c feedback = feedbacks[i];
          //  Sample_Request_Product__c srp = sampleRequests[i];
        }

        Code_Master__c updatedCodeMaster = [SELECT Current_Sequence__c FROM Code_Master__c WHERE Id = :codeMaster.Id];
    }
}