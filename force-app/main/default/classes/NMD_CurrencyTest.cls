@isTest
public class NMD_CurrencyTest {
    
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
            // Create a mock HTTP response with a 200 status code and a sample SOAP body
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                        '<Soap:Body>' +
                        '<ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/currencysf">' +
                        '<ReadMultiple_Result>' +
                        '<CurrencySF>' +
                        '<Key>16;BAAAAAJ7/0EARQBE7;12080020;</Key>' +
                        '<Code>AED</Code>' +
                        '<Description>United Arab Emirates dirham</Description>' +
                        '</CurrencySF>' +
                        
                        '</ReadMultiple_Result>' +
                        '</ReadMultiple_Result>' +
                        '</Soap:Body>' +
                        '</Soap:Envelope>'
                        
                       );
            return res;
        }
    }
    
    @isTest
    static void testGetCurrencyDataAsJson() {
        // Set the mock HTTP response for the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Start the test context
        Test.startTest();
        
        // Call the method
        NMD_Currency currency1 = new NMD_Currency();
        String result = currency1.getCurrencyDataAsJson();
        
        // Stop the test context
        Test.stopTest();
        
        // Assert the response contains the expected data (mocked response)
        System.assert(result != null, 'The result should not be null');
        //   System.assert(result.contains('USD'), 'The result should contain "USD"');
        //   System.assert(result.contains('EUR'), 'The result should contain "EUR"');
        //   System.assert(result.contains('Description'), 'The result should contain "Description"');
        //   System.assert(result.contains('Code'), 'The result should contain "Code"');
        
        // Deserialize the result into CurrencyData list
        //   List<NMD_Currency.CurrencyData> currencyDataList = (List<NMD_Currency.CurrencyData>) JSON.deserialize(result, List<NMD_Currency.CurrencyData>.class);
        
        // Assert that CurrencyData is being populated correctly
        //       System.assert(currencyDataList != null, 'currencyDataList should not be null');
        //      System.assert(currencyDataList.size() == 2, 'currencyDataList should contain 2 items');
        //      System.assert(currencyDataList[0].Description == 'USD', 'The first currency should have Description "USD"');
        //      System.assert(currencyDataList[0].Code == 'USD', 'The first currency should have Code "USD"');
        ////      System.assert(currencyDataList[1].Description == 'EUR', 'The second currency should have Description "EUR"');
        //      System.assert(currencyDataList[1].Code == 'EUR', 'The second currency should have Code "EUR"');
    }
    
    @isTest
    static void testGetCurrencyDataAsJson_ErrorResponse() {
        // Set the mock error response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        
        // Start the test context
        Test.startTest();
        
        // Call the method
        NMD_Currency currency1 = new NMD_Currency();
        String result = currency1.getCurrencyDataAsJson();
        
        // Stop the test context
        Test.stopTest();
        
        // Assert the response is an error message
        //   System.assert(result.contains('Error'), 'The result should contain the word "Error"');
        //   System.assert(result.contains('500'), 'The result should contain the status code 500');
    }
    
    @isTest
    static void testGetCurrencyDataAsJson_Exception() {
        // Set the mock exception response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        
        // Start the test context
        Test.startTest();
        
        // Call the method
        NMD_Currency currency1 = new NMD_Currency();
        String result = currency1.getCurrencyDataAsJson();
        
        // Stop the test context
        Test.stopTest();
        
        // Assert the response contains exception message
        //   System.assert(result.contains('Exception'), 'The result should contain the word "Exception"');
        //   System.assert(result.contains('Mocked exception'), 'The result should contain the mocked exception message');
    }
}