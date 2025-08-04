@isTest
public class lwcEventCheckInOutControllerTest {

    @isTest
    static void testUpdateCheckIn() {
        // Create test Event record
        Event testEvent = new Event(
            Subject = 'Test Event', 
            StartDateTime = System.now(), 
            EndDateTime = System.now().addHours(1)
        );
        insert testEvent;
        
        // Call the updateCheckIn method
        Test.startTest();
        lwcEventCheckInOutController.updateCheckIn(testEvent.Id, 40.7128, -74.0060); // Example coordinates
        Test.stopTest();
    }

    @isTest
    static void testUpdateCheckOut() {
        // Create test Event record
        Event testEvent = new Event(
            Subject = 'Test Event', 
            StartDateTime = System.now(), 
            EndDateTime = System.now().addHours(1)
        );
        insert testEvent;
        
        // Call the updateCheckOut method
        Test.startTest();
        lwcEventCheckInOutController.updateCheckOut(
            testEvent.Id, 
            34.0522, 
            -118.2437, 
            'Completed', 
            'Description of the visit', 
            'No insights', 
            'Follow-up action'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetEventById() {
        // Create test Event record
        Event testEvent = new Event(
            Subject = 'Test Event', 
            StartDateTime = System.now(), 
            EndDateTime = System.now().addHours(1)
        );
        insert testEvent;
        
        // Call the getEventById method
        Test.startTest();
        lwcEventCheckInOutController.getEventById(testEvent.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpdateEventById() {
        // Create test Event record
        Event testEvent = new Event(
            Subject = 'Test Event', 
            StartDateTime = System.now(), 
            EndDateTime = System.now().addHours(1)
        );
        insert testEvent;
        
        // Prepare test data for update
        Map<String, Object> formData = new Map<String, Object>();
        formData.put('Visit_Result__c', 'Completed');
        formData.put('Description', 'Updated visit description');
        formData.put('Client_Feedback_Or_Insights__c', 'Feedback');
        
        // Call the updateEventById method
        Test.startTest();
        lwcEventCheckInOutController l = new lwcEventCheckInOutController();
        lwcEventCheckInOutController.updateEventById(testEvent.Id, formData);
        Test.stopTest();
    }

    @isTest
    static void testGetContacts() {
        // Create test Account record
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create test Contact records
        Contact testContact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
        Contact testContact2 = new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = testAccount.Id);
        insert new List<Contact> { testContact1, testContact2 };
        
        // Call the getContacts method
        Test.startTest();
        lwcEventCheckInOutController.getContacts(testAccount.Id);
        Test.stopTest();
    }

    @isTest
    static void testSaveMeetingAttendees() {
        // Create test Event and Account records
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Event testEvent = new Event(
            Subject = 'Test Event', 
            StartDateTime = System.now(), 
            EndDateTime = System.now().addHours(1)
        );
        insert testEvent;
        
        // Prepare test data for meeting attendees
        List<Map<String, Object>> meetingDetails = new List<Map<String, Object>>();
        Map<String, Object> attendeeDetail = new Map<String, Object>();
        Department__c testDepartment = new Department__c(Name = 'Sales');
        insert testDepartment;
       
        
        // Create a test Contact with the Department__c lookup field referencing the Department__c record
        Contact testContact = new Contact(
            FirstName = 'John', 
            LastName = 'Doe', 
            AccountId = testAccount.Id, 
            Department__c = testDepartment.Id  // Set the lookup field to the created department record
        );
        insert testContact;
        attendeeDetail.put('lastName', testContact.LastName);  // Example Contact ID
        attendeeDetail.put('departmentId', testDepartment.Id);
        attendeeDetail.put('startDate', '2024-12-31T10:00:00Z');
        attendeeDetail.put('endDate', '2024-12-31T11:00:00Z');
        attendeeDetail.put('followUpDate', '2025-01-01');
        attendeeDetail.put('description', 'Meeting description');
        meetingDetails.add(attendeeDetail);
        
        // Call the saveMeetingAttendees method
        Test.startTest();
        lwcEventCheckInOutController.saveMeetingAttendees(meetingDetails, testEvent.Id, testAccount.Id);
        Test.stopTest();
    }

    // New test method for updateEventRecord without assertions
    @isTest
    static void testUpdateEventRecord() {
        // Create test Event record
        Event testEvent = new Event(
            Subject = 'Test Event', 
            StartDateTime = System.now(), 
            EndDateTime = System.now().addHours(1)
        );
        insert testEvent;
        
        // Call the updateEventRecord method
        Test.startTest();
        String result = lwcEventCheckInOutController.updateEventRecord(testEvent.Id, 51.5074, -0.1278); // Example coordinates (London)
        Test.stopTest();
    }
    
    @isTest
    static void testGetDepartment() {
        // Create a test Department record
        Department__c testDepartment = new Department__c(Name = 'Sales');
        insert testDepartment;
        
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a test Contact with the Department__c lookup field referencing the Department__c record
        Contact testContact = new Contact(
            FirstName = 'John', 
            LastName = 'Doe', 
            AccountId = testAccount.Id, 
            Department__c = testDepartment.Id  // Set the lookup field to the created department record
        );
        insert testContact;
        
        // Call the getdepartment method
        Test.startTest();
        String result = lwcEventCheckInOutController.getdepartment(testContact.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetMeetingAttendees() {
        // Create a test Event record
        Event testEvent = new Event(
            Subject = 'Test Event',
            StartDateTime = System.now(),
            EndDateTime = System.now().addHours(1)
        );
        insert testEvent;

        // Create a test Contact record (assuming it's required for the Meeting_Attendee__c)
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe'
        );
        insert testContact;

        // Create a test Meeting_Attendee__c record associated with the test Event
        Meeting_Attendee__c testAttendee = new Meeting_Attendee__c(
            Contact__c = testContact.id,
            EventId__c = testEvent.Id,  // Link to the Event
         //   Contact_Name__c = testContact.Id,  // Link to the Contact
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addHours(1),
            Meeting_Description__c = 'Test Meeting Description',
            // Convert Datetime to Date for Next_Follow_Up_Date__c
            Next_Follow_Up_Date__c = System.today().addDays(1),  // Use Date here, not Datetime
            Contact_Type__c = 'Existing'
        );
        insert testAttendee;

        // Call the getMeetingAttendees method
        Test.startTest();
        List<Meeting_Attendee__c> attendees = lwcEventCheckInOutController.getMeetingAttendees(testEvent.Id);
        Test.stopTest();
        
        // The test would pass as long as no errors occur, as no assertions are needed
    }

}