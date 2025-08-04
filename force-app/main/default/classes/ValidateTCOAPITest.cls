@isTest
public class ValidateTCOAPITest {

    @isTest
    static void testValidateTCO_Success() {
        // Create test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        Enquiry__c enquiry = new Enquiry__c(Account__c = account.Id);
        insert enquiry;

        Item_Master__c item = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (NORMA-V)');
        insert item;

          Enquiry_Line_Item__c enquiryLine = new Enquiry_Line_Item__c(Enquiry__c = enquiry.Id, Item_Master__c = item.Id);
        insert enquiryLine;
    //    insert enquiryLine;
		
        string str = [Select Name from Enquiry_Line_Item__c limit 1].Name;
        // Mock request and response
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ValidateTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"TechnoLineNo": "'+str+'", "CustomerNo": "' + account.Id + '"}');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        ValidateTCOAPI.doPost();

        // Assert success response
        String responseBody = res.responseBody.toString();
   //     System.assertEquals(200, res.statusCode);
   //     System.assert(responseBody.contains('"status":"success"'), 'Response should indicate success');
    //    System.assert(responseBody.contains('"Qty":100'), 'Response should contain correct Qty');
    }

    @isTest
    static void testValidateTCO_LineItemNotFound() {
        // Create test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Mock request and response
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ValidateTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"TechnoLineNo": "InvalidLineItem", "CustomerNo": "' + account.Id + '"}');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        ValidateTCOAPI.doPost();

        // Assert failure response
        String responseBody = res.responseBody.toString();
        System.assertEquals(404, res.statusCode);
        System.assert(responseBody.contains('"status":"fail"'), 'Response should indicate failure');
        System.assert(responseBody.contains('"TechnoLineNo Not found"'), 'Response should indicate line item not found');
    }

    @isTest
    static void testValidateTCO_MissingFields() {
        // Mock request and response
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ValidateTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{}'); // Missing required fields
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        ValidateTCOAPI.doPost();

        // Assert failure response
        String responseBody = res.responseBody.toString();
        System.assertEquals(400, res.statusCode);
        System.assert(responseBody.contains('"status":"fail"'), 'Response should indicate failure');
        System.assert(responseBody.contains('"TechnoLineNo and CustomerNo is Required"'), 'Response should indicate missing fields');
    }

 /*   @isTest
    static void testValidateTCO_InvalidJSON() {
        // Mock request and response
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ValidateTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('Invalid JSON'); // Invalid JSON format
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method
        ValidateTCOAPI.doPost();

        // Assert failure response due to JSON parsing error
        String responseBody = res.responseBody.toString();
        System.assertEquals(400, res.statusCode);
        System.assert(responseBody.contains('"Something went wrong"'), 'Response should indicate an error');
    }*/
}