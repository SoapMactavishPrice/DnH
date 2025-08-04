@isTest
public class showCustomerAppMatrixonAccountTest {

    @isTest
    public static void testGetCustomerApplicationMatrix() {
        String uniqueSuffix = String.valueOf(System.currentTimeMillis());
        User testUser = new User();
        testUser.Username = 'testuser' + uniqueSuffix + '@example.com';
        testUser.Email = 'testuser' + uniqueSuffix + '@example.com';
        testUser.Alias = 'tuser';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id;
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LastName = 'User';
        insert testUser;
        
        Account acc = new Account();
        acc.Name ='abc';
        insert acc;
        
        Industry__c ind = new Industry__c();
        ind.Name = 'CEMENT';
        insert ind;
        
        Department__c dept = new Department__c();
        dept.Name = 'ROPE SHOVELS';
        insert dept;
        
        Item_Master__c im = new Item_Master__c();
        im.Name ='AUTOTHERME GRADE-B 2.00 MM - 25KGS - REG';
        insert im;

        Customer_Application_Matrix__c cam = new Customer_Application_Matrix__c();
        cam.Company_Name__c = 'Test Application Matrix';
        cam.Employee_Name__c = testUser.Id;
        cam.Customer__c = acc.Id;
        cam.Industry__c = ind.id;
        cam.Department__c = dept.id;
        cam.New_Application__c = 'Yes';
        cam.Product_Brand__c = 'Test Brand';
        cam.Product_Category__c = 'Test Category';
        cam.Product_Name__c = im.id;
        cam.Product_Size__c = 'Large';
        cam.Alloy_Kgs_Annum__c = 1000;
        cam.Potential_Lakhs__c = 500;
        cam.Competitor_Product_Brand__c = 'Competitor Brand';
        cam.Competitor_Product_Category__c = 'Competitor Category';
        cam.Competitor_Potential_Lakhs__c = 300;
        cam.Competitor_Alloy_Kgs_Annum__c = 1500;
        cam.Competitor_Product_Name__c = 'Competitor Product';
        cam.Competitor_Product_Size__c = 'Medium';
        insert cam;

        String result = showCustomerApplicationMatrixonAccount.getCustomerApplicationMatrix();
    }
}