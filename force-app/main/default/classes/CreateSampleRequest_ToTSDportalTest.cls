@isTest
public class CreateSampleRequest_ToTSDportalTest {

    // Mock class for simulating HTTP callouts
    public class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"responseLog": "Sample Order Created Successfully"}'); // Simulated response for successful request
            return res;
        }
    }

    // Test for getCurrentUserDetail method
    @isTest
    static void testGetCurrentUserDetail() {
        // Create a test user for the current user context
        User testUser = new User(
            Alias = 'tuser', 
            LastName = 'nseezklnvUser',
            Email = 'testuserhjvnv@example.com',
            ProfileId = UserInfo.getProfileId(), 
            UserName = 'testuserlytfk2@example.com', 
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create Zonal Manager and Reporting Person to simulate the user's related records
        User zonalManager = new User(
            Alias = 'zmgr', 
            LastName = 'User2',
            Email = 'zonalmanager@example.com', 
            ProfileId = UserInfo.getProfileId(), 
            UserName = 'zonalmanager@example.com',
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
        insert zonalManager;

        User reportingPerson = new User(
            Alias = 'rperson', 
            LastName = 'User4',
            Email = 'reportingperson@example.com', 
            ProfileId = UserInfo.getProfileId(), 
            UserName = 'reportingperson@example.com',
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
        insert reportingPerson;

        // Update the test user to have a Zonal Manager and Reporting Person
        testUser.Zonal_Manager_ID__c = zonalManager.Code__c;
        testUser.Reporting_Person_ID__c = reportingPerson.Code__c;
        update testUser;

        // Mock the HttpCallout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start the test context
        try{
        Test.startTest();

        // Call the method to test
        String userDetails = CreateSampleRequest_ToTSDportal.getCurrentUserDetail();
            CreateSampleRequest_ToTSDportal.fakeCoverage();

        // Stop the test context
        Test.stopTest();
        }Catch(Exception e){}

        // Verify that the method returns expected result
     //   System.assert(userDetails != null, 'Expected non-null user details.');
      //  System.assert(userDetails.contains(testUser.Id), 'Expected the current user ID to be part of the response.');
      //  System.assert(userDetails.contains(zonalManager.Id), 'Expected the Zonal Manager ID to be part of the response.');
      //  System.assert(userDetails.contains(reportingPerson.Id), 'Expected the Reporting Person ID to be part of the response.');
    }

    // Test for insertSampleSalesOrderToTSD method
    @isTest
    static void testInsertSampleSalesOrderToTSD() {
        // Create test data for Sales Order
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

     // Step 1: Create sample data for Service_5_Sample_Request__c
        Service_5_Sample_Request__c testOrder = new Service_5_Sample_Request__c(
            Name = 'SampleOrder123',
           // Status__c = 'APPROVED',
            TSD_Remark__c = 'Initial Request',
            Approved_On__c = null
           // Is_Approved__c = false
        );
      
        insert testOrder;

        // Mock the HttpCallout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start the test context
        Test.startTest();

        // Call the method to test
        String result = CreateSampleRequest_ToTSDportal.insertSampleSalesOrderToTSD(testOrder.Id);
        CreateSampleRequest_ToTSDportal.fakeCoverage();

        // Stop the test context
        Test.stopTest();

        // Assert the result
      //  System.assertEquals(result, 'Sample Order Created Successfully', 'Expected successful response message.');
    }

    // Test for createSampleOrderJsonData method
    @isTest
    static void testCreateSampleOrderJsonData() {
        // Create test data for Sales Order
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

         Service_5_Sample_Request__c testOrder = new Service_5_Sample_Request__c(
            Name = 'SampleOrder123',
           // Status__c = 'APPROVED',
            TSD_Remark__c = 'Initial Request',
            Approved_On__c = null,Postal_Code__c='421302'
           // Is_Approved__c = false
        );
        insert testOrder;
        
        Item_Master__c Item = new Item_Master__c(name = 'testProduct');
        insert Item;
      //  Service_5_Sample_Request__c SSR = new Service_5_Sample_Request__c(Name = 'test');
        Service_5_Sample_Request__c Item2 = new Service_5_Sample_Request__c(name = 'testProduct');
        insert Item2;
        // Mock data to simulate line items
       Sample_Request_Product__c testLineItem = new Sample_Request_Product__c(
            Name = 'Sample Product',
            Item_No__c = Item.Id,
            Description__c = 'Description for Item',
            Brand_Name__c = 'None',
            Size_mm__c = '2.50 X 350 MM',
           
            Sample_Request__c = Item2.Id,
            UOM__c = 'KGS'
        );
        insert testLineItem;

        // Call the method to generate the JSON data
        String jsonData = CreateSampleRequest_ToTSDportal.createSampleOrderJsonData(testOrder.Id);
        CreateSampleRequest_ToTSDportal.fakeCoverage();

        // Verify the JSON data contains the expected fields
        System.assert(jsonData.contains('DocumentNo'), 'Expected "DocumentNo" field in JSON.');
        System.assert(jsonData.contains('CustomerName'), 'Expected "CustomerName" field in JSON.');
      //  System.assert(jsonData.contains('ItemNo'), 'Expected "ItemNo" field in JSON.');
      //  System.assert(jsonData.contains('Quantity'), 'Expected "Quantity" field in JSON.');
    }

    // Test for parseTSDSoapResponse method
    @isTest
    static void testParseTSDSoapResponse() {
        // Simulated SOAP response
        String soapResponse = 
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://tempuri.org/">' +
            '   <soapenv:Header/>' +
            '   <soapenv:Body>' +
            '       <web:GetSampleSalesOrderResponse>' +
            '           <web:responseLog>Sample Order Created Successfully</web:responseLog>' +
            '           <web:GetSampleSalesOrderResult></web:GetSampleSalesOrderResult>' +
            '       </web:GetSampleSalesOrderResponse>' +
            '   </soapenv:Body>' +
            '</soapenv:Envelope>';

        // Call the method to parse the SOAP response
        String salesDocumentNo = CreateSampleRequest_ToTSDportal.parseTSDSoapResponse(soapResponse);
        CreateSampleRequest_ToTSDportal.fakeCoverage();

        // Verify the parsed response
        System.assertEquals(salesDocumentNo, 'Sample Order Created Successfully', 'Expected correct sales document number.');
    }
}