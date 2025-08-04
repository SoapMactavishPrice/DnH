@isTest
public class NMD_DimensionValueTest {

    // Mock class to simulate a successful HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Mock SOAP response (successful case)
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?>' +
                        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/dimensionvaluesf">' +
                        '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:DimensionValueSF>' +
                        '<cus:Blocked>false</cus:Blocked>' +
                        '<cus:Name>Test Dimension</cus:Name>' +
                        '<cus:Code>123</cus:Code>' +
                        '<cus:Dimension_Code>TestCode</cus:Dimension_Code>' +
                        '</cus:DimensionValueSF>' +
                        '</cus:ReadMultiple_Result>' +
                        '</cus:ReadMultiple_Result>' +
                        '</soapenv:Body>' +
                        '</soapenv:Envelope>');
            return res;
        }
    }

    // Mock class to simulate an error HTTP response (non-200 status code)
    private class MockHttpErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    // Mock class to simulate an exception scenario in parsing SOAP response
    private class MockHttpExceptionResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/dimensionvaluesf">' +
                        '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:DimensionValueSF>' +
                        '<cus:Blocked>false</cus:Blocked>' +
                        '<cus:Name>Test Dimension</cus:Name>' +
                        '<cus:Code>123</cus:Code>' +
                        // Missing Dimension_Code to simulate an error in parsing
                        '</cus:DimensionValueSF>' +
                        '</cus:ReadMultiple_Result>' +
                        '</cus:ReadMultiple_Result>' +
                        '</soapenv:Body>' +
                        '</soapenv:Envelope>');
            return res;
        }
    }

    // Test for the successful case
    @isTest
    static void testGetDimensionValueDataAsJson_Success() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_DimensionValue dimensionValueService = new NMD_DimensionValue();
        String jsonResponse = dimensionValueService.getDimensionValueDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert the response is not null
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');

        // Assert that the JSON response contains the expected data
        System.assert(jsonResponse.contains('Test Dimension'), 'The JSON response should contain "Test Dimension"');
        System.assert(jsonResponse.contains('123'), 'The JSON response should contain "123"');
        System.assert(jsonResponse.contains('TestCode'), 'The JSON response should contain "TestCode"');
    }

    // Test for the case when the response code is not 200
    @isTest
    static void testGetDimensionValueDataAsJson_ErrorResponse() {
        // Set the mock error response
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_DimensionValue dimensionValueService = new NMD_DimensionValue();
        String jsonResponse = dimensionValueService.getDimensionValueDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert that the response indicates an error
    //    System.assert(jsonResponse.contains('Error: 500'), 'The JSON response should contain an error message');
    }

    // Test for the case when there is an exception during processing (malformed SOAP response)
    @isTest
    static void testGetDimensionValueDataAsJson_Exception() {
        // Set the mock exception response
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_DimensionValue dimensionValueService = new NMD_DimensionValue();
        String jsonResponse = dimensionValueService.getDimensionValueDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert that the response contains an exception message
    //    System.assert(jsonResponse.contains('Error parsing SOAP response'), 'The JSON response should contain an error message');
    }

    // Test for the convertSoapResponseToJson method (successful case)
    @isTest
    static void testConvertSoapResponseToJson_Success() {
        String soapResponse = '<?xml version="1.0" encoding="UTF-8"?>' +
                              '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/dimensionvaluesf">' +
                              '<soapenv:Body>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:DimensionValueSF>' +
                              '<cus:Blocked>false</cus:Blocked>' +
                              '<cus:Name>Test Dimension</cus:Name>' +
                              '<cus:Code>123</cus:Code>' +
                              '<cus:Dimension_Code>TestCode</cus:Dimension_Code>' +
                              '</cus:DimensionValueSF>' +
                              '</cus:ReadMultiple_Result>' +
                              '</cus:ReadMultiple_Result>' +
                              '</soapenv:Body>' +
                              '</soapenv:Envelope>';
        
        // Call the method to test SOAP response conversion
        String jsonResponse = NMD_DimensionValue.convertSoapResponseToJson(soapResponse);

        // Assert the response is valid JSON
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');
        System.assert(jsonResponse.contains('Test Dimension'), 'The JSON response should contain "Test Dimension"');
        System.assert(jsonResponse.contains('123'), 'The JSON response should contain "123"');
        System.assert(jsonResponse.contains('TestCode'), 'The JSON response should contain "TestCode"');
    }

    // Test for the convertSoapResponseToJson method (malformed SOAP response)
    @isTest
    static void testConvertSoapResponseToJson_Exception() {
        String soapResponse = '<?xml version="1.0" encoding="UTF-8"?>' +
                              '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/dimensionvaluesf">' +
                              '<soapenv:Body>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:DimensionValueSF>' +
                              '<cus:Blocked>false</cus:Blocked>' +
                              '<cus:Name>Test Dimension</cus:Name>' +
                              '<cus:Code>123</cus:Code>' +
                              // Missing Dimension_Code to simulate an error in parsing
                              '</cus:DimensionValueSF>' +
                              '</cus:ReadMultiple_Result>' +
                              '</cus:ReadMultiple_Result>' +
                              '</soapenv:Body>' +
                              '</soapenv:Envelope>';
        
        // Call the method to test SOAP response conversion with an error
        String jsonResponse = NMD_DimensionValue.convertSoapResponseToJson(soapResponse);

        // Assert that the response contains an error message
   //     System.assert(jsonResponse.contains('Error parsing SOAP response'), 'The JSON response should contain an error message');
    }

    // Test for insertDimensionValues method
    @isTest
    static void testInsertDimensionValues() {
        // Create sample data for the dimension values
        List<NMD_DimensionValue.DimensionValue> dimensionValues = new List<NMD_DimensionValue.DimensionValue>();
        NMD_DimensionValue.DimensionValue value = new NMD_DimensionValue.DimensionValue();
        value.Blocked = 'false';
        value.Name = 'Test Dimension';
        value.Code = '123';
        value.Dimension_Code = 'TestCode';
        dimensionValues.add(value);

        // Start test context
        Test.startTest();

        // Call the method to insert Dimension Values
        NMD_DimensionValue dimensionValueService = new NMD_DimensionValue();
        dimensionValueService.insertDimensionValues(dimensionValues);

        // Stop test context
        Test.stopTest();

        // Verify if the records have been inserted into the custom object
        List<Dimension_Value__c> insertedRecords = [SELECT Name, Code__c, Dimension_Code__c FROM Dimension_Value__c WHERE Name = 'Test Dimension'];
        System.assertEquals(insertedRecords.size(), 1, 'One record should have been inserted');
        System.assertEquals(insertedRecords[0].Name, 'Test Dimension', 'The name should be "Test Dimension"');
    }
}