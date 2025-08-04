@isTest
public class CustomLeadBeforeInsertTriggerHandlerTest {
    @isTest
    static void testCustomLeadAfterInsert() {
        
        Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;
    
        State__c testState = new State__c(Name = 'Test State', Country__c = testCountry.Id);
        insert testState;
    
        City__c testCity = new City__c(Name = 'Test City');
        insert testCity;
        
        District__c disCity = new District__c(Name = 'Test District');
        insert disCity;
        
        Lead__c testLead = new Lead__c();
        testLead.Name = 'abc xyz';
        testLead.Middle_Name__c = 'A.';
        testLead.Last_Name__c = 'Smith';
        testLead.Salutation__c = 'Mr.';
        testLead.Company_Name__c = 'Test Company';
        testLead.Email__c = 'abc@gmail.com';
        testLead.Mobile_Number__c = '1234567890';
        testLead.GSTIN__c = 'GST123456789';
        testLead.Address_ID__c = 'Addr123';
        testLead.GST_Type__c = 'CGST';
        testLead.Territory__c = 'Local';
        testLead.Lead_Source__c = 'Indiamart';
        testLead.Repeat_Calls_Frequency__c = 'Weekly';
        testLead.Sales_Turnover__c = 1000000.00;
        testLead.CIN_Number__c = 'CIN123456789';
        testLead.GST_Number__c = 'GST123456789';
        testLead.Number_of_Employees__c = 50;
        testLead.PAN_Card_Number__c = 'PAN123456';
        testLead.Website__c = 'www.testcompany.com';
        testLead.Lead_Status__c = 'New';
        testLead.Other_Lost_Reason__c = 'None';
        testLead.Line_1_Block__c = '123 Main St';
        testLead.Line_2_Building_Floor_Room__c = 'Floor 1';
        testLead.Line_3_Street_PO_Box__c = 'PO Box 456';
        testLead.City__c = testCity.Id;
        testLead.Area__c = 'Test Area';
        testLead.District__c = disCity.Id;
        testLead.Zip_Code__c = '123456';
        testLead.State__c = testState.Id;
        testLead.Country__c = testCountry.Id;
        testLead.Rating__c = 'Hot';
        testLead.Other_Lead_Source__c = 'Referral';
        testLead.Landline_No__c = '9876543210';
        testLead.Title__c = 'Mr.';

        Test.startTest();
        insert testLead;
        Test.stopTest();
        
    }
}