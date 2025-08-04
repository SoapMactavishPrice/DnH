@isTest
public class NMD_HSNSACCodeTest {
    
    @isTest
    static void testGetHSNSACCodeDataAsJson() {
        // Mock the HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                    '<soapenv:Body>' +
                    '<ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/hsnsaccodesf">' +
                    '<ReadMultiple_Result>' +
                    '<HSNSACCodeSF>' +
                    '<Type>HSN</Type>' +
                    '<Description>PNG GAS</Description>' +
                    '<Code>2711</Code>' +
                    '<GST_Group_Code>G-GST 0</GST_Group_Code>' +
                    '</HSNSACCodeSF>' +
                    '</ReadMultiple_Result>' +
                    '</ReadMultiple_Result>' +
                    '</soapenv:Body>' +
                    '</soapenv:Envelope>');
        res.setStatusCode(200);
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));
        
        // Call the method
        NMD_HSNSACCode nmd = new NMD_HSNSACCode();
        String jsonResponse = nmd.getHSNSACCodeDataAsJson();
        
        // Verify the response
        System.assert(jsonResponse.contains('"Type":"HSN"'));
        System.assert(jsonResponse.contains('"Description":"PNG GAS"'));
        System.assert(jsonResponse.contains('"Code":"2711"'));
        System.assert(jsonResponse.contains('"GST_Group_Code":"G-GST 0"'));
        
        // Verify the records were inserted
        List<HSN_Master__c> hsnMasterList = [SELECT Type__c, Description__c, Code__c, GST_Group_Code__c FROM HSN_Master__c];
        System.assertEquals(1, hsnMasterList.size());
        System.assertEquals('HSN', hsnMasterList[0].Type__c);
        System.assertEquals('PNG GAS', hsnMasterList[0].Description__c);
        System.assertEquals('2711', hsnMasterList[0].Code__c);
        System.assertEquals('G-GST 0', hsnMasterList[0].GST_Group_Code__c);
    }
    
    @isTest
    static void testConvertSoapResponseToJson() {
        String soapResponse = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                              '<soapenv:Body>' +
                              '<ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/hsnsaccodesf">' +
                              '<ReadMultiple_Result>' +
                              '<HSNSACCodeSF>' +
                              '<Type>HSN</Type>' +
                              '<Description>PNG GAS</Description>' +
                              '<Code>2711</Code>' +
                              '<GST_Group_Code>G-GST 0</GST_Group_Code>' +
                              '</HSNSACCodeSF>' +
                              '</ReadMultiple_Result>' +
                              '</ReadMultiple_Result>' +
                              '</soapenv:Body>' +
                              '</soapenv:Envelope>';
        
        String jsonResponse = NMD_HSNSACCode.convertSoapResponseToJson(soapResponse);
        
        // Verify the JSON response
        System.assert(jsonResponse.contains('"Type":"HSN"'));
        System.assert(jsonResponse.contains('"Description":"PNG GAS"'));
        System.assert(jsonResponse.contains('"Code":"2711"'));
        System.assert(jsonResponse.contains('"GST_Group_Code":"G-GST 0"'));
    }
    
    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse res;
        
        public MockHttpResponseGenerator(HttpResponse res) {
            this.res = res;
        }
        
        public HttpResponse respond(HttpRequest req) {
            return res;
        }
    }
}