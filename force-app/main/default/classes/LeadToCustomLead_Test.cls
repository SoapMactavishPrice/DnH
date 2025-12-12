@isTest
public class LeadToCustomLead_Test {
    
    @testSetup
    static void setupData() {
        // No setup data required for now
    }
    
    @isTest
    static void test_NewCustomLeadCreated() {
        Country__c c = new Country__c();
        c.Name ='India';
        Insert c;
        State__c s = new State__c();
        s.Name = 'Goa';
        s.Country__c = c.id;
        Insert s;
        // Insert a fresh Lead (no existing custom lead)
        Lead l1 = new Lead(
            FirstName = 'Test',
            LastName = 'User1',
            Company = 'ABC Corp',
            Email = 'test1@example.com',
            MobilePhone = '1234567890',
            State__c = s.id
        );
        insert l1;
        
        // Validate Custom Lead created
        Lead__c cl = [SELECT Id, Email__c, Mobile_Number__c FROM Lead__c WHERE Email__c = 'test1@example.com' LIMIT 1];
        System.assertNotEquals(null, cl, 'Custom Lead should be created');
        System.assertEquals('1234567890', cl.Mobile_Number__c);
        
        // Validate Lead Source created
        Lead_Source__c ls = [SELECT Id, Lead__c FROM Lead_Source__c WHERE Lead__c = :cl.Id LIMIT 1];
        System.assertEquals(cl.Id, ls.Lead__c, 'Lead Source should be linked to Custom Lead');
    }
    
    @isTest
    static void test_ExistingCustomLead_OnlyNewLeadSourceCreated() {
        Country__c c = new Country__c();
        c.Name ='India';
        Insert c;
        State__c s = new State__c();
        s.Name = 'Goa';
        s.Country__c = c.id;
        Insert s;
        // First Lead → creates Custom Lead
        Lead l1 = new Lead(
            FirstName = 'Test',
            LastName = 'User2',
            Company = 'XYZ Corp',
            Email = 'test2@example.com',
            MobilePhone = '9998887777',
            State__c = s.id
        );
        insert l1;
        
        Lead__c cl = [SELECT Id FROM Lead__c WHERE Email__c = 'test2@example.com' LIMIT 1];
        System.assertNotEquals(null, cl);
        
        // Second Lead with SAME email/mobile → should NOT create new Custom Lead but create new Lead Source
        Lead l2 = new Lead(
            FirstName = 'Test',
            LastName = 'User3',
            Company = 'PQR Corp',
            Email = 'testl2@example.com',
            MobilePhone = '9998887777',
            State__c = s.id
        );
        insert l2;
        
        // Ensure still only ONE custom lead
        Integer clCount = [SELECT COUNT() FROM Lead__c WHERE Email__c = 'test2@example.com'];
        System.assertEquals(1, clCount, 'Should still be only one Custom Lead');
        
        // But TWO lead sources should exist now
        Integer lsCount = [SELECT COUNT() FROM Lead_Source__c WHERE Lead__c = :cl.Id];
        System.assertEquals(2, lsCount, 'Two Lead Source records should be created');
    }
}