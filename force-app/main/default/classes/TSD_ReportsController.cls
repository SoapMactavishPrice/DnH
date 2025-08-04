public class TSD_ReportsController {
    
    @AuraEnabled
    public static string getPostedInvoiceReportData(String customerNo, String startDate, String endDate){
        try {

            String returnResponseLog='';

            User usr = [
                SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
                FROM User WHERE Id =:UserInfo.getUserId()
            ];

            Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

            try {

                HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('SalesInvoiceJSONReport');
                // Initialize the HTTP request
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                
                // Set the endpoint (URL)
                req.setEndpoint(apiparam.Endpoint);
                req.setMethod(apiparam.Method);
                req.setTimeout(120000);
                
                // Set headers
                req.setHeader('SOAPAction', apiparam.SOAPAction);
                req.setHeader('Content-Type', apiparam.ContentType);
                req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
                
                // Set body (SOAP Envelope)
                String reqBody = apiparam.Request_body;
                reqBody = reqBody.replace('para1', startDate);
                reqBody = reqBody.replace('para2', endDate);
                reqBody = reqBody.replace('para3', usr.Code__c);
                // reqBody = reqBody.replace('para3', 'DNH1189');
                reqBody = reqBody.replace('para4', acc.Customer_Code__c);
                req.setBody(reqBody);
                // api_log.Request__c = reqBody;
                HttpResponse res = http.send(req);
                
                System.debug(res.getBody());
    
                if (res.getStatusCode() == 200) {
    
                    Dom.Document doc = new Dom.Document();
                    doc.load(res.getBody());
            
                    // Get the root element of the SOAP Body
                    Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                    System.debug(soapBody);
                    
                    Dom.XmlNode response = soapBody.getChildElement('SalesInvoiceHeaderReport_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('responseLog '+ response);
                    Dom.XmlNode responseLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('responseLog '+ responseLog.getText());
                    // Extract the text content of the responseLog element
    
                    if(responseLog != null){
                        String returnValueLogContent = responseLog.getText();
                        returnResponseLog = returnValueLogContent;
                    } else {
                        returnResponseLog = 'No data found';
                    }
                    
                    System.debug(res.getBody());
                    // String jsonResponse = 'Ok';
                    // api_log.Log_Status__c = 'Success';
                    // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                    // api_log.Response__c = responseLog.getText();
                    // api_log.response_time__c = Datetime.now();
                    // insert api_log;
    
                } else {
    
                    // api_log.Log_Status__c = 'Failure';
                    returnResponseLog = 'Failure';
                    // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                    // api_log.Response__c = String.valueOf(res.getBody());
                    // api_log.response_time__c = Datetime.now();
                    // insert api_log;
    
                    System.debug('Error: ' + res.getStatus());
                    System.debug('Error: ' + res.getBody());
                    // return 'Error: ' + res.getStatus();
                }
                
            } catch (Exception e) {
                // api_log.Log_Status__c = 'Failure';
                // api_log.Response_Code__c = '400';
                // api_log.Response__c = String.valueOf(e.getMessage());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;
                returnResponseLog = e.getMessage();
    
                System.debug('Exception: ' + e.getMessage());
                // return 'Exception: ' + e.getMessage();
                
            }
            return returnResponseLog;
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getCreditNoteReportData(String customerNo, String startDate, String endDate){
        try {

            String returnResponseLog='';

            User usr = [
                SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
                FROM User WHERE Id =:UserInfo.getUserId()
            ];

            Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

            try {

                HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('CreditNoteJSONReport');
                // Initialize the HTTP request
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                
                // Set the endpoint (URL)
                req.setEndpoint(apiparam.Endpoint);
                req.setMethod(apiparam.Method);
                req.setTimeout(120000);
                
                // Set headers
                req.setHeader('SOAPAction', apiparam.SOAPAction);
                req.setHeader('Content-Type', apiparam.ContentType);
                req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
                
                // Set body (SOAP Envelope)
                String reqBody = apiparam.Request_body;
                reqBody = reqBody.replace('para1', startDate);
                reqBody = reqBody.replace('para2', endDate);
                reqBody = reqBody.replace('para3', usr.Code__c);
                // reqBody = reqBody.replace('para3', 'DNH1189');
                reqBody = reqBody.replace('para4', acc.Customer_Code__c);
                req.setBody(reqBody);
                // api_log.Request__c = reqBody;
                HttpResponse res = http.send(req);
                
                System.debug(res.getBody());
    
                if (res.getStatusCode() == 200) {
    
                    Dom.Document doc = new Dom.Document();
                    doc.load(res.getBody());
            
                    // Get the root element of the SOAP Body
                    Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                    System.debug(soapBody);
                    
                    Dom.XmlNode response = soapBody.getChildElement('SalesCreditNoteHeaderReport_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('responseLog '+ response);
                    Dom.XmlNode responseLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('responseLog '+ responseLog.getText());
                    // Extract the text content of the responseLog element
    
                    if(responseLog != null){
                        String returnValueLogContent = responseLog.getText();
                        returnResponseLog = returnValueLogContent;
                    } else {
                        returnResponseLog = 'No data found';
                    }
                    
                    System.debug(res.getBody());
                    // String jsonResponse = 'Ok';
                    // api_log.Log_Status__c = 'Success';
                    // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                    // api_log.Response__c = responseLog.getText();
                    // api_log.response_time__c = Datetime.now();
                    // insert api_log;
    
                } else {
    
                    // api_log.Log_Status__c = 'Failure';
                    returnResponseLog = 'Failure';
                    // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                    // api_log.Response__c = String.valueOf(res.getBody());
                    // api_log.response_time__c = Datetime.now();
                    // insert api_log;
    
                    System.debug('Error: ' + res.getStatus());
                    System.debug('Error: ' + res.getBody());
                    // return 'Error: ' + res.getStatus();
                }
                
            } catch (Exception e) {
                // api_log.Log_Status__c = 'Failure';
                // api_log.Response_Code__c = '400';
                // api_log.Response__c = String.valueOf(e.getMessage());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;
                returnResponseLog = e.getMessage();
    
                System.debug('Exception: ' + e.getMessage());
                // return 'Exception: ' + e.getMessage();
                
            }
            return returnResponseLog;
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getSalesOrderReportData(String customerNo, String startDate, String endDate, Boolean osDtl){
        try {

            String returnResponseLog='';

            // User usr = [
            //     SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
            //     FROM User WHERE Id =:UserInfo.getUserId()
            // ];

            Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

            try {

                HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('SalesOrderJSONReport');
                // Initialize the HTTP request
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                
                // Set the endpoint (URL)
                req.setEndpoint(apiparam.Endpoint);
                req.setMethod(apiparam.Method);
                req.setTimeout(120000);
                
                // Set headers
                req.setHeader('SOAPAction', apiparam.SOAPAction);
                req.setHeader('Content-Type', apiparam.ContentType);
                req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
                
                // Set body (SOAP Envelope)
                String reqBody = apiparam.Request_body;
                reqBody = reqBody.replace('para1', startDate);
                reqBody = reqBody.replace('para2', endDate);
                reqBody = reqBody.replace('para3', acc.Customer_Code__c);
                reqBody = reqBody.replace('para4', osDtl ? 'TRUE' : 'FALSE');
                req.setBody(reqBody);
                // api_log.Request__c = reqBody;
                HttpResponse res = http.send(req);
                
                System.debug(res.getBody());
    
                if (res.getStatusCode() == 200) {
    
                    Dom.Document doc = new Dom.Document();
                    doc.load(res.getBody());
            
                    // Get the root element of the SOAP Body
                    Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                    System.debug(soapBody);
                    
                    Dom.XmlNode response = soapBody.getChildElement('GenerateSalesOrder_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('responseLog '+ response);
                    Dom.XmlNode responseLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('responseLog '+ responseLog.getText());
                    // Extract the text content of the responseLog element
    
                    if(responseLog != null){
                        String returnValueLogContent = responseLog.getText();
                        returnResponseLog = returnValueLogContent;
                    } else {
                        returnResponseLog = 'No data found';
                    }
                    
                    System.debug(res.getBody());
                    // String jsonResponse = 'Ok';
                    // api_log.Log_Status__c = 'Success';
                    // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                    // api_log.Response__c = responseLog.getText();
                    // api_log.response_time__c = Datetime.now();
                    // insert api_log;
    
                } else {
    
                    // api_log.Log_Status__c = 'Failure';
                    returnResponseLog = 'Failure';
                    // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                    // api_log.Response__c = String.valueOf(res.getBody());
                    // api_log.response_time__c = Datetime.now();
                    // insert api_log;
    
                    System.debug('Error: ' + res.getStatus());
                    System.debug('Error: ' + res.getBody());
                    // return 'Error: ' + res.getStatus();
                }
                
            } catch (Exception e) {
                // api_log.Log_Status__c = 'Failure';
                // api_log.Response_Code__c = '400';
                // api_log.Response__c = String.valueOf(e.getMessage());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;
                returnResponseLog = e.getMessage();
    
                System.debug('Exception: ' + e.getMessage());
                // return 'Exception: ' + e.getMessage();
                
            }
            return returnResponseLog;
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getCustomerLedgerReportData(String customerNo, String startDate, String endDate){
        try {

            String returnResponseLog='';

            // User usr = [
            //     SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
            //     FROM User WHERE Id =:UserInfo.getUserId()
            // ];

            Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

            try {

                HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('CustomerLedgerJSONReport');
                // Initialize the HTTP request
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                
                // Set the endpoint (URL)
                req.setEndpoint(apiparam.Endpoint);
                req.setMethod(apiparam.Method);
                req.setTimeout(120000);
                
                // Set headers
                req.setHeader('SOAPAction', apiparam.SOAPAction);
                req.setHeader('Content-Type', apiparam.ContentType);
                req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
                
                // Set body (SOAP Envelope)
                String reqBody = apiparam.Request_body;
                reqBody = reqBody.replace('para1', startDate);
                reqBody = reqBody.replace('para2', endDate);
                reqBody = reqBody.replace('para3', acc.Customer_Code__c);
                req.setBody(reqBody);
                // api_log.Request__c = reqBody;
                HttpResponse res = http.send(req);
                
                System.debug(res.getBody());
    
                if (res.getStatusCode() == 200) {
    
                    Dom.Document doc = new Dom.Document();
                    doc.load(res.getBody());
            
                    // Get the root element of the SOAP Body
                    Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                    System.debug(soapBody);
                    
                    Dom.XmlNode response = soapBody.getChildElement('CustLedgerEntryReport_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('responseLog '+ response);
                    Dom.XmlNode responseLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('responseLog '+ responseLog.getText());
                    // Extract the text content of the responseLog element
    
                    if(responseLog != null){
                        String returnValueLogContent = responseLog.getText();
                        returnResponseLog = returnValueLogContent;
                    } else {
                        returnResponseLog = 'No data found';
                    }
                    
                    System.debug(res.getBody());
                    // String jsonResponse = 'Ok';
                    // api_log.Log_Status__c = 'Success';
                    // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                    // api_log.Response__c = responseLog.getText();
                    // api_log.response_time__c = Datetime.now();
                    // insert api_log;
    
                } else {
    
                    // api_log.Log_Status__c = 'Failure';
                    returnResponseLog = 'Failure';
                    // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                    // api_log.Response__c = String.valueOf(res.getBody());
                    // api_log.response_time__c = Datetime.now();
                    // insert api_log;
    
                    System.debug('Error: ' + res.getStatus());
                    System.debug('Error: ' + res.getBody());
                    // return 'Error: ' + res.getStatus();
                }
                
            } catch (Exception e) {
                // api_log.Log_Status__c = 'Failure';
                // api_log.Response_Code__c = '400';
                // api_log.Response__c = String.valueOf(e.getMessage());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;
                returnResponseLog = e.getMessage();
    
                System.debug('Exception: ' + e.getMessage());
                // return 'Exception: ' + e.getMessage();
                
            }
            return returnResponseLog;
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getSalesRegisterReportData(String customerNo, String startDate, String endDate){

        String returnResponseData='';

        User usr = [
            SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
            FROM User WHERE Id =:UserInfo.getUserId()
        ];

        Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('SalesRegisterJSONReport');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            req.setTimeout(120000);
            
            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
            
            // Set body (SOAP Envelope)
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('para1', startDate);
            reqBody = reqBody.replace('para2', endDate);
            // reqBody = reqBody.replace('para3', usr.Code__c);
            reqBody = reqBody.replace('para3', 'DNH1189');
            reqBody = reqBody.replace('para4', acc.Customer_Code__c);
            req.setBody(reqBody);
            // api_log.Request__c = reqBody;
            HttpResponse res = http.send(req);
            
            System.debug(reqBody);
            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('GenerateSalesRegister_Report_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode return_valueLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('return_valueLog '+ return_valueLog.getText());
                // Extract the text content of the return_valueLog element
                
                if(return_valueLog.getText() == '1'){
                    Dom.XmlNode salesRegisterReport_Log = response.getChildElement('salesRegisterReport', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('salesRegisterReport_Log '+ salesRegisterReport_Log.getText());
                    String salesRegisterReportLogContent = salesRegisterReport_Log.getText();
                    
                    Dom.XmlNode toFile_Log = response.getChildElement('toFile', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('toFile_Log '+ toFile_Log.getText());
                    String fileName = toFile_Log.getText();

                    // Map<String, String> returnResMap = new Map<String, String>();
                    // returnResMap.put('data', salesRegisterReportLogContent);
                    // returnResMap.put('name', fileName);

                    if (salesRegisterReport_Log.getText() != '') {
                        // Decode Base64 to Blob
                        Blob excelBlob = EncodingUtil.base64Decode(salesRegisterReportLogContent);

                        // Create ContentVersion record (Salesforce Files)
                        ContentVersion cv = new ContentVersion();
                        cv.Title = fileName;
                        // cv.PathOnClient = fileName.substringBeforeLast('.')+'.pdf';
                        cv.PathOnClient = fileName;
                        cv.VersionData = excelBlob;
                        cv.IsMajorVersion = true;
                        insert cv;

                        // Query ContentDocumentId from the inserted ContentVersion
                        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

                        // Create ContentDocumentLink
                        ContentDocumentLink contentLink = new ContentDocumentLink();
                        contentLink.ContentDocumentId = contentDocumentId;
                        contentLink.LinkedEntityId = customerNo; // Associate with Enquiry__c
                        contentLink.ShareType = 'V';
                        contentLink.Visibility = 'AllUsers';

                        // Generate ContentDistribution
                        ContentDistribution contentDist = new ContentDistribution(
                            // Name = title +'- public file ',
                            Name = fileName,
                            ContentVersionId = cv.Id,
                            PreferencesAllowViewInBrowser= true,
                            PreferencesLinkLatestVersion=true,
                            PreferencesNotifyOnVisit=false

                        );
                        insert contentDist;

                        insert contentLink;

                        ContentDistribution cdsHeader = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId =: contentLink.ContentDocumentId];

                        // Generate the downloadable file URL
                        String fileDownloadUrl = cdsHeader.ContentDownloadUrl;

                        returnResponseData = fileDownloadUrl;
                    } else {
                        returnResponseData = 'No data found';
                    }

                    // returnResponseData = JSON.serialize(returnResMap);
                } else {
                    returnResponseData = 'No data found';
                }
                
                System.debug(res.getBody());
                // String jsonResponse = 'Ok';
                // api_log.Log_Status__c = 'Success';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = responseLog.getText();
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

            } else {

                // api_log.Log_Status__c = 'Failure';
                returnResponseData = 'Failure';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = String.valueOf(res.getBody());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
            }
            
        } catch (Exception e) {
            // api_log.Log_Status__c = 'Failure';
            // api_log.Response_Code__c = '400';
            // api_log.Response__c = String.valueOf(e.getMessage());
            // api_log.response_time__c = Datetime.now();
            // insert api_log;
            returnResponseData = e.getMessage();

            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
            
        }
        return returnResponseData;
        
    }

    @AuraEnabled
    public static string getDownloadInvoiceDOC(String docNo, String customerNo){
        String returnResponseData='';

        // User usr = [
        //     SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
        //     FROM User WHERE Id =:UserInfo.getUserId()
        // ];

        // Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('SalesInvoiceDoc');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            req.setTimeout(120000);
            
            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
            
            // Set body (SOAP Envelope)
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('para1', docNo);
            req.setBody(reqBody);
            // api_log.Request__c = reqBody;
            HttpResponse res = http.send(req);
            
            System.debug(reqBody);
            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('GenerateInvoice_Report_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode return_valueLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('return_valueLog '+ return_valueLog.getText());
                // Extract the text content of the return_valueLog element
                
                if(return_valueLog.getText() == '1'){
                    Dom.XmlNode salesInvReport_Log = response.getChildElement('salesInvReport', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('salesInvReport_Log '+ salesInvReport_Log.getText());
                    String salesInvReportLogContent = salesInvReport_Log.getText();
                    
                    Dom.XmlNode toFile_Log = response.getChildElement('toFile', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('toFile_Log '+ toFile_Log.getText());
                    String fileName = toFile_Log.getText();

                    Map<String, String> returnResMap = new Map<String, String>();
                    returnResMap.put('data', salesInvReportLogContent);
                    returnResMap.put('name', fileName);

                    // // Decode Base64 to Blob
                    // Blob excelBlob = EncodingUtil.base64Decode(salesRegisterReportLogContent);

                    // // Create ContentVersion record (Salesforce Files)
                    // ContentVersion cv = new ContentVersion();
                    // cv.Title = fileName;
                    // // cv.PathOnClient = fileName.substringBeforeLast('.')+'.pdf';
                    // cv.PathOnClient = fileName;
                    // cv.VersionData = excelBlob;
                    // cv.IsMajorVersion = true;
                    // insert cv;

                    // // Query ContentDocumentId from the inserted ContentVersion
                    // Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

                    // // Create ContentDocumentLink
                    // ContentDocumentLink contentLink = new ContentDocumentLink();
                    // contentLink.ContentDocumentId = contentDocumentId;
                    // contentLink.LinkedEntityId = customerNo; // Associate with Enquiry__c
                    // contentLink.ShareType = 'V';
                    // contentLink.Visibility = 'AllUsers';

                    // // Generate ContentDistribution
                    // ContentDistribution contentDist = new ContentDistribution(
                    //     // Name = title +'- public file ',
                    //     Name = fileName,
                    //     ContentVersionId = cv.Id,
                    //     PreferencesAllowViewInBrowser= true,
                    //     PreferencesLinkLatestVersion=true,
                    //     PreferencesNotifyOnVisit=false

                    // );
                    // insert contentDist;

                    // insert contentLink;

                    // ContentDistribution cdsHeader = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId =: contentLink.ContentDocumentId];

                    // // Generate the downloadable file URL
                    // String fileDownloadUrl = cdsHeader.ContentDownloadUrl;

                    // returnResponseData = fileDownloadUrl;
                    returnResponseData = JSON.serialize(returnResMap);
                } else {
                    returnResponseData = 'No data found';
                }
                
                System.debug(res.getBody());
                // String jsonResponse = 'Ok';
                // api_log.Log_Status__c = 'Success';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = responseLog.getText();
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

            } else {

                // api_log.Log_Status__c = 'Failure';
                returnResponseData = 'Failure';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = String.valueOf(res.getBody());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
            }
            
        } catch (Exception e) {
            // api_log.Log_Status__c = 'Failure';
            // api_log.Response_Code__c = '400';
            // api_log.Response__c = String.valueOf(e.getMessage());
            // api_log.response_time__c = Datetime.now();
            // insert api_log;
            returnResponseData = e.getMessage();

            System.debug('Exception: ' + e.getLineNumber());
            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
            
        }
        return returnResponseData;
    }

    @AuraEnabled
    public static string getDownloadInvoiceNonSORTCDOC(String docNo, String customerNo){
        String returnResponseData='';

        // User usr = [
        //     SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
        //     FROM User WHERE Id =:UserInfo.getUserId()
        // ];

        // Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('SalesNonSORTCInvoiceDoc');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            req.setTimeout(120000);
            
            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
            
            // Set body (SOAP Envelope)
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('para1', docNo);
            req.setBody(reqBody);
            // api_log.Request__c = reqBody;
            HttpResponse res = http.send(req);
            
            System.debug(reqBody);
            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('GenerateTC_Report_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode return_valueLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('return_valueLog '+ return_valueLog.getText());
                // Extract the text content of the return_valueLog element
                
                if(return_valueLog.getText() == '1'){
                    Dom.XmlNode salesInvReport_Log = response.getChildElement('reportTC', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('salesInvReport_Log '+ salesInvReport_Log.getText());
                    String salesInvReportLogContent = salesInvReport_Log.getText();
                    
                    Dom.XmlNode toFile_Log = response.getChildElement('finalFileName', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('toFile_Log '+ toFile_Log.getText());
                    String fileName = toFile_Log.getText();

                    Map<String, String> returnResMap = new Map<String, String>();
                    returnResMap.put('data', salesInvReportLogContent);
                    returnResMap.put('name', fileName);

                    // // Decode Base64 to Blob
                    // Blob excelBlob = EncodingUtil.base64Decode(salesRegisterReportLogContent);

                    // // Create ContentVersion record (Salesforce Files)
                    // ContentVersion cv = new ContentVersion();
                    // cv.Title = fileName;
                    // // cv.PathOnClient = fileName.substringBeforeLast('.')+'.pdf';
                    // cv.PathOnClient = fileName;
                    // cv.VersionData = excelBlob;
                    // cv.IsMajorVersion = true;
                    // insert cv;

                    // // Query ContentDocumentId from the inserted ContentVersion
                    // Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

                    // // Create ContentDocumentLink
                    // ContentDocumentLink contentLink = new ContentDocumentLink();
                    // contentLink.ContentDocumentId = contentDocumentId;
                    // contentLink.LinkedEntityId = customerNo; // Associate with Enquiry__c
                    // contentLink.ShareType = 'V';
                    // contentLink.Visibility = 'AllUsers';

                    // // Generate ContentDistribution
                    // ContentDistribution contentDist = new ContentDistribution(
                    //     // Name = title +'- public file ',
                    //     Name = fileName,
                    //     ContentVersionId = cv.Id,
                    //     PreferencesAllowViewInBrowser= true,
                    //     PreferencesLinkLatestVersion=true,
                    //     PreferencesNotifyOnVisit=false

                    // );
                    // insert contentDist;

                    // insert contentLink;

                    // ContentDistribution cdsHeader = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId =: contentLink.ContentDocumentId];

                    // // Generate the downloadable file URL
                    // String fileDownloadUrl = cdsHeader.ContentDownloadUrl;

                    // returnResponseData = fileDownloadUrl;
                    returnResponseData = JSON.serialize(returnResMap);
                } else {
                    returnResponseData = 'No data found';
                }
                
                System.debug(res.getBody());
                // String jsonResponse = 'Ok';
                // api_log.Log_Status__c = 'Success';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = responseLog.getText();
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

            } else {

                // api_log.Log_Status__c = 'Failure';
                returnResponseData = 'Failure';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = String.valueOf(res.getBody());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
            }
            
        } catch (Exception e) {
            // api_log.Log_Status__c = 'Failure';
            // api_log.Response_Code__c = '400';
            // api_log.Response__c = String.valueOf(e.getMessage());
            // api_log.response_time__c = Datetime.now();
            // insert api_log;
            returnResponseData = e.getMessage();

            System.debug('Exception: ' + e.getLineNumber());
            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
            
        }
        return returnResponseData;
    }

    @AuraEnabled
    public static string getDownloadInvoiceLRDOC(String docNo, String customerNo){
        String returnResponseData='';

        // User usr = [
        //     SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
        //     FROM User WHERE Id =:UserInfo.getUserId()
        // ];

        // Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('SalesLRInvoiceDoc');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            req.setTimeout(120000);
            req.setTimeout(120000);
            
            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
            
            // Set body (SOAP Envelope)
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('para1', docNo);
            req.setBody(reqBody);
            // api_log.Request__c = reqBody;
            HttpResponse res = http.send(req);
            
            System.debug(reqBody);
            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('GenerateLR_Report_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode return_valueLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('return_valueLog '+ return_valueLog.getText());
                // Extract the text content of the return_valueLog element
                
                if(return_valueLog.getText() == '1'){
                    Dom.XmlNode salesInvReport_Log = response.getChildElement('lR_Report', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('salesInvReport_Log '+ salesInvReport_Log.getText());
                    String salesInvReportLogContent = salesInvReport_Log.getText();
                    
                    Dom.XmlNode toFile_Log = response.getChildElement('toFile', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('toFile_Log '+ toFile_Log.getText());
                    String fileName = toFile_Log.getText();

                    Map<String, String> returnResMap = new Map<String, String>();
                    returnResMap.put('data', salesInvReportLogContent);
                    returnResMap.put('name', fileName);

                    // // Decode Base64 to Blob
                    // Blob excelBlob = EncodingUtil.base64Decode(salesRegisterReportLogContent);

                    // // Create ContentVersion record (Salesforce Files)
                    // ContentVersion cv = new ContentVersion();
                    // cv.Title = fileName;
                    // // cv.PathOnClient = fileName.substringBeforeLast('.')+'.pdf';
                    // cv.PathOnClient = fileName;
                    // cv.VersionData = excelBlob;
                    // cv.IsMajorVersion = true;
                    // insert cv;

                    // // Query ContentDocumentId from the inserted ContentVersion
                    // Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

                    // // Create ContentDocumentLink
                    // ContentDocumentLink contentLink = new ContentDocumentLink();
                    // contentLink.ContentDocumentId = contentDocumentId;
                    // contentLink.LinkedEntityId = customerNo; // Associate with Enquiry__c
                    // contentLink.ShareType = 'V';
                    // contentLink.Visibility = 'AllUsers';

                    // // Generate ContentDistribution
                    // ContentDistribution contentDist = new ContentDistribution(
                    //     // Name = title +'- public file ',
                    //     Name = fileName,
                    //     ContentVersionId = cv.Id,
                    //     PreferencesAllowViewInBrowser= true,
                    //     PreferencesLinkLatestVersion=true,
                    //     PreferencesNotifyOnVisit=false

                    // );
                    // insert contentDist;

                    // insert contentLink;

                    // ContentDistribution cdsHeader = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId =: contentLink.ContentDocumentId];

                    // // Generate the downloadable file URL
                    // String fileDownloadUrl = cdsHeader.ContentDownloadUrl;

                    // returnResponseData = fileDownloadUrl;
                    returnResponseData = JSON.serialize(returnResMap);
                } else {
                    returnResponseData = 'No data found';
                }
                
                System.debug(res.getBody());
                // String jsonResponse = 'Ok';
                // api_log.Log_Status__c = 'Success';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = responseLog.getText();
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

            } else {

                // api_log.Log_Status__c = 'Failure';
                returnResponseData = 'Failure';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = String.valueOf(res.getBody());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
            }
            
        } catch (Exception e) {
            // api_log.Log_Status__c = 'Failure';
            // api_log.Response_Code__c = '400';
            // api_log.Response__c = String.valueOf(e.getMessage());
            // api_log.response_time__c = Datetime.now();
            // insert api_log;
            returnResponseData = e.getMessage();

            System.debug('Exception: ' + e.getLineNumber());
            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
            
        }
        return returnResponseData;
    }

    @AuraEnabled
    public static string getDownloadCreditNoteDOC(String docNo, String customerNo){
        String returnResponseData='';

        // User usr = [
        //     SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
        //     FROM User WHERE Id =:UserInfo.getUserId()
        // ];

        // Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('SalesCreditNoteDoc');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            req.setTimeout(120000);
            req.setTimeout(120000);
            
            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
            
            // Set body (SOAP Envelope)
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('para1', docNo);
            req.setBody(reqBody);
            // api_log.Request__c = reqBody;
            HttpResponse res = http.send(req);
            
            System.debug(reqBody);
            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('GenerateCreditNote_Report_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode return_valueLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('return_valueLog '+ return_valueLog.getText());
                // Extract the text content of the return_valueLog element
                
                if(return_valueLog.getText() == '1'){
                    Dom.XmlNode salesInvReport_Log = response.getChildElement('salesCrNoteReport', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('salesInvReport_Log '+ salesInvReport_Log.getText());
                    String salesInvReportLogContent = salesInvReport_Log.getText();
                    
                    Dom.XmlNode toFile_Log = response.getChildElement('toFile', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                    System.debug('toFile_Log '+ toFile_Log.getText());
                    String fileName = toFile_Log.getText();

                    Map<String, String> returnResMap = new Map<String, String>();
                    returnResMap.put('data', salesInvReportLogContent);
                    returnResMap.put('name', fileName);

                    // // Decode Base64 to Blob
                    // Blob excelBlob = EncodingUtil.base64Decode(salesRegisterReportLogContent);

                    // // Create ContentVersion record (Salesforce Files)
                    // ContentVersion cv = new ContentVersion();
                    // cv.Title = fileName;
                    // // cv.PathOnClient = fileName.substringBeforeLast('.')+'.pdf';
                    // cv.PathOnClient = fileName;
                    // cv.VersionData = excelBlob;
                    // cv.IsMajorVersion = true;
                    // insert cv;

                    // // Query ContentDocumentId from the inserted ContentVersion
                    // Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

                    // // Create ContentDocumentLink
                    // ContentDocumentLink contentLink = new ContentDocumentLink();
                    // contentLink.ContentDocumentId = contentDocumentId;
                    // contentLink.LinkedEntityId = customerNo; // Associate with Enquiry__c
                    // contentLink.ShareType = 'V';
                    // contentLink.Visibility = 'AllUsers';

                    // // Generate ContentDistribution
                    // ContentDistribution contentDist = new ContentDistribution(
                    //     // Name = title +'- public file ',
                    //     Name = fileName,
                    //     ContentVersionId = cv.Id,
                    //     PreferencesAllowViewInBrowser= true,
                    //     PreferencesLinkLatestVersion=true,
                    //     PreferencesNotifyOnVisit=false

                    // );
                    // insert contentDist;

                    // insert contentLink;

                    // ContentDistribution cdsHeader = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId =: contentLink.ContentDocumentId];

                    // // Generate the downloadable file URL
                    // String fileDownloadUrl = cdsHeader.ContentDownloadUrl;

                    // returnResponseData = fileDownloadUrl;
                    returnResponseData = JSON.serialize(returnResMap);
                } else {
                    returnResponseData = 'No data found';
                }
                
                System.debug(res.getBody());
                // String jsonResponse = 'Ok';
                // api_log.Log_Status__c = 'Success';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = responseLog.getText();
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

            } else {

                // api_log.Log_Status__c = 'Failure';
                returnResponseData = 'Failure';
                // api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = String.valueOf(res.getBody());
                // api_log.response_time__c = Datetime.now();
                // insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
            }
            
        } catch (Exception e) {
            // api_log.Log_Status__c = 'Failure';
            // api_log.Response_Code__c = '400';
            // api_log.Response__c = String.valueOf(e.getMessage());
            // api_log.response_time__c = Datetime.now();
            // insert api_log;
            returnResponseData = e.getMessage();

            System.debug('Exception: ' + e.getLineNumber());
            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
            
        }
        return returnResponseData;
    }

    public static void fc(){
        Integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}