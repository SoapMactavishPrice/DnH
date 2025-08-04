@isTest
public class ShowCustomerMatrixTest {
    @isTest
    Public static void testGetCustomerMatrix() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        User ur = new User();
        ur.Username = 'dandhsecheron@test.com';
        ur.Email = 'dandhsecheron@test.com';
        ur.FirstName = 'D&H';
        ur.LastName = 'Secheron';
        ur.Alias = 'DHS';
        ur.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        ur.TimeZoneSidKey = 'America/New_York';
        ur.LocaleSidKey = 'en_US';
        ur.EmailEncodingKey = 'UTF-8';
        ur.LanguageLocaleKey = 'en_US';
        insert ur;

        Customer_Application_Matrix__c cam = new Customer_Application_Matrix__c();
        cam.Customer__c = acc.Id;
        cam.Employee_Name__c = ur.Id;
        cam.New_Application__c = 'Yes';
        cam.Company_Name__c = 'Test Company';
        cam.Product_Brand__c = 'Test Brand';
        cam.Product_Category__c = 'Test Category';
        cam.Alloy_Kgs_Annum__c = 100;
        cam.Potential_Lakhs__c = 50;
        cam.Competitor_Product_Brand__c = 'Competitor Brand';
        cam.Competitor_Product_Category__c = 'Competitor Category';
        cam.Competitor_Potential_Lakhs__c = 30;
        cam.Competitor_Alloy_Kgs_Annum__c = 80;
        cam.Competitor_Product_Name__c = 'Competitor Product';
        insert cam;

        Test.startTest();
        String result = ShowCustomerMatrix.getCustomerMatrix(acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
}