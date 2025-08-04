@isTest
public class InsertCustomerComplaint_ToNAV_Test {

    @isTest
    static void testInsertComplaint() {
        // Create test data
        Customer_Complaint__c complaint = new Customer_Complaint__c(
            Name = 'Test/Complaint/001',
            Invoice_No__c = 'INV123',
           // FS_Name__c = 'John Doe',
            Brand_Name__c = 'BrandX',
            Batch_No__c = 'Batch001',
            Mfg_Date__c = Date.today().addDays(-30),
            TSD_Remarks__c = 'Test remarks',
            Line_No__c = '1'
        );
        insert complaint;

        // Mock the HTTP response
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method
        Test.startTest();
        InsertCustomerComplaint_ToNAV.insertComplaint(complaint.Id);
        Test.stopTest();

        // Verify the results
        API_Log__c[] logs = [SELECT Id, Log_Name__c, Request__c, Response__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_InsertCustomerComplaint_ToNAV'];
        System.assertEquals(1, logs.size());
        System.assertEquals('Ser19_InsertCustomerComplaint_ToNAV', logs[0].Log_Name__c);
    }

    @isTest
    static void testCreateComplaintJsonData() {
        // Create test data
        Customer_Complaint__c complaint = new Customer_Complaint__c(
            Name = 'Test/Complaint/001',
            Invoice_No__c = 'INV123',
           // FS_Name__c = 'John Doe',
            Brand_Name__c = 'BrandX',
            Batch_No__c = 'Batch001',
            Mfg_Date__c = Date.today().addDays(-30),
            TSD_Remarks__c = 'Test remarks',
            Line_No__c = '1'
        );
        insert complaint;

        // Call the method
        String jsonData = InsertCustomerComplaint_ToNAV.createComplaintJsonData(complaint.Id);

        // Verify the results
    }

    @isTest
    static void testParseApprovalSoapResponse() {
        // Mock the SOAP response
        String responseBody = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><InsertServices19New_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration"><compliantDocNo>DOC123</compliantDocNo><return_value>0</return_value></InsertServices19New_Result></soap:Body></soap:Envelope>';

        // Call the method
        String salesDocumentNo = InsertCustomerComplaint_ToNAV.parseApprovalSoapResponse(responseBody, '001');

        // Verify the results
        System.assertEquals('DOC123', salesDocumentNo);
    }
    
}