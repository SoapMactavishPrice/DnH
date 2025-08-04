public class NMD_PaymentTerms {
    
    // 17-10
    public class PaymentTermsData {
        public String Name { get; set; }
        public String Code { get; set; }
        public String Description { get; set; }
    }
    // 17-10
    
    public String getPaymentTermsDataAsJson() {
        
        List<Payment_Terms__c> paymentTermsList = new List<Payment_Terms__c>();

        try {
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:8047/Directors/WS/TESTLIVE/Page/PaymentTermsSF');
            req.setMethod('GET');
            
            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/page/paymenttermssf:ReadMultiple');
            req.setHeader('Content-Type', 'text/xml');
            
            // Set Basic Authentication
            String username = 'lfs';
            String password = 'Lfs@2023';
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            
            // Set body (SOAP Envelope)
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/paymenttermssf">' +
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
                String jsonResponse = NMD_PaymentTerms.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);
                // 17-10
                List<PaymentTermsData> paymentTermsDataList = (List<PaymentTermsData>) JSON.deserialize(jsonResponse, List<PaymentTermsData>.class);
            
                for (PaymentTermsData paymentTermsData : paymentTermsDataList) {
                    Payment_Terms__c paymentTerm = new Payment_Terms__c();
                    paymentTerm.Name = paymentTermsData.Name;                
                    paymentTerm.Code__c = paymentTermsData.Code;           
                    paymentTerm.Description__c = paymentTermsData.Description;
                    
                    paymentTermsList.add(paymentTerm);
                }
    
                if (!paymentTermsList.isEmpty()) {
                    insert paymentTermsList;
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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/paymenttermssf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/paymenttermssf');


            // List to hold the paymenttermssf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each paymenttermssf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'PaymentTermsSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each paymenttermssf node
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