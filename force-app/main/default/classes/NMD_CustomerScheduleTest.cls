@isTest
public class NMD_CustomerScheduleTest {
    @isTest
    static void testExecute() {
        
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{"key":"value"}');
        mockResponse.setStatusCode(200);

        HttpMock httpMock = new HttpMock();
        httpMock.setResponse(mockResponse);
        Test.setMock(HttpCalloutMock.class, httpMock);

        
        Test.startTest();
        NMD_CustomerSchedule job = new NMD_CustomerSchedule();
        System.enqueueJob(job);
        AllScheduler job1=new AllScheduler('NMD_CustSalesPersonMap');
        System.enqueueJob(job1);

        AllScheduler job12=new AllScheduler('NMD_ItemVariant');
        System.enqueueJob(job12);

        AllScheduler job13=new AllScheduler('NMD_SalesPerson');
        System.enqueueJob(job13);

        AllScheduler job14=new AllScheduler('NMD_SalesPriceList');
        System.enqueueJob(job14);
        Test.stopTest();

       
    }

   
    class HttpMock implements HttpCalloutMock {
        private HttpResponse response;
        public void setResponse(HttpResponse resp) {
            response = resp;
        }
        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}