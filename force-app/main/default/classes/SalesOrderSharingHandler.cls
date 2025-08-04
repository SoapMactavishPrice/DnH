public class SalesOrderSharingHandler {
    
    public static void shareSalesOrderWithUsers(List<Sales_Order__c> salesOrders) {
        // List to hold the Share records we will create
        List<Sales_Order__Share> sharesToInsert = new List<Sales_Order__Share>();
        
        // Query the existing Sales_Order__Share records for the given sales orders
        Set<Id> orderIds = new Set<Id>();
        for (Sales_Order__c order : salesOrders) {
            orderIds.add(order.Id);
        }
        
        // Query existing shares for these orders to avoid duplication
        Map<Id, List<Sales_Order__Share>> existingSharesMap = new Map<Id, List<Sales_Order__Share>>();
        for (Sales_Order__Share share : [SELECT ParentId, UserOrGroupId FROM Sales_Order__Share WHERE ParentId IN :orderIds]) {
            if (!existingSharesMap.containsKey(share.ParentId)) {
                existingSharesMap.put(share.ParentId, new List<Sales_Order__Share>());
            }
            existingSharesMap.get(share.ParentId).add(share);
        }
        
        for (Sales_Order__c order : salesOrders) {
            // Check if the Sales_Person__c field is populated and not already shared with this user
            if (order.Sales_Person__c != null && !isAlreadyShared(order.Id, order.Sales_Person__c, existingSharesMap)) {
                sharesToInsert.add(new Sales_Order__Share(
                    ParentId = order.Id,
                    UserOrGroupId = order.Sales_Person__c,
                    AccessLevel = 'Edit',  // Set the access level you want (e.g., 'Read', 'Edit')
                    RowCause = Schema.Sales_Order__Share.RowCause.Manual
                ));
            }
            
            // Check if the Area_Manager__c field is populated and not already shared with this user
            if (order.Area_Manager__c != null && !isAlreadyShared(order.Id, order.Area_Manager__c, existingSharesMap)) {
                sharesToInsert.add(new Sales_Order__Share(
                    ParentId = order.Id,
                    UserOrGroupId = order.Area_Manager__c,
                    AccessLevel = 'Edit',
                    RowCause = Schema.Sales_Order__Share.RowCause.Manual
                ));
            }
            
            // Check if the Zonal_Head__c field is populated and not already shared with this user
            if (order.Zonal_Head__c != null && !isAlreadyShared(order.Id, order.Zonal_Head__c, existingSharesMap)) {
                sharesToInsert.add(new Sales_Order__Share(
                    ParentId = order.Id,
                    UserOrGroupId = order.Zonal_Head__c,
                    AccessLevel = 'Edit',
                    RowCause = Schema.Sales_Order__Share.RowCause.Manual
                ));
            }
        }
        
        // Insert all the share records
        if (!sharesToInsert.isEmpty()) {
            insert sharesToInsert;
        }
    }
    
    // Helper method to check if a share already exists for a given Sales Order and user
    private static Boolean isAlreadyShared(Id orderId, Id userId, Map<Id, List<Sales_Order__Share>> existingSharesMap) {
        if (existingSharesMap.containsKey(orderId)) {
            for (Sales_Order__Share share : existingSharesMap.get(orderId)) {
                if (share.UserOrGroupId == userId) {
                    return true;  // The share already exists for this user
                }
            }
        }
        return false;
    }
}