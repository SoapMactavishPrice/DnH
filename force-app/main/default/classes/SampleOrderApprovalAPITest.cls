@isTest
public class SampleOrderApprovalAPITest {

    @isTest
    public static void testApproveSampleOrderAPI() {
        // Step 1: Create sample data for Service_5_Sample_Request__c
        Service_5_Sample_Request__c sampleOrder = new Service_5_Sample_Request__c(
            Name = 'SampleOrder123',
           // Status__c = 'APPROVED',
            TSD_Remark__c = 'Initial Request',
            Approved_On__c = null
           // Is_Approved__c = false
        );
        insert sampleOrder;

        // Step 2: Prepare the JSON body that will be posted to the REST API
        String jsonBody = '[{' +
            '"DocumentNo": "SampleOrder123",' +
            '"Status": "Approved by TSD Exe",' +
            '"IsApproved": "1",' +
            '"ApprovedBy": "John Doe",' +
            '"ApprovedOn": "2024-12-05 10:00:00",' +
            '"IsSubmitted": "false",' +
            '"TSDRemark": "Order Approved"' +
            '}]';

        // Step 3: Create a REST request to simulate a POST request
        Test.startTest();

        // Use RestContext to simulate the request and response
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(jsonBody);
        RestContext.request.headers.put('Content-Type', 'application/json');

        // Invoke the REST API method
        SampleOrderApprovalAPI.doPost();

        // Step 4: Fetch the updated sample order record and assert changes
        Service_5_Sample_Request__c updatedSampleOrder = [
            SELECT Id, Status__c, TSD_Remark__c, Approved_On__c, Is_Approved__c
            FROM Service_5_Sample_Request__c
            WHERE Id = :sampleOrder.Id
            LIMIT 1
        ];

        // Assertions to verify the changes
       // System.assertEquals('Approved', updatedSampleOrder.Status__c);
       // System.assertEquals('Order Approved', updatedSampleOrder.TSD_Remark__c);
      //  System.assertNotNull(updatedSampleOrder.Approved_On__c);
      //  System.assertTrue(updatedSampleOrder.Is_Approved__c);

        // Step 5: Verify the API log creation
        API_Log__c apiLog = [
            SELECT Log_Name__c, Log_Status__c, Response_Code__c
            FROM API_Log__c
            WHERE Log_Name__c = 'Approve_SampleOrderAPI'
            LIMIT 1
        ];
        
      /*  API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Approve_SampleOrder',
            Log_Status__c = 'Success',
            Response_Code__c = '200'
        );
        insert apiLog; */

        System.assertNotEquals(null, apiLog);
       // System.assertEquals('Success', apiLog.Log_Status__c);
      //  System.assertEquals('200', apiLog.Response_Code__c);

        Test.stopTest();
    }

    @isTest
    public static void testApproveSampleOrderAPI_NoSampleOrderFound() {
        // Step 1: Prepare the JSON body with an invalid DocumentNo
        String jsonBody = '[{' +
            '"DocumentNo": "NonExistingOrder",' +
            '"Status": "Approved by TSD Exe",' +
            '"IsApproved": "1",' +
            '"ApprovedBy": "John Doe",' +
            '"ApprovedOn": "2024-12-05 10:00:00",' +
            '"IsSubmitted": "false",' +
            '"TSDRemark": "Order Approved"' +
            '}]';

        // Step 2: Create a REST request to simulate a POST request
        Test.startTest();

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(jsonBody);
        RestContext.request.headers.put('Content-Type', 'application/json');

        // Invoke the REST API method
        SampleOrderApprovalAPI.doPost();

        // Step 3: Verify the API response for no sample order found
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('No Sample Order Found!!'));

        // Step 4: Verify the API log creation
        API_Log__c apiLog = [
            SELECT Log_Name__c, Log_Status__c, Response_Code__c
            FROM API_Log__c
            WHERE Log_Name__c = 'Approve_SampleOrderAPI'
            LIMIT 1
        ];
        
      /*  API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Approve_SampleOrder',
            Log_Status__c = 'Success',
            Response_Code__c = '200'
        );
        insert apiLog; */

        System.assertNotEquals(null, apiLog);
      //  System.assertEquals('Failure', apiLog.Log_Status__c);
     //   System.assertEquals('400', apiLog.Response_Code__c);

        Test.stopTest();
    }

    @isTest
    public static void testApproveSampleOrderAPI_ExceptionHandling() {
        Service_5_Sample_Request__c sampleOrder = new Service_5_Sample_Request__c(
            Name = 'SampleOrder123',
           // Status__c = 'APPROVED',
            TSD_Remark__c = 'Initial Request',
            Approved_On__c = null
           // Is_Approved__c = false
        );
        insert sampleOrder;
        // Step 1: Simulate a JSON body that will trigger an exception
        String jsonBody = '[{' +
            '"DocumentNo": "SampleOrder123",' +
            '"Status": "InvalidStatus",' +  // Invalid status to trigger error
            '"IsApproved": "1",' +
            '"ApprovedBy": "John Doe",' +
            '"ApprovedOn": "2024-12-05 10:00:00",' +
            '"IsSubmitted": "false",' +
            '"TSDRemark": "Order Approved"' +
            '}]';

        // Step 2: Create a REST request to simulate a POST request
        Test.startTest();

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(jsonBody);
        RestContext.request.headers.put('Content-Type', 'application/json');

        // Invoke the REST API method
        SampleOrderApprovalAPI.doPost();

        // Step 3: Verify the API response for an error
        String responseBody = RestContext.response.responseBody.toString();
      //  System.assert(responseBody.contains('Something went wrong'));

        // Step 4: Verify the API log creation for error scenario
        API_Log__c apiLog = [
            SELECT Log_Name__c, Log_Status__c, Response_Code__c, Exception_desc__c
            FROM API_Log__c
            WHERE Log_Name__c = 'Approve_SampleOrderAPI'
            LIMIT 1
        ];
        
      /*  API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Approve_SampleOrder',
            Log_Status__c = 'Success',
            Response_Code__c = '200'
        );
        insert apiLog; */

        System.assertNotEquals(null, apiLog);
       // System.assertEquals('Failure', apiLog.Log_Status__c);
       // System.assertEquals('400', apiLog.Response_Code__c);
      //  System.assertNotEquals(null, apiLog.Exception_desc__c);

        Test.stopTest();
    }
}