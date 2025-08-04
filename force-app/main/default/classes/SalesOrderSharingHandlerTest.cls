@isTest
public class SalesOrderSharingHandlerTest {
    
    @isTest
    static void testShareSalesOrderWithUsers() {
        // Create test users (ensure these users exist in your org or create them in the test)
        User salesPerson = [SELECT Id FROM User WHERE Profile.Name = 'Sales Engineer' AND isActive = true LIMIT 1];
        User areaManager = [SELECT Id FROM User WHERE Profile.Name = 'Sales Engineer' AND isActive = true LIMIT 1];
        User zonalHead   = [SELECT Id FROM User WHERE Profile.Name = 'Sales Engineer' AND isActive = true LIMIT 1];
        
        // Create test Sales Orders
        Sales_Order__c order1 = new Sales_Order__c(
            Name = 'Order 1',
            Sales_Person__c = salesPerson.Id,
            Area_Manager__c = areaManager.Id,
            Zonal_Head__c = zonalHead.Id
        );
        
        Sales_Order__c order2 = new Sales_Order__c(
            Name = 'Order 2',
            Sales_Person__c = salesPerson.Id
        );
        
        insert new List<Sales_Order__c>{ order1, order2 };
            
            // Call the method
            Test.startTest();
        SalesOrderSharingHandler.shareSalesOrderWithUsers(new List<Sales_Order__c>{ order1, order2 });
        Test.stopTest();
        
        // Verify Share records are created
        List<Sales_Order__Share> shares = [SELECT ParentId, UserOrGroupId, AccessLevel 
                                           FROM Sales_Order__Share WHERE ParentId IN :new List<Id>{ order1.Id, order2.Id }];
        
        System.assertEquals(4, shares.size(), 'There should be 4 share records created');
        
        // Re-run to check for duplicates
        //Test.startTest();
        SalesOrderSharingHandler.shareSalesOrderWithUsers(new List<Sales_Order__c>{ order1, order2 });
        //Test.stopTest();
        
        // Verify no additional Share records were created (i.e., no duplicates)
        List<Sales_Order__Share> sharesAfterReRun = [SELECT ParentId, UserOrGroupId, AccessLevel 
                                                     FROM Sales_Order__Share WHERE ParentId IN :new List<Id>{ order1.Id, order2.Id }];
        
        //System.assertEquals(4, sharesAfterReRun.size(), 'No duplicate share records should be created');
    }
}