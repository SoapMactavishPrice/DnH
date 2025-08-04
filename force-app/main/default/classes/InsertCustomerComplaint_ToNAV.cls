public class InsertCustomerComplaint_ToNAV {

    @AuraEnabled
    public static void insertComplaint(String SoId) {

        String s = '';
        API_Log__c api_log = new API_Log__c();

        try {

            HttpUtils.APIparamter apiparam;
            String allfields = HttpUtils.getAllFields('Customer_Complaint__c', SoId);
            Customer_Complaint__c ord_v1 = Database.query(allfields);
            
            apiparam = HttpUtils.getAPIdetails('CreateCustomerComplaintNAV');

            // api_log.Sales_Order__c = ord_v1.Id;
            // ------------------- API LOG to track the request -------------------

            api_log.Log_Name__c = 'Ser19_InsertCustomerComplaint_ToNAV';
            api_log.created_date__c = Datetime.now();

            // Step 1: Create JSON data separately
            String jsonData = createComplaintJsonData(SoId);

            //System.debug('apiparam.Request_body JSON: ' + apiparam.Request_body);
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('actualjson', jsonData);

            System.debug('Generated JSON: ' + jsonData);
            System.debug('apiparam.Request_body JSON: ' + reqBody);
            api_log.Request__c = reqBody;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('SOAPAction', apiparam.SOAPAction);

            req.setBody(reqBody);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                String responseBody = res.getBody();
                api_log.Response__c = res.getBody();
                System.debug('Response: ' + responseBody);
                String resBody = responseBody;
                // Parse the SOAP response and extract salesDocumentNo

                String salesDocumentNo = parseApprovalSoapResponse(responseBody, SoId);
                System.debug('Get Approval Response: ' + salesDocumentNo);
                s = salesDocumentNo;
                
            } else {
                System.debug('Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody());
                s = 'Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody();
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            s = 'Failed with status code: ' + e.getMessage();
        }

        insert api_log;

    }

    public static String createComplaintJsonData(String SoId) {

        String allfields = HttpUtils.getAllFields('Customer_Complaint__c', SoId);
        Customer_Complaint__c ord = Database.query(allfields);

        // Create a map to store the sales order details
        List < Map < String, Object >> mpList = new List < Map < String, Object >> ();
        Map < String, Object > salesOrder = new Map < String, Object > ();

        String str = ord.Document_No__c;
        List<String> parts = str.split('/');
        String sstr = parts[parts.size() - 1];
        salesOrder.put('CompliantNo', ord.Name);
        salesOrder.put('CompliantRegisterDate', Date.today());
        salesOrder.put('EntryType', ord.Entry_Type__c == null ? '0' : ord.Entry_Type__c);
        salesOrder.put('SalesInvNo', ord.Invoice_No__c);
        // salesOrder.put('NameofFieldStaff', ord.FS_Name__c);
        salesOrder.put('NameofFieldStaff', ord.Field_Engineer_Name__r.Code__c); // as per Naresh changes 'Engineer Code'
        // salesOrder.put('BrandName', ord.Brand_Name__c);
        salesOrder.put('BrandName', ord.ItemNo__c); // as per Naresh changes 'Item No'
        salesOrder.put('BatchName', ord.Batch_No__c);
        salesOrder.put('BatchMfgDate', ord.Mfg_Date__c);
        salesOrder.put('TypeofCompliant', '01'); // For Sandbox
        // salesOrder.put('TypeofCompliant', ord.Type_Of_Complaints__c);
        salesOrder.put('TSDRemarks', ord.TSD_Remarks__c);
        salesOrder.put('SalesInvoiceLineNo', ord.Line_No__c);
        salesOrder.put('nAVService19Attachments', null);

        // salesOrder.put('ComplaintQty', ord.Complaint_Quantity__c.stripTrailingZeros().format());
        // salesOrder.put('EndCustomerName', ord.EndCustomerName__c);
        // salesOrder.put('Qty', ord.Batch_Quantity__c.stripTrailingZeros().format());
        // salesOrder.put('TypeOfCompaint', ord.Type_Of_Complaints__c);
        // salesOrder.put('EntryType', ord.Entry_Type__c);
        // salesOrder.put('VerificationEndToCustomer', ord.Verification_End_To_Customer__c);
        // salesOrder.put('Recommendations', ord.Recommendations__c);
        // salesOrder.put('FieldStaffRemarks', ord.Field_Engineer_Remarks__c);
        // salesOrder.put('Status', 'Submitted');
        // DateTime currentDateTime = DateTime.now();
        // String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
        // salesOrder.put('SubmittedDate', formattedDateTime);
        // salesOrder.put('IsSubmitted', '2');
        // salesOrder.put('FieldstaffCode', ord.Field_Engineer_Name__r.Code__c);
        // salesOrder.put('AreaManager', ord.Area_Manager__r.Code__c);
        // salesOrder.put('ZonalHead', ord.Zonal_Head__r.Code__c);
        // salesOrder.put('InsertedBy', ord.Area_Manager__r.Code__c);
        // salesOrder.put('SubmittedBy', ord.Area_Manager__r.Code__c);
        // salesOrder.put('CustomerName', ord.Account__r.Name);

        mpList.add(salesOrder);

        // Convert the map to a JSON string
        String jsonString = JSON.serialize(mpList);
        return jsonString;

    }

    
    // Function to parse the SOAP response and extract salesDocumentNo
    public static String parseApprovalSoapResponse(String responseBody, String SoId) {
        String salesDocumentNo = '';
        try {
            Dom.Document doc = new Dom.Document();
            doc.load(responseBody);

            // Navigate the XML structure and extract salesDocumentNo
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode resultNode = body.getChildElement('InsertServices19New_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            Dom.XMLNode responseLogNode = resultNode.getChildElement('compliantDocNo', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            Dom.XMLNode resultNode2 = resultNode.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            if(resultNode2.getText() == '1'){
                salesDocumentNo = responseLogNode.getText();
                InsertCustomerComplaint_ToTSD.insertComplaint(SoId);
            }else{
                salesDocumentNo = responseLogNode.getText();
            }
            // salesDocumentNo = resultNode2.getText();

        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
        }
        return salesDocumentNo;
    }
    
}