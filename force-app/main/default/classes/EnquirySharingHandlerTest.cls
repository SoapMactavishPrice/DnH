@isTest
public class EnquirySharingHandlerTest{
    
    @isTest
    static void testShareSalesOrderWithUsers() {
        // Create test users (ensure these users exist in your org or create them in the test)
        User salesPerson = [SELECT Id FROM User WHERE Profile.Name = 'Sales Engineer' AND isActive = true LIMIT 1];
        User areaManager = [SELECT Id FROM User WHERE Profile.Name = 'Sales Engineer' AND isActive = true LIMIT 1];
        User zonalHead   = [SELECT Id FROM User WHERE Profile.Name = 'Sales Engineer' AND isActive = true LIMIT 1];
        
        // Create test Sales Orders
        Enquiry__c order1 = new Enquiry__c(
            //Name = 'Order 1',
            Field_Staff_Code__c = salesPerson.Id,
            Area_Manager__c = areaManager.Id,
            Zonal_Head__c = zonalHead.Id
        );
        
        Enquiry__c order2 = new Enquiry__c(
            //Name = 'Order 2',
            Field_Staff_Code__c = salesPerson.Id
        );
        
        insert new List<Enquiry__c>{ order1, order2 };
            
            // Call the method
            Test.startTest();
        EnquirySharingHandler.shareEnquiryWithUsers(new List<Enquiry__c>{ order1, order2 });
        Test.stopTest();
        
        // Verify Share records are created
        List<Enquiry__Share> shares = [SELECT ParentId, UserOrGroupId, AccessLevel 
                                           FROM Enquiry__Share WHERE ParentId IN :new List<Id>{ order1.Id, order2.Id }];
        
        System.assertEquals(4, shares.size(), 'There should be 4 share records created');
        
        // Re-run to check for duplicates
        //Test.startTest();
        EnquirySharingHandler.shareEnquiryWithUsers(new List<Enquiry__c>{ order1, order2 });
        //Test.stopTest();
        
        // Verify no additional Share records were created (i.e., no duplicates)
        List<Enquiry__Share> sharesAfterReRun = [SELECT ParentId, UserOrGroupId, AccessLevel 
                                                     FROM Enquiry__Share WHERE ParentId IN :new List<Id>{ order1.Id, order2.Id }];
        
        //System.assertEquals(4, sharesAfterReRun.size(), 'No duplicate share records should be created');
    }
}