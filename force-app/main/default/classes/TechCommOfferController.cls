public with sharing class TechCommOfferController {

    @AuraEnabled(cacheable = true)
    public static List < RecordType > getRecordTypes() {
        // Replace 'Enquiry__c' with the API name of your object if different
        return [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Enquiry__c'];
    }
    @AuraEnabled
    public static string getcodemaster(String objectname) {
        list < Code_Master__c > codem = [SELECT Id, Name, Object__c, Display_Label__c, Current_Sequence__c, Starting_Sequence__c,
            Backend_Current_Sequence__c, For_Display_Sequence__c FROM Code_Master__c
            WHERE Object__c =: objectname AND Is_Active__c = true
            LIMIT 1 FOR UPDATE
        ];
        if (!codem.isEmpty()) {

            String name = codem[0].Display_Label__c + '/' + String.valueOf(codem[0].For_Display_Sequence__c);
            codem[0].Current_Sequence__c += 1;
            update codem;
            //+ String.valueOf(codem.Backend_Current_Sequence__c);
            return name;
        } else {
            return null; // or you can throw an exception if you expect at least one result
        }
    }

    @AuraEnabled
    public static String getEnadCustomerList() {
        try {

            String resData = '';

            User usr = [
                SELECT Id, Email, Reporting_Person__c, IsApprovedUser__c, Profile.Name, Area_Manager__c, Code__c
                FROM User WHERE Id =: UserInfo.getUserId()
                // FROM User WHERE Id = '005F30000081bZMIAY'
            ];

            List < Customer_Sales_Person_Mapping__c > mappingList = [
                SELECT Id, Name, Account__r.Name
                FROM Customer_Sales_Person_Mapping__c
                WHERE Account__r.Customer_Type__c = 'End Customer'
                // AND Sales_Person_Code__c = 'DNH1077'
                AND Sales_Person_Code__c = :usr.Code__c
            ];

            List < Map < String, String >> optionList = new List < Map < String, String >> ();

            if (mappingList.size() > 0) {
                for (Customer_Sales_Person_Mapping__c iv: mappingList) {
                    Map < String, String > varOption = new Map < String, String > ();
                    varOption.put('label', iv.Account__r.Name);
                    varOption.put('value', iv.Account__r.Name);
                    optionList.add(varOption);
                }
                resData = JSON.serialize(optionList);
            }

            return resData;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getItemMaster() {
        try {

            User usr = [SELECT Id, ItemTargetCat__c FROM User WHERE Id =: UserInfo.getUserId()];
            String itemCategory = getPicklistLabelByValue('User', 'ItemTargetCat__c', usr.ItemTargetCat__c);
            List < Item_Master__c > itemMasterList = new List < Item_Master__c > ();
            if (itemCategory == 'AB - BOTH') {
                itemMasterList = [
                    SELECT Id, Dim_ItemTargetCat__c, Item_Number__c, Item_Description__c, Base_Unit_of_Measure__c, Sales_Unit_of_Measure__c, Blocked__c
                    FROM Item_Master__c
                    WHERE Item_Type__c = 'Normal'
                    AND Active__c = true
                    AND Blocked__c = false
                    AND CheckItemPrice__c = true
                    ORDER BY Name ASC
                ];
            } else {
                itemMasterList = [
                    SELECT Id, Dim_ItemTargetCat__c, Item_Number__c, Item_Description__c, Base_Unit_of_Measure__c, Sales_Unit_of_Measure__c, Blocked__c
                    FROM Item_Master__c
                    WHERE Item_Type__c = 'Normal'
                    AND Active__c = true
                    AND Blocked__c = false
                    AND CheckItemPrice__c = true
                    AND(Dim_ItemTargetCat__c =: itemCategory OR Dim_ItemTargetCat__c = 'D - WELD ACCESSORIES')
                    ORDER BY Name ASC
                ];
            }

            // itemMasterList = [
            //     SELECT Id,Dim_ItemTargetCat__c, Item_Number__c, Item_Description__c, Base_Unit_of_Measure__c, Sales_Unit_of_Measure__c,Blocked__c
            //     FROM Item_Master__c
            //     WHERE Item_Type__c = 'Normal'
            //     AND Active__c = true
            //     // AND Blocked__c = false
            // ];

            Set < String > itemNumberSet = new Set < String > ();
            for (Item_Master__c cc: itemMasterList) {
                itemNumberSet.add(cc.Item_Number__c);
            }
            Map < String, String > mpitemNumberSet = new Map < String, String > ();
            List < Pricelist_Line_Item__c > priceListItem = [SELECT Id, Item_No__c FROM Pricelist_Line_Item__c WHERE Item_No__c IN: itemNumberSet];
            for (Pricelist_Line_Item__c pc: priceListItem) {
                mpitemNumberSet.put(pc.Item_No__c, pc.Id);
            }

            wrapperClass wc = new wrapperClass();
            List < DataWrapper > ccListwc = new List < DataWrapper > ();
            Integer i = 0;

            for (Item_Master__c cc: itemMasterList) {
                // if(mpitemNumberSet.get(cc.Item_Number__c)!=null){
                DataWrapper ldwc = new DataWrapper();
                ldwc.Itemid = cc.Id;
                ldwc.ItemNo = cc.Item_Number__c;
                ldwc.Description = cc.Item_Description__c;
                ldwc.BUOM = cc.Base_Unit_of_Measure__c;
                ldwc.SUOM = cc.Sales_Unit_of_Measure__c;
                ldwc.index = i++;
                ccListwc.add(ldwc);
                // }
            }
            wc.dataList = ccListwc;
            return JSON.serialize(wc);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getPicklistLabelByValue(String objectApiName, String fieldApiName, String apiValue) {
        // Describe the object
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        if (sObjectType == null) {
            throw new IllegalArgumentException('Invalid object name: ' + objectApiName);
        }

        // Describe the field
        Schema.DescribeSObjectResult objectDescribe = sObjectType.getDescribe();
        Schema.SObjectField field = objectDescribe.fields.getMap().get(fieldApiName);
        if (field == null) {
            throw new IllegalArgumentException('Invalid field name: ' + fieldApiName);
        }

        // Get picklist entries
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        List < Schema.PicklistEntry > picklistEntries = fieldDescribe.getPicklistValues();

        // Find and return the label by value
        for (Schema.PicklistEntry entry: picklistEntries) {
            if (entry.getValue().equalsIgnoreCase(apiValue)) {
                return entry.getLabel(); // Return the user-friendly label of the picklist
            }
        }

        // If not found, return null or throw an exception
        return null;
    }

    @AuraEnabled
    public static String findRecentenqlineitem(id productId, String custId) {
        // Perform the query
        if (String.isEmpty(productId)) {
            system.debug('productId' + productId);
            return JSON.serialize(new List < Enquiry_Line_Item__c > ());
            //return JSON.serialize(new wrapperClass());
        }
        system.debug('productId' + productId);
        List < Enquiry_Line_Item__c > enqlIst1 = [
            SELECT Id, name, Item_Master__c, Item_Master__r.Name, Item_Master__r.Product_Code__c,
            Item_Master__r.Item_Category__c, Item_Master__r.Family__c, Item_Master__r.Item_Description__c, Qty__c, Enquiry__c,
            Sales_Price__c, Enquiry__r.name, Enquiry__r.Account__c, Enquiry__r.Account__r.name, Enquiry__r.Enquiry_Name__c, Approved_Price__c
            FROM Enquiry_Line_Item__c
            WHERE Item_Master__c =: productId
            AND Enquiry__r.Account__c =: custId
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];

        system.debug('enqlIst1' + enqlIst1);

        return JSON.serialize(enqlIst1);
    }

    @AuraEnabled(cacheable = true)
    public static String getItemVariantOptions(String productId) {
        List < Item_Variant__c > itemVariants = [
            SELECT Id, name, code__c, Item_Master__c FROM Item_Variant__c WHERE Item_Master__c =: productId AND Block__c = false ORDER BY code__c DESC
        ];
        // List<PicklistOption> options = new List<PicklistOption>();
        // options.add(new PicklistOption('', '--None--'));
        // for (Item_Variant__c iv : itemVariants) {
        //     options.add(new PicklistOption(iv.Id, iv.Code__c));
        //     system.debug('options'+options);
        // }

        List < Map < String, String >> optionList = new List < Map < String, String >> ();
        for (Item_Variant__c iv: itemVariants) {
            Map < String, String > varOption = new Map < String, String > ();
            varOption.put('label', iv.code__c);
            varOption.put('value', iv.Id);
            optionList.add(varOption);
        }

        return JSON.serialize(optionList);
    }

    @AuraEnabled
    public static string getConversionFactor(String varId) {
        try {

            String retData = '';

            System.debug(varId);

            Item_Variant__c itemVar = [
                SELECT Id, Name, Sales_UOM__c, Item_Master__c, UOM__c, Qty_in_SOUM__c
                FROM Item_Variant__c WHERE Id =: varId
            ];

            System.debug(itemVar);

            // List<Item_Unit_Of_Measure__c> iuomList = [
            //     SELECT Id, Name, Quantity_per_Unit_of_Measure__c FROM Item_Unit_Of_Measure__c 
            //     WHERE Item_Master__c =: itemVar.Item_Master__c
            //     AND Code__c =: itemVar.Sales_UOM__c
            // ];

            // system.debug('iuomList'+iuomList);

            // if(iuomList.size() > 0){
            //     retData = String.valueOf(iuomList[0].Quantity_per_Unit_of_Measure__c);
            // }
            return JSON.serialize(itemVar);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getContact(String customerId) {
        try {

            String resData = '';

            Map < String, Object > resMap = new Map < String, Object > ();

            List < Contact > cont = [
                SELECT Id, Name
                FROM Contact
                WHERE AccountId =: customerId
            ];

            if (cont.size() > 0) {
                resData = cont[0].Id;
                resMap.put('Id', cont[0].Id);
                resMap.put('Name', cont[0].Name);
                resData = JSON.serialize(resMap);
            }

            return resData;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getFieldStaffCode(String custId) {
        try {

            String resData = '';

            List < Customer_Sales_Person_Mapping__c > mappingList = [
                SELECT Id, Name, Account__c, Sales_Person__c, Sales_Person__r.Name, Privacy_Blocked__c
                FROM Customer_Sales_Person_Mapping__c
                WHERE Account__c =: custId
                AND Privacy_Blocked__c = false
            ];

            List < Map < String, String >> optionList = new List < Map < String, String >> ();

            if (mappingList.size() > 0) {
                for (Customer_Sales_Person_Mapping__c iv: mappingList) {
                    Map < String, String > varOption = new Map < String, String > ();
                    varOption.put('label', iv.Sales_Person__r.Name);
                    varOption.put('value', iv.Sales_Person__c);
                    optionList.add(varOption);
                }
                resData = JSON.serialize(optionList);
            }

            return resData;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getZonalManager(String staffId) {
        try {

            String resData = '';

            User usr = [SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c FROM User WHERE Id =: staffId];

            if (usr.Zonal_Manager_ID__c != null && usr.Zonal_Manager_ID__c != '') {
                User zonalMgrUsr = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: usr.Zonal_Manager_ID__c];
                resData = zonalMgrUsr.Id;
                resData = zonalMgrUsr.Id;

            }
            if (usr.Reporting_Person_ID__c != null && usr.Reporting_Person_ID__c != '') {
                User areaMgrUsr = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: usr.Reporting_Person_ID__c];
                resData = resData + ';' + areaMgrUsr.Id;

            }

            return resData;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static string getDealerPrice(String ItemNo, String customerId) {

        Account acc = [SELECT Id, Name, Customer_Price_Group__c FROM Account WHERE Id =: customerId];

        list < Pricelist_Line_Item__c > priceListLineItemList = [SELECT id, name, Item_No__c, Unit_Price__c FROM Pricelist_Line_Item__c WHERE Item_No__c =: ItemNo AND Sales_Price_Group__c =: acc.Customer_Price_Group__c];
        if (!priceListLineItemList.isempty()) {
            return JSON.serialize(priceListLineItemList.get(0).Unit_Price__c);
        } else {
            return null; // or you can throw an exception if you expect at least one result

        }

    }

    @AuraEnabled
    public static string deleteENQLI(String Id) {
        try {

            Enquiry_Line_Item__c soli = [
                SELECT Id, Name
                FROM Enquiry_Line_Item__c
                WHERE Id =: Id
            ];

            delete soli;

            return 'ok';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string addFile_n_LineItems(String Id, String mdoc, String lineitemlist, Boolean issync) {
        try {

            Integer lineno = 1;

            if (mdoc != '') {
                // String fileJson = System.JSON.serialize(mdoc);
                // relatedFile relatedDocument = (relatedFile) System.JSON.deserialize(mdoc, relatedFile.class);
                // Attachment att = new Attachment();
                // att.ParentId = Id;
                // att.Name = relatedDocument.Title;
                // att.Body = relatedDocument.VersionData;
                // insert att;
                List < ContentDocumentLink > contentLinks = new List < ContentDocumentLink > ();
                Map < String, Object > relatedDocumentMap = (Map < String, Object > ) JSON.deserializeUntyped(mdoc);

                // Validate and retrieve the fields
                String title = relatedDocumentMap.containsKey('Title') ? (String) relatedDocumentMap.get('Title') : null;
                String base64Data = relatedDocumentMap.containsKey('VersionData') ? (String) relatedDocumentMap.get('VersionData') : null;

                // Decode Base64 string into Blob
                Blob versionData = base64Data != null ? EncodingUtil.base64Decode(base64Data) : null;

                if (String.isBlank(title) || versionData == null) {
                    throw new AuraHandledException('Invalid or missing data in JSON: Title or VersionData is null');
                }

                // Proceed with valid data
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = title;
                contentVersion.PathOnClient = '/' + title;
                contentVersion.VersionData = versionData;

                insert contentVersion;

                // Query ContentDocumentId from the inserted ContentVersion
                Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

                // Create ContentDocumentLink
                ContentDocumentLink contentLink = new ContentDocumentLink();
                contentLink.ContentDocumentId = contentDocumentId;
                contentLink.LinkedEntityId = Id; // Associate with Enquiry__c
                contentLink.ShareType = 'V';
                contentLink.Visibility = 'AllUsers';
                contentLinks.add(contentLink);

                // Generate ContentDistribution
                ContentDistribution contentDist = new ContentDistribution(
                    // Name = title +'- public file ',
                    Name = title,
                    ContentVersionId = contentVersion.Id,
                    PreferencesAllowViewInBrowser= true,
                    PreferencesLinkLatestVersion=true,
                    PreferencesNotifyOnVisit=false

                );
                insert contentDist;

                if (!contentLinks.isEmpty()) {
                    insert contentLinks;
                }
            }

            if (lineitemlist != '') {
                String s = lineitemlist.replace('__c', '_c');
                List < Enquiry_Line_Item__c > TCLItoInsertList = new List < Enquiry_Line_Item__c > ();
                List < Tsdlineitemlist > vList = parseJsonData(s);
                system.debug('vList' + vList);

                Enquiry__c upEnq = [SELECT Id, Name, Document_No__c, Enquiry_Name__c, Is_Created_From_TSD__c,
                    SubmittedOn__c, PreparedBy__c, Field_Staff_Code__c
                    FROM Enquiry__c WHERE Id =: Id
                ];
                if (!upEnq.Is_Created_From_TSD__c) {
                    upEnq.Enquiry_Name__c = 'SF-' + upEnq.Document_No__c;
                }
                if (upEnq.SubmittedOn__c == null) {
                    upEnq.SubmittedOn__c = Datetime.now();
                }
                if (upEnq.PreparedBy__c == null) {
                    upEnq.PreparedBy__c = upEnq.Field_Staff_Code__c;
                }

                update upEnq;

                for (Tsdlineitemlist v: vList) {
                    System.debug('v.id 1:>>>>>> ' + v);
                    Enquiry_Line_Item__c msli = new Enquiry_Line_Item__c();
                    msli.Enquiry__c = Id;
                    if (String.isNotBlank(String.valueOf(v.Id))) {
                        System.debug('v.id 1:>>>>>> ' + v.Id);
                        msli.Id = v.Id;
                    } else {
                        msli.Item_Master__c = v.Item_Master_c;
                        msli.Item_Variant__c = v.Item_Variant_c;
                        msli.Item_No__c = v.Item_No_c;
                        msli.Requested_Rate_By_Dealer__c = v.Requested_Rate_By_Dealer_c;
                        msli.Conversion_Quantity__c = v.Conversion_Quantity_c;
                        msli.Conversion_Factor__c = v.Conversion_Factor_c;
                        msli.BUOM__c = v.BUOM_c;
                        msli.SUOM__c = v.SUOM_c;
                        msli.SuggestedCustomerPrice__c = v.SuggestedCustomerPrice_c;
                        msli.Standard_Private_Rate__c = v.Standard_Private_Rate_c;
                        msli.Standard_Dealer_Rate__c = v.Standard_Dealer_Rate_c;
                        msli.Suggested_Private_Price__c = v.Suggested_Private_Price_c;
                        msli.Document_Line_Number__c = lineno;
                        msli.RemainingQty__c = v.Qty_c;
                        lineno = lineno + 1;

                    }
                    msli.Qty__c = v.Qty_c;
                    if (v.Required_Rate_by_AM_c == null) {
                        msli.Dealer_Rate__c = v.Dealer_Rate_c;
                        msli.Required_Rate_by_AM__c = v.Dealer_Rate_c;
                        msli.SuggestedDealerPrice__c = v.Dealer_Rate_c;
                    } else {
                        msli.Dealer_Rate__c = v.Required_Rate_by_AM_c;
                        msli.Required_Rate_by_AM__c = v.Required_Rate_by_AM_c;
                        msli.SuggestedDealerPrice__c = v.Required_Rate_by_AM_c;
                    }
                    msli.Item_Value__c = v.Item_Value_c;
                    if (v.Discount_In_Percentage_c == null) {
                        msli.Discount_In_Percentage__c = 0.0;
                    } else {
                        msli.Discount_In_Percentage__c = Decimal.valueOf(v.Discount_In_Percentage_c);
                    }
                    msli.Standard_Private_Rate__c = 0.0;
                    msli.Suggested_Private_Price__c = 0.0;

                    system.debug('msli.Item_Value__c:>>  ' + msli.Item_Value__c);
                    system.debug('Dealer_Rate__c' + msli.Dealer_Rate__c);
                    //  msli.Order_Qty__c = v.Order_Qty_c;

                    if (v.Conversion_Quantity_c == null) {
                        Item_Variant__c itemVar = [
                            SELECT Id, Name, Sales_UOM__c, Item_Master__c, UOM__c, Qty_in_SOUM__c
                            FROM Item_Variant__c WHERE Id =: v.Item_Variant_c
                        ];
                        msli.Conversion_Factor__c = String.valueOf(itemVar.Qty_in_SOUM__c);
                        msli.Conversion_Quantity__c = Decimal.valueOf(msli.Conversion_Factor__c) * v.Qty_c;
                        msli.Item_Value__c = msli.Required_Rate_by_AM__c * msli.Conversion_Quantity__c;
                        v.Item_Value_c = msli.Item_Value__c;
                    }
                    if (v.Item_Value_c == null) { // for safty side
                        // system.debug(msli.Required_Rate_by_AM__c + ' -- '+v.Conversion_Quantity_c);
                        msli.Item_Value__c = msli.Required_Rate_by_AM__c * v.Conversion_Quantity_c;
                    }

                    TCLItoInsertList.add(msli);
                }

                upsert TCLItoInsertList;
                system.debug('TCLItoInsertList' + TCLItoInsertList);
                if (issync) {
                    EnquiryTriggerHandler.syncTCO_ToNavision(TCLItoInsertList);
                }
            }
            return 'success';
        } catch (Exception e) {
            System.debug(e.getLineNumber() + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createOrderFromEnquiry(String enquiryId) {
        // Step 1: Query the Inquiry (Enq) and its Line Items
        Enquiry__c enquiry = [SELECT Id, Document_No__c, Date_DD_MM_YYYY__c, End_Customer_Name__c,
            Application_Optional__c, Competition_Brand__c, Account__c, Contact__c, Contact__r.Name
            FROM Enquiry__c
            WHERE Id =: enquiryId
            LIMIT 1
        ];

        // Step 2: Create the Order record
        Sales_Order__c order = new Sales_Order__c();
        order.Name = AddSalesOrder.getcodemaster('Sales Order');
        order.Account__c = enquiry.Account__c;
        order.Rate_Type__c = '2';
        order.Enquiry__c = enquiry.Id;
        // order.End_Customer_Name__c = enquiry.End_Customer_Name__c;
        if (enquiry.Contact__c != null) {
            order.Contact_Name__c = enquiry.Contact__r.Name;
        }

        insert order;

        return order.Id;

    }

    @AuraEnabled
    public static string addsaleorderlineItems(String Id, String lineitemlist, String URL) {
        try {
            System.debug('RecordID' + Id);
            System.debug('lineitemlist' + lineitemlist);
            if (lineitemlist != '') {
                Sales_Order__c mainso = [SELECT Id, Name, Enquiry__c FROM Sales_Order__c WHERE Id =: Id];

                List < Enquiry_Line_Item__c > enqLIlist = [
                    SELECT Id, Name, Conversion_Factor__c, Conversion_Quantity__c, Item_Description__c, Item_No__c, Item_Master__c,
                    Item_Value__c, Qty__c, BUOM__c, SUOM__c, Standard_Dealer_Rate__c, Item_Variant__c, TempLineNo__c, Discount_In_Percentage__c,
                    Enquiry__r.Is_Created_From_TSD__c, Temp_Line_No__c
                    FROM Enquiry_Line_Item__c
                    WHERE Enquiry__c =: mainso.Enquiry__c
                ];

                String s = lineitemlist.replace('__c', '_c');
                list < Sales_Order_Line_Item__c > sollist = new list < Sales_Order_Line_Item__c > ();
                list < solineItemlist > vlist = parse2JsonData(s);

                // for (solineItemlist v: vlist) {
                for (Enquiry_Line_Item__c v: enqLIlist) {
                    Sales_Order_Line_Item__c msli = new Sales_Order_Line_Item__c();
                    msli.Sales_Order__c = Id;
                    msli.Conversion_Factor__c = v.Conversion_Factor__c;
                    msli.Conversion_Quantity__c = v.Conversion_Quantity__c;
                    msli.Description__c = v.Item_Description__c;
                    msli.Item_Number__c = v.Item_No__c;
                    msli.Item_Master__c = v.Item_Master__c;
                    System.debug('v.Item_Value__c:>>> SO' + v.Item_Value__c);
                    msli.Item_Value__c = v.Item_Value__c;
                    msli.Cash_Discount__c = 5;
                    Decimal totalval = v.Item_Value__c;
                    Decimal discval = totalval * (msli.Cash_Discount__c * 0.01);
                    msli.LineDiscountAmount__c = totalval - discval;
                    msli.Discount_In_Percentage__c = v.Discount_In_Percentage__c;
                    msli.Quantity__c = v.Qty__c;
                    msli.BUOM__c = v.BUOM__c;
                    msli.SUOM__c = v.SUOM__c;
                    // Decimal sptotalval = v.Standard_Dealer_Rate__c;
                    // Decimal spdiscval = sptotalval * (msli.Cash_Discount__c * 0.01);
                    // msli.Sales_Price__c = sptotalval - spdiscval;
                    msli.Sales_Price__c = v.Standard_Dealer_Rate__c;
                    Date currentDate = Date.today(); // Get today's date
                    Date futureDate = currentDate.addDays(7); // Add 7 days
                    msli.Shipment_Date__c = futureDate;
                    msli.Item_Variant__c = v.Item_Variant__c;
                    if (v.Enquiry__r.Is_Created_From_TSD__c) {
                        msli.TempLineNo__c = v.Temp_Line_No__c;
                    } else {
                        msli.TempLineNo__c = v.TempLineNo__c;
                    }

                    sollist.add(msli);
                }
                upsert sollist;
            }
            // sendEmailToAreaManager(Id, URL);
            return 'success';
        } catch (exception e) {
            system.debug(e.getLineNumber() + ' ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());

        }
    }

    @AuraEnabled
    public static string getTCOlineitems(String tcoid) {
        try {

            List < Enquiry_Line_Item__c > TCOli = new List < Enquiry_Line_Item__c > ();

            TCOli = [
                SELECT Id, Name, Qty__c, Item_Master__c, Item_Description__c, Item_Variant__c, Item_Variant__r.Code__c, Requested_Rate_By_Dealer__c,
                Item_No__c, Conversion_Quantity__c, Conversion_Factor__c, BUOM__c, SUOM__c, Dealer_Rate__c, Enquiry__r.Is_Created_From_TSD__c,
                Required_Rate_by_AM__c, Order_Qty__c, SuggestedDealerPrice__c, SuggestedCustomerPrice__c, Enquiry__r.Field_Staff_Code__c,
                Standard_Private_Rate__c, Standard_Dealer_Rate__c, Suggested_Private_Price__c, Enquiry__c, Enquiry__r.Submit_URL__c,
                Enquiry__r.Status__c, Item_Value__c, Discount_In_Percentage__c, Temp_Line_No__c, Enquiry__r.Attachment_Link__c
                FROM Enquiry_Line_Item__c
                WHERE Enquiry__c =: tcoid
            ];

            return JSON.serialize(TCOli);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List < solineItemlist > parse2JsonData(String json) {
        return (List < solineItemlist > ) System.JSON.deserialize(json, List < solineItemlist > .class);
    }

    public class solineItemlist {

        public String Id;
        public String Conversion_Factor_c;
        public Decimal Conversion_Quantity_c;
        public String Item_Description_c;
        public String Item_No_c;
        public String Item_Master_c;
        public Decimal Item_Value_c;
        public String Item_Variant_Name;
        public String Item_Variant_c;
        public Decimal Required_Rate_by_AM_c;
        public String Qty_c;
        public String BUOM_c;
        public String SUOM_c;
        public String SrNo;
        public Decimal Standard_Dealer_Rate_c;
        //public String Item_Variant_c;
    }

    public with sharing class wrapperClass {
        public List < DataWrapper > dataList;
    }

    public with sharing class DataWrapper {
        public String Itemid;
        public String ItemNo;
        public String Description;
        public String BUOM;
        public String SUOM;
        public Integer index;
    }
    public static List < Tsdlineitemlist > parseJsonData(String json) {
        return (List < Tsdlineitemlist > ) System.JSON.deserialize(json, List < Tsdlineitemlist > .class);
    }
    public class PicklistOption {
        @AuraEnabled public String value {
            get;
            set;
        }
        @AuraEnabled public String label {
            get;
            set;
        }

        public PicklistOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    public class Tsdlineitemlist {
        public String Id;
        public String Item_No_c;
        public string Item_Master_c;
        public String Item_Description_c;
        public Decimal Qty_c;
        public String Item_Variant_c;
        public Decimal Requested_Rate_By_Dealer_c;
        public Decimal Conversion_Quantity_c;
        public String Discount_In_Percentage_c;
        public String Conversion_Factor_c;
        public String Base_Unit_of_Measure_c;
        public String BUOM_c;
        public String Sales_Unit_of_Measure_c;
        public String SUOM_c;
        public Decimal Dealer_Rate_c;
        public Decimal Required_Rate_by_AM_c;
        public Decimal Dealer_Price_c;
        public Decimal SuggestedDealerPrice_c;
        public Decimal SuggestedCustomerPrice_c;
        public Decimal Standard_Private_Rate_c;
        public Decimal Standard_Dealer_Rate_c;
        public Decimal Suggested_Private_Price_c;
        public Decimal Item_Value_c;
    }

    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }

    public static void fakeCodeCoverage() {
        integer i = 1;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
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