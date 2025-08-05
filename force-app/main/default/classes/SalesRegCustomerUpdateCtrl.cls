public class SalesRegCustomerUpdateCtrl {
    
    @AuraEnabled
    public static string getCurrentActiveFY(){
        try {

            Fiscal_Year__c currFY = [
                SELECT Id, Name
                FROM Fiscal_Year__c
                WHERE isActive__c = true
            ];

            Map <String, String> resMap = new Map <String, String>();
            resMap.put('Id', currFY.Id);
            resMap.put('Name', currFY.Name);

            return JSON.serialize(resMap);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SalesRegisterWrapper> getSalesRegisterData(String fyId, String month){
        // try {

            String resData = '';

            String currentUserId = UserInfo.getUserId();
            User userObj = [SELECT Id, Code__c FROM User WHERE Id =: currentUserId LIMIT 1];

            List<String> salesRegisterIds = new List<String>();

            List<SalesRegisterWrapper> salesRegisters = new List<SalesRegisterWrapper>();

            System.debug('fyId ==>' + fyId);
            System.debug('month ==>' + month);

            List<Sales_Register__c> salesRegisterActiveList = [
                SELECT Id, Name, Stati_State__c, FY_Quarter__c, Item_No__c, Target_Category_Bonus_Plan__c, Fiscal_Year__c,
                Fiscal_Year__r.Name, Taxable_Value__c, Voucher_No__c, Customer_Name__c, Sales_Order_No__c, Posting_Date__c,
                Sales_Engineer__c, Item_No__r.Name, Net_Invoice_Value__c, Quantity_in_Variant_SKU__c
                FROM Sales_Register__c
                WHERE Fiscal_Year__c = :fyId
                AND Month__c = :month
                AND End_Customer__c = null
                // AND Stati_State__c != null
                // AND Target_Category_Bonus_Plan__c != null
                // AND FY_Quarter__c != null
            ];

            for (Sales_Register__c eachSalesRegister : salesRegisterActiveList) {
                salesRegisterIds.add(eachSalesRegister.Id);
            }
            Map<Id, List<Sales_Register_Line_Item__c>> salesRegisterLineItemMap = new Map<Id, List<Sales_Register_Line_Item__c>>();

            List<Sales_Register_Line_Item__c> salesRegisterLineItems = [SELECT Id, Name, End_Customer__c, End_Customer__r.Name, Net_Invoice_Value__c, Quantity_in_Variant_SKU__c, Sales_Register__c FROM Sales_Register_Line_Item__c WHERE Sales_Register__c IN :salesRegisterIds];

            for (Sales_Register_Line_Item__c eachSalesRegisterLineItem : salesRegisterLineItems) {
                if (!salesRegisterLineItemMap.containsKey(eachSalesRegisterLineItem.Sales_Register__c)) {
                    salesRegisterLineItemMap.put(eachSalesRegisterLineItem.Sales_Register__c, new List<Sales_Register_Line_Item__c>());
                }

                salesRegisterLineItemMap.get(eachSalesRegisterLineItem.Sales_Register__c).add(eachSalesRegisterLineItem);
            }

            for (Sales_Register__c eachSalesRegister : salesRegisterActiveList) {
                salesRegisters.add(new SalesRegisterWrapper(eachSalesRegister, salesRegisterLineItemMap.get(eachSalesRegister.Id)));
            }

            return salesRegisters;
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
    }

    @AuraEnabled
    public static string saveSalesRegisterLineItem(String salesRegisterStringObj){

        List<SalesRegisterWrapper> salesRegisters = parseHeaderAndLine(salesRegisterStringObj);

        List<Sales_Register_Line_Item__c> salesRegisterLineItemsToBeInserted = new List<Sales_Register_Line_Item__c>();

        for (SalesRegisterWrapper eachSalesRegister : salesRegisters) {
            if (eachSalesRegister.lineItems != null && !eachSalesRegister.lineItems.isEmpty()) {
                List<SalesRegisterLineItemWrapper> salesRegisterLineItems = eachSalesRegister.lineItems;
    
                for (SalesRegisterLineItemWrapper eachSalesRegisterLineItem : salesRegisterLineItems) {
    
                    Sales_Register_Line_Item__c salesRegisterLineItem = new Sales_Register_Line_Item__c();
                    if (eachSalesRegisterLineItem.id != null && String.isNotBlank(eachSalesRegisterLineItem.id)) {
                        salesRegisterLineItem.Id = eachSalesRegisterLineItem.id;
                    }

                    if (eachSalesRegisterLineItem.isNew) {
                        salesRegisterLineItem.Sales_Register__c = eachSalesRegister.id;
                    }
                    salesRegisterLineItem.End_Customer__c = eachSalesRegisterLineItem.endCustomer;
                    salesRegisterLineItem.Net_Invoice_Value__c = eachSalesRegisterLineItem.netInvoiceValue;
                    salesRegisterLineItem.Quantity_in_Variant_SKU__c = eachSalesRegisterLineItem.quantity;
    
                    salesRegisterLineItemsToBeInserted.add(salesRegisterLineItem);
                }
            }
        }

        System.debug('size of tobeinserted list ==>'+salesRegisterLineItemsToBeInserted.size());
        if (!salesRegisterLineItemsToBeInserted.isEmpty()) {
            UPSERT salesRegisterLineItemsToBeInserted;
        } else {
            throw new AuraHandledException('Please Enter line item to save');
        }

        return 'Success';
    }

    @AuraEnabled
    public static String updateSalesRegisters(List<Sales_Register__c> recordsToUpdate) {
        try {
            update recordsToUpdate;
            return 'ok';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<SalesRegisterWrapper> parseHeaderAndLine(string js){
        return (List<SalesRegisterWrapper>)system.JSON.deserialize(js,List<SalesRegisterWrapper>.class);
    }
    

    public class SalesRegisterWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String key;
        @AuraEnabled public String customerName;
        @AuraEnabled public String salesOrderNo;
        @AuraEnabled public Date postingDate;
        @AuraEnabled public String salesEngineer;
        @AuraEnabled public String itemNoName;
        @AuraEnabled public Decimal netInvoiceValue;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal rate;
        @AuraEnabled public List<SalesRegisterLineItemWrapper> lineItems;

        public SalesRegisterWrapper() {

        }

        public SalesRegisterWrapper(Sales_Register__c sr, List<Sales_Register_Line_Item__c> salesRegisterLineItems) {
            this.id = sr.Id;
            this.key = sr.Id + ' - child';
            this.customerName = sr.Customer_Name__c;
            this.salesOrderNo = sr.Sales_Order_No__c;
            this.postingDate = sr.Posting_Date__c;
            this.salesEngineer = sr.Sales_Engineer__c;
            this.itemNoName = sr.Item_No__r != null ? sr.Item_No__r.Name : null;
            this.netInvoiceValue = sr.Net_Invoice_Value__c;
            this.quantity = sr.Quantity_in_Variant_SKU__c;
            
            if (sr.Net_Invoice_Value__c > 0) {
                this.rate = sr.Net_Invoice_Value__c / sr.Quantity_in_Variant_SKU__c;
            } else {
                this.rate = 0;
            }
            

            if (this.lineItems == null) {
                this.lineItems = new List<SalesRegisterLineItemWrapper>();
            }
            
            if (salesRegisterLineItems != null) {
                for (Sales_Register_Line_Item__c eachItem : salesRegisterLineItems) {
                    this.lineItems.add(new SalesRegisterLineItemWrapper(eachItem));
                }
            }

            if (this.lineItems.isEmpty()) {
                this.lineItems = null;
            }
        }
    }

    public class SalesRegisterLineItemWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String tempId;
        @AuraEnabled public String endCustomer;
        @AuraEnabled public String endCustomerName;
        @AuraEnabled public Decimal netInvoiceValue;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Boolean isNew;
        @AuraEnabled public Boolean isOld;

        public SalesRegisterLineItemWrapper() {

        }

        public SalesRegisterLineItemWrapper(Sales_Register_Line_Item__c srli) {
            this.id = srli.Id;
            this.tempId = srli.Id;
            this.endCustomer = srli.End_Customer__c;
            this.endCustomerName = srli.End_Customer__r.Name;
            this.netInvoiceValue = srli.Net_Invoice_Value__c;
            this.quantity = srli.Quantity_in_Variant_SKU__c;
            this.isNew = false;
            this.isOld = true;
        }
    }


}