public class NMD_DimensionValue {
    
    public String getDimensionValueDataAsJson() {
        List<DimensionValue> dimensionValueList = new List<DimensionValue>(); // 17/10
        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Page/DimensionValueSF');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/page/dimensionvaluesf:ReadMultiple');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/dimensionvaluesf">' +
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
                String jsonResponse = NMD_DimensionValue.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);
                //  
                dimensionValueList = (List<DimensionValue>) JSON.deserialize(jsonResponse, List<DimensionValue>.class);
                insertDimensionValues(dimensionValueList);
                return jsonResponse;
                //

            } else {
                System.debug('Error: ' + res.getStatus());
                return 'Error: ' + res.getStatus();
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + 'line:' +e.getlinenumber());
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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/dimensionvaluesf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/dimensionvaluesf');


            // List to hold the dimensionvaluesf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each dimensionvaluesf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'DimensionValueSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each dimensionvaluesf node
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
    
    public class DimensionValue {
            public string Blocked;
            public String Name;
            public String Code;
            public String Dimension_Code;
        }
    
    public void insertDimensionValues(List<DimensionValue> dimensionValues) {
        List<Dimension_Value__c> recordsToInsert = new List<Dimension_Value__c>();

        for (DimensionValue dimensionValue : dimensionValues) {
            Dimension_Value__c record = new Dimension_Value__c();
            record.Blocked__c = boolean.valueof(dimensionValue.Blocked);
            record.Name = dimensionValue.Name;
            record.Code__c = dimensionValue.Code;
            record.Dimension_Code__c = dimensionValue.Dimension_Code;

            recordsToInsert.add(record);
        }
        // {"Blocked":"false","Name":"`1234","Code":"1","Dimension_Code":"BIS ITEM","Key":"40;XQEAAAJ7/0IASQBTACAASQBUAEUATQAAAAJ7ATE=9;2051412940;"}

        // Perform the insert operation
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
    }

}