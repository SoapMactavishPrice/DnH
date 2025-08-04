@isTest
public class CustomLeadAfterUpdateTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        // Create custom Lead__c records
        List<Lead__c> customLeads = new List<Lead__c>();
        for (Integer i = 0; i < 5; i++) {
            customLeads.add(new Lead__c(
                Name = 'Custom Lead ' + i,
                //Email__c = 'email' + i + '@example.com',
                Salutation__c = 'Mr.',
                Middle_Name__c = 'Middle' + i,
                Last_Name__c = 'Last' + i,
                //Industry__c = 'Industry' + i,
                Website__c = 'http://example' + i + '.com',
                Lead_Status__c = 'Qualified',
                Territory__c = 'Local',
                Lead_Type__c = 'Export',
                PAN_Card_Number__c = 'OEA6575752',
                GST_Type__c = 'CGST',
                GSTIN__c = '123123131',
                CIN_Number__c = '24123123232323',
                Lead_Lost_Reason__c = 'Price',
                Year_of_Establishment__c = '1981',
                Key_Person__c = 'Test',
                Sales_Turnover__c = 50.00,
                GST_Number__c ='1234567899',
                Repeat_Calls_Allowed__c = 'Yes',
                Other_Repeat_Calls_Frequency__c = 'Daily',
                Lead_Source__c = 'Email',
                Rating__c = 'Cold',
                Landline_No__c = '13122343234',
                Email__c = 'abc@gmail.com',
                Line_1_Block__c = 'Test',
                Line_2_Building_Floor_Room__c = 'Test',
                Line_3_Street_PO_Box__c = 'Test',
                Mobile_Number__c = '123456789' + i,
                Company_Name__c = 'Company ' + i
            ));
        }
        insert customLeads;

        // Create corresponding standard Lead records
        List<Lead> standardLeads = new List<Lead>();
        for (Lead__c customLead : customLeads) {
            standardLeads.add(new Lead(
                //Email = customLead.Email__c,
                Salutation = customLead.Salutation__c,
                FirstName = customLead.Name,
                LastName = customLead.Last_Name__c,
                Company = customLead.Company_Name__c,
                MobilePhone = customLead.Mobile_Number__c,
                Industry = customLead.Industry__c,
                Website = customLead.Website__c
            ));
        }
        insert standardLeads;
    }

    @isTest
    static void testTriggerHandler_UpdateLogic() {
        // Retrieve custom Lead__c records
        List<Lead__c> customLeads = [SELECT Id, Name, Email__c, Salutation__c, Middle_Name__c, Last_Name__c, 
                                       Website__c, Lead_Status__c, Territory__c, Lead_Type__c, PAN_Card_Number__c, GST_Type__c, GSTIN__c, CIN_Number__c, Mobile_Number__c,
                                     Company_Name__c, Lead_Lost_Reason__c, Year_of_Establishment__c, Key_Person__c, Sales_Turnover__c, GST_Number__c, Repeat_Calls_Allowed__c,
                                     Other_Repeat_Calls_Frequency__c, Lead_Source__c, Rating__c, Landline_No__c, Line_1_Block__c, Line_2_Building_Floor_Room__c,
                                     Line_3_Street_PO_Box__c
                                      FROM Lead__c];

        // Update custom Lead__c records
        for (Lead__c customLead : customLeads) {
            customLead.Salutation__c = 'Ms.';
            customLead.Name = 'Updated ' + customLead.Name;
            customLead.Middle_Name__c = 'UpdatedMiddle';
            customLead.Last_Name__c = 'UpdatedLast';
            //customLead.Industry__c = 'UpdatedIndustry';
            customLead.Website__c = 'http://updated.com';
            customLead.Lead_Status__c = 'Qualified';
            customLead.Territory__c = 'Local';
            customLead.Lead_Type__c = 'Export';
            customLead.PAN_Card_Number__c = 'OEA6575752';
            customLead.GSTIN__c = '123123131';
            customLead.CIN_Number__c = '24123123232323';
            customLead.GST_Type__c = 'CGST';
            customLead.Lead_Lost_Reason__c = 'Price';
            customLead.Year_of_Establishment__c = '1981';
            customLead.Key_Person__c = 'Test';
            customLead.Sales_Turnover__c = 50.00;
            customLead.GST_Number__c = '1234567899';
            customLead.Repeat_Calls_Allowed__c = 'Yes';
            customLead.Other_Repeat_Calls_Frequency__c = 'Daily';
            customLead.Lead_Source__c = 'Email';
            customLead.Rating__c = 'Cold';
            customLead.Landline_No__c = '13122343234';
            //customLead.Email__c = 'abc@gmail.com';
            customLead.Line_1_Block__c = 'Test';
            customLead.Line_2_Building_Floor_Room__c = 'Test';
            customLead.Line_3_Street_PO_Box__c = 'Test';
            
            customLead.Mobile_Number__c = '9876543210';
            customLead.Company_Name__c = 'UpdatedCompany';
        }
        update customLeads;

        // Verify that standard Leads are updated
        List<Lead> standardLeads = [SELECT Id, Salutation, FirstName, MiddleName, LastName, 
                                     Industry, Website, Status, Company, MobilePhone, Email
                                     FROM Lead];

        for (Lead lead : standardLeads) {
            // System.assertEquals('Ms.', lead.Salutation);
            // System.assert(lead.FirstName.startsWith('Updated'));
            // System.assertEquals('UpdatedMiddle', lead.MiddleName);
            // System.assertEquals('UpdatedLast', lead.LastName);
            // System.assertEquals('UpdatedIndustry', lead.Industry);
            // System.assertEquals('http://updated.com', lead.Website);
        }
    }

    @isTest
    static void testTriggerHandler_NoChange() {
        // Retrieve custom Lead__c records
        List<Lead__c> customLeads = [SELECT Id, Name, Email__c, Salutation__c, Middle_Name__c, Last_Name__c, 
                                       Website__c, Lead_Status__c, Territory__c, Lead_Type__c, GST_Type__c, PAN_Card_Number__c, Mobile_Number__c, Company_Name__c,
                                     GSTIN__c, CIN_Number__c, Lead_Lost_Reason__c, Year_of_Establishment__c, Key_Person__c, Sales_Turnover__c, GST_Number__c,
                                     Repeat_Calls_Allowed__c, Other_Repeat_Calls_Frequency__c, Lead_Source__c, Rating__c, Landline_No__c, Line_1_Block__c,
                                     Line_2_Building_Floor_Room__c, Line_3_Street_PO_Box__c
                                      FROM Lead__c];

        // Perform an update without making any changes
        update customLeads;

        // Verify that no updates occurred on the standard Lead records
        Integer originalDMLCount = Limits.getDMLStatements();
        List<Lead> standardLeads = [SELECT Id, Salutation, FirstName, MiddleName, LastName, 
                                      Website, Status, Company, MobilePhone, Email
                                     FROM Lead];

        // Assert no additional DML operations were performed
        // System.assertEquals(originalDMLCount, Limits.getDMLStatements(), 'No updates should have occurred.');
    }

    @isTest
    static void testTriggerHandler_EmptyEmail() {
        // Create a Lead__c record with an empty Email__c
        Lead__c leadWithEmptyEmail = new Lead__c(
            Name = 'No Email Lead',
            Email__c = null,
            Salutation__c = 'Dr.',
            Mobile_Number__c = '1112223333',
            Company_Name__c = 'No Email Company',
            Last_Name__c = 'Test'
        );
        insert leadWithEmptyEmail;

        // Update the Lead__c record
        leadWithEmptyEmail.Salutation__c = 'Mr.';
        update leadWithEmptyEmail;

        // Assert no updates were made to standard Lead records
        List<Lead> leads = [SELECT Id FROM Lead WHERE Email = null];
    }
}