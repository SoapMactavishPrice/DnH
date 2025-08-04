public class CreateSampleRequest_ToNav {
    
    @future(callout=true)
    public static void insertSampleSalesOrderToNav(String SoId) {
        
        system.debug('soid '+SoId);

        String s = '';
        API_Log__c api_log = new API_Log__c();

        try {
            HttpUtils.APIparamter apiparam;
            String allfields = HttpUtils.getAllFields('Service_5_Sample_Request__c', SoId);
            Service_5_Sample_Request__c ord_v1 = Database.query(allfields);
            
            apiparam = HttpUtils.getAPIdetails('SampleOrderNav');

            // api_log.Sales_Order__c = ord_v1.Id;
            // ------------------- API LOG to track the request -------------------

            api_log.Log_Name__c = 'Create_SampleOrderTo_NAV';

            api_log.created_date__c = Datetime.now();

            // Step 1: Create JSON data separately
            String jsonData = createSampleOrderJsonData(SoId);

            //System.debug('apiparam.Request_body JSON: ' + apiparam.Request_body);
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('actualjson', jsonData);
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
            
            if (res.getStatusCode() == 200) {
                String responseBody = res.getBody();
                System.debug('Response: ' + responseBody);
                api_log.Response__c = res.getBody();
                String resBody = responseBody;
                s = 'ok';
                // Parse the SOAP response and extract salesDocumentNo

                String salesDocumentNo = parseTSDSoapResponse(responseBody);
                System.debug('Sales Document No: ' + salesDocumentNo);
                s = salesDocumentNo;
                if (salesDocumentNo == '') {
                    s = resBody;
                }
                // // Save the salesDocumentNo to the Order record
                saveResponseToSampleOrder(SoId, salesDocumentNo);
            } else {
                System.debug('Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody());
                s = 'Failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody();
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getLineNumber());
            s = 'Failed with status code: ' + e.getMessage();
        }

        insert api_log;
        // return s;

    }

    public static String createSampleOrderJsonData(String SoId) {

        String allfields = HttpUtils.getAllFields('Service_5_Sample_Request__c', SoId);
        Service_5_Sample_Request__c ord = Database.query(allfields);

        // Create a map to store the sales order details
        List < Map < String, Object >> mpList = new List < Map < String, Object >> ();
        Map < String, Object > salesOrder = new Map < String, Object > ();

        Date cd = Date.valueOf(ord.CreatedDate);
        String cddate = String.valueOf(cd.year()) + '-' +(cd.month() < 10 ? '0' : '')+ String.valueOf(cd.month()) + '-' +(cd.day() < 10 ? '0' : '')+ String.valueOf(cd.day());

        salesOrder.put('shiptoname', ord.Customer_Name__c);
        salesOrder.put('shiptoaddress', ord.Address_1__c);
        salesOrder.put('shiptoaddress2', ord.Address_2__c);
        salesOrder.put('shiptocity', ord.City__r.Name); //
        salesOrder.put('shiptocontact', ord.Contact_Person_Name__c);
        salesOrder.put('selltocontact', ord.Contact_Person_Name__c);
        // salesOrder.put('shiptopost', String.valueOf(ord.Post_Code__c));
        salesOrder.put('shiptopost', ord.Postal_Code__c);
        salesOrder.put('fieldstaffid', ord.Field_Staff_Code__r.Code__c);
        salesOrder.put('OrderDate', cddate);
        salesOrder.put('externaldocumentno', ord.Name);
        salesOrder.put('CustomerNo', '');

        // salesOrder.put('ContactNo', ord.Contact_No__c);
        // salesOrder.put('ModeOfDispatch', ord.Mode_of_Dispatch__c);
        // salesOrder.put('Remarks', ord.Remark__c);
        // salesOrder.put('AreaManager', ord.Area_Manager__r.Code__c);
        // salesOrder.put('ZonalHead', ord.Zonal_Head__r.Code__c);
        // salesOrder.put('SubmittedBy', ord.Submitted_By__r.Code__c);
        // salesOrder.put('SubmittedDate', cddate);
        // salesOrder.put('InsertedBy', ord.Inserted_By__r.Code__c);
        // salesOrder.put('Status', 'Submitted');
        // salesOrder.put('IsSubmitted', 'true');

        //=============================================

        // Create a list for Sales Order Line items
        String parentRecId = SoId;
        String allChildfields = HttpUtils.getOneLevelLineItemRecords('Sample_Request_Product__c', 'Sample_Request__c', parentRecId);

        List < Sample_Request_Product__c > OrderLineItem = new List < Sample_Request_Product__c > ();
        OrderLineItem = Database.query(allChildfields);

        List < Map < String, Object >> salesOrderLines = new List < Map < String, Object >> ();

        for (Sample_Request_Product__c solineItem: OrderLineItem) {
            Map < String, Object > lineItem = new Map < String, Object > ();
            lineItem.put('itemno', solineItem.Item_No__r.Item_Number__c); //
            lineItem.put('itemcategorycode', solineItem.Sample_Request_Item_Category_Code__r.Code__c);
            lineItem.put('variantno', ''); // Send blank as per Naresh sir
            lineItem.put('quantity', String.valueOf(solineItem.Quantity_2__c));
            lineItem.put('itembrand', solineItem.Sam_Req_Brand_Name__r.Code__c);
            lineItem.put('size', solineItem.Sam_Req_Size_mm__r.Code__c); //
            lineItem.put('packsize', ''); // Send blank as per Naresh sir
            lineItem.put('packingmode', '0'); // Send 0 as per Naresh sir

            // lineItem.put('ApplicationDetails', solineItem.Application_Details__c);
            // lineItem.put('SpecialProperties', solineItem.Special_Properties__c);
            // lineItem.put('QtyType', solineItem.Qty_Type_2__c);
            // lineItem.put('InsertedBy', solineItem.Sample_Request__r.Inserted_By__r.Code__c); //
            // lineItem.put('InsertedOn', cddate);
            // lineItem.put('Remarks', solineItem.Remarks__c);

            salesOrderLines.add(lineItem);
        }

        // Add the lines to the main sales order map
        salesOrder.put('nAVService5LineJsons', salesOrderLines);
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
            resultNode = body.getChildElement('InsertSampleSalesOrderServices5_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            // if (resultNode == null) {
            //     resultNode = body.getChildElement('GetSpecialRateSalesOrderResponse', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                
            // }
            Dom.XMLNode returnValueNode = resultNode.getChildElement('salesDocumentNo', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            Dom.XMLNode returnValueNode2 = resultNode.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            if(returnValueNode.getText()!=''){
                salesDocumentNo = returnValueNode.getText(); }else{  salesDocumentNo = returnValueNode2.getText();  }
            
               
           
            

        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
        }
        return salesDocumentNo;
    }

    public static void saveResponseToSampleOrder(String SoId, String SoNumber){

        String str = SampleOrderApproval_ToTSD.sampleOrderApproval(SoId, SoNumber);
        System.debug(str);

        Service_5_Sample_Request__c so = new Service_5_Sample_Request__c(Id = SoId);
        
        if (str == '1') {so.Sample_Order_Number__c = SoNumber;  so.Status__c = 'Submitted';
            
            
        } else {
            so.Sample_Order_Number__c = SoNumber + ' ; ' + str;
        }
        update so;

    }

}