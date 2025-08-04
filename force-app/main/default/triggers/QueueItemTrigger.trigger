trigger QueueItemTrigger on eContacts__Queue_Item__c (after insert, after update) {
    
    List<Lead__c> leadsToInsert = new List<Lead__c>();
    List<Lead__c> leadsToUpdate = new List<Lead__c>();
    Set<String> emailSet = new Set<String>();
    
    for (eContacts__Queue_Item__c queueItem : Trigger.new) {
        emailSet.add(queueItem.eContacts__Email__c);
    }
    
    Map<String, Lead__c> existingLeadsMap = new Map<String, Lead__c>();
    if (!emailSet.isEmpty()) {
        for (Lead__c lead : [SELECT Id, Email__c, Name, First_Name__c, Last_Name__c, Mobile_Number__c, Landline_No__c, Title__c, Website__c, 
                             Scan_Street__c, Scan_City__c, Scan_State__c, Scan_Zip_Code__c, Scan_Country__c, Lead_Status__c, Lead_Source__c
                             FROM Lead__c WHERE Email__c IN :emailSet]) {
                                 existingLeadsMap.put(lead.Email__c, lead);
                             }
    }
    
    Boolean businessCardValue = Boolean.valueOf(System.Label.businessCard);
    
    for (eContacts__Queue_Item__c queueItem : Trigger.new) {
        if (businessCardValue == true) {
            if (existingLeadsMap.containsKey(queueItem.eContacts__Email__c)) {
                Lead__c existingLead = existingLeadsMap.get(queueItem.eContacts__Email__c);
                existingLead.Name = queueItem.eContacts__Company__c;
                existingLead.First_Name__c = queueItem.eContacts__First_Name__c;
                existingLead.Last_Name__c = queueItem.eContacts__Last_Name__c;
                existingLead.Mobile_Number__c = queueItem.eContacts__Phone_Mobile__c;
                existingLead.Landline_No__c = queueItem.eContacts__Phone_Office__c;
                existingLead.Title__c = queueItem.eContacts__Designation__c;
                existingLead.Website__c = queueItem.eContacts__Website__c;
                existingLead.Scan_Street__c = queueItem.eContacts__Address_Street__c;
                existingLead.Scan_City__c = queueItem.eContacts__Address_City__c;
                existingLead.Scan_State__c = queueItem.eContacts__Address_State__c;
                existingLead.Scan_Zip_Code__c = queueItem.eContacts__Address_Zip__c;
                existingLead.Scan_Country__c = queueItem.eContacts__Address_Country__c;
                leadsToUpdate.add(existingLead);
            } else {
                Lead__c newLead = new Lead__c();
                newLead.Name = queueItem.eContacts__Company__c;
                newLead.First_Name__c = queueItem.eContacts__First_Name__c;
                newLead.Last_Name__c = queueItem.eContacts__Last_Name__c;
                newLead.Email__c = queueItem.eContacts__Email__c;
                newLead.Mobile_Number__c = queueItem.eContacts__Phone_Mobile__c;
                newLead.Landline_No__c = queueItem.eContacts__Phone_Office__c;
                newLead.Title__c = queueItem.eContacts__Designation__c;
                newLead.Website__c = queueItem.eContacts__Website__c;
                newLead.Lead_Status__c = 'New';
                newLead.Lead_Source__c = 'businessCard';
                newLead.Scan_Street__c = queueItem.eContacts__Address_Street__c;
                newLead.Scan_City__c = queueItem.eContacts__Address_City__c;
                newLead.Scan_State__c = queueItem.eContacts__Address_State__c;
                newLead.Scan_Zip_Code__c = queueItem.eContacts__Address_Zip__c;
                newLead.Scan_Country__c = queueItem.eContacts__Address_Country__c;
                leadsToInsert.add(newLead);
            }
        }
    }
    
    if (!leadsToInsert.isEmpty()) {
        insert leadsToInsert;
    }
    
    if (!leadsToUpdate.isEmpty()) {
        update leadsToUpdate;
    }
}