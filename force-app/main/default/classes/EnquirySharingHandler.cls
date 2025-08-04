public class EnquirySharingHandler {
    
    public static void shareEnquiryWithUsers(List<Enquiry__c> EnqList) {
        // List to hold the Share records we will create
        List<Enquiry__Share> sharesToInsert = new List<Enquiry__Share>();
        
        // Collect all User Ids from Enquiries to check their active status
        Set<Id> userIds = new Set<Id>();
        for (Enquiry__c order : EnqList) {
            if (order.Field_Staff_Code__c != null) userIds.add(order.Field_Staff_Code__c);
            if (order.Area_Manager__c != null) userIds.add(order.Area_Manager__c);
            if (order.Zonal_Head__c != null) userIds.add(order.Zonal_Head__c);
        }
        
        // Fetch only active users
        Set<Id> activeUserIds = new Set<Id>();
        for (User u : [SELECT Id FROM User WHERE Id IN :userIds AND IsActive = TRUE]) {
            activeUserIds.add(u.Id);
        }
        
        // Query existing Enquiry__Share records for the given Enquiries
        Map<Id, List<Enquiry__Share>> existingSharesMap = new Map<Id, List<Enquiry__Share>>();
        for (Enquiry__Share share : [SELECT ParentId, UserOrGroupId FROM Enquiry__Share WHERE ParentId IN :EnqList]) {
            if (!existingSharesMap.containsKey(share.ParentId)) {
                existingSharesMap.put(share.ParentId, new List<Enquiry__Share>());
            }
            existingSharesMap.get(share.ParentId).add(share);
        }
        
        for (Enquiry__c order : EnqList) {
            // Share only if the user is active and not already shared
            if (order.Field_Staff_Code__c != null && activeUserIds.contains(order.Field_Staff_Code__c) && !isAlreadyShared(order.Id, order.Field_Staff_Code__c, existingSharesMap)) {
                sharesToInsert.add(new Enquiry__Share(
                    ParentId = order.Id,
                    UserOrGroupId = order.Field_Staff_Code__c,
                    AccessLevel = 'Edit',
                    RowCause = Schema.Enquiry__Share.RowCause.Manual
                ));
            }
            
            if (order.Area_Manager__c != null && activeUserIds.contains(order.Area_Manager__c) && !isAlreadyShared(order.Id, order.Area_Manager__c, existingSharesMap)) {
                sharesToInsert.add(new Enquiry__Share(
                    ParentId = order.Id,
                    UserOrGroupId = order.Area_Manager__c,
                    AccessLevel = 'Edit',
                    RowCause = Schema.Enquiry__Share.RowCause.Manual
                ));
            }
            
            if (order.Zonal_Head__c != null && activeUserIds.contains(order.Zonal_Head__c) && !isAlreadyShared(order.Id, order.Zonal_Head__c, existingSharesMap)) {
                sharesToInsert.add(new Enquiry__Share(
                    ParentId = order.Id,
                    UserOrGroupId = order.Zonal_Head__c,
                    AccessLevel = 'Edit',
                    RowCause = Schema.Enquiry__Share.RowCause.Manual
                ));
            }
        }
        
        // Insert all the share records
        if (!sharesToInsert.isEmpty()) {
            insert sharesToInsert;
        }
    }
    
    // Helper method to check if a share already exists for a given Enquiry and user
    private static Boolean isAlreadyShared(Id orderId, Id userId, Map<Id, List<Enquiry__Share>> existingSharesMap) {
        if (existingSharesMap.containsKey(orderId)) {
            for (Enquiry__Share share : existingSharesMap.get(orderId)) {
                if (share.UserOrGroupId == userId) {
                    return true;  // The share already exists for this user
                }
            }
        }
        return false;
    }
}