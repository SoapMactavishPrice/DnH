public class NMD_Customer {
    public String getCustomerDataAsJson() {
        List<customerWC> customerValueList = new List<customerWC>();
        try {
            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('NMD_Customer');
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
            String body = apiparam.Request_body;
            req.setBody(body);

            // Send the HTTP request
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                
                // System.debug(res.getBody());

                // Convert the map to JSON
                String jsonResponse = NMD_Customer.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);

                // Insert converted data
                customerValueList = (List<customerWC>) JSON.deserialize(jsonResponse, List<customerWC>.class);
                insertCustomer(customerValueList);

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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/customersf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/customersf');


            // List to hold the customersf data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each customersf element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'CustomerSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each customersf node
                    for (Dom.XmlNode fieldNode : salesPersonNode.getChildElements()) {               salesPersonMap.put(fieldNode.getName(), fieldNode.getText());
                    }
                    
                    // Add each SalesPerson data to the list
                    salesPersonList.add(salesPersonMap);
                }
            }
            
            // Convert the list of maps to JSON format
            String jsonResponse = JSON.serialize(salesPersonList);            return jsonResponse;
            
        } catch (Exception e) {
            System.debug('Error parsing SOAP response: ' + e.getMessage());
            return 'Error parsing SOAP response: ' + e.getMessage();
        }
    }

    public void insertCustomer(List<customerWC> customerValues) {

        List<Account> accountsToInsert = new List<Account>();
        List<Account> existingAccounts = new List<Account>();
        existingAccounts = [
            SELECT Id, Name, Customer_Code__c FROM Account WHERE Customer_Code__c != null
        ];

        Map<String, String> mapCustCode_AccId = new Map<String, String>();
        for (Account acc : existingAccounts) {
            mapCustCode_AccId.put(acc.Customer_Code__c, acc.Id);
        }

        for (customerWC custVal : customerValues) {
            // if (mapCustCode_AccId.containsKey(custVal.No) ) {
            //     System.debug(custVal.No);
            // } else {
                Account newAccount = new Account();
                if (mapCustCode_AccId.containsKey(custVal.No) ) {
                    newAccount.Id = mapCustCode_AccId.get(custVal.No);
                }
                if(custVal.No != null && custVal.No != ''){
                    newAccount.Customer_Code__c = custVal.No;
                }
                if(custVal.Name != null && custVal.Name != ''){
                    newAccount.Name = custVal.Name;
                } else {
                    newAccount.Name = custVal.No;
                }
                if(custVal.Address != null && custVal.Address != ''){
                    newAccount.BillingStreet = custVal.Address;
                }
                if(custVal.Address_2 != null && custVal.Address_2 != ''){
                    newAccount.ShippingStreet = custVal.Address_2;
                }
                if(custVal.City != null && custVal.City != ''){
                    newAccount.BillingCity = custVal.City;
                }
                if(custVal.Country_Region_Code != null && custVal.Country_Region_Code != ''){
                    newAccount.Country_Region_Code__c = custVal.Country_Region_Code;
                }
                if(custVal.Phone_No != null && custVal.Phone_No != ''){
                    newAccount.Phone = custVal.Phone_No;
                }
                if(custVal.Credit_Limit_LCY != null && custVal.Credit_Limit_LCY != ''){
                    newAccount.Credit_Limit_Requested__c = Decimal.valueOf(custVal.Credit_Limit_LCY);
                }
                if(custVal.Customer_Posting_Group != null && custVal.Customer_Posting_Group != ''){
                    newAccount.Customer_Posting_Group__c = custVal.Customer_Posting_Group;
                }
                if(custVal.Customer_Price_Group != null && custVal.Customer_Price_Group != ''){
                    newAccount.Customer_Price_Group__c = custVal.Customer_Price_Group;
                }
                if(custVal.Payment_Terms_Code != null && custVal.Payment_Terms_Code != ''){
                    newAccount.Payment_Terms_Code__c = custVal.Payment_Terms_Code;
                }
                if(custVal.Blocked != null && custVal.Blocked != '' && custVal.Blocked != '_blank_'){
                    newAccount.Blocked__c = custVal.Blocked;
                } else if (custVal.Blocked == '_blank_') {
                    newAccount.Blocked__c = null;
                }
                // newAccount.aaa = custVal.Last_Date_Modified;
                if(custVal.Gen_Bus_Posting_Group != null && custVal.Gen_Bus_Posting_Group != ''){
                    newAccount.Gen_Bus_Posting_Group__c = custVal.Gen_Bus_Posting_Group;
                }
                if(custVal.Post_Code != null && custVal.Post_Code != ''){
                    newAccount.BillingPostalCode = custVal.Post_Code;
                }
                if(custVal.P_A_N_No != null && custVal.P_A_N_No != ''){
                    newAccount.P_A_N_No__c = custVal.P_A_N_No;
                }
                if(custVal.E_Mail != null && custVal.E_Mail != ''){
                    newAccount.Email_Id__c = custVal.E_Mail;
                }
                if(custVal.State_Code != null && custVal.State_Code != ''){
                    newAccount.State_Code__c = custVal.State_Code;
                }
                if(custVal.GST_Registration_No != null && custVal.GST_Registration_No != ''){
                    newAccount.GST_Registration_No__c = custVal.GST_Registration_No;
                }
                if(custVal.GST_Registration_Type != null && custVal.GST_Registration_Type != ''){
                    newAccount.GST_Registration_Type__c = custVal.GST_Registration_Type;
                }
                if(custVal.GST_Customer_Type != null && custVal.GST_Customer_Type != '' && custVal.GST_Customer_Type != '_blank_'){
                    newAccount.GST_Customer_Type__c =custVal.GST_Customer_Type;
                }
                if(custVal.Customer_Type != null && custVal.Customer_Type != '' && custVal.Customer_Type != '_blank_'){
                    newAccount.Customer_Type__c =custVal.Customer_Type;
                }
                if(custVal.Turnover != null && custVal.Turnover != '' && custVal.Turnover != '_blank_'){
                    //newAccount.Turnover__c = custVal.Turnover;
                }
                if(custVal.ITR_Status != null && custVal.ITR_Status != '' && custVal.ITR_Status != '_blank_'){
                    //newAccount.ITR_Status__c = custVal.ITR_Status;
                }
                if(custVal.Whatsapp_Mobile_No != null && custVal.Whatsapp_Mobile_No != ''){
                    newAccount.Whatsapp_Mobile_No__c = custVal.Whatsapp_Mobile_No;
                }
                if(custVal.SalesOrderDetailEmail != null && custVal.SalesOrderDetailEmail != ''){
                    newAccount.SalesOrderDetailEmail__c = Boolean.valueOf(custVal.SalesOrderDetailEmail);
                }
                // newAccount.aaa = custVal.Creation_Date;
                if(custVal.Ofline_Order != null && custVal.Ofline_Order != ''){
                    newAccount.Ofline_Order__c = Boolean.valueOf(custVal.Ofline_Order);
                }
                if(custVal.Exclude_from_Loyalty_program != null && custVal.Exclude_from_Loyalty_program != ''){
                    newAccount.Exclude_from_Loyalty_program__c = Boolean.valueOf(custVal.Exclude_from_Loyalty_program);
                }
                if(custVal.DF_Finance_Customer != null && custVal.DF_Finance_Customer != ''){
                    newAccount.DF_Financial_Customer__c = Boolean.valueOf(custVal.DF_Finance_Customer);
                }
                if(custVal.DF_Finance_Customer_No != null && custVal.DF_Finance_Customer_No != ''){
                    newAccount.DF_Financial_Customer_No__c = custVal.DF_Finance_Customer_No;
                }
                newAccount.Balance__c=custVal.Balance;
                newAccount.Loyalty__c=custVal.Loyalty;
                accountsToInsert.add(newAccount);
            // }
        }


        if(accountsToInsert.size() > 0){
            // System.debug(accountsToInsert.size());
            //  insert accountsToInsert;
            // System.debug('DONEEEE');
            Database.UpsertResult[] srList = Database.upsert(accountsToInsert, false);
            set<Id> idsList = new set<Id> ();
            for(Database.UpsertResult sr : srList){
                    if (sr.isSuccess()) {
                        idsList.add(sr.getId());
                        System.debug('Upsert succeeded for record with ID: ' + sr.getId());
                    }else{
                        System.debug('failed order for record with ID: ' + sr.getId());
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('Error status code: ' + err.getStatusCode());
                            System.debug('Error message: ' + err.getMessage());
                        }
                    }
                    
                }
        }

    }

    public static String getPicklistValueByLabel(String objectApiName, String fieldApiName, String labelName) {
        // Describe the object
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        if (sObjectType == null) {
            throw new IllegalArgumentException('Invalid object name: ' + objectApiName);
        }

        // Describe the field
        Schema.DescribeSObjectResult objectDescribe = sObjectType.getDescribe();
        Schema.SObjectField field = objectDescribe.fields.getMap().get(fieldApiName);
        if (field == null) {
            throw new IllegalArgumentException('Invalid field name: ' + fieldApiName);
        }

        // Get picklist entries
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();

        // Find and return the value by label
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.getLabel().equalsIgnoreCase(labelName)) {
                return entry.getValue(); // Return the API value of the picklist
            }
        }

        // If not found, return null or throw an exception
        return null;
    }

    public class customerWC {
        public String No; // Customer_Code__c
        public String Name; // Name
        public String Address; // BillingStreet
        public String Address_2; // ShippingStreet
        public String City; // BillingCity
        public String Country_Region_Code; //Country_Region_Code__c
        public String Phone_No; // Phone
        public String Credit_Limit_LCY; // Credit_Limit_Requested__c
        public String Customer_Posting_Group; // Customer_Posting_Group__c
        public String Customer_Price_Group; // Customer_Price_Group__c
        public String Payment_Terms_Code; // Payment_Terms_Code__c
        public String Blocked; // Blocked__c
        public String Last_Date_Modified; // aaa
        public String Gen_Bus_Posting_Group; // Gen_Bus_Posting_Group__c
        public String Post_Code; // BillingPostalCode
        public String E_Mail; // Email_Id__c
        public String P_A_N_No; // P_A_N_No__c
        public String State_Code; // State_Code__c
        public String GST_Registration_No; // GST_Registration_No__c
        public String GST_Registration_Type; // GST_Registration_Type__c
        public String GST_Customer_Type; // GST_Customer_Type__c
        public String Customer_Type; // Customer_Type__c
        public String Turnover; // Turnover__c
        public String ITR_Status; // ITR_Status__c
        public String Whatsapp_Mobile_No; //Whatsapp_Mobile_No__c
        public String SalesOrderDetailEmail; // SalesOrderDetailEmail__c
        public String Creation_Date; // aaa
        public String Ofline_Order; // Ofline_Order__c
        public String Exclude_from_Loyalty_program; // Exclude_from_Loyalty_program__c
        public String DF_Finance_Customer; // DF_Financial_Customer__c
        public String DF_Finance_Customer_No; // DF_Financial_Customer_No__c
        public Decimal Balance; 
        public Decimal Loyalty; 
    }

}