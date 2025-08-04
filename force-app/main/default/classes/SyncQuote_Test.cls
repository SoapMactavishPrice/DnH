@isTest
public class SyncQuote_Test {
    static testMethod void testSyncQuoteOppWithAcceptedQuote() {
        //  Id PID = Test.getStandardPricebookId();
        
        Pricelist__c PriceList = new Pricelist__c();
        PriceList.Name = 'D & H Price Book';
        PriceList.Status__c = 'Active';
        
        insert PriceList;
        
        
        Item_Master__c prod = new Item_Master__c ();
        prod.name='LoTherme-605';
        insert prod;
        
        Account acc = new Account();
        acc.Name = 'Finesse IT';
        insert acc;
        
        
        Enquiry__c Enq = new Enquiry__c(
            // Name = ENQ2024060004,
            Enquiry_Name__c = 'Test Opportunity',
            Expected_Closure_Date__c = System.today().addDays(10),
            Enquiry_Stage__c = 'New',
            Account__c = acc.Id,
            Pricelist__c=PriceList.Id);
        insert Enq;
        
       Quote__c testQuote = new Quote__c(
            Quote_Name__c = 'Test Quote',
            Enquiry__c = Enq.Id,
            Account__c = acc.Id,
            Quote_Status__c = 'Accepted');
        insert testQuote;
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c(
            Quote__c = testQuote.Id,
            Item_Master__c = prod.Id,
            Quantity__c = 5,
            Sales_Price__c = 100.00);
        insert qli;
        
        Test.startTest();
        // Make sure to pass the quote ID to the page parameters
        ApexPages.currentPage().getParameters().put('id', testQuote.Id);
        SyncQuote controller = new SyncQuote();
        PageReference pageRef = controller.syncQuoteOpp();
        Test.stopTest();
        
    }
    
    
    @isTest
    static void testSyncQuoteWithNonAcceptedStatus() {
        
        Pricelist__c PriceList = new Pricelist__c();
        PriceList.Name = 'D & H Price Book';
        PriceList.Status__c = 'Active';
        insert PriceList;
        
        Item_Master__c prod = new Item_Master__c ();
        prod.name='LoTherme-605';
        
        insert prod;
        
        Account acc = new Account();
        acc.Name = 'Finesse IT';
        insert acc;
        
        
        Enquiry__c Enq = new Enquiry__c(
            // Name = ENQ2024060004,
            Enquiry_Name__c = 'Test Opportunity',
            Expected_Closure_Date__c = System.today().addDays(10),
            Enquiry_Stage__c = 'New',
            Account__c = acc.Id,
            Pricelist__c=PriceList.Id);
        insert Enq;
        
        Enquiry_Line_Item__c ELI = new Enquiry_Line_Item__c(
            Enquiry__c = Enq.Id,
            //Item_Master__c = prod.Id,
            Qty__c = 5,
            Sales_Price__c = 100.00,
            Item_Master__c = prod.Id);
        insert ELI;
        
        
        Quote__c testQuote = new Quote__c(
            Quote_Name__c = 'Test Quote',
            Enquiry__c = Enq.Id,
            Account__c = acc.Id,
            Quote_Status__c = 'Draft');
        insert testQuote;
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c(
            Quote__c = testQuote.Id,
            Item_Master__c = prod.Id,
            Quantity__c = 5,
            Sales_Price__c = 100.00);
        insert qli;
        
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', testQuote.Id);
        SyncQuote controller = new SyncQuote();
        PageReference pageRef = controller.syncQuoteOpp();
        Test.stopTest();
        
    }
    
    static testMethod void testSyncQuoteElseBlock() {
        
        Pricelist__c PriceList = new Pricelist__c();
        PriceList.Name = 'D & H Price Book';
        PriceList.Status__c = 'Active';
        
        insert PriceList;
        
        Item_Master__c prod = new Item_Master__c ();
        prod.name='LoTherme-605';
        
        insert prod;
        
        Account acc = new Account();
        acc.Name = 'Finesse IT';
        insert acc;
        
        
        Enquiry__c Enq = new Enquiry__c(
           
            Enquiry_Name__c = 'Test Opportunity',
            Expected_Closure_Date__c = System.today().addDays(10),
            Enquiry_Stage__c = 'New',
            Account__c = acc.Id,
            Pricelist__c=PriceList.Id);
        insert Enq;
        
        Enquiry_Line_Item__c ELI = new Enquiry_Line_Item__c(
            Enquiry__c = Enq.Id,
           
            Qty__c = 5,
            Sales_Price__c = 100.00,
            Item_Master__c = prod.Id);
        insert ELI;
        
        
        Quote__c testQuote = new Quote__c(
            Quote_Name__c = 'Test Quote',
            Enquiry__c = Enq.Id,
            Account__c = acc.Id,
            Quote_Status__c = 'Submitted');
        insert testQuote;
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c(
            Quote__c = testQuote.Id,
            Item_Master__c = prod.Id,
            Quantity__c = 5,
            Sales_Price__c = 100.00);
        
        testQuote.Quote_Status__c = 'Accepted';
        update testQuote;       
        insert qli;
        
        
        Test.startTest();
       
        ApexPages.currentPage().getParameters().put('id', testQuote.Id);
        SyncQuote controller = new SyncQuote();
        PageReference pageRef = controller.syncQuoteOpp();
        Test.stopTest();
        
    }
    
    
    
}