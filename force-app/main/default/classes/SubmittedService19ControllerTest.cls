@isTest
public class SubmittedService19ControllerTest {

    static testMethod void GetSubmittedServiceData() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'Test Invoice';
        insert invoice;

        Customer_Complaint__c com1 = new Customer_Complaint__c();
        com1.End_Customer_Name__c = acc.Id;
        com1.Invoice__c = invoice.Id;
        com1.Brand_Name__c = 'Brand A';
        com1.Batch_No__c = 'Batch 001';
        com1.Type_Of_Complaints__c = 'Rejected Material';
        insert com1;

        Customer_Complaint__c com2 = new Customer_Complaint__c();
        com2.End_Customer_Name__c = acc.Id;
        com2.Invoice__c = invoice.Id;
        com2.Brand_Name__c = 'Brand B';
        com2.Batch_No__c = 'Batch 002';
        com2.Type_Of_Complaints__c = 'Rejected Material';
        insert com2;

        try {
            String result = SubmittedService19Controller.getSubmittedServiceData();
        } catch (AuraHandledException e) {
            System.debug('AuraHandledException was thrown: ' + e.getMessage());
        }
    }
}