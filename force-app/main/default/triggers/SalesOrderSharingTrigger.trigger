trigger SalesOrderSharingTrigger on Sales_Order__c (after insert, after update) {
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        SalesOrderSharingHandler.shareSalesOrderWithUsers(Trigger.new);
    }
    if (Trigger.isInsert) {
        updateSOCountOnEnquiry.updateSOCountOnSalesOrder(Trigger.new);
    }
}