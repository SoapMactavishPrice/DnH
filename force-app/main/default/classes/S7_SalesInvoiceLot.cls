// public class S7_SalesInvoiceLot implements Queueable, Database.AllowsCallouts {
public class S7_SalesInvoiceLot {

    // public Invoice_Line_Item__c invLIobj;

    // public S7_SalesInvoiceLot(String invoiceLineItem, String invoiceHeader) {
    //     // this.invLIobj = (Invoice_Line_Item__c) JSON.deserialize(invoiceLineItem, Invoice_Line_Item__c.class);
    //     mapdata = (Map<String,Object>) JSON.deserializeUntyped(invoiceLineItem);
    //     mapdata = (Map<String,Object>) JSON.deserializeUntyped(invoiceHeader);
    // }
    
    // @future(callout=true)
    // public static void getInvoiceLot(String invoiceLineItem, String invoiceHeader) {
    public static void getInvoiceLot(String invoiceLineItem,String Docket_No,Date Docket_Date,Date InvoiceDate, String custName, String fieldEngg) {

        Map<String,Object> mapdata = new Map<String,Object> ();
        List<User> getFieldEngg = [SELECT Id, Name FROM User WHERE Code__c = :fieldEngg LIMIT 1];
        // Map<String,Object> mapdata = new Map<String,Object> ();
        
        mapdata = (Map<String,Object>) JSON.deserializeUntyped(invoiceLineItem);
        // mapdata = (Map<String,Object>) JSON.deserializeUntyped(invoiceHeader);
        // User usr = [
        //     SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
        //     FROM User WHERE Id =:UserInfo.getUserId()
        // ];

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'S7_SalesInvoice_Lot';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('S7_SalesInvoiceLot');
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
            reqBody = reqBody.replace('json1', (String)mapdata.get('Doc_No__c'));
            reqBody = reqBody.replace('json2', (String)mapdata.get('Item_No__c'));
            reqBody = reqBody.replace('json3', (String)mapdata.get('Line_No__c'));
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
                
                Dom.XmlNode response = soapBody.getChildElement('InsertGetSalesInvoiceLineLotServices7_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ response);
                Dom.XmlNode responseLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                Dom.XmlNode returnValueLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog '+ responseLog.getText());
                System.debug('returnValueLog '+ returnValueLog.getText());
                // Extract the text content of the responseLog element

                if(returnValueLog!=null){
                    String returnValueLogContent = returnValueLog.getText();
                    returnResponseLog = returnValueLogContent;

                    // Extract the JSON string
                    String jsonString = returnValueLogContent;
                    System.debug('Extracted JSON: ' + jsonString);

                    // Parse the JSON string into a list of objects
                    List<InvoiceLotData> invoiceLotList = (List<InvoiceLotData>) JSON.deserialize(jsonString, List<InvoiceLotData>.class);

                    // Debug the parsed list
                    // for (InvoiceLotData invlot : invoiceLotList) {
                    //     System.debug('Invoice Lot DATA: ' + invlot);
                    // }

                    // Locking Code_Master__c to avoid race conditions while updating sequences
                    Code_Master__c codem = [
                        SELECT Id, Name, Object__c, Display_Label__c, Current_Sequence__c, Starting_Sequence__c,
                        Backend_Current_Sequence__c FROM Code_Master__c
                        WHERE Object__c = 'Service 7-(Sample Feedbacks)' AND Is_Active__c = true
                        LIMIT 1 FOR UPDATE
                    ];

                    Service_7_Sample_Feedbacks__c sf = new Service_7_Sample_Feedbacks__c();
                    // System.debug((String)mapdata.get('SamplesSalesOrderNo'));
                    // System.debug((String)mapdata.get('ItemNo'));
                    
                    List<Sample_Request_Product__c> srp = new List<Sample_Request_Product__c>();
                    
                    if (Test.isRunningTest()) {
            			srp = [
                            SELECT Id, Name
                            FROM Sample_Request_Product__c
                            LIMIT 1
                    	];
                    } else {
                        srp = [
                            SELECT Id, Name
                            FROM Sample_Request_Product__c
                            WHERE Sample_Order_Number__c =: (String)mapdata.get('Sample_Sales_Order_Number__c')
                            AND Item_No__r.Item_Number__c =: (String)mapdata.get('Item_No__c')
                            LIMIT 1
                        ];
                    }

                    if (srp.size() > 0) {
                        sf.Name = codem.Display_Label__c + String.valueOf(codem.Backend_Current_Sequence__c);
                        sf.Sample_Request_Product__c = srp[0].Id;
                        sf.Item_Description__c = (String)mapdata.get('Description__c');
                        sf.InvoiceNo__c = (String)mapdata.get('Doc_No__c');
                        sf.ItemNo__c = (String)mapdata.get('Item_No__c');
                        sf.Qty_Pcs_Kgs__c = (String)mapdata.get('Quantity__c');
                        sf.Sizemm__c = (String)mapdata.get('Size__c');
                        sf.BrandName__c = (String)mapdata.get('Item_Brand__c');
                        sf.U_O_M__c = (String)mapdata.get('UOM__c');
                        sf.SampleSalesOrderNumber__c = (String)mapdata.get('Sample_Sales_Order_Number__c');
                        sf.Batch_No__c = invoiceLotList[0].LotNo;
                        sf.Docket_No__c = Docket_No;
                        String dd = String.valueOf(Docket_Date);
                        String d2 = dd.replace('/','-');
                        sf.Docket_Date__c = Date.valueOf(d2);
                        String invdate = String.valueOf(InvoiceDate);
                        String invdate2 = invdate.replace('/','-');
                        sf.Date__c = Date.valueOf(invdate2);
                        sf.CustomerName__c = custName;
                        sf.Name_of_Field_Staff__c = getFieldEngg.size()>0 ? getFieldEngg[0].Name : '';

                        // sf.SampleSalesOrderNumber__c = (String)mapdata.get('Description__c');
                        // sf.Invoice_Date__c = (String)mapdata.get('Description__c');
                        // sf.StatusOfOrder__c = (String)mapdata.get('Description__c');
                        // sf.ContactPersonName__c = (String)mapdata.get('Description__c');
                        // sf.CustomerName__c = (String)mapdata.get('Description__c');
                        // sf.Contact_Person_Designation__c = (String)mapdata.get('Description__c');
                        // sf.Testing_Date__c = (String)mapdata.get('Description__c');
                        // sf.Email_Id__c = (String)mapdata.get('Description__c');
                        // sf.Contact_No__c = (String)mapdata.get('Description__c');
                        // sf.Contact_Person_Address__c = (String)mapdata.get('Description__c');
                        // sf.Remark__c = (String)mapdata.get('Description__c');
                        insert sf;
                        codem.Current_Sequence__c += 1;
                        update codem;
                        sendEmail(sf.Id);
                        api_log.Response__c = returnValueLog !=null ? returnValueLog.getText() : responseLog.getText();
                    } else {
                        api_log.Response__c = 'No Sample Request Product Found for Item No: '+(String)mapdata.get('ItemNo')+' and Sample Order No: '+(String)mapdata.get('SamplesSalesOrderNo');
                    }
                }
                
                System.debug(res.getBody());
                String jsonResponse = 'Ok';
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                // api_log.Response__c = responseLog.getText();
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
            
            System.debug('Exception Invoice Lot: ' + e.getMessage() + ' || ' +e.getLineNumber());
            // return 'Exception: ' + e.getMessage();
            
        }
        insert api_log;
        // return 'OK';
    }

    public static void sendEmail(String recId){

        Service_7_Sample_Feedbacks__c fb = [
            SELECT Id, Name, Sample_Request_Product__c, Item_Description__c, InvoiceNo__c, ItemNo__c, Qty_Pcs_Kgs__c,
            Sizemm__c, BrandName__c, U_O_M__c, SampleSalesOrderNumber__c, Batch_No__c, Docket_No__c, Docket_Date__c, Date__c,
            CustomerName__c, Name_of_Field_Staff__c, Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Code__c,
            Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Name,
            Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Email
            FROM Service_7_Sample_Feedbacks__c
            WHERE Id =: recId
        ];

        String emailsub = 'Pending FeedBacks for Sample Order ' +fb.Date__c;
        String emailBody = ''
        + '<p>Dear <strong>'+fb.Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Name+'</strong>,</p>'
        + '<p>Following samples have been dispatched to you.<br/>'
        + 'Please do testing at customer site and submit your feedback in the portal\'s Service 7 document mentioned hereunder.</p>'
        + '<br/>'
        + '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">'
        + '<tr>'
        + '<th>Sample Sales Order No</th>'
        + '<th>Document No</th>'
        + '<th>Date</th>'
        + '<th>Invoice NO</th>'
        + '<th>Invoice Date</th>'
        + '<th>Docket No</th>'
        + '<th>Docket Date</th>'
        + '<th>Item Description</th>'
        + '<th>Batch No</th>'
        + '<th>Qty</th>'
        + '<th>UOM</th>'
        + '</tr>'
        + '<tr>'
        + '<td>'+fb.SampleSalesOrderNumber__c+'</td>'
        + '<td>'+fb.Name+'</td>'
        + '<td>'+fb.Date__c+'</td>'
        + '<td>'+fb.InvoiceNo__c+'</td>'
        + '<td>'+fb.Date__c+'</td>'
        + '<td>'+fb.Docket_No__c+'</td>'
        + '<td>'+fb.Docket_Date__c+'</td>'
        + '<td style="white-space: normal; word-wrap: break-word;">'+fb.Item_Description__c+'</td>'
        + '<td>'+fb.ItemNo__c+'</td>'
        + '<td>'+fb.Qty_Pcs_Kgs__c+'</td>'
        + '<td>'+fb.U_O_M__c+'</td>'
        + '</tr>'
        + '</table>';

        // String managerEmail = '';
        String staffEmail = '';
        if (!Test.isRunningTest()) {
            // managerEmail = x.Area_Manager__r.Email;
            staffEmail = fb.Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Email;
            // staffEmail = 'huzaifa@finessedirect.com';
        } else {
            // managerEmail = 'huzaifa@finessedirect.com';
            staffEmail = 'huzaifa@finessedirect.com';
        }
        
        if (staffEmail != null){ //&& managerEmail != null) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // if (managerEmail == staffEmail) {
            //     email.setToAddresses(new String[] {
            //         managerEmail
            //             });
            // } else {
            //     email.setToAddresses(new String[] {
            //         managerEmail, staffEmail
            //             });
            // }
            email.setToAddresses(new String[] {staffEmail});
            email.setCcAddresses(new String[] {'tsd.ak@dnhsecheron.net','tsd.rk@dnhsecheron.net'});
            email.setSubject(emailsub);
            email.setHtmlBody(emailBody);
            
            // Set related record ID for activity tracking
            email.setWhatId(fb.Id);
            email.setSaveAsActivity(true);

            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address = 'info@dnhsecheron.net'];
            if (owea.size() > 0) {
                System.debug('inside');
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }

    }

    // Define a class to map the JSON structure
    public class InvoiceLotData {
        public String LotNo;
        public String BatchQuantity;
        public String MfgDate;
        public String ExpirationDate;
    }
    
}