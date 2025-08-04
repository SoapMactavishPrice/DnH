//[  {    "CustomerNo": "CUS0012350",    "OrderDate": "10-24-2024",    "ShipMentaddress": "ABC XYZ",    "Shipmentaddress2": "ASDF RTYU",    "Shipmentcity": "Navi Mumbai",    "Postcode1": "400701",    "ExternalCommnet": "TEST1",    "InternalComment": "TEST2",    "ExternalDocumentNo": "X123456",    "Freightterms": "2",    "DestinationCitycode": "110001",    "LRDsetination": "NEW DELHI",    "LRfavour": "1",    "Deliverytype": "2",    "EngineerID": "DNH1077",    "AreaManager": "DNH1077",    "WebOrderDate": "10/24/2024",    "RateType": "2",    "ShipmentDate1": "10/24/2024",    "ShiptoCode": "",    "ZonalHead": "V. GANESH KUMAR",     "WebOrderNo": "EXP01" ,    "ContactName": "Mr.Kamal Jain",    "TransporterName":"VEN0000760",    "NAVSalesOrderLine": [      {        "ItemNo": "FGM0000020",        "ItemCategory": "FGM",        "Variant_code": "1BOX/4 CTN",        "Quantity": "10",        "Is_SOR": "1",        "SORType": "1",        "SpecialDiscount": "10",        "CashDiscount": "10",        "Description2": "SUPRATHERME 2.50 X 350 MM - 150PCS - REG",        "ConcessionalCode": "",        "AssesseeCode": "GOVT",        "TCSNatureofCollection": "TCS GOODS",        "SalesPrice": "5,755",        "ShipmentDate": "10/29/2024",        "nAVSalesOrderLineAttachments": null      }    ],    "nAVSalesOrderHeaderAttachments": null  }]

public with sharing class IntegrationHandler {
    @AuraEnabled
    public static String insertStandardSalesOrder(String SoId, String rectype) {
        String s = '';
        API_Log__c api_log = new API_Log__c();
        try {
            HttpUtils.APIparamter apiparam;
            if (rectype == '1') {

                apiparam = HttpUtils.getAPIdetails('SalesOrderTC');
            } else {
                apiparam = HttpUtils.getAPIdetails('SalesOrder');

            }
            String allfields = HttpUtils.getAllFields('Sales_Order__c', SoId);
            Sales_Order__c ord_v1 = Database.query(allfields);
            api_log.Sales_Order__c = ord_v1.Id;
            // ------------------- API LOG to track the request -------------------

            api_log.Log_Name__c = 'Create_StandardSalesOrder api callout';

            api_log.created_date__c = Datetime.now();

            // Step 1: Create JSON data separately
            String jsonData = createSalesOrderJsonData(SoId);

            //System.debug('apiparam.Request_body JSON: ' + apiparam.Request_body);
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('var', jsonData);
            if (reqBody.contains('&')) {
                reqBody = reqBody.replace('&', '&amp;');
            }
            /* String soapEnvelope = '<?xml version="1.0" encoding="utf-8"?>' +
                                   '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                                   '   <soapenv:Header/>' +
                                   '   <soapenv:Body>' +
                                   '      <sal:InsertStandardSalesOrder>' +
                                   '         <sal:jsonString>[{ "CustomerNo": "CUS0012350", "OrderDate": "10-24-2024", "ShipMentaddress": "ABC XYZ", "Shipmentaddress2": "ASDF RTYU", "Shipmentcity": "Navi Mumbai", "Postcode1": "400701", "ExternalCommnet": "TEST1", "InternalComment": "TEST2", "ExternalDocumentNo": "X123456", "Freightterms": "2", "DestinationCitycode": "110001", "LRDsetination": "NEW DELHI", "LRfavour": "1", "Deliverytype": "2", "EngineerID": "DNH1077", "AreaManager": "DNH1077", "WebOrderDate": "10/24/2024", "RateType": "2", "ShipmentDate1": "10/24/2024", "ShiptoCode": "", "ZonalHead": "V. GANESH KUMAR", "WebOrderNo": "EXP01", "ContactName": "Mr.Kamal Jain", "TransporterName":"VEN0000760", "NAVSalesOrderLine": [{ "ItemNo": "FGM0000020", "ItemCategory": "FGM", "Variant_code": "1BOX/4 CTN", "Quantity": "10", "Is_SOR": "1", "SORType": "1", "SpecialDiscount": "10", "CashDiscount": "10", "Description2": "SUPRATHERME 2.50 X 350 MM - 150PCS - REG", "ConcessionalCode": "", "AssesseeCode": "GOVT", "TCSNatureofCollection": "TCS GOODS", "SalesPrice": "5,755", "ShipmentDate": "10/29/2024", "nAVSalesOrderLineAttachments": null }], "nAVSalesOrderHeaderAttachments": null }] </sal:jsonString>' +
                                   '         <sal:salesDocumentNo>?</sal:salesDocumentNo>' +
                                   '      </sal:InsertStandardSalesOrder>' +
                                   '   </soapenv:Body>' +
                                   '</soapenv:Envelope>';*/
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

            if (res.getStatusCode() == 200) {
                String responseBody = res.getBody();
                api_log.Response__c = res.getBody();
                System.debug('Response: ' + responseBody);
                String resBody = responseBody;
                // Parse the SOAP response and extract salesDocumentNo

                String salesDocumentNo = parseSoapResponse(responseBody);
                System.debug('Sales Document No: ' + salesDocumentNo);
                s = salesDocumentNo;
                // if (salesDocumentNo.contains('fail-')) {
                //     s = resBody;
                // } else {

                // }

                // if (salesDocumentNo == '') {
                //     s = resBody;
                // }
                // Save the salesDocumentNo to the Order record
                saveResponseToOrder(SoId, salesDocumentNo, rectype);
            } else {
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
        String allfields = HttpUtils.getAllFields('Sales_Order__c', SoId);
        Sales_Order__c ord = Database.query(allfields);

        System.debug('ord.Account__c ' + ord.Account__c);
        //String allAccfields=HttpUtils.getAllFields('Account',ord.Account__c);
        Account acc = [SELECT Id, Customer_Code__c FROM Account WHERE Id =: ord.Account__c];

        // Create a map to store the sales order details
        List < Map < String, Object >> mpList = new List < Map < String, Object >> ();
        Map < String, Object > salesOrder = new Map < String, Object > ();
        salesOrder.put('CustomerNo', acc.Customer_Code__c);
        salesOrder.put('EndCustomerName', ord.End_Customer_Name__c);
        if (ord.Order_Booking_Date__c != null) {
            Date myDate = Date.valueOf(ord.Order_Booking_Date__c);
            String formattedDate = String.valueOf(myDate.year()) + '-' + (myDate.month() < 10 ? '0' : '') + String.valueOf(myDate.month()) + '-' + (myDate.day() < 10 ? '0' : '') + String.valueOf(myDate.day());
            System.debug('Formatted Date: ' + formattedDate);
            salesOrder.put('OrderDate', formattedDate);
            salesOrder.put('WebOrderDate', formattedDate);
        } else {
            salesOrder.put('OrderDate', '');
            salesOrder.put('WebOrderDate', '');
        }

        salesOrder.put('ShipMentaddress', ord.Shipment__c != null ? ord.Shipment__c.replaceall('&', ' ') : '');
        salesOrder.put('Shipmentaddress2', ord.Shipmentaddress2__c != null ? ord.Shipmentaddress2__c.replaceall('&', ' ') : '');
        salesOrder.put('Shipmentcity', ord.Shipmentcity__c);
        salesOrder.put('Postcode1', ord.ShipmentCode__c);
        salesOrder.put('ExternalCommnet', ord.External_Remarks__c);
        salesOrder.put('InternalComment', ord.Internal_Remarks__c);
        salesOrder.put('ExternalDocumentNo', ord.External_Doc_No_PO__c);
        salesOrder.put('Freightterms', ord.Freight_Terms__c);
        // salesOrder.put('DestinationCitycode', ord.ShipmentCode__c);
        // salesOrder.put('DestinationCitycode', ord.LR_Destination__c); // As per Naresh n Team
        // salesOrder.put('LRDsetination', ord.LR_Destination__c);
        salesOrder.put('DestinationCitycode', ord.LR_Destination_2__r.Code__c); // As per Naresh n Team
        salesOrder.put('LRDsetination', ord.LR_Destination_2__r.Code__c);
        salesOrder.put('LRfavour', ord.LR_favour__c);
        salesOrder.put('Deliverytype', ord.Delivery_Type__c);
        salesOrder.put('EngineerID', ord.Inserted_By_SP__r.Code__c == null ? ord.Inserted_By_Customer__r.Customer_Code__c : ord.Inserted_By_SP__r.Code__c);
        salesOrder.put('AreaManager', ord.Area_Manager__r.Code__c);

        salesOrder.put('RateType', ord.Rate_Type__c);
        salesOrder.put('ShipmentDate1', '2024-10-24'); //mapping pending
        salesOrder.put('ShiptoCode', ord.ShipmentCode__c);
        salesOrder.put('ZonalHead', ord.Zonal_Head__r.Code__c);
        // salesOrder.put('ZonalHead','V. GANESH KUMAR');
        salesOrder.put('WebOrderNo', ord.Name); //mapping pending
        salesOrder.put('ContactName', ord.Contact_Name__c);
        if (String.isNotBlank(ord.Transporter__c)) {
            salesOrder.put('TransporterName', ord.Transporter__r.Code__c);
            // salesOrder.put('TransporterNo', ord.Transporter__r.Code__c);
        }

        // Create a list for Sales Order Line items
        String parentRecId = SoId;
        String allChildfields = HttpUtils.getOneLevelLineItemRecords('Sales_Order_Line_Item__c', 'Sales_Order__c', parentRecId);

        List < Sales_Order_Line_Item__c > OrderLineItem = new List < Sales_Order_Line_Item__c > ();
        OrderLineItem = Database.query(allChildfields);

        List < Map < String, Object >> salesOrderLines = new List < Map < String, Object >> ();
        for (Sales_Order_Line_Item__c solineItem: OrderLineItem) {
            Map < String, Object > lineItem = new Map < String, Object > ();
            lineItem.put('ItemNo', solineItem.Item_Number__c);
            lineItem.put('ItemCategory', solineItem.Item_Master__r.Item_Category_Code__c);
            lineItem.put('Variant_code', solineItem.Item_Variant__r.Code__c);
            lineItem.put('Quantity', solineItem.Quantity__c);
            lineItem.put('Is_SOR', solineItem.Is_SOR__c ? '1' : '0');
            lineItem.put('SORType', solineItem.Is_SOR__c ? solineItem.Special_Order_Type__c : '1'); //mapping pending
            lineItem.put('SORRemark', solineItem.SOR_Remark__c != null ? solineItem.SOR_Remark__c : ''); //mapping pending
            lineItem.put('SpecialDiscount', solineItem.SpecialDiscount__c != null ? String.valueOf(solineItem.SpecialDiscount__c) : '0');
            if (solineItem.Cash_Discount__c != null) {
                lineItem.put('CashDiscount', String.valueOf(solineItem.Cash_Discount__c));
            } else {
                if (solineItem.Discount_In_Percentage__c != null) {
                    lineItem.put('CashDiscount', String.valueOf(solineItem.Discount_In_Percentage__c));
                } else {
                    lineItem.put('CashDiscount', '0');
                }
            }
            lineItem.put('Description2', solineItem.Description2__c);
            lineItem.put('ConcessionalCode', ''); //mapping pending
            lineItem.put('AssesseeCode', 'GOVT'); //mapping pending
            lineItem.put('TCSNatureofCollection', 'TCS GOODS');
            lineItem.put('SalesPrice', solineItem.Sales_Price__c);

            if (solineItem.Shipment_Date__c != null) {
                Date myDate = Date.valueOf(solineItem.Shipment_Date__c);
                String formattedDate = String.valueOf(myDate.year()) + '-' + (myDate.month() < 10 ? '0' : '') + String.valueOf(myDate.month()) + '-' + (myDate.day() < 10 ? '0' : '') + String.valueOf(myDate.day());
                System.debug('Formatted Date: ' + formattedDate);
                lineItem.put('ShipmentDate', formattedDate);
            } else {
                lineItem.put('ShipmentDate', '');
            }

            // Create attachment map for each line item
            if (solineItem.Is_SOR__c) {
                List < Map < String, String >> attachments = new List < Map < String, String >> ();
                if (solineItem.Sales_Order__r.Is_Created_From_TSD__c) {
                    if (solineItem.Attachment_Link__c != null && solineItem.Attachment_Link__c != '') {
                        List<AttachmentWrapper> lineItemAttList = (List<AttachmentWrapper>) JSON.deserialize(
                            solineItem.Attachment_Link__c, List<AttachmentWrapper>.class
                        );
                        for (AttachmentWrapper var : lineItemAttList) {
                            Map < String, String > att = new Map < String, String > ();
                            att.put('LinkAddress', var.DocumentLink);
                            attachments.add(att);
                        }
                        // lineItem.put('nAVSalesOrderLineAttachments', attachments);
                    } else {
                        // throw new IllegalArgumentException('1. Attachment link required for SOR');
                    }
                }
                List < ContentDocumentLink > contDocLink = new List < ContentDocumentLink > ();
                Set < String > cdlSet = new Set < String > ();
                contDocLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: solineItem.Id];
                for (ContentDocumentLink cdl: contDocLink) {
                    System.debug('ContentDocumentId: ' + cdl.ContentDocumentId);
                    cdlSet.add(cdl.ContentDocumentId);
                }
                List < ContentDistribution > cds = new List < ContentDistribution > ();
                cds = [SELECT Id, ContentDocumentId, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId IN: cdlSet];
                if (cds.size() > 0) {
                    for (ContentDistribution cd: cds) {
                        Map < String, String > att = new Map < String, String > ();
                        att.put('LinkAddress', cd.DistributionPublicUrl);
                        attachments.add(att);
                    }
                    // lineItem.put('nAVSalesOrderLineAttachments', attachments);
                } else {
                    // throw new IllegalArgumentException('1. Attachment link required for SOR');
                }
                if (attachments.size() > 0) {
                    lineItem.put('nAVSalesOrderLineAttachments', attachments);
                } else {
                    throw new IllegalArgumentException('2. Attachment link required for SOR');
                }
            } else {
                lineItem.put('nAVSalesOrderLineAttachments', null);
            }


            salesOrderLines.add(lineItem);
        }

        // Add the lines to the main sales order map
        salesOrder.put('NAVSalesOrderLine', salesOrderLines);

        // Add Sales order header attachment
        List < ContentDocumentLink > contDocLinkHeader = new List < ContentDocumentLink > ();
        Set < String > cdlSetHeader = new Set < String > ();

        contDocLinkHeader = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: SoId];

        for (ContentDocumentLink cdl: contDocLinkHeader) {
            System.debug('ContentDocumentId for Header: ' + cdl.ContentDocumentId);
            cdlSetHeader.add(cdl.ContentDocumentId);
        }

        List < ContentDistribution > cdsHeader = new List < ContentDistribution > ();

        cdsHeader = [SELECT Id, ContentDocumentId, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId IN: cdlSetHeader];
        if (cdsHeader.size() > 0) {
            List < Map < String, String >> attachmentsHeader = new List < Map < String, String >> ();
            for (ContentDistribution cd: cdsHeader) {
                Map < String, String > att = new Map < String, String > ();
                att.put('LinkAddress', cd.DistributionPublicUrl);
                attachmentsHeader.add(att);
            }
            salesOrder.put('nAVSalesOrderHeaderAttachments', attachmentsHeader);
        } else {
            salesOrder.put('nAVSalesOrderHeaderAttachments', null);
        }
        // salesOrder.put('nAVSalesOrderHeaderAttachments', null);
        mpList.add(salesOrder);

        // Convert the map to a JSON string
        String jsonString = JSON.serialize(mpList);
        return jsonString;
    }

    // Function to parse the SOAP response and extract salesDocumentNo
    public static String parseSoapResponse(String responseBody) {
        String salesDocumentNo = '';
        try {
            Dom.Document doc = new Dom.Document();
            doc.load(responseBody);

            // Navigate the XML structure and extract salesDocumentNo
            Dom.XMLNode envelope = doc.getRootElement();
            Dom.XMLNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode resultNode;
            resultNode = body.getChildElement('InsertStandardSalesOrder_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            if (resultNode == null) {
                resultNode = body.getChildElement('InsertSalesOrderWithTC_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');

            }
            Dom.XMLNode salesDocNode = resultNode.getChildElement('salesDocumentNo', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            Dom.XMLNode returnValueNode = resultNode.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            if (returnValueNode.getText() == '1') {
                salesDocumentNo = salesDocNode.getText(); // SOB/2024/0001234
            } else {
                salesDocumentNo = returnValueNode.getText(); // Any error message from NAV
                return 'fail-' + salesDocumentNo;
            }

            // if (salesDocNode.getText() != '') {
            //     salesDocumentNo = salesDocNode.getText();
            // } else {
            //     salesDocumentNo = returnValueNode.getText();
            // }

        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
        }
        return salesDocumentNo;
    }

    // Function to save the response to the Order record
    public static void saveResponseToOrder(String orderId, String salesDocumentNo, String rectype) {
        try {
            // Assuming you are updating an Order record with the extracted salesDocumentNo
            // Adjust this based on how you are identifying the Order record (e.g., by Order ID)
            Sales_Order__c ord = [SELECT Id, Sales_Document_Number__c, Is_Created_From_TSD__c FROM Sales_Order__c WHERE Id =: orderId LIMIT 1];

            // if (!salesDocumentNo.contains(' ') && (salesDocumentNo.contains('SOB/') || salesDocumentNo.contains('/2425/') || salesDocumentNo.contains('/'))) {

            //     CreateSalesOrder_ToTSDportal.insertStandardSalesOrderToTSD(orderId);
            // }

            String ret = '';
            if (ord.Is_Created_From_TSD__c) {
                // IntegrationHandler inthandler = new IntegrationHandler();
                ret = IntegrationHandler.salesOrderApproval(orderId, 2, salesDocumentNo);
            }

            System.debug(ret);

            if (!salesDocumentNo.contains('fail-')) {
                ord.Sales_Document_Number__c = salesDocumentNo; // Update your custom field on the Order object
                ord.Created_to_NAV__c = true;
                if (ord.Is_Created_From_TSD__c) {
                    ord.Status__c = 'Approved';
                }
            } else {
                ord.Sales_Order_Exception__c = salesDocumentNo;
            }
            // if(ret =='Approved'){
            //     ord.Status__c = 'Approved';
            // }
            // if(ret =='Rejected'){
            //     ord.Status__c = 'Rejected';
            // }
            update ord;

            if (ord.Is_Created_From_TSD__c && ord.Status__c == 'Approved' && ord.Sales_Document_Number__c.contains('SOB/')) {
                // AddSalesOrder.sendEmailToAreaManager(ord.Id, '');
                System.enqueueJob(new SendEmailJob(ord.Id));
            }

        } catch (Exception e) {
            System.debug('Error updating Order record: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static string getRecType(String SoId) {
        try {

            String recTypeId = [SELECT Id, Name, Enquiry__r.RecordType.Name FROM Sales_Order__c WHERE Id =: SoId].Enquiry__r.RecordType.Name;

            return recTypeId == null ? 'Normal Enquiry' : recTypeId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getDetails(String accId) {
        try {
            System.debug('accId' + accId);
            String SoId = accId;
            System.debug('SoId' + SoId);
            String allfields = HttpUtils.getAllFields('Account', SoId);
            Account acc = Database.query(allfields);
            List < Account > accList = new List < Account > ();
            accList.add(acc);

            return AccountTriggerHandler.syncAccountToNavision_v1(accList);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string sendForApproval(String tcoId) {
        try {
            System.debug('accId' + tcoId);
            String SoId = tcoId;
            System.debug('SoId' + SoId);
            String allfields = HttpUtils.getAllFields('Enquiry__c', SoId);
            Enquiry__c enq = Database.query(allfields);
            User usr = [SELECT Id, Email, Reporting_Person__c FROM User WHERE Id =: UserInfo.getUserId()];
            // System.debug(usr.Id);
            // System.debug(enq.Area_Manager__c);
            // System.debug(enq.Field_Staff_Code__r.Reporting_Person_ID__c );
            // System.debug(enq.Area_Manager__r.Code__c);

            if (enq.Status__c == 'Approved By Shivi Chaturvedi') {
                return 'This TCO is already approved.';
            } else {
                if (usr.Id == enq.Field_Staff_Code__c) {
                    if (enq.Field_Staff_Code__r.Area_Manager__c || enq.Field_Staff_Code__r.IsApprovedUser__c) {
                        //enq.SubmittedBy__c=UserInfo.getUserId();
                        // UPDATE enq;
                        return EnquiryTriggerHandler.approveTCOSyncToTSD(enq.Id);
                    } else {
                        return 'you dont have to access to approve this TCO 1';
                    }
                } else if (usr.Id == enq.Area_Manager__c && enq.Field_Staff_Code__r.Reporting_Person_ID__c == enq.Area_Manager__r.Code__c) {
                    //enq.SubmittedBy__c=UserInfo.getUserId();
                    // UPDATE enq;
                    return EnquiryTriggerHandler.approveTCOSyncToTSD(enq.Id);
                } else {
                    return 'you dont have to access to approve this TCO 2';
                }

            }

        } catch (Exception e) {
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class APIparamter {
        public string Endpoint;
        public string Method;
        public string ContentType;
        public string Password;
        public string Request_body;
        public string SOAPAction;
        public string Username;
    }

    // ======== For Sales Order Approval by AM ========= //
    @AuraEnabled
    public static String salesOrderApproval(String soid, Integer statustype, String sonumber) {

        String s = '';
        API_Log__c api_log = new API_Log__c();
        try {
            HttpUtils.APIparamter apiparam;

            String allfields = HttpUtils.getAllFields('Sales_Order__c', soid);
            Sales_Order__c ord_v1 = Database.query(allfields);

            if (ord_v1.Rate_Type__c == '2') {
                apiparam = HttpUtils.getAPIdetails('SalesOrderApprovedByAM');
                api_log.Log_Name__c = 'SalesOrderApprovedByAM';
            } else {
                apiparam = HttpUtils.getAPIdetails('SalesOrderApprovedByAMTC');
                api_log.Log_Name__c = 'SalesOrderApprovedByAMTC';
            }

            api_log.Sales_Order__c = ord_v1.Id;
            api_log.created_date__c = Datetime.now();

            // Step 1: Create JSON data separately
            String jsonData = createSalesOrderApproveJsonData(soid, statustype, sonumber, ord_v1.Rate_Type__c);

            //System.debug('apiparam.Request_body JSON: ' + apiparam.Request_body);
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('var', jsonData);
            if (reqBody.contains('&')) {
                reqBody = reqBody.replace('&', '&amp;');
            }

            api_log.Request__c = reqBody;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            // req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));
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
                s = salesDocumentNo;
                if (salesDocumentNo == 'Approval Sent Successfully') {
                    s = resBody;
                    if (statustype == 2) {
                        s = 'Approved';
                    } else if (statustype == 3) {
                        s = 'Rejected';
                    }
                }
                // Update the Status to the Sales Order record
                // Sales_Order__c upso = new Sales_Order__c();
                // upso.Id = soid;
                // if (statustype == 2) {
                //     upso.Status__c = 'Approved';
                // } else if (statustype == 3) {
                //     upso.Status__c = 'Rejected';
                // }
                // update upso;

            } else {
                System.debug('Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody());
                s = 'Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody();
                api_log.Exception_desc__c = 'In salesOrderApproval method of class integration handler: ' + res.getBody();
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            s = 'Failed with status code: ' + e.getMessage();
            api_log.Exception_desc__c = 'In salesOrderApproval method of class integration handler on line number: ' + e.getLineNumber() + ' || ' + e.getMessage();
        }
        insert api_log;
        return s;

    }

    public static String createSalesOrderApproveJsonData(String soid, Integer statustype, String sonumber, String ratetype) {
        String allfields = HttpUtils.getAllFields('Sales_Order__c', soid);
        Sales_Order__c ord = Database.query(allfields);

        // Create a map to store the sales order details
        List < Map < String, Object >> mpList = new List < Map < String, Object >> ();
        Map < String, Object > salesOrder = new Map < String, Object > ();

        salesOrder.put('WebOrderNo', ord.Name);
        salesOrder.put('DocumentNo', statustype == 2 ? sonumber : '');
        salesOrder.put('IsSubmitted', statustype);
        salesOrder.put('External_Remarks', ord.External_Remarks__c != null ? ord.External_Remarks__c : 'NA');
        salesOrder.put('Rate_Type', ord.Rate_Type__c == '1' ? 'Special Rate' : 'Standard Rate');
        salesOrder.put('IsPostedToNav', 'true'); // must be true
        salesOrder.put('updatedBy', ord.Updated_By_SP__r.Code__c); // need to confirm
        if (ratetype == '1') {
            salesOrder.put('TechnoDocNo', ord.Enquiry__r.Enquiry_Name__c);
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
            Dom.XMLNode resultNode;
            resultNode = body.getChildElement('ApprovedStandardOrderByAMResponse', 'http://tempuri.org/');
            if (resultNode == null) {
                resultNode = body.getChildElement('ApprovedSpecialRateOrderByAMResponse', 'http://tempuri.org/');
            }
            Dom.XMLNode returnValueNode = resultNode.getChildElement('responseLog', 'http://tempuri.org/');
            if (returnValueNode.getText() != '') {
                salesDocumentNo = returnValueNode.getText();
            } else {
                salesDocumentNo = 'Approval Sent Successfully';
            }

        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
        }
        return salesDocumentNo;
    }

    @AuraEnabled
    public static string updateSalesOrderApprovalStatus(String soid, Integer statustype) {
        try {

            Sales_Order__c upso = new Sales_Order__c();
            upso.Id = soid;
            if (statustype == 2) {
                upso.Status__c = 'Approved';
            } else if (statustype == 3) {
                upso.Status__c = 'Rejected';
            }
            update upso;

            return 'Success';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class AttachmentWrapper {
        public String DocumentLink;
        public String Title;
    }

}