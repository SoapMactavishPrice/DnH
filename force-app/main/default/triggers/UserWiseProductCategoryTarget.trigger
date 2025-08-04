trigger UserWiseProductCategoryTarget on User_Wise_Product_Category_Target__c (before insert,after insert, after update,before update) {

    if(Trigger.isBefore && Trigger.isUpdate) {
        TargetAllInOneTriggerHandler.rollupTargetAmount(Trigger.New, Trigger.oldMap, 'UserWiseProductCategoryTarget');
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
        TargetAllInOneTriggerHandler.createMonthlyTargetEntries(Trigger.New);
    }
    
   if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
       // TargetAllInOneTriggerHandler.updateBranchTarget(Trigger.New, Trigger.oldMap);
        TargetAllInOneTriggerHandler.shareRecordWithUser(Trigger.New, Trigger.oldMap);
    } 
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('updateMonthlyTargetEntries222:>>');
        TargetAllInOneTriggerHandler.updateMonthlyTargetEntries(Trigger.New, Trigger.oldMap, Trigger.newMap, 'UserWiseProductCategoryTarget');
    }
    
}