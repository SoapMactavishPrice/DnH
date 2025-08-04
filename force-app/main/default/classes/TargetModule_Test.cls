@isTest
public class TargetModule_Test {

    @isTest
    static void employeeWiseTarget() {
        // Create a Fiscal Year record
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;

        // Create Product records
        List<Product2> products = new List<Product2> {
            new Product2(Name = 'VOXCO CHROME ORANGE VO-750/SA', Family = 'VO'),
            new Product2(Name = 'VOXCO ZINC PHOSPHATE', Family = 'Anti-Corrosive')
        };
        insert products;

        // Create User Wise Target records
        List<User_Wise_Target__c> empTargets = new List<User_Wise_Target__c>();
        for (Integer i = 0; i < 5; i++) {
            empTargets.add(new User_Wise_Target__c(
                User__c = UserInfo.getUserId(),
                Fiscal_Year__c = fy.Id,
                Target_Amount__c = 1000 * i
            ));
        }
        insert empTargets;

        // Create Employee Wise Product Target records
        List<User_Wise_Product_Category_Target__c> prodTargets = new List<User_Wise_Product_Category_Target__c>();
        for (Product2 prod : products) {
            prodTargets.add(new User_Wise_Product_Category_Target__c(
                Product_Category1__c = 'Sample Product',
                User__c = UserInfo.getUserId(),
                Fiscal_Year__c = fy.Id,
                Target_Amount__c = 2000 * products.indexOf(prod)
            ));
        }
        insert prodTargets;

        Test.startTest();
        TargetModule.getDefaultFilterValues();
        
        String result = TargetModule.getYearly(null, fy.Id, UserInfo.getUserId(), 'User_Wise_Target__c', null);
        System.assertNotEquals(null, result, 'Expected a non-null result for yearly user-wise targets.');

        String result1 = TargetModule.getYearly(null, fy.Id, UserInfo.getUserId(), 'User_Wise_Product_Category_Target__c', null);
        System.assertNotEquals(null, result1, 'Expected a non-null result for yearly product category targets.');

        Test.stopTest();
    }

    @isTest
    static void testSaveRecords() {
        // Create a Fiscal Year record
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;

        String employeeId = UserInfo.getUserId();

        // Prepare test data for User_Wise_Target__c
        List<Map<String, Object>> userWiseData = new List<Map<String, Object>> {
            new Map<String, Object> {
                'Id' => null,
                'ParameterId' => employeeId,
                'Target_Amount_New__c' => 5000
            }
        };

        // Prepare test data for User_Wise_Product_Category_Target__c
        List<Map<String, Object>> productCategoryData = new List<Map<String, Object>> {
            new Map<String, Object> {
                'Id' => null,
                'ParameterId' => 'Sample Product',
                'Target_Amount_New__c' => 3000
            }
        };

        // Test Yearly Save
        String dataYearly = JSON.serialize(userWiseData);
        String resultYearly = TargetModule.saveRecords(dataYearly, fy.Id, employeeId, 'User_Wise_Target__c', 'Yearly');
        
        // Test Yearly Save for User_Wise_Product_Category_Target__c
        String dataProductCategory = JSON.serialize(productCategoryData);
        String resultProductCategory = TargetModule.saveRecords(dataProductCategory, fy.Id, employeeId, 'User_Wise_Product_Category_Target__c', 'Yearly');

        // Verify records created
        List<User_Wise_Product_Category_Target__c> savedProductTargets = [
            SELECT Id, Fiscal_Year__c, User__c, Product_Category1__c, Target_Amount__c 
            FROM User_Wise_Product_Category_Target__c 
            WHERE User__c = :employeeId AND Fiscal_Year__c = :fy.Id
        ];
        System.assertEquals(1, savedProductTargets.size(), 'Expected one User_Wise_Product_Category_Target__c record to be created.');
        System.assertEquals('Sample Product', savedProductTargets[0].Product_Category1__c, 'Product category should match.');
        System.assertEquals(3000, savedProductTargets[0].Target_Amount__c, 'Target amount should match.');
    }
    
    @isTest
    static void testSaveRecordsMonthly() {
        // Create a Fiscal Year record
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;

        String employeeId = UserInfo.getUserId();

        // Prepare test data for User_Wise_Target__c
        List<Map<String, Object>> userWiseData = new List<Map<String, Object>> {
            new Map<String, Object> {
                'Id' => 'a1B1r00000E1Xyz', // Assuming this is a valid Id for the test
                'ParameterId' => employeeId,
                'Monthly_Target_Amount__c' => 500
            }
        };

        // Prepare test data for User_Wise_Product_Category_Target__c
        List<Map<String, Object>> productCategoryData = new List<Map<String, Object>> {
            new Map<String, Object> {
                'Id' => 'a1B1r00000E1Xyz', // Assuming this is a valid Id for the test
                'ParameterId' => 'Sample Product',
                'Monthly_Target_Amount__c' => 300
            }
        };

        // Extract Ids from the maps
        String userWiseId = (String) userWiseData[0].get('Id');
        String productCategoryId = (String) productCategoryData[0].get('Id');

        // Test Monthly Save for User_Wise_Target__c
        String dataMonthly = JSON.serialize(userWiseData);
        String resultMonthly = TargetModule.saveRecords(dataMonthly, fy.Id, employeeId, 'User_Wise_Target__c', 'Monthly');
        System.assertNotEquals(null, resultMonthly);
        Map<String, Object> resultMapMonthly = (Map<String, Object>) JSON.deserializeUntyped(resultMonthly);
        //System.assertEquals('Success', resultMapMonthly.get('status'));

        // Test Monthly Save for User_Wise_Product_Category_Target__c
        String dataProductCategoryMonthly = JSON.serialize(productCategoryData);
        String resultProductCategoryMonthly = TargetModule.saveRecords(dataProductCategoryMonthly, fy.Id, employeeId, 'User_Wise_Product_Category_Target__c', 'Monthly');
        System.assertNotEquals(null, resultProductCategoryMonthly);
        Map<String, Object> resultMapProductCategoryMonthly = (Map<String, Object>) JSON.deserializeUntyped(resultProductCategoryMonthly);
        //System.assertEquals('Success', resultMapProductCategoryMonthly.get('status'));

        // Verify records created for User_Wise_Target_Line_Item__c
        List<User_Wise_Target_Line_Item__c> savedUserTargetsMonthly = [
            SELECT Id, Monthly_Target_Amount__c 
            FROM User_Wise_Target_Line_Item__c 
            WHERE Id = :userWiseId
        ];
        System.debug('savedUserTargetsMonthly: ' + savedUserTargetsMonthly);
        //System.assertEquals(1, savedUserTargetsMonthly.size(), 'Expected one User_Wise_Target_Line_Item__c record to be created.');
        //System.assertEquals(500, savedUserTargetsMonthly[0].Monthly_Target_Amount__c, 'Monthly target amount should match.');

        // Verify records created for User_Wise_Product_Category_Target_Line__c
        List<User_Wise_Product_Category_Target_Line__c> savedProductTargetsMonthly = [
            SELECT Id, Monthly_Target_Amount__c 
            FROM User_Wise_Product_Category_Target_Line__c 
            WHERE Id = :productCategoryId
        ];
        System.debug('savedProductTargetsMonthly: ' + savedProductTargetsMonthly);
        //System.assertEquals(1, savedProductTargetsMonthly.size(), 'Expected one User_Wise_Product_Category_Target_Line__c record to be created.');
        //System.assertEquals(300, savedProductTargetsMonthly[0].Monthly_Target_Amount__c, 'Monthly target amount should match.');
    }


    @isTest
    static void testSaveRecords_ExceptionHandling() {
        // Create a Fiscal Year record
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;

        String employeeId = UserInfo.getUserId();

        // Prepare invalid test data to trigger an exception
        List<Map<String, Object>> invalidData = new List<Map<String, Object>> {
            new Map<String, Object> {
                'Id' => null,
                'ParameterId' => null, // Intentionally set to null to trigger an error
                'Target_Amount_New__c' => 'NotADecimal' // Invalid format
            }
        };

        // Test Exception Handling
        String dataInvalid = JSON.serialize(invalidData);
        
        // Call saveRecords and expect an error response
        String result = TargetModule.saveRecords(dataInvalid, fy.Id, employeeId, 'User_Wise_Product_Category_Target__c', 'Yearly');
        
        // Check if result contains an error message
        // (Note: Adjust the check according to your error message format)
    }

    @isTest
    static void testGetYearly_EmployeeWiseProductTarget() {
        // Create a Fiscal Year record
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;

        // Create Product records
        List<Product2> products = new List<Product2> {
            new Product2(Name = 'VOXCO CHROME ORANGE VO-750/SA', Family = 'VO'),
            new Product2(Name = 'VOXCO ZINC PHOSPHATE', Family = 'Anti-Corrosive')
        };
        insert products;

        // Create User Wise Product Target records
        List<User_Wise_Product_Category_Target__c> prodTargets = new List<User_Wise_Product_Category_Target__c>();
        for (Product2 prod : products) {
            prodTargets.add(new User_Wise_Product_Category_Target__c(
                Product_Category1__c = 'Sample Product',
                User__c = UserInfo.getUserId(),
                Fiscal_Year__c = fy.Id,
                Target_Amount__c = 2000 * products.indexOf(prod)
            ));
        }
        insert prodTargets;

        Test.startTest();
        String result = TargetModule.getYearly(null, fy.Id, UserInfo.getUserId(), 'User_Wise_Product_Category_Target__c', null);
        System.assertNotEquals(null, result, 'Expected a non-null result for yearly product category targets.');
        Test.stopTest();
    }

    @isTest
    static void testGetMonthly() {
        // Create Fiscal Year
        Fiscal_Year__c fiscalYear = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fiscalYear;

        // Employee (User)
        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        // Product
        Product2 product = new Product2(Name = 'VOXCO CHROME ORANGE VO-750/SA', Family = 'VO');
        insert product;

        User_Wise_Target__c emt = new User_Wise_Target__c(
            User__c = UserInfo.getUserId(),
            Fiscal_Year__c = fiscalYear.Id,
            Target_Amount__c = 1000 
        );
        insert emt;

        User_Wise_Target_Line_Item__c targetLineItem = new User_Wise_Target_Line_Item__c(
            User_Wise_Target__c = emt.Id,
            Start_Date__c = Date.newInstance(2024, 1, 1),
            End_Date__c = Date.newInstance(2024, 1, 31),
            Monthly_Target_Amount__c = 1000
        );
        insert targetLineItem;

        // Employee Wise Product Target
        User_Wise_Product_Category_Target__c productTarget = new User_Wise_Product_Category_Target__c(
            User__c = user.Id,
            Product_Category1__c = 'Sample Product',
            Fiscal_Year__c = fiscalYear.Id,
            Target_Amount__c = 1000
        );
        insert productTarget;

        // Employee Wise Product Target Line Item
        User_Wise_Product_Category_Target_Line__c productTargetLineItem = new User_Wise_Product_Category_Target_Line__c(
            User_Wise_Product_Category_Target__c = productTarget.Id,
            Start_Date__c = Date.newInstance(2024, 1, 1),
            End_Date__c = Date.newInstance(2025, 03, 31),
            Monthly_Target_Amount__c = 1000
        );
        insert productTargetLineItem;

        // Test cases
        Test.startTest();
        String resultTarget = TargetModule.getMonthly(fiscalYear.Id, user.Id, 'User_Wise_Target__c', null);
        System.assertNotEquals(null, resultTarget, 'Expected a non-null result for monthly user-wise targets.');

        String resultProduct = TargetModule.getMonthly(fiscalYear.Id, user.Id, 'User_Wise_Product_Category_Target__c', null);
        System.assertNotEquals(null, resultProduct, 'Expected a non-null result for monthly product category targets.');

        // Test Exception Handling
        try {
            // Call getMonthly with invalid parameters to trigger exception
            String result = TargetModule.getMonthly(fiscalYear.Id, null, 'User_Wise_Target__c', null);
        } catch (AuraHandledException e) {
            // Expected exception handling
        }

        Test.stopTest();
    }

    @isTest
    static void testGetTargetQuantityByEmpId_NoRecords() {
        Test.startTest();
        // Testing with an invalid employee ID to trigger no records found
        // String result = TargetModule.getTargetQuantityByEmpId('InvalidEmpId');
        // System.assertEquals('', result, 'Expected an empty string when no records are found.');
        Test.stopTest();
    }

    @isTest
    static void testGetTargetQuantityByEmpId_Exception() {
        Test.startTest();
        // Testing with a null input to trigger exception
        try {
            String result = TargetModule.getTargetQuantityByEmpId(null);
            System.assert(false, 'Expected an exception to be thrown for null input.');
        } catch (AuraHandledException e) {
            // System.assert(e.getMessage().contains('null'), 'Expected error message to contain "null".');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductTargetQtyByProdCatVal_NoRecords() {
        Test.startTest();
        // Testing with an invalid product category to trigger no records found
        String result = TargetModule.getProductTargetQtyByProdCatVal('InvalidProductCat', 'InvalidEmpId');
        System.assertEquals('', result, 'Expected an empty string when no records are found.');
        Test.stopTest();
    }

    @isTest
    static void testGetProductTargetQtyByProdCatVal_Exception() {
        Test.startTest();
        // Testing with a null product category to trigger exception
        try {
            String result = TargetModule.getProductTargetQtyByProdCatVal(null, UserInfo.getUserId());
            // System.assert(false, 'Expected an exception to be thrown for null input.');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('null'), 'Expected error message to contain "null".');
        }
        Test.stopTest();
    }
}