public class AddProductPageQuote {
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
       
        Quote__c enq = [SELECT Id, Name,Pricelist__c,Pricelist__r.Name FROM Quote__c WHERE Id = :recordId];
      	system.debug('Enquiry'+enq);
        	system.debug('Enquiry Pricelist'+enq.Pricelist__c);
        
        List<Quote_Line_Item__c>  enqlIst = [select Id,Item_Master__c from Quote_Line_Item__c where Quote__c =:recordId ]; 
        system.debug('EqlIst - '+enqlIst);
      
         set<Id>existingProdId = new set<Id>();
        if(enqlIst.size() > 0){
            for(Quote_Line_Item__c eql : enqlIst){
              existingProdId.add(eql.Item_Master__c);  
            }
        }
        
        system.debug('existingProdId'+existingProdId);
        wrapperClass wc = new wrapperClass();
        wc.priceBook = enq.Pricelist__r.Name;
        
        
        string productQuery = 'select id,name,Item_Brand__c,Item_Category__c,Item_Group__c,Family__c from Item_Master__c where Id NOT IN :existingProdId';
        
         if(productFamily.size() > 0){ productQuery+=' where Family__c IN : productFamily';
           // productQuery+=' where Family IN '+productFamily;
        }
        set<Id> prodId = new set<Id>();
        for(Item_Master__c pd : database.query(productQuery)){
            prodId.add(pd.Id);
            system.debug('prodId'+prodId);
        }
        if(string.isNotblank(enq.Pricelist__c)){
            system.debug('Inside enq.Pricelist__c>>> ');
			
            String query = 'SELECT Id, Name, Item_Name__c, IsActive__c,Item_Name__r.Name,Item_Name__r.Item_Description__c,Item_Name__r.List_Price__c, Item_Name__r.Item_Brand__c, Item_Name__r.Item_Category__c, Item_Name__r.Product_Code__c, Item_Name__r.Item_Group__c, Item_Name__r.Family__c, Pricelist_Master__c ' + 
               'FROM Pricelist_Line_Item__c ' +
               'WHERE Pricelist_Master__c = \'' + enq.Pricelist__c + '\' ' +
               'AND IsActive__c = true ' +
               'AND Item_Name__c IN :prodId';
            
            /*   String query = 'SELECT Id, UnitPrice, Product2Id, Product2.Name, Product2.Family, Product2.ProductCode, Product2.Item_Category__c, Product2.HSN_Code__c, Product2.HSN_Code__r.Name, Product2.Product_Main_Group__c, Product2.Product_Sub_Group__c, Product2.Description ' +
               'FROM PricebookEntry ' +
               'WHERE CurrencyISOCode = \'' + op.currencyISOcode + '\' ' +
               'AND Pricebook2Id = \'' + op.Pricebook2Id + '\' ' +
               'AND IsActive = true ' +
               'AND Product2Id IN :prodId';*/
            
            
            
            
            
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
                    pw.Price = pbe.Item_Name__r.List_Price__c;
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
        List<Quote_Line_Item__c> lstOpp = new List<Quote_Line_Item__c>();
        for(ProductWrapper pw : wc){
            System.debug(' pw' + pw);
            Quote_Line_Item__c oli = new Quote_Line_Item__c();
            oli.Quantity__c = pw.Quantity;
            oli.Product_Family__c = pw.Family;
            oli.List_Price__c = pw.Price;
             
            //oli.ServiceDate = system.today();
            oli.Discount_In_Percentage__c = pw.Discount;
            //oli.Additional_Cost__c=pw.AdditionalCost;
            //oli.Packing_Cost__c=pw.PackingCost;
            //oli.Item_Category__c = pw.Itemcategory;
            system.debug('Price'+pw.Price);
            /*decimal discountamount1 = 0;
            discountamount1 = ((pw.Price*pw.Quantity) *(pw.Discount/100));  //50
            system.debug('discountamount1'+discountamount1);
            decimal discountamount = 0;
             discountamount =  (pw.Price*pw.Quantity) - discountamount1;
            //(pw.AdditionalCost/100);
 			system.debug('discountamount'+discountamount);
            decimal Additionalamount = 0;
            Additionalamount = discountamount *(pw.AdditionalCost/100);
            decimal packingcost =0;
            decimal total =0;
            packingcost = discountamount *(pw.PackingCost/100);
            pw.TotalAmount =  discountamount + Additionalamount + packingcost ;
            system.debug('TotalAmount'+pw.TotalAmount);*/
			           
            oli.Item_Description__c = pw.LineDescription;
            oli.Quote__c = recId;//'0065j00000N2RXiAAN';
            oli.Item_Master__c = pw.Product2Id;
           // oli.Tax_Code__c = pw.Taxcode;
           // oli.values_in__c = pw.ValuesIn;
            //oli.Total_Amountx__c = pw.TotalAmount;
            //decimal Total = oli.TotalPrice*(pw.AdditionalCost/100);
           // pw.TotalAmount = total;
           // system.debug('Total'+pw.TotalAmount);
            //oli.Total_Amountx__c = pw.TotalAmount; 
           // System.debug(oli.Additional_Cost__c);
            //System.debug(pw.ValuesIn);
           // System.debug(oli.values_in__c);
            
          //   oli.HSN_Master__c = pw.hsnMasterId;
          //   oli.CGST_RATE__c = pw.CGSTRATE;
          //   oli.SGST_RATE__c = pw.SGSTRATE;
          //   oli.IGST_RATE__c = pw.IGSTRATE;
            //oli.Pack_Size__c = pw.PackSize;
           // oli.PricebookEntryId = pw.Id;//'01u5j000003Pq51AAC';
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