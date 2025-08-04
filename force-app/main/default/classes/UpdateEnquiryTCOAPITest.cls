@IsTest
private class UpdateEnquiryTCOAPITest {
    @IsTest
    static void testDoPost() {
        // Create test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        Enquiry__c enquiry = new Enquiry__c(
           // Name = 'TestEnquiry',
            Status__c = 'Approved', 
            Account__c = account.Id
        );
        insert enquiry;
        
                string str = [Select Name from Enquiry__c limit 1].Name;


        // Create a mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/UpdateTCOStatus';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"EnquiryNo": "'+str+'", "Status": "Approved"}');
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        UpdateEnquiryTCOAPI.doPost();
        Test.stopTest();

        // Verify the response
        String responseString = res.responseBody.toString();

        // Verify the enquiry status update
        enquiry = [SELECT Status__c FROM Enquiry__c WHERE Id = :enquiry.Id];

        // Verify the API log
        API_Log__c apiLog = [SELECT Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Update_TCOStatus' LIMIT 1];
    }

    @IsTest
    static void testDoPostEnquiryNotFound() {
        // Create a mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/UpdateTCOStatus';
        req.httpMethod = 'POST';
      //  req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{"EnquiryNo": "NonExistentEnquiry", "Status": "Approved"}');
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        UpdateEnquiryTCOAPI.doPost();
        Test.stopTest();

        // Verify the response
        String responseString = res.responseBody.toString();

        // Verify the API log
        API_Log__c apiLog = [SELECT Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Update_TCOStatus' LIMIT 1];
    }

    @IsTest
    static void testDoPostException() {
        // Create test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        Enquiry__c enquiry = new Enquiry__c(
          //  Name = 'TestEnquiry',
            Status__c = 'Approved', 
            Account__c = account.Id
        );
        insert enquiry;
        

        // Create a mock request with invalid JSON to trigger an exception
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/UpdateTCOStatus';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('{ "EnquiryNo": null, "Status": null}');
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        UpdateEnquiryTCOAPI.doPost();
        Test.stopTest();

        // Verify the response
        String responseString = res.responseBody.toString();

        // Verify the API log
        API_Log__c apiLog = [SELECT Log_Status__c, Response_Code__c, Exception_desc__c FROM API_Log__c WHERE Log_Name__c = 'Update_TCOStatus' LIMIT 1];
    }
}