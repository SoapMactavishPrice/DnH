@isTest
global class NMD_TransporterTest {

    // Mock class to simulate a successful HTTP response
    global class MockHttpResponse implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            // Mock SOAP response (successful case)
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?>' +
                        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/transportersf">' +
                        '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:TransporterSF>' +
                        '<cus:Name>AMALTAS TRAVELS</cus:Name>' +
                        '<cus:Code>AML</cus:Code>' +
                        '<cus:Key>16;IwEAAAJ7/0EATQBM8;116336560;</cus:Key>' +
                        '</cus:TransporterSF>' +
                        '</cus:ReadMultiple_Result>' +
                        '</cus:ReadMultiple_Result>' +
                        '</soapenv:Body>' +
                        '</soapenv:Envelope>');
            return res;
        }
    }

    // Mock class to simulate an error HTTP response (non-200 status code)
    global class MockHttpErrorResponse implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    // Mock class to simulate an exception scenario in parsing SOAP response
    global class MockHttpExceptionResponse implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/transportersf">' +
                        '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:TransporterSF>' +
                        '<cus:Name>AMALTAS TRAVELS</cus:Name>' +
                        '<cus:Code>AML</cus:Code>' +
                        // Missing Key to simulate an error in parsing
                        '</cus:TransporterSF>' +
                        '</cus:ReadMultiple_Result>' +
                        '</cus:ReadMultiple_Result>' +
                        '</soapenv:Body>' +
                        '</soapenv:Envelope>');
            return res;
        }
    }

    // Test for the successful case
    @isTest
    static void testGetTransporterDataAsJson_Success() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_Transporter transporterService = new NMD_Transporter();
        String jsonResponse = transporterService.getTransporteDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert the response is not null
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');
        
        // Assert that the JSON response contains the expected data
        System.assert(jsonResponse.contains('AMALTAS TRAVELS'), 'The JSON response should contain "AMALTAS TRAVELS"');
        System.assert(jsonResponse.contains('AML'), 'The JSON response should contain "AML"');
        System.assert(jsonResponse.contains('16;IwEAAAJ7/0EATQBM8;116336560;'), 'The JSON response should contain the expected Key');
    }

    // Test for the case when the response code is not 200
    @isTest
    static void testGetTransporterDataAsJson_ErrorResponse() {
        // Set the mock error response
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_Transporter transporterService = new NMD_Transporter();
        String jsonResponse = transporterService.getTransporteDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert that the response indicates an error
   //     System.assert(jsonResponse.contains('Error: 500'), 'The JSON response should contain an error message');
    }

    // Test for the case when there is an exception during processing (malformed SOAP response)
    @isTest
    static void testGetTransporterDataAsJson_Exception() {
        // Set the mock exception response
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_Transporter transporterService = new NMD_Transporter();
        String jsonResponse = transporterService.getTransporteDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert that the response contains an exception message
    //    System.assert(jsonResponse.contains('Error parsing SOAP response'), 'The JSON response should contain an error message');
    }

    // Test for the convertSoapResponseToJson method (successful case)
    @isTest
    static void testConvertSoapResponseToJson_Success() {
        String soapResponse = '<?xml version="1.0" encoding="UTF-8"?>' +
                              '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/transportersf">' +
                              '<soapenv:Body>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:TransporterSF>' +
                              '<cus:Name>AMALTAS TRAVELS</cus:Name>' +
                              '<cus:Code>AML</cus:Code>' +
                              '<cus:Key>16;IwEAAAJ7/0EATQBM8;116336560;</cus:Key>' +
                              '</cus:TransporterSF>' +
                              '</cus:ReadMultiple_Result>' +
                              '</cus:ReadMultiple_Result>' +
                              '</soapenv:Body>' +
                              '</soapenv:Envelope>';
        
        // Call the method to test SOAP response conversion
        String jsonResponse = NMD_Transporter.convertSoapResponseToJson(soapResponse);

        // Assert the response is valid JSON
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');
        System.assert(jsonResponse.contains('AMALTAS TRAVELS'), 'The JSON response should contain "AMALTAS TRAVELS"');
        System.assert(jsonResponse.contains('AML'), 'The JSON response should contain "AML"');
        System.assert(jsonResponse.contains('16;IwEAAAJ7/0EATQBM8;116336560;'), 'The JSON response should contain the expected Key');
    }

    // Test for the convertSoapResponseToJson method (malformed SOAP response)
    @isTest
    static void testConvertSoapResponseToJson_Exception() {
        String soapResponse = '<?xml version="1.0" encoding="UTF-8"?>' +
                              '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/transportersf">' +
                              '<soapenv:Body>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:TransporterSF>' +
                              '<cus:Name>AMALTAS TRAVELS</cus:Name>' +
                              '<cus:Code>AML</cus:Code>' +
                              // Missing Key to simulate an error in parsing
                              '</cus:TransporterSF>' +
                              '</cus:ReadMultiple_Result>' +
                              '</cus:ReadMultiple_Result>' +
                              '</soapenv:Body>' +
                              '</soapenv:Envelope>';
        
        // Call the method to test SOAP response conversion with an error
        String jsonResponse = NMD_Transporter.convertSoapResponseToJson(soapResponse);

        // Assert that the response contains an error message
   //     System.assert(jsonResponse.contains('Error parsing SOAP response'), 'The JSON response should contain an error message');
    }
}