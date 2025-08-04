@isTest
public class UserWiseTarget_Test {
    
    @isTest
    static void testRollupTargetAmountUserWiseTarget() {
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;
        
        User_Wise_Target__c target = new User_Wise_Target__c(
            User__c = UserInfo.getUserId(),
            Fiscal_Year__c = fy.Id,
            Target_Amount__c = 1000
        );
        insert target;
        
        List<sObject> newRecords = new List<sObject>{target};
        Map<Id, sObject> oldMap = new Map<Id, sObject>{
            target.Id => new User_Wise_Target__c(
                Id = target.Id,
                Target_Amount__c = 10000
            )
        };
        
        Test.startTest();
        TargetAllInOneTriggerHandler.rollupTargetAmount(newRecords, oldMap, 'UserWiseTarget');
        Test.stopTest();
    }
    
    @isTest
    static void testRollupTargetAmountUserWiseProductCategoryTarget() {
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;
        
        User_Wise_Product_Category_Target__c productTarget = new User_Wise_Product_Category_Target__c(
            User__c = UserInfo.getUserId(),
            Fiscal_Year__c = fy.Id,
            Target_Amount__c = 1200
        );
        insert productTarget;
        
        List<sObject> newRecords = new List<sObject>{productTarget};
        Map<Id, sObject> oldMap = new Map<Id, sObject>{
            productTarget.Id => new User_Wise_Product_Category_Target__c(
                Id = productTarget.Id,
                Target_Amount__c = 1000
            )
        };
        
        Test.startTest();
        TargetAllInOneTriggerHandler.rollupTargetAmount(newRecords, oldMap, 'UserWiseProductCategoryTarget');
        Test.stopTest();
    }
    
    @isTest
    static void updateMonthlyTargetEntriesTest() {
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;
        
        User_Wise_Target__c target = new User_Wise_Target__c(
            User__c = UserInfo.getUserId(),
            Fiscal_Year__c = fy.Id,
            Target_Amount__c = 1000
        );
        insert target;
        
        List<sObject> newRecords = new List<sObject>{target};
        Map<Id, sObject> newMap = new Map<Id, sObject>(newRecords);
        Map<Id, sObject> oldMap = new Map<Id, sObject>{
            target.Id => new User_Wise_Target__c(
                Id = target.Id,
                Target_Amount__c = 10000
            )
        };
        
        Test.startTest();
        TargetAllInOneTriggerHandler.updateMonthlyTargetEntries(newRecords, oldMap, newMap, 'UserWiseTarget');
        Test.stopTest();
    }
    
    @isTest
    static void shareRecordWithUserTest() {
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
        );
        insert fy;
        
        List<User_Wise_Target__c> userTargets = new List<User_Wise_Target__c>();
        List<User_Wise_Product_Category_Target__c> productTargets = new List<User_Wise_Product_Category_Target__c>();
        
        User_Wise_Target__c uwt = new User_Wise_Target__c(
            Target_Amount__c = 1000,
            User__c = UserInfo.getUserId(),
            Fiscal_Year__c = fy.Id // Ensure that fiscal year is set
        );
        userTargets.add(uwt);
        
        User_Wise_Product_Category_Target__c uwpct = new User_Wise_Product_Category_Target__c(
            Target_Amount__c = 2000,
            User__c = UserInfo.getUserId(),
            Fiscal_Year__c = fy.Id // Ensure that fiscal year is set
        );
        productTargets.add(uwpct);
        
        insert userTargets;
        insert productTargets;
        
        List<sObject> newRecords = new List<sObject>();
        newRecords.addAll(userTargets);
        newRecords.addAll(productTargets);
        
        Test.startTest();
        TargetAllInOneTriggerHandler.shareRecordWithUser(newRecords, null);
        Test.stopTest();
    }
    
}