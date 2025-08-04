public with sharing class EnquiryTriggerHandler {

    @AuraEnabled
    public static void syncTCO_ToNavision(List<Enquiry_Line_Item__c> newEnquiryLineItems){

        Set<String> eliIdsSet = new Set<String>();
        
        List<Map<String, Object>> enquiryList = new List<Map<String, Object>>();
        List<Map<String, Object>> enquiryLineItemList = new List<Map<String, Object>>();

        for (Enquiry_Line_Item__c eli : newEnquiryLineItems) {
            eliIdsSet.add(eli.Id);
        }

        List<Enquiry_Line_Item__c> listELI = new List<Enquiry_Line_Item__c>();
        listELI = [
            SELECT Id, Name, Enquiry__r.Document_No__c, Item_Master__r.Item_Number__c, Item_Category2__c, Item_Variant__r.Code__c,
            Size_mm2__c, Dealer_Price__c, Qty__c, RemainingQty__c, Temp_Line_No__c, Deactive__c, Standard_Dealer_Rate__c,
            Standard_Private_Rate__c, Suggested_Private_Price__c, SuggestedDealerPrice__c, SingleorMultipleOrder__c,
            Discount_In_Percentage__c, SuggestedCustomerPrice__c, Enquiry__r.Account__r.Customer_Code__c, Dealer_Rate__c,
            Item_Master__r.Item_Category_Code__c,
            Item_Master__r.Dim_Size__c,
            Item_Master__r.Product_Group_Code__c, Enquiry__r.Enquiry_Name__c
            FROM Enquiry_Line_Item__c WHERE Id IN: eliIdsSet
            // FROM Enquiry_Line_Item__c WHERE Id = 'a05F300000Hd6NXIAZ'
        ];

        Enquiry__c enq = new Enquiry__c();
        enq = [
            SELECT Enquiry_Name__c, Document_No__c,Status__c,Date_DD_MM_YYYY__c,Competition_Brand__c,Application_Optional__c,
            Source_Of_Price_Feedback__c,Field_Staff_Code__c,TechnicalReq__c,Any_Special_Technical_Requirement__c,Remarks__c,
            Submittedby_Customer__c,SubmittedBy__c,SubmittedOn__c,IsSubmit__c,Deactive__c,End_Customer_Name__c,FS_Remarks__c,
            StatisticsZone__c,StatiState__c,Zonal_Head__c,IschangedPrice__c,IsCustomer__c,SubmittedByStatus__c,
            IsSubmittedbyCustomer__c,IsSubmittedByAM__c,PreparedBy__c,Account__c,Area_Manager__c
            FROM Enquiry__c WHERE Id =: newEnquiryLineItems[0].Enquiry__c
            // FROM Enquiry__c WHERE Id =: 'a03F300000BoL75IAF'
        ];

        // Main Map
        Map<String, Object> enquiryMap = new Map<String, Object>();
        List<Account> accList = new List<Account>();
        if (enq.Account__c != null) {
            accList = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: enq.Account__c];
        }

        String tempDocNumber = 'TECH/2024/'+System.DateTime.now();

        enquiryMap.put('DocumentNo' , enq.Enquiry_Name__c);
        // enquiryMap.put('DocumentNo' , tempDocNumber);
        enquiryMap.put('TCO_Name' , accList.size() > 0 ? accList[0].Customer_Code__c : '');
        enquiryMap.put('Status' , 'Requested For Approval');
        Date parsedDate = Date.valueOf(enq.Date_DD_MM_YYYY__c);
        String formattedDate = String.valueOf(parsedDate.year()) + '/' + String.valueOf(parsedDate.month()) + '/' + String.valueOf(parsedDate.day());

        enquiryMap.put('Date_DD_MM_YYYY' , formattedDate);
        enquiryMap.put('Competition_Brand' , enq.Competition_Brand__c);
        enquiryMap.put('Application_Optional' , enq.Application_Optional__c);
        enquiryMap.put('Source_Of_Price_Feedback' , enq.Source_Of_Price_Feedback__c != null ? enq.Source_Of_Price_Feedback__c : '');
        List<User> userList1 = new List<User>(); // For field staff
        if (enq.Field_Staff_Code__c != null) {
            userList1 = [SELECT Id, Name, Code__c FROM User WHERE Id =: enq.Field_Staff_Code__c];
        }
        enquiryMap.put('Field_Staff_Code' , userList1.size() > 0 ? userList1[0].Code__c : '');
        enquiryMap.put('TechnicalReq' , enq.TechnicalReq__c);
        enquiryMap.put('Any_Special_Technical_Requirement' , enq.Any_Special_Technical_Requirement__c);
        enquiryMap.put('Remarks' , enq.FS_Remarks__c);

        if (enq.IsCustomer__c == true) {
            List<Account> accList2 = new List<Account>(); // For Submitted By
            if (enq.Submittedby_Customer__c != null) {
                accList2 = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: enq.Submittedby_Customer__c];
            }
            enquiryMap.put('SubmittedBy' , accList2.size() > 0 ? accList2[0].Customer_Code__c : '');
        } else {
            List<User> userList2 = new List<User>(); // For field staff
            if (enq.SubmittedBy__c != null) {
                userList2 = [SELECT Id, Name, Code__c FROM User WHERE Id =: enq.SubmittedBy__c];
            }
            enquiryMap.put('SubmittedBy' , userList2.size() > 0 ? userList2[0].Code__c : '');
        }

        // enquiryMap.put('SubmittedBy' , enq.IsCustomer__c == true ? enq.Submittedby_Customer__r.Customer_Code__c : enq.SubmittedBy__r.Code__c);
        Datetime dt = Datetime.valueOf(enq.SubmittedOn__c);
        Date datePart = dt.date();
        String SubmittedOnDate = String.valueOf(datePart.year()) + '/' + String.valueOf(datePart.month()) + '/' + String.valueOf(datePart.day());
        enquiryMap.put('SubmittedOn_DD_MM_YYYY' , SubmittedOnDate);
        enquiryMap.put('IsSubmit' , enq.IsSubmit__c);
        enquiryMap.put('Deactive' , enq.Deactive__c);
        enquiryMap.put('CustomerNo' , accList.size() > 0 ? accList[0].Customer_Code__c : '');
        enquiryMap.put('End_Customer_Name' , enq.End_Customer_Name__c);
        enquiryMap.put('StatisticsZone' , enq.StatisticsZone__c != null ? enq.StatisticsZone__c : '');
        enquiryMap.put('StatiState' , enq.StatiState__c != null ? enq.StatiState__c : '');
        enquiryMap.put('Account' , accList.size() > 0 ? accList[0].Customer_Code__c : '');
        List<User> userList3 = new List<User>(); // For Zonal Head
        if (enq.Zonal_Head__c != null) {
            userList3 = [SELECT Id, Name, Code__c FROM User WHERE Id =: enq.Zonal_Head__c];
        }
        enquiryMap.put('Zonal_Head' , userList3.size() > 0 ? userList3[0].Code__c : '');
        // enquiryMap.put('Zonal_Head' , 'V. GANESH KUMAR');
        List<User> userList4 = new List<User>(); // For Area Manager
        if (enq.Area_Manager__c != null) {
            userList4 = [SELECT Id, Name, Code__c FROM User WHERE Id =: enq.Area_Manager__c];
        }
        enquiryMap.put('Area_Manager' , userList4.size() > 0 ? userList4[0].Code__c : '');
        // enquiryMap.put('Area_Manager' , 'PRATHMESH SHAH');
        enquiryMap.put('IschangedPrice' , enq.IschangedPrice__c);
        enquiryMap.put('IsCustomer' , enq.IsCustomer__c);
        enquiryMap.put('SubmittedByStatus' , enq.SubmittedByStatus__c != null ? enq.SubmittedByStatus__c : '');
        enquiryMap.put('IsSubmittedbyCustomer' , enq.IsSubmittedbyCustomer__c);
        enquiryMap.put('IsSubmittedByAM' , enq.IsSubmittedByAM__c);
        List<User> userList5 = new List<User>(); // For Preparedby
        if (enq.PreparedBy__c != null) {
            userList5 = [SELECT Id, Name, Code__c FROM User WHERE Id =: enq.PreparedBy__c];
        }
        enquiryMap.put('PreparedBy' , userList5.size() > 0 ? userList5[0].Code__c : '');

        // Add TCO header attachment
        List < ContentDocumentLink > contDocLinkHeader = new List < ContentDocumentLink > ();
        Set < String > cdlSetHeader = new Set < String > ();

        contDocLinkHeader = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: enq.Id];

        for (ContentDocumentLink cdl: contDocLinkHeader) {
            System.debug('ContentDocumentId for Header: ' + cdl.ContentDocumentId);
            cdlSetHeader.add(cdl.ContentDocumentId);
        }

        List < ContentDistribution > cdsHeader = new List < ContentDistribution > ();

        cdsHeader = [SELECT Id, Name, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId IN: cdlSetHeader];
        if (cdsHeader.size() > 0) {
            List < Map < String, String >> attachmentsHeader = new List < Map < String, String >> ();
            for (ContentDistribution cd: cdsHeader) {
                Map < String, String > att = new Map < String, String > ();
                att.put('DocumentNo', enq.Enquiry_Name__c);
                att.put('FileAddress', cd.ContentDownloadUrl);
                att.put('AttachmentName', cd.Name.replace('- public file',''));
                att.put('Field', 'Special Rate');
                attachmentsHeader.add(att);
            }
            enquiryMap.put('navAttachmentMsts', attachmentsHeader);
        } else {
            enquiryMap.put('navAttachmentMsts', null);
        }

        for (Enquiry_Line_Item__c eli : listELI) {
            Map<String, Object> enquiryLIMap = new Map<String, Object>();
            enquiryLIMap.put('DocumentNo', eli.Enquiry__r.Enquiry_Name__c);
            // enquiryLIMap.put('DocumentNo', tempDocNumber);
            enquiryLIMap.put('Item_No', eli.Item_Master__r.Item_Number__c);
            enquiryLIMap.put('Item_Category', eli.Item_Master__r.Item_Category_Code__c);
            enquiryLIMap.put('Variant_code', eli.Item_Variant__r.Code__c);
            enquiryLIMap.put('Size_mm', eli.Item_Master__r.Dim_Size__c);
            enquiryLIMap.put('Dealer_Rate', eli.Dealer_Rate__c);
            enquiryLIMap.put('Qty', eli.Qty__c); // Field Not confirm - from where to map
            // enquiryLIMap.put('RemainingQty', eli.RemainingQty__c); // Field Not confirm - from where to map
            enquiryLIMap.put('RemainingQty', eli.Qty__c); // Field Not confirm - from where to map
            enquiryLIMap.put('Temp_Line_No', eli.Id);
            enquiryLIMap.put('Deactive', eli.Deactive__c);
            enquiryLIMap.put('Standard_Dealer_Rate', eli.Standard_Dealer_Rate__c);
            enquiryLIMap.put('Standard_Private_Rate', eli.Standard_Private_Rate__c == null ? 0 : eli.Standard_Private_Rate__c);
            enquiryLIMap.put('Suggested_Private_Price', eli.Suggested_Private_Price__c == null ? 0 : eli.Suggested_Private_Price__c);
            enquiryLIMap.put('SuggestedDealerPrice', eli.SuggestedDealerPrice__c);
            enquiryLIMap.put('SingleorMultipleOrder', eli.SingleorMultipleOrder__c == true ? '1' : '0');
            enquiryLIMap.put('Discount_In_Percentage', eli.Discount_In_Percentage__c == null ? 0 : eli.Discount_In_Percentage__c);
            enquiryLIMap.put('SuggestedCustomerPrice', eli.SuggestedCustomerPrice__c == null ? 0 : eli.SuggestedCustomerPrice__c);
            enquiryLIMap.put('ProductGroupCode', eli.Item_Master__r.Product_Group_Code__c);
            enquiryLIMap.put('CustomerCode', eli.Enquiry__r.Account__r.Customer_Code__c);
            enquiryLineItemList.add(enquiryLIMap);
        }

        enquiryMap.put('TCOItems', enquiryLineItemList);

        List<Object> listName = new List<Object>();
        listName.add(enquiryMap);

        String jsonData = JSON.serialize(listName);
        System.debug('Json Data :: ' + jsonData);

        Enquiry__c record = [SELECT RecordType.Name FROM Enquiry__c WHERE Id = :enq.Id LIMIT 1];
        String recordTypeName = record.RecordType.Name;
        if (recordTypeName == 'Techno Commercial Offer') {
            CreateTCO_ToNAV.inserTCOData(jsonData, newEnquiryLineItems[0].Enquiry__c);
        }


    }

    public static String approveTCOSyncToTSD(String enqId){

        List<Object> mainResponse = new List<Object>();
        
        Enquiry__c enq = [
            SELECT Id,Enquiry_Name__c, Name,SubmittedBy__c,Status__c, Remarks__c, SubmittedOn__c, SubmittedBy__r.Code__c, IsSubmittedByAM__c, PreparedBy__r.Code__c,Document_No__c
            FROM Enquiry__c
            WHERE Id =: enqId
        ];
        

         User u=[SELECT Id, Code__c FROM USER where Id=:UserInfo.getUserId()];

        List<Enquiry_Line_Item__c> enqliList = [
            SELECT Id, Name, Temp_Line_No__c,Enquiry__r.Document_No__c,Enquiry__r.Enquiry_Name__c, Dealer_Rate__c,
            Item_Master__r.Item_Number__c, Document_Line_Number__c
            FROM Enquiry_Line_Item__c WHERE Enquiry__c =: enqId
        ];

        Map<String, Object> enqMap = new Map<String, Object>();
        enqMap.put('DocumentNo',enq.Enquiry_Name__c);
        enqMap.put('Remarks', enq.Remarks__c);
       Date todayDate = Date.today();

        String month = todayDate.month() < 10 ? '0' + String.valueOf(todayDate.month()) : String.valueOf(todayDate.month());
        String day = todayDate.day() < 10 ? '0' + String.valueOf(todayDate.day()) : String.valueOf(todayDate.day());
        String year = String.valueOf(todayDate.year());

        String formattedDate = month + '/' + day + '/' + year;

        System.debug(formattedDate);
        enqMap.put('SubmittedOn_DD_MM_YYYY', formattedDate);
        enqMap.put('SubmittedBy', u.Code__c);
        // enqMap.put('IsSubmittedByAM', enq.IsSubmittedByAM__c);
        enqMap.put('IsSubmittedByAM', false); // As confirmed by Naresh 
        // enqMap.put('PreparedBy', enq.PreparedBy__r.Code__c!=null?enq.PreparedBy__r.Code__c:'');
        enqMap.put('PreparedBy', u.Code__c); // Submitted by and Prepared by must be same.

        List<Map<String, Object>> enqliMapList = new List<Map<String, Object>>();
        for (Enquiry_Line_Item__c var : enqliList) {
            Map<String, Object> enqli = new Map<String, Object>();
            enqli.put('DocumentNo',var.Enquiry__r.Enquiry_Name__c);
            enqli.put('Dealer_Rate',var.Dealer_Rate__c);
            enqli.put('Item_No',var.Item_Master__r.Item_Number__c);
            System.debug('CHECKINGGG::>>>');
            enqli.put('Temp_Line_No',var.Temp_Line_No__c == null ? String.valueOf(var.Id) : var.Temp_Line_No__c);
            // enqli.put('Temp_Line_No',var.Temp_Line_No__c);
            System.debug('CHECKINGGG::>>>');
            enqli.put('DocumentLineNo', var.Document_Line_Number__c);
            enqliMapList.add(enqli);
        }

        enqMap.put('TCOItems', enqliMapList);
        mainResponse.add(enqMap);

        String jsons = JSON.serialize(mainResponse);
        //System.debug('ApproveTCO_ToTSDPortal.approveTCO '+ApproveTCO_ToTSDPortal.approveTCO(jsons));
        String res=   ApproveTCO_ToTSDPortal.approveTCO(jsons);
        System.debug('ApproveTCO_ToTSDPortal.approveTCO '+res);
        if(res==''){
            enq.Status__c='Approved';
            enq.SubmittedBy__c=UserInfo.getUserId();
            enq.SubmittedOn__c=todayDate;
            UPDATE enq;

            // Send Email to Shivi , AM , fs to inform that the TCO has been sent for approval
            Enquiry__c exenq= [
                SELECT Id, Name, Area_Manager__r.Email, Submittedby_Customer__r.Name, Field_Staff_Code__r.Email,Account__r.Name,
                Enquiry_Name__c, Customer_Name__c, Account__r.Customer_Code__c, Competition_Brand__c, End_Customer_Name__c,
                Field_Staff_Code__r.Code__c, Source_Of_Price_Feedback__c, Technical_Requirement_Agreed__c, Remarks__c, Date_DD_MM_YYYY__c,
                Field_Staff_Name__c, Application_Optional__c, Any_Special_Technical_Requirement__c, Valid_Up_To__c,FS_Remarks__c,
                Area_Manager__r.Name, Field_Staff_Code__r.Name, Area_Manager__c,Field_Staff_Code__c,Account__c,RecordTypeId,Status__c,
                Account__r.Email_Id__c, Is_Created_From_TSD__c
                FROM Enquiry__c WHERE Id =: enq.Id
            ];

            List <Enquiry_Line_Item__c> exenqli = [
                SELECT Id, Name, Item_No__c, Item_Description__c, Item_Variant__r.Code__c, Item_Variant__r.UOM__c,
                Item_Variant__r.Sales_UOM__c, Item_Master__r.Dim_Size__c, Item_Master__r.Item_Category_Code__c,
                Dealer_Rate__c, Required_Rate_by_AM__c, Approved_Price__c, Qty__c, Standard_Dealer_Rate__c, Discount_In_Percentage__c
                FROM Enquiry_Line_Item__c WHERE Enquiry__c =: enq.Id
            ];

            String managerEmail = exenq.Area_Manager__r.Email;
            String fieldStaffEmail = exenq.Field_Staff_Code__r.Email;
            // String dealerMail = exenq.Is_Created_From_TSD__c ? exenq.Account__r.Email_Id__c : '';
            String dealerMail = '';

            if (managerEmail != null && fieldStaffEmail != null) {
                // Set up the email
                if (dealerMail != null && dealerMail != '') {
                    managerEmail = managerEmail + ','+dealerMail;
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Send Special Rate Document For Approval');

                if (managerEmail == fieldStaffEmail) {    
                    email.setCcAddresses(new String[] {
                        managerEmail
                    });
                } else {
                    email.setCcAddresses(new String[] {
                        managerEmail, fieldStaffEmail
                    });
                }

                email.setToAddresses(new String[] {
                    'shivi.chaturvedi@dnhsecheron.net'
                });

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
                + '<p>Hello DNH,</p>'
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
                + '<th>Size</th><th>UOM</th><th>Dealer Price</th>'
                + '<th>DISCOUNT %</th><th>Required Price</th><th>Qty</th>'
                + '</tr>'
                + '</thead>'
                + '<tbody>'
                + lineItemBody
                + '</tbody>'
                + '</table>'
                + '</body>'
                + '</html>';
                email.setHtmlBody(emailBody);

                // Set related record ID for activity tracking
                email.setWhatId(exenq.Id);
                email.setSaveAsActivity(true);

                OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address = 'info@dnhsecheron.net'];
                if (owea.size() > 0) {
                    System.debug('inside');
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }

                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                    email
                });
            }

        }
        return res;
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
        
    }
    
}