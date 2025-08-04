@isTest
public class S7_SalesInvoiceLine_Test {
    @isTest
    static void testGetInvoiceLineItem_Success() {
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new S7_SalesInvoiceLineMock());

        // Sample JSON for the test
        String testJSON = '{"Name":"12345"}';

        Test.startTest();
        S7_SalesInvoiceLine.getInvoiceLineitem(testJSON);
        Test.stopTest();

        // Verify API_Log__c was created
        API_Log__c log = [SELECT Log_Name__c, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'S7_SalesInvoice_Line' LIMIT 1];
       // System.assertEquals('Success', log.Log_Status__c, 'Log status should be Success');
        //System.assertEquals('200', log.Response_Code__c, 'Response code should be 200');
    }

    @isTest
    static void testGetInvoiceLineItem_Failure() {
        // Mock HTTP callout with a failure response
        Test.setMock(HttpCalloutMock.class, new S7_SalesInvoiceLineMock_Failure());

        // Sample JSON for the test
        String testJSON = '{"Name":"1SAAC1/03927"}';

        Test.startTest();
        S7_SalesInvoiceLine.getInvoiceLineitem(testJSON);
        Test.stopTest();

        // Verify API_Log__c was created with failure details
        API_Log__c log = [SELECT Log_Name__c, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'S7_SalesInvoice_Line' LIMIT 1];
        System.assertEquals('Failure', log.Log_Status__c, 'Log status should be Failure');
        System.assertEquals('400', log.Response_Code__c, 'Response code should indicate failure');
    }
    
   
public class S7_SalesInvoiceLineMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '  <soapenv:Body>' +
            '    <InsertGetSalesInvoiceLineServices7_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
            '     <return_value>1</return_value>' +
            '     <returnValue>[{"DocNo": "1SAAC1/03927","ItemNo": "SMP0000160","LineNo": 20000,"Description": "SUPRATHERME 2.50 X 350","Description2": "SUPRATHERME 2.50 X 350(150PCS)","SamplesSalesOrderNo": "SMO21220289","Quantity": 10,"SIZE": "NA","ItemBrand": "NA","UOM": "PCS"}]</returnValue>' +
            '    </InsertGetSalesInvoiceLineServices7_Result>' +
            '  </soapenv:Body>' +
            '</soapenv:Envelope>'
        );
        // {"DocNo": "1SAAC1/03927","ItemNo": "SMP0000160","LineNo": 20000,"Description": "SUPRATHERME 2.50 X 350","Description2": "SUPRATHERME 2.50 X 350(150PCS)","SamplesSalesOrderNo": "SMO21220289","Quantity": 10,"SIZE": "NA","ItemBrand": "NA","UOM": "PCS"}
        res.setStatusCode(200);
        return res;
    }
}
    
   
public class S7_SalesInvoiceLineMock_Failure implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(400);
        res.setBody('{"error":"Bad Request"}');
        return res;
    }
}


}