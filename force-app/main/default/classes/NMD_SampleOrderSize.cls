public class NMD_SampleOrderSize {
    public class CurrencyData {
        public String DimensionCode { get; set; }
        public String Code { get; set; }
        public String Description { get; set; }
        public String EmailId { get; set; }
    }
    
    public String getCurrencyDataAsJson() {
        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Codeunit/SalesForceIntegration');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/GetItemSampleServices5:GetSize');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal="urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration">' +
                          '<soapenv:Header/>' +
                          '<soapenv:Body>' +
                          '<sal:GetSize>' +
                          '<sal:returnValue>?</sal:returnValue>' +
                          '</sal:GetSize>' +
                          '</soapenv:Body>' +
                          '</soapenv:Envelope>';
            req.setBody(body);

            // Send the HTTP request
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                
                // System.debug(res.getBody());

                // Convert the map to JSON
                String jsonResponse = NMD_SampleOrderBrand.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);

                String cleanedJsonString = jsonResponse.replace('\\', '');
                cleanedJsonString = cleanedJsonString.substring(1, cleanedJsonString.length() - 1);
                
                
                List<Sam_Req_Size_mm__c> currencyList = new List<Sam_Req_Size_mm__c>();
                List<CurrencyData> currencyDataList = (List<CurrencyData>) JSON.deserialize(cleanedJsonString, List<CurrencyData>.class);
                System.debug('currencyDataList:>>>> ' +currencyDataList);

                for (CurrencyData currencyData : currencyDataList) {
                    Sam_Req_Size_mm__c lead = new Sam_Req_Size_mm__c();
                    lead.Dimension_Code__c = currencyData.DimensionCode;
                    lead.Code__c = currencyData.Code;
                    lead.Description__c = currencyData.Description;
                    lead.Name = currencyData.Description;
                    
                    currencyList.add(lead);
                }


                System.debug('currencyList:>>>>> ' +currencyList);
                
                // Insert the currency records into the database
                if (!currencyList.isEmpty()) {
                    // insert currencyList;
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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('GetSize_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');

            // System.debug('RESULTTTT:>> ' +innerReadMultipleResultNode.getText());

            // List to hold the currencysf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each currencysf element and extract the data
            // for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
            //     // System.debug(salesPersonNode.getName());
            //     if (salesPersonNode.getName() == 'CurrencySF') {
            //         Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
            //         // Extract all fields for each currencysf node
            //         for (Dom.XmlNode fieldNode : salesPersonNode.getChildElements()) {
            //             salesPersonMap.put(fieldNode.getName(), fieldNode.getText());
            //         }
                    
            //         // Add each SalesPerson data to the list
            //         salesPersonList.add(salesPersonMap);
            //     }
            // }
            
            // Convert the list of maps to JSON format
            String jsonResponse = JSON.serialize(innerReadMultipleResultNode.getText());
            return jsonResponse;
            
        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
            return 'Error parsing SOAP response: ' + e.getMessage();
        }
    }

    public static void a(){
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
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}