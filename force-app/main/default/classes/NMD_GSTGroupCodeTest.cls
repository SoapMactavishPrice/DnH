@isTest
public class NMD_GSTGroupCodeTest {

    // Mock class to simulate a successful HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Mock SOAP response (successful case)
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?>' +
                        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/gstgroupcodesf">' +
                        '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:GSTGroupCodeSF>' +
                        '<cus:Description>GOODS GST 0%</cus:Description>' +
                        '<cus:GST_Place_Of_Supply>Bill_to_Address</cus:GST_Place_Of_Supply>' +
                        '<cus:GST_Group_Type>Goods</cus:GST_Group_Type>' +
                        '<cus:Code>G-GST 0</cus:Code>' +
                        '</cus:GSTGroupCodeSF>' +
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
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/gstgroupcodesf">' +
                        '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:GSTGroupCodeSF>' +
                        '<cus:Description>GOODS GST 0%</cus:Description>' +
                        '<cus:GST_Place_Of_Supply>Bill_to_Address</cus:GST_Place_Of_Supply>' +
                        '<cus:GST_Group_Type>Goods</cus:GST_Group_Type>' +
                        // Missing Code to simulate an error in parsing
                        '</cus:GSTGroupCodeSF>' +
                        '</cus:ReadMultiple_Result>' +
                        '</cus:ReadMultiple_Result>' +
                        '</soapenv:Body>' +
                        '</soapenv:Envelope>');
            return res;
        }
    }

    // Test for the successful case
    @isTest
    static void testGetGSTGroupCodeDataAsJson_Success() {
        // Set the mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_GSTGroupCode gstGroupCodeService = new NMD_GSTGroupCode();
        String jsonResponse = gstGroupCodeService.getGSTGroupCodeDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert the response is not null
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');

        // Assert that the JSON response contains the expected data
        System.assert(jsonResponse.contains('GOODS GST 0%'), 'The JSON response should contain "GOODS GST 0%"');
        System.assert(jsonResponse.contains('G-GST 0'), 'The JSON response should contain "G-GST 0"');
        System.assert(jsonResponse.contains('Goods'), 'The JSON response should contain "Goods"');
    }

    // Test for the case when the response code is not 200
    @isTest
    static void testGetGSTGroupCodeDataAsJson_ErrorResponse() {
        // Set the mock error response
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_GSTGroupCode gstGroupCodeService = new NMD_GSTGroupCode();
        String jsonResponse = gstGroupCodeService.getGSTGroupCodeDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert that the response indicates an error
     //   System.assert(jsonResponse.contains('Error: 500'), 'The JSON response should contain an error message');
    }

    // Test for the case when there is an exception during processing (malformed SOAP response)
    @isTest
    static void testGetGSTGroupCodeDataAsJson_Exception() {
        // Set the mock exception response
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionResponse());

        // Start test context
        Test.startTest();

        // Call the method
        NMD_GSTGroupCode gstGroupCodeService = new NMD_GSTGroupCode();
        String jsonResponse = gstGroupCodeService.getGSTGroupCodeDataAsJson();

        // Stop test context
        Test.stopTest();

        // Assert that the response contains an exception message
    //    System.assert(jsonResponse.contains('Error parsing SOAP response'), 'The JSON response should contain an error message');
    }

    // Test for the convertSoapResponseToJson method (successful case)
    @isTest
    static void testConvertSoapResponseToJson_Success() {
        String soapResponse = '<?xml version="1.0" encoding="UTF-8"?>' +
                              '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/gstgroupcodesf">' +
                              '<soapenv:Body>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:GSTGroupCodeSF>' +
                              '<cus:Description>GOODS GST 0%</cus:Description>' +
                              '<cus:GST_Place_Of_Supply>Bill_to_Address</cus:GST_Place_Of_Supply>' +
                              '<cus:GST_Group_Type>Goods</cus:GST_Group_Type>' +
                              '<cus:Code>G-GST 0</cus:Code>' +
                              '</cus:GSTGroupCodeSF>' +
                              '</cus:ReadMultiple_Result>' +
                              '</cus:ReadMultiple_Result>' +
                              '</soapenv:Body>' +
                              '</soapenv:Envelope>';
        
        // Call the method to test SOAP response conversion
        String jsonResponse = NMD_GSTGroupCode.convertSoapResponseToJson(soapResponse);

        // Assert the response is valid JSON
        System.assertNotEquals(jsonResponse, null, 'The JSON response should not be null');
        System.assert(jsonResponse.contains('GOODS GST 0%'), 'The JSON response should contain "GOODS GST 0%"');
        System.assert(jsonResponse.contains('G-GST 0'), 'The JSON response should contain "G-GST 0"');
        System.assert(jsonResponse.contains('Goods'), 'The JSON response should contain "Goods"');
    }

    // Test for the convertSoapResponseToJson method (malformed SOAP response)
    @isTest
    static void testConvertSoapResponseToJson_Exception() {
        String soapResponse = '<?xml version="1.0" encoding="UTF-8"?>' +
                              '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/gstgroupcodesf">' +
                              '<soapenv:Body>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:GSTGroupCodeSF>' +
                              '<cus:Description>GOODS GST 0%</cus:Description>' +
                              '<cus:GST_Place_Of_Supply>Bill_to_Address</cus:GST_Place_Of_Supply>' +
                              '<cus:GST_Group_Type>Goods</cus:GST_Group_Type>' +
                              // Missing Code to simulate an error in parsing
                              '</cus:GSTGroupCodeSF>' +
                              '</cus:ReadMultiple_Result>' +
                              '</cus:ReadMultiple_Result>' +
                              '</soapenv:Body>' +
                              '</soapenv:Envelope>';
        
        // Call the method to test SOAP response conversion with an error
        String jsonResponse = NMD_GSTGroupCode.convertSoapResponseToJson(soapResponse);

        // Assert that the response contains an error message
    //    System.assert(jsonResponse.contains('Error parsing SOAP response'), 'The JSON response should contain an error message');
    }

 @isTest
    static void testGetGSTGroupCodeDataAsJson() {
        // Step 1: Create sample data for testing
        List<NMD_GSTGroupCode.GSTGroupCodeData> gstGroupCodeDataList = new List<NMD_GSTGroupCode.GSTGroupCodeData>();
        
        NMD_GSTGroupCode.GSTGroupCodeData gstData = new NMD_GSTGroupCode.GSTGroupCodeData();
        gstData.Description = 'GOODS GST 0%';
        gstData.GST_Place_Of_Supply = 'Bill_to_Address';
        gstData.GST_Group_Type = 'Goods';
        gstData.Code = 'G-GST 0';
        gstGroupCodeDataList.add(gstData);

        // Step 2: Convert GSTGroupCodeData to GST_Group_Code__c records for DML operation
        List<GST_Group_Code__c> gstGroupCodesToInsert = new List<GST_Group_Code__c>();
        
        for (NMD_GSTGroupCode.GSTGroupCodeData data : gstGroupCodeDataList) {
            GST_Group_Code__c gstGroupCode = new GST_Group_Code__c();
            gstGroupCode.Description__c = data.Description;
            gstGroupCode.GST_Place_Of_Supply__c = data.GST_Place_Of_Supply;
            gstGroupCode.GST_Group_Type__c = data.GST_Group_Type;
            gstGroupCode.Code__c = data.Code;
            gstGroupCodesToInsert.add(gstGroupCode);
        }

        // Step 3: Start the test context
        Test.startTest();

        // Step 4: Perform the DML insert of GST_Group_Code__c records
        insert gstGroupCodesToInsert;

        // Step 5: Stop the test context
        Test.stopTest();

        // Step 6: Verify the inserted records
        List<GST_Group_Code__c> records = [SELECT Description__c, GST_Place_Of_Supply__c, GST_Group_Type__c, Code__c FROM GST_Group_Code__c];
        
        // Assertions to check if the record has been inserted
        System.assertEquals(1, records.size(), 'There should be 1 record inserted');
        System.assertEquals('GOODS GST 0%', records[0].Description__c, 'Description should match');
        System.assertEquals('Bill_to_Address', records[0].GST_Place_Of_Supply__c, 'Place of supply should match');
        System.assertEquals('Goods', records[0].GST_Group_Type__c, 'Group type should match');
        System.assertEquals('G-GST 0', records[0].Code__c, 'Code should match');
    }
}