@RestResource(urlMapping='/UpdateDetailSer19')
global class Ser19UpdateDetailsAPI {
    
    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');
        
        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Service_19 UpdateDetails';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();

        // JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        List<JSON2ApexSaveWebToLead> jsonObjList = (List<JSON2ApexSaveWebToLead>) JSON.deserialize(jSONRequestBody, List<JSON2ApexSaveWebToLead>.class);
        System.debug('======----->jsonObjList' + jsonObjList);

        try {

            JSON2ApexSaveWebToLead jsonObj = jsonObjList[0];

            Map<String, String> responseMap = new Map<String, String>();

            List<Customer_Complaint__c> sampleOrderList = [
                SELECT Id, Name, S_2VchNo__c, QC_Entry_Date__c, Root_Cause_for_Failure__c, Root_Cause_Department__c,
                BatchAsPerRecord__c, CounterSampleStatus__c, ActionTaken__c, PreventiveAction__c, ResponsiblePerson__c,
                ReportingTo__c, RejectionReasonDescription__c
                FROM Customer_Complaint__c
                WHERE Name =: jsonObj.DocNo
            ];

            if (sampleOrderList.size() > 0) {

                Customer_Complaint__c sor = new Customer_Complaint__c();
                sor.Id = sampleOrderList[0].Id;
                // sor.TSD_Remarks__c = jsonObj.DocNo;
                sor.S_2VchNo__c = jsonObj.S20VchNo;
                String formattedQCEntryDate = jsonObj.QCEntryDate.replace('/','-');
                sor.QC_Entry_Date__c = Date.valueOf(formattedQCEntryDate);
                sor.Root_Cause_for_Failure__c = jsonObj.RootCauseforFailure;
                sor.Root_Cause_Department__c = jsonObj.RootCauseDepartment;
                sor.BatchAsPerRecord__c = jsonObj.BatchasperRecord;
                sor.CounterSampleStatus__c = jsonObj.CounterSamplesStatus;
                sor.ActionTaken__c = jsonObj.ActionTaken;
                sor.PreventiveAction__c = jsonObj.PreventiveAction;
                sor.ResponsiblePerson__c = jsonObj.ResponsiblePerson;
                // sor.TSD_Remarks__c = jsonObj.Actiontakenonresponsible; // Field Need to Confirm
                sor.ReportingTo__c = jsonObj.Reportingto;
                // sor.TSD_Remarks__c = jsonObj.Effectiveness; // Field Need to Confirm
                sor.RejectionReasonDescription__c = jsonObj.RejectionreasonDescription;

                update sor;

                responseMap.put('returnValue', '1');
                // responseMap.put('message', 'APPROVED');
                
            } else {
                responseMap.put('returnValue', '0');
                responseMap.put('message', 'Customer Complaint Not Found!!');
            }

            String resp = JSON.serialize(responseMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;

            api_log.Log_Status__c = 'Success';
            api_log.Response_Code__c = '200';
            api_log.Response__c = String.valueOf(resp);
            api_log.response_time__c = Datetime.now();


        } catch (Exception e) {
            System.debug('Catch Error' + e.getStackTraceString());
            System.debug('Catch Error' + e.getMessage());
            System.debug('Catch Error' + e.getlineNumber());

            // ------------------- Create Response Map -------------------
            Map < string, string > errorResMap = new Map < string, string > ();
            errorResMap.put('Message', 'Something went wrong');
            errorResMap.put('Error1', e.getMessage());
            errorResMap.put('Error2', '' + e.getlineNumber());
            errorResMap.put('Error3', '' + String.valueOf(e));

            // ------------------- Send Response Map -------------------
            String resp = JSON.serialize(errorResMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();
            
        }
        
        insert api_log;

    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }

    public class JSON2ApexSaveWebToLead {
        public String DocNo;
        public String S20VchNo;
        public String QCEntryDate;
        public String RootCauseforFailure;
        public String RootCauseDepartment;
        public String BatchasperRecord;
        public String CounterSamplesStatus;
        public String ActionTaken;
        public String PreventiveAction;
        public String ResponsiblePerson;
        public String Actiontakenonresponsible;
        public String Reportingto;
        public String Effectiveness;
        public String RejectionreasonDescription;
    
    }
    

}