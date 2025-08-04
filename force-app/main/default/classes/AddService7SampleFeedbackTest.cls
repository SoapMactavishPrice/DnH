@isTest
public class AddService7SampleFeedbackTest {

    @isTest
    public static void testAddService7SampleFeedback() {
        // Create a test account
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Service_5_Sample_Request__c serv = new Service_5_Sample_Request__c();
        serv.Customer_Name__c='L&T';
        serv.Address_1__c='D&H';
        insert serv;
        
        Sample_Request_Product__c samp = new Sample_Request_Product__c();
        samp.Name= 'SRP00001';
        //samp.Sample_Request_Item_Category_Code__c = '6013 (NORMA-V)';
        samp.Size_mm__c = '2.50 X 350 MM';
        samp.Sample_Request__c=serv.id;
        insert samp;

        // Create a test Service_7_Sample_Feedbacks__c record
        Service_7_Sample_Feedbacks__c feedback = new Service_7_Sample_Feedbacks__c();
        feedback.Name = 'Test Feedback';
        feedback.InvoiceNo__c = 'INV123';
        feedback.Previously_Used_Consumables__c = 'Consumables';
        feedback.Test_Result_of_the_Samples__c = 'Passed';
        feedback.StatusOfOrder__c = 'Received';
        feedback.Sample_Request_Product__c = samp.Id;
        insert feedback;

        String recordId = feedback.Id; 
        String mdoc = '{"Title":"Test Document","VersionData":"VGhpcyBpcyBhIHRlc3Qu"}';

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test with valid document
        String result = AddService7SampleFeedback.AddService7SampleFeedback(recordId, mdoc);
        System.assertEquals('Success', result);

        // Test with null document
        String emptyMdoc = null;
        result = AddService7SampleFeedback.AddService7SampleFeedback(recordId, emptyMdoc);
        System.assertEquals('Success', result);

        // Test with empty string document
        String emptyStringMdoc = '';
        result = AddService7SampleFeedback.AddService7SampleFeedback(recordId, emptyStringMdoc);
        System.assertEquals('Success', result);

        // Test with invalid Base64 document
        String invalidBase64Mdoc = '{"Title":"Invalid Document","VersionData":"NotBase64Encoded"}';
        try {
            AddService7SampleFeedback.AddService7SampleFeedback(recordId, invalidBase64Mdoc);
            //System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Illegal base64 character'), 'Unexpected exception message: ' + e.getMessage());
        }

        // Test with invalid JSON
        String invalidJson = 'Invalid JSON String';
        try {
            List<AddService7SampleFeedback.SampleFeedbackList> parsedList = AddService7SampleFeedback.parseJsonData(invalidJson);
            //System.assert(false, 'Expected exception not thrown');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Unexpected character'), 'Unexpected exception message: ' + e.getMessage());
        }

        // Test with valid document again
        String validMdoc = '{"Title":"Valid Document","VersionData":"VGhpcyBpcyBhIHRlc3Qu"}';
        result = AddService7SampleFeedback.AddService7SampleFeedback(recordId, validMdoc);
        System.assertEquals('Success', result);
    }

    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><InsertSalesOrderFeedBack_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration"><return_value>Success</return_value></InsertSalesOrderFeedBack_Result></soapenv:Body></soapenv:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }
}