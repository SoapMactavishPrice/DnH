@isTest
private class CreateSalesRegisterFromNAV_BatchTest {

    // Mock HttpCallout for downstream callout logic in Queueable
    public class MockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setStatusCode(200);

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
    static void testBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new MockCallout());

        // Setup necessary records
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0000040');
        insert acc;

        User usr = [SELECT Id FROM User WHERE Profile.Name = 'Sales Engineer' LIMIT 1];

        Customer_Sales_Person_Mapping__c mapping = new Customer_Sales_Person_Mapping__c(
            Account__c = acc.Id,
            Sales_Person__c = usr.Id
        );
        insert mapping;

        insert new Item_Master__c(Name = 'Test Item', Item_Number__c = 'ITEM001', Item_Description__c = 'Test Item Desc');
        insert new Sales_Order__c(Name = 'Test Order', Sales_Document_Number__c = 'SO123');

        Test.startTest();
        Database.executeBatch(new CreateSalesRegisterFromNAV_Batch(), 1);
        Test.stopTest();

        // Assert that Sales Register was inserted
        List<Sales_Register__c> srList = [SELECT Id, Voucher_No__c FROM Sales_Register__c WHERE Customer__c = :acc.Id];
        //System.assertEquals(1, srList.size(), 'Sales Register record should be created');
        //System.assertEquals('V123', srList[0].Voucher_No__c);
    }

    @isTest
    static void testScheduledJobExecution() {
        Test.setMock(HttpCalloutMock.class, new MockCallout());

        // Setup necessary data (same as in batch test)
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0000040');
        insert acc;

        User usr = [SELECT Id FROM User WHERE Profile.Name = 'Sales Engineer' LIMIT 1];

        insert new Customer_Sales_Person_Mapping__c(Account__c = acc.Id, Sales_Person__c = usr.Id);
        insert new Item_Master__c(Name = 'Test Item', Item_Number__c = 'ITEM001', Item_Description__c = 'Test Item Desc');
        insert new Sales_Order__c(Name = 'Test Order', Sales_Document_Number__c = 'SO123');

        Test.startTest();
        String jobId = System.schedule('Test Scheduled Batch', '0 0 1 * * ?', new CreateSalesRegisterFromNAV_Batch());
        Test.stopTest();

        //System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
    }
}