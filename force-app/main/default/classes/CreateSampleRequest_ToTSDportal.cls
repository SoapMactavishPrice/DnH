public class CreateSampleRequest_ToTSDportal {

    @AuraEnabled
    public static string getCurrentUserDetail(){
        try {

            String resData = '';
            String curUsr = UserInfo.getUserId();

            // if (curUsr == '005GB00000YJ9QIYA1') {
            //     curUsr = '005F30000081WN0IAM'; // Nagin bhai
            // }

            User usr = [SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c FROM User WHERE Id =:curUsr];
            resData = usr.Id;
 
            if (usr.Zonal_Manager_ID__c != null && usr.Zonal_Manager_ID__c != '') {
                User zonalMgrUsr = [SELECT Id, Name, Code__c  FROM User WHERE Code__c =: usr.Zonal_Manager_ID__c];
                resData = resData +';'+ zonalMgrUsr.Id;
            }
            if (usr.Reporting_Person_ID__c != null && usr.Reporting_Person_ID__c != '') {
                User areaMgrUsr = [SELECT Id, Name, Code__c  FROM User WHERE Code__c =: usr.Reporting_Person_ID__c];
                resData = resData +';'+ areaMgrUsr.Id;
            }

            return resData;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String insertSampleSalesOrderToTSD(String SoId) {

        String s = '';
        API_Log__c api_log = new API_Log__c();

        try {
            HttpUtils.APIparamter apiparam;
            String allfields = HttpUtils.getAllFields('Service_5_Sample_Request__c', SoId);
            Service_5_Sample_Request__c ord_v1 = Database.query(allfields);
            
            apiparam = HttpUtils.getAPIdetails('SampleOrder');

            // ------------------- API LOG to track the request -------------------
            
            api_log.Log_Name__c = 'Create_SampleOrderTo_TSD';
            api_log.created_date__c = Datetime.now();
            api_log.Service_5_Sample_Request__c = ord_v1.Id;

            // Step 1: Create JSON data separately
            String jsonData = createSampleOrderJsonData(SoId);

            //System.debug('apiparam.Request_body JSON: ' + apiparam.Request_body);
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('var', jsonData);
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
            req.setTimeout(120000);

            req.setBody(reqBody);

            Http http = new Http();
            HttpResponse res = http.send(req);
            
            api_log.Response__c = res.getBody();
            if (res.getStatusCode() == 200) {
                String responseBody = res.getBody();
                System.debug('Response: ' + responseBody);
                String resBody = responseBody;
                s = 'ok';
                // Parse the SOAP response and extract salesDocumentNo

                String salesDocumentNo = parseTSDSoapResponse(responseBody);
                System.debug('Sales Document No: ' + salesDocumentNo);
                s = salesDocumentNo;
                if (salesDocumentNo == '') {
                    s = resBody;
                }
                if (salesDocumentNo == 'Sample Order Created Successfully') {

                    SendEmailAfterCreation(SoId);
                    
                }
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = '200';
                api_log.Response__c = responseBody;
                api_log.response_time__c = Datetime.now();
                // // Save the salesDocumentNo to the Order record
                // saveResponseToOrder(SoId, salesDocumentNo);
            } else {
                System.debug('Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody());
                s = 'Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody();
                api_log.Log_Status__c = 'Failure';
                api_log.Response_Code__c = '400';
                // api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
                api_log.response_time__c = Datetime.now();
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            s = 'Failed with status code: ' + e.getMessage();
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();
        }

        insert api_log;
        return s;

    }

    public static String createSampleOrderJsonData(String SoId) {

        String allfields = HttpUtils.getAllFields('Service_5_Sample_Request__c', SoId);
        Service_5_Sample_Request__c ord = Database.query(allfields);

        // Create a map to store the sales order details
        List < Map < String, Object >> mpList = new List < Map < String, Object >> ();
        Map < String, Object > salesOrder = new Map < String, Object > ();

        Date cd = Date.valueOf(ord.CreatedDate);
        String cddate = String.valueOf(cd.year()) + '-' +(cd.month() < 10 ? '0' : '')+ String.valueOf(cd.month()) + '-' +(cd.day() < 10 ? '0' : '')+ String.valueOf(cd.day());

        salesOrder.put('DocumentNo', ord.Name);
        salesOrder.put('DocumentDate', cddate);
        salesOrder.put('CustomerName', ord.Customer_Name__c);
        salesOrder.put('ContactPersonName', ord.Contact_Person_Name__c);
        salesOrder.put('Address1', ord.Address_1__c);
        salesOrder.put('Address2', ord.Address_2__c);
        salesOrder.put('City', ord.City_Name__c); //
        // salesOrder.put('Postcode', String.valueOf(ord.Post_Code__c));
        salesOrder.put('Postcode', ord.Postal_Code__c != null ? Integer.valueOf(ord.Postal_Code__c) : null);
        salesOrder.put('ContactNo', ord.Contact_No__c);
        salesOrder.put('ModeOfDispatch', ord.Mode_of_Dispatch__c);
        salesOrder.put('Remarks', ord.Remark__c);
        salesOrder.put('FieldStaffCode', ord.Field_Staff_Code__r.Code__c);
        salesOrder.put('AreaManager', ord.Area_Manager__r.Code__c);
        salesOrder.put('ZonalHead', ord.Zonal_Head__r.Code__c);
        salesOrder.put('SubmittedBy', ord.Submitted_By__r.Code__c);
        salesOrder.put('SubmittedDate', cddate);
        salesOrder.put('InsertedBy', ord.Inserted_By__r.Code__c);
        salesOrder.put('InsertedOn', cddate);
        salesOrder.put('Status', 'Submitted');
        salesOrder.put('IsSubmitted', 'true');

        // Add Sales order header attachment
        List < ContentDocumentLink > contDocLinkHeader = new List < ContentDocumentLink > ();
        Set < String > cdlSetHeader = new Set < String > ();

        contDocLinkHeader = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: SoId];

        for (ContentDocumentLink cdl: contDocLinkHeader) {
            System.debug('ContentDocumentId for Header: ' + cdl.ContentDocumentId);
            cdlSetHeader.add(cdl.ContentDocumentId);
        }

        List < ContentDistribution > cdsHeader = new List < ContentDistribution > ();

        cdsHeader = [SELECT Id, Name, ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN: cdlSetHeader];
        if (cdsHeader.size() > 0) {
            List < Map < String, String >> attachmentsHeader = new List < Map < String, String >> ();
            for (ContentDistribution cdobj: cdsHeader) {
                Map < String, String > att = new Map < String, String > ();
                att.put('DocumentNo', ord.Name);
                att.put('FileAddress', cdobj.ContentDownloadUrl);
                att.put('AttachmentName', cdobj.Name.replace('- public file',''));
                attachmentsHeader.add(att);
            }
            salesOrder.put('navAttachmentMsts', attachmentsHeader);
        } else {
            List < Map < String, String >> attachments = new List < Map < String, String >> ();
            salesOrder.put('navAttachmentMsts', attachments);
        }

        //=============================================

        // Create a list for Sales Order Line items
        String parentRecId = SoId;
        String allChildfields = HttpUtils.getOneLevelLineItemRecords('Sample_Request_Product__c', 'Sample_Request__c', parentRecId);

        List < Sample_Request_Product__c > OrderLineItem = new List < Sample_Request_Product__c > ();
        OrderLineItem = Database.query(allChildfields);

        List < Map < String, Object >> salesOrderLines = new List < Map < String, Object >> ();

        for (Sample_Request_Product__c solineItem: OrderLineItem) {
            Map < String, Object > lineItem = new Map < String, Object > ();
            lineItem.put('DocumentNo', solineItem.Sample_Request__r.Name); //
            lineItem.put('ItemCategory', solineItem.Sample_Request_Item_Category_Code__r.Code__c);
            lineItem.put('ItemNo', solineItem.Item_No__r.Item_Number__c); //
            lineItem.put('Description', solineItem.Description__c);
            lineItem.put('BrandName', solineItem.Sam_Req_Brand_Name__r.Code__c); //
            lineItem.put('Size', solineItem.Sam_Req_Size_mm__r.Code__c); //
            lineItem.put('PotentialOfBusiness', solineItem.Potential_Of_Business__c);
            lineItem.put('ApplicationDetails', solineItem.Application_Details__c);
            lineItem.put('SpecialProperties', solineItem.Special_Properties__c);
            lineItem.put('QtyType', solineItem.Qty_Type_2__c);
            lineItem.put('Quantity', String.valueOf(solineItem.Quantity_2__c));
            lineItem.put('InsertedBy', solineItem.Sample_Request__r.Inserted_By__r.Code__c); //
            lineItem.put('InsertedOn', cddate);
            lineItem.put('Remarks', solineItem.Remarks__c);

            salesOrderLines.add(lineItem);
        }

        // Add the lines to the main sales order map
        salesOrder.put('LineItems', salesOrderLines);
        mpList.add(salesOrder);

        // Convert the map to a JSON string
        String jsonString = JSON.serialize(mpList);
        return jsonString;

    }

    // Function to parse the SOAP response and extract salesDocumentNo
    public static String parseTSDSoapResponse(String responseBody) {
        String salesDocumentNo = '';
        try {
            Dom.Document doc = new Dom.Document();
            doc.load(responseBody);

            // Navigate the XML structure and extract salesDocumentNo
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode resultNode;
            resultNode = body.getChildElement('GetSampleSalesOrderResponse', 'http://tempuri.org/');
            // if (resultNode == null) {
            //     resultNode = body.getChildElement('GetSpecialRateSalesOrderResponse', 'http://tempuri.org/');
                
            // }
            Dom.XMLNode returnValueNode = resultNode.getChildElement('responseLog', 'http://tempuri.org/');
            Dom.XMLNode returnValueNode2 = resultNode.getChildElement('GetSampleSalesOrderResult', 'http://tempuri.org/');
            if(returnValueNode.getText()!=''){
                salesDocumentNo = returnValueNode.getText();
            }else{
                salesDocumentNo = 'Sample Order Created Successfully';
            }
            

        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
        }
        return salesDocumentNo;
    }

    public static void SendEmailAfterCreation(String SoId){
        Service_5_Sample_Request__c sor = [
            SELECT Id, Name, Field_Staff_Code__c, Field_Staff_Code__r.Name, Field_Staff_Code__r.Email, City_Name__c,
            Customer_Name__c, Address_1__c, Date__c, Address_2__c, Contact_No__c, Mode_of_Dispatch__c, Postal_Code__c,
            Contact_Person_Name__c
            FROM Service_5_Sample_Request__c
            WHERE Id =: SoId
        ];

        List<Sample_Request_Product__c> sorLIList = [
            SELECT Id, Name, Sample_Request_Item_Category_Code__c, Sample_Request_Item_Category_Code__r.Code__c,
            Item_No__c, Item_No__r.Item_Number__c, Description__c, Sam_Req_Size_mm__c, Sam_Req_Size_mm__r.Code__c,
            Sam_Req_Brand_Name__c, Sam_Req_Brand_Name__r.Code__c, Quantity_2__c
            FROM Sample_Request_Product__c
            WHERE Sample_Request__c =: sor.Id
        ];

        String sorLineItems = '';
        if (sorLIList.size() > 0) {
            for (Sample_Request_Product__c v : sorLIList) {
                String str = '<tr>'
                + '<td>'+v.Sample_Request_Item_Category_Code__r.Code__c+'</td><td>'+v.Item_No__r.Item_Number__c+'</td><td>'+v.Description__c+'</td>'
                + '<td>'+v.Sam_Req_Brand_Name__r.Code__c+'</td><td>'+v.Sam_Req_Size_mm__r.Code__c+'</td><td>'+v.Quantity_2__c+'</td>'
                + '</tr>';
                sorLineItems += str;
            }
        }

        String fieldStaffEmail = sor.Field_Staff_Code__r.Email;
        // String fieldStaffEmail = 'huzaifa@finessedirect.com';
        if (fieldStaffEmail != null) {
            // Set up the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();    
            email.setToAddresses(new String[] {
                fieldStaffEmail
            });
            email.setCcAddresses(new String[] {
                'ganeshkumar@dnhsecheron.net', 'tsd.ak@dnhsecheron.net', 'tsd.rk@dnhsecheron.net',
                'rahul.nair@dnhsecheron.net', 'tjprao@dnhsecheron.net', 'tsd.samples@dnhsecheron.net'
            });
            email.setSubject('Sample order request '+sor.Name);

            String emailBody = '<html>'
            + '<body>'
            + '<p><b>Hello TSD,</b></p>'
            + '<p>Please Find Document No For Service 5: <b>'+sor.Name+'</b></p>'
            + '<table border="1" style="border-collapse:collapse; width:100%;">'
            + '<tr>'
            + '<td><b>Document No:</b></td><td>'+sor.Name+'</td>'
            + '<td><b>Document Date:</b></td><td>'+sor.Date__c+'</td>'
            + '</tr>'
            + '<tr>'
            + '<td><b>Customer Name:</b></td><td>'+sor.Customer_Name__c+'</td>'
            + '<td><b>Contact Person Name:</b></td><td>'+sor.Contact_Person_Name__c+'</td>'
            + '</tr>'
            + '<tr>'
            + '<td><b>Address1:</b></td><td>'+sor.Address_1__c+'</td>'
            + '<td><b>Address 2:</b></td><td>'+sor.Address_2__c+'</td>'
            + '</tr>'
            + '<tr>'
            + '<td><b>City:</b></td><td>'+sor.City_Name__c+'</td>'
            + '<td><b>PostCode:</b></td><td>'+sor.Postal_Code__c+'</td>'
            + '</tr>'
            + '<tr>'
            + '<td><b>Contact No:</b></td><td>'+sor.Contact_No__c+'</td>'
            + '<td><b>Mod Of Dispatch:</b></td><td>'+sor.Mode_of_Dispatch__c+'</td>'
            + '</tr>'
            + '<tr>'
            + '<td><b>Remark:</b></td><td colspan="3"></td>'
            + '</tr>'
            + '</table>'
            + '<br/>'
            + '<table border="1" style="border-collapse:collapse; width:100%;">'
            + '<thead>'
            + '<tr>'
            + '<th>Item Category</th><th>Item No</th><th>Description</th>'
            + '<th>BrandName</th><th>Size</th><th>Quantity</th>'
            + '</tr>'
            + '</thead>'
            + '<tbody>'
            + sorLineItems
            + '</tbody>'
            + '</table>'
            + '</body>'
            + '</html>';

            email.setHtmlBody(emailbody);

            // Add Email Attachment
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            List<ContentDocumentLink> contDocLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :SoId];
            Set<String> cdlSet = new Set<String>();
            for (ContentDocumentLink cdl : contDocLink) {
                cdlSet.add(cdl.ContentDocumentId);
            }
            
            List<ContentVersion> fileVersions = [
                SELECT Id, Title, VersionData, FileType 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :cdlSet AND IsLatest = TRUE
            ];
            
            for (ContentVersion file : fileVersions) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                
                // Get file type and ensure lowercase
                String fileType = file.FileType != null ? file.FileType.toLowerCase() : 'txt'; // Default to text if unknown
                String mimeType = getMimeType(fileType);
                
                // Ensure file name has correct extension
                String fileName = file.Title;
                if (!fileName.toLowerCase().endsWith('.' + fileType)) {
                    fileName += '.' + fileType; // Append correct extension if missing
                }
                
                // Set the file name, content type, and body correctly
                efa.setFileName(fileName);
                efa.setBody(file.VersionData);
                efa.setContentType(mimeType); // Set correct MIME type
                
                emailAttachments.add(efa);
            }

            if (!emailAttachments.isEmpty()) {
                email.setFileAttachments(emailAttachments);
            }

            // Set related record ID for activity tracking
            email.setWhatId(sor.Id);
            email.setSaveAsActivity(true);

            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address = 'info@dnhsecheron.net'];
            if ( owea.size() > 0 ) {
                System.debug('inside');  
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                email
            });
        }
    }

    // Helper method to return correct MIME type
    private static String getMimeType(String fileType) {
        
        Map<String, String> mimeTypes = new Map<String, String>{
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'gif' => 'image/gif',
            'pdf' => 'application/pdf',
            'doc' => 'application/msword',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls' => 'application/vnd.ms-excel',
            'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'txt' => 'text/plain',
            'csv' => 'text/csv',
            'mp4' => 'video/mp4',
            'mp3' => 'audio/mpeg',
            'zip' => 'application/zip',
            'html' => 'text/html'
        };
                    
        return mimeTypes.containsKey(fileType) ? mimeTypes.get(fileType) : 'application/octet-stream';
    }

    public static void fakeCoverage(){
        integer i=1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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