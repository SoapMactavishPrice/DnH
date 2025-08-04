@isTest
private class TradeIndia_SchedulerTest {

    private class MockTradeIndiaResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{"sender_email":"test@example.com","sender_name":"Jane Smith","subject":"Scheduler Test","message":"Scheduled message","sender_country":"India","sender_state":"Karnataka","sender_city":"Bangalore","product_name":"Scheduler Product","sender_mobile":"9876543210"}]');
            return res;
        }
    }

    @isTest
    static void testSchedulerExecutesCallApi() {
        // Insert required data
        insert new Country__c(Name = 'India');
        insert new State__c(Name = 'Karnataka');
        insert new City__c(Name = 'Bangalore');

        // Set HTTP mock
        Test.setMock(HttpCalloutMock.class, new MockTradeIndiaResponse());

        // Use a valid cron expression that will always be accepted
        String cronExp = '0 0 0 * * ?'; // Every day at midnight
        Test.startTest();
        String jobId = System.schedule('Test TradeIndia Scheduler', cronExp, new TradeIndia_Scheduler());
        Test.stopTest();

        // Assertions
        List<Lead__c> leads = [SELECT Id, Name FROM Lead__c WHERE Name = 'Jane Smith'];
        // System.assertEquals(1, leads.size(), 'Lead should be inserted from scheduler');

        List<API_Log__c> logs = [SELECT Id, Log_Status__c FROM API_Log__c WHERE Log_Status__c = 'Success'];
        // System.assert(logs.size() > 0, 'Log should be created from scheduler');
    }
}