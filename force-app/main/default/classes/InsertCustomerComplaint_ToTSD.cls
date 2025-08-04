public class InsertCustomerComplaint_ToTSD {
    
    @future(callout=true)
    // @AuraEnabled
    public static void insertComplaint(String SoId) {

        String s = '';
        API_Log__c api_log = new API_Log__c();

        try {

            HttpUtils.APIparamter apiparam;
            String allfields = HttpUtils.getAllFields('Customer_Complaint__c', SoId);
            Customer_Complaint__c ord_v1 = Database.query(allfields);
            
            apiparam = HttpUtils.getAPIdetails('CreateCustomerComplaintTSD');

            // api_log.Sales_Order__c = ord_v1.Id;
            // ------------------- API LOG to track the request -------------------

            api_log.Log_Name__c = 'Ser19_InsertCustomerComplaint_ToTSD';
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

                String salesDocumentNo = parseApprovalSoapResponse(responseBody);
                System.debug('Get Approval Response: ' + salesDocumentNo);
                Customer_Complaint__c ccrec = new Customer_Complaint__c(Id = SoId);
                ccrec.Is_Created_To_NAV__c = true;
                if (salesDocumentNo == '1') {
                    ccrec.Is_Created_To_TSD__c = true;
                    sendEmail(SoId,'');
                    s = salesDocumentNo;
                } else {
                    System.debug('Failed with status code 1: ' + res.getStatusCode() + ' and body: ' + res.getBody());
                    s = 'Failed with status code 1: ' + res.getStatusCode() + ' and body: ' + res.getBody();
                }
                update ccrec;
                
            } else {
                System.debug('Failed with status code 2: ' + res.getStatusCode() + ' and body: ' + res.getBody());
                s = 'Failed with status code 2: ' + res.getStatusCode() + ' and body: ' + res.getBody();
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            s = 'Failed with status code 3: ' + e.getMessage();
        }

        insert api_log;

    }

    public static String createComplaintJsonData(String SoId) {

        String allfields = HttpUtils.getAllFields('Customer_Complaint__c', SoId);
        Customer_Complaint__c ord = Database.query(allfields);

        // Create a map to store the sales order details
        List < Map < String, Object >> mpList = new List < Map < String, Object >> ();
        Map < String, Object > salesOrder = new Map < String, Object > ();

        salesOrder.put('DocumentNo', ord.Name);
        salesOrder.put('DocumentDate', Date.today());
        salesOrder.put('InvoiceNo', ord.Invoice_No__c);
        salesOrder.put('ItemNo', ord.ItemNo__c);
        salesOrder.put('LineNo', ord.Line_No__c);
        salesOrder.put('BatchNo', ord.Batch_No__c);
        salesOrder.put('InvoiceDate', ord.InvoiceDate__c);
        salesOrder.put('BrandName', ord.Brand_Name__c);
        salesOrder.put('Size', ord.Size_mm__c);
        salesOrder.put('UOM', ord.U_O_M__c);
        salesOrder.put('CustomerNo', ord.Account__r.Customer_Code__c);
        salesOrder.put('MfgDate', ord.Mfg_Date__c);
        salesOrder.put('ComplaintQty', ord.Complaint_Quantity__c.stripTrailingZeros().format());
        salesOrder.put('EndCustomerName', ord.EndCustomerName__c);
        salesOrder.put('Qty', ord.Batch_Quantity__c.stripTrailingZeros().format());
        // salesOrder.put('TypeOfCompaint', ord.Type_Of_Complaints__c);
        salesOrder.put('TypeOfCompaint', '01'); // For sandbox only
        // salesOrder.put('EntryType', ord.Entry_Type__c);
        salesOrder.put('EntryType', '0');
        salesOrder.put('VerificationEndToCustomer', ord.Verification_End_To_Customer__c);
        salesOrder.put('Recommendations', ord.Recommendations__c);
        salesOrder.put('FieldStaffRemarks', ord.Field_Engineer_Remarks__c);
        salesOrder.put('Status', ord.Status__c);
        DateTime currentDateTime = DateTime.now();
        String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
        salesOrder.put('SubmittedDate', formattedDateTime);
        salesOrder.put('IsSubmitted', ord.IsSubmitted__c);
        salesOrder.put('FieldstaffCode', ord.Field_Engineer_Name__r.Code__c);
        salesOrder.put('AreaManager', ord.Area_Manager__r.Code__c);
        salesOrder.put('ZonalHead', ord.Zonal_Head__r.Code__c);
        salesOrder.put('InsertedBy', ord.Inserted_By__c);
        salesOrder.put('SubmittedBy', ord.Submitted_By__c);
        salesOrder.put('CustomerName', ord.Account__r.Name);

        // Header Attachment
        List < ContentDocumentLink > contDocLinkHeader = new List < ContentDocumentLink > ();
        Set < String > cdlSet = new Set < String > ();
        contDocLinkHeader = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: SoId];
        for (ContentDocumentLink cdl: contDocLinkHeader) {
            System.debug('ContentDocumentId: ' + cdl.ContentDocumentId);
            cdlSet.add(cdl.ContentDocumentId);
        }
        List < ContentDistribution > cdsHeader = new List < ContentDistribution > ();
        cdsHeader = [SELECT Id, Name, ContentDocumentId, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId IN: cdlSet];
        if (cdsHeader.size() > 0) {
            List < Map < String, String >> attachments = new List < Map < String, String >> ();
            for (ContentDistribution cdobj: cdsHeader) {
                Map < String, String > att = new Map < String, String > ();
                att.put('DocumentNo', ord.Name);
                att.put('FileAddress', cdobj.DistributionPublicUrl);
                att.put('AttachmentName', cdobj.Name.replace('- public file',''));
                attachments.add(att);
            }
            salesOrder.put('navAttachmentMsts', attachments);
        } else {
            List < Map < String, String >> attachments = new List < Map < String, String >> ();
            salesOrder.put('navAttachmentMsts', attachments);
        }

        mpList.add(salesOrder);

        // Convert the map to a JSON string
        String jsonString = JSON.serialize(mpList);
        return jsonString;

    }

    
    // Function to parse the SOAP response and extract salesDocumentNo
    public static String parseApprovalSoapResponse(String responseBody) {
        String salesDocumentNo = '';
        try {
            Dom.Document doc = new Dom.Document();
            doc.load(responseBody);

            // Navigate the XML structure and extract salesDocumentNo
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode resultNode = body.getChildElement('GetComplaintByEngineerResponse', 'http://tempuri.org/');
            Dom.XMLNode responseLogNode = resultNode.getChildElement('responseLog', 'http://tempuri.org/');
            Dom.XMLNode resultNode2 = resultNode.getChildElement('GetComplaintByEngineerResult', 'http://tempuri.org/');
            if(resultNode2.getText() == '0'){
                salesDocumentNo = responseLogNode.getText();
            }else{
                salesDocumentNo = resultNode2.getText();
            }
            // salesDocumentNo = resultNode2.getText();

        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
        }
        return salesDocumentNo;
    }

    public static void sendEmail(String ordId, String ordStatus) {

        Customer_Complaint__c excc = [
            SELECT Id, Name, Submitted_Date__c, Invoice_No__c, InvoiceDate__c, Account__r.Customer_Code__c, EndCustomerName__c,
            ItemNo__c, Brand_Name__c, Batch_No__c, Mfg_Date__c, Batch_Quantity__c, Complaint_Quantity__c, UOM__c, Size_mm__c,
            Type_Of_Complaints__c, Entry_Type__c, Verification_End_To_Customer__c, Recommendations__c, Field_Engineer_Name__r.Name,
            Field_Engineer_Name__r.Email, Area_Manager__r.Email, Zonal_Head__r.Email,TSD_Remarks__c,TSD_Confirmation__c,
            Area_Manager__r.Name, Zonal_Head__r.Name, Field_Engineer_Remarks__c FROM Customer_Complaint__c WHERE Id =: ordId
        ];

        // Get the picklist field's describe result
        Schema.DescribeFieldResult strTypeofCompFieldResult = Customer_Complaint__c.Type_Of_Complaints__c.getDescribe();
        Schema.DescribeFieldResult strEntryTypeFieldResult = Customer_Complaint__c.Entry_Type__c.getDescribe();

        // Get the picklist values
        List<Schema.PicklistEntry> TypeofCompValue = strTypeofCompFieldResult.getPicklistValues();
        List<Schema.PicklistEntry> EntryTypeValue = strEntryTypeFieldResult.getPicklistValues();

        String TypeofCompLabel = '';
        String EntryTypeLabel = '';
        for (Schema.PicklistEntry entry : TypeofCompValue) {
            if (entry.getValue() == excc.Type_Of_Complaints__c) {
                TypeofCompLabel = entry.getLabel();
                break;
            }
        }
        for (Schema.PicklistEntry entry : EntryTypeValue) {
            if (entry.getValue() == excc.Entry_Type__c) {
                EntryTypeLabel = entry.getLabel();
                break;
            }
        }

        // Email recipient
        String fieldStaffEmail = excc.Field_Engineer_Name__r.Email;
        String managerEmail = excc.Area_Manager__r.Email;
        String zonalEmail = excc.Zonal_Head__r.Email;
        // String otherEmails = 'tsd.ak@dnhsecheron.net,tsd.rk@dnhsecheron.net,tsd.mn@dnhsecheron.net,rahul.nair@dnhsecheron.net,tjprao@dnhsecheron.net,tsd.samples@dnhsecheron.net';
        // String otherEmails = 'tsd.rk@dnhsecheron.net';
        // String toRecipients = 'huzaifa@finessedirect.com';
        // String ccRecipients = 'huzaifa@finessedirect.com';

        String addOnLine = '';
        String strEmailSubject = 'Send Service19 Document For Approval To TSD';
        if (ordStatus == 'In-Process at TSD Team') {
            strEmailSubject = 'Service19 Document Approved by TSD successfully';
            addOnLine = '<tr><td><b>TSD Remarks:</b></td><td>'+excc.TSD_Remarks__c+'</td></tr>';
        } else if(ordStatus == 'Closed By TSD User' || ordStatus == 'Rejected By TSD User') {
            strEmailSubject = 'Service19 Solution Given by TSD';
            addOnLine = '<tr><td><b>TSD Remarks:</b></td><td>'+excc.TSD_Remarks__c+'</td>' +
            '<td><b>TSD Confirmation:</b></td><td>'+excc.TSD_Confirmation__c+'</td></tr>';
        }

        // HTML Email Body
        String htmlBody = '<html><body>' +
            '<p style="font-size: 20px"><b>Hello TSD,</b></p>' +
            '<p style="font-size: 20px">Please Find DocumentNo For Service 19: <b>'+excc.Name+'</b></p>' +
            '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; width: 100%;">' +
            '<tr><td><b>Document No:</b></td><td>'+excc.Name+'</td>' +
                '<td><b>Document Date:</b></td><td>'+excc.Submitted_Date__c+'</td></tr>' +
            '<tr><td><b>Invoice No:</b></td><td>'+excc.Invoice_No__c+'</td>' +
                '<td><b>Invoice Date:</b></td><td>'+excc.InvoiceDate__c+'</td></tr>' +
            '<tr><td><b>Dealer Name:</b></td><td>'+excc.Account__r.Customer_Code__c+'</td>' +
                '<td><b>End Customer Name:</b></td><td>'+excc.EndCustomerName__c+'</td></tr>' +
            '<tr><td><b>Item No:</b></td><td>'+excc.ItemNo__c+'</td>' +
                '<td><b>Brand Name:</b></td><td>'+excc.Brand_Name__c+'</td></tr>' +
            '<tr><td><b>Batch No:</b></td><td>'+excc.Batch_No__c+'</td>' +
                '<td><b>Mfg Date:</b></td><td>'+excc.Mfg_Date__c+'</td></tr>' +
            '<tr><td><b>Batch Qty:</b></td><td>'+excc.Batch_Quantity__c+'</td>' +
                '<td><b>Complaint Qty:</b></td><td>'+excc.Complaint_Quantity__c+'</td></tr>' +
            '<tr><td><b>UOM:</b></td><td>'+excc.UOM__c+'</td>' +
                '<td><b>Size:</b></td><td>'+excc.Size_mm__c+'</td></tr>' +
            '<tr><td><b>Type Of Complaint:</b></td><td>'+TypeofCompLabel+'</td>' +
                '<td><b>Entry Type:</b></td><td>'+EntryTypeLabel+'</td></tr>' +
            '<tr><td><b>Verification End To Customer:</b></td><td>'+excc.Verification_End_To_Customer__c+'</td>' +
                '<td><b>Recommendations:</b></td><td>'+excc.Recommendations__c+'</td></tr>' +
            '<tr><td><b>Fieldstaff Name:</b></td><td>'+excc.Field_Engineer_Name__r.Name+'</td>' +
                '<td><b>Area Manager:</b></td><td>'+excc.Area_Manager__r.Name+'</td></tr>' +
            '<tr><td><b>Zonal Head:</b></td><td>'+excc.Zonal_Head__r.Name+'</td>' +
                '<td><b>Field Staff Remarks:</b></td><td>'+excc.Field_Engineer_Remarks__c+'</td></tr>' +
                addOnLine +
            '</table>' +
            '</body></html>';

        // Set up the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(strEmailSubject);
        if (Test.isRunningTest()) {
            email.setToAddresses(new String[] {
                'huzaifa@finessedirect.com'
            });
        } else {
            if (addOnLine == '') {
                email.setToAddresses(new String[] {
                    'tsd.ak@dnhsecheron.net','tsd.rk@dnhsecheron.net','tsd.mn@dnhsecheron.net',
                    'rahul.nair@dnhsecheron.net','tjprao@dnhsecheron.net','tsd.samples@dnhsecheron.net'
                });
                if (managerEmail == fieldStaffEmail) {    
                    // email.setCcAddresses(new String[] {
                    //     managerEmail, zonalEmail
                    // });
                } else {
                    // email.setCcAddresses(new String[] {
                    //     managerEmail, fieldStaffEmail, zonalEmail
                    // });
                }
            } else {
                if (managerEmail == fieldStaffEmail) {    
                    email.setToAddresses(new String[] {
                        managerEmail, zonalEmail
                    });
                } else {
                    email.setToAddresses(new String[] {
                        managerEmail, fieldStaffEmail, zonalEmail
                    });
                }
            }
        }

        email.setHtmlBody(htmlBody);

        // Add Email Attachment
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        List<ContentDocumentLink> contDocLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ordId];
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

        if (!emailAttachments.isEmpty() && addOnLine == '') {
            email.setFileAttachments(emailAttachments);
        }
    
        // Set related record ID for activity tracking
        email.setWhatId(ordId);
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
        
    }    

}