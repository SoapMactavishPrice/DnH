trigger UserHandlerTrigger on User (after insert, after update) {

    List<Flutter_User__c> infoToUpsert = new List<Flutter_User__c>();

    List<Flutter_User__c> existingInfo = new List<Flutter_User__c>();
    existingInfo = [SELECT Id, User__c, User_Email__c, User_Mobile__c, Username__c, User_Code__c FROM Flutter_User__c WHERE User__c IN :Trigger.newMap.keySet()];

    Map<String, Flutter_User__c> existingInfoMap = new Map<String, Flutter_User__c>();

    for (Flutter_User__c info : existingInfo) {
        existingInfoMap.put(info.User__c, info);
    }

    for (User u : Trigger.new) {
        Flutter_User__c record;

        if (existingInfoMap.containsKey(u.Id)) {
            // Update existing
            record = existingInfoMap.get(u.Id);
        } else {
            // Create new
            record = new Flutter_User__c(User__c = u.Id);
        }

        record.User__c = u.Id;
        record.User_Email__c = u.Email;
        record.User_Mobile__c = u.Phone;
        record.Username__c = u.Username;
        record.User_Code__c = u.Code__c;

        infoToUpsert.add(record);
    }

    upsert infoToUpsert;

}