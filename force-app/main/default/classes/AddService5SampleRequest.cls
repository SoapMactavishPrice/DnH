public class AddService5SampleRequest {
    @AuraEnabled
    public static string getcodemaster(String objectname) {
        list < Code_Master__c > codem = [SELECT Id, Name, Object__c, Display_Label__c, Current_Sequence__c, Starting_Sequence__c,
            Backend_Current_Sequence__c, For_Display_Sequence__c FROM Code_Master__c
            WHERE Object__c =: objectname AND Is_Active__c = true
            LIMIT 1 FOR UPDATE
        ];
        if (!codem.isEmpty()) {String name = codem[0].Display_Label__c + '/' + String.valueOf(codem[0].For_Display_Sequence__c); codem[0].Current_Sequence__c += 1;  update codem; return name;
           
            

            
            //+ String.valueOf(codem.Backend_Current_Sequence__c);
            
        } else {
            return null; // or you can throw an exception if you expect at least one result
        }
    }

    @AuraEnabled(cacheable = true)
    public static List < PicklistValue > getitemcategoryCode() {
        List < Sample_Request_Item_Category_Code__c > itemcategoryCode = [SELECT Id, Name FROM Sample_Request_Item_Category_Code__c];
        List < PicklistValue > itemcategoryCodeList = new List < PicklistValue > ();
        for (Sample_Request_Item_Category_Code__c CategoryCode: itemcategoryCode) {
            PicklistValue pv = new PicklistValue(CategoryCode.Id, CategoryCode.Name);
            itemcategoryCodeList.add(pv);
        }
        return itemcategoryCodeList;
    }

    @AuraEnabled(cacheable = true)
    public static List < PicklistValue > getSamReqBrand() {
        List < Sam_Req_Brand_Name__c > SamReqBrandName = [SELECT Id, Name FROM Sam_Req_Brand_Name__c ORDER BY Name ASC];
        List < PicklistValue > SamReqBrandNameList = new List < PicklistValue > ();
        for (Sam_Req_Brand_Name__c SamReqBrand: SamReqBrandName) {
            PicklistValue pv = new PicklistValue(SamReqBrand.Id, SamReqBrand.Name);
            SamReqBrandNameList.add(pv);
        }
        return SamReqBrandNameList;
    }

    @AuraEnabled
    public static String getBrandNameById(String Id) {
        Sam_Req_Brand_Name__c SamReqBrandName = [SELECT Id, Name FROM Sam_Req_Brand_Name__c WHERE Id =: Id];
        return SamReqBrandName.Name;
    }

    @AuraEnabled(cacheable = true)
    public static List < PicklistValue > getitemsize() {
        List < Sam_Req_Size_mm__c > itemsize = [SELECT Id, Name FROM Sam_Req_Size_mm__c ORDER BY Name ASC];
        List < PicklistValue > itemsizeList = new List < PicklistValue > ();
        for (Sam_Req_Size_mm__c SamReqSize: itemsize) {
            PicklistValue pv = new PicklistValue(SamReqSize.Id, SamReqSize.Name);
            itemsizeList.add(pv);
        }
        return itemsizeList;
    }

    @AuraEnabled
    public static String getSizeNameById(String Id) {
        Sam_Req_Size_mm__c itemSize = [SELECT Id, Name FROM Sam_Req_Size_mm__c WHERE Id =: Id];
        return itemSize.Name;
    }

    @AuraEnabled
    public static string getItemByCategory(String catId){
        try {

            List<Item_Master__c> itemList = [
                SELECT Id, Name, Item_Type__c, Sample_Request_Item_Category_Code__c FROM Item_Master__c
                WHERE Item_Type__c = 'Sample' AND Sample_Request_Item_Category_Code__c =:catId
            ];

            List<Map<String,String>> itemMapList = new List<Map<String,String>>();

            for (Item_Master__c var : itemList) {
                Map<String, String> itemMap = new Map<String, String>();
                itemMap.put('label', var.Name);
                itemMap.put('value', var.Id);
                itemMapList.add(itemMap);
            }


            return JSON.serialize(itemMapList);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getItemDetail(String itemId){
        try {

            Item_Master__c item = [
                SELECT Id, Name, Item_Number__c, Product_Group_Code__c, Sample_Quantity__c, Sample_Packing_Mode__c,
                Sample_Inventory__c, Sample_UOM__c, Description__c
                FROM Item_Master__c
                WHERE Id =:itemId
            ];

            return JSON.serialize(item);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getLineItem(String rId){
        try {

            List<Sample_Request_Product__c> item = [
                SELECT Id, Name, Description__c, Application_Details__c, Remarks__c, Potential_Of_Business__c, Special_Properties__c,
                Sample_Request_Item_Category_Code__c, Sample_Request_Item_Category_Code__r.Name, Sam_Req_Size_mm__c, Sam_Req_Brand_Name__c,
                Sam_Req_Brand_Name__r.Name, Item_No__c, Item_No__r.Name, Item_No__r.Item_Number__c, Quantity_2__c, Qty_Type_2__c, Sam_Req_Size_mm__r.Name
                FROM Sample_Request_Product__c
                WHERE Sample_Request__c =:rId
            ];

            return JSON.serialize(item);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string addService5SampleRequest(String Id, String mdoc, String lineitemlist) {
        try {
            // Handling main document attachment if needed
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
                contentLink.LinkedEntityId = Id; // Associate with Sales_Order__c
                contentLink.ShareType = 'V';
                contentLink.Visibility = 'AllUsers';
                contentLinks.add(contentLink);

                // Generate ContentDistribution
                ContentDistribution contentDist = new ContentDistribution(
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

            // Handling line items and associated attachments
            if (lineitemlist != null && lineitemlist != '') {
                String s = lineitemlist.replace('__c', '_c');
                List < Sample_Request_Product__c > SRPItoInsertList = new List < Sample_Request_Product__c > ();
                List < Attachment > attlist = new List < Attachment > ();

                List < SampleRequestProductList > vList = parseJsonData(s);

                for (SampleRequestProductList v: vList) {
                    Sample_Request_Product__c msli = new Sample_Request_Product__c();

                    if (String.isNotBlank(v.Id)) {  msli.Id = v.Id;
                       
                    } else {
                        msli.Sample_Request__c = Id;
                    }

                    msli.Application_Details__c = v.Application_Details_c;
                    msli.Sam_Req_Brand_Name__c = v.Sam_Req_Brand_Name_c;
                    // msli.Quantity__c = Decimal.valueOf(v.Quantity_c);
                    msli.Quantity_2__c = v.Quantity_2_c;
                    msli.Description__c = v.Description_c;
                    msli.Sample_Request_Item_Category_Code__c = v.Sample_Request_Item_Category_Code_c;
                    msli.Item_No__c = v.Item_No_c;
                    msli.Potential_Of_Business__c = v.Potential_Of_Business_c;
                    msli.Qty_Type_2__c = v.Qty_Type_2_c;
                    msli.Remarks__c = v.Remarks_c;
                    msli.Sam_Req_Size_mm__c = v.Sam_Req_Size_mm_c;  msli.Special_Properties__c = v.Special_Properties_c; SRPItoInsertList.add(msli);
                    
                   

                    // Handle file attachment for each line item if exists
                    if (v.file != null) {
                        Attachment att = new Attachment();
                        att.ParentId = msli.Id; // This will be null until msli is inserted
                        att.Name = v.file.Title;
                        att.Body = EncodingUtil.base64Decode(v.file.VersionData); // Decode base64 string
                        attlist.add(att);
                    }
                }

                upsert SRPItoInsertList; // Insert the Sample Request Products first

                // Update attachment's parent ID
                for (Attachment att: attlist) {
                    att.ParentId = SRPItoInsertList.get(attlist.indexOf(att)).Id;
                }

                insert attlist; // Insert the attachments after setting correct parent IDs

                System.debug('SRPItoInsertList: ' + SRPItoInsertList);
            }

            return 'Success';

        } catch (Exception e) {
            System.debug('Error at line: ' + e.getLineNumber() + ', message: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string deleteSampleLI(String Id) {
        try {

            Sample_Request_Product__c soli = [
                SELECT Id, Name
                FROM Sample_Request_Product__c
                WHERE Id =: Id
            ];

            delete soli;

            return 'ok';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Method to parse JSON data into SampleRequestProductList class
    public static List < SampleRequestProductList > parseJsonData(String json) {
        return (List < SampleRequestProductList > ) System.JSON.deserialize(json, List < SampleRequestProductList > .class);
    }

    // Inner class representing each product line item
    public class SampleRequestProductList {
        public String Qty_Type_2_c;
        public Decimal Potential_Of_Business_c;
        public String Quantity_2_c;
        public String Revision_c;
        public String Sample_Request_Item_Category_Code_c;
        public String Item_No_c;
        public String Application_Details_c;
        public String Sam_Req_Brand_Name_c;
        public String Description_c;
        public String Remarks_c;
        public String Sam_Req_Size_mm_c;
        public String Special_Properties_c;
        public String Id;
        public relatedFile file;
    }

    // Inner class representing related file information
    public class relatedFile {
        public String Title;
        public String VersionData;
    }
    public class PicklistValue {
        @AuraEnabled
        public String value; // Typically holds the Id
        @AuraEnabled
        public String label; // Typically holds the Name

        // Constructor
        public PicklistValue(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}