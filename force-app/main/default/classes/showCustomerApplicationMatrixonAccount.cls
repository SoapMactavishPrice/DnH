public class showCustomerApplicationMatrixonAccount {

    @AuraEnabled
    public static String getCustomerApplicationMatrix() {
        List<Customer_Application_Matrix__c> customerApplicationMatrixList = [
            SELECT Id, Name, Customer__r.name, Employee_Name__c,Employee_Name__r.name, Industry__r.name, Department__r.name, New_Application__c, Application__r.name, Company_Name__c, 
                   Competitor_Name__r.name, Product_Brand__c, Product_Category__c, Product_Name__r.name, Product_Size__c, Alloy_Kgs_Annum__c, Potential_Lakhs__c,
                   Competitor_Product_Brand__c, Competitor_Product_Category__c, Competitor_Potential_Lakhs__c, Competitor_Alloy_Kgs_Annum__c, 
                   Competitor_Product_Name__c, Competitor_Product_Size__c 
            FROM Customer_Application_Matrix__c  ];
        //WHERE Customer__c = :accId 
        List<wrapcls> wrList = new List<wrapcls>();
        Integer i = 1;

        
        for(Customer_Application_Matrix__c cam : customerApplicationMatrixList){
            wrapcls wrp = new wrapcls();
            wrp.SrNo = i++;
            wrp.Id = cam.Id;
            wrp.purl = '/lightning/r/' +cam.Id+'/view';
            //wrp.Name = '/lightning/r/' +cam.Id+'/view';
            wrp.name = cam.name;
            wrp.empName = cam.Employee_Name__r.name;
            wrp.customer = cam.Customer__r.name;
            wrp.industry = cam.Industry__r.name;
            wrp.department = cam.Department__r.name;
            wrp.newApplication = cam.New_Application__c;
            wrp.application = cam.Application__r.name;
            wrp.companyName = cam.Company_Name__c;
            wrp.competitorName = cam.Competitor_Name__r.name;
            wrp.productBrand = cam.Product_Brand__c;
            wrp.productCategory = cam.Product_Category__c;
            wrp.productname = cam.Product_Name__r.name;
            wrp.productSize = cam.Product_Size__c;
            wrp.alloyKgsAnnum = cam.Alloy_Kgs_Annum__c;
            wrp.potentialLakhs = cam.Potential_Lakhs__c;
            wrp.competitorProductBrand = cam.Competitor_Product_Brand__c;
            wrp.competitorProductCategory = cam.Competitor_Product_Category__c;
            wrp.competitorProductname = cam.Competitor_Product_Name__c;
            wrp.competitorProductSize = cam.Competitor_Product_Size__c;
            wrp.competitorAlloyKgsAnnum = cam.Competitor_Alloy_Kgs_Annum__c;
            wrp.competitorPotentialLakhs = cam.Competitor_Potential_Lakhs__c;
            wrList.add(wrp); 
        }

    
        return JSON.serialize(wrList); 
    }
    public with sharing class wrapcls{
        public Integer SrNo;
        public String Id;
        public String purl;
        public String Name;
        public string empName;
        public string customer;
        public string industry;
        public string department;
        public string newApplication;
        public string application;
        public string companyName;
        public string competitorName;
        public string productBrand;
        public string productCategory;
        public string productname;
        public string productSize;
        public decimal alloyKgsAnnum;
        public decimal potentialLakhs;
        public string competitorCompanyName;
        //public string competitorName;
        public string competitorProductBrand;
        public string competitorProductCategory;
        public string competitorProductname;
        public string competitorProductSize;
        public decimal competitorAlloyKgsAnnum;
        public decimal competitorPotentialLakhs;  
        
    }
    
}