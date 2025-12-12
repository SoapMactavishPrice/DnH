@isTest
public class S7_SalesInvoiceHeader_Test {
    // Custom Mock Exception
    public class S7_SalesInvoiceHeaderMock_Exception extends Exception {}

    @isTest
    static void testGetInvoiceList() {
        // Mock data setup
        User testUser = new User(
            Username = 'Shrivastav@test.com',
            Email = 'testuser34@test.com',
            LastName = 'Test',
            Alias = 'test',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Code__c = 'DNH1974'
        );
        insert testUser;

        // Log in as the test user
        System.runAs(testUser) {
            // Mock API response using HttpCalloutMock
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

            Test.startTest();
            S7_SalesInvoiceHeader.getInvoiceList('2023-01-01', '2023-01-31', 'DNH1974');
            Test.stopTest();

            // Assert the result
            // System.assertEquals('OK', result, 'The response should be OK');
        }

        // Verify API_Log__c records
        List<API_Log__c> logs = [SELECT Id, Log_Name__c, Log_Status__c FROM API_Log__c];
        // System.assertEquals(1, logs.size(), 'One log record should be created.');
        // System.assertEquals('S7_SalesInvoice_Header', logs[0].Log_Name__c, 'Log name should match.');
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Validate the request
        // System.assertEquals('POST', req.getMethod(), 'Request method should be POST');
        // System.assert(req.getBody().contains('<sal:startDate>'), 'Request body should contain start date');
        // System.assert(req.getBody().contains('<sal:endDate>'), 'Request body should contain end date');

        // Mock response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '  <soapenv:Body>' +
            '    <InsertGetSalesInvoiceHeaderServices7_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
            '     <return_value>1</return_value>' +
            '     <returnValue>[{"DocNo": "1SAAC1/03927","CustomerNo": "CUS0018010","CustomerName": "FOR SELF SAMPLING","EndCustomerName": "L&amp;T","ShiptoCustomerName": "","FieldEngineer": "DNH1974","AreaManager": "DNH1078","ZonalManager": "","InvoiceDate": "2023/02/09","DocketNo": "TEST 090223","DocketDate": "2023/02/09"}]</returnValue>' +
            '    </InsertGetSalesInvoiceHeaderServices7_Result>' +
            '  </soapenv:Body>' +
            '</soapenv:Envelope>'
        );
        return res;
    }
}

    
}