public class ShowCustomerMatrix {
@AuraEnabled
    public static string getCustomerMatrix(string accId){
        List<Customer_Application_Matrix__c> camList = [SELECT Id, Name,Customer__c,	Employee_Name__c,Industry__c, Department__c, New_Application__c, Application__c, 
                                                       Company_Name__c, Competitor_Name__c,Product_Brand__c, Product_Category__c, Product_Name__c, Product_Size__c, 
                                                       Alloy_Kgs_Annum__c, Potential_Lakhs__c, Competitor_Product_Brand__c, 
            Competitor_Product_Category__c, Competitor_Potential_Lakhs__c, Competitor_Alloy_Kgs_Annum__c, Competitor_Product_Name__c, 
            Competitor_Product_Size__c  from Customer_Application_Matrix__c where Customer__r.id =: accId ];
        
        for(Customer_Application_Matrix__c cam :camList){
            wrapcls wrp = new wrapcls();
            cam.Employee_Name__c = wrp.empName;
            
        }
        
        
        return 'string';
    }
    public with sharing class wrapcls{
        public string empName;
        public string department;
        public string industry;
        public string customer;
        public string newApplication;
        public string application;
        public string companyName;
        public string productBrand;
        public string productCategory;
        public string productName;
        public decimal productSize;
        public string alloyKgsAnnum;
        public string potentialLakhs;
        public string competitorCompanyName;
        public string competitorProductBrand;
        public string competitorProductCategory;
        public string competitorProductName;
        public decimal competitorProductSize;
        public string competitorAlloyKgsAnnum;
        public string competitorPotentialLakhs;
    }
}