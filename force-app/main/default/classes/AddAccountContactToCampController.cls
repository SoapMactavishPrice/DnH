public class AddAccountContactToCampController {

    @AuraEnabled
    public static String getLeadRecord(String campId) {
        List<Route_Planner_Junction__c> campMemberList = [
            SELECT Id, Account__c
            FROM Route_Planner_Junction__c
            WHERE Route_Planner__c = :campId
        ];

        Set<Id> leadIdSet = new Set<Id>();
        for (Route_Planner_Junction__c cm : campMemberList) {
            if (cm.Account__c != null) {
                leadIdSet.add(cm.Account__c);
            }
        }

        List<Account> leads = [
            SELECT Id, Name, Industry, BillingCity, BillingState
            FROM Account
            WHERE Id NOT IN :leadIdSet
        ];

        List<LeadWrapper> leadListwc = new List<LeadWrapper>();
        Integer i = 0;

        for (Account ld : leads) {
            LeadWrapper ldwc = new LeadWrapper();
            ldwc.Id = ld.Id;
            ldwc.purl = '/lightning/r/' + ld.Id + '/view';
            ldwc.Name = ld.Name;
            ldwc.Industry = ld.Industry;
            ldwc.BillingCity = ld.BillingCity;
            ldwc.BillingState = ld.BillingState;
       //     ldwc.Status = ld.Customer_Status__c;
            ldwc.index = i++;
            leadListwc.add(ldwc);
        }

        wrapperClass wc = new wrapperClass();
        wc.leadList = leadListwc;
        return JSON.serialize(wc);
    }

    @AuraEnabled
    public static String getContactRecord(String campId) {
        List<Route_Planner_Junction__c> campMemberList = [
            SELECT Id, Contact__c
            FROM Route_Planner_Junction__c
            WHERE Route_Planner__c = :campId
        ];

        Set<Id> contIdSet = new Set<Id>();
        for (Route_Planner_Junction__c cm : campMemberList) {
            if (cm.Contact__c != null) {
                contIdSet.add(cm.Contact__c);
            }
        }

        List<Contact> contacts = [
            SELECT Id, Name, AccountId, Account.Name, MobilePhone, Email, Department, LeadSource, MailingCity, MailingState
            FROM Contact
            WHERE Id NOT IN :contIdSet
        ];

        List<ContactWrapper> contListwc = new List<ContactWrapper>();
        Integer i = 0;

        for (Contact ld : contacts) {
            ContactWrapper ldwc = new ContactWrapper();
            ldwc.Id = ld.Id;
            ldwc.curl = '/lightning/r/' + ld.Id + '/view';
            ldwc.aurl = '/lightning/r/' + ld.AccountId + '/view';
            ldwc.Name = ld.Name;
            ldwc.Account = ld.Account.Name;
            ldwc.Mobile = ld.MobilePhone != null ? ld.MobilePhone : '';
            ldwc.Email = ld.Email != null ? ld.Email : '';
            ldwc.Department = ld.Department != null ? ld.Department : '';
      //      ldwc.IndustryGroup = ld.Industry_Group__c;
            ldwc.LeadSource = ld.LeadSource;
            ldwc.MailingCity = ld.MailingCity;
            ldwc.MailingState = ld.MailingState;
            ldwc.index = i++;
            contListwc.add(ldwc);
        }

        wrapperClass2 wc = new wrapperClass2();
        wc.contactList = contListwc;
        return JSON.serialize(wc);
    }

    @AuraEnabled
    public static String saveCampMembers(String campId, String campMemberData, String type) {
        try {
            List<Json2Apex> campMemberDataList = parseTarget(campMemberData);
            List<Route_Planner_Junction__c> campMembersToInsert = new List<Route_Planner_Junction__c>();
            Set<Id> leadIdSet = new Set<Id>();
            Set<Id> contactIdSet = new Set<Id>();

            for (Json2Apex obj : campMemberDataList) {
                Route_Planner_Junction__c campMember = new Route_Planner_Junction__c();
                campMember.Route_Planner__c = campId;

                if (type == 'Lead') {
                    campMember.Account__c = obj.Id;
                    leadIdSet.add(obj.Id);
                } else if (type == 'Contact') {
                    campMember.Contact__c = obj.Id;
                    contactIdSet.add(obj.Id);
                }

                campMembersToInsert.add(campMember);
            }

            insert campMembersToInsert;

            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }

    public with sharing class wrapperClass {
        public List<LeadWrapper> leadList;
    }

    public with sharing class LeadWrapper {
        public Id Id;
        public String purl;
        public String Name;
        public String Industry;
        public String BillingCity;
        public String BillingState;
        public String Status;
        public Integer index;
    }

    public with sharing class wrapperClass2 {
        public List<ContactWrapper> contactList;
    }

    public with sharing class ContactWrapper {
        public Id Id;
        public String curl;
        public String aurl;
        public String Name;
        public String Account;
        public String Mobile;
        public String Email;
        public String Department;
        public String IndustryGroup;
        public String LeadSource;
        public String MailingCity;
        public String MailingState;
        public Integer index;
    }

    public class Json2Apex {
        public String Id;
    }

    public static List<Json2Apex> parseTarget(String json) {
        return (List<Json2Apex>) System.JSON.deserialize(json, List<Json2Apex>.class);
    }
}