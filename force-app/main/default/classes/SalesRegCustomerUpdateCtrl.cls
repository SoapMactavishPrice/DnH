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

            List<Sales_Register__c> salesRegisterActiveList = [
                SELECT Id, Name, Stati_State__c, FY_Quarter__c, Item_No__c, Target_Category_Bonus_Plan__c, Fiscal_Year__c,
                Fiscal_Year__r.Name, Taxable_Value__c, Voucher_No__c, Customer_Name__c, Sales_Order_No__c, Posting_Date__c,
                Sales_Engineer__c, Item_No__r.Name, Net_Invoice_Value__c
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

            List<Sales_Register_Line_Item__c> salesRegisterLineItems = [SELECT Id, Name, End_Customer__c, Net_Invoice_Value__c, Quantity_in_Variant_SKU__c, Sales_Register__c FROM Sales_Register_Line_Item__c WHERE Sales_Register__c IN :salesRegisterIds];

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
    public static String updateSalesRegisters(List<Sales_Register__c> recordsToUpdate) {
        try {
            update recordsToUpdate;
            return 'ok';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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
        @AuraEnabled public List<Sales_Register_Line_Item__c> lineItems;

        public SalesRegisterWrapper(Sales_Register__c sr, List<Sales_Register_Line_Item__c> salesRegisterLineItems) {
            this.id = sr.Id;
            this.key = sr.Id + ' - child';
            this.customerName = sr.Customer_Name__c;
            this.salesOrderNo = sr.Sales_Order_No__c;
            this.postingDate = sr.Posting_Date__c;
            this.salesEngineer = sr.Sales_Engineer__c;
            this.itemNoName = sr.Item_No__r != null ? sr.Item_No__r.Name : null;
            this.netInvoiceValue = sr.Net_Invoice_Value__c;
            
            for (Sales_Register_Line_Item__c eachItem : salesRegisterLineItems) {
                this.lineItems.add(new SalesRegisterLineItemWrapper(eachItem));
            }
        }
    }

    public class SalesRegisterLineItemWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String endCustomer;
        @AuraEnabled public Decimal netInvoiceValue;
        @AuraEnabled public Decimal quantity;

        public SalesRegisterLineItemWrapper(Sales_Register_Line_Item__c srli) {
            this.id = srli.Id;
            this.endCustomer = srli.End_Customer__c;
            this.netInvoiceValue = srli.Net_Invoice_Value__c;
            this.quantity = srli.Quantity_in_Variant_SKU__c;
        }
    }


}