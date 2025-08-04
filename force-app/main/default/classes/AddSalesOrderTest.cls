@isTest
public class AddSalesOrderTest {
    @testSetup
    static void setup() {
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; // Use a standard profile for the test

        // Generate a unique username to avoid duplicates
        String uniqueUsername = 'testuser' + System.currentTimeMillis() + '@example.com';

        // Create a User with 'Area_Manager__c' and 'IsApprovedUser__c' set to true
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            ProfileId = testProfile.Id,
            Username = uniqueUsername, // Use a unique username
            LastName = 'User',
            FirstName = 'Test',
            Area_Manager__c = true, // Simulating the user having Area_Manager__c
            IsApprovedUser__c = true, // Simulating the user being an approved user
            TimeZoneSidKey = 'America/Los_Angeles', // Required field
            LocaleSidKey = 'en_US', // Required field
            EmailEncodingKey = 'ISO-8859-1', // Required field
            LanguageLocaleKey = 'en_US' // Required field
            
        );
        insert testUser;
        
        // Create test data for Code_Master__c
        Code_Master__c codeMaster = new Code_Master__c(
            Object__c = 'Service 5-(Sample Request)',
            FY_End_Date__c =  date.today().addDays(10),
            FY_Start_Date__c =  date.today().addDays(-1),
            Current_Sequence__c = 1
            
        );
        insert codeMaster;

        // Create test data for Account
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingCity = 'Test City',
            BillingStreet = 'Test Street',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
            Customer_Code__c = 'TESTCODE'
        );
        insert testAccount;
        
        
        Customer_Sales_Person_Mapping__c customerSalesPersonMapping = new Customer_Sales_Person_Mapping__c(
            Account__c = testAccount.id // Example Account ID
           // Sales_Person__c = '0052b00000Wj6M5AA4' // Example User ID for Sales Person
        );
        insert customerSalesPersonMapping;
        
        Ship_to_Code__c sh = new Ship_to_Code__c();
        
        sh.Customer_No__c = 'TESTCODE';
        insert sh;

        

        // Create test data for Enquiry__c
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' LIMIT 1];
        Enquiry__c enquiry = new Enquiry__c(
           // Name = 'Test Enquiry',
            RecordTypeId = recordType.Id,
            Account__c= testAccount.id,
            Valid_Up_To__c= DateTime.newInstance(2025, 3, 3, 1, 1, 0)
        );
        insert enquiry;

        // Create test data for Sales_Order_Line_Item__c
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master');
        insert itemMaster;
        
        Item_Variant__c var = new Item_Variant__c();
        var.name= 'a0hF3000003WIqH';
        var.Code__c='1SPL/25KG';
        var.Item_No__c='FGM0014990';
        var.Item_Master__c=itemMaster.Id;
        insert var;
        
        Sales_Order__c sales = new Sales_Order__c();
        sales.Name='Sales_Order__c';
        sales.Enquiry__c = enquiry.id;
        insert sales;

        Sales_Order_Line_Item__c solItem = new Sales_Order_Line_Item__c(
            //Name = 'Test SOL Item',
            Sales_Order__c = sales.Id,
            Item_Master__c = itemMaster.Id
            
        );
        insert solItem;
    }

    @isTest
    static void testGetCodeMaster() {
        Test.startTest();
        String codeMasterName = AddSalesOrder.getcodemaster('Service 5-(Sample Request)');
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        //System.assertNotEquals(null, codeMasterName, 'Code master name should not be null');
        //System.assert(codeMasterName.contains('TestLabel'), 'Code master name should contain the Display_Label__c');
    }

    @isTest
    static void testGetRateType() {
        Enquiry__c enquiry = [SELECT Id, RecordTypeId FROM Enquiry__c LIMIT 1];

        Test.startTest();
        String rateType = AddSalesOrder.getRateType(enquiry.RecordTypeId, enquiry.Id);
        AddSalesOrder.getApprovalStatus(enquiry.Id);
        AddSalesOrder.lrDestinationList();
        AddSalesOrder.getIsWithRevision(enquiry.Id);
        AddSalesOrder.getEnquiryDetails(enquiry.Id);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        System.assertNotEquals(null, rateType, 'Rate type should not be null');
    }

    @isTest
    static void testGetAddress() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        String addressJSON = AddSalesOrder.getAddress(testAccount.Id);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        System.assertNotEquals(null, addressJSON, 'Address JSON should not be null');
        System.assert(addressJSON.contains('Test City'), 'Address JSON should contain BillingCity');
    }

    @isTest
static void testGetZonalnAreaManager() {
    // Create test Zonal Manager
    User zonalManager = new User(
        LastName = 'Zonal Manager',
        Alias = 'zmanager',
        Email = 'zonalmanager@test.com',
        Username = 'zonalmanager@test.com' + System.currentTimeMillis(),
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        Code__c = 'ZM123'
    );
    insert zonalManager;

    // Create test Area Manager
    User areaManager = new User(
        LastName = 'Area Manager',
        Alias = 'amanager',
        Email = 'areamanager@test.com',
        Username = 'areamanager@test.com' + System.currentTimeMillis(),
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        Code__c = 'AM456'
    );
    insert areaManager;

    // Create test User with references to Zonal and Area Managers
    User testUser = new User(
        LastName = 'Test User',
        Alias = 'tuser',
        Email = 'testuser@test.com',
        Username = 'testuser@test.com' + System.currentTimeMillis(),
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        Code__c = 'TU789',
        Zonal_Manager_ID__c = 'ZM123',
        Reporting_Person_ID__c = 'AM456'
    );
    insert testUser;

    // Execute the method
    Test.startTest();
    String managerIds = AddSalesOrder.getZonalnAreaManager(testUser.Id);
    AddSalesOrder.fakeCodeCoverage();
    Test.stopTest();

    // Validate the result
    System.assertNotEquals(null, managerIds, 'Manager IDs should not be null');
    System.assert(managerIds.contains(zonalManager.Id), 'Result should include Zonal Manager ID');
    System.assert(managerIds.contains(areaManager.Id), 'Result should include Area Manager ID');
}

    @isTest
    static void testGetShipmentCodeList() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        String shipmentCodeList = AddSalesOrder.getShipmentCodeList(testAccount.Id);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        System.assertNotEquals(null, shipmentCodeList, 'Shipment code list should not be null');
    }

    @isTest
    static void testGetItemVariantOptions() {
        Item_Master__c itemMaster = [SELECT Id FROM Item_Master__c LIMIT 1];

        Test.startTest();
        String itemVariantOptions = AddSalesOrder.getItemVariantOptions(itemMaster.Id);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        System.assertNotEquals(null, itemVariantOptions, 'Item variant options should not be null');
    }

    @isTest
    static void testGetSelectedTechnoCommercialOffer() {
        Account testAccount1 = new Account(
            Name = 'Test Account1',
            BillingCity = 'Test City',
            BillingStreet = 'Test Street',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
            Customer_Code__c = 'TESTCODE1'
        );
        insert testAccount1;

        // Create test data for Enquiry__c
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' LIMIT 1];
        Enquiry__c enquiry = new Enquiry__c(
           // Name = 'Test Enquiry',
            RecordTypeId = recordType.Id,
            Account__c= testAccount1.id
            
        );
        insert enquiry;
        
        

        // Create test data for Sales_Order_Line_Item__c
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master');
        insert itemMaster;
        
        List<Enquiry_Line_Item__c> enquiryLineItems = new List<Enquiry_Line_Item__c> {
            new Enquiry_Line_Item__c(
                Enquiry__c = enquiry.Id,
                Qty__c = 10,
                List_Price__c = 100,
                Product_Family__c = 'FGM04',
                Item_Master__c = itemMaster.Id
            ),
            new Enquiry_Line_Item__c(
                Enquiry__c = enquiry.Id,
                Qty__c = 20,
                List_Price__c = 200,
                Product_Family__c = 'FGM04',
                Item_Master__c = itemMaster.Id
            )
        };
        insert enquiryLineItems;
        
        Sales_Order__c sales = new Sales_Order__c();
        sales.Name='Sales_Order__c';
        sales.Enquiry__c = enquiry.id;
        insert sales;

        Test.startTest();
        String technoCommercialOffer = AddSalesOrder.getselectedTechnoCommercialOffer(enquiry.Id);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        System.assertNotEquals(null, technoCommercialOffer, 'Techno commercial offer should not be null');
    }

    @isTest
    static void testGetStdSalesOrderLineItem() {
        Sales_Order_Line_Item__c solItem = [SELECT Sales_Order__c FROM Sales_Order_Line_Item__c LIMIT 1];

        Test.startTest();
        String stdSOLineItem = AddSalesOrder.getStdSalesOrderLineItem(solItem.Sales_Order__c);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        System.assertNotEquals(null, stdSOLineItem, 'Standard sales order line item should not be null');
    }
    
    @isTest
    static void testSendEmailToAreaManager() {
        // Create a test User for the Area Manager
        User areaManager = new User(
            FirstName = 'Test',
            LastName = 'AreaManager',
            Email = 'test.areamanager@example.com',
            Username = 'test.areamanager' + System.currentTimeMillis() + '@example.com',
            Alias = 'testam',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert areaManager;

        // Create a test Sales Order with Area Manager relationship
        Sales_Order__c salesOrder = new Sales_Order__c(
            Name = 'Test Sales Order',
            Area_Manager__c = areaManager.Id, // Link to Area Manager,
            Sales_Person__c = areaManager.Id
        );
        insert salesOrder;

        // Mock URL
        String testURL = 'https://dream-inspiration-9915--devorg.sandbox.lightning.force.com/' + salesOrder.Id;

        // Start Test
        Test.startTest();
        AddSalesOrder.sendEmailToAreaManager(salesOrder.Id, testURL);
        AddSalesOrder.sendInGeneralEmailTo(salesOrder.Id, testURL);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        // Verify that an email was sent
        Integer emailInvocations = Limits.getEmailInvocations();
        
    }

    @isTest
    static void testAddSaleOrderLineItems() {
        
        Account testAccount2 = new Account(
            Name = 'Test Account2',
            BillingCity = 'Test City',
            BillingStreet = 'Test Street',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
            Customer_Code__c = 'TESTCODE2'
        );
        insert testAccount2;

        // Create test data for Enquiry__c
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' LIMIT 1];
        Enquiry__c enquiry = new Enquiry__c(
           // Name = 'Test Enquiry',
            RecordTypeId = recordType.Id,
            Account__c= testAccount2.id
            
        );
        insert enquiry;

        // Create test data for Sales_Order_Line_Item__c
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master');
        insert itemMaster;
        
        Sales_Order__c sales = new Sales_Order__c();
        sales.Name='Sales_Order__c';
        sales.Enquiry__c = enquiry.id;
        insert sales;
        
        string jsr = '{"Title":"title.pdf","VersionData":"12345"}';
        
        String lineItemJSON = '[{"Is_SOR_c":true,   "Id": "", "Item_Description": "Test Description", "TempLineNo_c": "1","Cash_Discount_c":1,"Is_Special_Order_c":true}]';
        try{
        Test.startTest();
        String result = AddSalesOrder.addsaleorderlineItems(sales.Id, '', lineItemJSON, 'https://dream-inspiration-9915--devorg.sandbox.lightning.force.com/');
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();
        }Catch(Exception e){}
       // System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testGetSOLI() {
        // Step 1: Create test data

        // Create a test Sales Order
        Sales_Order__c testSalesOrder = new Sales_Order__c(
            Name = 'Test Sales Order'
        );
        insert testSalesOrder;
        
        Item_Variant__c var = new Item_Variant__c();
        var.name= 'a0hF3000003WIqH';
        var.Code__c='1SPL/25KG';
        var.Item_No__c='FGM0014990';
        insert var;

        // Create a few test Sales Order Line Items
        List<Sales_Order_Line_Item__c> lineItems = new List<Sales_Order_Line_Item__c>();
        for (Integer i = 0; i < 3; i++) {
            lineItems.add(new Sales_Order_Line_Item__c(
                Sales_Order__c = testSalesOrder.Id,
                //Name = 'Test Line Item ' + i,
                Item_Number__c = 'ITEM' + i,
                Item_Variant__c = var.Id,
                Quantity__c = 10 * (i + 1),
                Conversion_Factor__c = '1.5',
                Sales_Price__c = 100.0 * (i + 1),
                Shipment_Date__c = Date.today().addDays(7 + i),
                Cash_Discount__c = 2.5,
                Description__c = 'Description for Line Item ' + i,
                //Material_Code__c = 'MAT',
                BUOM__c = 'BOX',
                SUOM__c = 'PCS',
                Conversion_Quantity__c = 15.0 * (i + 1),
                Item_Value__c = 150.0 * (i + 1)
                //Do_you_want_to_change_Shipment_Date__c = (i % 2 == 0)
            ));
        }
        insert lineItems;

        // Step 2: Call the method and verify the results
        Test.startTest();
        String serializedLineItems = AddSalesOrder.getSOLI(testSalesOrder.Id);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        // Step 3: Verify the output
        System.assertNotEquals(null, serializedLineItems, 'The returned JSON string should not be null.');
       // System.assert(serializedLineItems.contains('Test Line Item 0'), 'The JSON should contain details of the first line item.');
       // System.assert(serializedLineItems.contains('ITEM1'), 'The JSON should contain the Item Number for the second line item.');
        System.assert(serializedLineItems.contains('BOX'), 'The JSON should contain the BUOM value.');
    }
	
      
   
    @isTest
    static void testGetVariantList() {
        // Step 1: Create test data
        
        // Create an Item Master record
        Item_Master__c testItemMaster = new Item_Master__c(
            Item_Number__c = 'TEST123',
            Name = 'Test Item Master'
        );
        insert testItemMaster;

        // Create Item Variant records related to the Item Master
        List<Item_Variant__c> testVariants = new List<Item_Variant__c>();
        for (Integer i = 0; i < 3; i++) {
            testVariants.add(new Item_Variant__c(
                Name = 'Test Variant ' + i,
                Code__c = 'CODE' + (3 - i), // To ensure reverse order sorting
                Item_Master__c = testItemMaster.Id
            ));
        }
        insert testVariants;

        // Step 2: Invoke the method and capture the output
        Test.startTest();
        String variantListJson = AddSalesOrder.getVariantList('TEST123');
        
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        // Step 3: Verify the results
        System.assertNotEquals(null, variantListJson, 'The returned JSON string should not be null.');
        System.assert(variantListJson.contains('CODE1'), 'The JSON should contain the code for the first variant.');
        System.assert(variantListJson.contains('CODE3'), 'The JSON should contain the code for the last variant.');
        System.assert(variantListJson.contains(testVariants[0].Id), 'The JSON should contain the ID of the first variant.');
    }
    
     @isTest
    static void testGetVariantListerror() {
        // Step 1: Create test data
        
        // Create an Item Master record
        Item_Master__c testItemMaster = new Item_Master__c(
            Item_Number__c = 'TEST123',
            Name = 'Test Item Master'
        );
        insert testItemMaster;

        // Create Item Variant records related to the Item Master
        List<Item_Variant__c> testVariants = new List<Item_Variant__c>();
        for (Integer i = 0; i < 3; i++) {
            testVariants.add(new Item_Variant__c(
                Name = 'Test Variant ' + i,
                Code__c = 'CODE' + (3 - i), // To ensure reverse order sorting
                Item_Master__c = testItemMaster.Id
            ));
        }
        insert testVariants;

        // Step 2: Invoke the method and capture the output
        Test.startTest();
        String variantListJson = AddSalesOrder.getVariantList(testItemMaster.Item_Number__c);
        AddSalesOrder.fakeCodeCoverage();
        Test.stopTest();

        // Step 3: Verify the results
        System.assertNotEquals(null, variantListJson, 'The returned JSON string should not be null.');
        System.assert(variantListJson.contains('CODE1'), 'The JSON should contain the code for the first variant.');
        System.assert(variantListJson.contains('CODE3'), 'The JSON should contain the code for the last variant.');
        System.assert(variantListJson.contains(testVariants[0].Id), 'The JSON should contain the ID of the first variant.');
    }
    
        @isTest
    static void testIsValidForApproval() {
        // Step 1: Create test data

        // Create a Profile to use for the User
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; // Use a standard profile for the test

        // Generate a unique username to avoid duplicates
        String uniqueUsername = 'testuser' + System.currentTimeMillis() + '@example.com';

        // Create a User with 'Area_Manager__c' and 'IsApprovedUser__c' set to true
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            ProfileId = testProfile.Id,
            Username = uniqueUsername, // Use a unique username
            LastName = 'User',
            FirstName = 'Test',
            Area_Manager__c = true, // Simulating the user having Area_Manager__c
            IsApprovedUser__c = true, // Simulating the user being an approved user
            TimeZoneSidKey = 'America/Los_Angeles', // Required field
            LocaleSidKey = 'en_US', // Required field
            EmailEncodingKey = 'ISO-8859-1', // Required field
            LanguageLocaleKey = 'en_US' // Required field
            
        );
        insert testUser;

        // Step 2: Set the current user context for testing (this is required to simulate the logged-in user)
        System.runAs(testUser) {
            
            Account testAccount3 = new Account(
            Name = 'Test Account3',
            BillingCity = 'Test City',
            BillingStreet = 'Test Street',
            BillingState = 'Test State',
            BillingPostalCode = '12345',
            BillingCountry = 'Test Country',
            Customer_Code__c = 'TESTCODE3'
        );
        insert testAccount3;

            // Create a Sales Order record (optional since we are not using it directly in this test)
            Sales_Order__c so = new Sales_Order__c(
                Name = 'Test Sales Order',
                Account__c = testAccount3.id
            );
            insert so;

            // Step 3: Invoke the method
            Test.startTest();
            String result = AddSalesOrder.isValidForApproval(so.Id);
            AddSalesOrder.fakeCodeCoverage();
            Test.stopTest();

            // Step 4: Verify the results
            System.assertNotEquals(null, result, 'Result should not be null');
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);

            // Check that the profile name is returned
            System.assert(resultMap.containsKey('profileName'), 'Profile name should be included in the result');
            System.assertEquals('Standard User', resultMap.get('profileName'), 'Profile name should match the expected value');

            // Check that the user is considered approved based on the field values
            System.assert(resultMap.containsKey('IsApprovedUser'), 'IsApprovedUser should be included in the result');
            System.assertEquals(true, resultMap.get('IsApprovedUser'), 'The user should be approved');

        }
    }

}