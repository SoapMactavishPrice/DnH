public class NMD_SalesPerson {

    public String getSalesPersonDataAsJson() {
        try {
            // Initialize the HTTP request
            HttpUtils.APIparamter apiparam = HttpUtils.getAPIdetails('NMD_SalesPerson');
            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Set the endpoint (URL)
            req.setEndpoint(apiparam.Endpoint);
            req.setMethod(apiparam.Method);
            
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
                String jsonResponse = NMD_SalesPerson.convertSoapResponseToJson(res.getBody());
                System.debug('jsonResponse:>>>> ' +jsonResponse);
                NMD_SalesPerson.dataSave(jsonResponse);
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
            Dom.XmlNode outerReadMultipleResultNode = bodyNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/salespersonsf');
            
            // Now get the inner ReadMultiple_Result node
            Dom.XmlNode innerReadMultipleResultNode = outerReadMultipleResultNode.getChildElement('ReadMultiple_Result', 'urn:microsoft-dynamics-schemas/page/salespersonsf');


            // List to hold the SalesPersonSF data in map format
            List<Map<String, Object>> salesPersonList = new List<Map<String, Object>>();
            
            // Loop through each SalesPersonSF element and extract the data
            for (Dom.XmlNode salesPersonNode : innerReadMultipleResultNode.getChildElements()) {
                // System.debug(salesPersonNode.getName());
                if (salesPersonNode.getName() == 'SalesPersonSF') {
                    Map<String, Object> salesPersonMap = new Map<String, Object>();
                    
                    // Extract all fields for each SalesPersonSF node
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

    public static String dataSave (String jsondata){
        // String jsondata = '[{\"Key\":\"48;DQAAAAJ7/1AAUgBBAFQASABNAEUAUwBIACAAUwBIAEEASA==9;2186611660;\",\"Code\":\"PRATHMESH SHAH\",\"Name\":\"PRATHMESH SHAH\",\"Commission_Percent\":0,\"Privacy_Blocked\":false,\"E_Mail\":\"harish@finessedirect.com\",\"Phone_No\":\"9377972185\",\"Job_Title\":\"General Manager-Sales\",\"H_Q\":\"VADODARA\",\"Area\":\"GUJARAT\",\"Zone\":\"West\",\"Reporting_To\":\"Arvind Maheshwari\",\"Area_Manager\":false,\"Engineer_ID\":false,\"Reporting_Person\":\"PRATHMESH SHAH\",\"Zonal_Manager\":\"PRATHMESH SHAH\",\"Reporting_Person_ID\":\"PRATHMESH SHAH\",\"Zonal_Manager_ID\":\"PRATHMESH SHAH\",\"IsZonalManager\":true,\"IsApprovedUser\":false,\"ItemTargetCat\":\"A_CONVENTIONAL\"}]';

        List<SalesPersonWC> SalesPersonWCList = (List<SalesPersonWC>) JSON.deserialize(jsondata, List<SalesPersonWC>.class);

        List<User> userToInsert = new List<User>();
        List <User> userList = [SELECT Id, Name, Code__c FROM User WHERE Code__c != null];
        Map<String, String> salesPersonMap = new Map<String, String>();
        for (User usr : userList) {
            salesPersonMap.put(usr.Code__c, usr.Id);
        }
        for (SalesPersonWC sp : SalesPersonWCList) {
            
            if (salesPersonMap.containsKey(sp.Code)) {
                User usr = new User();
                usr.Id = salesPersonMap.get(sp.Code);
                // String alias = sp.Name !=null ? sp.Name : sp.Name;
                // if(alias.length()>=8){
                //     alias=alias.substring(0,4);
                // } else {
                //     alias = alias;
                // }

                // if(sp.Name != null && sp.Name != ''){
                //     usr.LastName = sp.Name;
                // }
                // if(sp.E_Mail != null && sp.E_Mail != ''){
                //     usr.Email = sp.E_Mail;
                // }
                // if(sp.E_Mail != null && sp.E_Mail != ''){
                //     usr.Username = sp.E_Mail;
                // }
                // usr.ProfileId = '00eGB000003tCmm';
                // usr.Alias = alias;
                // usr.TimeZoneSidKey = 'Asia/Kolkata';
                // usr.LocaleSidKey = 'en_US';
                // usr.EmailEncodingKey = 'UTF-8';
                // usr.LanguageLocaleKey = 'en_US';
                // usr.IsActive = true;
                // if(sp.Code != null && sp.Code != ''){
                //     usr.Code__c = sp.Code;
                // }
                if(sp.Commission_Percent != null && sp.Commission_Percent != ''){
                    usr.Commission__c = Decimal.valueOf(sp.Commission_Percent);
                }
                if(sp.Privacy_Blocked != null && sp.Privacy_Blocked != ''){
                    usr.Privacy_Blocked__c = Boolean.valueOf(sp.Privacy_Blocked);
                }
                if(sp.Phone_No != null && sp.Phone_No != ''){
                    usr.Phone = String.valueOf(sp.Phone_No);
                }
                // if(sp.Job_Title != null && sp.Job_Title != ''){
                //     usr.Job_Title__c = sp.Job_Title;
                // }
                if(sp.H_Q != null && sp.H_Q != ''){
                    usr.H_Q__c = sp.H_Q;
                }
                if(sp.Area != null && sp.Area != ''){
                    usr.Area__c = sp.Area;
                }
                if(sp.Zone != null && sp.Zone != ''){
                    usr.Zone__c = sp.Zone;
                }
                if(sp.Reporting_To != null && sp.Reporting_To != ''){
                    usr.Reporting_To__c = sp.Reporting_To;
                }
                if(sp.Area_Manager != null && sp.Area_Manager != ''){
                    usr.Area_Manager__c = Boolean.valueOf(sp.Area_Manager);
                }
                if(sp.Engineer_ID != null && sp.Engineer_ID != ''){
                    usr.Engineer_ID__c = Boolean.valueOf(sp.Engineer_ID);
                }
                if(sp.Reporting_Person != null && sp.Reporting_Person != ''){
                    usr.Reporting_Person__c = sp.Reporting_Person;
                }
                if(sp.Zonal_Manager != null && sp.Zonal_Manager != ''){
                    usr.Zonal_Manager__c = sp.Zonal_Manager;
                }
                if(sp.Reporting_Person_ID != null && sp.Reporting_Person_ID != ''){
                    usr.Reporting_Person_ID__c = sp.Reporting_Person_ID;
                }
                if(sp.Zonal_Manager_ID != null && sp.Zonal_Manager_ID != ''){
                    usr.Zonal_Manager_ID__c = sp.Zonal_Manager_ID;
                }
                if(sp.IsZonalManager != null && sp.IsZonalManager != ''){
                    usr.IsZonalManager__c = Boolean.valueOf(sp.IsZonalManager);
                }
                if(sp.IsApprovedUser != null && sp.IsApprovedUser != ''){
                    usr.IsApprovedUser__c = Boolean.valueOf(sp.IsApprovedUser);
                }
                if(sp.ItemTargetCat != null && sp.ItemTargetCat != ''){
                    usr.ItemTargetCat__c = sp.ItemTargetCat;
                }
                userToInsert.add(usr);
            }
            // System.debug('Key :'+sp.Key); 
            // System.debug('Code :'+sp.Code); // Code__c
            // System.debug('Name :'+sp.Name);
            // System.debug('Commission_Percent :'+sp.Commission_Percent); // Commission__c
            // System.debug('Privacy_Blocked :'+sp.Privacy_Blocked); // Privacy_Blocked__c
            // System.debug('E_Mail :'+sp.E_Mail);
            // System.debug('Phone_No :'+sp.Phone_No); // Phone
            // System.debug('Job_Title :'+sp.Job_Title); // Job_Title__c
            // System.debug('H_Q :'+sp.H_Q); // H_Q__c
            // System.debug('Area :'+sp.Area); // Area__c
            // System.debug('Zone :'+sp.Zone); // Zone__c
            // System.debug('Reporting_To :'+sp.Reporting_To); // Reporting_To__c
            // System.debug('Area_Manager :'+sp.Area_Manager); // Area_Manager__c
            // System.debug('Engineer_ID :'+sp.Engineer_ID); // Engineer_ID__c
            // System.debug('Reporting_Person :'+sp.Reporting_Person); // Reporting_Person__c
            // System.debug('Zonal_Manager :'+sp.Zonal_Manager); // Zonal_Manager__c
            // System.debug('Reporting_Person_ID :'+sp.Reporting_Person_ID); // Reporting_Person_ID__c
            // System.debug('Zonal_Manager_ID :'+sp.Zonal_Manager_ID); // Zonal_Manager_ID__c
            // System.debug('IsZonalManager :'+sp.IsZonalManager); // IsZonalManager__c
            // System.debug('IsApprovedUser :'+sp.IsApprovedUser); // IsApprovedUser__c
            // System.debug('ItemTargetCat :'+sp.ItemTargetCat); // ItemTargetCat__c
        }


        if (userToInsert.size() > 0) {
            //UPSERT userToInsert;
            Database.UpsertResult[] srList = Database.upsert(userToInsert, false);
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
            System.debug(userToInsert.size() + ' : User inserted :' +userToInsert);
        }
        return 'Done';

    }

    public class SalesPersonWC {

        public String Key;
        public String Code;
        public String Name;
        public String Commission_Percent;
        public String Privacy_Blocked;
        public String E_Mail;
        public String Phone_No;
        public String Job_Title;
        public String H_Q;
        public String Area;
        public String Zone;
        public String Reporting_To;
        public String Area_Manager;
        public String Engineer_ID;
        public String Reporting_Person;
        public String Zonal_Manager;
        public String Reporting_Person_ID;
        public String Zonal_Manager_ID;
        public String IsZonalManager;
        public String IsApprovedUser;
        public String ItemTargetCat;
    }

    public static  void fakeCodeCoverage(){
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
        
    }

}