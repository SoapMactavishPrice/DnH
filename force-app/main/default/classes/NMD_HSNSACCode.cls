public class NMD_HSNSACCode {
    // 18-10
    public class HSNSACCodeData {
        public String Type { get; set; }
        public String Description { get; set; }
        public String Code { get; set; }
        public String GST_Group_Code { get; set; }
    }
    // 18-10
    
    public String getHSNSACCodeDataAsJson() {
        
        List<HSN_Master__c> hsnMasterList = new List<HSN_Master__c>(); // 18-10
        
        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Page/HSNSACCodeSF');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/page/hsnsaccodesf:ReadMultiple');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/hsnsaccodesf">' +
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
                String jsonResponse = NMD_HSNSACCode.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);
                // 18-10
                List<HSNSACCodeData> hsnSACCodeDataList = (List<HSNSACCodeData>) JSON.deserialize(jsonResponse, List<HSNSACCodeData>.class);
            
                for (HSNSACCodeData hsnSACCodeData : hsnSACCodeDataList) {
                    HSN_Master__c hsnMaster = new HSN_Master__c();
                    hsnMaster.Type__c = hsnSACCodeData.Type;
                    hsnMaster.Description__c = hsnSACCodeData.Description; 
                    hsnMaster.Code__c = hsnSACCodeData.Code; 
                    hsnMaster.GST_Group_Code__c = hsnSACCodeData.GST_Group_Code;
                    
                    hsnMasterList.add(hsnMaster);
                }
                
                // {"Type":"HSN","Description":"PNG GAS","Code":"2711","GST_Group_Code":"G-GST 0","Key":"44;G0AAAAJ7/0cALQBHAFMAVAAgADAAAAACewQyADcAMQAx8;207401860;"}
               
                if (!hsnMasterList.isEmpty()) {
                    insert hsnMasterList;
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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/hsnsaccodesf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/hsnsaccodesf');


            // List to hold the hsnsaccodesf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each hsnsaccodesf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'HSNSACCodeSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each hsnsaccodesf node
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