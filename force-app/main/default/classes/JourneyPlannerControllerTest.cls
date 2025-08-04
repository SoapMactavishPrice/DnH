@isTest
public class JourneyPlannerControllerTest {

    @isTest
    static void testGenerateEvent() {
        State__c state1 = new State__c(Name = 'MAHATEST');
        insert state1;
        
        Lead lead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'jane.doe+' + System.currentTimeMillis() + '@test.com',
            MobilePhone = '0987654321',
            Website = 'www.janexample.com',
            IsCreatedFromCustomLead__c = false,
            Zip_Code__c = '560001',
            Salutation = 'Dr.',
            NumberOfEmployees = 30,
            state__c = state1.Id
        );
        insert lead;

        
        Lead__c cLead = new Lead__c(
            Name = 'Jane',
            Mobile_Number__c = lead.MobilePhone,
            Website__c = lead.Website,
            Company_Name__c = lead.Company,
            IsCreatedFromStandardLead__c = true,
            state__c = state1.Id
        );
        insert cLead;
        
        Account acc = new Account(Name = 'ABC', BillingCity = 'Thane');
        insert acc;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        Map<String, Object> entityDataMap = new Map<String, Object>();
        entityDataMap.put('Id', acc.Id);
        entityDataMap.put('City__c', acc.BillingCity);

        Map<String, Object> selectedDateMap = new Map<String, Object>();
        selectedDateMap.put('year', 2024);
        selectedDateMap.put('month', 11);
        selectedDateMap.put('day', 15);

        String entityData = JSON.serialize(entityDataMap);
        String selectedDate = JSON.serialize(selectedDateMap);

        Test.startTest();
        JourneyPlannerController.generateEvent(entityData, selectedDate);
        Test.stopTest();
    }
    
        @isTest
    static void testGetRoutePlanner() {
        
        Route_Planner__c rp1 = new Route_Planner__c(Name = 'Navi Mumbai', Is_Active__c = true);
        Route_Planner__c rp2 = new Route_Planner__c(Name = 'Kalyan', Is_Active__c = true);
        insert new List<Route_Planner__c>{rp1, rp2};
        
        Test.startTest();
        
    
        String result = JourneyPlannerController.getRoutePlanner();
        
        Test.stopTest();

        
        System.debug('Result from getRoutePlanner: ' + result);
    }

    @isTest
    static void testGetPicklistValues() {
        
        String objectName = 'Account'; 
        String fieldName = 'Industry'; 
        
        Test.startTest();
        List<String> picklistValues = JourneyPlannerController.getPicklistValues(objectName, fieldName);
        Test.stopTest();
    }

    @isTest
    static void testGetIndustryValues() {
        
        Industry__c industry1 = new Industry__c(Name = 'CEMENT');
        Industry__c industry2 = new Industry__c(Name = 'GLASS');
        insert new List<Industry__c>{industry1, industry2};
        
        Test.startTest();
        List<Industry__c> industries = JourneyPlannerController.getIndustryValues('dummyRecordId');
        Test.stopTest();
    }

    @isTest
    static void testGetIJPRecord() {
        
        IJP__c ijp = new IJP__c(IJP_Start_Date__c = Date.today(), IJP_End_Date__c = Date.today().addMonths(1));
        insert ijp;

        Test.startTest();
        IJP__c fetchedIJP = JourneyPlannerController.getIJPRecord(ijp.Id);
        Test.stopTest();
    }

    @isTest
    static void testCheckIsInApprovalProcess() {
       
        IJP__c ijp = new IJP__c(User_Employee__c = UserInfo.getUserId(), IJP_Start_Date__c = Date.today(), Approval_Status__c = 'Submitted');
        insert ijp;
        
        Test.startTest();
        Boolean isInApprovalProcess = JourneyPlannerController.checkIsInApprovalProcess(String.valueOf(Date.today().month()), String.valueOf(Date.today().year()));
        Test.stopTest();
    }

     @isTest
    static void testGetMainPrincipal() {
        // Set up test data
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');
        insert new List<Account>{acc1, acc2};
        
        // Test the method
        Test.startTest();
        String result = JourneyPlannerController.getMainPrincipal();
        Test.stopTest();
    }

    
        @isTest
    static void testGetRecordsLead() {
        
        Industry__c industry1 = new Industry__c(Name = 'CEMENT');
        Industry__c industry2 = new Industry__c(Name = 'GLASS');
        insert new List<Industry__c>{industry1, industry2};
        
        State__c state1 = new State__c(Name = 'MAHATEST');
        insert state1;
        // Setup test data for Lead__c
        Lead__c lead = new Lead__c(Last_Name__c = 'Test Lead',Company_Name__c = 'ASB', Industry__c = industry1.Id, state__c = state1.Id);
        insert lead;

        // Test parameters
        String routePlannerId = 'someRoutePlannerId';
        String objApiName = 'Lead__c';
        String selectedStage = '';
        String selectedMainPrincipal = '';
        String cityList = '';
        String selectedindustry = 'Technology';

        Test.startTest();
        List<Object> result = JourneyPlannerController.getRecords(routePlannerId, objApiName, selectedStage, selectedMainPrincipal, cityList, selectedindustry);
        Test.stopTest();

        
    }

    @isTest
    static void testGetRecordsAccount() {
        // Setup test data for Account
        Account acc = new Account(Name = 'Test Account', BillingCity = 'Thane');
        insert acc;

        // Test parameters
        String routePlannerId = 'someRoutePlannerId';
        String objApiName = 'Account';
        String selectedStage = '';
        String selectedMainPrincipal = '';
        String cityList = 'Thane';
        String selectedindustry = '';

        Test.startTest();
        List<Object> result = JourneyPlannerController.getRecords(routePlannerId, objApiName, selectedStage, selectedMainPrincipal, cityList, selectedindustry);
        Test.stopTest();

        
    }

    @isTest
    static void testGetRecordsContact() {
        // Setup test data for Contact
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', MailingCity = 'Mumbai');
        insert con;

        // Test parameters
        String routePlannerId = 'someRoutePlannerId';
        String objApiName = 'Contact';
        String selectedStage = '';
        String selectedMainPrincipal = '';
        String cityList = 'Mumbai';
        String selectedindustry = '';

        Test.startTest();
        List<Object> result = JourneyPlannerController.getRecords(routePlannerId, objApiName, selectedStage, selectedMainPrincipal, cityList, selectedindustry);
        Test.stopTest();


    }

  /*  @isTest
    static void testGetRecordsWithSelectedStageAndPrincipal() {
        
        Account acc = new Account(Name = 'ABC', BillingCity = 'Thane');
        insert acc;

        // Test parameters
        String routePlannerId = 'someRoutePlannerId';
        String objApiName = 'Account';
        String selectedStage = 'Prospecting';
        String selectedMainPrincipal = 'Principal1';
        String cityList = '';
        String selectedindustry = '';

        Test.startTest();
        List<Object> result = JourneyPlannerController.getRecords(routePlannerId, objApiName, selectedStage, selectedMainPrincipal, cityList, selectedindustry);
        Test.stopTest();

    }		*/
    
        @isTest
    static void testGetEventsForCurrentMonth() {
        Account acc = new Account(Name = 'Test Account', BillingCity = 'Mumbai');
        insert acc;

        Event ev1 = new Event(
            Subject = 'Test Event 1', 
            ActivityDate = Date.today(), 
            OwnerId = UserInfo.getUserId(), 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1), 
            Location = 'Mumbai',
            WhatId = acc.Id
        );
        insert ev1;

        Event ev2 = new Event(
            Subject = 'Test Event 2', 
            ActivityDate = Date.today().addDays(5), 
            OwnerId = UserInfo.getUserId(), 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1), 
            Location = 'Mumbai',
            WhatId = acc.Id
        );
        insert ev2;

        IJP__c ijp = new IJP__c(
            User_Employee__c = UserInfo.getUserId(), 
            IJP_Start_Date__c = Date.today(), 
            IJP_End_Date__c = Date.today().addMonths(1)
        );
        insert ijp;

        String currentYear = String.valueOf(Date.today().year());
        String currentMonth = String.valueOf(Date.today().month());
        String ijpId = ijp.Id;

        Test.startTest();
        String result = JourneyPlannerController.getEventsForCurrentMonth(currentYear, currentMonth, ijpId);
        Test.stopTest();
    }


    
    
    @isTest
    static void testGetRecordsWithError() {
        
        try {
            JourneyPlannerController.getRecords('', '', '', '', '', '');
           
        } catch (AuraHandledException e) {
           
        }
    }

    
    @isTest
    static void testGetSingleEvent() {
        Event ev = new Event(Subject = 'Test Event', Location = 'Test Location', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1));
        insert ev;

        Test.startTest();
        JourneyPlannerController.getSingleEvent(ev.Id);
        Test.stopTest();
    }

    @isTest
    static void testUpdateEventDragDrop() {
        Event ev = new Event(Subject = 'Test Event', Location = 'Test Location', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1));
        insert ev;

        Test.startTest();
        JourneyPlannerController.updateEventDragDrop(ev.Id, '1');
        Test.stopTest();
    }

    
   @isTest
    public static void testUpdateEvent() {
        User testUser = new User(
            Alias = 't1user',
            Email = 'tesuser@example.com',
            Username = 'alex1277654321@example.co',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LastName = 'cds'
        );
        insert testUser;
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
        insert testContact;
        
        Event testEvent = new Event(
            Subject = 'Test Meeting',
            OwnerId = testUser.Id,
            WhatId = testAccount.Id,
            WhoId = testContact.Id,
            ActivityDate = Date.today(),
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(1)
        );
        insert testEvent;
        
        Map<String, Object> mapEvent = new Map<String, Object>();
        mapEvent.put('Id', testEvent.Id);
        mapEvent.put('OwnerId', testUser.Id);
        mapEvent.put('Subject', 'Updated Test Meeting');
        mapEvent.put('WhoId', testContact.Id);
        mapEvent.put('WhatId', testAccount.Id);
        mapEvent.put('Description', 'Updated Description');
        mapEvent.put('Meeting_Purpose__c', 'Travel');
        mapEvent.put('Visit_Purpose__c', 'Introduction');
        mapEvent.put('Appointment_Taken__c', 'Yes');
        mapEvent.put('StartDateTime', DateTime.now().addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss'));
        mapEvent.put('EndDateTime', DateTime.now().addDays(1).addHours(1).format('yyyy-MM-dd\'T\'HH:mm:ss'));
        mapEvent.put('ActivityDateOriginal', DateTime.newInstance(testEvent.ActivityDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd\'T\'HH:mm:ss'));
        
        List<Map<String, Object>> attendees = new List<Map<String, Object>>();
        Map<String, Object> attendee = new Map<String, Object>();
        attendee.put('Id', testContact.Id);
        attendees.add(attendee);
        mapEvent.put('Attendees', attendees);
        
        String eventData = JSON.serialize(mapEvent);
        
        Test.startTest();
        String result = JourneyPlannerController.updateEvent(eventData);
        Test.stopTest();
    }
    @isTest
    static void testDeleteEvent() {
        Event ev = new Event(Subject = 'Test Event', Location = 'Test Location', StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1));
        insert ev;

        Test.startTest();
        JourneyPlannerController.deleteEvent(ev.Id);
        Test.stopTest();
    }

  /*  @isTest
    static void testSubmitForApproval() {
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        IJP__c ijp = new IJP__c(User_Employee__c = u.Id, IJP_Start_Date__c = Date.today(), IJP_End_Date__c = Date.today().addMonths(1));
        insert ijp;

        Test.startTest();
        JourneyPlannerController.submitForApproval('2024', '12', 'Test comment');
        Test.stopTest();
    }		*/
    
        @isTest
    static void testGetStyleClassName() {

        // Test Case 1: Event_created_from_Journey_Planner__c is false
        Event ev1 = new Event(
            Subject = 'Test Event 1', 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1),
            Event_created_from_Journey_Planner__c = false
        );
        // Expect 'created-outside' when Event_created_from_Journey_Planner__c is false
        String result1 = JourneyPlannerController.getStyleClassName(ev1);
        System.assertEquals('created-outside', result1);

        // Test Case 2: Event_created_from_Journey_Planner__c is true, Approval_Status_IJP__c is null
        Event ev2 = new Event(
            Subject = 'Test Event 2', 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1),
            Event_created_from_Journey_Planner__c = true,
            Approval_Status_IJP__c = null
        );
        // Expect 'none-submitted' when Approval_Status_IJP__c is null
        String result2 = JourneyPlannerController.getStyleClassName(ev2);
        System.assertEquals('none-submitted', result2);

        // Test Case 3: Event_created_from_Journey_Planner__c is true, Approval_Status_IJP__c is ''
        Event ev3 = new Event(
            Subject = 'Test Event 3', 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1),
            Event_created_from_Journey_Planner__c = true,
            Approval_Status_IJP__c = ''
        );
        // Expect 'none-submitted' when Approval_Status_IJP__c is empty
        String result3 = JourneyPlannerController.getStyleClassName(ev3);
        System.assertEquals('none-submitted', result3);

        // Test Case 4: Event_created_from_Journey_Planner__c is true, Approval_Status_IJP__c is 'Submitted'
        Event ev4 = new Event(
            Subject = 'Test Event 4', 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1),
            Event_created_from_Journey_Planner__c = true,
            Approval_Status_IJP__c = 'Submitted'
        );
        // Expect 'none-submitted' when Approval_Status_IJP__c is 'Submitted'
        String result4 = JourneyPlannerController.getStyleClassName(ev4);
        System.assertEquals('none-submitted', result4);

        // Test Case 5: Event_created_from_Journey_Planner__c is true, Approval_Status_IJP__c is 'Approved'
        Event ev5 = new Event(
            Subject = 'Test Event 5', 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1),
            Event_created_from_Journey_Planner__c = true,
            Approval_Status_IJP__c = 'Approved'
        );
        // Expect 'approved' when Approval_Status_IJP__c is 'Approved'
        String result5 = JourneyPlannerController.getStyleClassName(ev5);
        System.assertEquals('approved', result5);

        // Test Case 6: Event_created_from_Journey_Planner__c is true, Approval_Status_IJP__c is 'Approved but updated by Manager'
        Event ev6 = new Event(
            Subject = 'Test Event 6', 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1),
            Event_created_from_Journey_Planner__c = true,
            Approval_Status_IJP__c = 'Approved but updated by Manager'
        );
        // Expect 'approved-and-edited' when Approval_Status_IJP__c is 'Approved but updated by Manager'
        String result6 = JourneyPlannerController.getStyleClassName(ev6);
        System.assertEquals('approved-and-edited', result6);

        // Test Case 7: Event_created_from_Journey_Planner__c is true, Approval_Status_IJP__c is 'Rejected'
        Event ev7 = new Event(
            Subject = 'Test Event 7', 
            StartDateTime = DateTime.now(), 
            EndDateTime = DateTime.now().addHours(1),
            Event_created_from_Journey_Planner__c = true,
            Approval_Status_IJP__c = 'Rejected'
        );
        // Expect 'rejected' when Approval_Status_IJP__c is 'Rejected'
        String result7 = JourneyPlannerController.getStyleClassName(ev7);
        System.assertEquals('rejected', result7);
    }
}