trigger AccountTrigger on Account (before insert, after insert, before update, after update) {

    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            // AccountTriggerHandler.syncAccountToNavision(Trigger.New);
        }
    }

}