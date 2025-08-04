trigger IJPTrigger on IJP__c(before insert, before update, after update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {

        Map < Id, Integer > mapIjpIdEventCount = new Map < Id, Integer > ();
        for (AggregateResult result: [SELECT IJP__c, COUNT(Id) cnt FROM Event WHERE IsChild = false GROUP BY IJP__c LIMIT 2000]) {
            mapIjpIdEventCount.put(String.valueOf(result.get('IJP__c')), Integer.valueOf(String.valueOf(result.get('cnt'))));
        }

        for (IJP__c ijp: Trigger.New) {
            ijp.Unique_Key__c = ijp.OwnerId + ' ' + ijp.IJP_Start_Date__c + ' ' + ijp.IJP_End_Date__c;
            System.debug('ijp.Unique_Key__c' + ijp.Unique_Key__c);
            if (mapIjpIdEventCount.containsKey(ijp.Id)) {
                ijp.Event_Count__c = mapIjpIdEventCount.get(ijp.Id);
            } else {
                ijp.Event_Count__c = null;
            }

            if (ijp.IJP_Start_Date__c != null) {
                ijp.IJP_Start_Date__c = Date.newInstance(ijp.IJP_Start_Date__c.year(), ijp.IJP_Start_Date__c.month(), 1);

                Integer numberOfDays = Date.daysInMonth(ijp.IJP_Start_Date__c.year(), ijp.IJP_Start_Date__c.month());
                ijp.IJP_End_Date__c = Date.newInstance(ijp.IJP_Start_Date__c.year(), ijp.IJP_Start_Date__c.month(), numberOfDays);
            }
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        Set < Id > approvedIjpIds = new Set < Id > ();

        for (IJP__c ijp: Trigger.New) {
            if (ijp.Approval_Status__c != Trigger.oldMap.get(ijp.Id).Approval_Status__c) {
                if (ijp.Approval_Status__c == 'Approved' || ijp.Approval_Status__c == 'Rejected' || ijp.Approval_Status__c == 'Submitted') {
                    approvedIjpIds.add(ijp.Id);

                }
            }
        }

        if (approvedIjpIds.size() > 0) {
            List < Event > events = new List < Event > ();

            for (Event ev: [SELECT Id, Approval_Status_IJP__c, Edited_by_Manager__c, IJP__r.Approval_Status__c
                    FROM Event WHERE IJP__c IN: approvedIjpIds AND IsChild = false
                ]) {
                if (ev.IJP__r.Approval_Status__c == 'Rejected') {
                    ev.Approval_Status_IJP__c = 'Rejected';
                    events.add(ev);

                } else if (ev.IJP__r.Approval_Status__c == 'Approved') {
                    if (ev.Edited_by_Manager__c) {
                        ev.Approval_Status_IJP__c = 'Approved but updated by Manager';
                    } else {
                        ev.Approval_Status_IJP__c = 'Approved';
                    }
                    events.add(ev);
                } else if (ev.IJP__r.Approval_Status__c == 'Submitted') {
                    ev.Approval_Status_IJP__c = 'Submitted';
                    events.add(ev);
                }
            }

            if (events.size() > 0) {
                update events;
            }

        }
    }

}