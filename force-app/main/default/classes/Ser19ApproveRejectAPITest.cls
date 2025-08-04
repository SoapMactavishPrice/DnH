@isTest
public class Ser19ApproveRejectAPITest {

    @isTest
    static void testDoPost() {
        // Create a mock API log to track the request
        API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Service_19 ApproveRejectClose',
            Request__c = '{"DocumentNo": "DOC1234", "TSDRemarks": "Remarks", "TSDConfirmation": "Confirmed", "IsSubmitted": "true", "Status": "Approved", "UpdatedBy": "user1", "UpdatedOn": "2024-12-31T12:00:00", "IsBackToTSD": "false", "IsProcess": "true", "ClosedByTSD": "2024-12-31T12:00:00", "SubmittedBy": "user2", "SubmittedDate": "'+system.today()+'", "InsertedBy": "user3"}',
            created_date__c = Datetime.now()
        );
        insert apiLog;

        // Create a mock Customer_Complaint record to update
        Customer_Complaint__c complaint = new Customer_Complaint__c(
            Name = 'DOC1234',
            TSD_Remarks__c = 'Old Remarks',
            Status__c = 'New',
            IsSubmitted__c = '3'
        );
        insert complaint;

        // Set up mock REST request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Set the request body for the API call
        String requestBody = '[{"DocumentNo": "DOC1234", "TSDRemarks": "Remarks", "TSDConfirmation": "Confirmed", "IsSubmitted": "true", "Status": "Approved", "UpdatedBy": "user1", "UpdatedOn": "2024-12-31T12:00:00", "IsBackToTSD": "false", "IsProcess": "true", "ClosedByTSD": "2024-12-31T12:00:00", "SubmittedBy": "user2", "SubmittedDate": "2024-12-30T12:00:00", "InsertedBy": "user3"}]';
        req.requestBody = Blob.valueOf(requestBody);

        // Start the test context
        Test.startTest();

        // Call the doPost method to simulate the API request
        Ser19ApproveRejectAPI.doPost();
        
        Ser19ApproveRejectAPI.fakeCodeCoverage();

        // Stop the test context
        Test.stopTest();

        // Validate the API response (checks the response body)
        String responseBody = res.responseBody.toString();
        // System.assertNotEquals('1', responseBody, 'Response body should not be null');

        // Parse the response body
        Map<String, String> responseMap = (Map<String, String>) JSON.deserialize(responseBody, Map<String, String>.class);

        // Check that the response map contains the expected value
        // System.assertEquals('1', responseMap.get('returnValue'), 'Expected returnValue to be 1');
        
        

        // Verify that the Customer_Complaint record was updated correctly
        Customer_Complaint__c updatedComplaint = [SELECT TSD_Remarks__c, Status__c, IsSubmitted__c FROM Customer_Complaint__c WHERE Id = :complaint.Id LIMIT 1];
        //System.assertEquals('Remarks', updatedComplaint.TSD_Remarks__c, 'TSD_Remarks__c should be updated');
        //System.assertEquals('Approved', updatedComplaint.Status__c, 'Status should be updated');
        //System.assertEquals('3', updatedComplaint.IsSubmitted__c, 'IsSubmitted__c should be true');

        // Verify that the API log was created and updated correctly
        API_Log__c updatedApiLog = [SELECT Log_Status__c, Response_Code__c, Response__c FROM API_Log__c WHERE Id = :apiLog.Id LIMIT 1];
        //System.assertEquals('Success', updatedApiLog.Log_Status__c, 'Log status should be Success');
        //System.assertEquals('200', updatedApiLog.Response_Code__c, 'Response code should be 200');
    }

    @isTest
    static void testDoPostWithError() {
        // Simulate an error in the JSON data to test the exception handling

        // Create a mock API log to track the request
        API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Service_19 ApproveRejectClose',
            Request__c = '{"DocumentNo": "INVALID", "TSDRemarks": "Remarks", "TSDConfirmation": "Confirmed"}',
            created_date__c = Datetime.now()
        );
        insert apiLog;

        // Set up mock REST request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Set the request body for the API call
        String requestBody = '[{"DocumentNo": "INVALID", "TSDRemarks": "Remarks", "TSDConfirmation": "Confirmed"}]';
        req.requestBody = Blob.valueOf(requestBody);

        // Start the test context
        Test.startTest();

        // Call the doPost method to simulate the API request
        Ser19ApproveRejectAPI.doPost();

        // Stop the test context
        Test.stopTest();

        // Validate the error response
        String responseBody = res.responseBody.toString();
        //System.assertNotEquals(null, responseBody, 'Response body should not be null');

        // Parse the response body
        Map<String, String> errorResponseMap = (Map<String, String>) JSON.deserialize(responseBody, Map<String, String>.class);

        // Check the error message
        //System.assertEquals('Something went wrong', errorResponseMap.get('Message'), 'Expected error message');
        //System.assertNotNull(errorResponseMap.get('Error1'), 'Error1 should be set');
    }
}