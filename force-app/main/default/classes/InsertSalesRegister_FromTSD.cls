global class InsertSalesRegister_FromTSD implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Customer_Code__c, Sales_Person_Code__c
            FROM Customer_Sales_Person_Mapping__c
            WHERE Customer_Code__c != null
            AND Sales_Person_Code__c != null
            AND Sales_Person__c != null
            AND Sales_Person__r.IsActive = true
            LIMIT 1
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Customer_Sales_Person_Mapping__c> records) {
        for (Customer_Sales_Person_Mapping__c acc : records) {
            getSalesRegisterData(acc);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch completed!');
    }

    public String getSalesRegisterData(Customer_Sales_Person_Mapping__c acc) {
        String returnResponseData='';
        Date yesterdayDate = Date.today().addDays(-1);
        String formattedDate = String.valueOf(yesterdayDate);
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
            // reqBody = reqBody.replace('para1', formattedDate);
            // reqBody = reqBody.replace('para2', formattedDate);
            // reqBody = reqBody.replace('para3', acc.Sales_Person_Code__c);
            // reqBody = reqBody.replace('para4', acc.Customer_Code__c);
            reqBody = reqBody.replace('para1', '2025-02-22');
            reqBody = reqBody.replace('para2', '2025-02-22');
            reqBody = reqBody.replace('para3', 'DNH1189');
            reqBody = reqBody.replace('para4', 'CUS0000040');
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
                    String fileName = acc.Sales_Person_Code__c+'_'+acc.Customer_Code__c+'_'+toFile_Log.getText();

                    // Map<String, String> returnResMap = new Map<String, String>();
                    // returnResMap.put('data', salesRegisterReportLogContent);
                    // returnResMap.put('name', fileName);

                    if (salesRegisterReport_Log.getText() != '') {
                        processExcel(salesRegisterReportLogContent,fileName);
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

    public void processExcel(String base64Data, String fileName) {
        // Step 1: Decode Base64 to Blob
        Blob excelBlob = EncodingUtil.base64Decode(base64Data);

        ContentVersion content = new ContentVersion(
            Title = fileName.replace('.xlsx','.csv'),
            PathOnClient = fileName.replace('.xlsx','.csv'),
            VersionData = excelBlob,
            IsMajorVersion = true
        );
        insert content;

        Blob zipBlob = content.VersionData;

        // Step 2: Initialize Zippex to Extract the .xlsx ZIP Archive
        Zippex Zippex = new Zippex(zipBlob);
        Map<String, Blob> zipFiles = new Map<String, Blob>();

        // Step 3: Extract Files from the .xlsx ZIP Archive
        System.debug(Zippex.getFileNames());
        // while (Zippex.hasNextFile()) {
        //     ZipEntry file = Zippex.nextFile();
        //     zipFiles.put(file.getFileName(), file.getBlobValue());
        // }
        
        // Step 2: Convert Blob to Attachment (Optional, for Debugging)
        // ContentVersion contentVersion = new ContentVersion(
        //     Title = 'UploadedExcel.xlsx',
        //     PathOnClient = 'UploadedExcel.xlsx',
        //     VersionData = excelBlob
        // );
        // insert contentVersion;
        
        // // Step 3: Parse Excel Blob using an external library (Like Apex Office Converter)
        // List<List<String>> excelData = ExcelReader.parseExcel(excelBlob);
        
        // // Step 4: Iterate and Insert Records (Assuming it's for Customer_Sales_Person_Mapping__c)
        // List<Customer_Sales_Person_Mapping__c> accList = new List<Customer_Sales_Person_Mapping__c>();
        
        // for (Integer i = 1; i < excelData.size(); i++) { // Skipping header row
        //     List<String> row = excelData[i];
        //     // Account acc = new Account(
        //     //     Name = row[0],  // Assuming first column is Account Name
        //     //     Phone = row[1], // Assuming second column is Phone
        //     //     Website = row[2] // Assuming third column is Website
        //     // );
        //     // accList.add(acc);
        //     System.debug('IN PROCESSEXCEL METHOD:>> ' +row);
        // }
        
        // // Step 5: Bulk Insert
        // if (!accList.isEmpty()) {
        //     insert accList;
        // }
    }

}