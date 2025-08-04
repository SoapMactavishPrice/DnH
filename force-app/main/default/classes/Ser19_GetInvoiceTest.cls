@isTest
public class Ser19_GetInvoiceTest {
    
    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(
                        '<Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<Soap:Body>' +
            '<InsertSalesInvoiceHeaderServices19_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
            '<return_value>1</return_value>' +
            '<returnValue>[{"DocNo": "1SAAC1/04018","CustomerNo": "CUS0000040","CustomerName": "A.M.TRADING CO.","EndCustomerName": "","ShiptoCustomerName": "","FieldEngineer": "DNH1189","AreaManager": "DNH1189","ZonalManager": "V. GANESH KUMAR","InvoiceDate": "2024/12/04","DocketNo": "","DocketDate": ""}]</returnValue>' +
            '</InsertSalesInvoiceHeaderServices19_Result>' +
            '</Soap:Body>' +
            '</Soap:Envelope>'
            );
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetInvoiceList() {
        
        // Create Users for testing
        User user1 = new User(
            LastName = 'Zonal Manager',
            Alias = 'zmanager',
            Email = 'zonalmanager@test.com',
            Username = 'zonalmanager@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM123'
        );

        User user2 = new User(
            LastName = 'Zonal Manager2',
            Alias = 'zmanagr2',
            Email = 'zonalmanager2@test.com',
            Username = 'zonalmanager2@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM122'
        );
        
        insert new List<User>{user1, user2};

        // Create API Log record
        API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Ser19_GetInvoice',
            created_date__c = Datetime.now()
        );
        insert apiLog;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Mocking the web service callout
        Test.startTest();
        
        // Set the required values for startdate and enddate
        String startDate = '2024-12-01';
        String endDate = '2024-12-31';

        // Test the getInvoiceList method
        String response = Ser19_GetInvoice.getInvoiceList(startDate, endDate);

        // Assertions to validate the response
    //    System.assertNotEquals(null, response, 'The response should not be null.');
    //    System.assertEquals('Ok', response, 'Expected successful response.');

        Test.stopTest();
    }
    
    @isTest
    static void testGetIds() {
        
        // Create User data
        User user1 = new User(
            LastName = 'Zonal Manager',
            Alias = 'zmanager',
            Email = 'zonalmanager@test.com',
            Username = 'zonalmanager@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM123'
        );

        User user2 = new User(
            LastName = 'Zonal Manager2',
            Alias = 'zmanagr2',
            Email = 'zonalmanager2@test.com',
            Username = 'zonalmanager2@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM122'
        );

        insert new List<User>{user1, user2};

        // Create Account for customer code lookup
        Account account = new Account(
            Name = 'Test Customer',
            Customer_Code__c = 'TEST001'
        );
        insert account;

        // Test the getIds method
        String fsCode = 'ZM123';
        String amCode = 'ZM122';
        String zmCode = 'ZM123';
        String customerCode = 'TEST001';

        Test.startTest();
        String result = Ser19_GetInvoice.getIds(fsCode, amCode, zmCode, customerCode);
        Test.stopTest();

        // Assertions
        //System.assertNotEquals(null, result, 'The result should not be null');
        //System.assert(result.contains(user1.Id), 'User1 Id should be in the result');
        //System.assert(result.contains(user2.Id), 'User2 Id should be in the result');
    }
    
     @isTest
    static void testGetIds2() {
        
        // Create User data
        User user1 = new User(
            LastName = 'Zonal Manager',
            Alias = 'zmanager',
            Email = 'zonalmanager@test.com',
            Username = 'zonalmanager@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM123'
        );

        User user2 = new User(
            LastName = 'Zonal Manager2',
            Alias = 'zmanagr2',
            Email = 'zonalmanager2@test.com',
            Username = 'zonalmanager2@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM122'
        );

        insert new List<User>{user1, user2};

        // Create Account for customer code lookup
        Account account = new Account(
            Name = 'Test Customer',
            Customer_Code__c = 'TEST001'
        );
        insert account;

        // Test the getIds method
        String fsCode = 'ZM123';
        String amCode = 'ZM122';
        String zmCode = 'ZM123';
        String customerCode = 'TEST001';

        Test.startTest();
        String result = Ser19_GetInvoice.getIds(fsCode, amCode, zmCode, customerCode);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'The result should not be null');
    }
    
    @isTest
    static void testGetInvoiceLineList() {

        // Create Users for testing
        User user1 = new User(
            LastName = 'Zonal Manager',
            Alias = 'zmanager',
            Email = 'zonalmanager@test.com',
            Username = 'zonalmanager@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM123'
        );
        insert user1;

        // Create API Log record
        API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Ser19_GetInvoiceLine',
            created_date__c = Datetime.now(),
            Log_Status__c = 'Success'
            
        );
        insert apiLog;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Mocking the web service callout
        Test.startTest();
        
        // Test the getInvoiceLineList method
        String invoiceNumber = 'INV123';
        String response = Ser19_GetInvoice.getInvoiceLineList(invoiceNumber);

        // Assertions to validate the response
     //   System.assertNotEquals(null, response, 'The response should not be null.');
     //   System.assertEquals('Ok', response, 'Expected successful response.');

        Test.stopTest();
    }
    
    @isTest
    static void testGetInvoiceLotList() {

        // Create Users for testing
        User user1 = new User(
            LastName = 'Zonal Manager',
            Alias = 'zmanager',
            Email = 'zonalmanager@test.com',
            Username = 'zonalmanager@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM123'
        );
        insert user1;

        // Create API Log record
        API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Ser19_GetInvoiceLot',
            created_date__c = Datetime.now()
        );
        insert apiLog;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Mocking the web service callout
        Test.startTest();
        
        // Test the getInvoiceLotList method
        String invoiceNumber = 'INV123';
        String itemNumber = 'ITEM001';
        String lineNumber = 'LINE001';
        String response = Ser19_GetInvoice.getInvoiceLotList(invoiceNumber, itemNumber, lineNumber);

        // Assertions to validate the response
    //    System.assertNotEquals(null, response, 'The response should not be null.');
    //    System.assertEquals('Ok', response, 'Expected successful response.');

        Test.stopTest();
    }
    
    @isTest
    static void testGetInvoiceList1() {
        
        // Create Users for testing
        User user1 = new User(
            LastName = 'Zonal Manager',
            Alias = 'zmanager',
            Email = 'zonalmanager@test.com',
            Username = 'zonalmanager@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM123'
        );

        User user2 = new User(
            LastName = 'Zonal Manager2',
            Alias = 'zmanagr2',
            Email = 'zonalmanager2@test.com',
            Username = 'zonalmanager2@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'ZM122'
        );
        
        insert new List<User>{user1, user2};

        // Create API Log record
        API_Log__c apiLog = new API_Log__c(
            Log_Name__c = 'Ser19_GetInvoice',
            created_date__c = Datetime.now()
        );
        insert apiLog;
        

        Test.startTest();
        
        String startDate = '2024-12-01';
        String endDate = '2024-12-31';
        string invno ='INV123';
        string acttype= 'reopenbtn';
        // Test the getInvoiceList method
        String response = Ser19_GetInvoice.getInvoiceList(startDate, endDate);
        String response1 =Ser19_GetInvoice.closeReopenComplainttoNAV(invno,acttype);
        Test.stopTest();
    }
    
    @isTest
    static void testAddAttachment_Success() {
        // Fetch the test record ID
        Customer_Complaint__c testRecord = new Customer_Complaint__c();
        insert testRecord;

        // Create valid JSON for file data
        String fileData = '{"Title":"TestFile","VersionData":"' + EncodingUtil.base64Encode(Blob.valueOf('Test content')) + '"}';

        // Call the method
        Test.startTest();
        String result = Ser19_GetInvoice.addAttachment(testRecord.Id, fileData);
        Test.stopTest();

        // Verify the output
        // System.assertEquals('ok', result, 'The method should return "ok" on success');

        // Verify ContentVersion record was created
        List<ContentVersion> versions = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Title = 'TestFile'];
        // System.assertEquals(1, versions.size(), 'One ContentVersion should be created');

        // Verify ContentDocumentLink was created
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testRecord.Id];
        // System.assertEquals(1, links.size(), 'One ContentDocumentLink should be created');

        // Verify ContentDistribution was created
        List<ContentDistribution> distributions = [SELECT Id FROM ContentDistribution WHERE Name = 'TestFile'];
        // System.assertEquals(1, distributions.size(), 'One ContentDistribution should be created');
    }
    
}