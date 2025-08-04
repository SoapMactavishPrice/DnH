@RestResource(urlMapping='/CreateTCO')
global class CreateEnquiryTCOAPI {
    @HttpPost
    global static void doPost() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');
        
        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'CreateTCO API';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();

        JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        System.debug('======----->jsonObj' + jsonObj);

        try {
            // ------------------- Logic start from here -------------------

            if (jsonObj.CustomerNo != null && jsonObj.CustomerNo != '') {
                
                // Query for both record types in one query and store them in a map
                List<RecordType> recordTypes = [
                    SELECT Id, Name 
                    FROM RecordType 
                    WHERE SObjectType = 'Enquiry__c'
                    AND Name IN ('Techno Commercial Offer')
                ];

                // Create a Map with Name as the key
                Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
                for (RecordType rt : recordTypes) {
                    recordTypeMap.put(rt.Name, rt);
                }

                // Determine which RecordTypeId to use based on the condition
                String recordTypeId;
                // if (jsonObj.IsTCO == 'true') {
                //     recordTypeId = recordTypeMap.get('Techno Commercial Offer').Id;
                // } else {
                //     recordTypeId = recordTypeMap.get('Normal Enquiry').Id;
                // }

                recordTypeId = recordTypeMap.get('Techno Commercial Offer').Id;

                Enquiry__c newEnq = new Enquiry__c();
                newEnq.Is_Created_From_TSD__c = true;
                List<Enquiry__c> exEnquiry = [SELECT Id, Name, Enquiry_Name__c FROM Enquiry__c WHERE Enquiry_Name__c =: jsonObj.TCO_Name];
                if (exEnquiry.size() > 0) {
                    newEnq.Id  = exEnquiry[0].Id;
                    newEnq.Status__c  = 'Drafted';
                } else {
                    if (jsonObj.CustomerNo != null && jsonObj.CustomerNo != '') {
                        // newEnq.Account__c = jsonObj.CustomerNo;
                        List<Account> accountListbyCode = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Customer_Code__c =: jsonObj.CustomerNo];
                        if (accountListbyCode.size() > 0) {                        
                            newEnq.Account__c = accountListbyCode[0].Id;
                        }
                    }
                }
                newEnq.RecordTypeId = recordTypeId;
                // newEnq.Status__c = jsonObj.Status;
                newEnq.Status__c = 'Drafted';
                newEnq.Enquiry_Name__c = jsonObj.TCO_Name;
                if(jsonObj.Date_DD_MM_YYYY != null && jsonObj.Date_DD_MM_YYYY != ''){
                    newEnq.Date_DD_MM_YYYY__c = Date.valueOf(jsonObj.Date_DD_MM_YYYY);
                }
                newEnq.Competition_Brand__c = jsonObj.Competition_Brand;
                newEnq.Application_Optional__c = jsonObj.Application_Optional;
                newEnq.Source_Of_Price_Feedback__c = jsonObj.Source_Of_Price_Feedback;
                if (jsonObj.Field_Staff_Code != null && jsonObj.Field_Staff_Code != '') {
                    List<User> userListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.Field_Staff_Code];
                    if (userListbyCode.size() > 0) {                        
                        newEnq.Field_Staff_Code__c = userListbyCode[0].Id;
                    }
                }
                newEnq.TechnicalReq__c = jsonObj.TechnicalReq;
                newEnq.Any_Special_Technical_Requirement__c = jsonObj.Any_Special_Technical_Requirement;
                newEnq.Remarks__c = jsonObj.Remarks;
                if (jsonObj.SubmittedBy != null && jsonObj.SubmittedBy != '') {

                    if(jsonObj.IsCustomer != null && jsonObj.IsCustomer != ''){
                        if (jsonObj.IsCustomer == 'true') {
                            List<Account> accountListbyCode = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Customer_Code__c =: jsonObj.SubmittedBy];
                            if (accountListbyCode.size() > 0) {                        
                                newEnq.Submittedby_Customer__c = accountListbyCode[0].Id;
                            }
                        } else {
                            List<User> userListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.SubmittedBy];
                            if (userListbyCode.size() > 0) {                        
                                newEnq.SubmittedBy__c = userListbyCode[0].Id;
                            }
                        }
                        newEnq.IsCustomer__c = Boolean.valueOf(jsonObj.IsCustomer);
                    }

                    // newEnq.SubmittedBy__c = jsonObj.SubmittedBy;
                }
                if(jsonObj.SubmittedOn != null && jsonObj.SubmittedOn != ''){
                    newEnq.SubmittedOn__c = Datetime.valueOf(jsonObj.SubmittedOn);
                }
                if(jsonObj.IsSubmit != null && jsonObj.IsSubmit != ''){
                    newEnq.IsSubmit__c = Boolean.valueOf(jsonObj.IsSubmit);
                }
                if(jsonObj.ApprovedOn != null && jsonObj.ApprovedOn != ''){
                    newEnq.ApprovedOn__c = Datetime.valueOf(jsonObj.ApprovedOn);
                }
                if (jsonObj.ApprovedBy != null && jsonObj.ApprovedBy != '') {
                    List<User> userListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.ApprovedBy];
                    if (userListbyCode.size() > 0) {                        
                        newEnq.ApprovedBy__c = userListbyCode[0].Id;
                    }
                }
                newEnq.ApprovedRemark__c = jsonObj.ApprovedRemark;
                if(jsonObj.Deactive != null && jsonObj.Deactive != ''){
                    newEnq.Deactive__c = Boolean.valueOf(jsonObj.Deactive);
                }
                // if (jsonObj.CustomerNo != null && jsonObj.CustomerNo != '') {
                //     // newEnq.Account__c = jsonObj.CustomerNo;
                //     List<Account> accountListbyCode = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Customer_Code__c =: jsonObj.CustomerNo];
                //     if (accountListbyCode.size() > 0) {                        
                //         newEnq.Account__c = accountListbyCode[0].Id;
                //     }
                // }
                if (jsonObj.Zonal_Head != null && jsonObj.Zonal_Head != '') {
                    // newEnq.Zonal_Head__c = jsonObj.Zonal_Head;
                    List<User> userListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.Zonal_Head];
                    if (userListbyCode.size() > 0) {                        
                        newEnq.Zonal_Head__c = userListbyCode[0].Id;
                    }
                }
                if (jsonObj.Area_Manager != null && jsonObj.Area_Manager != '') {
                    // newEnq.Area_Manager__c = jsonObj.Area_Manager;
                    List<User> userListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.Area_Manager];
                    if (userListbyCode.size() > 0) {                        
                        newEnq.Area_Manager__c = userListbyCode[0].Id;
                    }
                }
                if(jsonObj.Valid_Up_To != null && jsonObj.Valid_Up_To != ''){
                    newEnq.Valid_Up_To__c = Datetime.valueOf(jsonObj.Valid_Up_To);
                }
                if(jsonObj.UpdatedBy != null && jsonObj.UpdatedBy != ''){
                    newEnq.UpdatedBy__c = jsonObj.UpdatedBy;
                }
                if(jsonObj.UpdatedOn != null && jsonObj.UpdatedOn != ''){
                    newEnq.UpdatedOn__c = Datetime.valueOf(jsonObj.UpdatedOn);
                }
                if(jsonObj.ExtensionDate != null && jsonObj.ExtensionDate != ''){
                    newEnq.ExtensionDate__c = Datetime.valueOf(jsonObj.ExtensionDate);
                }
                newEnq.OfferStatus__c = jsonObj.OfferStatus;
                newEnq.DnHExtensionDateReamrk__c = jsonObj.DnHExtensionDateReamrk;
                if(jsonObj.IsExtendOffer != null && jsonObj.IsExtendOffer != ''){
                    newEnq.IsExtendOffer__c = Boolean.valueOf(jsonObj.IsExtendOffer);
                }
                if(jsonObj.IsExpire != null && jsonObj.IsExpire != ''){
                    newEnq.IsExpire__c = Boolean.valueOf(jsonObj.IsExpire);
                }
                newEnq.End_Customer_Name__c = jsonObj.End_Customer_Name;
                newEnq.StatisticsZone__c = jsonObj.StatisticsZone;
                newEnq.StatiState__c = jsonObj.StatiState;
                if(jsonObj.IschangedPrice != null && jsonObj.IschangedPrice != ''){
                    newEnq.IschangedPrice__c = Boolean.valueOf(jsonObj.IschangedPrice);
                }
                if(jsonObj.IsCustomer != null && jsonObj.IsCustomer != ''){
                    newEnq.IsCustomer__c = Boolean.valueOf(jsonObj.IsCustomer);
                }
                newEnq.SubmittedByStatus__c = jsonObj.SubmittedByStatus;
                if(jsonObj.IsSubmittedbyCustomer != null && jsonObj.IsSubmittedbyCustomer != ''){
                    newEnq.IsSubmittedbyCustomer__c = Boolean.valueOf(jsonObj.IsSubmittedbyCustomer);
                }
                if(jsonObj.IsSubmittedByAM != null && jsonObj.IsSubmittedByAM != ''){
                    newEnq.IsSubmittedByAM__c = Boolean.valueOf(jsonObj.IsSubmittedByAM);
                }
                if (jsonObj.PreparedBy != null && jsonObj.PreparedBy != '') {
                    // newEnq.PreparedBy__c = jsonObj.PreparedBy;
                    List<User> userListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.PreparedBy];
                    if (userListbyCode.size() > 0) {                        
                        newEnq.PreparedBy__c = userListbyCode[0].Id;
                    }
                }

                System.debug('HeaderAttachment:>>>> ' +jsonObj.HeaderAttachment);
                if (jsonObj.HeaderAttachment != null && jsonObj.HeaderAttachment.size() > 0) {
                    List<Map <String, String>> headerAttMapList = new List<Map <String, String>>();
                    for (TCOHeaderAttachments var : jsonObj.HeaderAttachment) {
                        // CreateSalesOrderWithTCO.downloadAndInsertHeaderAtt(var.Title,var.DocumentLink,newSO.Id);
                        if (var.Title != null && var.Title != '' && var.DocumentLink != null && var.DocumentLink != '') {
                            headerAttMapList.add(new Map<String,String>{'Title'=>var.Title,'DocumentLink'=>var.DocumentLink});
                        } else {
                            throw new IllegalArgumentException('Title and DocumentLink required');
                        }
                        newEnq.Attachment_Link__c = json.serialize(headerAttMapList);
                    }
                }
                
                upsert newEnq;

                Map<String, String> exsistingLineItemMap = new Map<String, String>();
                Map<String, String> itemIdMap = new Map<String, String>();

                List<Enquiry_Line_Item__c> getExistingLineItem = [
                    SELECT Id, Name, Item_Master__r.Item_Number__c, Temp_Line_No__c, Document_Line_Number__c, Enquiry__r.Enquiry_Name__c
                    FROM Enquiry_Line_Item__c
                    WHERE Enquiry__c =: newEnq.Id
                ];

                

                if (getExistingLineItem.size() > 0) {
                    for (Enquiry_Line_Item__c v : getExistingLineItem) {
                        itemIdMap.put(v.Item_Master__r.Item_Number__c, v.Id);
                        exsistingLineItemMap.put(v.Enquiry__r.Enquiry_Name__c+v.Temp_Line_No__c, v.Id);
                    }
                }

                List<Enquiry_Line_Item__c> deleteLineItem = new List<Enquiry_Line_Item__c>();
                for (EnqLineItemClass a : jsonObj.TCOItems) {
                    if (a.IsDeleted == 1 && itemIdMap.containsKey(a.Item_No)) {
                        deleteLineItem.add(new Enquiry_Line_Item__c(Id = itemIdMap.get(a.Item_No)));
                    }
                }

                // if (deleteLineItem.size() > 0) {
                //     delete deleteLineItem;
                // }

                List<Enquiry_Line_Item__c> newTCO = new List<Enquiry_Line_Item__c>();
                for (EnqLineItemClass a : jsonObj.TCOItems) {

                    Enquiry_Line_Item__c techCO = new Enquiry_Line_Item__c();

                    if (a.IsDeleted == 0 && exsistingLineItemMap.containsKey(a.DocumentNo+a.Temp_Line_No)) {
                        System.debug('In Is Deleted');
                        techCO.Id = exsistingLineItemMap.get(a.DocumentNo+a.Temp_Line_No);
                    } else {
                        
                        techCO.Enquiry__c = newEnq.Id;
                        techCO.Item_No__c = a.Item_No;
                    }
                    techCO.Item_Category2__c = a.Item_Category;
                    if (a.Item_No != null && a.Item_No != '') {
                        List<Item_Master__c> userListbyCode = [
                            SELECT Id, Name, Item_Number__c FROM Item_Master__c
                            WHERE Item_Number__c =: a.Item_No
                            AND Item_Type__c = 'Normal'
                        ];
                        if (userListbyCode.size() > 0) {                        
                            techCO.Item_Master__c = userListbyCode[0].Id;
                        }
                    }
                    if (a.Variant_Code != null && a.Variant_Code != '') {
                        // techCO.Item_Variant__c = a.Variant_Code;
                        List<Item_Variant__c> userListbyCode = [
                            SELECT Id, Name, Code__c, UOM__c, Sales_UOM__c
                            FROM Item_Variant__c
                            WHERE Code__c =: a.Variant_Code
                            AND Item_No__c =: a.Item_No
                        ];
                        if (userListbyCode.size() > 0) {                        
                            techCO.Item_Variant__c = userListbyCode[0].Id;
                            techCO.BUOM__c = userListbyCode[0].UOM__c;
                            techCO.SUOM__c = userListbyCode[0].Sales_UOM__c;
                        }
                    }
                    techCO.Size_mm2__c = a.Size_mm;
                    if(a.Dealer_Rate != null && a.Dealer_Rate != ''){
                        techCO.Dealer_Rate__c = Decimal.valueOf(a.Dealer_Rate);
                        techCO.Required_Rate_by_AM__c = Decimal.valueOf(a.Dealer_Rate);
                        techCO.Requested_Rate_By_Dealer__c = Decimal.valueOf(a.Dealer_Rate);
                    }
                    if(a.Qty != null && a.Qty != ''){
                        techCO.Qty__c = Decimal.valueOf(a.Qty);
                    }
                    techCO.Temp_Line_No__c = a.Temp_Line_No;
                    if(a.Deactive != null && a.Deactive != ''){
                        techCO.Deactive__c = Boolean.valueOf(a.Deactive);
                    }
                    if(a.Standard_Dealer_Rate != null && a.Standard_Dealer_Rate != ''){
                        techCO.Standard_Dealer_Rate__c = Decimal.valueOf(a.Standard_Dealer_Rate);
                    }
                    if(a.Standard_Private_Rate != null && a.Standard_Private_Rate != ''){
                        techCO.Standard_Private_Rate__c = Decimal.valueOf(a.Standard_Private_Rate);
                    }
                    if(a.Suggested_Private_Price != null && a.Suggested_Private_Price != ''){
                        techCO.Suggested_Private_Price__c = Decimal.valueOf(a.Suggested_Private_Price);
                    }
                    if(a.SuggestedDealerPrice != null && a.SuggestedDealerPrice != ''){
                        techCO.SuggestedDealerPrice__c = Decimal.valueOf(a.SuggestedDealerPrice);
                    }
                    if(a.SingleorMultipleOrder != null && a.SingleorMultipleOrder != ''){
                        techCO.SingleorMultipleOrder__c = Boolean.valueOf(a.SingleorMultipleOrder);
                    }
                    if(a.Discount_In_Percentage != null && a.Discount_In_Percentage != ''){
                        techCO.Discount_In_Percentage__c = Decimal.valueOf(a.Discount_In_Percentage);
                    }
                    if(a.SuggestedCustomerPrice != null && a.SuggestedCustomerPrice != ''){
                        techCO.SuggestedCustomerPrice__c = Decimal.valueOf(a.SuggestedCustomerPrice);
                    }
                    if(a.RemainingQty != null && a.RemainingQty != ''){
                        techCO.RemainingQty__c = Decimal.valueOf(a.RemainingQty);
                    }
                    if(a.DocumentLineNo != null){
                        techCO.Document_Line_Number__c = Integer.valueOf(a.DocumentLineNo);
                    }
                
                    if (a.IsDeleted == 0 ) {
                        newTCO.add(techCO);
                    }
                }

                if (deleteLineItem.size() > 0) {
                    delete deleteLineItem;
                }
                if (newTCO.size() > 0) {
                    upsert newTCO;
                }

                Enquiry__c exenq= [
                    SELECT Id, Name, Area_Manager__r.Email, Submittedby_Customer__r.Name, Field_Staff_Code__r.Email,Account__r.Name,
                    Enquiry_Name__c, Customer_Name__c, Account__r.Customer_Code__c, Competition_Brand__c, End_Customer_Name__c,
                    Field_Staff_Code__r.Code__c, Source_Of_Price_Feedback__c, Technical_Requirement_Agreed__c, Remarks__c, Date_DD_MM_YYYY__c,
                    Field_Staff_Name__c, Application_Optional__c, Any_Special_Technical_Requirement__c, Valid_Up_To__c,FS_Remarks__c,
                    Area_Manager__r.Name, Field_Staff_Code__r.Name, Area_Manager__c,Field_Staff_Code__c,Account__c,RecordTypeId,Status__c
                    FROM Enquiry__c WHERE Id =: newEnq.Id
                ];

                List <Enquiry_Line_Item__c> exenqli = [
                    SELECT Id, Name, Item_No__c, Item_Description__c, Item_Variant__r.Code__c, Item_Variant__r.UOM__c,
                    Item_Variant__r.Sales_UOM__c, Item_Master__r.Dim_Size__c, Item_Master__r.Item_Category_Code__c,
                    Dealer_Rate__c, Required_Rate_by_AM__c, Approved_Price__c, Qty__c, Standard_Dealer_Rate__c, Discount_In_Percentage__c
                    FROM Enquiry_Line_Item__c WHERE Enquiry__c =: newEnq.Id
                ];

                api_log.Enquiry__c = exenq.Id;

                String managerEmail;
                String fieldStaffEmail;
                
                if (Test.isRunningTest()) {
                    managerEmail = 'huzaifa@finessedirect.com';
                    fieldStaffEmail = 'huzaifa@finessedirect.com';   
                } else {
                    managerEmail = exenq.Area_Manager__r.Email;
                    fieldStaffEmail = exenq.Field_Staff_Code__r.Email;
                }

                if (managerEmail != null && fieldStaffEmail != null) {
                    // Set up the email
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject('Special Rate Document Created');

                    if (managerEmail == fieldStaffEmail) {    
                        email.setToAddresses(new String[] {
                            managerEmail
                        });
                    } else {
                        email.setToAddresses(new String[] {
                            managerEmail, fieldStaffEmail
                        });
                    }

                    // email.setToAddresses(new String[] {
                    //     'shivi.chaturvedi@dnhsecheron.net'
                    // });

                    // Construct the record link URL
                    String newTCOLink = Label.Cust_URL+'/lightning/n/New_Enquiry?c__EnqId='+exenq.Id+'&c__rectypeid='+exenq.RecordTypeId;
                    // String newTCOLink = 'https://dream-inspiration-9915.lightning.force.com/lightning/n/New_Enquiry?c__EnqId='+exenq.Id+'&c__rectypeid='+recordTypeId;

                    String lineItemBody = ''; 
                    for (Enquiry_Line_Item__c v : exenqli) {
                        String litable = 
                        '<tr>' +
                        '<td>'+v.Item_No__c+'</td><td>'+v.Item_Description__c+'</td>' +
                        '<td>'+v.Item_Variant__r.Code__c+'</td><td>'+v.Item_Master__r.Dim_Size__c+'</td>' +
                        '<td>'+v.Item_Variant__r.UOM__c+'</td><td>'+v.Standard_Dealer_Rate__c+'</td><td>'+v.Discount_In_Percentage__c+'</td>' +
                        '<td>'+v.Required_Rate_by_AM__c+'</td><td>'+v.Qty__c+'</td>' +
                        '</tr>';
                        lineItemBody += litable;
                    }

                    // HTML email body
                    String emailBody = '<html>'
                    + '<body>'
                    + '<p>Hi '+exenq.Area_Manager__r.Name+',</p>'
                    + '<p>Please Find Special Rate Document No: <b>'+exenq.Enquiry_Name__c+'</b></p>'
                    + '<table border="1" style="border-collapse:collapse; width:100%;">'
                    + '<tr>'
                    + '<td><b>Document No:</b></td><td>'+exenq.Enquiry_Name__c+'</td>'
                    + '<td><b>Document Date:</b></td><td>'+exenq.Date_DD_MM_YYYY__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>Customer No:</b></td><td>'+exenq.Account__r.Customer_Code__c+'</td>'
                    + '<td><b>Customer Name:</b></td><td>'+exenq.Account__r.Name+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>Competition Brand:</b></td><td>'+exenq.Competition_Brand__c+'</td>'
                    + '<td><b>Application:</b></td><td>'+exenq.Application_Optional__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>End Customer Name:</b></td><td>'+exenq.End_Customer_Name__c+'</td>'
                    + '<td><b>FieldStaff Code:</b></td><td>'+exenq.Field_Staff_Code__r.Code__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>FieldStaff Name:</b></td><td>'+exenq.Field_Staff_Code__r.Name+'</td>'
                    + '<td><b>Technical requirement agreed by TSD or Not:</b></td><td>'+exenq.Technical_Requirement_Agreed__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>Any Special Requirement By Marketing:</b></td><td>'+exenq.Any_Special_Technical_Requirement__c+'</td>'
                    + '<td><b>Remark:</b></td><td>'+exenq.FS_Remarks__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>Source Of Price:</b></td><td>'+exenq.Source_Of_Price_Feedback__c+'</td>'
                    + '</tr>'
                    + '</table>'
                    + '<br/>'
                    + '<table border="1" style="border-collapse:collapse; width:100%;">'
                    + '<thead>'
                    + '<tr>'
                    + '<th>Item NO</th><th>Description</th><th>Variant Code</th>'
                    + '<th>Size</th><th>UOM</th><th>Standard Dealer Price</th>'
                    + '<th>Discount %</th><th>Required Dealer Price</th><th>Qty</th>'
                    + '</tr>'
                    + '</thead>'
                    + '<tbody>'
                    + lineItemBody
                    + '</tbody>'
                    + '</table>'
                    + '<a href="' + newTCOLink + '" target="_blank">'+newTCOLink+'</a>'
                    + '</body>'
                    + '</html>';
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

                System.debug('-->Data Saved Successfully');
                // ------------------- Send the Success Response -------------------
                Map < string, string > successResMap = new Map < string, string > ();
                successResMap.put('status', 'success');
                successResMap.put('message', 'Enquiry Created');
                successResMap.put('EnquiryId', newEnq.Id);
                String resp = JSON.serialize(successResMap);
                response.responseBody = Blob.valueOf(resp);
                response.addHeader('Content-Type', 'application/json');
                response.statusCode = 200;

                api_log.Enquiry__c = newEnq.Id;
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = '200';
                api_log.Response__c = String.valueOf(resp);
                api_log.response_time__c = Datetime.now();

            } else {

                // ------------------- Send the Success Response -------------------
                Map < string, string > successResMap = new Map < string, string > ();
                successResMap.put('message', 'CustomerNo required');

                String resp = JSON.serialize(successResMap);
                response.responseBody = Blob.valueOf(resp);
                response.addHeader('Content-Type', 'application/json');
                response.statusCode = 400;

                api_log.Log_Status__c = 'Failure';
                api_log.Response_Code__c = '400';
                api_log.Response__c = String.valueOf(resp);
                api_log.response_time__c = Datetime.now();

            }

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

    public class JSON2ApexSaveWebToLead {
        public String TCO_Name;
        public String Status;
        public String Date_DD_MM_YYYY;
        public String Competition_Brand;
        public String Application_Optional;
        public String Source_Of_Price_Feedback;
        public String TechnicalReq;
        public String Any_Special_Technical_Requirement;
        public String Remarks;
        public String SubmittedBy;
        public String SubmittedOn;
        public String IsSubmit;
        public String ApprovedOn;
        public String ApprovedBy;
        public String ApprovedRemark;
        public String Deactive;
        public String CustomerNo;
        public String Field_Staff_Code;
        public String Zonal_Head;
        public String Area_Manager;
        public String Valid_Up_To;
        public String UpdatedBy;
        public String UpdatedOn;
        public String ExtensionDate;
        public String OfferStatus;
        public String DnHExtensionDateReamrk;
        public String IsExtendOffer;
        public String IsExpire;
        public String End_Customer_Name;
        public String StatisticsZone;
        public String StatiState;
        public String IschangedPrice;
        public String IsCustomer;
        public String SubmittedByStatus;
        public String IsSubmittedbyCustomer;
        public String IsSubmittedByAM;
        public String PreparedBy;
        
        // public String Technical_Requirement_Agreed;
        // public String FS_Remarks;
        // public String Contact;
        // public String Enquiry_Value;
        // public String Enquiry_Type;
        // public String Enquiry_Stage;
        // public String Enquiry_Clost_Won_Lost_Reason;
        // public String Enquiry_Date;
        // public String Expected_Closure_Date;
        // public String Project_Sales_Type;
        // public String Portal_Source;
        // public String Tender_Download_Date;
        // public String Pre_Bid_Date;
        // public String Submission_Date;
        // public String Opening_Date;
        // public String EMD_Amount;
        // public String Project_Value;
        // public String Project_Description;
        // public String Project_Tender_ID;
        // public String Project_Contact_Designation;
        // public String Project_Department;
        // public String Registration_Compliance_Qualified;
        // public String Delivery_FulFillment_Quantity;
        // public String Product_SKU_Availbality;
        // public String Suggested_Delivery_Date;
        // public String Delivery_FulFillment_by_Date;
        // public String Additional_Information;
        // public String Delivery_FulFillment_by_Quantity;
        // public String Transaction_Type;
        // public String Shipment;
        // public String Commission_Type;
        // public String Other_Terms_Conditions;
        // public String Commission_Value;
        // public String Inco_Terms;
        // public String Inco_Terms_Remark;
        // public String Payment_Terms;
        // public String Other_Payment_Terms;
        // public String Delivery_Terms;
        // public String Other_Delivery_Terms;
        // public String Pricelist;
        // public String IsTCO;
        public List<EnqLineItemClass> TCOItems;
        public List < TCOHeaderAttachments > HeaderAttachment;
    }
    
    public class EnqLineItemClass {
        public String DocumentNo;
        public String Item_Category;
        public String Item_No;
        public String Variant_Code;
        public String Size_mm;
        public String Dealer_Rate;
        public String Qty;
        public String Temp_Line_No;
        public String Deactive;
        public String Standard_Dealer_Rate;
        public String Standard_Private_Rate;
        public String Suggested_Private_Price;
        public String SuggestedDealerPrice;
        public String SingleorMultipleOrder;
        public String Discount_In_Percentage;
        public String SuggestedCustomerPrice;
        public String RemainingQty;
        public Integer DocumentLineNo;
        public Integer IsDeleted;
        
        // public String Order_Qty;
        // public String Item_Master;
        // public String Product_Family;
        // public String Item_Display_Name;
        // public String List_Price;
        // public String Sales_Price;
        // public String Approved_Price;
        // public String Conversion_Factor;
        // public String Conversion_Quantity;
        // public String Dealer_Price;
        // public String Material_Code;
        // public String Requested_Rate_By_Dealer;
        // public String Required_Rate_by_AM;
        // public String Specification;
        // public String HSN_SAC_Code;
        // public String Unit_of_Measure_Code;
        // public String Sync;
    }

    public class TCOHeaderAttachments {
        public String Title;
        public String DocumentLink;
    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }

}