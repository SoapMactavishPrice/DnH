public class NMD_GSTGroupCode {
    // 18-10
    public class GSTGroupCodeData {
        public String Description { get; set; }
        public String GST_Place_Of_Supply { get; set; }
        public String GST_Group_Type { get; set; }
        public String Code { get; set; }
    }
    // 18-10
    
    public String getGSTGroupCodeDataAsJson() {
        List<GST_Group_Code__c> gstGroupCodesList = new List<GST_Group_Code__c>(); // 18-10

        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Page/GSTGroupCodeSF');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/page/gstgroupcodesf:ReadMultiple');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/gstgroupcodesf">' +
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
                String jsonResponse = NMD_GSTGroupCode.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);
                // 18-10
                 List<GSTGroupCodeData> gstGroupCodeDataList = (List<GSTGroupCodeData>) JSON.deserialize(jsonResponse, List<GSTGroupCodeData>.class);
            
                for (GSTGroupCodeData gstGroupCodeData : gstGroupCodeDataList) {
                    GST_Group_Code__c gstGroupCode = new GST_Group_Code__c();
                    gstGroupCode.Description__c = gstGroupCodeData.Description; 
                    gstGroupCode.GST_Place_Of_Supply__c = gstGroupCodeData.GST_Place_Of_Supply; 
                    gstGroupCode.GST_Group_Type__c = gstGroupCodeData.GST_Group_Type; 
                    gstGroupCode.Code__c = gstGroupCodeData.Code; 
                    
                    gstGroupCodesList.add(gstGroupCode);
                }
                // {"Description":"GOODS GST 0%","GST_Place_Of_Supply":"Bill_to_Address","GST_Group_Type":"Goods","Code":"G-GST 0","Key":"28;FEAAAAJ7/0cALQBHAFMAVAAgADA=7;12109250;"}
                
                if (!gstGroupCodesList.isEmpty()) {
                    insert gstGroupCodesList;
                }
                // 18-10
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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/gstgroupcodesf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/gstgroupcodesf');


            // List to hold the gstgroupcodesf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each gstgroupcodesf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'GSTGroupCodeSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each gstgroupcodesf node
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

}