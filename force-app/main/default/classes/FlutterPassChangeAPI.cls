@RestResource(urlMapping='/flutterChangePassword')
global class FlutterPassChangeAPI {
    @HttpPost
    global static void changePassword() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jSONRequestBody = req.requestBody.toString().replace('\n', '');

        JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'flutterChangePassword';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();
        
        try {
            Map<String, String> responseMap = new Map<String, String>();
            String resp;

            if (String.isBlank(jsonObj.username) || String.isBlank(jsonObj.newPassword)) {

                responseMap.put('status', 'false');
                responseMap.put('message', 'Username or password cannot be blank');

                res.statusCode = 400;

                api_log.Response_Code__c = '400';
                api_log.Log_Status__c = 'Failure';

            } else {
                
                List<Flutter_User__c> flutterUser = [
                    SELECT Id, Username__c, Password__c, User__c, User__r.Email, User__r.MobilePhone,
                    User__r.Code__c, User__r.Reporting_Person_ID__c, User__r.Zonal_Manager_ID__c
                    FROM Flutter_User__c
                    WHERE Username__c = :jsonObj.username
                    LIMIT 1
                ];
    
                if (flutterUser.size() > 0) {

                    flutterUser[0].Password__c = jsonObj.newPassword;
                    update flutterUser;

                    responseMap.put('status', 'true');
                    responseMap.put('message', 'Password changed successfully');

                    res.statusCode = 200;
                    
                    api_log.Log_Status__c = 'Success';
                    api_log.Response_Code__c = '200';

                } else {

                    responseMap.put('status', 'false');
                    responseMap.put('message', 'Invalid username');

                    res.statusCode = 400;

                    api_log.Response_Code__c = '400';
                    api_log.Log_Status__c = 'Failure';
                }
                
            }
            
            resp = JSON.serialize(responseMap);
            res.responseBody = Blob.valueOf(resp);
            res.addHeader('Content-Type', 'application/json');

            api_log.Response__c = String.valueOf(resp);
            api_log.response_time__c = Datetime.now();

        } catch (Exception e) {

            System.debug('Catch Error' + e.getStackTraceString());
            System.debug('Catch Error' + e.getMessage());
            System.debug('Catch Error' + e.getLineNumber());

            // ------------------- Create Response Map -------------------
            Map < string, string > errorResMap = new Map < string, string > ();
            errorResMap.put('status', 'false');
            errorResMap.put('message', 'Something went wrong');
            errorResMap.put('error', e.getMessage() + ' || ' + e.getlineNumber() + ' || ' + String.valueOf(e));

            // ------------------- Send Response Map -------------------
            String resp = JSON.serialize(errorResMap);
            res.responseBody = Blob.valueOf(resp);
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 400;

            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();

        } finally {
            insert api_log;
        }

    }

    public class JSON2ApexSaveWebToLead {
        public String username;
        public String newPassword;
    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }
}