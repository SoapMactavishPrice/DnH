@isTest
public class NMD_PaymentTermsTest {
    
    @isTest
    static void testGetPaymentTermsDataAsJson() {
        // Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create an instance of the class
        NMD_PaymentTerms paymentTerms = new NMD_PaymentTerms();
        
        // Call the method
        String jsonResponse = paymentTerms.getPaymentTermsDataAsJson();
        
    }
    
    @isTest
    static void testConvertSoapResponseToJson() {
        // Sample SOAP response
        String soapResponse = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/paymenttermssf">' +
                              '<soapenv:Body>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:ReadMultiple_Result>' +
                              '<cus:PaymentTermsSF>' +
                              '<cus:Name>Net 30</cus:Name>' +
                              '<cus:Code>NET30</cus:Code>' +
                              '<cus:Description>Payment due in 30 days</cus:Description>' +
                              '</cus:PaymentTermsSF>' +
                              '</cus:ReadMultiple_Result>' +
                              '</cus:ReadMultiple_Result>' +
                              '</soapenv:Body>' +
                              '</soapenv:Envelope>';
        
        // Call the method
        String jsonResponse = NMD_PaymentTerms.convertSoapResponseToJson(soapResponse);
        
    }
    
    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/paymenttermssf">' +
                        '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:ReadMultiple_Result>' +
                        '<cus:PaymentTermsSF>' +
                        '<cus:Name>Net 30</cus:Name>' +
                        '<cus:Code>NET30</cus:Code>' +
                        '<cus:Description>Payment due in 30 days</cus:Description>' +
                        '</cus:PaymentTermsSF>' +
                        '</cus:ReadMultiple_Result>' +
                        '</cus:ReadMultiple_Result>' +
                        '</soapenv:Body>' +
                        '</soapenv:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }
}