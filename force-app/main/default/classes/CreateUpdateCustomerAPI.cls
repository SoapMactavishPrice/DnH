@RestResource(urlMapping='/CreateUpdateCustomer')
global class CreateUpdateCustomerAPI {
    @HttpPost
    global static void doPost() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');
        
        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'CreateUpdateCustomer';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();

        JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        System.debug('======----->jsonObj' + jsonObj);

        try {
            String sCustomerNo = '';
            String sSFID = '';
            Account acc = new Account();

            if (jsonObj.SFID != '' && jsonObj.SFID != null) {

                List<Account> acc2 = [
                    SELECT Id, Phone, Customer_Code__c
                    FROM Account
                    WHERE Id =: jsonObj.SFID
                    ORDER BY createddate DESC
                    LIMIT 1
                ];

                acc.Id = acc2[0].Id;
                if (acc2[0].Customer_Code__c != null) {
                    sCustomerNo = acc2[0].Customer_Code__c;
                } else {
                    acc.Customer_Code__c = jsonObj.CustomerNo;
                    sCustomerNo = jsonObj.CustomerNo;
                }
                
            } else {
                
                List<Account> acc2 = [
                    SELECT Id, Phone, Customer_Code__c
                    FROM Account
                    WHERE Customer_Code__c =: jsonObj.CustomerNo
                    ORDER BY createddate DESC
                    LIMIT 1
                ];
                    
                if (acc2.size() > 0) {
                    acc.Id = acc2[0].Id;
                    sCustomerNo = acc2[0].Customer_Code__c;
                } else {
                    acc.Customer_Code__c = jsonObj.CustomerNo;
                    sCustomerNo = jsonObj.CustomerNo;
                }
            }

            if (!String.isBlank(jsonObj.Name)) {
                acc.Name = jsonObj.Name;
            }
            if (!String.isBlank(jsonObj.BillingAddress)) {
                acc.BillingStreet = jsonObj.BillingAddress;
            }
            if (!String.isBlank(jsonObj.ShippingAddress)) {
                acc.ShippingStreet = jsonObj.ShippingAddress;
            }
            if (!String.isBlank(jsonObj.Country_Region_Code)) {
                acc.Country_Region_Code__c = jsonObj.Country_Region_Code;
            }
            if (jsonObj.Blocked != null) { // Assuming Blocked is a Boolean field
                acc.Blocked__c = jsonObj.Blocked;
            }
            if (!String.isBlank(jsonObj.Contact)) {
                acc.Contact__c = jsonObj.Contact;
            }
            if (!String.isBlank(jsonObj.Global_Dimension_1_Code)) {
                acc.Global_Dimension_1_Code__c = jsonObj.Global_Dimension_1_Code;
            }
            if (!String.isBlank(jsonObj.Global_Dimension_2_Code)) {
                acc.Global_Dimension_2_Code__c = jsonObj.Global_Dimension_2_Code;
            }
            
            if (jsonObj.Credit_Limit_Requested != null && jsonObj.Credit_Limit_Requested != '') {
                acc.Credit_Limit_Requested__c = Decimal.valueOf(jsonObj.Credit_Limit_Requested);
            }
            if (!String.isBlank(jsonObj.Customer_Posting_Group)) {
                acc.Customer_Posting_Group__c = jsonObj.Customer_Posting_Group;
            }
            if (!String.isBlank(jsonObj.Customer_Price_Group)) {
                acc.Customer_Price_Group__c = jsonObj.Customer_Price_Group;
            }
            if (!String.isBlank(jsonObj.Payment_Terms_Code)) {
                acc.Payment_Terms_Code__c = jsonObj.Payment_Terms_Code;
            }
            if (!String.isBlank(jsonObj.Customer_Disc_Group)) {
                acc.Customer_Disc_Group__c = jsonObj.Customer_Disc_Group;
            }
            if (!String.isBlank(jsonObj.Gen_Bus_Posting_Group)) {
                acc.Gen_Bus_Posting_Group__c = jsonObj.Gen_Bus_Posting_Group;
            }
            if (!String.isBlank(jsonObj.Email_Id)) {
                acc.Email_Id__c = jsonObj.Email_Id;
            }
            if (!String.isBlank(jsonObj.P_A_N_No)) {
                acc.P_A_N_No__c = jsonObj.P_A_N_No;
            }
            if (!String.isBlank(jsonObj.State_Code)) {
                acc.State_Code__c = jsonObj.State_Code;
            }
            if (!String.isBlank(jsonObj.Structure)) {
                acc.Structure__c = jsonObj.Structure;
            }
            if (!String.isBlank(jsonObj.GST_Number)) {
                acc.GST_Number__c = jsonObj.GST_Number;
            }
            if (!String.isBlank(jsonObj.GST_Registration_Type)) {
                acc.GST_Registration_Type__c = jsonObj.GST_Registration_Type;
            }
            if (!String.isBlank(jsonObj.GST_Customer_Type)) {
                acc.GST_Customer_Type__c = jsonObj.GST_Customer_Type;
            }
            if (!String.isBlank(jsonObj.Customer_Type)) {
                acc.Customer_Type__c = jsonObj.Customer_Type;
            }
            if (!String.isBlank(jsonObj.Turnover)) {
                acc.Turnover__c = jsonObj.Turnover;
            }
            if (!String.isBlank(jsonObj.ITR_Status)) {
                acc.ITR_Status__c = jsonObj.ITR_Status;
            }
            if (!String.isBlank(jsonObj.Whatsapp_Mobile_No)) {
                acc.Whatsapp_Mobile_No__c = jsonObj.Whatsapp_Mobile_No;
            }
            
            if (jsonObj.SalesOrderDetailEmail != null && jsonObj.SalesOrderDetailEmail != '') {
                acc.SalesOrderDetailEmail__c = Boolean.valueOf(jsonObj.SalesOrderDetailEmail);
            }
            if (jsonObj.Ofline_Order != null && jsonObj.Ofline_Order != '') {
                acc.Ofline_Order__c = Boolean.valueOf(jsonObj.Ofline_Order);
            }
            
            if (jsonObj.Exclude_from_Loyalty_program != null && jsonObj.Exclude_from_Loyalty_program != '') {
                acc.Exclude_from_Loyalty_program__c = Boolean.valueOf(jsonObj.Exclude_from_Loyalty_program);
            }
            if (jsonObj.DF_Financial_Customer != null && jsonObj.DF_Financial_Customer != '') {
                acc.DF_Financial_Customer__c = Boolean.valueOf(jsonObj.DF_Financial_Customer);
            }
            if (!String.isBlank(jsonObj.tranPart1)) {
                acc.tranPart1__c = jsonObj.tranPart1;
            }
            if (!String.isBlank(jsonObj.tranPart2)) {
                acc.tranPart2__c = jsonObj.tranPart2;
            }
            if (!String.isBlank(jsonObj.DF_Financial_Customer_No)) {
                acc.DF_Financial_Customer_No__c = jsonObj.DF_Financial_Customer_No;
            }
            if (!String.isBlank(jsonObj.Phone)) {
                acc.Phone = jsonObj.Phone;
            }            

            upsert acc;

            System.debug('-->Data Saved Successfully');
            // ------------------- Send the Success Response -------------------
            Map < string, string > successResMap = new Map < string, string > ();
            successResMap.put('status', 'success');
            successResMap.put('message', 'Done');
            successResMap.put('SFId', acc.Id);
            successResMap.put('CustomerNo', sCustomerNo);
            String resp = JSON.serialize(successResMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;

            api_log.Log_Status__c = 'Success';
            api_log.Response_Code__c = '200';
            api_log.Response__c = String.valueOf(resp);
            api_log.response_time__c = Datetime.now();

        } catch (Exception e) {
            System.debug('Catch Error' + e.getStackTraceString());
            System.debug('Catch Error' + e.getMessage());
            System.debug('Catch Error' + e.getlineNumber());

            // ------------------- Create Response Map -------------------
            Map < string, string > errorResMap = new Map < string, string > ();
            errorResMap.put('Message', 'Something went wrong');
            errorResMap.put('Error1', e.getMessage());
            errorResMap.put('Error2', '' + e.getlineNumber());
            errorResMap.put('Error3', '' + String.valueOf(e));

            // ------------------- Send Response Map -------------------
            String resp = JSON.serialize(errorResMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();
            
        }
        
        insert api_log;
    }
    
    public class JSON2ApexSaveWebToLead {
        public String SFID;
        public String CustomerNo;
        public String Name;
        public String BillingAddress;
        public String ShippingAddress;
        public String Country_Region_Code;
        public String Blocked;
        public String Contact;
        public String Global_Dimension_1_Code;
        public String Global_Dimension_2_Code;
        public String Credit_Limit_Requested;
        public String Customer_Posting_Group;
        public String Customer_Price_Group;
        public String Payment_Terms_Code;
        public String Customer_Disc_Group;
        public String Gen_Bus_Posting_Group;
        public String Email_Id;
        public String Phone;
        public String P_A_N_No;
        public String State_Code;
        public String Structure;
        public String GST_Number;
        public String GST_Registration_Type;
        public String GST_Customer_Type;
        public String Customer_Type;
        public String Turnover;
        public String ITR_Status;
        public String Whatsapp_Mobile_No;
        public String SalesOrderDetailEmail;
        public String Ofline_Order;
        public String tranPart1;
        public String tranPart2;
        public String Exclude_from_Loyalty_program;
        public String DF_Financial_Customer;
        public String DF_Financial_Customer_No;
        
        
        // public String Type;
        // public String Customer_Code;
        // public String Customer_Group;
        // public String Focus_Customer;
        // public String Repeat_Calls_Allowed;
        // public String Customer_Category;
        // public String Year_of_Establishment;
        // public String Sales_Turnover;
        // public String Territory;
        // public String Creation_Date;
        // public String Parent_AccountId;
        // public String Customer_Dealer;
        // public String Industry;
        // public String NumberOfEmployees;
        // public String Key_Person;
        // public String Pan_No;
        // public String CIN_Number;
        // public String GST_Type;
        // public String GSTIN_No;
        // public String Customer_Remarks;
        // public String Mobile_Number_1;
        // public String Website;
        // public String Credit_Limit_LYC;
        // public String Approved_Credit_Limit;
        // public String Approved_Credit_Limit_Date;
        // public String Utilised_Credit_Limit;
        // public String Utilised_Credit_Updated_Date;
        // public String Available_Credit_Limit;
        // public String Credit_Insurance;
        // public String Credit_Period;
        // public String Open_Orders;
        // public String Outstanding_Invoices;
        // public String Inco_Terms;
        // public String Payment_Terms;
        // public String Delivery_Terms;
        // public String Inco_Terms_Remark;
        // public String Other_Payment_Terms;
        // public String Other_Delivery_Terms;
        // public String Pricelist;
        // public String Description;
    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }

}