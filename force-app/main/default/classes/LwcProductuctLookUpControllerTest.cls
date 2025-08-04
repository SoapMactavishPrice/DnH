@isTest
public class LwcProductuctLookUpControllerTest {
    
    @isTest
    public static void testLwcProductLookUp() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Enquiry__c enquiry = new Enquiry__c( );
        enquiry.Enquiry_Name__c = 'Test Enquiry';
        enquiry.Account__c = acc.Id;
        insert enquiry;

        Test.startTest();
        
        List<sObject> results = LwcProductuctLookUpController.findRecords(
            null, 
            null, 
            'Test', 
            'Enquiry__c', 
            enquiry.Id, 
            'Name', 
            new List<String>{'Enquiry_Name__c'}, 
            'Name', 
            null, 
            null, 
            null, 
            false
        );

        sObject fetchedRecord = LwcProductuctLookUpController.fetchDefaultRecord(enquiry.Id, 'Enquiry__c', '');

        Test.stopTest();
    }
}