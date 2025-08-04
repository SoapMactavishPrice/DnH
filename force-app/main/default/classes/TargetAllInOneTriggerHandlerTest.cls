@isTest
public class TargetAllInOneTriggerHandlerTest {
   @isTest
    static void testRollupTargetAmountEmployeeWiseTarget() {
      
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
            
        );
        insert fy;
        
      
        User_Wise_Target__c target = new User_Wise_Target__c(
            User__c  = UserInfo.getUserId(),
           
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
        TargetAllInOneTriggerHandler.rollupTargetAmount(newRecords, oldMap, 'EmployeeWiseTarget');
        Test.stopTest();
        
    }
    
    @isTest
    static void testRollupTargetAmountEmployeeWiseProductTarget() {
        
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
            
        );
        insert fy;
        
        Product2 prod = new Product2();
        prod.Name='VOXCO ZINC PHOSPHATE ';
        prod.Family = 'Anti-Corrosive';
        insert prod;
        
        
        User_Wise_Product_Category_Target__c productTarget = new User_Wise_Product_Category_Target__c(
            User__c = UserInfo.getUserId(),
          //  Product_Category__c = 'Sample Product2',
            Fiscal_Year__c = fy.Id,
            Target_Amount__c=1200
        );
        insert productTarget;
        
        List<sObject> newRecords = new List<sObject>{productTarget};
            Map<Id, sObject> oldMap = new Map<Id, sObject>{
                productTarget.Id => new User_Wise_Product_Category_Target__c(
                    Id = productTarget.Id,
                    Target_Amount__c=1000
                )
                    };
                        
        Test.startTest();
        TargetAllInOneTriggerHandler.rollupTargetAmount(newRecords, oldMap, 'UserWiseProductCategoryTarget');
        
        Test.stopTest();
        
    }
    
    @isTest
    static void createMonthlyTargetEntriesTest() {
        
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
            
        );
        insert fy;
        
        
    }
    
    @isTest
    static void updateMonthlyTargetEntriesTest() {
        
        Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31));
        
        insert fy;
        // Create an Employee Wise Target record
        User_Wise_Target__c target = new User_Wise_Target__c(
            User__c  = UserInfo.getUserId(),
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
        TargetAllInOneTriggerHandler.updateMonthlyTargetEntries(newRecords, oldMap,newMap, 'UserWiseTarget');
        //TargetAllInOneTriggerHandler.updateMonthlyTargetEntries(newRecords, oldMap,newMap, 'EmployeeWiseProductTarget');

        Test.stopTest();
        
        
    }     
   
   
    @isTest
    static void shareRecordWithUserTest() {
        List<User_Wise_Target__c> employeeTargets = new List<User_Wise_Target__c>();
        List<User_Wise_Product_Category_Target__c> productTargets = new List<User_Wise_Product_Category_Target__c>();
      //  List<Employee_Wise_Account_Target__c> accountTargets = new List<Employee_Wise_Account_Target__c>();
           Fiscal_Year__c fy = new Fiscal_Year__c(
            Name = 'FY 2024',
            FY_Start_Date__c = Date.newInstance(2024, 1, 1),
            FY_End_Date__c = Date.newInstance(2025, 03, 31)
            
        );
        insert fy;
            Product2 prod = new Product2();
            prod.Name='VOXCO ZINC PHOSPHATE ';
            prod.Family = 'Anti-Corrosive';
            insert prod;
            User_Wise_Target__c ewt = new User_Wise_Target__c(
                Fiscal_Year__c=fy.Id,
                Target_Amount__c = 1000,
                User__c = UserInfo.getUserId() 
            );
            employeeTargets.add(ewt);
            User_Wise_Product_Category_Target__c ewpt = new User_Wise_Product_Category_Target__c(
                Fiscal_Year__c=fy.Id,
             //   Product_Category__c= 'Sample Product2',
                Target_Amount__c = 2000,
                User__c = UserInfo.getUserId()
            );
            productTargets.add(ewpt);
           
        insert employeeTargets;
        insert productTargets;
     
        
        List<sObject> newRecords = new List<sObject>();
        newRecords.addAll(employeeTargets);
        newRecords.addAll(productTargets);

        

        Test.startTest();
        TargetAllInOneTriggerHandler.shareRecordWithUser(newRecords, null );
        Test.stopTest();
        
        
    }
    

}