@isTest
public class RoutePlannerControllerTest {

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetStateList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Setup test data with valid state
        Account acc = new Account(Name='Test Account', BillingState='Maharashtra', OwnerId=UserInfo.getUserId());
        insert acc;

        // Test with accessAllRecords = 'false'
        Test.startTest();
        String result = RoutePlannerController.getStateList('false', 'Account');
        Test.stopTest();

        // Validate results
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetCityList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Setup test data with valid state and city
        Account acc = new Account(Name='Test Account', BillingState='Maharashtra', BillingCity='Pune', OwnerId=UserInfo.getUserId());
        insert acc;

        // Test with accessAllRecords = 'false'
        Test.startTest();
        String result = RoutePlannerController.getCityList('false', 'Account', 'Maharashtra');
        Test.stopTest();

        // Validate results
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetEntityRecords() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Setup test data with valid state and city
        Account acc = new Account(Name='Test Account', BillingState='Maharashtra', BillingCity='Pune', OwnerId=UserInfo.getUserId());
        insert acc;

        // Test retrieving Account records
        Test.startTest();
        List<Object> result = (List<Object>) RoutePlannerController.getEntityRecords(acc.Id, 'false', 'Account', 'Maharashtra', 'Pune', null);
        Test.stopTest();

        // Validate results
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testUpdateEntities() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create a Route Planner record
        Route_Planner__c routePlanner = new Route_Planner__c(Name='Test Route Planner');
        insert routePlanner;
        
        // Setup test data for Account and Lead
        Account acc = new Account(Name='Test Account', BillingState='Maharashtra', BillingCity='Pune', OwnerId=UserInfo.getUserId());
        insert acc;
        
        Lead__c lead = new Lead__c(Name='Test Lead', Company_Name__c='Test Company', Last_Name__c='zxc', OwnerId=UserInfo.getUserId());
        insert lead;
        
        // Create Route Planner Junction records
        Route_Planner_Junction__c rpj1 = new Route_Planner_Junction__c(Route_Planner__c=routePlanner.Id, Account__c=acc.Id);
        Route_Planner_Junction__c rpj2 = new Route_Planner_Junction__c(Route_Planner__c=routePlanner.Id, Lead__c=lead.Id);
        insert new List<Route_Planner_Junction__c>{rpj1, rpj2};
        
        // Prepare selected and not selected rows for the update
        String selectedRows = '[\"' + acc.Id + '\"]';
        String notSelectedRows = '[\"' + lead.Id + '\"]';
        
        Test.startTest();
        String result = RoutePlannerController.updateEntities('Account', routePlanner.Id, selectedRows, notSelectedRows);
        Test.stopTest();
        
        // Validate results
        System.assertEquals('', result);
    }

    @isTest
    static void testExceptionHandling() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        try {
            // Trigger an exception
            RoutePlannerController.getStateList(null, null);
            System.assert(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage() != null);
        }
    }

    @isTest
    static void testGetCityListForAccount() {
        // Create test data
        Account acc = new Account(Name = 'Test Account', BillingState = 'Test State', BillingCity = 'Test City', OwnerId = UserInfo.getUserId());
        insert acc;

        Test.startTest();
        String result = RoutePlannerController.getCityList('false', 'Account', 'Test State');
        Test.stopTest();
    }

    @isTest
    static void testGetCityListForContact() {
        // Create test data
        Contact con = new Contact(LastName = 'Test Contact', MailingState = 'Test State', MailingCity = 'Test City', OwnerId = UserInfo.getUserId());
        insert con;

        Test.startTest();
        String result = RoutePlannerController.getCityList('false', 'Contact', 'Test State');
        Test.stopTest();
    }

    @isTest
    static void testGetCityListForLead() {
        try {
            // Create test data
            City__c ct = new City__c(Name = 'Panjim');
            insert ct;

            Country__c cn = new Country__c(Name = 'India');
            insert cn;

            State__c st = new State__c(Name = 'GOA', Country__c = cn.Id);
            insert st;

            Lead__c lead = new Lead__c(Name = 'Test Lead', State__c = st.Id, City__c = ct.Id, Company_Name__c = 'ASB', Last_Name__c = 'cn', OwnerId = UserInfo.getUserId());
            insert lead;

            Test.startTest();
            String result = RoutePlannerController.getCityList('false', 'Lead__c', st.Id); // Pass the state ID, not the city ID
            Test.stopTest();

            // Verify the result
            List<Map<String, Object>> cityList = (List<Map<String, Object>>) JSON.deserializeUntyped(result);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }

    @isTest
    static void testGetEntityRecordsForContact() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Setup test data for Contact
        Contact contact1 = new Contact(LastName = 'Contact1', MailingState = 'Maharashtra', MailingCity = 'Pune', OwnerId = UserInfo.getUserId());
        Contact contact2 = new Contact(LastName = 'Contact2', MailingState = 'Maharashtra', MailingCity = 'Pune', OwnerId = UserInfo.getUserId());
        insert new List<Contact>{contact1, contact2};

        // Create Route Planner Junction records to link contacts with a Route Planner
        Route_Planner__c routePlanner = new Route_Planner__c(Name = 'Test Route Planner');
        insert routePlanner;

        Route_Planner_Junction__c rpj1 = new Route_Planner_Junction__c(Route_Planner__c = routePlanner.Id, Contact__c = contact1.Id);
        Route_Planner_Junction__c rpj2 = new Route_Planner_Junction__c(Route_Planner__c = routePlanner.Id, Contact__c = contact2.Id);
        insert new List<Route_Planner_Junction__c>{rpj1, rpj2};

        // Prepare selected and not selected rows for the update
        String selectedRows = '[\"' + contact1.Id + '\", \"' + contact2.Id + '\"]';
        String notSelectedRows = '[]';  // No contacts to exclude

        Test.startTest();
        try {
            String result = RoutePlannerController.updateEntities('Contact', routePlanner.Id, selectedRows, notSelectedRows);
            Test.stopTest();

            // Verify the Route_Planner_Junction__c records are updated or created
            List<Route_Planner_Junction__c> updatedRPJs = [SELECT Id, Route_Planner__c, Contact__c FROM Route_Planner_Junction__c WHERE Route_Planner__c = :routePlanner.Id];
            System.assertEquals(2, updatedRPJs.size());
            System.assertEquals(routePlanner.Id, updatedRPJs[0].Route_Planner__c);
            System.assertEquals(routePlanner.Id, updatedRPJs[1].Route_Planner__c);
        } catch (Exception e) {
            Test.stopTest();
            System.debug('Error occurred: ' + e.getMessage());
            
        }
    }

    @isTest
    static void testGetCityListAccessAllRecords() {
        // Create test data
        Account acc = new Account(Name = 'Test Account', BillingState = 'Test State', BillingCity = 'Test City');
        insert acc;

        Test.startTest();
        String result = RoutePlannerController.getCityList('true', 'Account', 'Test State');
        Test.stopTest();
    }
    
@isTest
static void testGetEntityRecordsForLead() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    // Create State and City custom objects first
    City__c ct = new City__c(Name = 'Panjim');
    insert ct;

    Country__c cn = new Country__c(Name = 'India');
    insert cn;

    State__c st = new State__c(Name = 'GOA', Country__c = cn.Id);
    insert st;

    // Setup test data for Lead__c with references to State__c and City__c
    Lead__c lead1 = new Lead__c(
        Name = 'Lead1', 
        Company_Name__c = 'Company1', 
        Last_Name__c = 'asd', 
        Lead_Status__c = 'New', 
        State__c = st.Id, 
        City__c = ct.Id, 
        OwnerId = UserInfo.getUserId()
    );
    Lead__c lead2 = new Lead__c(
        Name = 'Lead2', 
        Company_Name__c = 'Company2', 
        Last_Name__c = 'sd', 
        Lead_Status__c = 'New', 
        State__c = st.Id, 
        City__c = ct.Id, 
        OwnerId = UserInfo.getUserId()
    );
    insert new List<Lead__c>{lead1, lead2};

    // Create Route Planner Junction records to link leads with a Route Planner
    Route_Planner__c routePlanner = new Route_Planner__c(Name = 'Test Route Planner');
    insert routePlanner;

    Route_Planner_Junction__c rpj1 = new Route_Planner_Junction__c(Route_Planner__c = routePlanner.Id, Lead__c = lead1.Id);
    Route_Planner_Junction__c rpj2 = new Route_Planner_Junction__c(Route_Planner__c = routePlanner.Id, Lead__c = lead2.Id);
    insert new List<Route_Planner_Junction__c>{rpj1, rpj2};

    try {
        Test.startTest();
        List<Object> result = (List<Object>) RoutePlannerController.getEntityRecords(
            routePlanner.Id, 
            'false', 
            'Lead__c', 
            st.Id, 
            ct.Id, 
            null
        );
        Test.stopTest();

        // Verify the result is not null and contains the expected number of records
        System.assertNotEquals(null, result);
        System.assert(result.size() > 0, 'Expected results for Lead records.');
    } catch (Exception e) {
        Test.stopTest();
        System.debug('Error occurred: ' + e.getMessage());
   
    }
}



}