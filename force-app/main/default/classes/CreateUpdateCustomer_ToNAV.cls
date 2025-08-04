public class CreateUpdateCustomer_ToNAV {
    
    @future(callout=true)
    public static void insertUpdateCustomerData(String JSONData, String accId) {
        
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'CreateUpdateCustomer_ToNAV';
        api_log.created_date__c = Datetime.now();

        try {
            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('CreateUpdateCustomer_ToNAV');
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

                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                insert api_log;

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                // Get the InsertCustomerCard_Result node
                Dom.XMLNode resultNode = soapBody.getChildElement('InsertCustomerCard_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug(resultNode);
                
                // Extract the values
                // Extract the values with the correct namespace
                String returnValue = resultNode.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration').getText();
                String customerNumber = resultNode.getChildElement('custNo', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration').getText();

                System.debug(returnValue);
                System.debug(customerNumber);
                System.debug(accId);

                Account acc = new Account();
                acc.Id = accId;
                acc.Customer_Code__c = customerNumber;
                update acc;
                
                System.debug(res.getBody());
                String jsonResponse = 'Ok';

                // Convert the map to JSON
                // String jsonResponse = insertUpdateCustomerData.convertSoapResponseToJson(res.getBody());
                // System.debug('jsonResponse:>>>> ' +jsonResponse);
                // return jsonResponse;

            } else {

                api_log.Log_Status__c = 'Failure';
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

            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
        }
    }


    public static String insertUpdateCustomerData_v1(String JSONData, String accId) {
        
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'CreateUpdateCustomer_ToNAV';
        api_log.created_date__c = Datetime.now();
        String returnValueResponse ='';
        try {
            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('CreateUpdateCustomer_ToNAV');
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

                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                insert api_log;

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                // Get the InsertCustomerCard_Result node
                Dom.XMLNode resultNode = soapBody.getChildElement('InsertCustomerCard_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug(resultNode);
                
                // Extract the values
                // Extract the values with the correct namespace
                String returnValue = resultNode.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration').getText();
                String customerNumber = resultNode.getChildElement('custNo', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration').getText();

                System.debug(returnValue);
                System.debug(customerNumber);
                System.debug(accId);

                Account acc = new Account();
                acc.Id = accId;
                acc.Customer_Code__c = customerNumber;
                update acc;
                
                System.debug(res.getBody());
                String jsonResponse = 'Ok';
                returnValueResponse=returnValue;
                // Convert the map to JSON
                // String jsonResponse = insertUpdateCustomerData.convertSoapResponseToJson(res.getBody());
                // System.debug('jsonResponse:>>>> ' +jsonResponse);
                // return jsonResponse;

            } else {

                api_log.Log_Status__c = 'Failure';
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

            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
        }
        return returnValueResponse;
    }


}