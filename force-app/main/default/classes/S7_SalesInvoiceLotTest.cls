@isTest
public class S7_SalesInvoiceLotTest {

    @isTest
    static void testExecute_SuccessfulResponse() {
        // Create test User
        User testUser = new User(
            Username = 'testuser7678363@test.com',
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserRoleId = null,
            Code__c = 'FieldEnggCode'
        );
        insert testUser;

        Code_Master__c cmm = new Code_Master__c();
        cmm.Name = 'Test Code';
        cmm.Object__c = 'Service 7-(Sample Feedbacks)';
        cmm.Current_Sequence__c = 1;
        cmm.Starting_Sequence__c = 1;
        cmm.FY_Start_Date__c = Date.valueOf('2024-01-01');
        cmm.FY_End_Date__c = Date.valueOf('2030-12-31');
        // cmm.Is_Active__c = true;
        insert cmm;

        Item_Master__c item1 = new Item_Master__c(
            Name = 'ELECTRODES SAMPLES (KG)',
            Item_Number__c = 'SMP0000150'
        );
        insert item1;

        Service_5_Sample_Request__c sampleRequest = new Service_5_Sample_Request__c(
            Name = 'Sample Request',
            Status__c = 'Submitted'
        );
        insert sampleRequest;

        Sample_Request_Product__c sampleProduct = new Sample_Request_Product__c(
            Name = 'Sample Product',
            Item_No__c = item1.Id,
            Description__c = 'Description for Item',
            Brand_Name__c = 'None',
            Size_mm__c = '2.50 X 350 MM',
            //Sample_Order_Number__c = 'Test123',
            Sample_Request__c = sampleRequest.Id,
            UOM__c = 'KGS'
        );
        insert sampleProduct;

        String invoiceLineItem = JSON.serialize(new Map<String, Object> {
            'Doc_No__c' => '1SAAC1/03922',
            'Item_No__c' => 'SMP0000150',
            'Line_No__c' => '2000',
            'Sample_Sales_Order_Number__c' => 'SMO21220276',
            'Description__c' => 'Sample Description',
            'Quantity__c' => '10',
            'Size__c' => '20',
            'Item_Brand__c' => 'BrandX',
            'UOM__c' => 'KG'
        });

        // Mock HTTP Response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true)); // Success scenario
        S7_SalesInvoiceLot.getInvoiceLot(invoiceLineItem, 'LR - TEST0001', Date.newInstance(2023, 12, 1), Date.newInstance(2023, 12, 2), 'CustomerName', 'FieldEnggCode');
        Test.stopTest();

        // Verify results
        List<Service_7_Sample_Feedbacks__c> feedbacks = [
            SELECT Id, Name FROM Service_7_Sample_Feedbacks__c WHERE InvoiceNo__c = '1SAAC1/03922'
        ];
    }

    @isTest
    static void testExecute_ErrorResponse() {
        // Create test User
        User testUser = new User(
            Username = 'testuser12376745@test.com',
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserRoleId = null,
            Code__c = 'FieldEnggCode'
        );
        insert testUser;

        String invoiceLineItem = JSON.serialize(new Map<String, Object> {
            'Doc_No__c' => 'INV456',
            'Item_No__c' => 'TestItemNo',
            'Line_No__c' => '1',
            'Sample_Sales_Order_Number__c' => 'TestOrderNo',
            'Description__c' => 'Sample Description',
            'Quantity__c' => '10',
            'Size__c' => '20',
            'Item_Brand__c' => 'BrandX',
            'UOM__c' => 'KG'
        });

        // Mock HTTP Response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false)); // Error scenario
        S7_SalesInvoiceLot.getInvoiceLot(invoiceLineItem, 'LR - TEST0001', Date.newInstance(2023, 12, 1), Date.newInstance(2023, 12, 2), 'CustomerName', 'FieldEnggCode');
        Test.stopTest();

        // Verify results
        List<API_Log__c> logs = [
            SELECT Id, Log_Status__c, Response__c FROM API_Log__c WHERE Log_Name__c = 'S7_SalesInvoice_Lot'
        ];
        System.assertEquals(1, logs.size());
        System.assertEquals('Failure', logs[0].Log_Status__c);
        System.assertEquals('Error: Unable to process the request.', logs[0].Response__c);
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        Boolean isSuccess;

        MockHttpResponseGenerator(Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');

            if (isSuccess) {
                res.setStatusCode(200);
                res.setBody('<?xml version="1.0" encoding="UTF-8"?>' +
                    '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                    '  <soap:Body>' +
                    '    <InsertGetSalesInvoiceLineLotServices7_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                    '     <return_value>1</return_value>' +
                    '      <returnValue>[{"LotNo": "14932","BatchQuantity": 10,"MfgDate": "","ExpirationDate": ""}]</returnValue>' +
                    '    </InsertGetSalesInvoiceLineLotServices7_Result>' +
                    '  </soap:Body>' +
                    '</soap:Envelope>');
            } else {
                res.setStatusCode(500);
                res.setBody('Error: Unable to process the request.');
            }

            return res;
        }
    }
}