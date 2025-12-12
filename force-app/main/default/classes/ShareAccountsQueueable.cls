public class ShareAccountsQueueable implements Queueable, Database.AllowsCallouts {
    
    List<Customer_Sales_Person_Mapping__c> triggerMappings;
    
    public ShareAccountsQueueable(List<Customer_Sales_Person_Mapping__c> mappings) {
        this.triggerMappings = mappings;
    }
    
    public void execute(QueueableContext context) {
        // Collect all affected accounts
        Set<String> affectedAccounts = new Set<String>();
        for (Customer_Sales_Person_Mapping__c mapping : triggerMappings) {
            if (mapping.Account__c != null) {
                affectedAccounts.add(mapping.Account__c);
            }
        }
        
        if (affectedAccounts.isEmpty()) return;
        
        // 🔑 Get *all mappings* for these accounts (not just trigger ones)
        List<Customer_Sales_Person_Mapping__c> allMappings = [
            SELECT Id, Account__c, Sales_Person_Code__c, Reporting_person_ID__c, Zonal_manager_ID__c
            FROM Customer_Sales_Person_Mapping__c
            WHERE Account__c IN :affectedAccounts
        ];
        
        // Build Account → UserCode map
        Map<String, Set<String>> accountToUserCodes = new Map<String, Set<String>>();
        Set<String> allUserCodes = new Set<String>();
        
        for (Customer_Sales_Person_Mapping__c m : allMappings) {
            if (m.Account__c == null) continue;
            
            if (!accountToUserCodes.containsKey(m.Account__c)) {
                accountToUserCodes.put(m.Account__c, new Set<String>());
            }
            
            if (m.Sales_Person_Code__c != null) accountToUserCodes.get(m.Account__c).add(m.Sales_Person_Code__c);
            if (m.Reporting_person_ID__c != null) accountToUserCodes.get(m.Account__c).add(m.Reporting_person_ID__c);
            if (m.Zonal_manager_ID__c != null) accountToUserCodes.get(m.Account__c).add(m.Zonal_manager_ID__c);
            
            allUserCodes.addAll(accountToUserCodes.get(m.Account__c));
        }
        
        // Get User IDs for those codes
        Map<String, String> userCodeToIdMap = new Map<String, String>();
        for (User u : [
            SELECT Id, Code__c, Profile.Name 
            FROM User 
            WHERE Code__c IN :allUserCodes AND IsActive = true AND Profile.Name != 'System Administrator'
        ]) {
            userCodeToIdMap.put(u.Code__c, u.Id);
        }
        
        // Translate codes to IDs
        Map<String, Set<String>> accountToUserIds = new Map<String, Set<String>>();
        for (String acctId : accountToUserCodes.keySet()) {
            Set<String> ids = new Set<String>();
            for (String code : accountToUserCodes.get(acctId)) {
                if (userCodeToIdMap.containsKey(code)) {
                    ids.add(userCodeToIdMap.get(code));
                }
            }
            accountToUserIds.put(acctId, ids);
        }
        
        // Get existing shares for those accounts
        List<AccountShare> existingShares = [
            SELECT Id, AccountId, UserOrGroupId 
            FROM AccountShare 
            WHERE AccountId IN :affectedAccounts
        ];
        
        Map<String, Set<String>> existingSharesMap = new Map<String, Set<String>>();
        for (AccountShare share : existingShares) {
            if (!existingSharesMap.containsKey(share.AccountId)) {
                existingSharesMap.put(share.AccountId, new Set<String>());
            }
            existingSharesMap.get(share.AccountId).add(share.UserOrGroupId);
        }
        
        // Prepare inserts & deletes
        List<AccountShare> toInsert = new List<AccountShare>();
        List<AccountShare> toDelete = new List<AccountShare>();
        
        for (String acctId : accountToUserIds.keySet()) {
            Set<String> requiredUsers = accountToUserIds.get(acctId);
            Set<String> existingUsers = existingSharesMap.get(acctId) != null ? existingSharesMap.get(acctId) : new Set<String>();
            
            // Add missing shares
            for (String userId : requiredUsers) {
                if (!existingUsers.contains(userId)) {
                    toInsert.add(new AccountShare(
                        AccountId = acctId,
                        UserOrGroupId = userId,
                        AccountAccessLevel = 'Edit',
                        OpportunityAccessLevel = 'Read',
                        RowCause = Schema.AccountShare.RowCause.Manual
                    ));
                }
            }
            
            // Delete unnecessary shares
            for (String userId : existingUsers) {
                if (!requiredUsers.contains(userId)) {
                    for (AccountShare share : existingShares) {
                        if (share.AccountId == acctId && share.UserOrGroupId == userId) {
                            toDelete.add(share);
                        }
                    }
                }
            }
        }
        
        if (!toInsert.isEmpty()) Database.insert(toInsert, false);
        if (!toDelete.isEmpty()) Database.delete(toDelete, false);
    }
}