trigger EventTrigger on Event (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        Set<Id> whatIds = new Set<Id>();
        for(Event ev : Trigger.New) {
            whatIds.add(ev.WhatId);
        }
        
        /*    Map<Id, Opportunity__c> mapOpps = new Map<Id, Opportunity__c> ([SELECT Id, Next_Step__c FROM Opportunity__c WHERE Id IN: whatIds]);

for(Event ev : Trigger.New) {
if(mapOpps.containsKey(ev.WhatId)) {
System.debug(mapOpps.get(ev.WhatId).Next_Step__c);
ev.Next_Step__c = mapOpps.get(ev.WhatId).Next_Step__c;
}
}  */
    }
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        Set<Id> userEmpIds = new Set<Id>();
        for(Event ev : Trigger.New) {
            userEmpIds.add(ev.OwnerId);
        }
        
        if(userEmpIds.size() > 0) {
            Set<IJP__c> ijps = new Set<IJP__c>();
            
            Map<Id, List<IJP__c>> mapEmpIdListIJP = new Map<Id, List<IJP__c>>();
            for(IJP__c ijp : [SELECT Id, User_Employee__c, IJP_Start_Date__c, IJP_End_Date__c FROM IJP__c WHERE User_Employee__c IN: userEmpIds]) {
                if(mapEmpIdListIJP.containsKey(ijp.User_Employee__c))
                    mapEmpIdListIJP.get(ijp.User_Employee__c).add(ijp);
                else
                    mapEmpIdListIJP.put(ijp.User_Employee__c, new List<IJP__c> {ijp});
            }
            
            for(Event ev : Trigger.New) {
                if(mapEmpIdListIJP.containsKey(ev.OwnerId)) {
                    for(IJP__c ijp : mapEmpIdListIJP.get(ev.OwnerId)) {
                        if(ev.ActivityDate >= ijp.IJP_Start_Date__c && ev.ActivityDate <= ijp.IJP_End_Date__c) {
                            ev.IJP__c = ijp.Id;
                            ijps.add(ijp);
                            break;
                        }
                    }
                }
                
                if(String.isBlank(ev.IJP__c)) {
                    IJP__c ijp = new IJP__c();
                    ijp.User_Employee__c = ev.OwnerId;
                    ijp.OwnerId = ev.OwnerId;
                    
                    ijp.IJP_Start_Date__c = Date.newInstance(ev.StartDateTime.year(), ev.StartDateTime.month(), 1);
                    Integer numberOfDays = Date.daysInMonth(ev.StartDateTime.year(), ev.StartDateTime.month());
                    ijp.IJP_End_Date__c = Date.newInstance(ev.StartDateTime.year(), ev.StartDateTime.month(), numberOfDays);
                    
                    ijp.Unique_Key__c = ev.OwnerId + ' ' + ijp.IJP_Start_Date__c + ' ' + ijp.IJP_End_Date__c;
                    
                    Database.SaveResult result = Database.insert(ijp, false);
                    if (result.isSuccess() == false) {
                        for (Database.Error error : result.getErrors()) {
                            if (error instanceof Database.DuplicateError) {
                                Database.DuplicateError duplicateError = (Database.DuplicateError) error;
                                Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                                Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                                Datacloud.MatchResult matchResult = matchResults[0];
                                Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                                
                                for (Datacloud.MatchRecord matchRecord : matchRecords) {
                                    ijp = (IJP__c) matchRecord.getRecord();
                                    System.debug('matched ijp record ' + ijp);
                                    ijp = [SELECT Id, User_Employee__c, IJP_Start_Date__c, IJP_End_Date__c FROM IJP__c WHERE Id =: ijp.Id];
                                }
                            }
                        }
                    }
                    
                    ijps.add(ijp);
                    
                    ev.IJP__c = ijp.Id;
                    
                    
                    if(mapEmpIdListIJP.containsKey(ijp.User_Employee__c)) {
                        mapEmpIdListIJP.get(ijp.User_Employee__c).add(ijp);
                    } else {
                        mapEmpIdListIJP.put(ijp.User_Employee__c, new List<IJP__c> {ijp});
                    }
                }
            }
            
            List<IJP__c> ijpsList = new List<IJP__c>();
            ijpsList.addAll(ijps);
            update ijpsList;
        }
    }
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        
        Set<Id> accountIds = new Set<Id>();
        
        for (Event evt : Trigger.new) {
            if (evt.WhatId != null && String.valueOf(evt.WhatId).startsWith('001')) {
                accountIds.add(evt.WhatId);
            }
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        if (!accountIds.isEmpty()) {
            accountMap = new Map<Id, Account>([
                SELECT Id, BillingCity, BillingState, BillingStreet
                FROM Account
                WHERE Id IN :accountIds
            ]);
        }
        
        for (Event evt : Trigger.new) {
            if (evt.WhatId != null && accountMap.containsKey(evt.WhatId)) {
                Account acc = accountMap.get(evt.WhatId);
                
                evt.City__c = acc.BillingCity;
                evt.State__c = acc.BillingState;
                evt.Address__c = acc.BillingStreet;
            }
        }
        
    }
}