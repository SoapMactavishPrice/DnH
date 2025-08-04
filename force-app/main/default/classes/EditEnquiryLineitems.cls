public class EditEnquiryLineitems {
    
    // Custom class for picklist options
    public class SelectOption {
        public String value { get; set; }
        public String label { get; set; }
        
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Enquiry_Line_Item__c> getEnquiryLineItems(Id enquiryId) {
        return [SELECT Id,name, Item_No__c, Item_Master__c, Item_Master__r.Name, Qty__c,Competitor__c, Dealer_Rate__c, Item_Description__c, Status__c,Reason_for_lost_enquiry__c 
                FROM Enquiry_Line_Item__c 
                WHERE Enquiry__c = :enquiryId];
    }
    
    // @AuraEnabled(cacheable=true)
    // public static List<SelectOption> getStatusPicklistOptions() {
    //     List<SelectOption> options = new List<SelectOption>();
    //     // Get the describe result for the Status__c field
    //     Schema.DescribeFieldResult fieldResult = Enquiry_Line_Item__c.Status__c.getDescribe();
    
    //     // Get the picklist values
    //     for (Schema.PicklistEntry entry : fieldResult.getPickListValues()) {
    //         options.add(new SelectOption(entry.getValue(), entry.getLabel()));
    //     }
    //     system.debug('options'+options);
    //     return options; // Return the list of picklist options
    // }
    @AuraEnabled(cacheable=true)
    public static List<PicklistValue> getStatusPicklistOptions(){
        String strObjectName = 'Enquiry_Line_Item__c';
        String strPicklistField = 'Status__c';
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        List<PicklistValue> valuesList = new List<PicklistValue>();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            PicklistValue pv = new PicklistValue(objPickList.getValue(), objPickList.getLabel());
            valuesList.add(pv);
            system.debug(valuesList);
        }
        return valuesList;
    }    
    
    
    // @AuraEnabled(cacheable=true)
    // public static List<SelectOption> getLostReasonPicklistOptions() {
    //     List<SelectOption> options = new List<SelectOption>();
    //     // Get the describe result for the Reason_for_lost_enquiry__c field
    //     Schema.DescribeFieldResult fieldResult = Enquiry_Line_Item__c.Reason_for_lost_enquiry__c.getDescribe();
    
    //     // Get the picklist values
    //     for (Schema.PicklistEntry entry : fieldResult.getPickListValues()) {
    //         options.add(new SelectOption(entry.getValue(), entry.getLabel()));
    //     }
    //     system.debug('options'+options);
    //     return options; // Return the list of picklist options
    // }
    
    @AuraEnabled(cacheable=true)
    public static List<PicklistValue> getLostReasonPicklistOptions(){
        String strObjectName = 'Enquiry_Line_Item__c';
        String strPicklistField = 'Reason_for_lost_enquiry__c';
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        List<PicklistValue> valuesList = new List<PicklistValue>();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            PicklistValue pv = new PicklistValue(objPickList.getValue(), objPickList.getLabel());
            valuesList.add(pv);
            system.debug(valuesList);
        }
        return valuesList;
    }    
    
    @AuraEnabled(cacheable=true)
    public static List<PicklistValue> getComprtitormaster() {
        List<Competitor__c> comprtitormaster = [select id,name from Competitor__c ];
        List<PicklistValue> pvComprtitormasterList = new List<PicklistValue>();
        for (Competitor__c master : comprtitormaster) {            PicklistValue pv = new PicklistValue(master.Id, master.Name);
                                                       pvComprtitormasterList.add(pv);
                                                      }
        return pvComprtitormasterList;
    }
    
    @AuraEnabled
    public static String saveProducts(String recordData, String recId) {
        System.debug('recordData'+recordData);
        if(recordData != ''){
        String s = recordData.replace('__c','_c');
        // List<Enquiry_Line_Item__c> prodList = List<Enquiry_Line_Item__c>();
        List<ProductWrapper> wc = (List<ProductWrapper>)JSON.deserialize(s, List<ProductWrapper>.class);
        List<Enquiry_Line_Item__c> lsteli = new List<Enquiry_Line_Item__c>();
        system.debug('wc'+wc);
        Enquiry__c Enquiry  = [SELECT Id  FROM enquiry__c WHERE Id = :recId];
        for (ProductWrapper pw : wc) {
       
        Enquiry_Line_Item__c eli = new Enquiry_Line_Item__c();
        eli.id = pw.Id;    
        //eli.Enquiry__c = recId;
        eli.Status__c = pw.Status_c;
        eli.Qty__c = pw.Qty_c;
        eli.Competitor__c	 = pw.Competitor_c;
        system.debug('Competitor'+eli.Competitor__c);
        eli.Competitor_Product__c  = pw.Competitor_Product_c;
        system.debug('Competitor_Product__c'+eli.Competitor_Product__c);
        system.debug(' pw.Competitor_Product_c'+ pw.Competitor_Product_c);
        eli.Sales_Price__c = pw.Sales_Price_c;
        eli.Reason_for_lost_enquiry__c = pw.Reason_for_lost_enquiry_c;
        system.debug('Status__c'+eli.Status__c);
            lsteli.add(eli);
}
         system.debug('lsteli'+lsteli);
         update lsteli;
        }
       
        return 'success';
    }
    public with sharing class wrapperClass {
        public String priceBook;
        public List<ProductWrapper> productList;
    }
    
    public with sharing class ProductWrapper {
        public String Name;
        public String Id;
        public String purl;
        public String Status_c;
        public String ProductCode;
        public String HSNSACcode;
        public string ProductMainGroup;
        public string ProductGroup;
        public string ProductSubTypeGroup;
        public String Itemcategory;
        public string ValuesIn;
        public String PackSize;
        public String Competitor_Product_c;
        public String Reason_for_lost_enquiry_c;
        public String Competitor_c;
        public integer index;
        public Decimal Price;
        public Decimal Sales_Price_c;
        public Decimal Qty_c = 0;
        public String Family;
        
        public Date PDate;
        public String Description;
        public String LineDescription;
        public String Taxcode;
        public String BPCatalogueNo;
        public decimal CGSTRATE;
        public decimal IGSTRATE;
        public decimal SGSTRATE;
        public boolean showError;
        public decimal Discount = 0;
        public decimal AdditionalCost = 0;
        public decimal PackingCost = 0;
        public decimal TotalAmount = 0;
        
        
    }
    public class PicklistValue {
        @auraenabled
        public String label {get;set;}
        @auraenabled
        public String value {get;set;}
        
        public PicklistValue(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}