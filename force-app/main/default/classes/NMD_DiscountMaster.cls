public class NMD_DiscountMaster {
    
    public List<Discount> getDiscountMasterDataAsJson() {
        List<Discount> discountList = new List<Discount>();   // 17-10
        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Page/DiscountMasterSF');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/page/discountmastersf:ReadMultiple');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/discountmastersf">' +
                          '<soapenv:Header/>' +
                          '<soapenv:Body>' +
                          '<cus:ReadMultiple/>' +
                          '</soapenv:Body>' +
                          '</soapenv:Envelope>';
            req.setBody(body);

            // Send the HTTP request
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                
                // System.debug(res.getBody());

                // Convert the map to JSON
                String jsonResponse = NMD_DiscountMaster.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);
                // 17-10
                discountList = (List<Discount>) JSON.deserialize(jsonResponse, List<Discount>.class);
                insertDiscounts(discountList);

                // return jsonResponse;
                // 17-10

            } else {
                System.debug('Error: ' + res.getStatus());
                // return 'Error: ' + res.getStatus();
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
        }
        
      return discountList;

    }

    public static String convertSoapResponseToJson(String soapResponse) {
        try {
            // Load the SOAP XML response into a DOM Document
            Dom.Document doc = new Dom.Document();
            doc.load(soapResponse);
            
            // Navigate to the Body > ReadMultiple_Result node
            Dom.XmlNode root = doc.getRootElement();
            Dom.XmlNode bodyNode = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/discountmastersf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/discountmastersf');


            // List to hold the discountmastersf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each discountmastersf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'DiscountMasterSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each discountmastersf node
                    for (Dom.XmlNode fieldNode : salesPersonNode.getChildElements()) {
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
    
    public class Discount{
        public decimal Discount_Percent;
        public decimal Qty_To;
        public decimal Qty_From;
        public string Disc_Type;
        public string Item_Discount_Group;
    }
    
    public void insertDiscounts(List<Discount> discounts) {
        List<Discount_Master__c> recordsToInsert = new List<Discount_Master__c>();

        for (Discount discount : discounts) {
            Discount_Master__c record = new Discount_Master__c();
            record.Discount__c = discount.Discount_Percent;
            record.Qty_To__c = discount.Qty_To;
            record.Qty_From__c = discount.Qty_From;
            record.Disc_Type__c = discount.Disc_Type;
            record.Item_Discount_Group__c = discount.Item_Discount_Group;

            recordsToInsert.add(record);
        }
        // {"Discount_Percent":"0","Qty_To":"199","Qty_From":"100","Disc_Type":"Variant_Quanity","Item_Discount_Group":"6013+7018","Key":"80;ccMAAAJ7/zYAMAAxADMAKwA3ADAAMQA4AAAAADJCAAAAAAAAAAAQAAAAMkIAAAAAAAAAkBkAAACLAQ==9;2051398190;"}

        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
    }
    
    
    
}