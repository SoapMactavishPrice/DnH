@isTest
private class AddCustomerMatrixOnAccountControllerTest {

    static testMethod void testGetDefaultData() {
        Industry__c industry = new Industry__c(Name = 'CEMENT');
        insert industry;

        Account acc = new Account(Name = 'Test Account', Industry__c = industry.Id);
        insert acc;

        String result = AddCustomerMatrixOnAccountController.getdefalutData(acc.Id);
        
    }

    static testMethod void testSaveRecordWithCompetitorData() {
        Industry__c industry = new Industry__c(Name = 'CEMENT');
        insert industry;

        Account acc = new Account(Name = 'Test Account', Industry__c = industry.Id);
        insert acc;

       
        Item_Master__c itemMaster = new Item_Master__c(Name = 'ULTRATENSAL-MH 2.50 X 350 MM - 100PCS - HDPE');
        insert itemMaster;

        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        String jsonData = '[' +
            '{' +
                '"empId":"' + user.Id + '",' +
                '"customerId":"' + acc.Id + '",' +
                '"industryId":"' + industry.Id + '",' +
                '"deptId":"","applictionId":"","newApp":"New App",' +
                '"label":"Company Name",' +
                '"Product_Brand":"Brand",' +
                '"Product_Category":"Category",' +
                '"Product_Name":"' + itemMaster.Id + '",' + 
                '"Product_Size":"Size",' +
                '"alloy":"10",' +
                '"potential":"20",' +
                '"com_label":"Competitor Name",' +
                '"com_Product_Brand":"Comp Brand",' +
                '"com_Product_Category":"Comp Category",' +
                '"com_Product_Name":"Comp Product",' +
                '"com_Product_Size":"Comp Size",' +
                '"com_alloy":"5"' + 
            '}' +
        ']';

        Map<String, String> result = AddCustomerMatrixOnAccountController.saveRecord(jsonData);
       
    }

    static testMethod void testSaveRecordWithZeroValues() {
        Industry__c industry = new Industry__c(Name = 'CEMENT');
        insert industry;

        Account acc = new Account(Name = 'Test Account', Industry__c = industry.Id);
        insert acc;

        
        Item_Master__c itemMaster = new Item_Master__c(Name = 'ULTRATENSAL-MH 2.50 X 350 MM - 100PCS - HDPE');
        insert itemMaster;

        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        String jsonData = '[' +
            '{' +
                '"empId":"' + user.Id + '",' +
                '"customerId":"' + acc.Id + '",' +
                '"industryId":"' + industry.Id + '",' +
                '"deptId":"","applictionId":"","newApp":"New App",' +
                '"label":"Company Name",' +
                '"Product_Brand":"Brand",' +
                '"Product_Category":"Category",' +
                '"Product_Name":"' + itemMaster.Id + '",' + 
                '"Product_Size":"Size",' +
                '"alloy":"0",' +  
                '"potential":"0",' +  
                '"com_label":"Competitor",' +
                '"com_Product_Brand":"Comp Brand",' +
                '"com_Product_Category":"Comp Category",' +
                '"com_Product_Name":"Comp Product",' +
                '"com_Product_Size":"Comp Size",' +
                '"com_alloy":"0"' + 
            '}' +
        ']';

        Map<String, String> result = AddCustomerMatrixOnAccountController.saveRecord(jsonData);
       
    }

    static testMethod void testSaveRecordWithMissingFields() {
        Industry__c industry = new Industry__c(Name = 'CEMENT');
        insert industry;

        Account acc = new Account(Name = 'Test Account', Industry__c = industry.Id);
        insert acc;

       
        Item_Master__c itemMaster = new Item_Master__c(Name = 'ULTRATENSAL-MH 2.50 X 350 MM - 100PCS - HDPE');
        insert itemMaster;

        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        String jsonData = '[' +
            '{' +
                '"empId":"' + user.Id + '",' +
                '"customerId":"' + acc.Id + '",' +
                '"industryId":"' + industry.Id + '",' +
                '"deptId":"","applictionId":"","newApp":"New App",' +
                '"label":"Company Name",' +
                '"Product_Brand":"Brand",' +
                '"Product_Category":"Category",' +
                '"Product_Name":"","' + // Missing Product Name
                '"Product_Size":"Size",' +
                '"alloy":"10",' +
                '"potential":"20",' +
                '"com_label":"Competitor",' +
                '"com_Product_Brand":"Comp Brand",' +
                '"com_Product_Category":"Comp Category",' +
                '"com_Product_Name":"Comp Product",' +
                '"com_Product_Size":"Comp Size",' +
                '"com_alloy":"5"' +
            '}' +
        ']';

        Map<String, String> result = AddCustomerMatrixOnAccountController.saveRecord(jsonData);
      
    }

    static testMethod void testSaveRecordWithInvalidData() {
        String invalidJsonData = '[' +
            '{' +
                '"empId":"005XXXXXXXXXXXX",' +
                '"customerId":"001XXXXXXXXXXXX",' +
                '"industryId":"a0NF3000004SSScMAO",' +
                '"deptId":"","applictionId":"","newApp":"New App",' +
                '"label":"Company Name",' +
                '"Product_Brand":"Brand",' +
                '"Product_Category":"Category",' +
                '"Product_Name":"Product",' +
                '"Product_Size":"Size",' +
                '"alloy":"10",' +
                '"potential":"20",' +
                '"com_label":"Competitor",' +
                '"com_Product_Brand":"Comp Brand",' +
                '"com_Product_Category":"Comp Category",' +
                '"com_Product_Name":"Comp Product",' +
                '"com_Product_Size":"Comp Size",' +
                '"com_alloy":"5"' +
            '}' +
        ']';

        Map<String, String> result = AddCustomerMatrixOnAccountController.saveRecord(invalidJsonData);
       
    }

    static testMethod void testSaveRecordWithEmptyJson() {
        String emptyJsonData = '[]';
        Map<String, String> result = AddCustomerMatrixOnAccountController.saveRecord(emptyJsonData);
        
    }
}