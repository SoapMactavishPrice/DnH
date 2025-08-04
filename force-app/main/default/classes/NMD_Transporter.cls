public class NMD_Transporter {
    //17-10
    public class TransporterData {
        public String Name { get; set; }
        public String Code { get; set; }
        public String Key { get; set; }
    }
    //17-10
    
    public String getTransporteDataAsJson() {
        List<Transporter__c> transporterList = new List<Transporter__c>(); // 17-10

        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:7047/DynamicsNAV90/WS/DNH-LIVE/Page/TransporterSF');
            // req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Page/TransporterSF');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/page/transportersf:ReadMultiple');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/transportersf">' +
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
                String jsonResponse = NMD_Transporter.convertSoapResponseToJson(res.getBody());
                // System.debug('jsonResponse:>>>> ' +jsonResponse);
                // 17-10
                List<TransporterData> transporterDataList = (List<TransporterData>) JSON.deserialize(jsonResponse, List<TransporterData>.class);
                Set<String> etSet = new Set<String>();

                List<Transporter__c> existingTransporterList = [SELECT Id, Code__c FROM Transporter__c];
                for (Transporter__c var : existingTransporterList) {
                    etSet.add(var.Code__c);
                }
            
                for (TransporterData transporterData : transporterDataList) {
                    if (!etSet.contains(transporterData.Code)) {
                        // System.debug(transporterData.Code);
                        Transporter__c transporter = new Transporter__c();
                        transporter.Name = transporterData.Name;
                        transporter.Code__c = transporterData.Code;                  
                        transporterList.add(transporter);
                    }
                }
                // {"Name":"AMALTAS TRAVELS","Code":"AML","Key":"16;IwEAAAJ7/0EATQBM8;116336560;"}

                if (!transporterList.isEmpty()) {
                    // System.debug(transporterList.size());
                    insert transporterList;
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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/transportersf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/transportersf');


            // List to hold the transportersf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each transportersf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'TransporterSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each transportersf node
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