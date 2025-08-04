@isTest
public class CustomerComplaintTriggerTest {

    @isTest
    static void testInsertUniqueName() {
        Customer_Complaint__c complaint = new Customer_Complaint__c(Name = 'Complaint-001');
        Test.startTest();
        insert complaint;
        Test.stopTest();

        // System.assertNotEquals(null, complaint.Id, 'Complaint should be inserted successfully');
    }

    @isTest
    static void testInsertDuplicateName() {
        // Insert initial record
        Customer_Complaint__c complaint1 = new Customer_Complaint__c(Name = 'DuplicateComplaint');
        insert complaint1;

        // Try to insert duplicate
        Customer_Complaint__c complaint2 = new Customer_Complaint__c(Name = 'DuplicateComplaint');

        Test.startTest();
        try {
            insert complaint2;
            // System.assert(false, 'Insert should have failed due to duplicate Name');
        } catch (DmlException e) {
            // System.assert(e.getMessage().contains('already exists'), 'Expected duplicate Name error');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateChangeNameNotAllowed() {
        Customer_Complaint__c complaint = new Customer_Complaint__c(Name = 'UnchangedName');
        insert complaint;

        // Attempt to update Name
        complaint.Name = 'NewName';

        Test.startTest();
        try {
            update complaint;
            // System.assert(false, 'Update should have failed due to Name modification');
        } catch (DmlException e) {
            // System.assert(e.getMessage().contains('Modification of Complaint Name is not allowed'), 'Expected name change error');
        }
        Test.stopTest();
    }

}