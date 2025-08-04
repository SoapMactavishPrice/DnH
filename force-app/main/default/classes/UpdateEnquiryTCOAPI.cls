@RestResource(urlMapping='/UpdateTCOStatus')
global class UpdateEnquiryTCOAPI {
    @HttpPost
    global static void doPost() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');
        
        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Update_TCOStatus';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();

        JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        System.debug('======----->jsonObj' + jsonObj);

        try {
            // ------------------- Logic start from here -------------------
            
            List<Enquiry__c> enqList = new List<Enquiry__c>();
            String resString = '';
            enqList = [
                SELECT Id, Name, Status__c FROM Enquiry__c
                WHERE Name =: jsonObj.EnquiryNo
            ];

            if (enqList.size() == 1) { if (enqList[0].Status__c == 'Approved' || enqList[0].Status__c == 'Rejected') {  resString = 'TCO is already ' + enqList[0].Status__c;                 } else {  Enquiry__c enq = new Enquiry__c();  enq.Id = enqList[0].Id;  enq.Status__c = jsonObj.Status; update enq;  resString = 'TCO Status Update Successfully';  }

                   
                
                   

            } else if(enqList.size() > 1) { resString = 'Multiple TCOs Found';
                
            } else {
                resString = 'TCO Not Found';
            }

            System.debug('-->Data Saved Successfully');

            // ------------------- Send the Success Response -------------------
            Map < string, string > successResMap = new Map < string, string > ();
            // successResMap.put('status', 'success');
            successResMap.put('message', resString);
            String resp = JSON.serialize(successResMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;

            api_log.Log_Status__c = 'Success';
            api_log.Response_Code__c = '200';
            api_log.Response__c = String.valueOf(resp);
            api_log.response_time__c = Datetime.now(); } catch (Exception e) { System.debug('Catch Error' + e.getStackTraceString());  System.debug('Catch Error' + e.getMessage()); System.debug('Catch Error' + e.getlineNumber());  Map < string, string > errorResMap = new Map < string, string > ();  errorResMap.put('Message', 'Something went wrong'); errorResMap.put('Error1', e.getMessage());  errorResMap.put('Error2', '' + e.getlineNumber()); errorResMap.put('Error3', '' + String.valueOf(e));

            // ------------------- Create Response Map ------------------- 
           
           
            
           
            

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

    public class JSON2ApexSaveWebToLead {
        public String EnquiryNo;
        public String Status;
    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }
}