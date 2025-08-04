trigger CustomerComplaintTrigger on Customer_Complaint__c (before insert, before update) {

    // Handle duplicate Name on INSERT
    if (Trigger.isInsert) {
        Set<String> complaintNames = new Set<String>();

        for (Customer_Complaint__c con : Trigger.new) {
            if (con.Name != null) {
                complaintNames.add(con.Name);
            }
        }

        if (!complaintNames.isEmpty()) {
            Map<String, Customer_Complaint__c> existingNamesMap = new Map<String, Customer_Complaint__c>();

            for (Customer_Complaint__c existing : [
                SELECT Id, Name 
                FROM Customer_Complaint__c 
                WHERE Name IN :complaintNames
            ]) {
                existingNamesMap.put(existing.Name, existing);
            }

            for (Customer_Complaint__c con : Trigger.new) {
                if (con.Name != null && existingNamesMap.containsKey(con.Name)) {
                    con.addError('A record with this complaint number already exists.');
                }
            }
        }
    }

    // Prevent changing Name on UPDATE
    if (Trigger.isUpdate) {
        for (Customer_Complaint__c con : Trigger.new) {
            Customer_Complaint__c oldCon = Trigger.oldMap.get(con.Id);

            if (con.Name != oldCon.Name) {
                con.addError('Modification of Complaint Name is not allowed.');
            }
        }
    }
}