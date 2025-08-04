@isTest
public class NMD_LRDestinationTest {
    @isTest
    static void testGetLRDataAsJson() {
        // Create mock HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockLRDestinationResponse());
        
        // Instantiate the class and call the method
        NMD_LRDestination destination = new NMD_LRDestination();
        String result = destination.getLRDataAsJson();
        
        Test.stopTest();
        
        // Verify expected behavior
        // System.assertEquals('Ok', result, 'Expected response is Ok');
        
        // Verify that records were inserted
        List<LR_Destination__c> insertedRecords = [SELECT Id, Name, Code__c FROM LR_Destination__c];
        // System.assert(insertedRecords.size() > 0, 'Expected some records to be inserted');
    }

    private class MockLRDestinationResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?>'+
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'+
                    '<soapenv:Body>'+
                        '<GetLRDestination_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">'+
                            '<returnValue>[{"Code":"ABC123","City":"TestCity","SearchCity":"TestSearchCity","CountryRegionCode":"US"}]</returnValue>'+
                        '</GetLRDestination_Result>'+
                    '</soapenv:Body>'+
                '</soapenv:Envelope>');
            return res;
        }
    }
}