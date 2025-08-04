@IsTest
public class AddQuotePageEnqControllerTest {
    @TestSetup
    static void setup() {
        // Create an Account and Contact
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        // Create an Enquiry__c record
        Enquiry__c enq = new Enquiry__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0
        );
        insert enq;

        // Create Item Master
        Item_Master__c item1 = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (NORMA-V)');
        Item_Master__c item2 = new Item_Master__c(Name = 'Product 2', Item_Category__c = '6013 (NORMA-V)');
        insert new List<Item_Master__c>{item1, item2};

        // Create Enquiry_Line_Item__c records
        List<Enquiry_Line_Item__c> enquiryLineItems = new List<Enquiry_Line_Item__c> {
            new Enquiry_Line_Item__c(
                Enquiry__c = enq.Id,
                Qty__c = 10,
                List_Price__c = 100,
                Product_Family__c = 'FGM04',
                Item_Master__c = item1.Id
            ),
            new Enquiry_Line_Item__c(
                Enquiry__c = enq.Id,
                Qty__c = 20,
                List_Price__c = 200,
                Product_Family__c = 'FGM04',
                Item_Master__c = item2.Id
            )
        };
        insert enquiryLineItems;

        // Create Quote__c
        Quote__c quote = new Quote__c(
            Enquiry__c = enq.Id,
            Account__c = acc.Id,
            Contact__c = con.Id
        );
        insert quote;

        // Create a Quote_Line_Item__c for one Enquiry_Line_Item__c
        Quote_Line_Item__c quoteLineItem = new Quote_Line_Item__c(
            Quote__c = quote.Id,
            Item_Master__c = item1.Id
        );
        insert quoteLineItem;
    }

    @IsTest
    static void testCreateQuote() {
        // Fetch Enquiry__c Id and prepare EnquiryLineItemWrapper list for testing
        Id enquiryId = [SELECT Id FROM Enquiry__c LIMIT 1].Id;

        // Fetch Enquiry Line Items dynamically
        List<Enquiry_Line_Item__c> enquiryLineItems = [SELECT Id, Item_Master__c, Qty__c, List_Price__c, Sales_Price__c, Product_Family__c FROM Enquiry_Line_Item__c WHERE Enquiry__c = :enquiryId];

        // Initialize the line items dynamically (without using constructor)
        List<AddQuotePageEnqController.EnquiryLineItemWrapper> lineItems = new List<AddQuotePageEnqController.EnquiryLineItemWrapper>();

        for (Enquiry_Line_Item__c item : enquiryLineItems) {
            AddQuotePageEnqController.EnquiryLineItemWrapper lineItem = new AddQuotePageEnqController.EnquiryLineItemWrapper();
            lineItem.Id = item.Id;
            lineItem.itemMaster = item.Item_Master__c;
            lineItem.qty = item.Qty__c;
            lineItem.listPrice = item.List_Price__c;
            lineItem.salesPrice = item.Sales_Price__c;  // Assuming Sales_Price__c exists on Enquiry_Line_Item__c
            lineItem.description = item.Product_Family__c;  // Assuming Product_Family__c is used for description
            lineItem.isSelected = true;  // Example condition, adjust as necessary
            lineItem.isDisabled = false;  // Example condition, adjust as necessary

            lineItems.add(lineItem);
        }

        // Invoke the createQuote method
        Test.startTest();
        String quoteId = AddQuotePageEnqController.createQuote(enquiryId, lineItems);
        Test.stopTest();

        // Verify the Quote__c was created
        System.assertNotEquals(null, quoteId, 'Quote should be created');
        Quote__c createdQuote = [SELECT Id, Enquiry__c, Account__c FROM Quote__c WHERE Id = :quoteId];
        System.assertEquals(enquiryId, createdQuote.Enquiry__c, 'Enquiry__c should match');
        
        // Verify Quote_Line_Item__c records
        List<Quote_Line_Item__c> createdQuoteLines = [SELECT Id, Quote__c, Item_Master__c, Quantity__c, List_Price__c, Sales_Price__c FROM Quote_Line_Item__c WHERE Quote__c = :quoteId];
        System.assertEquals(enquiryLineItems.size(), createdQuoteLines.size(), 'There should be the same number of Quote_Line_Item__c records as Enquiry Line Items');
        
        // Verify first line item data
        Quote_Line_Item__c firstLineItem = createdQuoteLines[0];
        System.assertEquals(enquiryLineItems[0].Item_Master__c, firstLineItem.Item_Master__c, 'First item should match');
        System.assertEquals(enquiryLineItems[0].Qty__c, firstLineItem.Quantity__c, 'Quantity should match');
        System.assertEquals(enquiryLineItems[0].List_Price__c, firstLineItem.List_Price__c, 'List price should match');
        System.assertEquals(enquiryLineItems[0].Sales_Price__c, firstLineItem.Sales_Price__c, 'Sales price should match');
    }

    @IsTest
    static void testGetEnqLineItems() {
        // Fetch test Enquiry__c Id
        Id enquiryId = [SELECT Id FROM Enquiry__c LIMIT 1].Id;

        // Invoke getEnqLineItems
        String result = AddQuotePageEnqController.getEnqLineItems(enquiryId);
        System.debug('Result from getEnqLineItems: ' + result);
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assert(result != '', 'Result should not be empty.');

        // Deserialize the result to verify its contents
        AddQuotePageEnqController.WrapperClass resultWrapper = 
            (AddQuotePageEnqController.WrapperClass) JSON.deserialize(result, AddQuotePageEnqController.WrapperClass.class);

        System.assert(resultWrapper.enquiryLineItemList.size() > 0, 'There should be enquiry line items.');
     //   System.assert(resultWrapper.enquiryLineItemList[0].isDisabled == true, 'First item should be disabled.');
      //  System.assert(resultWrapper.enquiryLineItemList[1].isDisabled == false, 'Second item should not be disabled.');
    }
}



/*@IsTest
public class AddQuotePageEnqControllerTest {
    @TestSetup
    static void setup() {
        // Create an Account and Contact
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        // Create an Enquiry__c record
        Enquiry__c enq = new Enquiry__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0
        );
        insert enq;

        // Create Item Master
        Item_Master__c item1 = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (NORMA-V)');
        Item_Master__c item2 = new Item_Master__c(Name = 'Product 2', Item_Category__c = '6013 (NORMA-V)');
        insert new List<Item_Master__c>{item1, item2};

        // Create Enquiry_Line_Item__c records
        List<Enquiry_Line_Item__c> enquiryLineItems = new List<Enquiry_Line_Item__c>{
            new Enquiry_Line_Item__c(
                Enquiry__c = enq.Id,
                Qty__c = 10,
                List_Price__c = 100,
                Product_Family__c = 'Sample Product',
                Item_Master__c = item1.Id
            ),
            new Enquiry_Line_Item__c(
                Enquiry__c = enq.Id,
                Qty__c = 20,
                List_Price__c = 200,
                Product_Family__c = 'Sample Product',
                Item_Master__c = item2.Id
            )
        };
        insert enquiryLineItems;

        // Create Quote__c
        Quote__c quote = new Quote__c(
            Enquiry__c = enq.Id,
            Account__c = acc.Id,
            Contact__c = con.Id
        );
        insert quote;

        // Create a Quote_Line_Item__c for one Enquiry_Line_Item__c
        Quote_Line_Item__c quoteLineItem = new Quote_Line_Item__c(
            Quote__c = quote.Id,
            Item_Master__c = item1.Id
        );
        insert quoteLineItem;
    }

    @IsTest
    static void testGetEnqLineItems() {
        // Fetch test Enquiry__c Id
        Id enquiryId = [SELECT Id FROM Enquiry__c LIMIT 1].Id;

        // Invoke getEnqLineItems
        String result = AddQuotePageEnqController.getEnqLineItems(enquiryId);
        System.debug('Result from getEnqLineItems: ' + result);
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assert(result != '', 'Result should not be empty.');

        // Deserialize the result to verify its contents
        AddQuotePageEnqController.WrapperClass resultWrapper = 
            (AddQuotePageEnqController.WrapperClass) JSON.deserialize(result, AddQuotePageEnqController.WrapperClass.class);

        System.assert(resultWrapper.enquiryLineItemList.size() > 0, 'There should be enquiry line items.');
     //   System.assert(resultWrapper.enquiryLineItemList[0].isDisabled == true, 'First item should be disabled.');
      //  System.assert(resultWrapper.enquiryLineItemList[1].isDisabled == false, 'Second item should not be disabled.');
    }
}
*/