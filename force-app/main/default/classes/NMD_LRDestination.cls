public class NMD_LRDestination {

    public class LRdestData {
        public String Code {
            get;
            set;
        }
        public String City {
            get;
            set;
        }
        public String SearchCity {
            get;
            set;
        }
        public String CountryRegionCode {
            get;
            set;
        }
    }

    public String getLRDataAsJson() {
        List < LR_Destination__c > lrDataList = new List < LR_Destination__c > (); // 17-10
        String jsonResponse = '';

        try {

            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();

            // Set the endpoint (URL)
            req.setEndpoint('http://52.172.153.4:7047/DynamicsNAV90/WS/DNH-LIVE/Codeunit/SalesForceIntegration');
            req.setMethod('POST');

            // Set headers
            req.setHeader('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/GetLRDestination:GetLRDestination');
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
                '<sal:GetLRDestination>' +
                '<sal:returnValue>?</sal:returnValue>' +
                '</sal:GetLRDestination>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>';
            req.setBody(body);

            // Send the HTTP request
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());

                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);

                Dom.XmlNode response = soapBody.getChildElement('GetLRDestination_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog ' + response);
                Dom.XmlNode returnValueLog = response.getChildElement('returnValue', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                if (returnValueLog != null) {
                    String returnValueLogContent = returnValueLog.getText();
                    List<LRdestData> lrDestDataList = (List<LRdestData>) JSON.deserialize(returnValueLogContent, List<LRdestData>.class);
                    List<LR_Destination__c> exLRlist = [SELECT Id, Name, Code__c FROM LR_Destination__c];
                    Set<String> lrSet = new Set<String>();
                    for (LR_Destination__c lr : exLRlist) {
                        lrSet.add(lr.Name+''+lr.Code__c);
                    }
                    for (LRdestData v : lrDestDataList) {
                        if (!lrSet.contains(v.City+''+v.Code)) {
                            // System.debug('YESSSSSSSSSSSSS');
                            LR_Destination__c lr = new LR_Destination__c();
                            lr.Name = v.City;
                            lr.Code__c = v.Code;
                            lrDataList.add(lr);
                        }
                    }
                }
                if (lrDataList.size() > 0) {
                    insert lrDataList;
                }

                jsonResponse = 'Ok';
            }
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return 'Exception: ' + e.getMessage();
        }
        return jsonResponse;
    }

}