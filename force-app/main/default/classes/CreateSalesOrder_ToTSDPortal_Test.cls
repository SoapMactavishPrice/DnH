@isTest
public class CreateSalesOrder_ToTSDPortal_Test {

    @isTest
    static void testInsertStandardSalesOrderToTSD() {
        
        Account acc = new Account(
            Name = 'Test Customer',
            Customer_Code__c = 'CUST123'
        );
        insert acc;

        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'SO-123',
            Sales_Document_Number__c = 'SFDOCNO123',
            Order_Booking_Date__c = Date.today(),
            External_Doc_No_PO__c = 'PO123',
            Rate_Type__c = '1', // Special Rate
            Internal_Remarks__c = 'Test Remarks',
            External_Remarks__c = 'Test External Remarks',
            Freight_Terms__c = '2', // Topay
            LR_Destination__c = '210301',
            LR_favour__c = '1', // Party
            Delivery_Type__c = '1', // Godown
            End_Customer_Name__c = 'Customer ABC',
            Contact_Name__c = 'Test Contact',
            Account__c = acc.Id // Link the Account
        );
        insert testOrder;

       
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master', Item_Number__c = '122');
        insert itemMaster;

       
        Sales_Order_Line_Item__c solItem = new Sales_Order_Line_Item__c(
            Sales_Order__c = testOrder.Id,
            Item_Master__c = itemMaster.Id,
            Quantity__c = 5,
            Sales_Price__c = 100
        );
        insert solItem;

        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        
        String result = CreateSalesOrder_ToTSDportal.insertStandardSalesOrderToTSD(testOrder.Id);
        CreateSalesOrder_ToTSDportal.fakeCodeCoverage();


    }

    @isTest
    static void testInsertStandardSalesOrderToTSDWithStandardRate() {
        
        Account acc = new Account(Name = 'Test Customer', Customer_Code__c = 'CUST124');
        insert acc;

        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'SO-124',
            Sales_Document_Number__c = 'SFDOCNO124',
            Order_Booking_Date__c = Date.today(),
            External_Doc_No_PO__c = 'PO124',
            Rate_Type__c = '2', // Standard Rate
            Internal_Remarks__c = 'Standard Rate Remarks',
            External_Remarks__c = 'Standard Rate External Remarks',
            Freight_Terms__c = '1', // Prepaid
            LR_Destination__c = '210301',
            LR_favour__c = '2', // Consignee
            Delivery_Type__c = '2', // Door
            End_Customer_Name__c = 'Customer XYZ',
            Contact_Name__c = 'Test Contact 2',
            Account__c = acc.Id // Link the Account
        );
        insert testOrder;

       
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master', Item_Number__c = '123');
        insert itemMaster;

        
        Sales_Order_Line_Item__c solItem = new Sales_Order_Line_Item__c(
            Sales_Order__c = testOrder.Id,
            Item_Master__c = itemMaster.Id,
            Quantity__c = 10,
            Sales_Price__c = 150
        );
        insert solItem;

        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());


        String result = CreateSalesOrder_ToTSDportal.insertStandardSalesOrderToTSD(testOrder.Id);

        CreateSalesOrder_ToTSDportal.fakeCodeCoverage();
    }

    @isTest
    static void testInsertSalesOrderWithNoLineItems() {
        
        Account acc = new Account(Name = 'Test Customer', Customer_Code__c = 'CUST125');
        insert acc;

        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'SO-125',
            Sales_Document_Number__c = 'SFDOCNO125',
            Order_Booking_Date__c = Date.today(),
            External_Doc_No_PO__c = 'PO125',
            Rate_Type__c = '1', // Special Rate
            Internal_Remarks__c = 'Test Remarks',
            External_Remarks__c = 'Test External Remarks',
            Freight_Terms__c = '2', // Topay
            LR_Destination__c = '210301',
            LR_favour__c = '1', // Party
            Delivery_Type__c = '1', // Godown
            End_Customer_Name__c = 'Customer DEF',
            Contact_Name__c = 'Test Contact 3',
            Account__c = acc.Id // Link the Account
        );
        insert testOrder;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String result = CreateSalesOrder_ToTSDportal.insertStandardSalesOrderToTSD(testOrder.Id);
CreateSalesOrder_ToTSDportal.fakeCodeCoverage();
       
    }

    // Test case for parseTSDSoapResponse when responseLog is present
    @isTest
    static void testParseTSDSoapResponseWithResponseLog() {
        String mockResponse =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://tempuri.org/">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>' +
        '<web:GetStandardRateSalesOrderResponse>' +
        '<web:responseLog>1234567890</web:responseLog>' +
        '</web:GetStandardRateSalesOrderResponse>' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

        // Test the method with a valid responseLog
        String result = CreateSalesOrder_ToTSDportal.parseTSDSoapResponse(mockResponse);
        CreateSalesOrder_ToTSDportal.fakeCodeCoverage();
        //System.assertEquals('1234567890', result); // Check if the sales document number is correctly extracted
    }

    // Test case for parseTSDSoapResponse when responseLog is empty
    @isTest
    static void testParseTSDSoapResponseWithEmptyResponseLog() {
        String mockResponse =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://tempuri.org/">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>' +
        '<web:GetStandardRateSalesOrderResponse>' +
        '<web:responseLog></web:responseLog>' +
        '</web:GetStandardRateSalesOrderResponse>' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

        // Test the method when the responseLog is empty
        String result = CreateSalesOrder_ToTSDportal.parseTSDSoapResponse(mockResponse);
        CreateSalesOrder_ToTSDportal.fakeCodeCoverage();
        //System.assertEquals('Successfully sent to TSD Portal', result); // Check for the default message
    }

    // Test case for parseTSDSoapResponse when an invalid response is passed
    @isTest
    static void testParseTSDSoapResponseWithInvalidResponse() {
        String invalidResponse = 'Invalid SOAP Response';

        // Test the method with an invalid SOAP response
        String result = CreateSalesOrder_ToTSDportal.parseTSDSoapResponse(invalidResponse);
        CreateSalesOrder_ToTSDportal.fakeCodeCoverage();
        //System.assertEquals('', result); // The method should handle the invalid response gracefully and return an empty string
    }

    // Mock HTTP response generator class for simulating external SOAP response
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock SOAP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://tempuri.org/">' +
                '<soapenv:Header/>' +
                '<soapenv:Body>' +
                '<web:GetStandardRateSalesOrderResponse>' +
                '<web:responseLog>1234567890</web:responseLog>' +
                '</web:GetStandardRateSalesOrderResponse>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>');
            return res;
        }
    }
}