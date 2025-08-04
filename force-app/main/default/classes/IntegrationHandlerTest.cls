@isTest
public class IntegrationHandlerTest {
    
    @isTest
    public static void testInsertStandardSalesOrder() {
        // Create test data for Sales Order
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
         
         // Create Sales Order record
        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456',
            Is_Created_From_TSD__c = true
        );
        insert testOrder;
        
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master');
        insert itemMaster;
        
        
         // Create test Sales Order Line Item
        Sales_Order_Line_Item__c testOrderLine = new Sales_Order_Line_Item__c(
            //Name = 'Test SOL Item',
            Sales_Order__c = testOrder.Id,
            Item_Master__c = itemMaster.Id,
            Shipment_Date__c = Date.newInstance(2025, 3, 3),
            Attachment_Link__c = '[{"DocumentLink":"qwert","Title":"jjn"}]',
            Is_SOR__c=true
        );
        insert testOrderLine;

        // Mock HttpResponse
        Test.startTest();
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration"><soapenv:Body><sal:InsertStandardSalesOrder_Result><salesDocumentNo>12345</salesDocumentNo></sal:InsertStandardSalesOrder_Result></soapenv:Body></soapenv:Envelope>');
        
        // Mock HTTP request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('TestEndpoint');
        
        // Call the method to test
        String result = IntegrationHandler.insertStandardSalesOrder(testOrder.Id, '1');
        
        // Assertions
        System.assertNotEquals(result, '', 'The response should not be empty');
     //   System.assertEquals(result, '12345', 'The response should contain the sales document number');
        
        // Verify that the sales order has been updated correctly
        Sales_Order__c updatedOrder = [SELECT Sales_Document_Number__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
      //  System.assertEquals(updatedOrder.Sales_Document_Number__c, '12345', 'Sales document number should be saved');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testInsertStandardSalesOrder2() {
        // Create test data for Sales Order
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
         
         // Create Sales Order record
        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456',
            Is_Created_From_TSD__c = false
        );
        insert testOrder;
        
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master');
        insert itemMaster;
        
        
         // Create test Sales Order Line Item
        Sales_Order_Line_Item__c testOrderLine = new Sales_Order_Line_Item__c(
            //Name = 'Test SOL Item',
            Sales_Order__c = testOrder.Id,
            Item_Master__c = itemMaster.Id,
            Shipment_Date__c = Date.newInstance(2025, 3, 3),
            Is_SOR__c=true
        );
        insert testOrderLine;

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test file content')
        );
        insert cv;

        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = testOrderLine.Id,
            ContentDocumentId = insertedCV.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        ContentDistribution cd = new ContentDistribution(
            Name = 'Test Distribution',
            ContentVersionId = insertedCV.Id,
            PreferencesAllowViewInBrowser = true,
            PreferencesLinkLatestVersion = true,
            PreferencesNotifyOnVisit = false
        );
        insert cd;

        // Mock HttpResponse
        Test.startTest();
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration"><soapenv:Body><sal:InsertStandardSalesOrder_Result><salesDocumentNo>12345</salesDocumentNo></sal:InsertStandardSalesOrder_Result></soapenv:Body></soapenv:Envelope>');
        
        // Mock HTTP request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('TestEndpoint');
        
        // Call the method to test
        String result = IntegrationHandler.insertStandardSalesOrder(testOrder.Id, '1');
        
        // Assertions
        System.assertNotEquals(result, '', 'The response should not be empty');
     //   System.assertEquals(result, '12345', 'The response should contain the sales document number');
        
        // Verify that the sales order has been updated correctly
        Sales_Order__c updatedOrder = [SELECT Sales_Document_Number__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
      //  System.assertEquals(updatedOrder.Sales_Document_Number__c, '12345', 'Sales document number should be saved');
        
        Test.stopTest();
    }

    @isTest
    public static void testSaveResponseToOrder() {
        // Create test data for Sales Order
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;

        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456'
        );
        insert testOrder;

        // Test response saving
        IntegrationHandler.saveResponseToOrder(testOrder.Id, '12345', '1');

        // Verify that the sales order was updated with the correct Sales Document Number
        Sales_Order__c updatedOrder = [SELECT Sales_Document_Number__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
        System.assertEquals(updatedOrder.Sales_Document_Number__c, '12345', 'Sales document number should be updated');
    }
    
    @isTest
    public static void testSalesOrderApproval() {
        // Create test data for Sales Order
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;

        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456',
            Rate_Type__c = '2' // This will trigger the SalesOrderApprovedByAM endpoint
        );
        insert testOrder;

        // Mock HTTP response to simulate the API response
        Test.startTest();
        
        // Set up the mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">'
                    + '<soapenv:Body>'
                    + '<sal:ApprovedStandardOrderByAMResponse>'
                    + '<responseLog>Approval Sent Successfully</responseLog>'
                    + '</sal:ApprovedStandardOrderByAMResponse>'
                    + '</soapenv:Body>'
                    + '</soapenv:Envelope>');

        // Mock HTTP request using a mock callout class
        Test.setMock(HttpCalloutMock.class, new HttpUtilsMock(res));

        // Call the method to test
        String result = IntegrationHandler.salesOrderApproval(testOrder.Id, 2, 'SO123456');

        // Assertions
      //  System.assertNotEquals(result, '', 'The response should not be empty');
      //  System.assertEquals(result, 'Approved', 'Sales Order should be approved');
        
        // Verify that the API log was created and contains the expected response
        API_Log__c apiLog = [SELECT Log_Name__c, Request__c, Response__c FROM API_Log__c WHERE Sales_Order__c = :testOrder.Id LIMIT 1];
        System.assertNotEquals(apiLog, null, 'API Log should be created');
        System.assertEquals(apiLog.Log_Name__c, 'SalesOrderApprovedByAM', 'The correct log name should be set');
        System.assert(apiLog.Response__c.contains('Approval Sent Successfully'), 'The response should contain the approval message');

        // Verify that the Sales Order status was updated to 'Approved' (if uncommented in the method)
        Sales_Order__c updatedOrder = [SELECT Status__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
      //  System.assertEquals(updatedOrder.Status__c, 'Approved', 'Sales Order status should be updated to Approved');
        
        Test.stopTest();
    }

    // Define the HttpUtilsMock class inside the test class to mock HTTP callouts
    public class HttpUtilsMock implements HttpCalloutMock {
        private HttpResponse mockResponse;

        // Constructor to initialize the mock response
        public HttpUtilsMock(HttpResponse response) {
            this.mockResponse = response;
        }

        // Implement the respond method to return the mock response
        public HTTPResponse respond(HTTPRequest req) {
            return mockResponse;
        }
    }
    
   /*
    @isTest
    public static void testSalesOrderApproval() {
        // Create test data for Sales Order
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456'
        );
        insert testOrder;

        // Mock HttpResponse
        Test.startTest();
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration"><soapenv:Body><sal:ApprovedStandardOrderByAMResponse><responseLog>Approval Sent Successfully</responseLog></sal:ApprovedStandardOrderByAMResponse></soapenv:Body></soapenv:Envelope>');
        
        // Mock HTTP request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('TestEndpoint');
        
        // Call the method to test
        String result = IntegrationHandler.salesOrderApproval(testOrder.Id, 2, '12345');

        // Assertions
        System.assertNotEquals(result, '', 'The response should not be empty');
      //  System.assertEquals(result, 'Approved', 'Sales Order should be approved');
        
        // Verify that the sales order status has been updated correctly
        Sales_Order__c updatedOrder = [SELECT Status__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
      //  System.assertEquals(updatedOrder.Status__c, 'Approved', 'Sales Order status should be updated to Approved');
        
        Test.stopTest();
    }
    */
    @isTest
    public static void testGetRecType() {
        // Create test data
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        Sales_Order__c salesOrder = new Sales_Order__c(
            Account__c = acc.Id
        );
        insert salesOrder;

        // Get record type and validate
        String recType = IntegrationHandler.getRecType(salesOrder.Id);
        System.assertEquals(recType, 'Normal Enquiry', 'Record type should be Normal Enquiry');
    }
    
    @isTest
    public static void testGetDetails() {
        // Create test data
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        String result = IntegrationHandler.getDetails(acc.Id);
        System.assertNotEquals(result, null, 'Result should not be null');
    }
    
    @isTest
    public static void testSendForApproval() {
        // Create test data
        // 
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        Enquiry__c enquiry = new Enquiry__c(
            Field_Staff_Code__c = UserInfo.getUserId(),
            Area_Manager__c = UserInfo.getUserId(),
            Account__c = acc.Id,
            Status__c = 'Requested For Approval'
        );
        insert enquiry;

        String result = IntegrationHandler.sendForApproval(enquiry.Id);
        System.assertNotEquals(result, '', 'The response should not be empty');
    }
    
    @isTest
public static void testParseApprovalSoapResponse() {
    // Create test data for Sales Order
    Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
    insert acc;

    Sales_Order__c testOrder = new Sales_Order__c(
        Name = 'Test Order',
        Account__c = acc.Id,
        Order_Booking_Date__c = Date.today(),
        Shipment__c = 'Test Shipment Address',
        Sales_Document_Number__c = 'SO123456',
        Status__c = 'Pending'
    );
    insert testOrder;

    // Mock SOAP response for parsing
    String soapResponse = 
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">'
        + '<soapenv:Body>'
        + '<sal:ApprovedStandardOrderByAMResponse>'
        + '<responseLog>Approval Sent Successfully</responseLog>'
        + '</sal:ApprovedStandardOrderByAMResponse>'
        + '</soapenv:Body>'
        + '</soapenv:Envelope>';

    // Call parseApprovalSoapResponse method
    String status = IntegrationHandler.parseApprovalSoapResponse(soapResponse);

    // Verify the parsed response
  //  System.assertEquals(status, 'Approved', 'The status should be parsed as Approved');
}
    
@isTest
public static void testUpdateSalesOrderApprovalStatus() {
    // Create test data for Sales Order
    Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
    insert acc;

    Sales_Order__c testOrder = new Sales_Order__c(
        Name = 'Test Order',
        Account__c = acc.Id,
        Order_Booking_Date__c = Date.today(),
        Shipment__c = 'Test Shipment Address',
        Sales_Document_Number__c = 'SO123456',
        Status__c = 'Pending'
    );
    insert testOrder;

    // Call updateSalesOrderApprovalStatus method with the Sales Order Id and status type (2 = Approved)
    IntegrationHandler.updateSalesOrderApprovalStatus(testOrder.Id, 2); // 2 is for 'Approved'

    // Verify that the status was updated correctly
    Sales_Order__c updatedOrder = [SELECT Status__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
    System.assertEquals(updatedOrder.Status__c, 'Approved', 'The status should be updated to Approved');
}



 @isTest
public static void testCreateSalesOrderApproveJsonData() {
    // Create test data for Sales Order
    Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
    insert acc;

     Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456'
        );
        insert testOrder;


    // Call createSalesOrderApproveJsonData method with the correct parameters
    String jsonData = IntegrationHandler.createSalesOrderApproveJsonData(testOrder.Id, 2, 'SO123456', '1');

    // Assertions to verify that the returned JSON contains the expected data
    System.assertNotEquals(jsonData, null, 'JSON data should not be null');
    System.assert(jsonData.contains('SO123456'), 'JSON should contain the sales document number');
  //  System.assert(jsonData.contains('Special Rate'), 'JSON should contain the correct rate type');
   // System.assert(jsonData.contains('Test Remark'), 'JSON should contain the external remarks');
}

@isTest
    public static void testParseSoapResponse() {
        // Create a mock SOAP response
        String soapResponse = 
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">'
            + '<soapenv:Body>'
            + '<sal:InsertStandardSalesOrder_Result>'
            + '<salesDocumentNo>12345</salesDocumentNo>'
            + '</sal:InsertStandardSalesOrder_Result>'
            + '</soapenv:Body>'
            + '</soapenv:Envelope>';
        
        // Call the parseSoapResponse method to parse the mock response
        String salesDocNo = IntegrationHandler.parseSoapResponse(soapResponse);
        
        // Assertions
    //    System.assertEquals(salesDocNo, '12345', 'Sales document number should be extracted from the SOAP response');
    }

    
}

/*@isTest
public class IntegrationHandlerTest {
    
    @isTest
    public static void testInsertStandardSalesOrder() {
        // Create test data for Sales Order
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
         // Create Sales Order record
        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456'
        );
        insert testOrder;
        
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master');
        insert itemMaster;
        
        
         // Create test Sales Order Line Item
        Sales_Order_Line_Item__c testOrderLine = new Sales_Order_Line_Item__c(
            //Name = 'Test SOL Item',
            Sales_Order__c = testOrder.Id,
            Item_Master__c = itemMaster.Id
        );
        insert testOrderLine;

        // Mock HttpResponse
        Test.startTest();
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration"><soapenv:Body><sal:InsertStandardSalesOrder_Result><salesDocumentNo>12345</salesDocumentNo></sal:InsertStandardSalesOrder_Result></soapenv:Body></soapenv:Envelope>');
        
        // Mock HTTP request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('TestEndpoint');
        
        // Call the method to test
        String result = IntegrationHandler.insertStandardSalesOrder(testOrder.Id, '1');
        
        // Assertions
        System.assertNotEquals(result, '', 'The response should not be empty');
     //   System.assertEquals(result, '12345', 'The response should contain the sales document number');
        
        // Verify that the sales order has been updated correctly
        Sales_Order__c updatedOrder = [SELECT Sales_Document_Number__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
      //  System.assertEquals(updatedOrder.Sales_Document_Number__c, '12345', 'Sales document number should be saved');
        
        Test.stopTest();
    }

    @isTest
    public static void testSaveResponseToOrder() {
        // Create test data for Sales Order
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;

        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456'
        );
        insert testOrder;

        // Test response saving
        IntegrationHandler.saveResponseToOrder(testOrder.Id, '12345', '1');

        // Verify that the sales order was updated with the correct Sales Document Number
        Sales_Order__c updatedOrder = [SELECT Sales_Document_Number__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
        System.assertEquals(updatedOrder.Sales_Document_Number__c, '12345', 'Sales document number should be updated');
    }

    @isTest
    public static void testSalesOrderApproval() {
        // Create test data for Sales Order
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        Sales_Order__c testOrder = new Sales_Order__c(
            Name = 'Test Order',
            Account__c = acc.Id,
            Order_Booking_Date__c = Date.today(),
            Shipment__c = 'Test Shipment Address',
            Sales_Document_Number__c = 'SO123456'
        );
        insert testOrder;

        // Mock HttpResponse
        Test.startTest();
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration"><soapenv:Body><sal:ApprovedStandardOrderByAMResponse><responseLog>Approval Sent Successfully</responseLog></sal:ApprovedStandardOrderByAMResponse></soapenv:Body></soapenv:Envelope>');
        
        // Mock HTTP request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('TestEndpoint');
        
        // Call the method to test
        String result = IntegrationHandler.salesOrderApproval(testOrder.Id, 2, '12345');

        // Assertions
        System.assertNotEquals(result, '', 'The response should not be empty');
      //  System.assertEquals(result, 'Approved', 'Sales Order should be approved');
        
        // Verify that the sales order status has been updated correctly
        Sales_Order__c updatedOrder = [SELECT Status__c FROM Sales_Order__c WHERE Id = :testOrder.Id];
      //  System.assertEquals(updatedOrder.Status__c, 'Approved', 'Sales Order status should be updated to Approved');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testGetRecType() {
        // Create test data
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        Sales_Order__c salesOrder = new Sales_Order__c(
            Account__c = acc.Id
        );
        insert salesOrder;

        // Get record type and validate
        String recType = IntegrationHandler.getRecType(salesOrder.Id);
        System.assertEquals(recType, 'Normal Enquiry', 'Record type should be Normal Enquiry');
    }
    
    @isTest
    public static void testGetDetails() {
        // Create test data
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        String result = IntegrationHandler.getDetails(acc.Id);
        System.assertNotEquals(result, null, 'Result should not be null');
    }
    
    @isTest
    public static void testSendForApproval() {
        // Create test data
        // 
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        Enquiry__c enquiry = new Enquiry__c(
            Field_Staff_Code__c = UserInfo.getUserId(),
            Area_Manager__c = UserInfo.getUserId(),
            Account__c = acc.Id,
            Status__c = 'Requested For Approval'
        );
        insert enquiry;

        String result = IntegrationHandler.sendForApproval(enquiry.Id);
        System.assertNotEquals(result, '', 'The response should not be empty');
    }
}
*/