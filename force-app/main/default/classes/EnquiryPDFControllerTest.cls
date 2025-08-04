@isTest
public class EnquiryPDFControllerTest {

    @isTest
    public static void testConstructor() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        // Create an Enquiry__c record
        Enquiry__c enq = new Enquiry__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Enquiry_Type__c='Direct Sales Domestic',
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0
        );
        insert enq;
        
        // Set up the test context
        Test.startTest();
        
        // Initialize the controller with a valid Enquiry ID
        ApexPages.currentPage().getParameters().put('id', enq.Id);
        EnquiryPDFController controller = new EnquiryPDFController();
        
        // Verify that the enquiry data is retrieved correctly
        System.assertEquals(controller.enqId, enq.Id);
        System.assertNotEquals(controller.enqData, null);
    //    System.assertEquals(controller.isValid, true);
        
        Test.stopTest();
    }

    @isTest
    public static void testSave() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        // Create an Enquiry__c record
        Enquiry__c enq = new Enquiry__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Enquiry_Type__c='Direct Sales Domestic',
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0
        );
        insert enq;        
        
        // Set up the test context
        Test.startTest();
        
        // Initialize the controller with a valid Enquiry ID
        ApexPages.currentPage().getParameters().put('id', enq.Id);
        EnquiryPDFController controller = new EnquiryPDFController();
        
        // Set Sales Type
        controller.Salestype = 'Test Type';
        
        // Call save method
        PageReference result = controller.save();
        
        // Verify the result
        System.assertNotEquals(result, null);
        System.assert(result.getUrl().contains(enq.Id));
        
        Test.stopTest();
    }

    @isTest
    public static void testSaveAndSend() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        // Create an Enquiry__c record
        Enquiry__c enq = new Enquiry__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Enquiry_Type__c='Direct Sales Domestic',
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0
        );
        insert enq;
        
        // Set up the test context
        Test.startTest();
        
        // Initialize the controller with a valid Enquiry ID
        ApexPages.currentPage().getParameters().put('id', enq.Id);
        EnquiryPDFController controller = new EnquiryPDFController();
        
        // Set Sales Type and other parameters
        controller.Salestype = 'Test Type';
        controller.emailId = 'test@example.com';
        controller.subject = 'Test Subject';
        
        // Call saveAndSend method
        PageReference result = controller.saveAndSend();
        
        // Verify the result
        System.assertNotEquals(result, null);
        System.assert(result.getUrl().contains(enq.Id));
        
        // Verify the email was sent (can mock email sending to verify)
   //     List<Messaging.SingleEmailMessage> emails = Test.getEmailMessages();
   //     System.assertEquals(emails.size(), 1);
   //     System.assertEquals(emails[0].getToAddresses()[0], 'test@example.com');
        
        Test.stopTest();
    }

    @isTest
    public static void testCancel() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        // Create an Enquiry__c record
        Enquiry__c enq = new Enquiry__c(
            Account__c = acc.Id,
            Contact__c = con.Id,
            Enquiry_Type__c='Direct Sales Domestic',
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0
        );
        insert enq;
        
        // Set up the test context
        Test.startTest();
        
        // Initialize the controller with a valid Enquiry ID
        ApexPages.currentPage().getParameters().put('id', enq.Id);
        EnquiryPDFController controller = new EnquiryPDFController();
        
        // Call cancel method
        PageReference result = controller.cancel();
        
        // Verify the result
        System.assertNotEquals(result, null);
        System.assert(result.getUrl().contains(enq.Id));
        
        Test.stopTest();
    }
}