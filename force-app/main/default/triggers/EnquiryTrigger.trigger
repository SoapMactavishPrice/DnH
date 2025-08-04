trigger EnquiryTrigger on Enquiry__c(before insert, after insert, before update, after update) {

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            for (Enquiry__c enq : Trigger.New) {
                RecordType rt = [SELECT Id, Name FROM RecordType WHERE Id =: enq.RecordTypeId];
                if (rt.Name == 'Techno Commercial Offer') {                    
                    // EnquiryTriggerHandler.syncTCO_ToNavision(Trigger.New);
                }
            }
        }
        if(Trigger.isUpdate) {
            // for (Enquiry__c enq : Trigger.New) {
            //     for (Enquiry__c enq : Trigger.New) {
            //         RecordType rt = [SELECT Id, Name FROM RecordType WHERE Id =: enq.RecordTypeId];
            //         if (rt.Name == 'Techno Commercial Offer') {                    
            //             EnquiryTriggerHandler.approveTCOSyncToTSD(Trigger.New);
            //         }
            //     }
            // }

            Map < Id, Enquiry__c > oldAccAddRecs = Trigger.oldMap;
            Map < Id, Enquiry__c > newAccAddRecs = Trigger.newMap;

            for (Integer i = 0; i < newAccAddRecs.values().size(); i++) {

                Enquiry__c oldPA = oldAccAddRecs.values()[i];
                Enquiry__c newPA = newAccAddRecs.values()[i];

                if (oldPA.Status__c != 'Approved By Shivi Chaturvedi' && newPA.Status__c == 'Approved By Shivi Chaturvedi') {
                    // EnquiryTriggerHandler.approveTCOSyncToTSD(newPA.Id);
                }
            }

        }
    }
}