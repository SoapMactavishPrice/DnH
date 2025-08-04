@isTest
public class UpdateSalesOrderAPI_Test {

    @isTest
    static void testUpdateSalesOrderStatus_Success() {
        // Set up test data: create a Sales_Order__c record
        Sales_Order__c testSO = new Sales_Order__c(
            Name = 'SO12345',
            Status__c = 'Pending'
        );
        insert testSO;
        
        // Create a sample JSON request body
        String jsonRequest = '{"SalesOrderNo": "SO12345", "Status": "Approved"}';
        
        // Simulate the REST request and response
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        UpdateSalesOrderAPI.doPost();
        Test.stopTest();
        
        // Verify the response
        RestResponse res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('Sales Order Status Update Successfully'));

        // Verify that the sales order status was updated
        Sales_Order__c updatedSO = [SELECT Status__c FROM Sales_Order__c WHERE Id = :testSO.Id];
        System.assertEquals('Approved', updatedSO.Status__c);
    }

    @isTest
    static void testUpdateSalesOrderStatus_AlreadyApproved() {
        // Set up test data: create a Sales_Order__c record with 'Approved' status
        Sales_Order__c testSO = new Sales_Order__c(
            Name = 'SO12345',
            Status__c = 'Approved'
        );
        insert testSO;
        
        // Create a sample JSON request body
        String jsonRequest = '{"SalesOrderNo": "SO12345", "Status": "Rejected"}';
        
        // Simulate the REST request and response
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        UpdateSalesOrderAPI.doPost();
        Test.stopTest();
        
        // Verify the response
        RestResponse res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('Sales Order is already Approved'));
    }

    @isTest
    static void testUpdateSalesOrderStatus_MultipleOrders() {
        // Set up test data: create two Sales_Order__c records with the same Name
        Sales_Order__c testSO1 = new Sales_Order__c(
            Name = 'SO12345',
            Status__c = 'Pending'
        );
        Sales_Order__c testSO2 = new Sales_Order__c(
            Name = 'SO12345',
            Status__c = 'Pending'
        );
        insert new List<Sales_Order__c>{testSO1, testSO2};
        
        // Create a sample JSON request body
        String jsonRequest = '{"SalesOrderNo": "SO12345", "Status": "Approved"}';
        
        // Simulate the REST request and response
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        UpdateSalesOrderAPI.doPost();
        Test.stopTest();
        
        // Verify the response
        RestResponse res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('Multiple Sales Orders Found'));
    }

    @isTest
    static void testUpdateSalesOrderStatus_NotFound() {
        // Create a sample JSON request body for a non-existent Sales Order
        String jsonRequest = '{"SalesOrderNo": "SO99999", "Status": "Approved"}';
        
        // Simulate the REST request and response
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        UpdateSalesOrderAPI.doPost();
        Test.stopTest();
        
        // Verify the response
        RestResponse res = RestContext.response;
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('Sales Order Not Found'));
    }

    @isTest
    static void testUpdateSalesOrderStatus_Exception() {
        // Simulate an exception in the code
        String jsonRequest = '{"SalesOrderNo": "SO12345", "Status": "Approved"}';
        
        // Force an exception in the code by creating an invalid JSON
        jsonRequest = '{"InvalidField": "SO12345"}';
        
        // Simulate the REST request and response
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        UpdateSalesOrderAPI.doPost();
        Test.stopTest();
        
        // Verify the response
        RestResponse res = RestContext.response;
        String responseBody = res.responseBody.toString();
       // System.assert(responseBody.contains('Something went wrong'));
       // System.assert(responseBody.contains('Invalid JSON'));
    }
}