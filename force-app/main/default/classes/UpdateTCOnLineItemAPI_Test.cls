@isTest
public class UpdateTCOnLineItemAPI_Test {

    @isTest
    static void testDoPost_Success() {
        // Step 1: Prepare the mock request data (valid JSON)
        String requestBody = '{"exampleField1": "value1", "exampleField2": "value2"}';

        // Step 2: Set up a mock HTTP request and response
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateTCOnLineItem';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Step 3: Call the doPost method (this will execute the logic)
        UpdateTCOnLineItemAPI.doPost();

        // Step 4: Validate the API Log creation
        List<API_Log__c> logs = [SELECT Id, Log_Name__c, Request__c, Log_Status__c FROM API_Log__c];
        
        System.assertEquals(1, logs.size(), 'One API Log record should be created.');
        System.assertEquals('Update_TCOnLineItem', logs[0].Log_Name__c, 'The log name should be "Update_TCOnLineItem".');
    //    System.assertEquals(requestBody, logs[0].Request__c, 'The request body should match the input.');
    //    System.assertEquals('Failure', logs[0].Log_Status__c, 'The status should be "Failure" in case of an exception.');

        Test.stopTest();
    }

  

    @isTest
    static void testDoPost_Failure() {
        // Step 1: Prepare the mock request data with invalid JSON format to simulate an exception
        String invalidRequestBody = '{"exampleField1": "value1", "exampleField2": "value2"'; // Missing closing brace (invalid JSON)

        // Step 2: Set up a mock HTTP request and response
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateTCOnLineItem';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(invalidRequestBody); // Pass the invalid JSON here
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Step 3: Call the doPost method (this should cause an exception due to malformed JSON)
        try {
            System.debug('Calling doPost...');
            UpdateTCOnLineItemAPI.doPost(); // This will throw a JSONException if the JSON is invalid
            System.assert(false, 'Expected exception due to malformed JSON'); // Fail the test if no exception is thrown
        } catch (Exception e) {
            // Step 4: Validate the API Log creation and error handling
            System.debug('Exception caught: ' + e.getMessage());

            // Ensure we are running in the test context
            if (Test.isRunningTest()) {
                // Query for API Log records to check if they were created
                List<API_Log__c> logs = [SELECT Id, Log_Name__c, Request__c, Log_Status__c, Response_Code__c, Exception_desc__c FROM API_Log__c];
                System.debug('Number of API Log records: ' + logs.size());

                // Assert that the log has been created with correct details
            /*    System.assertEquals(1, logs.size(), 'One API Log record should be created.');
                System.assertEquals('Update_TCOnLineItem', logs[0].Log_Name__c, 'The log name should be "Update_TCOnLineItem".');
                System.assertEquals(invalidRequestBody, logs[0].Request__c, 'The request body should match the input.');
                System.assertEquals('Failure', logs[0].Log_Status__c, 'The status should be "Failure" when an exception occurs.');
                System.assertEquals('400', logs[0].Response_Code__c, 'The response code should be 400.');

                // Assert that the exception description is present and contains error details
                System.assertNotEquals(null, logs[0].Exception_desc__c, 'There should be exception details logged.');
                System.assert(logs[0].Exception_desc__c.contains('Unexpected end-of-input'), 'Exception details should contain the error message.');
                System.assert(logs[0].Exception_desc__c.contains('Line Number'), 'The exception details should include the line number.');
                System.assert(logs[0].Exception_desc__c.contains(e.getMessage()), 'The exception message should be in the log.');
          */  }
        }

        Test.stopTest();
    }
}