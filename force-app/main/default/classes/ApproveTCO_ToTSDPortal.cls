public class ApproveTCO_ToTSDPortal {

    
    public static String approveTCO(String JSONData) {

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'ApproveTCO_ToTSD';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';
        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('ApproveTCO_ToTSDPortal');
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
            reqBody = reqBody.replace('actualjson', JSONData);
            req.setBody(reqBody);

            api_log.Request__c = reqBody;

            // Send the HTTP request
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('UpdateTechnoOfferForDealerResponse', 'http://tempuri.org/');
                System.debug('responseLog '+ response);
                Dom.XmlNode responseLog = response.getChildElement('responseLog', 'http://tempuri.org/');
                System.debug('responseLog '+ responseLog);
                // Extract the text content of the responseLog element

                if(responseLog!=null){
                    String responseLogContent = responseLog.getText();
                    returnResponseLog=responseLogContent;
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
        return returnResponseLog;
    }
}