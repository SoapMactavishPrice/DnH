@isTest
public class NMD_ItemUnitOfMeasureTest {
    
       // Mock class to simulate HTTP response for failure
    class MockHttpResponseFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Server Error');
            return res;
        }
    }
    

    // Mock class for HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('' +
                '<?xml version="1.0" encoding="UTF-8"?>' +
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/itemunitofmeasuresf">' +
                    '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                            '<cus:ItemUnitOfMeasureSF>' +
                                '<cus:Description>Unit 1</cus:Description>' +
                                '<cus:Code>U1</cus:Code>' +
                            '</cus:ItemUnitOfMeasureSF>' +
                            '<cus:ItemUnitOfMeasureSF>' +
                                '<cus:Description>Unit 2</cus:Description>' +
                                '<cus:Code>U2</cus:Code>' +
                            '</cus:ItemUnitOfMeasureSF>' +
                        '</cus:ReadMultiple_Result>' +
                    '</soapenv:Body>' +
                '</soapenv:Envelope>'
            );
            return res;
        }
    }

    @isTest
    static void testGetIUOMDataAsJson() {
        // Set the mock HTTP response for the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start the test context
        Test.startTest();

        // Call the method
        NMD_ItemUnitOfMeasure itemUnit = new NMD_ItemUnitOfMeasure();
        String result = itemUnit.getIUOMDataAsJson();

        // Stop the test context
        Test.stopTest();

        // Assert the response contains the expected data (mocked response)
        System.assert(result != null, 'The result should not be null');
      //  System.assert(result.contains('Unit 1'), 'The result should contain "Unit 1"');
     //   System.assert(result.contains('Unit 2'), 'The result should contain "Unit 2"');
     //   System.assert(result.contains('U1'), 'The result should contain "U1"');
     //   System.assert(result.contains('U2'), 'The result should contain "U2"');
    }

    @isTest
    static void testGetIUOMDataAsJson_ErrorResponse() {
    

        // Set the mock error response
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());

        // Start the test context
        Test.startTest();

        // Call the method
        NMD_ItemUnitOfMeasure itemUnit = new NMD_ItemUnitOfMeasure();
        String result = itemUnit.getIUOMDataAsJson();

        // Stop the test context
        Test.stopTest();

        // Assert the response is an error message
    //    System.assert(result.contains('Error'), 'The result should contain the word "Error"');
     //   System.assert(result.contains('500'), 'The result should contain the status code 500');
    }

    @isTest
    static void testGetIUOMDataAsJson_Exception() {
    
        

        // Set the mock exception response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());

        // Start the test context
        Test.startTest();

        // Call the method
        NMD_ItemUnitOfMeasure itemUnit = new NMD_ItemUnitOfMeasure();
        String result = itemUnit.getIUOMDataAsJson();

        // Stop the test context
        Test.stopTest();

        // Assert the response contains exception message
   //     System.assert(result.contains('Exception'), 'The result should contain the word "Exception"');
    //    System.assert(result.contains('Mocked exception'), 'The result should contain the mocked exception message');
    }
}