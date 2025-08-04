@isTest
public class CustomLeadConvertControllerTest {

    @isTest
    static void testConvertLead() {
        Lead__c lead = new Lead__c(
            Last_Name__c = 'LeadLastName',
            Company_Name__c = 'Test Company',
            Email__c = 'test@example.com',
            Is_Converted__c = false
        );
        insert lead;

        String accName = 'Test Account';
        Map<String, String> contactName = new Map<String, String>{
            'Salutation' => 'Mr.',
            'FirstName' => 'John',
            'MiddleName' => 'A',
            'LastName' => 'Doe'
        };
            
            Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
            
            RecordType rectype = [SELECT Id, Name FROM RecordType WHERE Name = 'Normal Enquiry'];

        Map<String, String> result = CustomLeadConvertController.convertLead(
            lead, accName, false, acc.Id, 'AccountRecordType', null, contactName, null, 'Test Enquiry',rectype.Id, false, true, true
        );

    }

    @isTest
    static void testConvertLeadWithExistingContact() {
        Lead__c lead = new Lead__c(
            Last_Name__c = 'LeadLastName',
            Company_Name__c = 'Test Company',
            Email__c = 'test@example.com',
            Is_Converted__c = false
        );
        insert lead;

        Contact existingContact = new Contact(
            LastName = 'Doe',
            AccountId = null,
            Email = 'existing@example.com',
            Phone = '1234567890',
            MobilePhone = '0987654321',
            Title = null,
            Salutation = null,
            FirstName = null,
            MiddleName = null
        );
        insert existingContact;

        String accName = 'Test Account';
        Map<String, String> contactName = new Map<String, String>{
            'Salutation' => 'Mr.',
            'FirstName' => 'John',
            'MiddleName' => 'A',
            'LastName' => 'Doe'
        };
            
             Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
            
/*
        Map<String, String> result = CustomLeadConvertController.convertLead(
            lead, accName, null, null, contactName, existingContact.Id, 'Test Enquiry', null, false, true, true
        );
*/
            RecordType rectype = [SELECT Id, Name FROM RecordType WHERE Name = 'Normal Enquiry'];
            
            
            Map<String, String> result = CustomLeadConvertController.convertLead(
    lead,                         // Lead__c leadRecord
    accName,                      // String accName
    false,                         // Boolean isDC
    acc.Id,                         // String dealerName
    null,          // String accRT (Provide a valid Account record type or null)
    existingContact.AccountId,    // String existingAccId (Use AccountId of the existing contact)
    contactName,                  // Map<String, String> contactName
    null,                         // String existingContId (Contact ID or null)
    rectype.Id,               // String enqName
    null,          // String enqRT (Enquiry Record Type or null)
    false,                        // Boolean enqChk
    true,                         // Boolean isAccountNew
    true                          // Boolean isContactNew
);

        Contact convertedContact = [SELECT Id, AccountId, Salutation, FirstName, MiddleName, LastName, Title, Phone, MobilePhone, Email FROM Contact WHERE Id = :existingContact.Id];
    }

    @isTest
    static void testConvertLeadWithTasksAndEmails() {
        Lead__c lead = new Lead__c(
            Last_Name__c = 'LeadLastName',
            Company_Name__c = 'Test Company',
            Email__c = 'test@example.com',
            Is_Converted__c = false
        );
        insert lead;

        Task task1 = new Task(
            WhatId = lead.Id,
            Status = 'Not Started',
            Subject = 'Follow Up',
            ActivityDate = Date.today(),
            Description = 'Follow up on lead',
            WhoId = null,
            Priority = 'Normal',
            OwnerId = UserInfo.getUserId(),
            ReminderDateTime = DateTime.now(),
            IsReminderSet = true
        );
        insert task1;

        EmailMessage email = new EmailMessage(
            Subject = 'Initial Contact',
            TextBody = 'This is a test email body.',
            FromAddress = 'sender@example.com',
            ToAddress = 'recipient@example.com',
            RelatedToId = lead.Id
        );
        insert email;

        String accName = 'Test Account';
        Map<String, String> contactName = new Map<String, String>{
            'Salutation' => 'Mr.',
            'FirstName' => 'John',
            'MiddleName' => 'A',
            'LastName' => 'Doe'
        };
            
            Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
            
            
             RecordType rectype = [SELECT Id, Name FROM RecordType WHERE Name = 'Normal Enquiry'];
/*
        Map<String, String> result = CustomLeadConvertController.convertLead(
            lead, accName, null, null, contactName, null, 'Test Enquiry', null, false, true, true
        );
*/
            Map<String, String> result = CustomLeadConvertController.convertLead(
    lead,                         // Lead__c leadRecord
    accName,                      // String accName
    false,                         // Boolean isDC
    acc.Id,                         // String dealerName
    'AccountRecordType',          // String accRT (Provide valid record type or null)
    null,                         // String existingAccId (Account ID or null)
    contactName,                  // Map<String, String> contactName
    null,                         // String existingContId (Contact ID or null)
    'Test Enquiry',               // String enqName
    rectype.Id,          // String enqRT (Enquiry Record Type or null)
    false,                        // Boolean enqChk
    true,                         // Boolean isAccountNew
    true                          // Boolean isContactNew
);


        List<Task> copiedTasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :result.get('accountId')];
        List<EmailMessage> copiedEmails = [SELECT Id, RelatedToId FROM EmailMessage WHERE RelatedToId = :result.get('accountId')];
    }

    @isTest
    static void testConvertLeadWithAttachments() {
        Lead__c lead = new Lead__c(
            Last_Name__c = 'LeadLastName',
            Company_Name__c = 'Test Company',
            Email__c = 'test@example.com',
            Is_Converted__c = false
        );
        insert lead;

        Event event1 = new Event(
            WhatId = lead.Id,
            Subject = 'Follow Up Meeting',
            ActivityDate = Date.today(),
            Description = 'Follow up with lead.',
            WhoId = null,
            OwnerId = UserInfo.getUserId(),
            ReminderDateTime = DateTime.now(),
            IsReminderSet = true,
            EndDateTime = DateTime.now().addHours(1),
            StartDateTime = DateTime.now()
        );
        insert event1;

       
        Attachment attach = new Attachment(
            Name = 'Test Attachment',
            Body = Blob.valueOf('This is a test attachment body.'),
            ContentType = 'text/plain',
            ParentId = event1.Id,
            IsPrivate = false
        );
        insert attach;

        String accName = 'Test Account';
        Map<String, String> contactName = new Map<String, String>{
            'Salutation' => 'Mr.',
            'FirstName' => 'John',
            'MiddleName' => 'A',
            'LastName' => 'Doe'
        };
            
             Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
            
            
             RecordType rectype = [SELECT Id, Name FROM RecordType WHERE Name = 'Normal Enquiry'];
/*
        Map<String, String> result = CustomLeadConvertController.convertLead(
            lead, accName, null, null, contactName, null, 'Test Enquiry', null, false, true, true
        );
*/
            Map<String, String> result = CustomLeadConvertController.convertLead(
    lead,                         // Lead__c leadRecord
    accName,                      // String accName
    false,                         // Boolean isDC
    acc.Id,                         // String dealerName
    null,                         // String accRT (if not required, use null)
    null,                         // String existingAccId (if not required, use null)
    contactName,                  // Map<String, String> contactName
    null,                         // String existingContId (if not required, use null)
    rectype.Id,               // String enqName
    null,                         // String enqRT (if not required, use null)
    false,                        // Boolean enqChk
    true,                         // Boolean isAccountNew
    true                          // Boolean isContactNew
);

     
        List<Attachment> copiedAttachments = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :result.get('accountId')];
       
    }

    @isTest
    static void testGetLeadRecord() {
        Lead__c lead = new Lead__c(
            Last_Name__c = 'LeadLastName',
            Company_Name__c = 'Test Company',
            Email__c = 'test@example.com',
            Is_Converted__c = false
        );
        insert lead;

        Lead__c resultLead = CustomLeadConvertController.getLeadRecord(lead.Id);
    }

    @isTest
    static void testGetAccRecTypes() {
        List<Object> result = CustomLeadConvertController.getAccRecTypes();
    }

    @isTest
    static void testGetEnquiryRecordTypes() {
        List<RecordType> result = CustomLeadConvertController.getEnquiryRecordTypes();
    }

    @isTest
    static void testExceptionHandling() {
        Lead__c lead = new Lead__c(
            Last_Name__c = 'LeadLastName',
            Company_Name__c = 'Test Company',
            Email__c = 'test@example.com',
            Is_Converted__c = false
        );
        insert lead;
        
         Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
            
        
        RecordType rectype = [SELECT Id, Name FROM RecordType WHERE Name = 'Normal Enquiry'];

        Test.startTest();
        try {
          //  CustomLeadConvertController.convertLead(lead, null, null, null, null, null, null, null, false, true, true);
          Map<String, String> result = CustomLeadConvertController.convertLead(
    lead,                         // Lead__c leadRecord
    null,                         // String accName
    false,                         // Boolean isDC
    acc.Id,                         // String dealerName
    null,                         // String accRT
    null,                         // String existingAccId
    null,                         // Map<String, String> contactName
    null,                         // String existingContId
    null,                         // String enqName
    rectype.Id,                         // String enqRT
    false,                        // Boolean enqChk
    true,                         // Boolean isAccountNew
    true                          // Boolean isContactNew
);

        } catch (AuraHandledException e) {
            
        }
        Test.stopTest();
    }
}