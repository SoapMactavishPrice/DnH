@IsTest
private class CreateCustomerComplaintAPITest {
    @IsTest
    static void testDoPost() {
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'Test Invoice';
        insert invoice;

        Customer_Complaint__c com1 = new Customer_Complaint__c();
        com1.End_Customer_Name__c = account.Id;
        com1.Invoice__c = invoice.Id;
        com1.Brand_Name__c = 'Brand A';
        com1.Batch_No__c = 'Batch 001';
        com1.Type_Of_Complaints__c = 'Rejected Material';
        com1.Date__c = Date.valueOf('2023-12-10');
        insert com1;
        
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master');
        insert itemMaster;
        
        // Create a mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        
        // Create a sample JSON request body
        String jsonBody = '{"Invoice":"'+invoice.id+'","Dealer_Name":"'+account.Id+'","cDate":"2023-12-10","End_Customer_Name":"'+account.Id+'","Item_No":"'+itemMaster.Id+'","Batch_No":"Batch123","Batch_Quantity":"100","UOM":"pcs","Brand_Name":"Brand1","Mfg_Date":"2023-01-01","Complaint_Quantity":"10","Size_mm":"5","Type_Of_Complaints":"Type1","Verification_End_To_Customer":"Yes","Field_Engineer_Name":"'+userInfo.getUserId()+'","Zonal_Head":"'+userInfo.getUserId()+'","Entry_Type":"TypeA","Recommendations":"None","Area_Manager":"'+userInfo.getUserId()+'","Field_Engineer_Remarks":"Remarks1","TSD_Remarks":"TSD1"}';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';

        // Call the method
        Test.startTest();
        CreateCustomerComplaintAPI.doPost();
        Test.stopTest();

        // Verify the response
        String responseBody = res.responseBody.toString();

        // Verify the record was created
        List<Customer_Complaint__c> complaints = [SELECT Id, Invoice__c, Dealer_Name__c, Date__c, Batch_Quantity__c, Complaint_Quantity__c FROM Customer_Complaint__c];

        // Verify the API log was created
        List<API_Log__c> logs = [SELECT Id, Log_Name__c, Log_Status__c FROM API_Log__c WHERE Log_Name__c = 'CreateCustomerComplaint'];
    }

    /*@IsTest
    static void testDoPostWithError() {
        // Create a mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Create a sample JSON request body with an invalid date
        String jsonBody = '{"Invoice":"INV123","Dealer_Name":"Dealer1","cDate":"invalid-date","End_Customer_Name":"Customer1","Item_No":"Item123","Batch_No":"Batch123","Batch_Quantity":"100","UOM":"pcs","Brand_Name":"Brand1","Mfg_Date":"2023-01-01","Complaint_Quantity":"10","Size_mm":"5","Type_Of_Complaints":"Type1","Verification_End_To_Customer":"Yes","Field_Engineer_Name":"Engineer1","Zonal_Head":"Head1","Entry_Type":"TypeA","Recommendations":"None","Area_Manager":"Manager1","Field_Engineer_Remarks":"Remarks1","TSD_Remarks":"TSD1"}';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';

        // Call the method
        Test.startTest();
        CreateCustomerComplaintAPI.doPost();
        Test.stopTest();

        // Verify the response
        String responseBody = res.responseBody.toString();

        // Verify the API log was created
        List<API_Log__c> logs = [SELECT Id, Log_Name__c, Log_Status__c FROM API_Log__c WHERE Log_Name__c = 'CreateCustomerComplaint'];
    }
*/}