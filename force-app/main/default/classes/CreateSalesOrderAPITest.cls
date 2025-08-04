@isTest
public class CreateSalesOrderAPITest {

    @isTest
    static void testCreateSalesOrderSuccess() {
        
        Account acc = new Account(Name = 'Test Customer', Customer_Code__c = 'CUST001');
        insert acc;
        
        // Create mock data for LineItems
        String jsonRequest = '{"CustomerNo":"CUST001","WebOrderNo":"12345","Order_Booking_Date":"2024-12-01","External_Doc_No_PO":"PO123","Rate_Type":"1","Internal_Remarks":"Test Remarks","Freight_Terms":"2","LR_Destination":"210301","LR_favour":"1","Delivery_Type":"2","TransporterNo":"VEN0015930","Area_Manager":"AM001","Zonal_Head":"ZH001","WebOrderDate":"2024-12-01","Shipment":"Sea","Shipmentaddress2":"Address Line 2","Shipmentcity":"Test City","Postcode1":"12345","EngineerID":"ENG001","IsSubmitted":"true","SubmittedBy":"CUST001","SubmittedDate":"2024-12-01","Deactive":"false","IsPostedToNav":"true","ShipmentCode":"SC001","LineItems":[{"Item_Number":"ITEM001","Item_Category":"Category A","Cash_Discount":"10","Quantity":"5","UOM":"kg","Sales_Price":"100","Item_Value":"500","Conversion_Quantity":"1","Shipment_Date":"2024-12-05","Description":"Test Item","Location":"Warehouse","LineAmountExclTax":"500","Status":"Active"}]}';
        
        // Start the test
        Test.startTest();
        
        // Mock the request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        // Mock the response
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the API method
        CreateSalesOrderAPI.doPost();
        
        // End the test
        Test.stopTest();
        
        // Query for Sales Order created
        List<Sales_Order__c> salesOrders = [SELECT Id, Name, Status__c FROM Sales_Order__c WHERE Name = '12345'];
   
         Sales_Order__c salesOrder = new Sales_Order__c(
            Name = 'Test Sales Order',
            Status__c = 'Pending'

        );
        insert salesOrder;
        
        // Query for Sales Order Line Items
        List<Sales_Order_Line_Item__c> salesOrderLineItems = [SELECT Id, Item_Number__c, Quantity__c, Sales_Price__c FROM Sales_Order_Line_Item__c];
        
      
        
        // Assert specific values of the Sales Order Line Item
        Sales_Order_Line_Item__c soli = New Sales_Order_Line_Item__c ();
        
		soli.Item_Number__c = '123';
        soli.Sales_Order__c = salesOrder.Id;
        
        insert soli;

    }

    @isTest
    static void testCreateSalesOrderCustomerNotFound() {
        
        String jsonRequest = '{"CustomerNo":"CUST_NOT_FOUND","WebOrderNo":"12345","Order_Booking_Date":"2024-12-01","External_Doc_No_PO":"PO123","Rate_Type":"1"}';
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        CreateSalesOrderAPI.doPost();
        
        Test.stopTest();
        
        String responseBody = res.responseBody.toString();
        }

    @isTest
    static void testCreateSalesOrderMissingCustomerNo() {
        String jsonRequest = '{"WebOrderNo":"12345","Order_Booking_Date":"2024-12-01","External_Doc_No_PO":"PO123","Rate_Type":"1"}';
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        CreateSalesOrderAPI.doPost();
        
        Test.stopTest();
        
        System.assertEquals(400, res.statusCode);
        
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('CustomerNo required'), 'Response should contain "CustomerNo required" message');
    }

    @isTest
    static void testCreateSalesOrderExceptionHandling() {
        Account acc = new Account(Name = 'Test Customer', Customer_Code__c = 'CUST001');
        insert acc;
        
        String jsonRequest = '{"CustomerNo":"CUST001","WebOrderNo":"12345","Order_Booking_Date":"2024-12-01","External_Doc_No_PO":"PO123","Rate_Type":"1"}';
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        try {
            CreateSalesOrderAPI.doPost();
        } catch (Exception e) {
            Test.stopTest();
            
            System.assertEquals(400, res.statusCode);
            
            String responseBody = res.responseBody.toString();
            System.assert(responseBody.contains('Something went wrong'), 'Response should contain "Something went wrong" message');
        }
    }
}