public class CreateSalesRegisterFromNAV_API {

    // @AuraEnabled
    public static void getPostedInvoiceReportData(String customerNo, String engId, String startDate, String endDate) {

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'CreateSalesRegisterFromNAV_API';
        api_log.created_date__c = Datetime.now();

        try {

            String returnResponseLog = '';

            User usr = [
                SELECT Id, Name, Code__c, Zonal_Manager_ID__c, Reporting_Person_ID__c
                FROM User WHERE Id =: engId
            ];

            Account acc = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Id =: customerNo];

            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('SalesRegisterReportInsert');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();

            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            req.setTimeout(120000);

            // Set headers
            req.setHeader('SOAPAction', apiparam.SOAPAction);
            req.setHeader('Content-Type', apiparam.ContentType);
            req.setHeader('Authorization', HttpUtils.createBasicAuthHeader(apiparam.Username, apiparam.Password));

            // Set body (SOAP Envelope)
            String reqBody = apiparam.Request_body;
            reqBody = reqBody.replace('para1', startDate);
            reqBody = reqBody.replace('para2', endDate);
            reqBody = reqBody.replace('para3', usr.Code__c);
            // reqBody = reqBody.replace('para3', 'DNH1189');
            reqBody = reqBody.replace('para4', acc.Customer_Code__c);
            // reqBody = reqBody.replace('para4', 'CUS0000040');
            req.setBody(reqBody);

            api_log.Request__c = reqBody;

            HttpResponse res = http.send(req);

            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                Dom.Document doc = new Dom.Document();
                doc.load(res.getBody());

                // Get the root element of the SOAP Body
                Dom.XMLNode soapBody = doc.getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                System.debug(soapBody);

                Dom.XmlNode response = soapBody.getChildElement('GenerateSalesRegister_Result', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('response check ' + response);
                Dom.XmlNode returnValueLog = response.getChildElement('return_value', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('returnValueLog check ' + response);
                Dom.XmlNode responseLog = response.getChildElement('salesRegisterReport', 'urn:microsoft-dynamics-schemas/codeunit/SalesForceIntegration');
                System.debug('responseLog ' + responseLog);
                System.debug('responseLog ' + responseLog.getText());
                // Extract the text content of the responseLog element

                if(responseLog != null){
                    String returnValueLogContent = responseLog.getText();

                    // Extract the JSON string
                    String jsonString = returnValueLogContent;
                    System.debug('Extracted JSON: ' + jsonString);

                    // Insert Sales Register Report Data
                    insertSalesRegisterData(jsonString, acc.Id, usr.Code__c);
                    // insertSalesRegisterData(jsonString, acc.Id, 'DNH1189');

                } else {
                    // returnResponseLog = 'No data found';
                }

                // System.debug(res.getBody());
                // String jsonResponse = 'Ok';
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = returnValueLog.getText();
                api_log.response_time__c = Datetime.now();
                // insert api_log;

            } else {

                returnResponseLog = 'Failure';
                api_log.Log_Status__c = 'Failure';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                // insert api_log;

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());
                // return 'Error: ' + res.getStatus();
            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getLineNumber());
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Response__c = String.valueOf(e.getMessage());
            api_log.response_time__c = Datetime.now();
            // insert api_log;

            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
        }

        insert api_log;

    }

    public static void insertSalesRegisterData(String jsonData, String accId, String enggId){

        // Parse the JSON string into a list of objects
        List<SalesRegisterData> salesRegList = (List<SalesRegisterData>) JSON.deserialize(jsonData, List<SalesRegisterData>.class);

        List<Sales_Register__c> insertSalesRegisterListRegister = new List<Sales_Register__c>();

        // Set of Item Number and SOB number
        Set<String> itemNumberSet = new Set<String>();
        Set<String> salesOrderSet = new Set<String>();

        for(SalesRegisterData data : salesRegList){
            itemNumberSet.add(data.No);
            salesOrderSet.add(data.SalesOrderNo);
        }

        // Get Item and Sales order list
        List<Item_Master__c> imList = [
            SELECT Id, Name, Item_Number__c, Item_Description__c
            FROM Item_Master__c
            WHERE Item_Number__c IN :itemNumberSet
        ];

        List<Sales_Order__c> soList = [
            SELECT Id, Name, Sales_Document_Number__c
            FROM Sales_Order__c
            WHERE Sales_Document_Number__c IN :salesOrderSet
        ];

        List<Service_5_Sample_Request__c> sampleSOList = [
            SELECT Id, Name, Sample_Order_Number__c
            FROM Service_5_Sample_Request__c
            WHERE Sample_Order_Number__c IN :salesOrderSet
        ];

        // Create Master map for Item and Sales Order
        Map<String, Object> itemMasterMap = new Map<String, Object>();
        Map<String, Object> itemMasterDescMap = new Map<String, Object>();
        Map<String, Object> salesOrderMap = new Map<String, Object>();
        Map<String, Object> sampleSalesOrderMap = new Map<String, Object>();

        for(Item_Master__c ims : imList){
            itemMasterMap.put(ims.Item_Number__c, ims.Id);
            itemMasterDescMap.put(ims.Item_Number__c, ims.Item_Description__c);
        }

        for(Sales_Order__c sos : soList){
            salesOrderMap.put(sos.Sales_Document_Number__c, sos.Id);
        }

        for(Service_5_Sample_Request__c sso : sampleSOList){
            sampleSalesOrderMap.put(sso.Sample_Order_Number__c, sso.Id);
        }

        // Read response JSON
        for(SalesRegisterData data : salesRegList){
            if (data.EngineerID == enggId) {
                // System.debug('data: ' + data);
                Sales_Register__c sr = new Sales_Register__c();
                sr.Voucher_No__c = data.VoucherNo;
                sr.Type__c = data.Type;
                if (itemMasterMap.containsKey(data.No)) {
                    sr.Item_No__c = (String)itemMasterMap.get(data.No);
                }
                if (itemMasterDescMap.containsKey(data.No)) {
                    sr.Item_Description__c = (String)itemMasterDescMap.get(data.No);
                }
                sr.No__c = data.No;
                // sr.Item_No__c = im.size()>0 ? im[0].Id : null;
                // sr.Item_Description__c = im.size()>0 ? im[0].Item_Description__c : null;
                sr.Customer_Name__c = data.CustomerName;
                sr.Customer__c = accId;
                String sPostingDate = data.PostingDate;
                sPostingDate = sPostingDate.replace('/', '-');
                sr.Posting_Date__c = Date.valueOf(sPostingDate);
                String sQuantityinVariantSKU = data.QuantityinVariantSKU;
                sQuantityinVariantSKU = sQuantityinVariantSKU.replace(',',''); 
                sr.Quantity_in_Variant_SKU__c = Decimal.valueOf(sQuantityinVariantSKU);
                sr.Unit_of_Measure_Code__c = data.UitofMeasureCode;
                String sQuantityinKGS = data.QuantityinKGS;
                sQuantityinKGS = sQuantityinKGS.replace(',',''); 
                sr.Quantity_in_KGS__c = Decimal.valueOf(sQuantityinKGS);
                String sNetInvoiceValue = data.NetInvoiceValue;
                sNetInvoiceValue = sNetInvoiceValue.replace(',',''); 
                sr.Net_Invoice_Value__c = Decimal.valueOf(sNetInvoiceValue);
                sr.Stati_State__c = data.StatiState;
                sr.Sales_Engineer__c = data.SalesEngineer;
                sr.SPECIAL_CATEGO__c = data.SPECIALCATEGO;
                sr.Item_Brand__c = data.BrandName;
                String sTaxableValue = data.TaxableValue;
                sTaxableValue = sTaxableValue.replace(',',''); 
                sr.Taxable_Value__c = Decimal.valueOf(sTaxableValue);
                String sSalesOrderNo = data.SalesOrderNo;
                if (sSalesOrderNo.contains('SOB/')) {
                    if (salesOrderMap.containsKey(data.SalesOrderNo)) {
                        sr.Sales_Order__c = (String)salesOrderMap.get(data.SalesOrderNo);
                    }
                } else if (sSalesOrderNo.contains('SOM/')) {
                    if (sampleSalesOrderMap.containsKey(data.SalesOrderNo)) {
                        sr.Service_5_Sample_Request__c = (String)sampleSalesOrderMap.get(data.SalesOrderNo);
                    }
                }
                sr.Item_Traget_Category__c = data.ItemTarCategory;
                sr.Sales_Order_No__c = data.SalesOrderNo;
                insertSalesRegisterListRegister.add(sr);
            }
        }

        if(insertSalesRegisterListRegister.size() > 0){
            insert insertSalesRegisterListRegister;
        }

    }

    // Define a class to map the JSON structure
    public class SalesRegisterData {
        public String VoucherNo;
        public String Type;
        public String No;
        public String CustomerName;
        public String PostingDate;
        public String QuantityinVariantSKU;
        public String UitofMeasureCode;
        public String QuantityinKGS;
        public String NetInvoiceValue;
        public String StatiState;
        public String SalesEngineer;
        public String SPECIALCATEGO;
        public String BrandName;
        public String TaxableValue;
        public String EngineerID;
        public String ItemTarCategory;
        public String SalesOrderNo;
    }

}