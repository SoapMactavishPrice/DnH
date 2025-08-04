public class SubmittedService19Controller {

    @AuraEnabled
    public static string getSubmittedServiceData(){
        try {

            List<Customer_Complaint__c> ccList = [
                SELECT Id, Name, Document_No__c, End_Customer_Name__c, Invoice__c, Brand_Name__c, Batch_No__c,
                Type_Of_Complaints__c, End_Customer_Name__r.Name, Invoice__r.Name
                FROM Customer_Complaint__c
            ];

            wrapperClass wc = new wrapperClass();
            List<DataWrapper> ccListwc= new List<DataWrapper>();
            Integer i = 0;

            for (Customer_Complaint__c cc : ccList) {
                DataWrapper ldwc= new DataWrapper();
                ldwc.DocumentNo = cc.Document_No__c;
                ldwc.CustomerName = cc.End_Customer_Name__r.Name;
                ldwc.InvoiceNo = cc.Invoice__r.Name;
                ldwc.BrandName = cc.Brand_Name__c;
                ldwc.BatchNo = cc.Batch_No__c;
                ldwc.TypeofComplaint = cc.Type_Of_Complaints__c;
                ldwc.index = i++;
                ccListwc.add(ldwc);
            }
            wc.dataList = ccListwc;
            return JSON.serialize(wc);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public with sharing class wrapperClass {
        public List<DataWrapper> dataList;
    }
    
    public with sharing class DataWrapper {
        public String DocumentNo;
        public String CustomerName;
        public String InvoiceNo;
        public String BrandName;
        public String BatchNo;
        public String TypeofComplaint;
        public String Status;
        public Integer index;
    }

}