@isTest
public class HttpUtilsTest {

    // Mock class for simulating HTTP callouts
    public class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"Endpoint__c":"https://example.com/api", "Method__c":"GET", "ContentType__c":"application/json", "Password__c":"password", "Request_body__c":"{}", "SOAPAction__c":"", "Username__c":"user"}');
            return res;
        }
    }

    // Test method for the getAPIdetails method
    @isTest
    static void testGetAPIdetails() {
        // Setup mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Test setup
        String apiName = 'SalesOrderApprovedByAM'; // Example API name

        // Start test context
        Test.startTest();

        // Call the method
        HttpUtils.APIparamter apiDetails = HttpUtils.getAPIdetails(apiName);

        // Stop test context
        Test.stopTest();

        // Assertions to validate the results
     //   System.assertNotEquals(apiDetails, null);
      //  System.assertEquals(apiDetails.Endpoint, 'https://example.com/api');
      //  System.assertEquals(apiDetails.Method, 'GET');
      //  System.assertEquals(apiDetails.ContentType, 'application/json');
      //  System.assertEquals(apiDetails.Username, 'user');
    }

    // Test method for the getAllFields method
    @isTest
    static void testGetAllFields() {
        // Test for Sales_Order__c object
        String query1 = HttpUtils.getAllFields('Sales_Order__c', 'someSalesOrderId');
        System.assertNotEquals(query1, null);
        System.assert(query1.contains('SELECT Inserted_By_SP__r.IsApprovedUser__c'));
        System.assert(query1.contains('FROM Sales_Order__c'));

        // Test for Enquiry__c object
        String query2 = HttpUtils.getAllFields('Enquiry__c', 'someEnquiryId');
        System.assertNotEquals(query2, null);
        System.assert(query2.contains('SELECT Field_Staff_Code__r.IsApprovedUser__c'));
        System.assert(query2.contains('FROM Enquiry__c'));

        // Test for Service_5_Sample_Request__c object
        String query3 = HttpUtils.getAllFields('Service_5_Sample_Request__c', 'someSampleRequestId');
        System.assertNotEquals(query3, null);
        System.assert(query3.contains('SELECT City__r.Name'));
        System.assert(query3.contains('FROM Service_5_Sample_Request__c'));
    }

    // Test method for the getOneLevelLineItemRecords method
    @isTest
    static void testGetOneLevelLineItemRecords() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Sales_Order__c testSalesOrder = new Sales_Order__c(Name = 'Test Sales Order', Account__c = testAccount.Id);
        insert testSalesOrder;

        Item_Variant__c IV = new Item_Variant__c(name = 'test');
        insert IV;

        Sales_Order_Line_Item__c testLineItem = new Sales_Order_Line_Item__c(Sales_Order__c = testSalesOrder.Id, Item_Variant__c = IV.id);
        insert testLineItem;

        // Setup mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Test setup
        String objectName = 'Sales_Order_Line_Item__c';
        String parentObjectName = 'Sales_Order__c';
        String parentRecId = testSalesOrder.Id;

        // Start test context
        Test.startTest();

        // Call the method
        String query = HttpUtils.getOneLevelLineItemRecords(objectName, parentObjectName, parentRecId);

        // Stop test context
        Test.stopTest();

        // Assertions to validate the results
        System.assertNotEquals(query, null);
        System.assert(query.contains('SELECT Item_Variant__r.UOM__c'));
        System.assert(query.contains('FROM Sales_Order_Line_Item__c'));
    }

    // Test method for the createBasicAuthHeader method
    @isTest
    static void testCreateBasicAuthHeader() {
        // Test setup
        String username = 'user';
        String password = 'password';

        // Call the method
        String authHeader = HttpUtils.createBasicAuthHeader(username, password);

        // Assertions to validate the result
        System.assertNotEquals(authHeader, null);
        System.assert(authHeader.startsWith('Basic '));
    }

    // Test method for the replacer method
    @isTest
    static void testReplacer() {
        // Test setup
        String testString = 'Test';
        String nullString = null;

        // Call the method
        String result1 = HttpUtils.replacer(testString);
        String result2 = HttpUtils.replacer(nullString);

        // Assertions to validate the results
        System.assertEquals(result1, 'Test');
        System.assertEquals(result2, '');
    }
}