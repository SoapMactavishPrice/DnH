@isTest
private class CloseReopenComplaint_ToNAVTest {

    
    private class MockHttpResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                '  <soapenv:Body>' +
                '    <sal:Services19Reopen_Result>' +
                '      <sal:return_value>Success</sal:return_value>' +
                '    </sal:Services19Reopen_Result>' +
                '  </soapenv:Body>' +
                '</soapenv:Envelope>'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    
    private class MockHttpResponseCloseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                '  <soapenv:Body>' +
                '    <sal:UpdateServices19_Result>' +
                '      <sal:return_value>Success</sal:return_value>' +
                '    </sal:UpdateServices19_Result>' +
                '  </soapenv:Body>' +
                '</soapenv:Envelope>'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    
    private class MockHttpResponseFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                '  <soapenv:Body>' +
                '    <sal:Error>' +
                '      <sal:message>Error occurred</sal:message>' +
                '    </sal:Error>' +
                '  </soapenv:Body>' +
                '</soapenv:Envelope>'
            );
            res.setStatusCode(500);
            return res;
        }
    }

    @isTest
    static void testReopenCustomerComplaintSuccess() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        
        Test.startTest();
        CloseReopenComplaint_ToNAV.reopenCustomerComplaint('12345');
        Test.stopTest();

        
        List<API_Log__c> logs = [SELECT Id, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_reopenCustomerComplaint_NAV'];
        System.assertEquals(1, logs.size());
        System.assertEquals('Success', logs[0].Log_Status__c);
        System.assertEquals('200', logs[0].Response_Code__c);
    }

    @isTest
    static void testReopenCustomerComplaintFailure() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        
       
        Test.startTest();
        CloseReopenComplaint_ToNAV.reopenCustomerComplaint('12345');
        Test.stopTest();

        
        List<API_Log__c> logs = [SELECT Id, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_reopenCustomerComplaint_NAV'];
        System.assertEquals(1, logs.size());
        System.assertEquals('Failure', logs[0].Log_Status__c);
        System.assertEquals('500', logs[0].Response_Code__c);
    }

    @isTest
    static void testCloseCustomerComplaintSuccess() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCloseSuccess());
        
        
        Test.startTest();
        CloseReopenComplaint_ToNAV.closeCustomerComplaint('12345');
        Test.stopTest();

        
        List<API_Log__c> logs = [SELECT Id, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_closeCustomerComplaint_NAV'];
        System.assertEquals(1, logs.size());
        System.assertEquals('Success', logs[0].Log_Status__c);
        System.assertEquals('200', logs[0].Response_Code__c);
    }

    @isTest
    static void testCloseCustomerComplaintFailure() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        
        
        Test.startTest();
        CloseReopenComplaint_ToNAV.closeCustomerComplaint('12345');
        Test.stopTest();

        
        List<API_Log__c> logs = [SELECT Id, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_closeCustomerComplaint_NAV'];
        System.assertEquals(1, logs.size());
        System.assertEquals('Failure', logs[0].Log_Status__c);
        System.assertEquals('500', logs[0].Response_Code__c);
    }
}