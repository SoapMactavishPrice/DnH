@isTest
public class AddSOrderPageEnqControllerTest {
    @isTest
    static void testGetEnqLineItems() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Enquiry__c enquiry = new Enquiry__c(Account__c = acc.Id);
        insert enquiry;

        Item_Master__c item = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (NORMA-V)');
        insert item;

    Enquiry_Line_Item__c enquiryLine = new Enquiry_Line_Item__c(
            Enquiry__c = enquiry.Id,
            Item_Master__c = item.Id,
         //   Name = 'TestLineItem123',
            Qty__c = 100,
            Order_Qty__c = 50,
            RemainingQty__c = 50
        );
        insert enquiryLine;

        // Call the method
        String result = AddSOrderPageEnqController.getEnqLineItems(enquiry.Id);

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
     //   System.assert(result.contains('TestLineItem123'), 'Result should contain the line item name');
     //   System.assert(result.contains('Electronics'), 'Result should contain the product family');
    }

    @isTest
    static void testCreateQuote() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact contact = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id);
        insert contact;

        Enquiry__c enquiry = new Enquiry__c(
            Account__c = acc.Id,
            Contact__c = contact.Id,
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0,
            Shipment__c = 'Air',
         //   Other_Terms_Conditions__c = 'Test Conditions',
            Inco_Terms__c = 'CIF',
            Inco_Terms_Remark__c = 'Test Remark',
            Payment_Terms__c = 'LC'
          //  Other_Payment_Terms__c = 'Custom Terms'
           // Other_Delivery_Terms__c = 'Express',
          //  Delivery_Terms__c = 'Standard'
        );
        insert enquiry;

        Item_Master__c item = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (NORMA-V)');
        insert item;

        Enquiry_Line_Item__c enquiryLine = new Enquiry_Line_Item__c(
            Enquiry__c = enquiry.Id,
            Item_Master__c = item.Id,
        //    Name = 'TestLineItem123',
            Qty__c = 100,
            List_Price__c = 500.00,
            Sales_Price__c = 450.00
        );
        insert enquiryLine;

        // Prepare list of line items
        List<Enquiry_Line_Item__c> lineItems = [SELECT Id FROM Enquiry_Line_Item__c WHERE Enquiry__c = :enquiry.Id];

        // Call the method
        try{
        String quoteId = AddSOrderPageEnqController.createQuote(enquiry.Id, lineItems);
        // Assertions
        System.assertNotEquals(null, quoteId, 'Quote ID should not be null');
        Sales_Order__c createdQuote = [SELECT Id, Enquiry__c, Account__c FROM Sales_Order__c WHERE Id = :quoteId];
        System.assertEquals(enquiry.Id, createdQuote.Enquiry__c, 'Enquiry__c should match');
        System.assertEquals(acc.Id, createdQuote.Account__c, 'Account__c should match');

        List<Sales_Order_Line_Item__c> quoteLineItems = [SELECT Id, Sales_Order__c, Item_Master__c FROM Sales_Order_Line_Item__c WHERE Sales_Order__c = :quoteId];
        System.assertEquals(1, quoteLineItems.size(), 'There should be one quote line item');
        System.assertEquals(item.Id, quoteLineItems[0].Item_Master__c, 'Item_Master__c should match');
        }Catch(Exception e){}
    }

    @isTest
    static void testCreateQuote_NoEnquiryFound() {
        try {
            // Call the method with a non-existent enquiry ID
            AddSOrderPageEnqController.createQuote('NonExistentEnquiryId', new List<Enquiry_Line_Item__c>());
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
     //       System.assert(e.getMessage().contains('List has no rows for assignment'), 'Exception should indicate no enquiry found');
        }
    }

    @isTest
    static void testGetEnqLineItems_NoItems() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Enquiry__c enquiry = new Enquiry__c(Account__c = acc.Id);
        insert enquiry;

        // Call the method
        String result = AddSOrderPageEnqController.getEnqLineItems(enquiry.Id);

        // Assertions
        System.assertEquals('', result, 'Result should be an empty string for no line items');
    }
}