@RestResource(urlMapping='/CreateCustomerComplaint')
global class CreateCustomerComplaintAPI {
    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');
        
        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'CreateCustomerComplaint';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();

        JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        System.debug('======----->jsonObj' + jsonObj);

        try {
            // ------------------- Logic start from here -------------------
            Customer_Complaint__c newCC = new Customer_Complaint__c();
            newCC.Invoice__c = jsonObj.Invoice;
            newCC.Dealer_Name__c = jsonObj.Dealer_Name;
            if (jsonObj.cDate != null && jsonObj.cDate != '') {
                newCC.Date__c = Date.valueOf(jsonObj.cDate);
            }
            newCC.End_Customer_Name__c = jsonObj.End_Customer_Name;
            newCC.Item_No__c = jsonObj.Item_No;
            newCC.Batch_No__c = jsonObj.Batch_No;
            if (jsonObj.Batch_Quantity != null && jsonObj.Batch_Quantity != '') {
                newCC.Batch_Quantity__c = Decimal.valueOf(jsonObj.Batch_Quantity);
            }
            newCC.UOM__c = jsonObj.UOM;
            newCC.Brand_Name__c = jsonObj.Brand_Name;
            if (jsonObj.Mfg_Date != null && jsonObj.Mfg_Date != '') {
                newCC.Mfg_Date__c = Date.valueOf(jsonObj.Mfg_Date);
            }
            if (jsonObj.Complaint_Quantity != null && jsonObj.Complaint_Quantity != '') {
                newCC.Complaint_Quantity__c = Decimal.valueOf(jsonObj.Complaint_Quantity);
            }
            newCC.Size_mm__c = jsonObj.Size_mm;
            newCC.Type_Of_Complaints__c = jsonObj.Type_Of_Complaints;
            newCC.Verification_End_To_Customer__c = jsonObj.Verification_End_To_Customer;
            newCC.Field_Engineer_Name__c = jsonObj.Field_Engineer_Name;
            newCC.Zonal_Head__c = jsonObj.Zonal_Head;
            newCC.Entry_Type__c = jsonObj.Entry_Type;
            newCC.Recommendations__c = jsonObj.Recommendations;
            newCC.Area_Manager__c = jsonObj.Area_Manager;
            newCC.Field_Engineer_Remarks__c = jsonObj.Field_Engineer_Remarks;
            newCC.TSD_Remarks__c = jsonObj.TSD_Remarks;

            insert newCC;

            System.debug('-->Data Saved Successfully');
            // ------------------- Send the Success Response -------------------
            Map < string, string > successResMap = new Map < string, string > ();
            successResMap.put('status', 'success');
            successResMap.put('message', 'Complaint Created');
            successResMap.put('CustomerComplaintId', newCC.Id);
            String resp = JSON.serialize(successResMap);
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

    public class JSON2ApexSaveWebToLead {
        public String Invoice;
        public String Dealer_Name;
        public String cDate;
        public String End_Customer_Name;
        public String Item_No;
        public String Batch_No;
        public String Batch_Quantity;
        public String UOM;
        public String Brand_Name;
        public String Mfg_Date;
        public String Complaint_Quantity;
        public String Size_mm;
        public String Type_Of_Complaints;
        public String Verification_End_To_Customer;
        public String Field_Engineer_Name;
        public String Zonal_Head;
        public String Entry_Type;
        public String Recommendations;
        public String Area_Manager;
        public String Field_Engineer_Remarks;
        public String TSD_Remarks;
    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }

}