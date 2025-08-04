public class AccountTriggerHandler {
    
    public static void syncAccountToNavision(List<Account> newAccount){

        List<Map<String, String>> accountList = new List<Map<String, String>>();
        
        for (Account accItem : newAccount) {
            
            Map<String, String> customerMap = new Map<String, String>();

            // Adding key-value pairs to the map
            customerMap.put('Name', accItem.Name); // Name
            customerMap.put('Address', accItem.BillingStreet); // BillingStreet
            customerMap.put('Address2', ''); // 
            customerMap.put('City', accItem.BillingCity); // BillingCity
            // customerMap.put('CountryRegionCode', ); 
            customerMap.put('Contact', accItem.Contact__c); // Contact__c
            customerMap.put('PhoneNo', accItem.Phone); // Phone
            customerMap.put('PostCode', accItem.BillingPostalCode);
            customerMap.put('GlobalDimension1Code', accItem.Global_Dimension_1_Code__c); // Global_Dimension_1_Code__c
            customerMap.put('GlobalDimension2Code', accItem.Global_Dimension_2_Code__c); // Global_Dimension_2_Code__c
            customerMap.put('CreditLimitLCY', String.valueOf(accItem.Credit_Limit_Requested__c) == 'true' ? '1' : '0'); // Credit_Limit_Requested__c
            customerMap.put('CustomerPostingGroup', accItem.Customer_Posting_Group__c); // Customer_Posting_Group__c
            customerMap.put('CurrencyCode', '');
            customerMap.put('CustomerPriceGroup', accItem.Customer_Price_Group__c); // Customer_Price_Group__c
            customerMap.put('Payment Terms Code', accItem.Payment_Terms_Code__c); // Payment_Terms_Code__c
            customerMap.put('CustomerDiscGroup', accItem.Customer_Disc_Group__c); // Customer_Disc_Group__c
            customerMap.put('Blocked', accItem.Blocked__c == null ? '0' : accItem.Blocked__c); // Blocked__c
            customerMap.put('GenBusPostingGroup', accItem.Gen_Bus_Posting_Group__c); // Gen_Bus_Posting_Group__c
            // customerMap.put('PostCode', '400702'); // Notice the second PostCode in your JSON (IMP)
            customerMap.put('EMail', accItem.Email_Id__c); // Email_Id__c
            customerMap.put('PANNo', accItem.Pan_No__c); // Pan_No__c
            customerMap.put('StateCode', accItem.State_Code__c); // State_Code__c
            customerMap.put('Structure', accItem.Structure__c); // Structure__c
            customerMap.put('GSTRegistrationNo', accItem.GST_Registration_No__c); // GST_Registration_No__c
            customerMap.put('GSTRegistrationType', accItem.GST_Registration_Type__c == null ? '0' : accItem.GST_Registration_Type__c); // GST_Registration_Type__c
            customerMap.put('GSTCustomerType', accItem.GST_Customer_Type__c == null ? '0' : accItem.GST_Customer_Type__c); // GST_Customer_Type__c
            customerMap.put('CustomerType', accItem.Type == null ? '0' : accItem.Type); // Type
            customerMap.put('Turnover', accItem.Turnover__c == null ? '0' : accItem.Turnover__c); // Turnover__c
            customerMap.put('ITRStatus', accItem.ITR_Status__c == null ? '0' : accItem.ITR_Status__c); // ITR_Status__c
            customerMap.put('WhatsappMobileNo', accItem.Whatsapp_Mobile_No__c); // Whatsapp_Mobile_No__c
            customerMap.put('SalesOrderDetailEmail', String.valueOf(accItem.SalesOrderDetailEmail__c) == 'true' ? '1' : '0'); // SalesOrderDetailEmail__c
            customerMap.put('OflineOrder', String.valueOf(accItem.Ofline_Order__c) == 'true' ? '1' : '0'); // Ofline_Order__c
            customerMap.put('tranParticularstranPart1', accItem.tranPart1__c); // tranPart1__c
            customerMap.put('tranParticularstranPart2', accItem.tranPart2__c); // tranPart2__c
            customerMap.put('ExcludefromLoyaltyprogram', String.valueOf(accItem.Exclude_from_Loyalty_program__c) == 'true' ? '1' : '0'); // Exclude_from_Loyalty_program__c
            customerMap.put('DFFinanceCustomer', String.valueOf(accItem.DF_Financial_Customer__c) == 'true' ? '1' : '0'); // DF_Financial_Customer__c
            customerMap.put('DFFinanceCustomerNo', accItem.DF_Financial_Customer_No__c); // DF_Financial_Customer_No__c
            accountList.add(customerMap);
        }

        String jsonData = JSON.serialize(accountList);
        System.debug('Json Data :: ' + jsonData);
        
        CreateUpdateCustomer_ToNAV.insertUpdateCustomerData(jsonData, newAccount[0].Id);

    }

    public static String syncAccountToNavision_v1(List<Account> newAccount){

        List<Map<String, String>> accountList = new List<Map<String, String>>();
        
        for (Account accItem : newAccount) {
            
            Map<String, String> customerMap = new Map<String, String>();

            // Adding key-value pairs to the map
            customerMap.put('Name', accItem.Name); // Name
            customerMap.put('Address', accItem.BillingStreet); // BillingStreet
            customerMap.put('Address2', ''); // 
            customerMap.put('City', accItem.BillingCity); // BillingCity
            // customerMap.put('CountryRegionCode', ); 
            customerMap.put('Contact', accItem.Contact__c); // Contact__c
            customerMap.put('PhoneNo', accItem.Phone); // Phone
            customerMap.put('PostCode', accItem.BillingPostalCode);
            customerMap.put('GlobalDimension1Code', accItem.Global_Dimension_1_Code__c); // Global_Dimension_1_Code__c
            customerMap.put('GlobalDimension2Code', accItem.Global_Dimension_2_Code__c); // Global_Dimension_2_Code__c
            customerMap.put('CreditLimitLCY', String.valueOf(accItem.Credit_Limit_Requested__c) == 'true' ? '1' : '0'); // Credit_Limit_Requested__c
            customerMap.put('CustomerPostingGroup', accItem.Customer_Posting_Group__c); // Customer_Posting_Group__c
            customerMap.put('CurrencyCode', '');
            customerMap.put('CustomerPriceGroup', accItem.Customer_Price_Group__c); // Customer_Price_Group__c
            customerMap.put('Payment Terms Code', accItem.Payment_Terms_Code__c); // Payment_Terms_Code__c
            customerMap.put('CustomerDiscGroup', accItem.Customer_Disc_Group__c); // Customer_Disc_Group__c
            customerMap.put('Blocked', accItem.Blocked__c == null ? '0' : accItem.Blocked__c); // Blocked__c
            customerMap.put('GenBusPostingGroup', accItem.Gen_Bus_Posting_Group__c); // Gen_Bus_Posting_Group__c
            // customerMap.put('PostCode', '400702'); // Notice the second PostCode in your JSON (IMP)
            customerMap.put('EMail', accItem.Email_Id__c); // Email_Id__c
            customerMap.put('PANNo', accItem.Pan_No__c); // Pan_No__c
            customerMap.put('StateCode', accItem.State_Code__c); // State_Code__c
            customerMap.put('Structure', accItem.Structure__c); // Structure__c
            customerMap.put('GSTRegistrationNo', accItem.GST_Registration_No__c); // GST_Registration_No__c
            customerMap.put('GSTRegistrationType', accItem.GST_Registration_Type__c == null ? '0' : accItem.GST_Registration_Type__c); // GST_Registration_Type__c
            customerMap.put('GSTCustomerType', accItem.GST_Customer_Type__c == null ? '0' : accItem.GST_Customer_Type__c); // GST_Customer_Type__c
            customerMap.put('CustomerType', accItem.Type == null ? '0' : accItem.Type); // Type
            customerMap.put('Turnover', accItem.Turnover__c == null ? '0' : accItem.Turnover__c); // Turnover__c
            customerMap.put('ITRStatus', accItem.ITR_Status__c == null ? '0' : accItem.ITR_Status__c); // ITR_Status__c
            customerMap.put('WhatsappMobileNo', accItem.Whatsapp_Mobile_No__c); // Whatsapp_Mobile_No__c
            customerMap.put('SalesOrderDetailEmail', String.valueOf(accItem.SalesOrderDetailEmail__c) == 'true' ? '1' : '0'); // SalesOrderDetailEmail__c
            customerMap.put('OflineOrder', String.valueOf(accItem.Ofline_Order__c) == 'true' ? '1' : '0'); // Ofline_Order__c
            customerMap.put('tranParticularstranPart1', accItem.tranPart1__c); // tranPart1__c
            customerMap.put('tranParticularstranPart2', accItem.tranPart2__c); // tranPart2__c
            customerMap.put('ExcludefromLoyaltyprogram', String.valueOf(accItem.Exclude_from_Loyalty_program__c) == 'true' ? '1' : '0'); // Exclude_from_Loyalty_program__c
            customerMap.put('DFFinanceCustomer', String.valueOf(accItem.DF_Financial_Customer__c) == 'true' ? '1' : '0'); // DF_Financial_Customer__c
            customerMap.put('DFFinanceCustomerNo', accItem.DF_Financial_Customer_No__c); // DF_Financial_Customer_No__c
            accountList.add(customerMap);
        }

        String jsonData = JSON.serialize(accountList);
        System.debug('Json Data :: ' + jsonData);
        
        return CreateUpdateCustomer_ToNAV.insertUpdateCustomerData_v1(jsonData, newAccount[0].Id);

    }

}