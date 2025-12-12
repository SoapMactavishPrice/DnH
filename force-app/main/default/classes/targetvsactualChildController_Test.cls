@isTest
public class targetvsactualChildController_Test {
    
    @isTest
    static void userWiseTarget() {
        // Create Fiscal Year
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;

        // Create Product Categories
        List<Item_Master__c> productCategories = new List<Item_Master__c> {
            new Item_Master__c(Name = 'Category 1', Family__c = 'FGM01'),
            new Item_Master__c(Name = 'Category 2', Family__c = 'FGM09')
        };
        insert productCategories;

        // Create Products
        List<Item_Master__c> products = new List<Item_Master__c> {
            new Item_Master__c(Name = 'TestTest'),
            new Item_Master__c(Name = 'TESTTTT')
        };
        insert products;

        // Create User Wise Targets
        List<User_Wise_Target__c> empTargets = new List<User_Wise_Target__c>();
        for (Integer i = 0; i < 5; i++) {
            empTargets.add(new User_Wise_Target__c(
                User__c = UserInfo.getUserId(),
                Fiscal_Year__c = fy.Id,
                Target_Amount__c = 1000 * i
            ));
        }
        insert empTargets;

        // Create User Wise Product Category Targets
        List<User_Wise_Product_Category_Target__c> prodTargets = new List<User_Wise_Product_Category_Target__c>();
        for (Integer i = 0; i < products.size(); i++) {
            prodTargets.add(new User_Wise_Product_Category_Target__c(
                User__c = UserInfo.getUserId(),
                Fiscal_Year__c = fy.Id,
                Target_Amount__c = 2000 * i
                // Product_Category1__c = productCategories[i].Id // Ensure linking
            ));
        }
        insert prodTargets;

        Test.startTest();
        String result = targetvsactualChildController.getYearly(null, fy.Id, UserInfo.getUserId(), 'User_Wise_Target__c', null);
        Test.stopTest();

        // Validate result
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetYearly_UserWiseProductCategoryTarget() {
        // Create Fiscal Year
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;

        // Create Product Categories
        List<Item_Master__c> productCategories = new List<Item_Master__c> {
            new Item_Master__c(Name = 'Category 1', Family__c = 'FGM04'),
            new Item_Master__c(Name = 'Category 2', Family__c = 'FGM05')
        };
        insert productCategories;

        // Create Products
        List<Product2> products = new List<Product2> {
            new Product2(Name = 'VOXCO CHROME ORANGE VO-750/SA', Family = 'VO'),
            new Product2(Name = 'VOXCO ZINC PHOSPHATE', Family = 'Anti-Corrosive')
        };
        insert products;

        // Create User Wise Product Category Targets
        List<User_Wise_Product_Category_Target__c> prodTargets = new List<User_Wise_Product_Category_Target__c>();
        for (Integer i = 0; i < products.size(); i++) {
            prodTargets.add(new User_Wise_Product_Category_Target__c(
                User__c = UserInfo.getUserId(),
                Fiscal_Year__c = fy.Id,
                Target_Amount__c = 2000 * i
                // Product_Category1__c = productCategories[i].Id // Ensure linking
            ));
        }
        insert prodTargets;

        Test.startTest();
        String result = targetvsactualChildController.getYearly(null, fy.Id, UserInfo.getUserId(), 'User_Wise_Product_Category_Target__c', null);
        Test.stopTest();

        // Validate result
        System.assertNotEquals(null, result);
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

        // Create User
        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        // Create Product
        Product2 product = new Product2(Name = 'VOXCO CHROME ORANGE VO-750/SA', Family = 'VO');
        insert product;

        // Create User Wise Product Category Target
        User_Wise_Product_Category_Target__c productTarget = new User_Wise_Product_Category_Target__c(
            User__c = user.Id,
            Fiscal_Year__c = fiscalYear.Id,
            Target_Amount__c = 1000
            // Product_Category1__c = 'Category 1' // Assuming this is valid
        );
        insert productTarget;

        Test.startTest();
        String resultProductTarget = targetvsactualChildController.getMonthly(fiscalYear.Id, user.Id, 'User_Wise_Product_Category_Target__c');
        
        // Additional tests for blank inputs
        String resultBlankFiscId = targetvsactualChildController.getMonthly('', user.Id, 'User_Wise_Product_Category_Target__c');
        String resultBlankParentTab = targetvsactualChildController.getMonthly(fiscalYear.Id, user.Id, '');
        
        // Triggering exception handling
        try {
            // Here we pass invalid parameters to trigger an exception
            String resultInvalid = targetvsactualChildController.getMonthly(fiscalYear.Id, user.Id, 'Invalid_Object_Name');
        } catch (Exception e) {
            // This should trigger the catch block in your method

        }

        Test.stopTest();

        // Validate results
        System.assertNotEquals(null, resultProductTarget);
        System.assertNotEquals(null, resultBlankFiscId);
        System.assertNotEquals(null, resultBlankParentTab);
    }
}