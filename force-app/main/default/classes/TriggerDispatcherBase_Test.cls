@istest
public class TriggerDispatcherBase_Test {
    
    @isTest
    static void testAfterUpdate() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Karnataka');
        insert stateRecord;
        
        Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;

        Lead lead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'jane.doe+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '0987654321',
            Website = 'www.janexample.com',
            IsCreatedFromCustomLead__c = false,
            Country__c = testCountry.Id,
            State__c = stateRecord.Id,
            Zip_Code__c = '560001',
            Salutation = 'Dr.',
            NumberOfEmployees = 30
        );
        insert lead;

        Lead__c cLead = new Lead__c(
            Name = 'Jane',
            Mobile_Number__c = lead.MobilePhone,
            Website__c = lead.Website,
            Company_Name__c = lead.Company,
            IsCreatedFromStandardLead__c = true
        );
        insert cLead;

        lead.LastName = 'Smith';
        lead.Email = 'jane.smith+' + System.currentTimeMillis() + '@test.com';
        lead.Website = 'www.updated-jane.com';
        lead.Salutation = 'Mrs.';
        lead.Company = 'Updated Company';
        update lead;

        Test.stopTest();
    }
       @isTest
    static void testafterInsert() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Karnataka');
        insert stateRecord;
        
        Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;

        Lead lead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'jane.doe+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '0987654321',
            Website = 'www.janexample.com',
            IsCreatedFromCustomLead__c = false,
            Country__c = testCountry.Id,
            State__c = stateRecord.Id,
            Zip_Code__c = '560001',
            Salutation = 'Dr.',
            NumberOfEmployees = 30
        );
        insert lead;

        Lead__c cLead = new Lead__c(
            Name = 'Jane',
            Mobile_Number__c = lead.MobilePhone,
            Website__c = lead.Website,
            Company_Name__c = lead.Company,
            IsCreatedFromStandardLead__c = true
        );
        insert cLead;

        /*lead.LastName = 'Smith';
        lead.Email = 'jane.smith+' + System.currentTimeMillis() + '@test.com';
        lead.Website = 'www.updated-jane.com';
        lead.Salutation = 'Mrs.';
        lead.Company = 'Updated Company';
        update lead;*/

        Test.stopTest();
    }

}