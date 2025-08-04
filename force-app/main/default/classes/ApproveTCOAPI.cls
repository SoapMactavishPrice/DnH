@RestResource(urlMapping = '/ApproveTCO')
global class ApproveTCOAPI {

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');

        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'ApproveTCOAPI';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();

        // JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        List < JSON2ApexSaveWebToLead > jsonObjList = (List < JSON2ApexSaveWebToLead > ) JSON.deserialize(jSONRequestBody, List < JSON2ApexSaveWebToLead > .class);
        System.debug('======----->jsonObjList' + jsonObjList);

        String respMsg = '';

        try {

            // for (JSON2ApexSaveWebToLead jsonObj : jsonObjList) {
            //     System.debug('======----->jsonObj:  ' + jsonObj.DocumentNo);
            // }

            JSON2ApexSaveWebToLead jsonObj = jsonObjList[0];

            Map < String, String > responseMap = new Map < String, String > ();

            List < Enquiry__c > enquiryList = [
                SELECT Id, Name, Status__c, ApprovedRemark__c, ApprovedOn__c, ApprovedBy__c, Valid_Up_To__c, IsSubmit__c, OfferStatus__c,
                IschangedPrice__c, Enquiry_Name__c FROM Enquiry__c
                WHERE Enquiry_Name__c =: jsonObj.DocumentNo
            ];

            if (enquiryList.size() > 0) {

                Enquiry__c enq = new Enquiry__c();
                enq.Id = enquiryList[0].Id;
                enq.Status__c = jsonObj.Status;
                if (jsonObj.Status.contains('Approve')) {
                    respMsg = 'Approved';
                } else if (jsonObj.Status.contains('Reject')) {
                    respMsg = 'Rejected';
                }
                enq.ApprovedRemark__c = jsonObj.ApprovedRemark;
                enq.ApprovedOn__c = Datetime.valueOf(jsonObj.ApprovedOn_DD_MM_YYYY);
                // enq.ApprovedBy__c = jsonObj.ApprovedBy;
                enq.Valid_Up_To__c = Datetime.valueOf(jsonObj.Valid_Up_To_DD_MM_YYYY);
                enq.IsSubmit__c = Boolean.valueOf(jsonObj.IsSubmit);
                enq.OfferStatus__c = jsonObj.OfferStatus;
                enq.IschangedPrice__c = Boolean.valueOf(jsonObj.IschangedPrice);

                update enq;

                List < Enquiry_Line_Item__c > enqLIList = [
                    SELECT Id, Name, Item_Master__r.Item_Number__c, SuggestedDealerPrice__c, Discount_In_Percentage__c, Document_Line_Number__c
                    FROM Enquiry_Line_Item__c WHERE Enquiry__c =: enquiryList[0].Id
                ];

                if (enqLIList.size() > 0) {

                    Map < String, Decimal > itemRateMap = new Map < String, Decimal > ();
                    Map < String, Decimal > itemPercMap = new Map < String, Decimal > ();
                    Map < String, Integer > itemDocLineMap = new Map < String, Integer > ();

                    for (TCOItem v: jsonObj.TCOItems) {
                        itemRateMap.put(v.Item_No, Decimal.valueOf(v.SuggestedDealerPrice));
                        itemPercMap.put(v.Item_No, Decimal.valueOf(v.Discount_In_Percentage));
                        itemDocLineMap.put(v.Item_No, Integer.valueOf(v.DocumentLineNo));
                    }

                    // Set<String> itemSet = new Set<String>();
                    // List<Map<String, String>> noIremMapList = new List<Map<String, String>>();

                    List < Enquiry_Line_Item__c > updateELIList = new List < Enquiry_Line_Item__c > ();

                    for (Enquiry_Line_Item__c qli: enqLIList) {
                        if (itemRateMap.containsKey(qli.Item_Master__r.Item_Number__c)) {
                            System.debug(qli);
                            Enquiry_Line_Item__c upELI = new Enquiry_Line_Item__c();
                            upELI.Id = qli.Id;
                            upELI.SuggestedDealerPrice__c = itemRateMap.get(qli.Item_Master__r.Item_Number__c);
                            upELI.Approved_Price__c = itemRateMap.get(qli.Item_Master__r.Item_Number__c);
                            upELI.Discount_In_Percentage__c = itemPercMap.get(qli.Item_Master__r.Item_Number__c);
                            upELI.Document_Line_Number__c = itemDocLineMap.get(qli.Item_Master__r.Item_Number__c);
                            updateELIList.add(upELI);
                        }
                    }

                    update updateELIList;

                    Enquiry__c exenq = [
                        SELECT Id, Name, Area_Manager__r.Email, Submittedby_Customer__r.Name, Field_Staff_Code__r.Email,
                        Enquiry_Name__c, Customer_Name__c, Account__r.Customer_Code__c, Competition_Brand__c, End_Customer_Name__c,
                        Field_Staff_Code__r.Code__c, Source_Of_Price_Feedback__c, Technical_Requirement_Agreed__c, Remarks__c, Date_DD_MM_YYYY__c,
                        Field_Staff_Name__c, Application_Optional__c, Any_Special_Technical_Requirement__c, Valid_Up_To__c,
                        Area_Manager__r.Name, Field_Staff_Code__r.Name, Area_Manager__c, Field_Staff_Code__c, Account__c, RecordTypeId,
                        Account__r.Email_Id__c, Is_Created_From_TSD__c
                        FROM Enquiry__c WHERE Id =: enq.Id
                    ];

                    api_log.Enquiry__c = exenq.Id;

                    List < Enquiry_Line_Item__c > exenqli = [
                        SELECT Id, Name, Item_No__c, Item_Description__c, Item_Variant__r.Code__c, Item_Variant__r.UOM__c,
                        Item_Variant__r.Sales_UOM__c, Item_Master__r.Dim_Size__c, Item_Master__r.Item_Category_Code__c,
                        Dealer_Rate__c, Required_Rate_by_AM__c, Approved_Price__c, Qty__c, Standard_Dealer_Rate__c, Discount_In_Percentage__c
                        FROM Enquiry_Line_Item__c WHERE Enquiry__c =: enq.Id
                    ];

                    RecordType recordTypes = [
                        SELECT Id, Name
                        FROM RecordType
                        WHERE SObjectType = 'Enquiry__c'
                        AND Name = 'Techno Commercial Offer'
                    ];

                    String sFieldStaff = exenq.Area_Manager__c != null ? exenq.Area_Manager__r.Name : '';
                    String sAreaManager = exenq.Field_Staff_Code__c != null ? exenq.Field_Staff_Code__r.Name : '';

                    String sCompetition_Brand = exenq.Competition_Brand__c != null ? exenq.Competition_Brand__c : ' ';
                    String sApplication_Optional = exenq.Application_Optional__c != null ? exenq.Application_Optional__c : ' ';
                    String sEnd_Customer_Name = exenq.End_Customer_Name__c != null ? exenq.End_Customer_Name__c : ' ';
                    String sSource_Of_Price_Feedback = exenq.Source_Of_Price_Feedback__c != null ? exenq.Source_Of_Price_Feedback__c : ' ';
                    String sTechnical_Requirement_Agreed = exenq.Technical_Requirement_Agreed__c != null ? exenq.Technical_Requirement_Agreed__c : ' ';
                    String sAny_Special_Technical_Requirement = exenq.Any_Special_Technical_Requirement__c != null ? exenq.Any_Special_Technical_Requirement__c : ' ';
                    String sRemarks = exenq.Remarks__c != null ? exenq.Remarks__c : ' ';

                    // String managerEmail = 'huzaifa@finessedirect.com';
                    // String fieldStaffEmail = 'huzaifa@finessedirect.com';

                    String managerEmail = exenq.Area_Manager__r.Email;
                    String fieldStaffEmail = exenq.Field_Staff_Code__r.Email;
                    // String dealerMail = exenq.Is_Created_From_TSD__c ? exenq.Account__r.Email_Id__c : '';
                    String dealerMail = '';

                    if (managerEmail != null && fieldStaffEmail != null) {
                        // Set up the email
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if (managerEmail == fieldStaffEmail) {
                            email.setToAddresses(new String[] {
                                managerEmail
                            });
                            if (dealerMail != null && dealerMail != '') {
                                email.setCcAddresses(new String[] {
                                    dealerMail
                                });
                            }
                        } else {
                            email.setToAddresses(new String[] {
                                managerEmail
                            });
                            if (dealerMail != null && dealerMail != '') {
                                email.setCcAddresses(new String[] {
                                    fieldStaffEmail,
                                    dealerMail
                                });
                            } else {
                                email.setCcAddresses(new String[] {
                                    fieldStaffEmail
                                });
                            }
                        }

                        String emailsub = '';
                        Boolean isWithrevision = false;

                        // Construct the record link URL
                        String newTCOLink = Label.Cust_URL + '/lightning/n/Create_Sales_Order?c__enquiryId=' + exenq.Id + '&c__accountId=' + exenq.Account__c + '&c__recordtypeId=' + exenq.RecordTypeId;
                        // String newTCOLink = 'https://dream-inspiration-9915.lightning.force.com/lightning/r/Enquiry__c/'+exenq.Id+'/view';

                        String lineItemBody = '';
                        for (Enquiry_Line_Item__c v: exenqli) {
                            if (v.Dealer_Rate__c != v.Approved_Price__c) {
                                isWithrevision = true;
                            }
                            String litable =
                                '<tr>' +
                                '<td>' + v.Item_No__c + '</td><td>' + v.Item_Description__c + '</td>' +
                                '<td>' + v.Item_Variant__r.Code__c + '</td><td>' + v.Item_Master__r.Dim_Size__c + '</td>' +
                                '<td>' + v.Item_Variant__r.UOM__c + '</td><td>' + v.Standard_Dealer_Rate__c + '</td><td>' + v.Discount_In_Percentage__c + '</td>' +
                                '<td>' + v.Required_Rate_by_AM__c + '</td><td>' + v.Qty__c + '</td><td>' + v.Approved_Price__c + '</td>' +
                                '</tr>';
                            lineItemBody += litable;
                        }

                        String emailBody = '<html>' +
                            '<head><style>' +
                            'table { width: 100%; border-collapse: collapse; }' +
                            'table, th, td { border: 1px solid black; padding: 8px; text-align: left; }' +
                            'th { background-color: #f2f2f2; }' +
                            '</style></head>' +
                            '<body>' +
                            '<h2>Hello ' + sAreaManager + '</h2>' +
                            '<h2>Please Find Special Rate Document No : ' + exenq.Enquiry_Name__c + '</h2>' +
                            '<table>' +
                            '<tr><th colspan="2">Document Details</th><th colspan="2">Customer Details</th></tr>' +
                            '<tr>' +
                            '<td><b>Document No:</b></td><td>' + exenq.Enquiry_Name__c + '</td>' +
                            '<td><b>Document Date:</b></td><td>' + exenq.Date_DD_MM_YYYY__c + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td><b>Customer No:</b></td><td>' + exenq.Account__r.Customer_Code__c + '</td>' +
                            '<td><b>Customer Name:</b></td><td>' + exenq.Customer_Name__c + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td><b>Competition Brand:</b></td><td>' + sCompetition_Brand + '</td>' +
                            '<td><b>Application:</b></td><td>' + sApplication_Optional + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td><b>End Customer Name:</b></td><td>' + sEnd_Customer_Name + '</td>' +
                            '<td><b>FieldStaff Name:</b></td><td>' + exenq.Field_Staff_Name__c + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td><b>FieldStaff Code:</b></td><td>' + exenq.Field_Staff_Code__r.Code__c + '</td>' +
                            '<td><b>Source Of Price:</b></td><td>' + sSource_Of_Price_Feedback + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td><b>Technical requirement agreed by TSD or Not:</b></td><td>' + sTechnical_Requirement_Agreed + '</td>' +
                            '<td><b>Any Special requirement By Marketing:</b></td><td>' + sAny_Special_Technical_Requirement + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td><b>Remark:</b></td><td>' + sRemarks + '</td>' +
                            '<td><b>Valid Up To:</b></td><td>' + exenq.Valid_Up_To__c + '</td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td><b>DNH User Remark:</b></td><td colspan="3"></td>' +
                            '</tr>' +
                            '</table>' +
                            '<br/>' +
                            '<table>' +
                            '<tr>' +
                            '<th>Item NO</th><th>Description</th><th>Variant Code</th><th>Size</th>' +
                            '<th>UOM</th><th>Dealer Price</th><th>DISCOUNT %</th>' +
                            '<th>Required Price</th><th>Qty</th><th>Approved Price</th>' +
                            '</tr>' +
                            lineItemBody +
                            '</table>' +
                            '<br/>' +
                            '<div>Click below for more detail</div>' +
                            '<a href="' + newTCOLink + '" target="_blank">' + newTCOLink + '</a>' +
                            '</body>' +
                            '</html>';

                        if (respMsg == 'Approved') {
                            if (isWithrevision) {
                                emailsub = 'Special Rate Document Approved - With revision';
                            } else {
                                emailsub = 'Special Rate Document Approved';
                            }
                        } else {
                            emailsub = 'Special Rate Document Rejected';
                        }

                        email.setSubject(emailsub);
                        email.setHtmlBody(emailBody);

                        // Set related record ID for activity tracking
                        email.setWhatId(exenq.Id);
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
                    responseMap.put('status', '1');
                    responseMap.put('message', respMsg);

                } else {
                    responseMap.put('status', '0');
                    responseMap.put('message', 'No TCO LineItem Found!!');
                }

            } else {
                responseMap.put('status', '0');
                responseMap.put('message', 'No TCO Found!!');
            }

            String resp = JSON.serialize(responseMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;

            api_log.Log_Status__c = 'Success';
            api_log.Response_Code__c = '200';
            api_log.Response__c = String.valueOf(resp);
            api_log.response_time__c = Datetime.now();

        } catch (Exception e) {
            System.debug('Catch Error' + e.getStackTraceString());
            System.debug('Catch Error' + e.getMessage());
            System.debug('Catch Error' + e.getlineNumber());

            // ------------------- Create Response Map -------------------
            Map < string, string > errorResMap = new Map < string, string > ();
            errorResMap.put('Message', 'Something went wrong');
            errorResMap.put('Error1', e.getMessage());
            errorResMap.put('Error2', '' + e.getlineNumber());
            errorResMap.put('Error3', '' + String.valueOf(e));

            // ------------------- Send Response Map -------------------
            String resp = JSON.serialize(errorResMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;

            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();

        }

        insert api_log;

    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }

    public class JSON2ApexSaveWebToLead {
        public String DocumentNo;
        public String Status;
        public String ApprovedRemark;
        public String ApprovedOn_DD_MM_YYYY;
        public String ApprovedBy;
        public String Valid_Up_To_DD_MM_YYYY;
        public String IsSubmit;
        public String OfferStatus;
        public String IschangedPrice;
        public List < TCOItem > TCOItems;

    }

    // Nested wrapper class for TCOItems
    public class TCOItem {
        public String DocumentNo;
        public String UpdatedBy;
        public String UpdatedOn;
        public String Discount_In_Percentage;
        public String Item_No;
        public String SuggestedDealerPrice;
        public Integer DocumentLineNo;
    }

}