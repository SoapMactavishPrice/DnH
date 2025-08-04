public class CloseReopenComplaint_ToTSD {
    
    @future(callout=true)
    public static void reopenCustomerComplaint(String docNo){
        
        // String str = docNo;
        // List<String> parts = str.split('/');
        // String custCompNo = parts[parts.size() - 1];
        String custCompNo = docNo;

        Customer_Complaint__c excc = new Customer_Complaint__c ();
        if (Test.isRunningTest()){
            excc = [
                SELECT Id, Name, Inserted_By__c, Submitted_By__c, Submitted_Date__c, Account__r.Customer_Code__c, LastModifiedDate,
                Updated_By__c, Status__c, Is_Process__c, IsSubmitted__c, SalesPersonConfirmation__c
                FROM Customer_Complaint__c 
                //WHERE Name = :custCompNo
                LIMIT 1
            ];
        } else {
            excc = [
                SELECT Id, Name, Inserted_By__c, Submitted_By__c, Submitted_Date__c, Account__r.Customer_Code__c, LastModifiedDate,
                Updated_By__c, Status__c, Is_Process__c, IsSubmitted__c, SalesPersonConfirmation__c
                FROM Customer_Complaint__c 
                WHERE Name = :custCompNo
            ];
        }
        
        
        List<Map<String, String>> ccMapList = new List<Map<String, String>>();
        Map<String, String> ccMap = new Map<String, String>();
        
        ccMap.put('DocumentNo', excc.Name);
        ccMap.put('SalesPersonConfirmation', excc.SalesPersonConfirmation__c);
        ccMap.put('IsSubmitted','3');
        ccMap.put('IsProcess','1');
        ccMap.put('IsBackToTSD','1');
        ccMap.put('Status', excc.Status__c);
        ccMap.put('UpdatedBy', excc.Inserted_By__c);
        ccMap.put('CustomerNo', excc.Account__r.Customer_Code__c);
        DateTime currentDateTime = DateTime.now();
        String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
        ccMap.put('UpdatedOn',formattedDateTime);
        
        ccMapList.add(ccMap);
        
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Ser19_reopenCustomerComplaint_TSD';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';
        
        try {
            
            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('ReopenComplaint_TSD');
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
                
                Dom.XmlNode response = soapBody.getChildElement('ReOpenComplaintByEngineerResponse', 'http://tempuri.org/');
                System.debug('responseLog '+ response);
                Dom.XmlNode returnValueLog = response.getChildElement('ReOpenComplaintByEngineerResult', 'http://tempuri.org/');
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
    
    @future(callout=true)
    public static void closeCustomerComplaint(String docNo){
        
        // String str = docNo;
        // List<String> parts = str.split('/');
        // String custCompNo = parts[parts.size() - 1];
        String custCompNo = docNo;
        
        Customer_Complaint__c excc = new Customer_Complaint__c ();
        if (Test.isRunningTest()){
            excc = [
                SELECT Id, Name, Inserted_By__c, Submitted_By__c, Submitted_Date__c, Account__r.Customer_Code__c, LastModifiedDate,
                Updated_By__c, Status__c, Is_Process__c, IsSubmitted__c, SalesPersonConfirmation__c
                FROM Customer_Complaint__c 
                //WHERE Name = :custCompNo
                LIMIT 1
            ];
        } else {
            excc = [
                SELECT Id, Name, Inserted_By__c, Submitted_By__c, Submitted_Date__c, Account__r.Customer_Code__c, LastModifiedDate,
                Updated_By__c, Status__c, Is_Process__c, IsSubmitted__c, SalesPersonConfirmation__c
                FROM Customer_Complaint__c 
                WHERE Name = :custCompNo
            ];
        }
        
        
        List<Map<String, String>> ccMapList = new List<Map<String, String>>();
        Map<String, String> ccMap = new Map<String, String>();
        ccMap.put('InsertedBy', excc.Inserted_By__c);
        ccMap.put('SubmittedBy', excc.Inserted_By__c);
        
        Datetime subDate = excc.Submitted_Date__c;     
        String subFormatdate = subDate.year() + '-' +
            (subDate.month() < 10 ? '0' + String.valueOf(subDate.month()) : String.valueOf(subDate.month())) + '-' +
            (subDate.day() < 10 ? '0' + String.valueOf(subDate.day()) : String.valueOf(subDate.day())) + ' ' +
            (subDate.hour() < 10 ? '0' + String.valueOf(subDate.hour()) : String.valueOf(subDate.hour())) + ':' +
            (subDate.minute() < 10 ? '0' + String.valueOf(subDate.minute()) : String.valueOf(subDate.minute())) + ':' +
            (subDate.second() < 10 ? '0' + String.valueOf(subDate.second()) : String.valueOf(subDate.second()));
        ccMap.put('SubmittedDate', subFormatdate);
        
        ccMap.put('CustomerNo', excc.Account__r.Customer_Code__c);
        
        Datetime lmDate = excc.LastModifiedDate;
        String lmFormatdate = lmDate.year() + '-' +
            (lmDate.month() < 10 ? '0' + String.valueOf(lmDate.month()) : String.valueOf(lmDate.month())) + '-' +
            (lmDate.day() < 10 ? '0' + String.valueOf(lmDate.day()) : String.valueOf(lmDate.day())) + ' ' +
            (lmDate.hour() < 10 ? '0' + String.valueOf(lmDate.hour()) : String.valueOf(lmDate.hour())) + ':' +
            (lmDate.minute() < 10 ? '0' + String.valueOf(lmDate.minute()) : String.valueOf(lmDate.minute())) + ':' +
            (lmDate.second() < 10 ? '0' + String.valueOf(lmDate.second()) : String.valueOf(lmDate.second()));
        ccMap.put('ClosedBySalesPerson', lmFormatdate);
        // ccMap.put('UpdatedBy', excc.Updated_By__c);
        ccMap.put('UpdatedBy', excc.Inserted_By__c);
        ccMap.put('Status', excc.Status__c);
        // ccMap.put('IsProcess', excc.Is_Process__c); // Must  be 4
        // ccMap.put('IsSubmitted', excc.IsSubmitted__c); // must be 2
        ccMap.put('IsProcess', '4'); // Must  be 4
        ccMap.put('IsSubmitted', '2'); // must be 2
        ccMap.put('SalesPersonConfirmation', excc.SalesPersonConfirmation__c);
        ccMap.put('DocumentNo', excc.Name);
        
        ccMapList.add(ccMap);
        
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Ser19_closeCustomerComplaint_ToTSD';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';
        
        try {
            
            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('CloseComplaint_TSD');
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
            reqBody = reqBody.replace('actualjson', json.serialize(ccMapList));
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
                
                Dom.XmlNode response = soapBody.getChildElement('ComplaintClosedByEngineerResponse', 'http://tempuri.org/');
                System.debug('responseLog '+ response);
                Dom.XmlNode returnValueLog = response.getChildElement('ComplaintClosedByEngineerResult', 'http://tempuri.org/');
                Dom.XmlNode returnValueLog2 = response.getChildElement('responseLog', 'http://tempuri.org/');
                System.debug('returnValueLog '+ returnValueLog.getText());
                // Extract the text content of the responseLog element
                
                if(returnValueLog.getText() == '1'){
                    String returnValueLogContent = returnValueLog.getText();
                    returnResponseLog = returnValueLogContent;
                    excc.Close_NAV__c = true;
                    excc.Close_TSD__c = true;
                    update excc;
                } else {
                    String returnValueLogContent = returnValueLog2.getText();
                    returnResponseLog = returnValueLogContent;
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
            
            System.debug('Exception: ' + e.getMessage() + ' || ' +e.getLineNumber());
            // return 'Exception: ' + e.getMessage();
            
        }
        // return returnResponseLog;
        
    }
    
    public static String CreateJSONData(String ccNo, String jsonFor){
        
        Customer_Complaint__c customerComplaintData = [
            SELECT Id, Name, Inserted_By__c,
            Document_No__c, SalesPersonConfirmation__c,
            Updated_By__c,
            Updated_On__c,
            Submitted_By__c,Submitted_Date__c,
            Account__r.Customer_Code__c
            FROM Customer_Complaint__c
            WHERE Name =: ccNo
        ];
        
        List < Map < String, Object >> mpList = new List < Map < String, Object >> ();
        Map<String, Object> ccMap = new Map<String, Object>();
        ccMap.put('DocumentNo', customerComplaintData.Name);
        ccMap.put('SalesPersonConfirmation',customerComplaintData.SalesPersonConfirmation__c);
        
        ccMap.put('Status','Re-Submitted By Sales Person');
        
        // User usr = [SELECT Id, Name, Code__c FROM User WHERE Id =: customerComplaintData.Updated_By__c];
        User usr = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: customerComplaintData.Inserted_By__c];
        ccMap.put('UpdatedBy',usr.Code__c);
        
        // DateTime currentDateTime = DateTime.valueOf(customerComplaintData.Updated_On__c);
        DateTime currentDateTime = DateTime.now();
        String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
        
        ccMap.put('CustomerNo', customerComplaintData.Account__r.Customer_Code__c);
        
        if (jsonFor == 'reopen') {
            ccMap.put('UpdatedOn',formattedDateTime);
            ccMap.put('IsBackToTSD','1');
            ccMap.put('IsSubmitted','3');
            ccMap.put('IsProcess','1');
        }
        
        if (jsonFor == 'close') {
            DateTime currentDateTime2 = DateTime.valueOf(customerComplaintData.Submitted_Date__c);
            String formattedDateTime2 = currentDateTime2.format('yyyy-MM-dd HH:mm:ss');
            ccMap.put('SubmittedDate',formattedDateTime2);
            
            // User usr1 = [SELECT Id, Name, Code__c  FROM User WHERE Id =: customerComplaintData.Submitted_By__c];
            User usr1 = [SELECT Id, Name, Code__c  FROM User WHERE Code__c =: customerComplaintData.Inserted_By__c];
            ccMap.put('SubmittedBy',usr1.Code__c);
            
            User usr2 = [SELECT Id, Name, Code__c  FROM User WHERE Code__c =: customerComplaintData.Inserted_By__c];
            ccMap.put('InsertedBy',usr2.Code__c);
            
            ccMap.put('IsSubmitted','2');
            ccMap.put('IsProcess','4');
            ccMap.put('ClosedBySalesPerson',formattedDateTime);
        }
        
        
        mpList.add(ccMap);
        
        return JSON.serialize(mpList);
        
    }
    
}