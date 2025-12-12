public class S7_SalesInvoiceHeader {
    
    // @future(callout=true)
    public static void getInvoiceList(String startdate, String enddate, String usrCode){

        User usr = [
            SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
            FROM User WHERE Id =:UserInfo.getUserId()
        ];

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'S7_SalesInvoice_Header';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('S7_SalesInvoiceHeader');
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
            reqBody = reqBody.replace('json3', usrCode); req.setBody(reqBody); api_log.Request__c = reqBody; HttpResponse res = http.send(req);

            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                // System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('InsertGetSalesInvoiceHeaderServices7_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                // System.debug('responseLog '+ response);
                Dom.XmlNode responseLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                Dom.XmlNode returnValueLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                // System.debug('responseLog '+ responseLog.getText());
                System.debug('returnValueLog '+ returnValueLog.getText());
                // Extract the text content of the responseLog element

                if(returnValueLog!=null){
                    String returnValueLogContent = returnValueLog.getText();
                    returnResponseLog = returnValueLogContent;

                    // Extract the JSON string
                    String jsonString = returnValueLogContent;
                    // System.debug('Extracted JSON: ' + jsonString);

                    // Parse the JSON string into a list of objects
                    List<InvoiceData> invoiceList = (List<InvoiceData>) JSON.deserialize(jsonString, List<InvoiceData>.class);

                    Set<String> invNumSet = new Set<String>();
                    Set<String> invNumSet2 = new Set<String>();
                    for (InvoiceData invoice : invoiceList) {
                        invNumSet.add(invoice.DocNo);
                    }
                    List<Invoice__c> existingInvoiceList = [
                        SELECT Id, Name
                        FROM Invoice__c
                        WHERE Name IN :invNumSet
                    ];
                    for (Invoice__c var : existingInvoiceList) {
                        invNumSet2.add(var.Name);
                    }

                    // for (InvoiceData invoice : invoiceList) {
                    //     if (!invNumSet2.contains(invoice.DocNo)) {
                    //         String invJSON = JSON.serialize(invoice);
                    //         // S7_SalesInvoiceLine.getInvoiceLineitem(invJSON);
                    //         System.enqueueJob(new S7_SalesInvoiceLine(invJSON));
                    //     }
                    // }

                    List<Invoice__c> insertInvoiceList = new List<Invoice__c>();
                    // Debug the parsed list
                    for (InvoiceData invoice : invoiceList) {
                        System.debug('Invoice DATA: ' + invoice.DocNo);
                        System.debug('Check Existing: ' + invNumSet2.contains(invoice.DocNo));
                        if (!invNumSet2.contains(invoice.DocNo) && usrCode == invoice.FieldEngineer) {
                            Invoice__c inv = new Invoice__c();
                            inv.Name = invoice.DocNo;
                            inv.Doc_No__c = invoice.DocNo;
                            inv.Customer_No__c = invoice.CustomerNo;
                            inv.Customer_Name__c = invoice.CustomerName;
                            inv.End_Customer_Name__c = invoice.EndCustomerName;
                            inv.Ship_to_Customer_Name__c = invoice.ShiptoCustomerName;
                            inv.Field_Engineer__c = invoice.FieldEngineer;
                            inv.Area_Manager__c = invoice.AreaManager;
                            inv.Zonal_Manager__c = invoice.ZonalManager;
                            String d1 = invoice.InvoiceDate.replace('/','-');
                            inv.InvoiceDate__c = Date.valueOf(d1);
                            inv.Docket_No__c = invoice.DocketNo;
                            String d2 = invoice.DocketDate.replace('/','-');
                            inv.Docket_Date__c = Date.valueOf(d2);
                            insertInvoiceList.add(inv);
                        }
                    }

                    if(insertInvoiceList.size()>0){
                        insert insertInvoiceList;
                        // for (Invoice__c v : insertInvoiceList) {
                        //     String invJSON = JSON.serialize(v);
                        //     S7_SalesInvoiceLine.getInvoiceLineitem(invJSON);
                        // }
                    }


                }
                
                System.debug(res.getBody());
                String jsonResponse = 'Ok';
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = returnValueLog !=null ? returnValueLog.getText() : responseLog.getText();
                api_log.response_time__c = Datetime.now();
                // insert api_log;

            } else {

                api_log.Log_Status__c = 'Failure';
                returnResponseLog='Failure';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                // insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
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
        // return returnResponseLog;
    }

    // Define a class to map the JSON structure
    public class InvoiceData {
        public String DocNo;
        public String CustomerNo;
        public String CustomerName;
        public String EndCustomerName;
        public String ShiptoCustomerName;
        public String FieldEngineer;
        public String AreaManager;
        public String ZonalManager;
        public String InvoiceDate;
        public String DocketNo;
        public String DocketDate;
    }

}