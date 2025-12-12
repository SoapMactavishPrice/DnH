public with sharing class LeadSourceHandler {

    public static void handleAfterUpdate(List<Lead_Source__c> newList, Map<Id, Lead_Source__c> oldMap) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Collect Lead Ids where owner has changed
        Set<Id> leadIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();

        for (Lead_Source__c ls : newList) {
            Lead_Source__c oldLs = oldMap.get(ls.Id);
            if (ls.OwnerId != oldLs.OwnerId && ls.Lead__c != null) {
                leadIds.add(ls.Lead__c);
            }
            ownerIds.add(ls.OwnerId);
        }

        // Query related Leads
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        if (!leadIds.isEmpty()) {
            leadMap = new Map<Id, Lead>([
                SELECT Id, FirstName
                FROM Lead
                WHERE Id IN :leadIds
            ]);
        }

        // Query Users
        Map<Id, User> userMap = new Map<Id, User>();
        if (!ownerIds.isEmpty()) {
            userMap = new Map<Id, User>([
                SELECT Id, FirstName, LastName, Email
                FROM User
                WHERE Id IN :ownerIds
            ]);
        }

        // Build emails
        for (Lead_Source__c ls : newList) {
            Lead_Source__c oldLs = oldMap.get(ls.Id);

            if (ls.OwnerId != oldLs.OwnerId && ls.Lead__c != null) {
                Lead leadRecord = leadMap.get(ls.Lead__c);
                User newOwner = userMap.get(ls.OwnerId);

                if (newOwner != null && newOwner.Email != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{newOwner.Email});

                    // Use Last_Name__c from Lead_Source__c instead of Lead.LastName
                    mail.setSubject(
                        'New Lead Assigned to You – ' + 
                        (leadRecord != null ? leadRecord.FirstName + ' ' : '') + 
                        (ls.Last_Name__c != null ? ls.Last_Name__c : '')
                    );

                    //  Use Lead__c Id for the record URL
                    String recordUrl = System.URL.getOrgDomainUrl().toExternalForm() + '/' + ls.Lead__c;

                    String body = ''
                        + 'Hi ' + newOwner.FirstName + ' ' + newOwner.LastName + ',<br/><br/>'
                        + 'A new lead has been assigned to you in Salesforce. <br/>Here are the details:<br/><br/>'
                        + '<b>Name:</b> ' 
                            + (leadRecord != null ? leadRecord.FirstName + ' ' : '') 
                            + (ls.Last_Name__c != null ? ls.Last_Name__c : '') + '<br/>'
                        + '<b>Mobile Number:</b> ' + (ls.Mobile_No__c != null ? ls.Mobile_No__c : '') + '<br/>'
                        + '<b>Subject:</b> ' + (ls.Subject__c != null ? ls.Subject__c : '') + '<br/>'
                        + '<b>Product Name:</b> ' + (ls.Product_Name__c != null ? ls.Product_Name__c : '') + '<br/>'
                        + '<b>Message:</b> ' + (ls.Message__c != null ? ls.Message__c : '') + '<br/><br/>'
                        + '<a href="' + recordUrl + '">View Lead in Salesforce</a><br/>'   // ✅ now opens Lead record
                        + 'Please follow up with this lead at the earliest to ensure timely engagement.<br/><br/>'
                        + 'Thanks,<br/>Salesforce System Notification';

                    mail.setHtmlBody(body);
                    emails.add(mail);
                }
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}