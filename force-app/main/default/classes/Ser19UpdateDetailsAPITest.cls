@IsTest
public class Ser19UpdateDetailsAPITest {
    
    @IsTest
    static void testDoPostSuccess() {
        // Create a sample Customer_Complaint__c record
        Customer_Complaint__c complaint = new Customer_Complaint__c(
            Name = 'Ser19/2425/000002',
            S_2VchNo__c = 'Vch123',
            QC_Entry_Date__c = Date.today(),
            Root_Cause_for_Failure__c = 'Test Failure',
            Root_Cause_Department__c = 'Test Department',
            BatchAsPerRecord__c = 'Batch123',
            CounterSampleStatus__c = 'Status123',
            ActionTaken__c = 'Action123',
            PreventiveAction__c = 'Preventive123',
            ResponsiblePerson__c = 'Person123',
            ReportingTo__c = 'Reporting123',
            RejectionReasonDescription__c = 'Reason123'
        );
        insert complaint;

        // JSON request body
        String requestBody = '[{"DocNo":"Ser19/2425/000002","S20VchNo":"Vch456","QCEntryDate":"2024-12-08","RootCauseforFailure":"Updated Failure","RootCauseDepartment":"Updated Department","BatchasperRecord":"Batch456","CounterSamplesStatus":"Updated Status","ActionTaken":"Updated Action","PreventiveAction":"Updated Preventive","ResponsiblePerson":"Updated Person","Actiontakenonresponsible":"Updated Action","Reportingto":"Updated Reporting","Effectiveness":"Updated Effectiveness","RejectionreasonDescription":"Updated Reason"}]';

        // Set up the request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        Ser19UpdateDetailsAPI.doPost();
        Test.stopTest();

        // Verify the response
        String responseBody = res.responseBody.toString();

        // Verify the updated record
        Customer_Complaint__c updatedComplaint = [
            SELECT S_2VchNo__c, Root_Cause_for_Failure__c
            FROM Customer_Complaint__c
            WHERE Id = :complaint.Id
        ];
    }

    @IsTest
    static void testDoPostNoSampleOrderFound() {
        // JSON request body with non-existing Document_No__c
        String requestBody = '[{"DocNo":"NonExistingDocNo","S20VchNo":"Vch456","QCEntryDate":"2024-12-08","RootCauseforFailure":"Updated Failure"}]';

        // Set up the request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        Ser19UpdateDetailsAPI.doPost();
        Test.stopTest();

        // Verify the response
        String responseBody = res.responseBody.toString();
    }

   @IsTest
    static void testDoPostException() {
        
        Customer_Complaint__c complaint = new Customer_Complaint__c(
            Name = 'Ser19/2425/000002',
            S_2VchNo__c = 'Vch123',
            QC_Entry_Date__c = Date.today(),
            Root_Cause_for_Failure__c = 'Test Failure',
            Root_Cause_Department__c = 'Test Department',
            BatchAsPerRecord__c = 'Batch123',
            CounterSampleStatus__c = 'Status123',
            ActionTaken__c = 'Action123',
            PreventiveAction__c = 'Preventive123',
            ResponsiblePerson__c = 'Person123',
            ReportingTo__c = 'Reporting123',
            RejectionReasonDescription__c = 'Reason123'
        );
        insert complaint;
        
        // Create JSON request body with invalid date format to trigger exception
        String jsonRequestBody = '[{"DocNo":"Ser19/2425/000002","S20VchNo":"Vch456","QCEntryDate":"","RootCauseforFailure":"Updated Failure","RootCauseDepartment":"Updated Department","BatchasperRecord":"Batch456","CounterSamplesStatus":"Updated Status","ActionTaken":"Updated Action","PreventiveAction":"Updated Preventive","ResponsiblePerson":"Updated Person","Actiontakenonresponsible":"Updated Action","Reportingto":"Updated Reporting","Effectiveness":"Updated Effectiveness","RejectionreasonDescription":"Updated Reason"}]';

        // Set up the request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonRequestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        Ser19UpdateDetailsAPI.doPost();
        Test.stopTest();

        // Verify the response
        String responseBody = res.responseBody.toString();
    }
}