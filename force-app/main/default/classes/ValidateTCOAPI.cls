@RestResource(urlMapping='/ValidateTCO')
global class ValidateTCOAPI {
    
    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');
        
        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Validate_TCO';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();

        JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        System.debug('======----->jsonObj' + jsonObj);

        try {

            if (jsonObj.TechnoLineNo != '' && jsonObj.TechnoLineNo != null && jsonObj.CustomerNo != '' && jsonObj.CustomerNo != null) {

                List<Enquiry_Line_Item__c> techCOLIList = new List<Enquiry_Line_Item__c>(); // Techno commercial line item list
                techCOLIList = [
                    SELECT Id, Name, Qty__c, Order_Qty__c, RemainingQty__c, Enquiry__r.Account__c
                    FROM Enquiry_Line_Item__c
                    WHERE Name =: jsonObj.TechnoLineNo
                    AND Enquiry__r.Account__c =: jsonObj.CustomerNo
                ];

                System.debug(techCOLIList);

                if (techCOLIList.size() > 0) {
                    
                    // ------------------- Send the Success Response -------------------
                    Map < string, object > successResMap = new Map < string, object > ();
                    successResMap.put('status', 'success');
                    successResMap.put('Qty', techCOLIList[0].Qty__c);
                    successResMap.put('OrderQty', techCOLIList[0].Order_Qty__c);
                    successResMap.put('RemainingQty', techCOLIList[0].RemainingQty__c);
                    String resp = JSON.serialize(successResMap);
                    response.responseBody = Blob.valueOf(resp);
                    response.addHeader('Content-Type', 'application/json');
                    response.statusCode = 200;

                    api_log.Log_Status__c = 'Success';
                    api_log.Response_Code__c = '200';
                    api_log.Response__c = String.valueOf(resp);
                    api_log.response_time__c = Datetime.now();

                } else {

                    // ------------------- Send the Response -------------------
                    Map < string, string > successResMap = new Map < string, string > ();
                    successResMap.put('message', 'TechnoLineNo Not found');
                    successResMap.put('status', 'fail');

                    String resp = JSON.serialize(successResMap);
                    response.responseBody = Blob.valueOf(resp);
                    response.addHeader('Content-Type', 'application/json');
                    response.statusCode = 404;

                    api_log.Log_Status__c = 'Failure';
                    api_log.Response_Code__c = '404';
                    api_log.Response__c = String.valueOf(resp);
                    api_log.response_time__c = Datetime.now();

                }
                
            } else {
                
                // ------------------- Send the Response -------------------
                Map < string, string > successResMap = new Map < string, string > ();
                successResMap.put('message', 'TechnoLineNo and CustomerNo is Required');
                successResMap.put('status', 'fail');

                String resp = JSON.serialize(successResMap);
                response.responseBody = Blob.valueOf(resp);
                response.addHeader('Content-Type', 'application/json');
                response.statusCode = 400;

                api_log.Log_Status__c = 'Failure';
                api_log.Response_Code__c = '400';
                api_log.Response__c = String.valueOf(resp);
                api_log.response_time__c = Datetime.now();

            }

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
        public String TechnoLineNo;
        public String CustomerNo;
    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }

}