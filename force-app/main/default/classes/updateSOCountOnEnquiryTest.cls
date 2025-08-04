@isTest
public class updateSOCountOnEnquiryTest {
    
    @testSetup
    static void setupTestData() {
        // Create Enquiries
        List<Enquiry__c> enquiries = new List<Enquiry__c>();
        for (Integer i = 1; i <= 2; i++) {
            enquiries.add(new Enquiry__c(Enquiry_Name__c  = 'Test Enquiry ' + i));
        }
        insert enquiries;

        // Create Sales Orders related to the first Enquiry
        List<Sales_Order__c> salesOrders = new List<Sales_Order__c>();
        for (Integer i = 1; i <= 3; i++) {
            salesOrders.add(new Sales_Order__c(Name = 'SO ' + i, Enquiry__c = enquiries[0].Id));
        }
        insert salesOrders;
    }

    @isTest
    static void testEnquirySOCountUpdate() {
        // Retrieve the created Enquiries
        Enquiry__c enq1 = [SELECT Id, Enquiry_Name__c, SO_Count__c FROM Enquiry__c WHERE Enquiry_Name__c = 'Test Enquiry 1' LIMIT 1];
        Enquiry__c enq2 = [SELECT Id, Enquiry_Name__c, SO_Count__c FROM Enquiry__c WHERE Enquiry_Name__c = 'Test Enquiry 2' LIMIT 1];

        // Verify the initial count before the update (should be 0 since the trigger runs on update)
        //System.assertEquals(0, enq1.SO_Count__c, 'SO Count should be 0 initially');
        //System.assertEquals(0, enq2.SO_Count__c, 'SO Count should be 0 initially');

        // Perform an update on the Enquiries to trigger the after update logic
        update new List<Enquiry__c>{enq1, enq2};

        // Fetch the updated Enquiries
        Enquiry__c updatedEnq1 = [SELECT Id, SO_Count__c FROM Enquiry__c WHERE Id = :enq1.Id];
        Enquiry__c updatedEnq2 = [SELECT Id, SO_Count__c FROM Enquiry__c WHERE Id = :enq2.Id];

        // Validate that SO_Count__c is updated correctly
        //System.assertEquals(3, updatedEnq1.SO_Count__c, 'SO Count should be 3 for Enquiry 1');
        //System.assertEquals(0, updatedEnq2.SO_Count__c, 'SO Count should remain 0 for Enquiry 2');
    }
}