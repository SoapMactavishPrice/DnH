@isTest
private class CheckSampleOrderInvoice_BatchTest {
    
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"DocNo":"INV001","CustomerNo":"C001","CustomerName":"Customer1","EndCustomerName":"EndCustomer1","ShiptoCustomerName":"ShiptoCustomer1","FieldEngineer":"Engineer1","AreaManager":"Manager1","ZonalManager":"Manager2","InvoiceDate":"2022-12-01","DocketNo":"D001","DocketDate":"2022-12-02"}]');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testBatchExecution() {
       
        User testUser = new User(
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Code__c = 'DNH1974'
        );
        insert testUser;
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        
        Test.startTest();
        CheckSampleOrderInvoice_Batch batch = new CheckSampleOrderInvoice_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE JobType='BatchApex' AND Status='Completed'];
        System.assert(jobs.size() > 0);
        System.assertEquals('Completed', jobs[0].Status);
    }
}