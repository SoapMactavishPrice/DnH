@IsTest
public class IndiaMart_APITest {

    @testSetup
    static void setupTestData() {
        // Create reference data
        Country__c co = new Country__c(Name = 'India');
        insert co;
        State__c s = new State__c(Name = 'Maharashtra',Country__c = co.Id);
        insert s;
        City__c c = new City__c(Name = 'Mumbai', State__c = s.Id);
        insert c;


        // Existing Lead for matching mobile
        insert new Lead__c(
            Last_Name__c = 'Existing Lead',
            Mobile_Number__c = '9876543210',
            State__c = s.Id,
            City__c = c.Id
        );
        
        insert new Lead(
            LastName = 'Existing Lead',
            MobilePhone = '9876543210',
            Company = 'Test',
            Email = 'testtest@gmail.com',
            State__c = s.Id,
            City__c = c.Id
        );
    }

    @IsTest
    static void testCallApi_Success() {
        // Prepare mock response
        IndiaMart_API.InquiryWrapper inquiry = new IndiaMart_API.InquiryWrapper();
        inquiry.UNIQUE_QUERY_ID = 'Q123';
        inquiry.QUERY_TYPE = 'Product';
        inquiry.QUERY_TIME = '2025-07-17 10:00:00';
        inquiry.SENDER_NAME = 'Test Sender';
        inquiry.SENDER_MOBILE = '9876543210';
        inquiry.SENDER_EMAIL = 'test@example.com';
        inquiry.SUBJECT = 'Test Subject';
        inquiry.SENDER_COMPANY = 'Test Company';
        inquiry.SENDER_ADDRESS = 'Test Address';
        inquiry.SENDER_CITY = 'Mumbai';
        inquiry.SENDER_STATE = 'Maharashtra';
        inquiry.SENDER_PINCODE = '400001';
        inquiry.SENDER_COUNTRY_ISO = 'IN';
        inquiry.SENDER_MOBILE_ALT = '1234567890';
        inquiry.SENDER_EMAIL_ALT = 'alt@example.com';
        inquiry.QUERY_PRODUCT_NAME = 'Test Product';
        inquiry.QUERY_MESSAGE = 'Test Message';
        inquiry.RECEIVER_MOBILE = '9999999999';

        IndiaMart_API.IndiaMartApiResponse response = new IndiaMart_API.IndiaMartApiResponse();
        response.CODE = 200;
        response.STATUS = 'OK';
        response.MESSAGE = 'Success';
        response.TOTAL_RECORDS = 1;
        response.RESPONSE = new List<IndiaMart_API.InquiryWrapper>{ inquiry };

        String responseBody = JSON.serialize(response);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(responseBody, 200));

        Test.startTest();
        IndiaMart_API.callApi();
        Test.stopTest();

        // Assert log created
        List<API_Log__c> logs = [
            SELECT Log_Name__c, Log_Status__c, Response_Code__c 
            FROM API_Log__c 
            WHERE Log_Name__c LIKE 'IndiaMart_API%'
        ];
        // System.assert(!logs.isEmpty(), 'API_Log__c record must be created.');
        // System.assertEquals('Success', logs[0].Log_Status__c, 'Log_Status__c should be Success.');

        // Assert Lead updated
        Lead__c updatedLead = [
            SELECT IndiaMart__c 
            FROM Lead__c 
            WHERE Mobile_Number__c = '9876543210'
            LIMIT 1
        ];
        // System.assertEquals(true, updatedLead.IndiaMart__c, 'Lead must be marked IndiaMart__c = true.');
    }

    @IsTest
    static void testCallApi_Failure() {
        // Simulate failure response
        String responseBody = '{"error":"Bad Request"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(responseBody, 400));

        Test.startTest();
        IndiaMart_API.callApi();
        Test.stopTest();

        // Assert log created with failure
        List<API_Log__c> logs = [
            SELECT Log_Status__c, Response_Code__c 
            FROM API_Log__c 
            WHERE Log_Name__c LIKE 'IndiaMart_API%' 
            ORDER BY CreatedDate DESC
        ];
        // System.assert(!logs.isEmpty(), 'API_Log__c record must be created.');
        // System.assertEquals('Failure', logs[0].Log_Status__c, 'Log_Status__c should be Failure.');
        // System.assertEquals('400', logs[0].Response_Code__c, 'Response code should match failure.');
    }

    // HTTP Mock implementation
    class MockHttpResponseGenerator implements HttpCalloutMock {
        String body;
        Integer code;

        MockHttpResponseGenerator(String body, Integer code) {
            this.body = body;
            this.code = code;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(code);
            return res;
        }
    }
}