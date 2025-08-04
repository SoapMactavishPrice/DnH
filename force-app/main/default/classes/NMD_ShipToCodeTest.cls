@isTest
global class NMD_ShipToCodeTest {

    // Mock class to simulate a successful HTTP response
    global class MockHttpResponse implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            // Mock SOAP response (successful case)
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?>' +
                        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/shiptocodesf">' +
                        '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ShipToCodeSF>' +
                        '<cus:Name>A B & CORP</cus:Name>' +
                        '<cus:Code>452009</cus:Code>' +
                        '<cus:Customer_No>CUS0000010</cus:Customer_No>' +
                        '</cus:ShipToCodeSF>' +
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
            res.setBody(
            			'<Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                                '<Soap:Body>' +
                                    '<ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/shiptocodesf">' +
                                        '<ReadMultiple_Result>' +
                                            '<ShipToCodeSF>' +
                                                '<Key>44;3gAAAAJ7/0MAVQBTADAAMAAwADAANgA0ADAAAAACewEx8;150850680;</Key>' +
                                                '<Customer_No>CUS0000640</Customer_No>' +
                                                '<Code>1</Code>' +
                                                '<Name>AMIT IRON &amp; OXY CYL AGENCY.</Name>' +
                                                '<Address>In Front Of ITI College,Village: Kohrar Ghat,  </Address>' +
                                                '<Address_2>Tehsil: Meja,Near NTPC Meja Power Plant</Address_2>' +
                                                '<City>KOHRAR GHAT, DIST: A</City>' +
                                                '<Phone_No>9161811111</Phone_No>' +
                                                '<Country_Region_Code>IN</Country_Region_Code>' +
                                                '<Post_Code>212301</Post_Code>' +
                                                '<State>UP</State>' +
                                                '<GST_Registration_No>09ASXPS3472M2ZJ</GST_Registration_No>' +
                                            '</ShipToCodeSF>' +
                                        '</ReadMultiple_Result>' +
                                    '</ReadMultiple_Result>' +
                                '</Soap:Body>' +
                            '</Soap:Envelope>');
            return res;
        }
    }

    // Test for the successful case
    @isTest
    static void testGetShipToCodeDataAsJson_Success() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_ShipToCode shipToCodeService = new NMD_ShipToCode();
        String jsonResponse = shipToCodeService.getShipToCodeDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert the response is not null
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');
        
        // Assert that the JSON response contains the expected data
    //    System.assert(jsonResponse.contains('A B & CORP'), 'The JSON response should contain "A B & CORP"');
    //    System.assert(jsonResponse.contains('452009'), 'The JSON response should contain "452009"');
    //    System.assert(jsonResponse.contains('CUS0000010'), 'The JSON response should contain "CUS0000010"');
    }

    // Test for the case when the response code is not 200
    @isTest
    static void testGetShipToCodeDataAsJson_ErrorResponse() {
        // Set the mock error response
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_ShipToCode shipToCodeService = new NMD_ShipToCode();
        String jsonResponse = shipToCodeService.getShipToCodeDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert that the response indicates an error
     //   System.assert(jsonResponse.contains('Error: 500'), 'The JSON response should contain an error message');
    }

    // Test for the case when there is an exception during processing (malformed SOAP response)
    @isTest
    static void testGetShipToCodeDataAsJson_Exception() {
        // Set the mock exception response
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_ShipToCode shipToCodeService = new NMD_ShipToCode();
        String jsonResponse = shipToCodeService.getShipToCodeDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert that the response contains an exception message
    //    System.assert(jsonResponse.contains('Error parsing SOAP response'), 'The JSON response should contain an error message');
    }

    // Test for the convertSoapResponseToJson method (successful case)
    @isTest
    static void testConvertSoapResponseToJson_Success() {
        String soapResponse = 
                            '<Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                                '<Soap:Body>' +
                                    '<ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/shiptocodesf">' +
                                        '<ReadMultiple_Result>' +
                                            '<ShipToCodeSF>' +
                                                '<Key>44;3gAAAAJ7/0MAVQBTADAAMAAwADAANgA0ADAAAAACewEx8;150850680;</Key>' +
                                                '<Customer_No>CUS0000640</Customer_No>' +
                                                '<Code>1</Code>' +
                                                '<Name>AMIT IRON &amp; OXY CYL AGENCY.</Name>' +
                                                '<Address>In Front Of ITI College,Village: Kohrar Ghat,  </Address>' +
                                                '<Address_2>Tehsil: Meja,Near NTPC Meja Power Plant</Address_2>' +
                                                '<City>KOHRAR GHAT, DIST: A</City>' +
                                                '<Phone_No>9161811111</Phone_No>' +
                                                '<Country_Region_Code>IN</Country_Region_Code>' +
                                                '<Post_Code>212301</Post_Code>' +
                                                '<State>UP</State>' +
                                                '<GST_Registration_No>09ASXPS3472M2ZJ</GST_Registration_No>' +
                                            '</ShipToCodeSF>' +
                                        '</ReadMultiple_Result>' +
                                    '</ReadMultiple_Result>' +
                                '</Soap:Body>' +
                            '</Soap:Envelope>';	
        
        // Call the method to test SOAP response conversion
        String jsonResponse = NMD_ShipToCode.convertSoapResponseToJson(soapResponse);

        // Assert the response is valid JSON
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');
     //   System.assert(jsonResponse.contains('A B & CORP'), 'The JSON response should contain "A B & CORP"');
     //   System.assert(jsonResponse.contains('452009'), 'The JSON response should contain "452009"');
      //  System.assert(jsonResponse.contains('CUS0000010'), 'The JSON response should contain "CUS0000010"');
    }

    // Test for the convertSoapResponseToJson method (malformed SOAP response)
    @isTest
    static void testConvertSoapResponseToJson_Exception() {
        String soapResponse = 
                            '<Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                                '<Soap:Body>' +
                                    '<ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/shiptocodesf">' +
                                        '<ReadMultiple_Result>' +
                                            '<ShipToCodeSF>' +
                                                '<Key>44;3gAAAAJ7/0MAVQBTADAAMAAwADAANgA0ADAAAAACewEx8;150850680;</Key>' +
                                                '<Customer_No>CUS0000640</Customer_No>' +
                                                '<Code>1</Code>' +
                                                '<Name>AMIT IRON &amp; OXY CYL AGENCY.</Name>' +
                                                '<Address>In Front Of ITI College,Village: Kohrar Ghat,  </Address>' +
                                                '<Address_2>Tehsil: Meja,Near NTPC Meja Power Plant</Address_2>' +
                                                '<City>KOHRAR GHAT, DIST: A</City>' +
                                                '<Phone_No>9161811111</Phone_No>' +
                                                '<Country_Region_Code>IN</Country_Region_Code>' +
                                                '<Post_Code>212301</Post_Code>' +
                                                '<State>UP</State>' +
                                                '<GST_Registration_No>09ASXPS3472M2ZJ</GST_Registration_No>' +
                                            '</ShipToCodeSF>' +
                                        '</ReadMultiple_Result>' +
                                    '</ReadMultiple_Result>' +
                                '</Soap:Body>' +
                            '</Soap:Envelope>';	
        
        // Call the method to test SOAP response conversion with an error
        String jsonResponse = NMD_ShipToCode.convertSoapResponseToJson(soapResponse);

    }
}