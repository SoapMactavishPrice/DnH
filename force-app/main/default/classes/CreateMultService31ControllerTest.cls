@isTest
private class CreateMultService31ControllerTest {

    static testMethod void testAllFunctionality() {
        
        Code_Master__c codeMaster = new Code_Master__c();
        codeMaster.Name = 'Test Code';
        codeMaster.Object__c = 'Service 31';
        codeMaster.Current_Sequence__c = 1;
        codeMaster.Starting_Sequence__c = 1;
        insert codeMaster;

        String result = CreateMultService31Controller.getcodemaster('Service 31');

      
        Multiple_Service_31__c service = new Multiple_Service_31__c(Name = 'Test Service');
        insert service;

        String lineItemJson = '[' +
            '{' +
                '"Existing_TDS_TPS_Reference_No_c":"Ref123",' +
                '"Field_Staff_TDC_Remark_c":"Remark",' +
                '"Quantity_c":"10",' +
                '"Revision_c":"1",' +
                '"TDC_TPS_No_c":"TPS123",' +
                '"Unit_of_Measure_c":"Kg",' +
                '"file":{' +
                    '"Title":"Test File",' +
                    '"VersionData":"Test Data"' +
                '}' +
            '}' +
        ']';

        String mdoc = '{"Title":"Test Document","VersionData":"Document Data"}';

        String addResult = CreateMultService31Controller.addFile_n_LineItems(service.Id, mdoc, lineItemJson);

        List<API_Log__c> logs = new List<API_Log__c>{
            new API_Log__c(Name = 'Old Log'),
            new API_Log__c(Name = 'Recent Log')
        };
        insert logs;

        Test.startTest();
        CreateMultService31Controller.deleteOldRecords();
        Test.stopTest();
    }
}