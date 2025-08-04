public class createService7SamplefeedbackTrigHandler {
    public static void handleAfterInsert(List<Sample_Request_Product__c> newSampleProducts) {
        List<Service_7_Sample_Feedbacks__c> insertService7Samplefeedback = new List<Service_7_Sample_Feedbacks__c>();

        // Locking Code_Master__c to avoid race conditions while updating sequences
        Code_Master__c codem = [SELECT Id, Name, Object__c, Display_Label__c, Current_Sequence__c, Starting_Sequence__c, 
                                    Backend_Current_Sequence__c FROM Code_Master__c 
                                    WHERE Object__c = 'Service 7-(Sample Feedbacks)' AND Is_Active__c = true 
                                    LIMIT 1 FOR UPDATE];

        for(Sample_Request_Product__c srp : newSampleProducts) {
            Service_7_Sample_Feedbacks__c sf = new Service_7_Sample_Feedbacks__c();

            // Constructing the name using sequence and label
            String name = codem.Display_Label__c + String.valueOf(codem.Backend_Current_Sequence__c);
            sf.Name = name;
            //Debugging if needed
            System.debug('Generated Feedback Name: ' + sf.Name);
            
            // Mapping fields from Sample_Request_Product__c to Service_7_Sample_Feedbacks__c
            sf.Sample_Request_Product__c = srp.Id;
            sf.Item_No__c = srp.Item_No__c;
            sf.Item_Description__c = srp.Description__c;
            sf.Brand_Name__c = srp.Brand_Name__c;
            sf.Size_mm__c = srp.Size_mm__c;
            sf.Qty_Pcs_Kgs__c = String.valueOf(srp.Quantity__c);
            sf.UOM__c = srp.UOM__c;

            insertService7Samplefeedback.add(sf);
            
            // Increment the sequence for the next record
            codem.Current_Sequence__c += 1;
        }

        // Insert the feedback records
        if(!insertService7Samplefeedback.isEmpty()) {
            insert insertService7Samplefeedback;
        }

        // Update the sequence in Code_Master__c
        update codem;
    }

    // @future(callout=true)
    public static void updateSentAPICallout(String InvNo){

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'S7_updateSentAPICallout';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('S7_updateSentAPICallout');
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
            reqBody = reqBody.replace('actualjson', InvNo);
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
                
                Dom.XmlNode response = soapBody.getChildElement('SalesOrderFeedBackSentOn_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode responseLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ responseLog.getText());

                System.debug(res.getBody());
                String jsonResponse = 'Ok';
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = responseLog.getText();
                api_log.response_time__c = Datetime.now();

            }

        } catch (Exception e) {
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Response__c = String.valueOf(e.getMessage());
            api_log.response_time__c = Datetime.now();
            // insert api_log;
            returnResponseLog=e.getMessage();
            
            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
            
        }
        insert api_log;

    }

}