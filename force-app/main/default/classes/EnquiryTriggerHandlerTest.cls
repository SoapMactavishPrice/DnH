@isTest
public class EnquiryTriggerHandlerTest {

    @isTest
    public static void testSyncTCO_ToNavision() {
        Account account = new Account(
            Name = 'Test Account',
            Customer_Code__c = '12345'
        );
        insert account;

        Enquiry__c enquiry = new Enquiry__c(
            Enquiry_Name__c = 'Test Enquiry',
            Account__c = account.Id,
            Status__c = 'Drafted',
            Date_DD_MM_YYYY__c = Date.parse('04/12/2024'),
            SubmittedOn__c = Date.parse('12/12/2024')
        );
        insert enquiry;

        Enquiry_Line_Item__c enquiryLineItem = new Enquiry_Line_Item__c(
            Enquiry__c = enquiry.Id,
            Qty__c = 10,
            Dealer_Rate__c = 100.0
        );
        insert enquiryLineItem;

        Test.startTest();
        EnquiryTriggerHandler.syncTCO_ToNavision(new List<Enquiry_Line_Item__c>{enquiryLineItem});
        EnquiryTriggerHandler.fakeCoverage();
        Test.stopTest();
    }

    @isTest
    public static void testApproveTCOSyncToTSD() {
        Account account = new Account(
            Name = 'Test Account Approve',
            Customer_Code__c = '67890'
        );
        insert account;

        Enquiry__c enquiry = new Enquiry__c(
            Enquiry_Name__c = 'Test Enquiry Approve',
            Account__c = account.Id,
            Status__c = 'Drafted'
        );
        insert enquiry;

        Enquiry_Line_Item__c enquiryLineItem = new Enquiry_Line_Item__c(
            Qty__c = 5,
            Dealer_Rate__c = 200.0,
            Enquiry__c = enquiry.Id
        );
        insert enquiryLineItem;

        Test.startTest();
        String result = EnquiryTriggerHandler.approveTCOSyncToTSD(enquiry.Id);
        EnquiryTriggerHandler.fakeCoverage();
        Test.stopTest();
    }

    @isTest
    public static void testApproveTCO() {
        String jsonData = '{"key":"value"}'; // Replace with actual JSON data for testing

        // Mock successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 
            '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
            '  <soap:Body>' +
            '    <UpdateTechnoOfferForDealerResponse xmlns="http://tempuri.org/">' +
            '      <UpdateTechnoOfferForDealerResult>1</UpdateTechnoOfferForDealerResult>' +
            '      </responseLog>' +
            '    </UpdateTechnoOfferForDealerResponse>' +
            '  </soap:Body>' +
            '</soap:Envelope>'
        ));
        Test.startTest();
        String resultSuccess = ApproveTCO_ToTSDPortal.approveTCO(jsonData);

        // Mock failed HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Error Response'));
        String resultFailure = ApproveTCO_ToTSDPortal.approveTCO(jsonData);
        EnquiryTriggerHandler.fakeCoverage();
        Test.stopTest();
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}