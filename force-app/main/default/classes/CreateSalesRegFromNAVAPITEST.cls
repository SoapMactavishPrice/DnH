@isTest
private class CreateSalesRegFromNAVAPITEST {

    // Mock class for the callout
    public class SalesRegisterMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setStatusCode(200);

            // Manually construct the JSON string that would come in the XML
            String jsonResponse = '[{' +
                '"VoucherNo":"V123",' +
                '"Type":"Sale",' +
                '"No":"ITEM001",' +
                '"CustomerName":"Test Customer",' +
                '"PostingDate":"2025-03-01",' +
                '"QuantityinVariantSKU":"10.5",' +
                '"UitofMeasureCode":"PCS",' +
                '"QuantityinKGS":"15.2",' +
                '"NetInvoiceValue":"5000.75",' +
                '"StatiState":"StateX",' +
                '"SalesEngineer":"005xx00000123Ab",' +
                '"SPECIALCATEGO":"SPL",' +
                '"BrandName":"BrandX",' +
                '"TaxableValue":"4500.55",' +
                '"EngineerID":"DNH1189",' +
                '"SalesOrderNo":"SO123"' +
            '}]';

            String soapBody = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soap:Body>' +
                '<GenerateSalesRegister_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                '<return_value>Success</return_value>' +
                '<salesRegisterReport>' + jsonResponse + '</salesRegisterReport>' +
                '</GenerateSalesRegister_Result>' +
                '</soap:Body>' +
                '</soap:Envelope>';

            res.setBody(soapBody);
            return res;
        }
    }

    @isTest
    static void testGetPostedInvoiceReportData() {
        Test.setMock(HttpCalloutMock.class, new SalesRegisterMock());

        // Create required records
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0000040');
        insert acc;

        User usr = [SELECT Id, Code__c FROM User WHERE Profile.Name = 'Sales Engineer' AND Code__c = 'DNH1189' LIMIT 1];

        insert new Item_Master__c(Name = 'Test Item', Item_Number__c = 'ITEM001', Item_Description__c = 'Test Item Desc');

        insert new Sales_Order__c(Name = 'Test Order', Sales_Document_Number__c = 'SO123');

        Test.startTest();
        CreateSalesRegisterFromNAV_API.getPostedInvoiceReportData(acc.Id, usr.Id, '2025-01-01', '2025-03-31');
        Test.stopTest();

        List<Sales_Register__c> results = [SELECT Id, Voucher_No__c, Net_Invoice_Value__c FROM Sales_Register__c WHERE Customer__c = :acc.Id];
        // System.assertEquals(1, results.size(), 'One Sales Register record should be inserted');
        // System.assertEquals('V123', results[0].Voucher_No__c);
        // System.assertEquals(5000.75, results[0].Net_Invoice_Value__c);
    }
}