@isTest
public class CreateSalesOrderWithTCO_Test {

    // Declare 'con' variable to be accessible in your test method
    private static Contact con;

    public static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUST123');
        insert acc;

        // Create Contact associated with the Account
        con = new Contact(
            FirstName = 'Test',  
            LastName = 'Contact', 
            AccountId = acc.Id
        );
        insert con;

        // Create other related records...
        Enquiry__c enquiry = new Enquiry__c(Enquiry_Name__c = 'TechDoc123', Account__c = acc.Id);
        insert enquiry;

        Item_Master__c im = new Item_Master__c(Name = 'asd', Item_Number__c = '123');
        insert im;

        Sales_Order__c so = new Sales_Order__c(
            Name = 'ABC',
            Enquiry__c = enquiry.Id,
            Shipment__c = 'GENERAL CONDITIONS CONTRACT (GCC) SIKHAR',
            Postcode1__c = 12343,
            Rate_Type__c = '1'
        );
        insert so;

        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(
            Sales_Order__c = so.Id,  
            Item_Master__c = im.Id
        );
        insert soli;

        User areaManager = new User(
            UserName = 'areaManager@test.com', 
            Alias = 'AM', 
            Email = 'areaManager@test.com', 
            LastName = 'MANAGER',
            ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            Code__c = 'AM123'
        );
        insert areaManager;

        User zonalHead = new User(
            UserName = 'zonalHead@test.com', 
            Alias = 'ZH', 
            Email = 'zonalHead@test.com', 
            LastName = 'ABC',
            ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZH123' 
        );
        insert zonalHead;
    }

    @isTest
    public static void testDoPost_ValidRequest() {
        setupTestData();

        // Now 'con' is accessible here
        String jsonRequest = '{"CustomerNo":"CUST123","LASTNAME":"ABC","Shipment__c":"GENERAL CONDITIONS CONTRACT (GCC) SIKHAR","TechnoDocNo":"TechDoc123", "WebOrderNo":"WEB123", ' + 
                             '"Order_Booking_Date":"2024-12-01", "External_Doc_No_PO":"PO123", "Rate_Type":"1", ' +
                             '"Internal_Remarks":"Test Remarks", "External_Remarks":"Test External Remarks", "Freight_Terms":"1", ' +
                             '"LR_Destination":"210301", "LR_favour":"1","TransporterNo":"VEN0015930", ' +
                             '"Area_Manager":"AM123", "End_Customer_Name":"End Customer", "Zonal_Head":"ZH123", "Contact":"'+con.Id+'","Contact__c":"Test Contact", ' +
                             '"WebOrderDate":"2024-12-01","WebOrderDate__c":"2024-12-01","Shipment":"Ship1", "Shipmentaddress2":"Address2", "Shipmentcity":"City", ' +
                             '"Postcode1":"10001", "EngineerID":"ENG123", "IsSubmitted":"true", ' +
                             '"SubmittedBy":"CUST123", "SubmittedDate":"2024-12-01", "Deactive":"false", "IsPostedToNav":"true", ' +
                             '"ShipmentCode":"SHIP123", "LineItems":[{"Item_Number":"ITEM1", "Item_Category":"FGM", ' +
                             '"Quantity":"10", "UOM":"PCS", "Sales_Price":"100.0", "Item_Value":"1000.0", "OrderQty":"10", ' +
                             '"LineAmountExclTax":"1000.0","Postcode1__c":"12343","Conversion_Quantity":"10.00","Shipment_Date":"2025-01-01","Is_SOR":"False","SORRemark":"TESTINGG","UnitPriceExcl":"10.0","AvailableQuantity":"1","QuantityDiscount":"0","SpecialDiscount":"0"}]}';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;

        CreateSalesOrderWithTCO.doPost();

        Test.stopTest();
    }

    @isTest
    public static void testDoPost_MissingCustomerNoOrTechnoDocNo() {
        setupTestData();

        String jsonRequest = '{"CustomerNo":"CUST123","TechnoDocNo":""}';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;

        CreateSalesOrderWithTCO.doPost();

        Test.stopTest();
    }

    @isTest
    public static void testDoPost_NoMatchingCustomerOrTCO() {
        setupTestData();

        String jsonRequest = '{"CustomerNo":"NONEXISTENT","TechnoDocNo":"NonExistentTechDoc"}';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;

        CreateSalesOrderWithTCO.doPost();

        Test.stopTest();
    }

    @isTest
    public static void testDoPost_ExceptionHandling() {
        setupTestData();

        String jsonRequest = '{"CustomerNo":"CUST123","TechnoDocNo":"TechnoDoc123"}';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        CreateSalesOrderWithTCO.doPost();

        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"fail", "message":"An error occurred", "Error1":"Some error details"}');
            return res;
        }
    }
}