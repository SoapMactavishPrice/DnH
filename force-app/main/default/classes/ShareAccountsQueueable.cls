public class ShareAccountsQueueable implements Queueable, Database.AllowsCallouts {
    
    List<Customer_Sales_Person_Mapping__c> mappings;
    
    public ShareAccountsQueueable(List<Customer_Sales_Person_Mapping__c> mappings) {
        this.mappings = mappings;
    }
    
    public void execute(QueueableContext context) {
        Map<String, Set<String>> accountToUserMap = new Map<String, Set<String>>();
        Set<String> allUserCodes = new Set<String>();
        Set<String> affectedAccounts = new Set<String>();
        
        for (Customer_Sales_Person_Mapping__c mapping : mappings) {
            if (mapping.Account__c == null) continue;
            
            affectedAccounts.add(mapping.Account__c);
            
            Set<String> userCodes = new Set<String>();
            if (mapping.Sales_Person_Code__c != null) userCodes.add(mapping.Sales_Person_Code__c);
            if (mapping.Reporting_person_ID__c != null) userCodes.add(mapping.Reporting_person_ID__c);
            if (mapping.Zonal_manager_ID__c != null) userCodes.add(mapping.Zonal_manager_ID__c);
            
            allUserCodes.addAll(userCodes);
            
            if (!accountToUserMap.containsKey(mapping.Account__c)) {
                accountToUserMap.put(mapping.Account__c, new Set<String>());
            }
            accountToUserMap.get(mapping.Account__c).addAll(userCodes);
        }
        
        // Fetch User Ids
        Map<String, String> userCodeToIdMap = new Map<String, String>();
        for (User u : [
            SELECT Id, Code__c, Profile.Name FROM User 
            WHERE Code__c IN :allUserCodes AND IsActive = true AND Profile.Name != 'System Administrator'
        ]) {
            userCodeToIdMap.put(u.Code__c, u.Id);
        }
        
        // Map Account Ids to User Ids
        Map<String, Set<String>> accountToUserIds = new Map<String, Set<String>>();
        for (String acctId : accountToUserMap.keySet()) {
            Set<String> userIds = new Set<String>();
            for (String code : accountToUserMap.get(acctId)) {
                if (userCodeToIdMap.containsKey(code)) {
                    userIds.add(userCodeToIdMap.get(code));
                }
            }
            accountToUserIds.put(acctId, userIds);
        }
        
        // Get existing shares
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
        
        // Prepare DML
        List<AccountShare> toInsert = new List<AccountShare>();
        List<AccountShare> toDelete = new List<AccountShare>();
        
        for (String acctId : accountToUserIds.keySet()) {
            Set<String> newUsers = accountToUserIds.get(acctId);
            Set<String> existingUsers = existingSharesMap.get(acctId) != null ? existingSharesMap.get(acctId) : new Set<String>();
            
            for (String userId : newUsers) {
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
            
            for (String userId : existingUsers) {
                if (!newUsers.contains(userId)) {
                    for (AccountShare share : existingShares) {
                        if (share.AccountId == acctId && share.UserOrGroupId == userId) {
                            toDelete.add(share);
                        }
                    }
                }
            }
        }
        
        // Execute DML safely
        if (!toInsert.isEmpty()) Database.insert(toInsert, false);
        if (!toDelete.isEmpty()) Database.delete(toDelete, false);
    }
}