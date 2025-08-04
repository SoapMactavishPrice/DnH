public with sharing class AddProductPageEnq {
    
       @AuraEnabled(cacheable=true)
        public static List<Item_Master__c> getProducts(String selectedItemCategory) {
        String query = 'SELECT Id, Name, Item_Brand__c, Item_Category__c, Item_Group__c, Family__c FROM Item_Master__c ';
        System.debug('Enq list: ' + query);

        // Append WHERE clause based on selected status
        if (String.isNotBlank(selectedItemCategory)) {
            query += ' WHERE Item_Category__c = :selectedItemCategory';
        }

        return Database.query(query);
    }
    @AuraEnabled
    public static String findProduct(String recordId, List<String> productFamily) {
       
        Enquiry__c enq = [SELECT Id, Name,Pricelist__c,Pricelist__r.Name FROM Enquiry__c WHERE Id = :recordId];
        system.debug('Enquiry'+enq);
            system.debug('Enquiry Pricelist'+enq.Pricelist__c);
        
        List<Enquiry_Line_Item__c>  enqlIst = [select Id,Item_Master__c from Enquiry_Line_Item__c where Enquiry__c =:recordId ]; 
        system.debug('EqlIst - '+enqlIst);
              
         set<Id>existingProdId = new set<Id>();
        if(enqlIst.size() > 0){
            for(Enquiry_Line_Item__c eql : enqlIst){
              existingProdId.add(eql.Item_Master__c);  
            }
        }
       /* List<Enquiry_Line_Item__c>  enqlIst1 = [select Id,Item_Master__c,Item_Master__r.Name,Item_Master__r.Product_Code__c,Item_Master__r.Item_Category__c
                                                ,Item_Master__r.Family__c,Item_Master__r.Item_Description__c from Enquiry_Line_Item__c where Item_Master__c IN :existingProdId order by createddate desc limit 5 ];
        system.debug('enqlIst1'+enqlIst1);
        system.debug('existingProdId'+existingProdId);
       List<ProductWrapper> recentItems = new List<ProductWrapper>();
        
        for (Enquiry_Line_Item__c item : enqlIst1) {
            ProductWrapper pw = new ProductWrapper();
            pw.Id = item.Id;
            pw.purl = '/lightning/r/' + item.Item_Master__c + '/view';
            pw.Name = item.Item_Master__r.Name;
            pw.ProductCode = item.Item_Master__r.Product_Code__c;
            pw.Itemcategory = item.Item_Master__r.Item_Category__c;
            pw.Family = item.Item_Master__r.Family__c;
            pw.Description = item.Item_Master__r.Item_Description__c;
            
            recentItems.add(pw);
        }
         system.debug('recentItems'+recentItems);
        
        */
        
        wrapperClass wc = new wrapperClass();
        wc.priceBook = enq.Pricelist__r.Name;
        //wc.recentEnquiryItems = recentItems;

        
        string productQuery = 'select id,name,Item_Brand__c,Item_Category__c,Item_Group__c,Family__c from Item_Master__c where Id NOT IN :existingProdId';
        
         if(productFamily.size() > 0){ productQuery+=' AND Family__c IN : productFamily';
           // productQuery+=' where Family IN '+productFamily;
        }
        set<Id> prodId = new set<Id>();
        for(Item_Master__c pd : database.query(productQuery)){
            prodId.add(pd.Id);
            system.debug('prodId'+prodId);
        }
        if(string.isNotblank(enq.Pricelist__c)){
            system.debug('Inside enq.Pricelist__c>>> ');
            
            String query = 'SELECT Id, Name, Item_Name__c, IsActive__c,List_Price__c,Item_Name__r.Name,Item_Name__r.Item_Description__c,Item_Name__r.List_Price__c, Item_Name__r.Item_Brand__c, Item_Name__r.Item_Category__c, Item_Name__r.Product_Code__c, Item_Name__r.Item_Group__c, Item_Name__r.Family__c, Pricelist_Master__c ' + 
               'FROM Pricelist_Line_Item__c ' +
               'WHERE Pricelist_Master__c = \'' + enq.Pricelist__c + '\' ' +
               'AND IsActive__c = true ' +
               'AND Item_Name__c IN :prodId';
    
           List<Pricelist_Line_Item__c> lstPBE = (List<Pricelist_Line_Item__c>)Database.query(query);
        system.debug('lstPBE'+lstPBE);
        List<ProductWrapper> lstProduct= new List<ProductWrapper>();
        integer i = 0;
        for(Pricelist_Line_Item__c pbe : lstPBE){
            ProductWrapper pw = new ProductWrapper();
                    pw.Id = pbe.Id;
                    pw.purl = '/lightning/r/' +pbe.Id+'/view';
                    pw.Product2Id = pbe.Item_Name__c;
                    pw.Name =pbe.Item_Name__r.Name;
                    pw.ProductCode = pbe.Item_Name__r.Product_Code__c ;
                    //pw.HSNSACcode = pbe.Product2.HSN_Code__r.name;
                    pw.Itemcategory =pbe.Item_Name__r.Item_Category__c;
                    
                    //pw.ProductMainGroup =pbe.Product2.Product_Main_Group__c;
                    //pw.ProductSubTypeGroup = pbe.Product2.Product_Sub_Group__c;
                
                   // pw.PackSize = pbe.Product2.Pack_Size__c;
                    pw.Family = pbe.Item_Name__r.Family__c;
                    //pw.ValuesIn = pbe.Product2.values_in__c;
                    pw.Description= pbe.Item_Name__r.Item_Description__c;
                    pw.Price = pbe.List_Price__c;
                    pw.SalesPrice = null;
                    // pw.hsnMasterId = pbe.Product2.HSN_Code__c;
                   //  pw.hsnMasterCode =pbe.Product2.HSN_Code__r.Name;
                   //  pw.CGSTRATE = pbe.Product2.HSN_Code__r.CGST_Rate__c;
                   //  pw.SGSTRATE = pbe.Product2.HSN_Code__r.SGST_Rate__c;
                   //  pw.IGSTRATE = pbe.Product2.HSN_Code__r.IGST_Rate__c;
                    pw.index = i++;
                    pw.showError = false;
                    system.debug('group'+pw);
                    lstProduct.add(pw);
                    system.debug(lstProduct);
                    System.debug('productList size'+lstProduct.size());
        }
        wc.productList = lstProduct;
        }
             return JSON.serialize(wc);
        
        
    }
     @AuraEnabled
    public static String findRecentenqlineitem(String productId) {
        // Perform the query
        if (String.isEmpty(productId)) {
            system.debug('productId'+productId);
            return JSON.serialize(new List<Enquiry_Line_Item__c>());
            //return JSON.serialize(new wrapperClass());
        }
        system.debug('productId'+productId);
        List<Enquiry_Line_Item__c> enqlIst1 = [
            SELECT Id,name, Item_Master__c, Item_Master__r.Name, Item_Master__r.Product_Code__c,
                   Item_Master__r.Item_Category__c, Item_Master__r.Family__c, Item_Master__r.Item_Description__c,Qty__c,Enquiry__c,
                   Sales_Price__c,Enquiry__r.name,Enquiry__r.Account__c,Enquiry__r.Account__r.name,Enquiry__r.Enquiry_Name__c
            FROM Enquiry_Line_Item__c 
            WHERE Item_Master__c = :productId 
            ORDER BY CreatedDate DESC 
            LIMIT 5
        ];
       

         system.debug('enqlIst1'+enqlIst1);
       

        return JSON.serialize(enqlIst1); 
    }
    
     @AuraEnabled
    public static Map<string,List<PicklistValue>> getproductfamily(){
        String strObjectName = 'Item_Master__c';
        String strPicklistField = 'Family__c';
        String strPicklistField1 = 'Item_Category__c';
        String strPicklistField2 = 'Item_Brand__c';
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        system.debug('mapFields'+mapFields);
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        List<Schema.PicklistEntry> lstPickListValues1 = mapFields.get(strPicklistField1).getDescribe().getPickListValues();
        List<Schema.PicklistEntry> lstPickListValues2 = mapFields.get(strPicklistField2).getDescribe().getPickListValues();
        
        List<PicklistValue> pvList = new List<PicklistValue>();
        List<PicklistValue> pvList1 = new List<PicklistValue>();
        List<PicklistValue> pvList2 = new List<PicklistValue>();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            PicklistValue pv = new PicklistValue(objPickList.getValue(), objPickList.getLabel());
            pvList.add(pv);
        }
        for (Schema.PicklistEntry objPickList : lstPickListValues1) {
            PicklistValue pv = new PicklistValue(objPickList.getValue(), objPickList.getLabel());
            pvList1.add(pv);
        }
        for (Schema.PicklistEntry objPickList : lstPickListValues2) {
            PicklistValue pv = new PicklistValue(objPickList.getValue(), objPickList.getLabel());
            pvList2.add(pv);
        }
        
        Map<string,List<PicklistValue>> mpValues = new Map<string,List<PicklistValue>>();
        mpValues.put('Family__c',pvList);
        mpValues.put('ItemCategory',pvList1);
        mpValues.put('ItemBrand',pvList2);
        
        
        return mpValues;
        
    }
         @AuraEnabled
        public static List<PicklistValue> getItemCategory(){
         String strObjectName = 'Item_Master__c';
        String strPicklistField = 'Item_Category__c';
         Map<String, String> mapPickListValues = new Map<String, String>();
         Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        List<PicklistValue> pvitemtypeList = new List<PicklistValue>();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            PicklistValue pv = new PicklistValue(objPickList.getValue(), objPickList.getLabel());
            pvitemtypeList.add(pv);
             system.debug(pvitemtypeList);
        }
        return pvitemtypeList;
    }
     @AuraEnabled
    public static String saveProducts( String recordData, String recId ){
       
        List<ProductWrapper> wc  = (List<ProductWrapper>)json.deserialize(recordData, List<ProductWrapper>.class);
        List<Enquiry_Line_Item__c> lstOpp = new List<Enquiry_Line_Item__c>();
        for(ProductWrapper pw : wc){
            System.debug(' pw' + pw);
            Enquiry_Line_Item__c oli = new Enquiry_Line_Item__c();
            oli.Qty__c = pw.Quantity;
            oli.Product_Family__c = pw.Family;
            oli.List_Price__c = pw.Price;
            oli.Sales_Price__c = pw.Price;
            oli.Discount_In_Percentage__c = pw.Discount;
            system.debug('Price'+pw.Price);
          
                       
            //oli.Item_Description__c = pw.LineDescription;
            oli.enquiry__c = recId;//'0065j00000N2RXiAAN';
            oli.Item_Master__c = pw.Product2Id;
          
            lstOpp.add(oli);
            System.debug(' pw' + lstOpp);
            
        }
        try {
            insert lstOpp;
            return 'success';
        } catch (Exception e) {
            System.debug(e.getMessage());
            return 'error';
        }        
    }
        
    
     public with sharing class wrapperClass {
        public String priceBook;
        public List<ProductWrapper> productList;
        //public List<ProductWrapper> recentEnquiryItems;
        public List<Enquiry_Line_Item__c> recentEnquiryItems;
    }
    public with sharing class ProductWrapper {
        public String Name;
        public String Id;
        public String purl;
        public String Product2Id;
        public String ProductCode;
        public String HSNSACcode;
        public string ProductMainGroup;
        public string ProductSubTypeGroup;
        public String Itemcategory;
        public string ValuesIn;
        public String PackSize;
        public String hsnMasterId;
        public String hsnMasterCode;
        public integer index;
        public Decimal Price;
        public Decimal SalesPrice;
        public Decimal Quantity = 0;
        public String Family;
        public Date PDate;
        public String Description;
        public String LineDescription;
        public String Taxcode;
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