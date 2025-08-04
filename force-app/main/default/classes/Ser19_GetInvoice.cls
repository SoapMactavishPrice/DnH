public class Ser19_GetInvoice {

    @AuraEnabled
    public static string getInvoiceList(String startdate, String enddate){

        User usr = [
            SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
            FROM User WHERE Id =:UserInfo.getUserId()
        ];

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Ser19_GetInvoice';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('Ser19_GetInvoice');
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
            reqBody = reqBody.replace('json1', startdate);
            reqBody = reqBody.replace('json2', enddate);
            reqBody = reqBody.replace('json3', usr.Code__c); req.setBody(reqBody); api_log.Request__c = reqBody; HttpResponse res = http.send(req);
            

            

           
            

            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('InsertSalesInvoiceHeaderServices19_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode responseLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                Dom.XmlNode returnValueLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ responseLog.getText());
                System.debug('returnValueLog '+ returnValueLog.getText());
                // Extract the text content of the responseLog element

                if(returnValueLog!=null){
                    String returnValueLogContent = returnValueLog.getText();
                    returnResponseLog = returnValueLogContent;
                }
                
                System.debug(res.getBody());
                String jsonResponse = 'Ok';
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = responseLog.getText();
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

    @AuraEnabled
    public static string getIds(String fs, String am, String zm, String cn){
        try {

            if (String.isEmpty(fs)) {
                throw new AuraHandledException('Field Staff Code (fs) is required.');
            } else if (String.isEmpty(cn)) {
                throw new AuraHandledException('Customer Number (cn) is required.');
            }

            String resData = '';

            List<User> usrList = new List<User>();
            usrList = [
                SELECT Id, Name, Code__c, Reporting_Person_ID__c, Zonal_Manager_ID__c
                FROM User
                WHERE Code__c =: fs LIMIT 1
            ]; // For field staff

            if (usrList.size() > 0) {
                resData = usrList[0].Id;
    
                List<User> usrList1 = new List<User>();
                usrList1 = [
                    SELECT Id, Name, Code__c
                    FROM User
                    WHERE Code__c =: usrList[0].Reporting_Person_ID__c
                    LIMIT 1
                ]; // For area manager
    
                if (usrList1.size() > 0) {
                    resData = resData+','+usrList1[0].Id;
                } else {
                    throw new AuraHandledException('Area manager Not found');
                }
    
                List<User> usrList2 = new List<User>();
                usrList2 = [
                    SELECT Id, Name, Code__c
                    FROM User
                    WHERE Code__c =: usrList[0].Zonal_Manager_ID__c
                    LIMIT 1
                ]; // for Zonal manager
    
                if (usrList2.size() > 0) {
                    resData = resData+','+usrList2[0].Id;
                } else {
                    throw new AuraHandledException('Zonal Manager Not found');
                }

                List<Account> custname = new List<Account>();
                custname = [
                    SELECT Id, Name, Customer_Code__c
                    FROM Account
                    WHERE Customer_Code__c =: cn LIMIT 1
                ];

                if (custname.size() > 0) {
                    resData = resData+','+custname[0].Id;
                } else {
                    throw new AuraHandledException('Customer Not found');
                }

            } else {
                throw new AuraHandledException('Field staff Not found');
            }

            return resData;
        } catch (AuraHandledException e) {throw e;} catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static string getInvoiceLineList(String invNo){

        User usr = [
            SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
            FROM User WHERE Id =:UserInfo.getUserId()
        ];

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Ser19_GetInvoiceLine';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('Ser19_GetInvoiceLine');
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
            reqBody = reqBody.replace('actualjson', invNo);
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
                
                Dom.XmlNode response = soapBody.getChildElement('InsertSalesInvoiceLineServices19_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode responseLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');  Dom.XmlNode returnValueLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration'); if(returnValueLog!=null){  String returnValueLogContent = returnValueLog.getText();  returnResponseLog = returnValueLogContent; } String jsonResponse = 'Ok'; api_log.Log_Status__c = 'Success'; api_log.Response_Code__c = String.valueOf(res.getStatusCode()); api_log.Response__c = responseLog.getText(); api_log.response_time__c = Datetime.now(); insert api_log;

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

    @AuraEnabled
    public static string getInvoiceLotList(String invNo, String itemNo, String lineNo){

        User usr = [
            SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
            FROM User WHERE Id =:UserInfo.getUserId()
        ];

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Ser19_GetInvoiceLot';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('Ser19_GetInvoiceLot');
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
            reqBody = reqBody.replace('json1', invNo);
            reqBody = reqBody.replace('json2', itemNo);
            reqBody = reqBody.replace('json3', lineNo);
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
                
                Dom.XmlNode response = soapBody.getChildElement('InsertSalesInvoiceLineLotServices19_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode responseLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration'); Dom.XmlNode returnValueLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration'); if(returnValueLog!=null){  String returnValueLogContent = returnValueLog.getText();  returnResponseLog = returnValueLogContent; } String jsonResponse = 'Ok'; api_log.Log_Status__c = 'Success'; api_log.Response_Code__c = String.valueOf(res.getStatusCode()); api_log.Response__c = responseLog.getText(); api_log.response_time__c = Datetime.now();  insert api_log;
                

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
    
    @AuraEnabled
    public static string closeReopenComplainttoNAV(String invno, String actiontype){
        try {

            if (actiontype == 'closebtn') {  CloseReopenComplaint_ToNAV.closeCustomerComplaint(invno);
               
            } else if(actiontype == 'reopenbtn'){
                CloseReopenComplaint_ToNAV.reopenCustomerComplaint(invno);
            }
            
            return 'ok';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string addAttachment(String Id, String filedata){
        try {

            List < ContentVersion > contentVersions = new List < ContentVersion > ();
            List < ContentDocumentLink > contentLinks = new List < ContentDocumentLink > ();
            List<ContentDistribution> contentDistributions = new List<ContentDistribution>();

            System.debug(filedata);
            Map < String, Object > relatedDocumentMap = (Map < String, Object > ) JSON.deserializeUntyped(filedata);

            // Validate and retrieve the fields
            String title = relatedDocumentMap.containsKey('Title') ? (String) relatedDocumentMap.get('Title') : null;
            String base64Data = relatedDocumentMap.containsKey('VersionData') ? (String) relatedDocumentMap.get('VersionData') : null;

            // Decode Base64 string into Blob
            Blob versionData = base64Data != null ? EncodingUtil.base64Decode(base64Data) : null;

            if (String.isBlank(title) || versionData == null) {
                throw new AuraHandledException('Invalid or missing data in JSON: Title or VersionData is null');
            }

            // Proceed with valid data
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = title;
            contentVersion.PathOnClient = '/' + title;
            contentVersion.VersionData = versionData;

            insert contentVersion;
            
            // Query ContentDocumentId from the inserted ContentVersion
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

            
            // Create ContentDocumentLink
            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.ContentDocumentId = contentDocumentId;
            contentLink.LinkedEntityId = Id; // Associate with Sales_Order_Line_Item__c
            contentLink.ShareType = 'V';
            contentLink.Visibility = 'AllUsers';
            contentLinks.add(contentLink);

            // Generate ContentDistribution
            ContentDistribution contentDist = new ContentDistribution(
                Name = title,
                ContentVersionId = contentVersion.Id,
                PreferencesAllowViewInBrowser= true,
                PreferencesLinkLatestVersion=true,
                PreferencesNotifyOnVisit=false

            );
            contentDistributions.add(contentDist);

            // Insert all ContentDocumentLinks
            if (!contentLinks.isEmpty()) {
                insert contentLinks;
            }

            // Insert all ContentDistributions
            if (!contentDistributions.isEmpty()) {
                insert contentDistributions;
            }

            return 'ok';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}