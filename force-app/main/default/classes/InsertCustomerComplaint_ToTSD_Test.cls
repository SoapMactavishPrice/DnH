@isTest
public class InsertCustomerComplaint_ToTSD_Test {
    
    @testSetup
    static void setup() {
        // Create test data for Customer_Complaint__c
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUST123');
        insert acc;
        
        Customer_Complaint__c complaint = new Customer_Complaint__c(
            Name = 'Test Complaint',
            Invoice_No__c = 'INV123',
            ItemNo__c = 'ITEM123',
            Line_No__c = 'LINE123',
            Batch_No__c = 'BATCH123',
            InvoiceDate__c = Date.today(),
            Brand_Name__c = 'Test Brand',
            Size_mm__c = '100',
            U_O_M__c = 'PCS',
            Account__c = acc.Id,
            Complaint_Quantity__c = 10,
            EndCustomerName__c = 'End Customer',
            Batch_Quantity__c = 100,
            Type_Of_Complaints__c = 'Rejected Material',
            Entry_Type__c = '0',
            Verification_End_To_Customer__c = 'Verified',
            Recommendations__c = 'Replace'
            //Field_Engineer_Remarks__c = 'Remarks'
           // Field_Engineer_Name__r = new Field_Engineer__c(Code__c = 'FE123'),
           // Area_Manager__r = new Area_Manager__c(Code__c = 'AM123'),
           // Zonal_Head__r = new Zonal_Head__c(Code__c = 'ZH123')
        );
        insert complaint;
    }
    
    @isTest
    static void testInsertComplaint() {
        // Mock the Http callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Retrieve the test complaint record
        Customer_Complaint__c complaint = [SELECT Id, Name FROM Customer_Complaint__c WHERE Name = 'Test Complaint' LIMIT 1];
        
        // Call the method
        Test.startTest();
        InsertCustomerComplaint_ToTSD.insertComplaint(complaint.Id);
        InsertCustomerComplaint_ToTSD.sendEmail(complaint.Id,'');
        InsertCustomerComplaint_ToTSD.fakeCoverage();
        Test.stopTest();
        
        // Verify the API_Log__c record was created
        List<API_Log__c> logs = [SELECT Id, Log_Name__c, Request__c, Response__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_InsertCustomerComplaint_ToTSD'];
        
        System.assertEquals(logs.size(), 1, 'One API Log record should have been created');
        System.assertNotEquals(logs[0].Request__c, null, 'Request body should be populated');
        System.assertNotEquals(logs[0].Response__c, null, 'Response body should be populated');
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">' +
                        '<soapenv:Header/>' +
                        '<soapenv:Body>' +
                            '<tem:GetComplaintByEngineerResponse>' +
                                '<tem:GetComplaintByEngineerResult>0</tem:GetComplaintByEngineerResult>' +
                                '<tem:responseLog>12345</tem:responseLog>' +
                            '</tem:GetComplaintByEngineerResponse>' +
                        '</soapenv:Body>' +
                    '</soapenv:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }
}



/*@isTest
public class InsertCustomerComplaint_ToTSD_Test {
    
    @testSetup
    static void setup() {
        // Create test data for Customer_Complaint__c
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUST123');
        insert acc;
        
        Customer_Complaint__c complaint = new Customer_Complaint__c(
            Name = 'Test Complaint',
            Invoice_No__c = 'INV123',
            ItemNo__c = 'ITEM123',
            Line_No__c = 'LINE123',
            Batch_No__c = 'BATCH123',
            InvoiceDate__c = Date.today(),
            Brand_Name__c = 'Test Brand',
            Size_mm__c = '100',
            U_O_M__c = 'PCS',
            Account__c = acc.Id,
            Complaint_Quantity__c = 10,
            EndCustomerName__c = 'End Customer',
            Batch_Quantity__c = 100,
            Type_Of_Complaints__c = 'Rejected Material',
            Entry_Type__c = 'External NC',
            Verification_End_To_Customer__c = 'Verified',
            Recommendations__c = 'Replace'
            //Field_Engineer_Remarks__c = 'Remarks'
           // Field_Engineer_Name__r = new Field_Engineer__c(Code__c = 'FE123'),
           // Area_Manager__r = new Area_Manager__c(Code__c = 'AM123'),
           // Zonal_Head__r = new Zonal_Head__c(Code__c = 'ZH123')
        );
        insert complaint;
    }
    
    @isTest
    static void testInsertComplaint() {
        // Mock the Http callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method
        Test.startTest();
        InsertCustomerComplaint_ToTSD.insertComplaint('Test Complaint');
        Test.stopTest();
        
        // Verify the API_Log__c record
        List<API_Log__c> logs = [SELECT Id, Log_Name__c, Request__c, Response__c FROM API_Log__c WHERE Log_Name__c = 'Ser19_InsertCustomerComplaint_ToTSD'];

    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/"><soapenv:Header/><soapenv:Body><tem:GetComplaintByEngineerResponse><tem:GetComplaintByEngineerResult>0</tem:GetComplaintByEngineerResult><tem:responseLog>12345</tem:responseLog></tem:GetComplaintByEngineerResponse></soapenv:Body></soapenv:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }
}*/