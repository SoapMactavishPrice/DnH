@isTest
private class CheckInvoiceLine_BatchTest {
    
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"LineItemNo":"001","Description":"Item 1","Quantity":1,"Price":100}]');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testBatchExecution() {
        
        Invoice__c testInvoice = new Invoice__c(Name = 'Test Invoice');
        insert testInvoice;
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        
        Test.startTest();
        CheckInvoiceLine_Batch batch = new CheckInvoiceLine_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
       
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems 
                                   FROM AsyncApexJob 
                                   WHERE JobType='BatchApex' AND Status='Completed'];
        System.assert(jobs.size() > 0);
        System.assertEquals('Completed', jobs[0].Status);
        
       
    }
}