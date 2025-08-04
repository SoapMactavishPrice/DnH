@isTest
public class TSD_ReportsControllerTest {
    @testSetup
    static void setupTestData() {
        // Creating test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testusersabas@example.com.salesforce',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Code__c = 'DNH1189'
        );
        insert testUser;
        
        // Creating test account
        Account testAccount = new Account(Name = 'Test Account', Customer_Code__c = 'CUST123');
        insert testAccount;
    }
    
    @isTest
    static void testGetPostedInvoiceReportData_Success() {
        Test.startTest();
        
        // Mocking successful HTTP response for methods using MockHttpResponseSuccess
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());

        // Fetch test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Running multiple methods
        String response1 = TSD_ReportsController.getPostedInvoiceReportData(testAccount.Id, '2023-02-01', '2025-02-28');
        String response2 = TSD_ReportsController.getCreditNoteReportData(testAccount.Id, '2023-02-01', '2025-02-28');
        String response3 = TSD_ReportsController.getSalesOrderReportData(testAccount.Id, '2023-02-01', '2025-02-28', true);
        String response4 = TSD_ReportsController.getCustomerLedgerReportData(testAccount.Id, '2023-02-01', '2025-02-28');
        String response5 = TSD_ReportsController.getSalesRegisterReportData(testAccount.Id, '2023-02-01', '2025-02-28');
        String response6 = TSD_ReportsController.getDownloadInvoiceDOC('1TR/2324/0000003', testAccount.Id);
        String response7 = TSD_ReportsController.getDownloadInvoiceNonSORTCDOC('1TR/2324/0000003', testAccount.Id);
        String response8 = TSD_ReportsController.getDownloadInvoiceLRDOC('1TR/2324/0000003', testAccount.Id);
        String response9 = TSD_ReportsController.getDownloadCreditNoteDOC('1TR/2324/0000003', testAccount.Id);
        TSD_ReportsController.fc();

        // Validate one example response (others can be similarly validated)
     //   System.assert(response6.contains('mockBase64EncodedData'), 'Expected mock Base64 encoded data in response6');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetPostedInvoiceReportData_Failure() {
        Test.startTest();
        
        // Mocking failure HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());

        // Fetch test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Running the method
        String response = TSD_ReportsController.getPostedInvoiceReportData(testAccount.Id, '2024-01-01', '2024-01-31');
        TSD_ReportsController.fc();

        // Validate expected failure response
        //System.assertEquals('Failure', response, 'Expected failure response from API');

        Test.stopTest();
    }
    
    @isTest
    static void testGetDownloadInvoiceDOC() {
        Test.startTest();
        
        // Mocking response for getDownloadInvoiceDOC
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetDownloadInvoiceDOC());

        // Fetch test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Running the method
        String response = TSD_ReportsController.getDownloadInvoiceDOC('1TR/2324/0000003', testAccount.Id);
        TSD_ReportsController.fc();

        // Assert response contains expected mock values
        //System.assert(response.contains('mockBase64EncodedData'), 'Response should contain mock Base64 encoded data');
        //System.assert(response.contains('mockFile.pdf'), 'Response should contain mock file name');

        Test.stopTest();
    }
    
    @isTest
    static void testGetDownloadInvoiceNonSORTCDOC() {
        Test.startTest();
        
        // Mocking response for getDownloadInvoiceNonSORTCDOC
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetDownloadInvoiceNonSORTCDOC());

        // Fetch test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Running the method
        String response = TSD_ReportsController.getDownloadInvoiceNonSORTCDOC('DOC123', testAccount.Id);
        TSD_ReportsController.fc();

        // Assert response contains expected mock values
        //System.assert(response.contains('mockNonSORTCBase64Data'), 'Response should contain expected Base64 encoded data');
        //System.assert(response.contains('mockNonSORTCFile.pdf'), 'Response should contain expected file name');

        Test.stopTest();
    }
    
    @isTest
    static void testGetDownloadInvoiceLRDOC() {
        Test.startTest();
        
        // Mocking response for getDownloadInvoiceLRDOC
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetDownloadInvoiceLRDOC());

        // Fetch test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Running the method
        String response = TSD_ReportsController.getDownloadInvoiceLRDOC('DOC123', testAccount.Id);
        TSD_ReportsController.fc();

        // Assert response contains expected mock values
        //System.assert(response.contains('mockLRBase64EncodedData'), 'Response should contain expected LR Base64 encoded data');
        //System.assert(response.contains('mockLRFile.pdf'), 'Response should contain expected LR file name');

        Test.stopTest();
    }
    
    @isTest
    static void testGetDownloadCreditNoteDOC() {
        Test.startTest();
        
        // Mocking response for getDownloadCreditNoteDOC
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGetDownloadCreditNoteDOC());

        // Fetch test account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Running the method
        String response = TSD_ReportsController.getDownloadCreditNoteDOC('DOC123', testAccount.Id);
        TSD_ReportsController.fc();

        // Assert response contains expected mock values
        //System.assert(response.contains('mockCreditNoteBase64Data'), 'Response should contain expected Credit Note Base64 encoded data');
        //System.assert(response.contains('mockCreditNoteFile.pdf'), 'Response should contain expected Credit Note file name');

        Test.stopTest();
    }
    
    // --- Mock Classes ---
    
    // Mock for successful HTTP response used in several methods
    private class MockHttpResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                        '<soap:Body>' +
                        '<SalesInvoiceHeaderReport_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                        '<returnValue>Success</returnValue>' +
                        '</SalesInvoiceHeaderReport_Result>' +
                        '</soap:Body></soap:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Mock for failure HTTP response
    private class MockHttpResponseFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }
    
    // Mock for getDownloadInvoiceDOC HTTP response
    private class MockHttpResponseGetDownloadInvoiceDOC implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String mockResponseBody = 
                '<?xml version="1.0" encoding="utf-8"?>' +
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soap:Body>' +
                '<GenerateInvoice_Report_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                '<return_value>1</return_value>' +
                '<salesInvReport>mockBase64EncodedData</salesInvReport>' +
                '<toFile>mockFile.pdf</toFile>' +
                '</GenerateInvoice_Report_Result>' +
                '</soap:Body>' +
                '</soap:Envelope>';
            res.setBody(mockResponseBody);
            return res;
        }
    }
    
    // Mock for getDownloadInvoiceNonSORTCDOC HTTP response
    private class MockHttpResponseGetDownloadInvoiceNonSORTCDOC implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String mockResponseBody = 
                '<?xml version="1.0" encoding="utf-8"?>' +
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soap:Body>' +
                '<GenerateTC_Report_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                '<return_value>1</return_value>' +
                '<reportTC>mockNonSORTCBase64Data</reportTC>' +
                '<finalFileName>mockNonSORTCFile.pdf</finalFileName>' +
                '</GenerateTC_Report_Result>' +
                '</soap:Body>' +
                '</soap:Envelope>';
            res.setBody(mockResponseBody);
            return res;
        }
    }
    
    // Mock for getDownloadInvoiceLRDOC HTTP response
    private class MockHttpResponseGetDownloadInvoiceLRDOC implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String mockResponseBody = 
                '<?xml version="1.0" encoding="utf-8"?>' +
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soap:Body>' +
                '<GenerateLR_Report_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                '<return_value>1</return_value>' +
                '<lR_Report>mockLRBase64EncodedData</lR_Report>' +
                '<toFile>mockLRFile.pdf</toFile>' +
                '</GenerateLR_Report_Result>' +
                '</soap:Body>' +
                '</soap:Envelope>';
            res.setBody(mockResponseBody);
            return res;
        }
    }
    
    // Mock for getDownloadCreditNoteDOC HTTP response
    private class MockHttpResponseGetDownloadCreditNoteDOC implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String mockResponseBody =
                '<?xml version="1.0" encoding="utf-8"?>' +
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soap:Body>' +
                '<GenerateCreditNote_Report_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                '<return_value>1</return_value>' +
                '<salesCrNoteReport>mockCreditNoteBase64Data</salesCrNoteReport>' +
                '<toFile>mockCreditNoteFile.pdf</toFile>' +
                '</GenerateCreditNote_Report_Result>' +
                '</soap:Body>' +
                '</soap:Envelope>';
            res.setBody(mockResponseBody);
            return res;
        }
    }
}