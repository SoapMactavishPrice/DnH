@isTest
public class AddAccountContactToCampControllerTest {

    @testSetup
    static void setup() {
        

        // Create test data for Account
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                Industry = 'Industry ' + i,
                BillingCity = 'City ' + i,
                BillingState = 'State ' + i
            );
            accounts.add(acc);
        }
        insert accounts;

        Route_Planner__c rps = new Route_Planner__c();
        rps.Name = 'Western Suburbs';
        rps.Is_Active__c = true;
        insert rps;
        
        
        // Create test data for Contact
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact con = new Contact(
                LastName = 'Test Contact ' + i,
                AccountId = accounts[i].Id,
                MobilePhone = '1234567890',
                Email = 'test' + i + '@example.com',
                Department = 'Department ' + i,
                LeadSource = 'Lead Source ' + i,
                MailingCity = 'City ' + i,
                MailingState = 'State ' + i
            );
            contacts.add(con);
        }
        insert contacts;
        
        
        Route_Planner_Junction__c RP = new Route_Planner_Junction__c();
        rp.Account__c = accounts[0].Id;
        rp.Contact__c = contacts[0].Id;
        rp.Route_Planner__c = rps.Id;
        insert rp;
    }

    @isTest
    static void testGetLeadRecord() {
        Test.startTest();
        Route_Planner__c rps = [select Id from Route_Planner__c limit 1];
        String result = AddAccountContactToCampController.getLeadRecord(rps.Id);
        System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    static void testGetContactRecord() {
        Test.startTest();
        Route_Planner__c rps = [select Id from Route_Planner__c limit 1];
        String result = AddAccountContactToCampController.getContactRecord(rps.Id);
        
        
        System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    static void testSaveCampMembers() {
        Test.startTest();
        List<AddAccountContactToCampController.Json2Apex> members = new List<AddAccountContactToCampController.Json2Apex>();
        AddAccountContactToCampController.Json2Apex member = new AddAccountContactToCampController.Json2Apex();
        Account rps = [select Id from Account limit 1];
        member.Id = rps.Id;
        members.add(member);
        String jsonMembers = JSON.serialize(members);
        
        Route_Planner__c rpsl = [select Id from Route_Planner__c limit 1];
        
        AddAccountContactToCampController.saveCampMembers(rpsl.Id,jsonMembers,'Lead');        

        Test.stopTest();
    }
}