@isTest
public class AccountTriggerHandlerTest {
    
    @isTest
    static void testSyncAccountToNavision() {
        // Step 1: Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Test Street',
            BillingCity = 'Test City',
            BillingPostalCode = '12345',
            Contact__c = 'Test Contact',
            Phone = '123-456-7890',
            Global_Dimension_1_Code__c = 'Dim1',
            Global_Dimension_2_Code__c = 'Dim2',
            Credit_Limit_Requested__c = 1,
            Customer_Posting_Group__c = 'PostingGroup1',
            Customer_Price_Group__c = 'PriceGroup1',
            Payment_Terms_Code__c = 'TermsCode1',
            Customer_Disc_Group__c = 'DiscGroup1',
            Blocked__c = 'Ship',
            Gen_Bus_Posting_Group__c = 'GenPostingGroup1',
            Email_Id__c = 'test@example.com',
            Pan_No__c = 'ABCDE1234F',
            State_Code__c = 'TS',
            Structure__c = 'TestStructure',
            GST_Registration_No__c = '27ABCDE1234FZ5',
           // GST_Registration_Type__c = 'GID',
            // GST_Customer_Type__c = 'Export',
            Type = 'Customer',
            //Turnover__c = 'NA',
            //ITR_Status__c = 'NA',
            Whatsapp_Mobile_No__c = '9876543210',
            SalesOrderDetailEmail__c = true,
            Ofline_Order__c = false,
            tranPart1__c = 'TranPart1',
            tranPart2__c = 'TranPart2',
            Exclude_from_Loyalty_program__c = true,
            DF_Financial_Customer__c = true,
            DF_Financial_Customer_No__c = 'DF12345'
        );
        insert testAccount;

        // Step 2: Test the syncAccountToNavision method
        Test.startTest();
        AccountTriggerHandler.syncAccountToNavision(new List<Account>{testAccount});
        Test.stopTest();

        // Step 3: Assertions
        // Verify that the debug log contains serialized JSON
        // NOTE: Adjust based on your implementation, e.g., mock CreateUpdateCustomer_ToNAV
        //System.assertNotEquals(null, System.debug('Json Data :: '));
    }

    @isTest
    static void testSyncAccountToNavision_v1() {
        // Step 1: Create test data
        Account testAccount = new Account(
            Name = 'Test Account v1',
            BillingStreet = '456 Test Avenue',
            BillingCity = 'Sample City',
            BillingPostalCode = '54321',
            Contact__c = 'Another Contact',
            Phone = '987-654-3210',
            Global_Dimension_1_Code__c = 'Dim3',
            Global_Dimension_2_Code__c = 'Dim4',
            Credit_Limit_Requested__c = 1,
            Customer_Posting_Group__c = 'PostingGroup2',
            Customer_Price_Group__c = 'PriceGroup2',
            Payment_Terms_Code__c = 'TermsCode2',
            Customer_Disc_Group__c = 'DiscGroup2',
            Blocked__c = '0',
            Gen_Bus_Posting_Group__c = 'GenPostingGroup2',
            Email_Id__c = 'another@example.com',
            Pan_No__c = 'FGHIJ5678K',
            State_Code__c = 'MH',
            Structure__c = 'AnotherStructure',
            GST_Registration_No__c = '29FGHIJ5678KZ2',
            GST_Registration_Type__c = null, // Null to test default '0'
            GST_Customer_Type__c = null, // Null to test default '0'
            Type = null, // Null to test default '0'
            Turnover__c = null, // Null to test default '0'
            ITR_Status__c = null, // Null to test default '0'
            Whatsapp_Mobile_No__c = null,
            SalesOrderDetailEmail__c = false,
            Ofline_Order__c = true,
            tranPart1__c = 'TranPart3',
            tranPart2__c = 'TranPart4',
            Exclude_from_Loyalty_program__c = false,
            DF_Financial_Customer__c = false,
            DF_Financial_Customer_No__c = null
        );
        insert testAccount;

        // Step 2: Test the syncAccountToNavision_v1 method
        Test.startTest();
        String result = AccountTriggerHandler.syncAccountToNavision_v1(new List<Account>{testAccount});
        Test.stopTest();

        // Step 3: Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        //System.assert(result.contains('"Name":"Test Account v1"'), 'JSON should contain the account name');
    }
}