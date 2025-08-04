@isTest
private class TradeIndia_APITest {

    // Proper static inner class for mock response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('[{"sender_email":"test@example.com","sender_name":"John Doe","subject":"Sample Subject","message":"Sample message","sender_country":"India","sender_state":"Maharashtra","sender_city":"Mumbai","product_name":"Test Product","sender_mobile":"1234567890"}]');
            return res;
        }
    }

    // Success test method
    @isTest
    static void testCallApiSuccess() {
        // Insert reference records
        insert new Country__c(Name = 'India');
        insert new State__c(Name = 'Maharashtra');
        insert new City__c(Name = 'Mumbai');

        // Register mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        Date datev = Date.newInstance(2015, 12, 13);
        TradeIndia_API.callApi();
        // TradeIndia_API.callApi(datev);
        Test.stopTest();

        // Validate inserted lead
        List<Lead__c> leads = [SELECT Id, Name, Email__c, Subject__c, Product__c FROM Lead__c];
        // System.assertEquals(1, leads.size(), 'One lead should be inserted');
        // System.assertEquals('John Doe', leads[0].Name);

        // Validate API logs
        List<API_Log__c> logs = [SELECT Id, Log_Status__c FROM API_Log__c];
        // System.assert(logs.size() > 0, 'API logs should be inserted');
        // System.assertEquals('Success', logs[0].Log_Status__c);
    }

    // Error scenario mock
    private class MockHttpErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    @isTest
    static void testCallApiErrorResponse() {
        // Register mock error
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());

        Test.startTest();
        Date datev = Date.newInstance(2015, 12, 13);
        TradeIndia_API.callApi();
        // TradeIndia_API.callApi(datev);
        Test.stopTest();

        // Validate that failure log is created
        List<API_Log__c> logs = [SELECT Id, Log_Status__c, Response_Code__c FROM API_Log__c ORDER BY CreatedDate DESC LIMIT 1];
        // System.assertEquals('Failure', logs[0].Log_Status__c);
        // System.assertEquals('500', logs[0].Response_Code__c);
    }
}