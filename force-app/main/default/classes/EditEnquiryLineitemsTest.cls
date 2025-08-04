@isTest
public class EditEnquiryLineitemsTest {
    @isTest
    static void testGetEnquiryLineItems() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item Master');
        insert itemMaster;

        Enquiry__c enquiry = new Enquiry__c(Account__c = acc.Id);
        insert enquiry;

        Enquiry_Line_Item__c item = new Enquiry_Line_Item__c(
            Enquiry__c = enquiry.Id,
            Item_No__c = 'Item 1',
            Item_Master__c = itemMaster.Id,
            Qty__c = 10,
            Sales_Price__c = 100,
            Status__c = 'Close Won'
        );
        insert item;

        // Test the getEnquiryLineItems method
        Test.startTest();
        List<Enquiry_Line_Item__c> items = EditEnquiryLineitems.getEnquiryLineItems(enquiry.Id);
        Test.stopTest();

        System.assertNotEquals(null, items);
        System.assertEquals(1, items.size());
        System.assertEquals('Item 1', items[0].Item_No__c);
    }

    @isTest
    static void testGetStatusPicklistOptions() {
        // Test the getStatusPicklistOptions method
        Test.startTest();
        List<EditEnquiryLineitems.PicklistValue> options = EditEnquiryLineitems.getStatusPicklistOptions();
        Test.stopTest();

        System.assertNotEquals(null, options);
        System.assert(options.size() > 0);
    }

    @isTest
    static void testGetLostReasonPicklistOptions() {
        // Test the getLostReasonPicklistOptions method
        Test.startTest();
        List<EditEnquiryLineitems.PicklistValue> options = EditEnquiryLineitems.getLostReasonPicklistOptions();
        Test.stopTest();

        System.assertNotEquals(null, options);
        System.assert(options.size() > 0);
    }

    @isTest
    static void testGetComprtitormaster() {
        // Create test data
        Competitor__c competitor = new Competitor__c(Name = 'Test Competitor');
        insert competitor;

        // Test the getComprtitormaster method
        Test.startTest();
        List<EditEnquiryLineitems.PicklistValue> competitors = EditEnquiryLineitems.getComprtitormaster();
        Test.stopTest();

        System.assertNotEquals(null, competitors);
        System.assertEquals(1, competitors.size());
        System.assertEquals('Test Competitor', competitors[0].label);
    }

    @isTest
    static void testSaveProducts() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Enquiry__c enquiry = new Enquiry__c(Account__c = acc.Id);
        insert enquiry;

        Enquiry_Line_Item__c item = new Enquiry_Line_Item__c(
            Enquiry__c = enquiry.Id,
            Item_No__c = 'Item 1',
            Qty__c = 10,
            Sales_Price__c = 100
            //Status__c = 'Closed'
        );
        insert item;

        // Create JSON string for product data
        String recordData = '[{"Id":"' + item.Id + '","Status_c":"Close Won","Qty_c":20,"Competitor_c":null,"Competitor_Product_c":null,"Sales_Price_c":150,"Reason_for_lost_enquiry_c":null}]';

        // Test the saveProducts method
        Test.startTest();
        String result = EditEnquiryLineitems.saveProducts(recordData, enquiry.Id);
        Test.stopTest();

        System.assertEquals('success', result);

        // Verify the updates
        item = [SELECT Status__c, Qty__c, Sales_Price__c FROM Enquiry_Line_Item__c WHERE Id = :item.Id];
        System.assertEquals('Close Won', item.Status__c);
        System.assertEquals(20, item.Qty__c);
        System.assertEquals(150, item.Sales_Price__c);
    }
}