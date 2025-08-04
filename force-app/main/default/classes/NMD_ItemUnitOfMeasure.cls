public class NMD_ItemUnitOfMeasure {

    public String getIUOMDataAsJson() {
        List<Currency__c> currencyList = new List<Currency__c>(); // 17-10
        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Page/ItemUnitOfMeasureSF');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/page/salespersonsf:ReadMultiple');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/itemunitofmeasuresf">' +
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
                String jsonResponse = NMD_ItemUnitOfMeasure.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);
                
                
                // List<CurrencyData> currencyDataList = (List<CurrencyData>) JSON.deserialize(jsonResponse, List<CurrencyData>.class);
                
                // for (CurrencyData currencyData : currencyDataList) {
                //     Currency__c curency = new Currency__c();
                //     curency.Description__c = currencyData.Description;
                //     curency.Code__c = currencyData.Code;
                    
                //     currencyList.add(curency);
                // }
                
                // // Insert the currency records into the database
                // if (!currencyList.isEmpty()) {
                //     insert currencyList;
                // }

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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/itemunitofmeasuresf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/itemunitofmeasuresf');


            // List to hold the itemunitofmeasuresf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each itemunitofmeasuresf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'ItemUnitOfMeasureSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each itemunitofmeasuresf node
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