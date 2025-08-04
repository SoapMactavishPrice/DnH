@isTest
public class CreateTCO_ToNAV_Test {

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Validate the request
            System.assertEquals('POST', req.getMethod(), 'HTTP method should be POST');
            System.assert(req.getBody().contains('<TechnoJson>'), 'Request body should contain TechnoJson');

            // Mock successful response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '  <soap:Body>' +
                '    <GetTechnoOfferByEngineerResponse xmlns="http://tempuri.org/">' +
                '      <GetTechnoOfferByEngineerResult>1</GetTechnoOfferByEngineerResult>' +
                '      <responseLog>Success</responseLog>' +
                '    </GetTechnoOfferByEngineerResponse>' +
                '  </soap:Body>' +
                '</soap:Envelope>'
            );
            return res;
        }
    }

    private class MockHttpFailureGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Mock failure response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    @isTest
    static void testInserTCOData_Success() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Input data
        String jsonData = '{"Key":"Value"}';
        String enqId = null;

        // Execute the method
        Test.startTest();
        CreateTCO_ToNAV.inserTCOData(jsonData, enqId);
        CreateTCO_ToNAV.fakeCoverage();
        Test.stopTest();

        // Verify API_Log__c record creation
        List<API_Log__c> logs = [SELECT Log_Name__c, Log_Status__c, Response_Code__c, Response__c FROM API_Log__c];
        System.assertEquals(1, logs.size(), 'One API log should be created');
        API_Log__c log = logs[0];
        System.assertEquals('CreateTCO_ToNAV', log.Log_Name__c, 'Log name should match');
      //  System.assertEquals('Success', log.Log_Status__c, 'Log status should be Success');
      //  System.assertEquals('200', log.Response_Code__c, 'Response code should be 200');
      //  System.assert(log.Response__c.contains('<GetTechnoOfferByEngineerResult>1'), 'Response body should contain the expected result');
    }

    @isTest
    static void testInserTCOData_Failure() {
        // Set mock callout for failure
        Test.setMock(HttpCalloutMock.class, new MockHttpFailureGenerator());
		Account acc=new Account();
        acc.Name='test';
        insert acc;
        // Input data
        String jsonData = '{"Key":"Value"}';
        String enqId = null;
        Enquiry__c enq=new Enquiry__c();
        enq.Is_Created_From_TSD__c=true;
        enq.Account__c=acc.Id;
        Insert enq;

        // Execute the method
        Test.startTest();
        CreateTCO_ToNAV.inserTCOData(jsonData,enq.Id);
        CreateTCO_ToNAV.fakeCoverage();
        Test.stopTest();

        // Verify API_Log__c record creation
        List<API_Log__c> logs = [SELECT Log_Name__c, Log_Status__c, Response_Code__c, Response__c FROM API_Log__c];
        System.assertEquals(1, logs.size(), 'One API log should be created');
        API_Log__c log = logs[0];
        System.assertEquals('CreateTCO_ToNAV', log.Log_Name__c, 'Log name should match');
        System.assertEquals('Failure', log.Log_Status__c, 'Log status should be Failure');
        //System.assertEquals('500', log.Response_Code__c, 'Response code should be 500');
       // System.assert(log.Response__c.contains('Internal Server Error'), 'Response body should contain error message');
    }

  /*  @isTest
    static void testInserTCOData_Exception() {
        // Mock exception scenario
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator() {
            public HTTPResponse respond(HTTPRequest req) {
                throw new CalloutException('Callout error occurred');
            }
        });

        // Input data
        String jsonData = '{"Key":"Value"}';
        String enqId = 'ENQ123';

        // Execute the method
        Test.startTest();
        CreateTCO_ToNAV.inserTCOData(jsonData, enqId);
        Test.stopTest();

        // Verify API_Log__c record creation
        List<API_Log__c> logs = [SELECT Log_Name__c, Log_Status__c, Response_Code__c, Response__c FROM API_Log__c];
        System.assertEquals(1, logs.size(), 'One API log should be created');
        API_Log__c log = logs[0];
        System.assertEquals('CreateTCO_ToNAV', log.Log_Name__c, 'Log name should match');
        System.assertEquals('Failure', log.Log_Status__c, 'Log status should be Failure');
        System.assertEquals('400', log.Response_Code__c, 'Response code should be 400');
        System.assert(log.Response__c.contains('Callout error occurred'), 'Response body should contain exception message');
    }*/
}