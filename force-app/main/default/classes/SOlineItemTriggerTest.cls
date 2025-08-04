@isTest
public class SOlineItemTriggerTest {
    
    public static testMethod void validate(){

        Account account = new Account(Name = 'Test Account', Type__c = 'End Customer');
        insert account;

        Item_Master__c itemMaster = new Item_Master__c(
            Item_Number__c = 'FGM0014990',
            Item_Description__c = 'Test Item',
            Base_Unit_of_Measure__c = 'KGS',
            Sales_Unit_of_Measure__c = 'KGS',
            Item_Type__c = 'Normal'
        );
        insert itemMaster;

        Item_Variant__c var = new Item_Variant__c();
        var.name = 'a0hF3000003WIqH';
        var.Code__c = '1SPL/25KG';
        var.Item_No__c = 'FGM0014990';
        var.Item_Master__c = itemMaster.Id;
        insert var;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id);
        insert con;

        // Create an Enquiry__c record
        Enquiry__c enq = new Enquiry__c(
            Account__c = account.Id,
            Contact__c = con.Id,
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0
        );
        insert enq;

        List < Enquiry_Line_Item__c > enquiryLineItems = new List < Enquiry_Line_Item__c > {
            new Enquiry_Line_Item__c(
                Enquiry__c = enq.Id,
                Qty__c = 10,
                RemainingQty__c = 10,
                List_Price__c = 100,
                Product_Family__c = 'FGM04',
                Item_Master__c = itemMaster.Id,
                Required_Rate_by_AM__c = 1001,
                Conversion_Quantity__c = 2001,
                Item_Value__c = 1234,
                Item_No__c = 'FGM0014990'
            )
        };

        insert enquiryLineItems;

        Customer_Sales_Person_Mapping__c customerSalesPersonMapping = new Customer_Sales_Person_Mapping__c(
            Account__c = account.id // Example Account ID
            // Sales_Person__c = '0052b00000Wj6M5AA4' // Example User ID for Sales Person
        );
        insert customerSalesPersonMapping;

        Pricelist__c p = new Pricelist__c();
        p.Name = 'Test';
        insert p;

        Pricelist_Line_Item__c pl = new Pricelist_Line_Item__c();
        pl.Pricelist_Master__c = p.Id;
        pl.Item_No__c = 'test 001';
        insert pl;

        Sales_Order__c sales = new Sales_Order__c();
        sales.Name = 'Sales_Order__c';
        sales.Enquiry__c = enq.id;
        insert sales;

        Sales_Order_Line_Item__c solItem = new Sales_Order_Line_Item__c(
            //Name = 'Test SOL Item',
            Sales_Order__c = sales.Id,
            Item_Master__c = itemMaster.Id,
            Quantity__c = 1,
            Item_Number__c = 'FGM0014990'
        );
        //insert solItem;
        
        Sales_Order_Line_Item__c solItem1 = new Sales_Order_Line_Item__c(
            //Name = 'Test SOL Item',
            Sales_Order__c = sales.Id,
            Item_Master__c = itemMaster.Id,
            Quantity__c = 1,
            Item_Number__c = 'FGM0014990'
        );
        //insert solItem1;
        
        List<Sales_Order_Line_Item__c> solilist = new List<Sales_Order_Line_Item__c>();
        solilist.add(solItem);
        solilist.add(solItem1);
        insert solilist;
    }

}