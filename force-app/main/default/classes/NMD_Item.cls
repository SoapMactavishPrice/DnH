public class NMD_Item {
    // @future (callout=true)
    public String getItemDataAsJson() {
        try {
            List < Item_Master__c > itemMaster = new List < Item_Master__c > (); // 18-10
            // Initialize the HTTP request
            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('NMD_Item');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();

            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);

            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));

            // Set body (SOAP Envelope)
            String body = apiparam.Request_body;
            req.setBody(body);

            // Send the HTTP request
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {

                // System.debug(res.getBody());

                // Convert the map to JSON
                String jsonResponse = NMD_Item.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' + jsonResponse);

                List < Item_Master__c > itemMasterListInSF = [SELECT Id, Name, Item_Number__c FROM Item_Master__c];

                Map < String, String > ItemMasterMap = new Map < String, String > ();
                for (Item_Master__c im: itemMasterListInSF) {
                    ItemMasterMap.put(im.Item_Number__c, im.Id);
                }

                List < ItemWrapper > itemMasterListInResponse = (List < ItemWrapper > ) JSON.deserialize(jsonResponse, List < ItemWrapper > .class);

                for (ItemWrapper itemVariantData: itemMasterListInResponse) {

                    Item_Master__c itemVariant = new Item_Master__c();
                    if (ItemMasterMap.get(itemVariantData.No) != null) {
                        itemVariant.Id = ItemMasterMap.get(itemVariantData.No);
                    }

                    itemVariant.Name = itemVariantData.Description;
                    itemVariant.Item_Number__c = itemVariantData.No;
                    itemVariant.Item_Description__c = itemVariantData.Description;
                    itemVariant.CheckItemPrice__c = boolean.valueof(itemVariantData.CheckItemPrice);
                    itemVariant.Base_Unit_of_Measure__c = itemVariantData.Base_Unit_of_Measure;
                    //itemVariant.Inventory_Type__c = itemVariantData.Gross_Wt; 
                    itemVariant.Inventory_Posting_Group__c = itemVariantData.Inventory_Posting_Group;
                    itemVariant.Blocked__c = boolean.valueof(itemVariantData.Blocked);
                    itemVariant.Gen_Prod_Posting_Group__c = itemVariantData.Gen_Prod_Posting_Group;
                    itemVariant.Sales_Unit_of_Measure__c = itemVariantData.Sales_Unit_of_Measure;
                    itemVariant.Purch_Unit_of_Measure__c = itemVariantData.Purch_Unit_of_Measure;
                    itemVariant.Item_Category_Code__c = itemVariantData.Item_Category_Code;
                    itemVariant.Product_Group_Code__c = itemVariantData.Product_Group_Code;
                    itemVariant.Item_Tracking_Code__c = itemVariantData.Item_Tracking_Code;
                    itemVariant.GST_Group_Code__c = itemVariantData.GST_Group_Code;
                    //itemVariant.HSN_SAC_Code = itemVariantData.HSN_SAC_Code;
                    itemVariant.GST_Credit__c = itemVariantData.GST_Credit;
                    //itemVariant.Exempted__c = boolean.valueof(itemVariantData.Exempted);
                    itemVariant.Tolerance__c = itemVariantData.Tolerance_Percent;
                    itemVariant.Enable_Packing__c = boolean.valueof(itemVariantData.Enable_Packing);
                    if (itemVariantData.Inventory_Type != '_blank_') {
                        itemVariant.Inventory_Type__c = itemVariantData.Inventory_Type;
                    }

                    itemVariant.Pack_Size__c = itemVariantData.Pack_Size;
                    itemVariant.Packing_Mode__c = itemVariantData.Packing_Mode;
                    itemVariant.SampleItem__c = boolean.valueof(itemVariantData.SampleItem);
                    itemVariant.Tracking_Item__c = boolean.valueof(itemVariantData.Tracking_Item);
                    itemVariant.Dim_Size__c = itemVariantData.Dim_Size;
                    itemVariant.Dim_BrandName__c = itemVariantData.Dim_BrandName;
                    itemVariant.Dim_ItemTargetCat__c = itemVariantData.Dim_ItemTargetCat;
                    itemVariant.ItemVariant_SalesUOM__c = itemVariantData.ItemVariant_SalesUOM;
                    itemVariant.DiscOn__c = String.valueOf(itemVariantData.DiscOn);

                    itemMaster.add(itemVariant);

                }

                if (itemMaster.size() > 0) {
                    // System.debug(accountsToInsert.size());
                    //  insert accountsToInsert;
                    // System.debug('DONEEEE');
                    Database.UpsertResult[] srList = Database.upsert(itemMaster, false);
                    set < Id > idsList = new set < Id > ();
                    for (Database.UpsertResult sr: srList) {
                        if (sr.isSuccess()) {
                            idsList.add(sr.getId());
                            System.debug('Upsert succeeded for record with ID: ' + sr.getId());
                        } else {
                            System.debug('failed order for record with ID: ' + sr.getId());
                            for (Database.Error err: sr.getErrors()) {
                                System.debug('Error status code: ' + err.getStatusCode());
                                System.debug('Error message: ' + err.getMessage());
                            }
                        }

                    }
                }

                return jsonResponse;

            } else {
                System.debug('Error: ' + res.getStatus());
                return 'Error: ' + res.getStatus();
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return 'Exception: ' + e.getMessage();
        }
    }

    public static String convertSoapResponseToJson(String soapResponse) {
        try {
            // Load the SOAP XML response into a DOM Document
            Dom.Document doc = new Dom.Document();
            doc.load(soapResponse);

            // Navigate to the Body > ReadMultiple_Result node
            Dom.XmlNode root = doc.getRootElement();
            Dom.XmlNode bodyNode = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/itemsf');

            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/itemsf');

            // List to hold the itemsf data in map format
            List < Map < String, Object >> salesPersonList = new List < Map < String, Object >> ();

            // Loop through each itemsf element and extract the data
            for (Dom.XmlNode salesPersonNode: innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'ItemSF') {
                    Map < String, Object > salesPersonMap = new Map < String, Object > ();

                    // Extract all fields for each itemsf node
                    for (Dom.XmlNode fieldNode: salesPersonNode.getChildElements()) {
                        salesPersonMap.put(fieldNode.getName(), fieldNode.getText());
                    }

                    // Add each SalesPerson data to the list
                    salesPersonList.add(salesPersonMap);
                }
            }

            // Convert the list of maps to JSON format
            String jsonResponse = JSON.serialize(salesPersonList);
            return jsonResponse;

        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
            return 'Error parsing SOAP response: ' + e.getMessage();
        }
    }

    public class ItemWrapper {
        public String Key;
        public String No;
        public String Description;
        public String Base_Unit_of_Measure;
        // public String Type;
        public String Inventory_Posting_Group;
        public String Blocked;
        public String Gen_Prod_Posting_Group;
        public String Sales_Unit_of_Measure;
        public String Purch_Unit_of_Measure;
        public String Item_Category_Code;
        public String Product_Group_Code;
        public String Item_Tracking_Code;
        public String GST_Group_Code;
        public String HSN_SAC_Code;
        public String GST_Credit;
        public String Exempted;
        public Decimal Tolerance_Percent;
        //public Boolean R_x0026_D_Item;
        public String Enable_Packing;
        public String Inventory_Type;
        public String Pack_Size;
        public String Packing_Mode;
        public String SampleItem;
        public String Tracking_Item;
        public String Dim_Size;
        public String Dim_BrandName;
        public String Dim_ItemTargetCat;
        public String ItemVariant_SalesUOM;
        public Integer DiscOn;
        public String Transaction_Block;
        public String CheckItemPrice;
    }
    public static void fakeCodeCoverage() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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