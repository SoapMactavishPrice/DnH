@isTest
public class ConvertSLeadtoCLeadTriggerTest {

    @isTest
    static void testAfterUpdate() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Karnataka');
        insert stateRecord;
        
           Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;
        
        State__c testState = new State__c(Name = 'Test State', Country__c = testCountry.Id);
        insert testState;
        
        City__c testCity = new City__c(Name = 'Test City');
        insert testCity;


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
    static void testFieldChanges() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Gujarat');
        insert stateRecord;
      
           Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;
       

        Lead lead = new Lead(
            FirstName = 'Mark',
            LastName = 'Johnson',
            Company = 'Another Company',
            Email = 'mark.johnson+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '9998887777',
            Website = 'www.old-website.com',
            IsCreatedFromCustomLead__c = false,
            Title = 'Manager',
            Country__c = testCountry.Id,
            State__c = stateRecord.Id,
            Zip_Code__c = '380001',
            Salutation = 'Mr.',
            NumberOfEmployees = 120
        );
        insert lead;

        Lead__c cLead = new Lead__c(
            Name = 'Mark',
            Mobile_Number__c = lead.MobilePhone,
            Title__c = lead.Title,
            Website__c = lead.Website,
            Company_Name__c = lead.Company,
            IsCreatedFromStandardLead__c = true
        );
        insert cLead;

        lead.LastName = 'Taylor';
        lead.Email = 'mark.taylor+' + System.currentTimeMillis() + '@test.com';
        lead.Company = 'Updated Company';
        lead.Title = 'Senior Manager';
        lead.Website = 'www.updated-website.com';
        lead.Salutation = 'Dr.';
        update lead;

        Test.stopTest();
    }   

 /*   @isTest
    static void testCountryStateZipCodeSalutationAssignment() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Maharashtra');
        insert stateRecord;

        Lead lead = new Lead(
            FirstName = 'Tom',
            LastName = 'Hanks',
            Company = 'Test Company',
            Email = 'tom.hanks+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '1234561234',
            Website = 'www.tom-example.com',
            IsCreatedFromCustomLead__c = false,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '400001',
            Salutation = 'Mr.',
            NumberOfEmployees = 200
        );
        insert lead;

        List<Lead__c> cLeads = [SELECT Id FROM Lead__c WHERE Email__c = :lead.Email];
        Test.stopTest();
    }   */

   /* @isTest
    static void testCustomLeadCreation() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Uttar Pradesh');
        insert stateRecord;

        Lead lead = new Lead(
            FirstName = 'Emma',
            LastName = 'Stone',
            Company = 'New Company',
            Email = 'emma.stone+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '1231231234',
            Website = 'www.emma-example.com',
            IsCreatedFromCustomLead__c = true,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '201301',
            Salutation = 'Ms.',
            NumberOfEmployees = 20
        );
        insert lead;

        List<Lead__c> cLeads = [SELECT Id FROM Lead__c WHERE Email__c = :lead.Email];
        Test.stopTest();
    }

    @isTest
    static void testFirstNameChange() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Telangana');
        insert stateRecord;

        Lead lead = new Lead(
            FirstName = 'James',
            LastName = 'Bond',
            Company = 'Change Company',
            Email = 'james.bond+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '1234567890',
            Website = 'www.james-example.com',
            IsCreatedFromCustomLead__c = false,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '500001',
            Salutation = 'Mr.',
            NumberOfEmployees = 5
        );
        insert lead;

        Lead__c cLead = new Lead__c(
            Name = 'James',
            Mobile_Number__c = lead.MobilePhone,
            Website__c = lead.Website,
            Company_Name__c = lead.Company,
            IsCreatedFromStandardLead__c = true
        );
        insert cLead;

        lead.FirstName = 'Jim';
        update lead;

        Test.stopTest();
    }   */

    @isTest
    static void testFieldChanges1() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Gujarat');
        insert stateRecord;
       
      
           Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;
       

        Lead lead = new Lead(
            FirstName = 'Mark',
            LastName = 'Johnson',
            Company = 'Another Company',
            Email = 'mark.johnson+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '9998887777',
            Phone = '1234567890',
            Website = 'www.old-website.com',
            IsCreatedFromCustomLead__c = false,
            Title = 'Manager',
            Country__c = testCountry.Id,
            State__c = stateRecord.Id,
            Zip_Code__c = '380001',
            Salutation = 'Mr.',
            NumberOfEmployees = 120,
            Other_Lost_Reason__c = 'Reason A',
            Address_ID__c = 'Addr123',
            Sales_Turnover__c = 100000,
            GST_Number__c = 'GST123',
            PAN_Card_Number__c = 'PAN123',
            GST_Type__c = 'SGST',
            GSTIN__c = 'GSTIN123',
            CIN_Number__c = 'CIN123',
            Lead_Lost_Reason__c = 'Competitor',
            Year_of_Establishment__c = '2000',
            Rating = 'Warm',
            Repeat_Calls_Allowed__c = 'Yes',
            Repeat_Calls_Frequency__c = 'Weekly',
            Other_Repeat_Calls_Frequency__c = 'Monthly',
            LeadSource = 'Email',
            Other_Lead_Source__c = 'Social Media',
            Area__c = 'Urban'
        );
        insert lead;

        Lead__c cLead = new Lead__c(
            Name = 'Mark',
            Mobile_Number__c = lead.MobilePhone,
            Title__c = lead.Title,
            Website__c = lead.Website,
            Company_Name__c = lead.Company,
            IsCreatedFromStandardLead__c = true,
            Other_Lost_Reason__c = lead.Other_Lost_Reason__c,
            Address_ID__c = lead.Address_ID__c,
            Sales_Turnover__c = lead.Sales_Turnover__c,
            GST_Number__c = lead.GST_Number__c,
            PAN_Card_Number__c = lead.PAN_Card_Number__c,
            GST_Type__c = lead.GST_Type__c,
            GSTIN__c = lead.GSTIN__c,
            CIN_Number__c = lead.CIN_Number__c,
            Lead_Lost_Reason__c = lead.Lead_Lost_Reason__c,
            Year_of_Establishment__c = lead.Year_of_Establishment__c,
            Repeat_Calls_Allowed__c = lead.Repeat_Calls_Allowed__c,
            Repeat_Calls_Frequency__c = lead.Repeat_Calls_Frequency__c,
            Other_Repeat_Calls_Frequency__c = lead.Other_Repeat_Calls_Frequency__c,
            Rating__c = lead.Rating,
            Landline_No__c = lead.Phone,
            Lead_Source__c = lead.LeadSource,
            Other_Lead_Source__c = lead.Other_Lead_Source__c,
            Area__c = lead.Area__c,
            Zip_Code__c = lead.Zip_Code__c
        );
        insert cLead;

        lead.Other_Lost_Reason__c = 'Reason B';
        lead.Address_ID__c = 'Addr456';
        lead.Sales_Turnover__c = 200000;
        lead.GST_Number__c = 'GST456';
        lead.PAN_Card_Number__c = 'PAN456';
        lead.GST_Type__c = 'SGST';
        lead.GSTIN__c = 'GSTIN456';
        lead.CIN_Number__c = 'CIN456';
        lead.Lead_Lost_Reason__c = 'Competitor';
        lead.Year_of_Establishment__c = '2021';
        lead.Repeat_Calls_Allowed__c = 'No';
        lead.Repeat_Calls_Frequency__c = 'Monthly';
        lead.Other_Repeat_Calls_Frequency__c = 'Bi-Weekly';
        lead.Rating = 'Cold';
        lead.MobilePhone = '8887776666';
        lead.Phone = '2223334444';
        lead.LeadSource = 'Referral';
        lead.Other_Lead_Source__c = 'Email Campaign';
        lead.Area__c = 'Rural';
        lead.Zip_Code__c = '380002';

        update lead;

        Lead__c updatedCLead = [SELECT Id, Other_Lost_Reason__c, Address_ID__c, Sales_Turnover__c, 
                                 GST_Number__c, PAN_Card_Number__c, GST_Type__c, GSTIN__c, 
                                 CIN_Number__c, Lead_Lost_Reason__c, Year_of_Establishment__c,
                                 Repeat_Calls_Allowed__c, Repeat_Calls_Frequency__c,
                                 Other_Repeat_Calls_Frequency__c, Rating__c, Landline_No__c,
                                 Lead_Source__c, Other_Lead_Source__c, Area__c, Zip_Code__c 
                                 FROM Lead__c WHERE Id = :cLead.Id];

        Test.stopTest();
    }
    
    /*   @isTest
    static void testLeadNameAssignment() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Test State');
        insert stateRecord;

        Lead lead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'john.doe+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '1234567890',
            Website = 'www.example.com',
            IsCreatedFromCustomLead__c = false,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '400001',
            Salutation = 'Mr.',
            NumberOfEmployees = 50
        );
        insert lead;

        List<Lead__c> cLeads = [SELECT Id FROM Lead__c WHERE Email__c = :lead.Email];
        Test.stopTest();
    }   */

   /* @isTest
    static void testBeforeInsertAndAfterInsert() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Maharashtra');
        insert stateRecord;

        Lead lead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'john.doe+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '1234567890',
            Website = 'www.initial-example.com',
            IsCreatedFromCustomLead__c = false,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '400001',
            Salutation = 'Mr.',
            NumberOfEmployees = 75
        );
        insert lead;

        List<Lead__c> cLeads = [SELECT Id FROM Lead__c WHERE Email__c = :lead.Email];
        Test.stopTest();
    }   */

  /*  @isTest
    static void testBeforeInsertCloneLead() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Delhi');
        insert stateRecord;

        Lead originalLead = new Lead(
            FirstName = 'Alice',
            LastName = 'Smith',
            Company = 'Test Company',
            Email = 'alice.smith+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '5555555555',
            Website = 'www.original-example.com',
            IsCreatedFromCustomLead__c = true,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '110001',
            Salutation = 'Ms.',
            NumberOfEmployees = 100
        );
        insert originalLead;

        Lead clonedLead = new Lead(
            FirstName = 'Alice',
            LastName = 'Smith',
            Company = 'Test Company',
            Email = 'alice.smith.clone+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '5555555555',
            Website = 'www.clone-example.com',
            IsCreatedFromCustomLead__c = false,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '110001',
            Salutation = 'Ms.',
            NumberOfEmployees = 100
        );

        insert clonedLead;

        originalLead = [SELECT IsCreatedFromCustomLead__c FROM Lead WHERE Id = :originalLead.Id];

        Test.stopTest();
    }  */

/*    @isTest
    static void testClonedLeadIsCreatedFromCustomLead() {
        Test.startTest();
        State__c stateRecord = new State__c(Name = 'Uttar Pradesh');
        insert stateRecord;

        Lead originalLead = new Lead(
            FirstName = 'Clone',
            LastName = 'Tester',
            Company = 'Cloning Company',
            Email = 'clone.tester+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '1234567890',
            Website = 'www.clone-example.com',
            IsCreatedFromCustomLead__c = true,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '201301',
            Salutation = 'Mr.',
            NumberOfEmployees = 50
        );
        insert originalLead;

        Lead clonedLead = new Lead(
            FirstName = 'Clone',
            LastName = 'Tester',
            Company = 'Cloning Company',
            Email = 'clone.tester.clone+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '1234567890',
            Website = 'www.clone-example.com',
            IsCreatedFromCustomLead__c = false,
            Country__c = 'a0HF30000090Y09MAE',
            State__c = stateRecord.Id,
            Zip_Code__c = '201301',
            Salutation = 'Mr.',
            NumberOfEmployees = 50
        );

        insert clonedLead;

        Test.stopTest();
    }   */

}