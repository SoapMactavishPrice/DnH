public class CloseReopenComplaint_ToNAV {

    public static void reopenCustomerComplaint(String docNo){

        // String str = docNo;
        // List<String> parts = str.split('/');
        // String custCompNo = parts[parts.size() - 1];
        String custCompNo = docNo;
        
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Ser19_reopenCustomerComplaint_NAV';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('ReopenComplaint_ToNAV');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            
            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
            
            // Set body (SOAP Envelope)
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('actualjson', custCompNo);
            req.setBody(reqBody);

            api_log.Request__c = reqBody;

            // Send the HTTP request
            HttpResponse res = http.send(req);

            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('Services19Reopen_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode returnValueLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('returnValueLog '+ returnValueLog.getText());
                // Extract the text content of the responseLog element

                if(returnValueLog!=null){
                    String returnValueLogContent = returnValueLog.getText();
                    returnResponseLog = returnValueLogContent;
                    // CloseReopenComplaint_ToTSD.reopenCustomerComplaint(custCompNo);
                }
                
                System.debug(res.getBody());
                String jsonResponse = 'Ok';
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                insert api_log;

            } else {

                api_log.Log_Status__c = 'Failure';
                returnResponseLog='Failure';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
            }
            
        } catch (Exception e) {
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Response__c = String.valueOf(e.getMessage());
            api_log.response_time__c = Datetime.now();
            insert api_log;
            returnResponseLog=e.getMessage();

            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();

        }
        // return returnResponseLog;

    }

    public static void closeCustomerComplaint(String docNo){

        // String str = docNo;
        // List<String> parts = str.split('/');
        // String custCompNo = parts[parts.size() - 1];
        String custCompNo = docNo;
        
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Ser19_closeCustomerComplaint_NAV';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('CloseComplaint_ToNAV');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            
            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
            
            // Set body (SOAP Envelope)
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('actualjson', custCompNo);
            req.setBody(reqBody);

            api_log.Request__c = reqBody;

            // Send the HTTP request
            HttpResponse res = http.send(req);

            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('UpdateServices19_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode returnValueLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('returnValueLog '+ returnValueLog.getText());
                // Extract the text content of the responseLog element

                if(returnValueLog!=null){
                    String returnValueLogContent = returnValueLog.getText();
                    returnResponseLog = returnValueLogContent;
                    if (returnResponseLog == '1') {
                        CloseReopenComplaint_ToTSD.closeCustomerComplaint(custCompNo);
                    }
                }
                
                System.debug(res.getBody());
                String jsonResponse = 'Ok';
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = res.getBody();
                api_log.response_time__c = Datetime.now();
                insert api_log;

            } else {

                api_log.Log_Status__c = 'Failure';
                returnResponseLog='Failure';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
            }
            
        } catch (Exception e) {
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Response__c = String.valueOf(e.getMessage());
            api_log.response_time__c = Datetime.now();
            insert api_log;
            returnResponseLog=e.getMessage();

            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();

        }
        // return returnResponseLog;

    }
    
}