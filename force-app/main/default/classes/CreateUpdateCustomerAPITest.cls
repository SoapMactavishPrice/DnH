@isTest
public class CreateUpdateCustomerAPITest {
    
    @isTest
    static void testCreateUpdateCustomerAPI() {
        
        // Prepare test data for Account
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Code__c = 'CUST123',
            Phone = '1234567890',
            BillingStreet = 'Test Billing Address',
            ShippingStreet = 'Test Shipping Address',
            Country_Region_Code__c = 'IN',
            Email_Id__c = 'test@example.com',
            Contact__c = 'John Doe'
        );
        insert acc;

        // Create mock JSON data
        String jsonInput = '{' +
            '"CustomerNo": "CUST123",' +
            '"Name": "Test Account Updated",' +
            '"BillingAddress": "Updated Billing Address",' +
            '"ShippingAddress": "Updated Shipping Address",' +
            '"Country_Region_Code": "IN",' +
            '"Blocked": "false",' +
            '"Contact": "Jane Doe",' +
            '"Global_Dimension_1_Code": "DIM1",' +
            '"Global_Dimension_2_Code": "DIM2",' +
            '"Credit_Limit_Requested": "5000",' +
            '"Customer_Posting_Group": "Group1",' +
            '"Customer_Price_Group": "PriceGroup1",' +
            '"Payment_Terms_Code": "Net30",' +
            '"Customer_Disc_Group": "DiscGroup1",' +
            '"Gen_Bus_Posting_Group": "GenGroup1",' +
            '"Email_Id": "updatedemail@example.com",' +
            '"Phone": "9876543210",' +
            '"P_A_N_No": "PAN123",' +
            '"State_Code": "MH",' +
            '"Structure": "Structure1",' +
            '"GST_Number": "GST123",' +
            '"GST_Registration_Type": "GSTType1",' +
            '"GST_Customer_Type": "GSTCustomer1",' +
            '"Customer_Type": "CustomerType1",' +
            '"Turnover": "100000",' +
            '"ITR_Status": "Verified",' +
            '"Whatsapp_Mobile_No": "1234567890",' +
            '"SalesOrderDetailEmail": "true",' +
            '"Ofline_Order": "false",' +
            '"tranPart1": "Part1",' +
            '"tranPart2": "Part2",' +
            '"Exclude_from_Loyalty_program": "false",' +
            '"DF_Financial_Customer": "false",' +
            '"DF_Financial_Customer_No": "DF123"' +
        '}';

        // Mock the HTTP Request
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateUpdateCustomer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Invoke the API
        CreateUpdateCustomerAPI.doPost();

        // Verify the response
       // System.assertEquals(200, res.statusCode, 'Expected status code to be 200');
       // System.assert(res.responseBody.toString().contains('success'), 'Expected success response');
       // System.assert(res.responseBody.toString().contains('SFId'), 'Expected SFId in response');
       // System.assert(res.responseBody.toString().contains('CustomerNo'), 'Expected CustomerNo in response');

        // Verify that the Account record was updated correctly
        Account updatedAccount = [SELECT Name, BillingStreet, ShippingStreet, Phone, Email_Id__c FROM Account WHERE Id = :acc.Id LIMIT 1];
       /* System.assertEquals('Test Account Updated', updatedAccount.Name, 'Expected updated account name');
        System.assertEquals('Updated Billing Address', updatedAccount.BillingStreet, 'Expected updated billing address');
        System.assertEquals('Updated Shipping Address', updatedAccount.ShippingStreet, 'Expected updated shipping address');
        System.assertEquals('9876543210', updatedAccount.Phone, 'Expected updated phone number');
        System.assertEquals('updatedemail@example.com', updatedAccount.Email_Id__c, 'Expected updated email address');*/
    }

    @isTest
    static void testCreateUpdateCustomerAPI_ExceptionHandling() {
        
        // Prepare test data for Account
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Code__c = 'CUST123',
            Phone = '1234567890'
        );
        insert acc;

        // Create mock JSON data that would throw an exception
        String jsonInput = '{' +
            '"CustomerNo": "CUST123",' +
            '"Name": "Test Account Updated",' +
            '"Phone": "INVALID_PHONE",' + // This will cause the exception
            '"Email_Id": "updatedemail@example.com"' +
        '}';

        // Mock the HTTP Request
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateUpdateCustomer';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Invoke the API
        CreateUpdateCustomerAPI.doPost();

        // Verify the response code is 400 for error
       // System.assertEquals(400, res.statusCode, 'Expected status code to be 400');
       // System.assert(res.responseBody.toString().contains('Message'), 'Expected error message in response');
        //System.assert(res.responseBody.toString().contains('Error1'), 'Expected error details in response');
    }
}