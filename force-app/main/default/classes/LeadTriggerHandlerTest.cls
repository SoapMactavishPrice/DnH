@isTest
public class LeadTriggerHandlerTest {
    
    @isTest
    static void testUpdateLeadAddresses() {
        
        // Step 2: Create mock records for Postal_Code, Area, City, and State
        Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;
        
        State__c testState = new State__c(Name = 'Test State', Country__c = testCountry.Id);
        insert testState;
        
        City__c testCity = new City__c(Name = 'Test City', State__c = testState.Id);
        insert testCity;
        
        Area__c testArea = new Area__c(Name = 'Test Area', City__c = testCity.Id);
        insert testArea;
        
        Pin_Code__c testPostalCode = new Pin_Code__c(Name = '12345', Area__c = testArea.Id);
        insert testPostalCode;
        
        // Step 3: Create test leads with the required Company field
        Lead__c lead1 = new Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Lead1',
            Name = 'Test Company 1', // Required field
            Pin_Code__c = testPostalCode.Id,
            Lead_Status__c = 'New'
        );
        
        Lead__c lead2 = new Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Lead2',
            Name = 'Test Company 2', // Required field
            Area_Name__c = testArea.Id,
            Lead_Status__c = 'New'
        ); 
        
        List<Lead__c> leads = new List<Lead__c>{ lead1, lead2 };
            
            // Step 4: Perform DML operation
            Test.startTest();
        insert leads;
        Test.stopTest();
        
        // Step 5: Verify the results
        Lead__c updatedLead1 = [SELECT Area_Name__c, City__c, State__c, Country__c FROM Lead__c WHERE Id = :lead1.Id];
        Lead__c updatedLead2 = [SELECT City__c, State__c, Country__c FROM Lead__c WHERE Id = :lead2.Id];
    }    
}