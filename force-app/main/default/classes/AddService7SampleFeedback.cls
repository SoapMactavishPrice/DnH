public class AddService7SampleFeedback {
    @AuraEnabled
    public static string AddService7SampleFeedback(String Id,String mdoc) {
        String ress = '';
        try {
            // Handling main document attachment if needed
            if (mdoc != null && mdoc != '') {
                relatedFile relatedDocument = (relatedFile) System.JSON.deserialize(mdoc, relatedFile.class);
                Attachment att = new Attachment();
                att.ParentId = Id;
                att.Name = relatedDocument.Title;
                att.Body = EncodingUtil.base64Decode(relatedDocument.VersionData); // Decode base64 string
                insert att;           
            }
            ress = AddService7SampleFeedback.updateReceivedAPICallout(Id);
            // if (ress == '1') {
            //     ress = Service7_ToTSD.createService7ToTSD(Id);
            // }
        }catch (Exception e) {
            System.debug('Error at line: ' + e.getLineNumber() + ', message: ' + e.getMessage());
            ress = 'Error at line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
        return ress;
    }
    
    public static String updateReceivedAPICallout(String fbId){

        String returnResponseLog = '';

        Service_7_Sample_Feedbacks__c sf = [
            SELECT Id, Name, Previously_Used_Consumables__c, Test_Result_of_the_Samples__c, InvoiceNo__c, StatusOfOrder__c,
            Is_Update_Received_Done__c, IsCreatedToTSD__c
            FROM Service_7_Sample_Feedbacks__c
            WHERE Id =: fbId
        ];

        if (sf.Is_Update_Received_Done__c && !sf.IsCreatedToTSD__c) {
            // returnResponseLog = Service7_ToTSD.createService7ToTSD(fbId);
            returnResponseLog = '1';
            return returnResponseLog;
        }

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'S7_updateReceivedAPICallout';
        api_log.created_date__c = Datetime.now();

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('S7_updateReceivedAPICallout');
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
            reqBody = reqBody.replace('json1', sf.InvoiceNo__c);
            reqBody = reqBody.replace('json2', sf.Previously_Used_Consumables__c);
            reqBody = reqBody.replace('json3', sf.Test_Result_of_the_Samples__c);
            reqBody = reqBody.replace('json4', sf.StatusOfOrder__c);
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
                
                Dom.XmlNode response = soapBody.getChildElement('InsertSalesOrderFeedBack_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode responseLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ responseLog.getText());

                if (responseLog.getText() == '1') {
                    sf.Is_Update_Received_Done__c = true;
                    update sf;
                }

                System.debug(res.getBody());
                String jsonResponse = 'Ok';
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = responseLog.getText();
                api_log.response_time__c = Datetime.now();

                returnResponseLog=responseLog.getText();
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
        return returnResponseLog;
    }

    public static List<SampleFeedbackList> parseJsonData(String json) {
        return (List<SampleFeedbackList>) System.JSON.deserialize(json, List<SampleFeedbackList>.class);
    }
    
    // Inner class representing each product line item
    public class SampleFeedbackList {
        public relatedFile file;
    }
    
    // Inner class representing related file information
    public class relatedFile {
        public String Title;
        public String VersionData;
    }

}