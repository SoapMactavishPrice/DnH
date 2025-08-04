@isTest
public class EnquiryTaxInvoiceTest {

    @isTest
    static void testEnquiryTaxInvoice() {
        // Step 1: Create test data (Enquiry, Enquiry_Line_Item__c, Account, and Contact)
        
        // Create Account and Contact
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;
        
        Item_Master__c itemMaster = new Item_Master__c(Name = 'Test Item', Product_Code__c = '12345');
        insert itemMaster;
        
        
        Contact contact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            MobilePhone = '123-456-7890',
            AccountId = account.Id
        );
        insert contact;
        
          // Create test data for Enquiry__c
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' LIMIT 1];
        Enquiry__c enquiry = new Enquiry__c(
           // Name = 'Test Enquiry',
            RecordTypeId = recordType.Id,
            Account__c= account.id,
            Contact__c = contact.Id
            
        );
        insert enquiry;
        
       


        Enquiry_Line_Item__c enquiryLineItem1 = new Enquiry_Line_Item__c(
            Enquiry__c = enquiry.Id,
            Item_Master__c = itemMaster.Id,
            Item_No__c = 'Item 1',
            Qty__c = 10,
            Sales_Price__c = 100
            //Status__c = 'Closed'
        );
        insert enquiryLineItem1;
        
        
        
        
            Enquiry_Line_Item__c enquiryLineItem2 = new Enquiry_Line_Item__c(
            Enquiry__c = enquiry.Id,
            Item_Master__c = itemMaster.Id,
            Item_No__c = 'Item 1',
            Qty__c = 10,
            Sales_Price__c = 100
            //Status__c = 'Closed'
        );
        insert enquiryLineItem2;
        
        
       
        
      //  insert new List<Enquiry_Line_Item__c>{enquiryLineItem1, enquiryLineItem2};
        
        // Step 2: Set the test parameter for enquiryId (Simulating a page with this parameter)
        Test.startTest();
        ApexPages.currentPage().getParameters().put('enquiryId', enquiry.Id);
        
        // Step 3: Instantiate EnquiryTaxInvoice class
        EnquiryTaxInvoice enquiryTaxInvoice = new EnquiryTaxInvoice();
        
        // Step 4: Assertions to verify the behavior
        
        // Verify that enquiryLineItems are correctly populated
        System.assertNotEquals(null, enquiryTaxInvoice.enquiryLineItems, 'Enquiry Line Items should not be null');
        System.assertEquals(2, enquiryTaxInvoice.enquiryLineItems.size(), 'There should be 2 Enquiry Line Items');
        
        // Verify that the formattedDate is correct
        Date today = System.today();
        String day = String.valueOf(today.day());
        String month = String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String expectedFormattedDate = day + '-' + month + '-' + year;
        
        System.assertEquals(expectedFormattedDate, enquiryTaxInvoice.formattedDate, 'The formatted date should be correct');
        
        // Verify that the EnquiryId is correctly set
        System.assertEquals(enquiry.Id, enquiryTaxInvoice.enquiryId, 'The enquiryId should match the page parameter');
        
        Test.stopTest();
    }
}