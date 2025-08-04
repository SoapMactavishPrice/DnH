// public class S7_SalesInvoiceLine implements Queueable, Database.AllowsCallouts {
public class S7_SalesInvoiceLine {

    // Map<String,Object> mapdata = new Map<String,Object> ();
    // String sinvoiceJSON = '';

    // public S7_SalesInvoiceLine(String invoiceJSON) {
    //     // this.invLIobj = (Invoice_Line_Item__c) JSON.deserialize(invoiceLineItem, Invoice_Line_Item__c.class);
    //     mapdata = (Map<String,Object>) JSON.deserializeUntyped(invoiceJSON);
    //     sinvoiceJSON = invoiceJSON;
    // }

    // @future(callout=true)
    public static void getInvoiceLineitem(String invoiceJSON){
        System.debug('invoiceJSON'+invoiceJSON);
        Invoice__c invoiceObj = (Invoice__c) JSON.deserialize(invoiceJSON, Invoice__c.class);
        Map<String,Object> mapdata = (Map<String,Object>) JSON.deserializeUntyped(invoiceJSON);
			
        
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'S7_SalesInvoice_Line';
        api_log.created_date__c = Datetime.now();
        String returnResponseLog='';

        try {

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('S7_SalesInvoiceLine');
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
            reqBody = reqBody.replace('actualjson', (String)mapdata.get('Name')); 
            req.setBody(reqBody); 
            api_log.Request__c = reqBody; HttpResponse res = http.send(req);

            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());
        
                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);
                
                Dom.XmlNode response = soapBody.getChildElement('InsertGetSalesInvoiceLineServices7_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog LINE: '+ response);
                Dom.XmlNode responseLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                Dom.XmlNode returnValueLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog LINE :'+ responseLog.getText());
                System.debug('returnValueLog LINE: '+ returnValueLog.getText());
                // Extract the text content of the responseLog element

                if(returnValueLog != null){
                    String returnValueLogContent = returnValueLog.getText();
                    returnResponseLog = returnValueLogContent;

                    // Extract the JSON string
                    String jsonString = returnValueLogContent;
                    System.debug('Extracted JSON: ' + jsonString);

                    // Parse the JSON string into a list of objects
                    List<InvoiceLineData> invoiceList = (List<InvoiceLineData>) JSON.deserialize(jsonString, List<InvoiceLineData>.class);

                    // for (InvoiceLineData invoice : invoiceList) {
                    //     String invJSON = JSON.serialize(invoice);
                    //     System.debug('invJSON LINE :> ' +invJSON);
                    //     // System.enqueueJob(new S7_SalesInvoiceLot(invJSON, sinvoiceJSON));
                    //     S7_SalesInvoiceLot.getInvoiceLot(invJSON, invoiceJSON);
                    // }

                    List<Invoice_Line_Item__c> insertLineItems = new List<Invoice_Line_Item__c>();

                    // Debug the parsed list
                    for (InvoiceLineData invoice : invoiceList) {
                        System.debug('Invoice Line DATA: ' + invoice);
                        Invoice_Line_Item__c inv = new Invoice_Line_Item__c();
                        inv.Invoice__c = invoiceObj.Id;
                        inv.Name = 'INVLI-'+invoice.DocNo;
                        inv.Doc_No__c = invoice.DocNo;
                        inv.Item_No__c = invoice.ItemNo;
                        inv.Line_No__c = invoice.LineNo;
                        inv.Description__c = invoice.Description;
                        inv.Description2__c = invoice.Description2;
                        inv.Sample_Sales_Order_Number__c = invoice.SamplesSalesOrderNo;
                        inv.Quantity__c = invoice.Quantity;
                        inv.Size__c = invoice.SIZE;
                        inv.Item_Brand__c = invoice.ItemBrand;
                        inv.UOM__c = invoice.UOM;
                        insertLineItems.add(inv);
                    }

                    // Insert the list
                    if(insertLineItems.size()>0){
                        insert insertLineItems;
                        // for (Invoice_Line_Item__c v : insertLineItems) {
                        //     String invJSON = JSON.serialize(v);
                        //     // S7_SalesInvoiceLot.getInvoiceLot(invJSON);
                        //     // Trigger the third API call via Queueable
                        //     System.enqueueJob(new S7_SalesInvoiceLot(invJSON));
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
            
            System.debug('Exception Invoice Line: ' + e.getMessage() + ' || ' +e.getLineNumber());
            // return 'Exception: ' + e.getMessage();
            
        }
        insert api_log;
        // return 'OK';
    }

    // Define a class to map the JSON structure
    public class InvoiceLineData {
        public String DocNo;
        public String ItemNo;
        public String LineNo;
        public String Description;
        public String Description2;
        public String SamplesSalesOrderNo;
        public String Quantity;
        public String SIZE;
        public String ItemBrand;
        public String UOM;
    }
    
}