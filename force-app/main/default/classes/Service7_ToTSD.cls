public class Service7_ToTSD {
    
    @AuraEnabled
    public static String createService7ToTSD(String SoId) {

        String s = '';
        API_Log__c api_log = new API_Log__c();

        try {

            HttpUtils.APIparamter apiparam;
            String allfields = HttpUtils.getAllFields('Service_7_Sample_Feedbacks__c', SoId);
            Service_7_Sample_Feedbacks__c ord_v1 = Database.query(allfields);
            apiparam = HttpUtils.getAPIdetails('Service7ToTSD');

            // ------------------- API LOG to track the request -------------------
            api_log.created_date__c = Datetime.now();
            // Step 1: Create JSON data separately
            String jsonData = createSalesOrderJsonData(SoId);

            //System.debug('apiparam.Request_body JSON: ' + apiparam.Request_body);
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('actualJSON', jsonData);
            if (reqBody.contains('&')) {
                reqBody = reqBody.replace('&', '&amp;');
            }

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
            
            api_log.Response__c = res.getBody();
            if (res.getStatusCode() == 200) {
                String responseBody = res.getBody();
                System.debug('Response: ' + responseBody);
                String resBody = responseBody;

                String responseAfterParsed = parseTSDSoapResponse(responseBody);
                if (responseAfterParsed == 'Service 7 Successfully sent to TSD Portal') {
                    Service_7_Sample_Feedbacks__c sf = [
                        SELECT Id, Name, IsCreatedToTSD__c
                        FROM Service_7_Sample_Feedbacks__c
                        WHERE Id =: SoId
                    ];
                    sf.IsCreatedToTSD__c = true;
                    update sf;
                }
                s = responseAfterParsed;

                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
            } else {
                api_log.Log_Status__c = 'Failure';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                System.debug('Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody());
                s = 'Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody();
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            s = 'Failed with status code: ' + e.getMessage();
        }

        insert api_log;
        return s;
    }

    // Step 1: Function to create JSON data separately
    public static String createSalesOrderJsonData(String SoId) {
        String allfields = HttpUtils.getAllFields('Service_7_Sample_Feedbacks__c', SoId);
        Service_7_Sample_Feedbacks__c ord = Database.query(allfields);

        // Create a map to store the sales order details
        List < Map < String, Object >> mpList = new List < Map < String, Object >> ();
        Map < String, Object > recordMap = new Map < String, Object > ();

        recordMap.put('DocumentNo', ord.Name);
        recordMap.put('DocketDate', ord.Docket_Date__c);
        recordMap.put('FieldStaffName', ord.Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Name);
        recordMap.put('FieldStaffEmail', ord.Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Email);
        recordMap.put('DocketNo', ord.Docket_No__c);
        recordMap.put('InvoiceDate', ord.Date__c);
        recordMap.put('Item_No', ord.ItemNo__c);
        recordMap.put('BrandName', ord.BrandName__c);
        recordMap.put('Size', ord.Sizemm__c);
        recordMap.put('BatchNo', ord.Batch_No__c);
        recordMap.put('Quantity', ord.Qty_Pcs_Kgs__c);
        recordMap.put('PreviouslyUsed_Consumables', ord.Previously_Used_Consumables__c);
        recordMap.put('TestResult', ord.Test_Result_of_the_Samples__c);
        recordMap.put('StatusofOrder', ord.StatusOfOrder__c);
        recordMap.put('TestingDate', ord.Date__c);
        recordMap.put('Remarks', ord.Remark__c);
        recordMap.put('CustomerName', ord.CustomerName__c);
        recordMap.put('ContactPersonName', ord.ContactPersonName__c);
        recordMap.put('ContactPersonDesignation', ord.Contact_Person_Designation__c);
        recordMap.put('ContactPersonAddress', ord.Contact_Person_Address__c);
        recordMap.put('EmailId', '');
        recordMap.put('ContactNo', '');
        recordMap.put('InsertedOn', ord.Date__c);
        recordMap.put('UpdatedOn', ord.Date__c);
        recordMap.put('UpdatedBy', ord.Sample_Request_Product__r.Sample_Request__r.Submitted_By__r.Code__c);
        recordMap.put('Deactive', 'false');
        recordMap.put('IsSubmitted', '2');
        recordMap.put('SubmittedDate', ord.Date__c);
        recordMap.put('SubmittedBy', ord.Sample_Request_Product__r.Sample_Request__r.Submitted_By__r.Code__c);
        recordMap.put('SaleInvoiceNo', ord.InvoiceNo__c);
        recordMap.put('CustomerNo', ''); // Need to confirm
        recordMap.put('Status', 'Submitted by Field Engineer'); // Need to confirm
        recordMap.put('DocumentDate', ord.Date__c);
        recordMap.put('UOM', ord.U_O_M__c);
        recordMap.put('AreaManager', ord.Sample_Request_Product__r.Sample_Request__r.Area_Manager__r.Code__c);
        recordMap.put('ZonalManager', ord.Sample_Request_Product__r.Sample_Request__r.Zonal_Head__r.Code__c);
        recordMap.put('FieldEngineer', ord.Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Code__c);
        recordMap.put('ItemDescription1', ord.Sample_Request_Product__r.Description__c);
        recordMap.put('ItemDescription2', ord.Sample_Request_Product__r.Description__c);
        recordMap.put('SampleSalesOrderNo', ord.Sample_Request_Product__r.Sample_Order_Number__c);

        List < ContentDocumentLink > contDocLinkHeader = new List < ContentDocumentLink > ();
        Set < String > cdlSet = new Set < String > ();
        contDocLinkHeader = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: SoId];
        for (ContentDocumentLink cdl: contDocLinkHeader) {
            System.debug('ContentDocumentId: ' + cdl.ContentDocumentId);
            cdlSet.add(cdl.ContentDocumentId);
        }
        List < ContentDistribution > cdsHeader = new List < ContentDistribution > ();
        cdsHeader = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId IN: cdlSet];
        if (cdsHeader.size() > 0) {
            List < Map < String, String >> attachments = new List < Map < String, String >> ();
            for (ContentDistribution cdobj: cdsHeader) {
                Map < String, String > att = new Map < String, String > ();
                att.put('DocumentNo', ord.Name);
                att.put('FileAddress', cdobj.DistributionPublicUrl);
                att.put('AttachmentName', cdobj.Name.replace('- public file',''));
                attachments.add(att);
            }
            recordMap.put('navAttachmentMsts', attachments);
        } else {
            List < Map < String, String >> attachments = new List < Map < String, String >> ();
            recordMap.put('navAttachmentMsts', attachments);
        }

        mpList.add(recordMap);

        // Convert the map to a JSON string
        String jsonString = JSON.serialize(mpList);

        // API_Log__c aaa = new API_Log__c();
        // aaa.Request__c = jsonString;
        // insert aaa;

        return jsonString;

    }

    public static String parseTSDSoapResponse(String responseBody) {
        String parsedResponse = '';
        try {
            Dom.Document doc = new Dom.Document();
            doc.load(responseBody);

            // Navigate the XML structure and extract parsedResponse
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode bodyChild = body.getChildElement('GetFeedBackByEngineerResponse', 'http://tempuri.org/');
            Dom.XMLNode resultNode = bodyChild.getChildElement('GetFeedBackByEngineerResult', 'http://tempuri.org/');
            Dom.XMLNode responseLogNode = bodyChild.getChildElement('responseLog', 'http://tempuri.org/');
            if(resultNode.getText() == '1'){
                parsedResponse = 'Service 7 Successfully sent to TSD Portal';
            }else if(resultNode.getText() == '0') {
                parsedResponse = responseLogNode.getText();
            }
            

        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
        }
        return parsedResponse;
    }
    
}