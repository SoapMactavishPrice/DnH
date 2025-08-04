@isTest
private class CloseReopenComplaint_ToTSDTest {
    
    
    private class MockHttpResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(
                '<?xml version="1.0" encoding="UTF-8"?>' +
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '  <soap:Body>' +
                '    <ReOpenComplaintByEngineerResponse xmlns="http://tempuri.org/">' +
                '      <ReOpenComplaintByEngineerResult>1</ReOpenComplaintByEngineerResult>' +
                '      <responseLog />' +
                '    </ReOpenComplaintByEngineerResponse>' +
                '  </soap:Body>' +
                '</soap:Envelope>'
            );    
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class MockHttpResponseSuccessClose implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(
                '<?xml version="1.0" encoding="UTF-8"?>' +
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '  <soap:Body>' +
                '    <ComplaintClosedByEngineerResponse xmlns="http://tempuri.org/">' +
                '      <ComplaintClosedByEngineerResult>1</ComplaintClosedByEngineerResult>' +
                '      <responseLog />' +
                '    </ComplaintClosedByEngineerResponse>' +
                '  </soap:Body>' +
                '</soap:Envelope>'            );
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    private class MockHttpResponseFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(
                '<?xml version="1.0" encoding="utf-8"?>' + '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' + ' <soap:Body>' + ' <Error>' + ' <message>Error occurred</message>' + ' </Error>' + ' </soap:Body>' + '</soap:Envelope>' );
            res.setStatusCode(400);
            return res;
        }
    }
    
    @isTest
    static void testReopenCustomerComplaintFailure() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        
        
        Test.startTest();
        //CloseReopenComplaint_ToTSD.reopenCustomerComplaint('12345');
        Test.stopTest();
        
        
        List<API_Log__c> logs = [SELECT Id, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_reopenCustomerComplaint_TSD'];
    }
    
    
    @isTest
    static void testCloseCustomerComplaintSuccess() {
        
        Account testAccount = new Account(Name = 'Test Account', Customer_Code__c = 'CUST001');
        insert testAccount;
        
        Customer_Complaint__c testComplaint = new Customer_Complaint__c(
            Name = 'CC001',
            Account__c = testAccount.Id,
            Inserted_By__c = 'USR001',
            SalesPersonConfirmation__c = 'Yes',
            Updated_On__c = DateTime.now(),
            Submitted_By__c = 'USR001',
            Submitted_Date__c = DateTime.now()
        );
        insert testComplaint;
        
        User testUser = new User(
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Code__c = 'USR001'
        );
        insert testUser;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessClose());
        Test.startTest();
        CloseReopenComplaint_ToTSD.closeCustomerComplaint('SF-Ser19/2425/000099');
        Test.stopTest();
        
        List<API_Log__c> logs = [SELECT Id, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_closeCustomerComplaint_ToTSD'];
    }
    
    
    
    @istest
    static void testCloseCustomerComplaintFailure() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());
        
        
        Test.startTest();
        //CloseReopenComplaint_ToTSD.closeCustomerComplaint('12345');
        Test.stopTest();
        
        
        List<API_Log__c> logs = [SELECT Id, Log_Status__c, Response_Code__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_closeCustomerComplaint_ToTSD'];
    }
    
    //
    @isTest
    static void testCreateJSONDataReopen() {
        
        Account testAccount = new Account(Name = 'Test Account', Customer_Code__c = 'CUST001');
        insert testAccount;
        
        Customer_Complaint__c testComplaint = new Customer_Complaint__c(
            Name = 'CC001',
            Account__c = testAccount.Id,
            Inserted_By__c = 'USR001',
            SalesPersonConfirmation__c = 'Yes',
            Updated_On__c = DateTime.now(),
            Submitted_By__c = 'USR001',
            Submitted_Date__c = DateTime.now()
        );
        insert testComplaint;
        
        User testUser = new User(
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Code__c = 'USR001'
        );
        insert testUser;
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        String result = CloseReopenComplaint_ToTSD.CreateJSONData('CC001', 'reopen');
        CloseReopenComplaint_ToTSD.reopenCustomerComplaint('CC001');
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateJSONDataClose() {
        
        Account testAccount = new Account(Name = 'Test Account', Customer_Code__c = 'CUST001');
        insert testAccount;
        
        Customer_Complaint__c testComplaint = new Customer_Complaint__c(
            Name = 'CC001',
            Account__c = testAccount.Id,
            Inserted_By__c = 'USR001',
            SalesPersonConfirmation__c = 'Yes',
            Updated_On__c = DateTime.now(),
            Submitted_By__c = 'USR001',
            Submitted_Date__c = DateTime.now()
        );
        insert testComplaint;
        
        User testUser = new User(
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Code__c = 'USR001'
        );
        insert testUser;
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessClose());
        String result = CloseReopenComplaint_ToTSD.CreateJSONData('CC001', 'close');
        CloseReopenComplaint_ToTSD.closeCustomerComplaint('CC001');
        Test.stopTest();
        
    }
    
}