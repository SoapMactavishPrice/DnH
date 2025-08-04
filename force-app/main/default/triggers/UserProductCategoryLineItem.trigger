trigger UserProductCategoryLineItem on User_Wise_Product_Category_Target_Line__c(before insert, before update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
      TargetAllInOneTriggerHandler.evaluateValues(Trigger.New);
      TargetAllInOneTriggerHandler.UpdateAmountValues(Trigger.New);
    }
}