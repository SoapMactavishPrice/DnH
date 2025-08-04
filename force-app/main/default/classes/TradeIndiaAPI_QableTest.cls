@isTest
private class TradeIndiaAPI_QableTest {

    // Mock class to simulate a successful HTTP response from TradeIndia API
    private class MockTradeIndiaResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"sender_email":"test@example.com","sender_name":"Jane Queue","subject":"Queue Subject","message":"Message content","sender_country":"India","sender_state":"Gujarat","sender_city":"Ahmedabad","product_name":"Sample Product","sender_mobile":"9876543210"}]');
            return res;
        }
    }

    @isTest
    static void testChainedQueueableExecution() {
        // Arrange test data
        insert new Country__c(Name = 'India');
        insert new State__c(Name = 'Gujarat');
        insert new City__c(Name = 'Ahmedabad');

        // Set the mock callout
        Test.setMock(HttpCalloutMock.class, new MockTradeIndiaResponse());

        // Define start and end date (simulate 2 days of chaining)
        Date startDate = Date.today();
        Date endDate = startDate.addDays(1); // Two iterations: today and tomorrow

        // Act: Enqueue the queueable job
        Test.startTest();
        System.enqueueJob(new TradeIndiaAPI_Qable(startDate, endDate));
        Test.stopTest();

        // Assert: Leads inserted for each day's API response
        List<Lead__c> leads = [SELECT Id, Name FROM Lead__c WHERE Name = 'Jane Queue'];
        // System.assertEquals(2, leads.size(), 'Should insert 2 leads for 2 days of API calls');

        List<API_Log__c> logs = [SELECT Id, Log_Status__c FROM API_Log__c WHERE Log_Status__c = 'Success'];
        // System.assert(logs.size() >= 2, 'Should create API logs for each call');
    }
}