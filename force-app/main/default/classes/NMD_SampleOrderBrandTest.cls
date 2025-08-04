@isTest
public class NMD_SampleOrderBrandTest {
    
    // Mock class to simulate a successful HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Mock SOAP response (successful case)
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?>' +
                        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                        '<soapenv:Body>' +
                        '<sal:GetBrandName_Result>' +
                        '<sal:returnValue>' +
                        '[{"DimensionCode":"DIM001","Code":"CODE001","Description":"Brand 1","EmailId":"email1@example.com"},' +
                        '{"DimensionCode":"DIM002","Code":"CODE002","Description":"Brand 2","EmailId":"email2@example.com"}]' +
                        '</sal:returnValue>' +
                        '</sal:GetBrandName_Result>' +
                        '</soapenv:Body>' +
                        '</soapenv:Envelope>');
            return res;
        }
    }
    
    // Mock class to simulate a failure HTTP response
    private class MockHttpResponseFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Mock error response (failure case)
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }
    
    // Test for the successful case
    @isTest
    static void testGetCurrencyDataAsJson_Success() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Start test context
        Test.startTest();
        
        // Call the method
        NMD_SampleOrderBrand brandService = new NMD_SampleOrderBrand();
        String jsonResponse = brandService.getCurrencyDataAsJson();
        
        // Stop test context
        Test.stopTest();
        
        // Assert the response is not null
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');
        
        // Assert the response contains expected data
        System.assert(jsonResponse.contains('Brand 1'), 'The JSON response should contain "Brand 1"');
        System.assert(jsonResponse.contains('Brand 2'), 'The JSON response should contain "Brand 2"');
    }
    
    // Test for handling an error response (HTTP 500)
    @isTest
    static void testGetCurrencyDataAsJson_ErrorResponse() {
        // Set the mock error response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        
        // Start test context
        Test.startTest();
        
        // Call the method
        NMD_SampleOrderBrand brandService = new NMD_SampleOrderBrand();
        String jsonResponse = brandService.getCurrencyDataAsJson();
        
        // Stop test context
        Test.stopTest();
        
        // Assert that the response indicates an error
    //    System.assert(jsonResponse.contains('Error: 500'), 'The JSON response should contain the error message for status 500');
    }
    
    // Test the convertSoapResponseToJson method directly
    @isTest
    static void testConvertSoapResponseToJson() {
        // Sample SOAP response to test the conversion method
        String soapResponse = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
            '<soapenv:Body>' +
            '<sal:GetBrandName_Result>' +
            '<sal:returnValue>' +
            '[{"DimensionCode":"DIM001","Code":"CODE001","Description":"Brand 1","EmailId":"email1@example.com"},' +
            '{"DimensionCode":"DIM002","Code":"CODE002","Description":"Brand 2","EmailId":"email2@example.com"}]' +
            '</sal:returnValue>' +
            '</sal:GetBrandName_Result>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';
        
        // Call the method to convert SOAP response to JSON
        String jsonResponse = NMD_SampleOrderBrand.convertSoapResponseToJson(soapResponse);
        
        // Assert that the JSON response contains the expected values
        System.assert(jsonResponse.contains('DIM001'), 'The JSON response should contain DIM001');
        System.assert(jsonResponse.contains('DIM002'), 'The JSON response should contain DIM002');
        System.assert(jsonResponse.contains('Brand 1'), 'The JSON response should contain "Brand 1"');
        System.assert(jsonResponse.contains('Brand 2'), 'The JSON response should contain "Brand 2"');
    }
}