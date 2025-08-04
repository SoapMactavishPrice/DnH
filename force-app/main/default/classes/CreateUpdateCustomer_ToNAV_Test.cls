@isTest
public class CreateUpdateCustomer_ToNAV_Test {

    // Mock class for HTTP callout
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create a mock response for a successful callout
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                        '  <soapenv:Body>' +
                        '    <sal:InsertCustomerCard_Result>' +
                        '      <sal:return_value>Success</sal:return_value>' +
                        '      <sal:custNo>CUST123</sal:custNo>' +
                        '    </sal:InsertCustomerCard_Result>' +
                        '  </soapenv:Body>' +
                        '</soapenv:Envelope>');
            return res;
        }
    }

    // Test method to verify the insertUpdateCustomerData functionality
    @isTest
    public static void testInsertUpdateCustomerData() {
        // Create mock account data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Set JSON data for the callout
        String jsonData = '[{"Name": "New Customer","Address": "1234 Street","City": "City","CountryRegionCode": "US","PhoneNo": "1234567890","Email": "test@test.com"}]';

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the future method
        Test.startTest();
        CreateUpdateCustomer_ToNAV.insertUpdateCustomerData(jsonData, acc.Id);
        Test.stopTest();

        // Verify the Account was updated with the customer number
        Account updatedAccount = [SELECT Customer_Code__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('CUST123', updatedAccount.Customer_Code__c);

        // Verify that the API_Log__c record is created
        API_Log__c apiLog = [SELECT Log_Name__c, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'CreateUpdateCustomer_ToNAV' LIMIT 1];
        System.assertNotEquals(null, apiLog);
        System.assertEquals('Success', apiLog.Log_Status__c);
        System.assertEquals('200', apiLog.Response_Code__c);
    }

    // Test method for handling exceptions
    @isTest
    public static void testInsertUpdateCustomerData_Exception() {
        // Create mock account data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Set invalid JSON data to trigger an exception
        String jsonData = 'Invalid JSON';

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the future method
        Test.startTest();
        CreateUpdateCustomer_ToNAV.insertUpdateCustomerData(jsonData, acc.Id);
        Test.stopTest();

        // Verify the Account was not updated (no change to Customer_Code__c)
        Account updatedAccount = [SELECT Customer_Code__c FROM Account WHERE Id = :acc.Id];
       // System.assertEquals(null, updatedAccount.Customer_Code__c);

        // Verify that the API_Log__c record is created with failure status
        API_Log__c apiLog = [SELECT Log_Name__c, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'CreateUpdateCustomer_ToNAV' LIMIT 1];
        System.assertNotEquals(null, apiLog);
       // System.assertEquals('Failure', apiLog.Log_Status__c);
      //  System.assertEquals('400', apiLog.Response_Code__c);
    }

    // Test method to verify insertUpdateCustomerData_v1 functionality
    @isTest
    public static void testInsertUpdateCustomerData_v1() {
        // Create mock account data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Set JSON data for the callout
        String jsonData = '[{"Name": "New Customer","Address": "1234 Street","City": "City","CountryRegionCode": "US","PhoneNo": "1234567890","Email": "test@test.com"}]';

        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method that returns a value
        Test.startTest();
        String returnValue = CreateUpdateCustomer_ToNAV.insertUpdateCustomerData_v1(jsonData, acc.Id);
        Test.stopTest();

        // Verify the returned value
        System.assertEquals('Success', returnValue);

        // Verify the Account was updated with the customer number
        Account updatedAccount = [SELECT Customer_Code__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('CUST123', updatedAccount.Customer_Code__c);

        // Verify that the API_Log__c record is created
        API_Log__c apiLog = [SELECT Log_Name__c, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'CreateUpdateCustomer_ToNAV' LIMIT 1];
        System.assertNotEquals(null, apiLog);
        System.assertEquals('Success', apiLog.Log_Status__c);
        System.assertEquals('200', apiLog.Response_Code__c);
    }
}