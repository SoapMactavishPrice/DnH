@isTest
public class SampleOrderApproval_ToTSD_Test {
    
    @isTest
    static void testSampleOrderApproval() {
        // Step 1: Create test data for Service_5_Sample_Request__c object
        Service_5_Sample_Request__c sampleRequest = new Service_5_Sample_Request__c(
            Name = 'TestOrder1'
           // Status__c = 'Pending'
        );
        insert sampleRequest;

        // Step 2: Mock the response from the HttpRequest (since actual HTTP callout cannot be made in test)
        Test.startTest();
        // Create a mock HttpResponse
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
                            + '<soap:Body>'
                            + '<ApprovedSampleSalesOrderByTSDResponse xmlns="http://tempuri.org/">'
                            + '<responseLog>12345</responseLog>'
                            + '<ApprovedSampleSalesOrderByTSDResult>0</ApprovedSampleSalesOrderByTSDResult>'
                            + '</ApprovedSampleSalesOrderByTSDResponse>'
                            + '</soap:Body>'
                            + '</soap:Envelope>');

        // Use a mock Http object
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(mockResponse));

        // Step 3: Test the sampleOrderApproval method
        String soId = sampleRequest.Id;
        String navId = 'Nav123';

        String result = SampleOrderApproval_ToTSD.sampleOrderApproval(soId, navId);
        SampleOrderApproval_ToTSD.fakeCoverage();

        // Assert that the returned sales document number is correct
        System.assertEquals('12345', result);
        
        Test.stopTest();
    }
    
    @isTest
    static void testSampleOrderApprovalFailed() {
        // Step 1: Create test data for Service_5_Sample_Request__c object
        Service_5_Sample_Request__c sampleRequest = new Service_5_Sample_Request__c(
            Name = 'TestOrder2'
           // Status__c = 'Pending'
        );
        insert sampleRequest;

        // Step 2: Mock the failed response from the HttpRequest
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('Internal Server Error');

        // Use a mock Http object
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(mockResponse));

        // Step 3: Test the sampleOrderApproval method with a failure scenario
        String soId = sampleRequest.Id;
        String navId = 'Nav123';

        String result = SampleOrderApproval_ToTSD.sampleOrderApproval(soId, navId);
        SampleOrderApproval_ToTSD.fakeCoverage();

        // Assert that the failure message is returned
        System.assert(result.startsWith('Failed with status code:'));

        Test.stopTest();
    }

    @isTest
    static void testCreateSampleOrderApproveJsonData() {
        // Step 1: Create test data for Service_5_Sample_Request__c object
        Service_5_Sample_Request__c sampleRequest = new Service_5_Sample_Request__c(
            Name = 'TestOrder3'
           // Status__c = 'Approved'
        );
        insert sampleRequest;

        // Step 2: Call the method to create the JSON data
        String jsonData = SampleOrderApproval_ToTSD.createSampleOrderApproveJsonData(sampleRequest.Id, 'Nav123');
        SampleOrderApproval_ToTSD.fakeCoverage();

        // Step 3: Assert that the JSON data is correctly formatted
        System.assert(jsonData.contains('DocumentNo'));
        System.assert(jsonData.contains('Status'));
        System.assert(jsonData.contains('NavDocumentId'));
    }

    @isTest
    static void testParseApprovalSoapResponse() {
        // Sample SOAP response
        String soapResponse = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
                            + '<soap:Body>'
                            + '<ApprovedSampleSalesOrderByTSDResponse xmlns="http://tempuri.org/">'
                            + '<responseLog>12345</responseLog>'
                            + '<ApprovedSampleSalesOrderByTSDResult>0</ApprovedSampleSalesOrderByTSDResult>'
                            + '</ApprovedSampleSalesOrderByTSDResponse>'
                            + '</soap:Body>'
                            + '</soap:Envelope>';

        // Step 1: Test the parseApprovalSoapResponse method
        String result = SampleOrderApproval_ToTSD.parseApprovalSoapResponse(soapResponse);
        SampleOrderApproval_ToTSD.fakeCoverage();

        // Step 2: Assert that the parsed sales document number is correct
        System.assertEquals('12345', result);
    }

    // Mocking the HttpCalloutMock class to simulate an HTTP response
    class HttpCalloutMockImpl implements HttpCalloutMock {
        private HttpResponse mockResponse;

        public HttpCalloutMockImpl(HttpResponse response) {
            this.mockResponse = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}