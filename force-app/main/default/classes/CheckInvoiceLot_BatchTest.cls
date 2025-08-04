@isTest
private class CheckInvoiceLot_BatchTest {

    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"LotNo":"LOT001","ItemNo":"ITEM001","Quantity":100,"Description":"Item 1 Lot"}]');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testBatchExecution() {
        
        Invoice__c testInvoice = new Invoice__c(Name = '1SAAC1/03922', Docket_No__c = 'DOC001', Docket_Date__c = Date.today(), InvoiceDate__c = Date.today());
        insert testInvoice;
        
        
        Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c(
            Invoice__c = testInvoice.Id,
            Doc_No__c = 'DOC001',
            Item_No__c = 'ITEM001',
            Line_No__c = '1', 
            Description__c = 'Description',
            Description2__c = 'Description2',
            Sample_Sales_Order_Number__c = 'SO001',
            Quantity__c = '10',
            Size__c = 'Large',
            Item_Brand__c = 'BrandA',
            UOM__c = 'Each'
        );
        insert testInvoiceLineItem;
        
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        
        Test.startTest();
        CheckInvoiceLot_Batch batch = new CheckInvoiceLot_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems 
                                   FROM AsyncApexJob 
                                   WHERE JobType='BatchApex' AND Status='Completed'];
        System.assert(jobs.size() > 0);
        System.assertEquals('Completed', jobs[0].Status);
        
     
    }
}