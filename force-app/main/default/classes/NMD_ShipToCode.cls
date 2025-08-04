public class NMD_ShipToCode {
    // 17-10
    public class ShipToCodeData {
        public String Name { get; set; }
        public String Code { get; set; }
        public String Customer_No { get; set; }
        public String Address { get; set; }
        public String Address_2 { get; set; }
        public String City { get; set; }
        public String Country_Region_Code { get; set; }
        public String Post_Code { get; set; }
        public String State { get; set; }
        public String GST_Registration_No { get; set; }
    }
    // 17-10
    
    public String getShipToCodeDataAsJson() {
        List<Ship_to_Code__c> shipToCodeList = new List<Ship_to_Code__c>();

        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Page/ShipToCodeSF');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/page/shiptocodesf:ReadMultiple');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/shiptocodesf">' +
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
                String jsonResponse = NMD_ShipToCode.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);

                Map<String, String> mapName = new Map<String, String>();

                List<Ship_to_Code__c> existingSTC = [
                    SELECT Id, Name, Customer_No__c, Code__c
                    FROM Ship_to_Code__c
                ];

                for (Ship_to_Code__c stc : existingSTC) {
                    mapName.put(stc.Customer_No__c+stc.Code__c, stc.Id);
                }

                // 17-10
                List<ShipToCodeData> shipToCodeDataList = (List<ShipToCodeData>) JSON.deserialize(jsonResponse, List<ShipToCodeData>.class);

                for (ShipToCodeData shipToCodeData : shipToCodeDataList) {
                    Ship_to_Code__c shipToCode = new Ship_to_Code__c();
                    if (mapName.containsKey(shipToCodeData.Customer_No+shipToCodeData.Code)) {
                        shipToCode.Id = mapName.get(shipToCodeData.Customer_No+shipToCodeData.Code);
                    }
                    shipToCode.Customer_No__c = shipToCodeData.Customer_No != null ? shipToCodeData.Customer_No : null; 
                    shipToCode.Code__c = shipToCodeData.Code != null ? shipToCodeData.Code : null;     
                    shipToCode.Name__c = shipToCodeData.Name != null ? shipToCodeData.Name : null;
                    shipToCode.Address__c = shipToCodeData.Address != null ? shipToCodeData.Address : null;
                    shipToCode.Address_2__c = shipToCodeData.Address_2 != null ? shipToCodeData.Address_2 : null;
                    shipToCode.City__c = shipToCodeData.City != null ? shipToCodeData.City : null;
                    shipToCode.Country_Region_Code__c = shipToCodeData.Country_Region_Code != null ? shipToCodeData.Country_Region_Code : null;
                    shipToCode.Post_Code__c = shipToCodeData.Post_Code != null ? shipToCodeData.Post_Code : null;
                    shipToCode.State__c = shipToCodeData.State != null ? shipToCodeData.State : null;
                    shipToCode.GST_Registration_No__c = shipToCodeData.GST_Registration_No != null ? shipToCodeData.GST_Registration_No : null;
                    
                    shipToCodeList.add(shipToCode);
                }
                
                // {"Name":"A B & CORP","Code":"452009","Customer_No":"CUS0000010","Key":"60;3gAAAAJ7/0MAVQBTADAAMAAwADAAMAAxADAAAAACewY0ADUAMgAwADAAOQ==9;2384573830;"}


                if (!shipToCodeList.isEmpty()) {
                    upsert shipToCodeList;
                }
                // 17-10
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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/shiptocodesf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/shiptocodesf');


            // List to hold the shiptocodesf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each shiptocodesf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'ShipToCodeSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each shiptocodesf node
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