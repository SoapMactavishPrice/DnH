@isTest
public class ApproveTCOAPITest {

    private static void setupTestData() {
        Account acc = new Account(Name = 'Finesse IT');
        insert acc;

        Item_Master__c itemMaster = new Item_Master__c(Name = 'Item001',Item_Number__c='Item001');
        insert itemMaster;

        Enquiry__c enquiry = new Enquiry__c(
            Enquiry_Name__c = 'TestDoc001',
            Account__c = acc.Id,
            Area_Manager__c = userInfo.getUserId(),
            Field_Staff_Code__c = userInfo.getUserId(),
            IsSubmit__c = True,
            Status__c = 'Drafted'
        );
        insert enquiry;

        Enquiry_Line_Item__c enquiryLineItem = new Enquiry_Line_Item__c(
            Enquiry__c = enquiry.Id,
            Item_Master__c = itemMaster.Id,
            SuggestedDealerPrice__c = 1000,
            Discount_In_Percentage__c = 10,
            Document_Line_Number__c = 1
        );
        insert enquiryLineItem;
    }

    @isTest
    static void testDoPost() {
        setupTestData();

        String jsonBody = '[{' +
                          '"DocumentNo": "TestDoc001",' +
                          '"Status": "Drafted",' +
                          '"ApprovedRemark": "Approved Successfully",' +
                          '"ApprovedOn_DD_MM_YYYY": "2024-12-01 12:00:00",' +
                          '"ApprovedBy": "Test User",' +
                          '"Valid_Up_To_DD_MM_YYYY": "2025-12-01 12:00:00",' +
                          '"IsSubmit": "true",' +
                          '"OfferStatus": "Accepted",' +
                          '"IschangedPrice": "false",' +
                          '"TCOItems": [{' +
                              '"Item_No": "Item001",' +
                              '"Discount_In_Percentage": "15",' +
                              '"SuggestedDealerPrice": "900",' +
                              '"DocumentLineNo": 1' +
                          '}]' +
                          '}]';

        // Mock HTTP request and response
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/ApproveTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        ApproveTCOAPI.doPost();
        Test.stopTest();
    }

    @isTest
    static void testEnquiryNotFound() {
        String jsonBody = '[{' +
                          '"DocumentNo": "NonExistentDoc",' +
                          '"Status": "Drafted",' +
                          '"ApprovedRemark": "Approved Successfully",' +
                          '"ApprovedOn_DD_MM_YYYY": "2024-12-01 12:00:00",' +
                          '"ApprovedBy": "Test User",' +
                          '"Valid_Up_To_DD_MM_YYYY": "2025-12-01 12:00:00",' +
                          '"IsSubmit": "true",' +
                          '"OfferStatus": "Accepted",' +
                          '"IschangedPrice": "false",' +
                          '"TCOItems": [{' +
                              '"Item_No": "Item001",' +
                              '"Discount_In_Percentage": "15",' +
                              '"SuggestedDealerPrice": "900",' +
                              '"DocumentLineNo": 1' +
                          '}]' +
                          '}]';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/ApproveTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        ApproveTCOAPI.doPost();
        Test.stopTest();
    }

    @isTest
    static void testEnquiryLineItemsNotFound() {
        Account acc = new Account(Name = 'Finesse IT');
        insert acc;

        Enquiry__c enquiry = new Enquiry__c(
            Enquiry_Name__c = 'TestDoc002',
            Account__c = acc.Id,
            IsSubmit__c = True
        );
        insert enquiry;

        String jsonBody = '[{' +
                          '"DocumentNo": "TestDoc002",' +
                          '"Status": "Drafted",' +
                          '"ApprovedRemark": "Approved Successfully",' +
                          '"ApprovedOn_DD_MM_YYYY": "2024-12-01 12:00:00",' +
                          '"ApprovedBy": "Test User",' +
                          '"Valid_Up_To_DD_MM_YYYY": "2025-12-01 12:00:00",' +
                          '"IsSubmit": "true",' +
                          '"OfferStatus": "Accepted",' +
                          '"IschangedPrice": "false",' +
                          '"TCOItems": [{' +
                              '"Item_No": "Item001",' +
                              '"Discount_In_Percentage": "15",' +
                              '"SuggestedDealerPrice": "900",' +
                              '"DocumentLineNo": 1' +
                          '}]' +
                          '}]';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/ApproveTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        ApproveTCOAPI.doPost();
        Test.stopTest();
    }

    @isTest
    static void testDoPost_Exception() {
        setupTestData();

        String jsonBody = '[{' +
                          '"DocumentNo": "TestDoc001",' +
                          '"Status": "Drafted",' +
                          '"ApprovedRemark": "Approved Successfully",' +
                          '"ApprovedOn_DD_MM_YYYY": "InvalidDate",' + // Invalid date to cause exception
                          '"ApprovedBy": "Test User",' +
                          '"Valid_Up_To_DD_MM_YYYY": "2025-12-01 12:00:00",' +
                          '"IsSubmit": "true",' +
                          '"OfferStatus": "Accepted",' +
                          '"IschangedPrice": "false",' +
                          '"TCOItems": [{' +
                              '"Item_No": "Item001",' +
                              '"Discount_In_Percentage": "15",' +
                              '"SuggestedDealerPrice": "900",' +
                              '"DocumentLineNo": 1' +
                          '}]' +
                          '}]';

        // Mock HTTP request and response
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestURI = '/ApproveTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        try {
            ApproveTCOAPI.doPost();
        } catch (Exception e) {
            // Verify the response
            String responseBody = res.responseBody.toString();
            System.assert(responseBody.contains('Something went wrong'), 'Expected error message not found');
            System.assertEquals(400, res.statusCode, 'Expected status code 400');
        }
        Test.stopTest();
    }
}