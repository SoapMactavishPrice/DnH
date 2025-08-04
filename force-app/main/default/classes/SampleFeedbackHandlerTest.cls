@isTest
public class SampleFeedbackHandlerTest {

    @isTest
    static void testHandleAfterInsert() {
        
      //  Sample_Request__c sampleRequest = new Sample_Request__c();
      //  insert sampleRequest;

        
        City__c ct = new City__c();
        ct.Name = 'Navi Mumbai';
        insert ct;

        Service_5_Sample_Request__c sampleRequest = new Service_5_Sample_Request__c(
            Name = 'SF-Ser5/2425/000097',
            Customer_Name__c = 'patiln',
            Address_1__c = 'Mumbai Highway',
            Address_2__c = 'Mumbai Highway',
            City__c = ct.id,
            Remark__c = 'Test Remark',
            Submitted_Date__c = Date.Parse('02/12/2024'),
            Status__c = 'Draft By Sales Person',
            Postal_Code__c = '422098'
        );
        insert sampleRequest;

        
        Code_Master__c codeMaster = new Code_Master__c(
            Object__c = 'Service 7-(Sample Feedbacks)',
            FY_End_Date__c =  date.today().addDays(10),
            FY_Start_Date__c =  date.today().addDays(-1),
            Current_Sequence__c = 1
            
        );
        insert codeMaster;
        
        List<Sample_Request_Product__c> sampleProducts = new List<Sample_Request_Product__c>();
        Sample_Request_Product__c srp = new Sample_Request_Product__c(
            Name = 'Sample Product',
         //   Item_No__c = 'a04F300000Gk9ahIAB',
            Description__c = 'Description for Item',
            Brand_Name__c = 'None',
            Sample_Request__c = sampleRequest.Id,
            Size_mm__c = '2.50 X 350 MM',
           // Sample_Request__c = 'a0VF3000003Wa63MAC',
            UOM__c = 'KGS'
        );
        sampleProducts.add(srp);
        insert sampleProducts;

        Test.startTest();
        createService7SamplefeedbackTrigHandler.handleAfterInsert(sampleProducts);
        Test.stopTest();

        //List<Service_7_Sample_Feedbacks__c> feedbacks = [SELECT Id, Name, Sample_Request_Product__c, Item_No__c, Item_Description__c, Brand_Name__c, Size_mm__c, Qty_Pcs_Kgs__c, UOM__c FROM Service_7_Sample_Feedbacks__c];
    }
}