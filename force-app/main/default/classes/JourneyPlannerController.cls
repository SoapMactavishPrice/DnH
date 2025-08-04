public class JourneyPlannerController {
    
    private static String queryFields = ' Id, Subject, WhatId, WhoId,ActivityDate, Location, OwnerId, '+
        'StartDateTime, EndDateTime, Approval_Status_IJP__c, Edited_by_Manager__c, '+
        'Event_created_from_Journey_Planner__c, Meeting_Purpose__c,Visit_Purpose__c, Appointment_Taken__c, '+
        'What.Name, Who.Name, Description, ' +
        '(SELECT Id, eventId, Event.WhoId, Event.WhatId, Event.OwnerId, RelationId, Relation.Name from EventRelations) ';
    
    
    @AuraEnabled
    public static String getRoutePlanner() {
        try {

            User usr = [
                SELECT Id, Email, Reporting_Person__c, IsApprovedUser__c, Profile.Name, Area_Manager__c, Code__c
                FROM User WHERE Id =: UserInfo.getUserId()
                // FROM User WHERE Id = '005F30000081bZMIAY'
            ];

            List <Customer_Sales_Person_Mapping__c> cspmList = [
                SELECT Id, Account__c, Sales_Person__c, Sales_Person_Code__c
                FROM Customer_Sales_Person_Mapping__c
                WHERE Account__c != null
                AND Sales_Person_Code__c = :usr.Code__c
            ];

            Set<String> accIdSet = new Set<String>();
            for (Customer_Sales_Person_Mapping__c v : cspmList) {
                accIdSet.add(v.Account__c);
            }

            List <Route_Planner_Junction__c> rpjList = [
                SELECT Account__c, Account__r.Name, Route_Planner__c FROM Route_Planner_Junction__c
                WHERE Route_Planner__c != null
                AND Account__c IN: accIdSet
            ];

            Set<String> rpIdSet = new Set<String>();
            for (Route_Planner_Junction__c va : rpjList) {
                rpIdSet.add(va.Route_Planner__c);
            }

            List<Object> finalList = new List<Object>();
            for(Route_Planner__c rp : [SELECT Id, Name FROM Route_Planner__c WHERE Is_Active__c = true AND Id IN :rpIdSet ORDER BY Name]) {
                finalList.add(new Map<String, String> {'value' => rp.Id, 'label' => rp.Name});
            }
            
            return JSON.serialize(finalList);
        } catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }

    //     @AuraEnabled
    // public static String getIndustryList() {
    //     try {
    //         List<Object> finalList = new List<Object>();
            
    //         for(Lead__c ld : [SELECT Id, Industry_Group__c FROM Lead__c ORDER BY Industry_Group__c]) {
    //             finalList.add(new Map<String, String> {'value' => ld.Id, 'label' => ld.Industry_Group__c});
    //         }
            
    //         return JSON.serialize(finalList);
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describeSObjectResult.fields.getMap();
       
        if (fieldsMap.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> genderEntries = fieldResult.getPicklistValues();
           
            for (Schema.PicklistEntry entry : genderEntries) {
                picklistValues.add(entry.getLabel());
            }
        }
       
        return picklistValues;
    }
    
    @AuraEnabled
    public static List<Industry__c> getIndustryValues(String recordId) {
        try {
            return [SELECT Id, Name FROM Industry__c];
        } catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static IJP__c getIJPRecord(String recordId) {
        try {
            return [SELECT Id, Name, IJP_Start_Date__c, IJP_End_Date__c FROM IJP__c WHERE Id =: recordId];
        } catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean checkIsInApprovalProcess(String currentMonth, String currentYear) {
        try {
            Date dt = Date.newInstance(Integer.valueOf(currentYear), Integer.valueOf(currentMonth)+1, 1);
            IJP__c ijp = [SELECT Id, Approval_Status__c FROM IJP__c WHERE User_Employee__c =: UserInfo.getUserId() AND IJP_Start_Date__c =: dt LIMIT 1];
            if(ijp.Approval_Status__c == 'Submitted') {return true;
            }
            else {return false;
            }
        }
        catch(Exception e) {
            return false;
        }
    }


    @AuraEnabled
    public static String getMainPrincipal() {
        try {
            List<Object> finalList = new List<Object>();
            for(Account rp : [SELECT Id, Name FROM Account  ORDER BY Name]) {
                finalList.add(new Map<String, String> {'value' => rp.Id, 'label' => rp.Name});
            }
            
            return JSON.serialize(finalList);
        } catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    /*
    @AuraEnabled(cacheable=false)
    public static String getCityValues(String routePlannerId, String objName, String selectedStage, String selectedMainPrincipal) {
        String grpByField;
        String routePlannerFilter;

        List<String> selectedStageList = new List<String>();

        switch on objName {
            when 'Lead' {
                routePlannerFilter = ' Route_Planner__c =: routePlannerId ';
                grpByField = 'City';
            }
            when 'Account' {
                routePlannerFilter = ' Route_Planner__c =: routePlannerId ';
                grpByField = 'BillingCity';
            }
            when 'Opportunity' {
                routePlannerFilter = ' Account.Route_Planner__c =: routePlannerId ';
                if(String.isNotBlank(selectedStage)) {
                    selectedStageList = selectedStage.split(',');
                    routePlannerFilter += ' AND StageName IN: selectedStageList ';
                }
                if(String.isNotBlank(selectedMainPrincipal)) {
                    routePlannerFilter += ' AND Main_Principal__c =: selectedMainPrincipal ';
                }
                grpByField = 'Customer_Billing_City__c';
            }
            when 'Order' {
                routePlannerFilter = ' Account.Route_Planner__c =: routePlannerId ';
                grpByField = 'BillingCity';
            }
            when 'Case' {
                routePlannerFilter = ' Account.Route_Planner__c =: routePlannerId ';
                grpByField = 'City__c';
            }
            when 'Asset' {
                routePlannerFilter = ' Account.Route_Planner__c =: routePlannerId ';
                grpByField = 'City__c';
            }
        }
        
        String query = 'SELECT ' + grpByField + ' FROM ' + objName + ' WHERE ' + routePlannerFilter +
            ' AND ' + grpByField + ' != \'\' GROUP BY ' + grpByField + ' ORDER BY ' + grpByField;
        System.debug(query);
        
        List<Object> finalList = new List<Object>();
        Map<String, Object> tempMap = new Map<String, Object>();
        
        for(AggregateResult result : Database.query(query)) {
            tempMap = new Map<String, Object>();
            tempMap.put('id', result.get(grpByField));
            tempMap.put('title', result.get(grpByField));
            tempMap.put('isSelected', false);
            finalList.add(tempMap);
        }
        
        if(finalList.size() > 0) {
            tempMap = new Map<String, Object>();
            tempMap.put('id', 'selectAll');
            tempMap.put('title', 'Select All');
            tempMap.put('isSelected', false);
            finalList.add(0, tempMap);
        }
        
        return JSON.serialize(finalList);
    }
    */
    
    
    @AuraEnabled(cacheable=false)
    public static List<Object> getRecords(String routePlannerId, String objApiName, String selectedStage, String selectedMainPrincipal, String cityList, string selectedindustry) {
        try {
            if(String.isBlank(objApiName))
                throw new AuraHandledException('Please select target object to fetch records');

            String query = '';
            String whr = '';
            String ordBy = '';
            String nameField = '';
            String cityField = '';

            List<String> selectedStageList = new List<String>();
            
            List<String> cityNames = cityList.split(',');
            
            List<String> industryname = new List<String>();
            
            switch on objApiName {
                when 'Lead__c' {
                    query = 'SELECT Id, Name, Industry__c ';
                    nameField = 'Name';
                    cityField = 'Industry__c';
                    whr += ' WHERE Industry__c =: selectedindustry AND Industry__c != \'\'';
                    ordBy = ' ORDER BY Name ';
                }  
             /*    when 'Lead__c' {
                    query = 'SELECT Id, Name, Industry_Group__c ';
                    nameField = 'Name';
                    cityField = 'Industry_Group__c';
                    ordBy = ' ORDER BY Name,Last_Name__c ';
                }  */
                when 'Account' {
                    query = 'SELECT Id, Name, BillingCity ';
                    nameField = 'Name';
                    cityField = 'BillingCity';
                    whr += ' WHERE Id IN (SELECT Account__c FROM Route_Planner_Junction__c WHERE Route_Planner__c =: routePlannerId AND Account__c != \'\')';
                    ordBy = ' ORDER BY Name ';
                }
                 when 'Contact' {
                    query = 'SELECT Id, Name,MailingCity ';
                    nameField = 'Name';
                    cityField = 'MailingCity';
                    whr += ' WHERE ID IN (SELECT Contact__c FROM Route_Planner_Junction__c WHERE Route_Planner__c =: routePlannerId AND Contact__c != \'\')';
                    ordBy = ' ORDER BY Name ';
                }  
         /*       when 'Opportunity__c' {
                    query = 'SELECT Id, Name, Customer_Billing_City__c, Stage_Name__c,Main_Principal__r.Name';
                    nameField = 'Name';
                    cityField = 'Customer_Billing_City__c';
                    whr += ' WHERE AccountId__c IN (SELECT Account__c FROM Route_Planner_Junction__c WHERE Route_Planner__c =: routePlannerId AND Account__c != \'\')';
                    if(String.isNotBlank(selectedStage)) {
                        selectedStageList = selectedStage.split(',');
                        whr += ' AND Stage_Name__c IN: selectedStageList ';
                    }
                    if(String.isNotBlank(selectedMainPrincipal)) {
                        whr += ' AND Main_Principal__c =: selectedMainPrincipal ';
                    }
                    ordBy = ' ORDER BY Name ';
                }
                when 'Order__c' {
                    query = 'SELECT Id, Name, BillingCity__c,Main_Principal__r.Name';
                    nameField = 'Name';
                    cityField = 'BillingCity__c';
                    whr += ' WHERE AccountId__c IN (SELECT Account__c FROM Route_Planner_Junction__c WHERE Route_Planner__c =: routePlannerId AND Account__c != \'\')';
                    ordBy = ' ORDER BY Name ';
                }
                when 'Case__c' {
                    query = 'SELECT Id, CaseNumber__c, City__c, AssetId__r.Name ';
                    nameField = 'CaseNumber__c';
                    cityField = 'City__c';
                    whr += ' WHERE AccountId__c IN (SELECT Account__c FROM Route_Planner_Junction__c WHERE Route_Planner__c =: routePlannerId AND Account__c != \'\')';
                    ordBy = ' ORDER BY CaseNumber__c ';
                }
                when 'Asset__c' {
                    query = 'SELECT Id, Name, City__c ';
                    nameField = 'Name';
                    cityField = 'City__c';
                    whr += ' WHERE Id IN (SELECT Asset1__c FROM Route_Planner_Junction__c WHERE Route_Planner__c =: routePlannerId AND Asset1__c != \'\')';
                    ordBy = ' ORDER BY Name ';
                } */
            }
            query += ' FROM '+objApiName+' ';
            
            List<Object> finalList = new List<Object>();
            for(sObject rec : Database.query(query + whr + ordBy)) {
                Map<String, Object> tempMap = new Map<String, Object>();
                tempMap.put('Id', rec.Id);
                tempMap.put('Name', rec.get(nameField));
                tempMap.put('CityName__c', rec.get(cityField));
         /*       if(objApiName == 'Opportunity__c') {
                    tempMap.put('Stage_Name__c', rec.get('Stage_Name__c'));
                    if(rec.getSobject('Main_Principal__r') != null) {
                        tempMap.put('Principal__c', rec.getSobject('Main_Principal__r').get('Name'));
                    }
                }
                if(objApiName == 'Order__c') {
                    if(rec.getSobject('Main_Principal__r') != null) {
                        tempMap.put('Principal__c', rec.getSobject('Main_Principal__r').get('Name'));
                    }
                }
                if(objApiName == 'Case__c') {
                    if(rec.getSobject('Asset__c') != null) {
                        tempMap.put('AssetName', rec.getSobject('AssetId__c').get('Name'));
                    }
                }    */
                
                finalList.add(tempMap);
            }
            return finalList;
        }
        catch (Exception e) {
        String errorMessage = 'Error on line ' + e.getLineNumber() + ': ' + e.getMessage();
        System.debug('Exception caught: ' + errorMessage);
        System.debug('Stack Trace: ' + e.getStackTraceString());
        throw new AuraHandledException(errorMessage);
    }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static string getEventsForCurrentMonth(String currentYear, String currentMonth, String ijpId) {
        try {            
            String userId;
            String filter = '';
            if(String.isNotBlank(ijpId)) {
                IJP__c ijpRecord = [SELECT Id, Name, IJP_Start_Date__c, IJP_End_Date__c, User_Employee__c
                                    FROM IJP__c WHERE Id =: ijpId];
                filter = ' WHERE IsChild = false AND (IJP__c =: ijpId OR (OwnerId =: userId AND ActivityDate >=: firstDt AND ActivityDate <=: lastDt)) ';
            } else {
                userId = UserInfo.getUserId();
                
                Date firstDt = Date.newInstance(Integer.valueOf(currentYear), Integer.valueOf(currentMonth), 1);
                Date lastDt = Date.newInstance(Integer.valueOf(currentYear), Integer.valueOf(currentMonth), Date.daysInMonth(firstDt.year(), firstDt.month()));

                filter = ' WHERE OwnerId =: userId AND ActivityDate >=: firstDt AND ActivityDate <=: lastDt ';
            }
            String query = 'SELECT ' + queryFields +
                'FROM Event '+
                 filter +
                'ORDER BY StartDateTime, Subject';
            
            Map<Integer, List<Object>> mapDateWiseEvents = new Map<Integer, List<Object>>();
            
            for(Event ev : Database.query(query)) {
                System.debug(ev);
                if(mapDateWiseEvents.containsKey(ev.ActivityDate.day())) {
                    mapDateWiseEvents.get(ev.ActivityDate.day()).add(getEventMapForJSON(ev));
                }
                else {
                    mapDateWiseEvents.put(ev.ActivityDate.day(), new List<Object> {getEventMapForJSON(ev)});
                }
            }
            
            return JSON.serialize(mapDateWiseEvents);
            
        } catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=false)
    public static string generateEvent(String entityData, String selectedDate) {
        try {
            Map<String, Object> entityDataMap = (Map<String, Object>) JSON.deserializeUntyped(entityData);
            Map<String, Object> selectedDateMap = (Map<String, Object>) JSON.deserializeUntyped(selectedDate);
            Date selectedDateDate = Date.newInstance(Integer.valueOf(selectedDateMap.get('year')),
                                                     Integer.valueOf(selectedDateMap.get('month')) + 1,
                                                     Integer.valueOf(selectedDateMap.get('day')));
            Datetime startDateTime = DateTime.newInstance(Integer.valueOf(selectedDateMap.get('year')),
                                                          Integer.valueOf(selectedDateMap.get('month')) + 1,
                                                          Integer.valueOf(selectedDateMap.get('day')),
                                                          10, 0, 0);
            Datetime endDateTime = DateTime.newInstance(Integer.valueOf(selectedDateMap.get('year')),
                                                        Integer.valueOf(selectedDateMap.get('month')) + 1,
                                                        Integer.valueOf(selectedDateMap.get('day')),
                                                        11, 0, 0);
            
            Event ev				=		new Event();
            ev.Subject				=		String.valueOf('Face to Face');
            
            switch on String.valueOf(Id.valueOf(String.valueOf(entityDataMap.get('Id'))).getSObjectType()) {
                when 'Lead__c' {
                    System.debug('Lead ID: ' + String.valueOf(entityDataMap.get('Id')));
                    ev.WhatId		=		String.valueOf(entityDataMap.get('Id'));
                    ev.Location		=		String.valueOf(entityDataMap.get('City__c'));
                }
                when 'Account' {
                    ev.WhatId		=		String.valueOf(entityDataMap.get('Id'));
                    ev.Location		=		String.valueOf(entityDataMap.get('BillingCity'));
                }
                when 'Contact' {
                    ev.WhoID		=		String.valueOf(entityDataMap.get('Id'));
                    ev.Location		=		String.valueOf(entityDataMap.get('MailingCity'));
                }
         /*       when 'Opportunity__c' {
                    ev.WhatId		=		String.valueOf(entityDataMap.get('Id'));
                    ev.Location		=		String.valueOf(entityDataMap.get('Customer_Billing_City__c'));
                }
                when 'Order__c' {
                    ev.WhatId		=		String.valueOf(entityDataMap.get('Id'));
                    ev.Location		=		String.valueOf(entityDataMap.get('Billing_City__c'));
                }
                when 'Case__c' {
                    ev.WhatId		=		String.valueOf(entityDataMap.get('Id'));
                    ev.Location		=		String.valueOf(entityDataMap.get('City__c'));
                }
                when 'Asset__c' {
                    ev.WhatId		=		String.valueOf(entityDataMap.get('Id'));
                    ev.Location		=		String.valueOf(entityDataMap.get('City__c'));
                }    */
            }
            
            ev.Event_created_from_Journey_Planner__c = true;
            ev.OwnerId = UserInfo.getUserId();
            ev.Type = 'Meeting';
            ev.ActivityDate			=	selectedDateDate;
            ev.StartDateTime		=	startDateTime;
            ev.Start_Date_Time__c	=	startDateTime;
            ev.EndDateTime			=	endDateTime;
            ev.End_Date_Time__c		=	endDateTime;
            ev.DurationInMinutes	=	60;
            ev.Status__c			=	'Open';
            
            try {
                
                IJP__c ijp = [SELECT Id,Name, Approval_Status__c FROM IJP__c
                              WHERE User_Employee__c =: ev.OwnerId AND
                              IJP_Start_Date__c <=: ev.ActivityDate AND
                              IJP_End_Date__c >=: ev.ActivityDate];
         
                if(ijp.Approval_Status__c == 'Approved') {throw new CustomException('You are not allowed to create new IJP events post Approval');
                }  
            } catch(Exception e) {
                System.debug('Error ' + e);
            }
            
            insert ev;
            
            
            return getSingleEvent(ev.Id);
            
        }
        catch (DMLException e) {            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch(CustomException e) {            throw new AuraHandledException(e.getMessage());
        }
        catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=false)
    public static string getSingleEvent(String eventId) {
        try {
            Event ev = Database.query('SELECT ' + queryFields + ' FROM Event WHERE Id =: eventId');
            
            return JSON.serialize(getEventMapForJSON(ev));
        }
        catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static string updateEventDragDrop(String eventId, String diffInNewDays) {
        try {
            event ev = [SELECT Id, ActivityDate, OwnerId, Edited_by_Manager__c, End_Date_Time__c, Start_Date_Time__c,
                        StartDateTime, EndDateTime
                        FROM Event
                        WHERE Id =: eventId];
            ev.ActivityDate 			=	ev.ActivityDate.addDays(Integer.valueOf(diffInNewDays));
            ev.StartDateTime			=	ev.StartDateTime.addDays(Integer.valueOf(diffInNewDays));
            ev.Start_Date_Time__c		=	ev.StartDateTime;
            ev.EndDateTime				=	ev.EndDateTime.addDays(Integer.valueOf(diffInNewDays));
            ev.End_Date_Time__c			=	ev.EndDateTime;
            ev.Approval_Status_IJP__c   =   '';
            if(ev.OwnerId != UserInfo.getUserId()) {
                ev.Edited_by_Manager__c = true;
            }
            if(ev.OwnerId == UserInfo.getUserId()) {
                ev.Edited_by_Manager__c = false;
            }
            
            update ev;
            
            return getSingleEvent(ev.Id);
            
        }
        catch (DMLException e) {            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=false)
    public static string updateEvent(String eventData) {
        System.debug(eventData);
        try {
            Map<String, Object> mapEvent = (Map<String, Object>) JSON.deserializeUntyped(eventData);

            Event ev = new Event();
            ev.Id					=		String.valueOf(mapEvent.get('Id'));
            ev.OwnerId				=		String.valueOf(mapEvent.get('OwnerId'));
            if(ev.OwnerId != UserInfo.getUserId()) {
                ev.Edited_by_Manager__c = true;
            }
            if(ev.OwnerId == UserInfo.getUserId()) {
                ev.Edited_by_Manager__c = false;
            }


            ev.Subject				=		String.valueOf(mapEvent.get('Subject'));
            ev.WhoId				=		String.valueOf(mapEvent.get('WhoId'));
            ev.WhatId				=		String.valueOf(mapEvent.get('WhatId'));
           /* ev.WhatId__c			=		String.valueOf(mapEvent.get('WhatId__c'));
            ev.WhatId_Order__c		=		String.valueOf(mapEvent.get('WhatId_Order_c'));
            ev.WhatId_Case__c		=		String.valueOf(mapEvent.get('WhatId_Case_c'));
            ev.WhatId_Asset__c		=		String.valueOf(mapEvent.get('WhatId_Asset_c')); */
            ev.Description          =       String.valueOf(mapEvent.get('Description'));
			ev.Meeting_Purpose__c	=		String.valueOf(mapEvent.get('Meeting_Purpose__c'));
            ev.Visit_Purpose__c	=			String.valueOf(mapEvent.get('Visit_Purpose__c'));
			ev.Appointment_Taken__c	=		String.valueOf(mapEvent.get('Appointment_Taken__c'));
            ev.StartDateTime		=		DateTime.valueOfGMT(String.valueOf(mapEvent.get('StartDateTime')).replace('T', ' '));
            ev.Start_Date_Time__c	=		DateTime.valueOfGMT(String.valueOf(mapEvent.get('StartDateTime')).replace('T', ' '));
            ev.EndDateTime			=		DateTime.valueOfGMT(String.valueOf(mapEvent.get('EndDateTime')).replace('T', ' '));
            ev.End_Date_Time__c		=		DateTime.valueOfGMT(String.valueOf(mapEvent.get('EndDateTime')).replace('T', ' '));

            if(Date.valueOf(String.valueOf(mapEvent.get('ActivityDateOriginal'))) != Date.valueOf(String.valueOf(mapEvent.get('StartDateTime')))) {
                ev.Approval_Status_IJP__c = '';
            }	

            update ev;
            
            List<EventRelation> eventAttendees = new List<EventRelation>();
            List<Object> attendees = (List<Object>) mapEvent.get('Attendees');
            for(Object attendee : attendees) {
                Map<String, Object> mapAttendee = (Map<String, Object>) attendee;
                EventRelation er = new EventRelation();
                er.eventId = String.valueOf(mapEvent.get('Id'));
                er.RelationId = String.valueOf(mapAttendee.get('Id'));
                
                eventAttendees.add(er);
            }

            Database.insert(eventAttendees, false);
            
            return getSingleEvent(ev.Id);
        }
        catch (DMLException e) {            throw new AuraHandledException(e.getDmlMessage(0));
        }
       catch (Exception e) {
        String errorMessage = 'Error on line ' + e.getLineNumber() + ': ' + e.getMessage();
        System.debug('Exception caught: ' + errorMessage);
        System.debug('Stack Trace: ' + e.getStackTraceString());
        throw new AuraHandledException(errorMessage);
    }
    }
    
    
    @AuraEnabled(cacheable=false)
    public static string deleteEvent(String eventId) {
        try {
            Event ev = new Event(Id = eventId);
            delete ev;
            
            return '';
        }
        catch (DMLException e) {            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch (Exception e) {            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static string submitForApproval(String currentYear, String currentMonth, String comment) {
        try {
            Id userId = UserInfo.getUserId();
            Date firstDt = Date.newInstance(Integer.valueOf(currentYear), Integer.valueOf(currentMonth), 1);
            Date lastDt = Date.newInstance(Integer.valueOf(currentYear), Integer.valueOf(currentMonth), Date.daysInMonth(firstDt.year(), firstDt.month()));
            
            IJP__c ijp = [SELECT Id, Name
						  FROM IJP__c
                          WHERE User_Employee__c =: userId AND IJP_Start_Date__c >=: firstDt AND IJP_End_Date__c <=: lastDt];
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(comment);
            req1.setObjectId(ijp.Id);
            req1.setSubmitterId(userId);
            Approval.process(req1);
            
            return '';
        } catch (DMLException e) {            throw new AuraHandledException(e.getDmlMessage(0));		
        } catch (Exception e) {            throw new AuraHandledException(e.getMessage());
        }
    }		
    
    
    private static Map<String, Object> getEventMapForJSON(Event ev) {
        Map<String, Object> tempMap = new Map<String, Object>();
        tempMap.put('Id', ev.Id);
        if(String.isNotBlank(ev.What.Name)) {
            tempMap.put('Title', ev.What.Name);
        }
        else if(String.isNotBlank(ev.Who.Name)) {
            tempMap.put('Title', ev.Who.Name);
        }
        else {
            tempMap.put('Title', ev.Subject);
        }
        tempMap.put('Subject', ev.Subject);
        tempMap.put('WhatId', ev.WhatId);
      /*  tempMap.put('WhatId__c', ev.WhatId__c);
        tempMap.put('WhatId_Asset__c', ev.WhatId_Asset__c);
        tempMap.put('WhatId_Case__c', ev.WhatId_Case__c);
        tempMap.put('WhatId', ev.WhatId_Order__c); */
        tempMap.put('WhoId', ev.WhoId);
        tempMap.put('ActivityDate', ev.ActivityDate);
        tempMap.put('ActivityDateOriginal', ev.ActivityDate);
        tempMap.put('Location', ev.Location);
        tempMap.put('OwnerId', ev.OwnerId);
        tempMap.put('Description', ev.Description);
		tempMap.put('Meeting_Purpose__c', ev.Meeting_Purpose__c);
        tempMap.put('Visit_Purpose__c', ev.Visit_Purpose__c);
		tempMap.put('Appointment_Taken__c', ev.Appointment_Taken__c);
        tempMap.put('StartDateTime', ev.StartDateTime);
        tempMap.put('EndDateTime', ev.EndDateTime);

        tempMap.put('StartTime', Datetime.valueOfGmt(String.valueOf(ev.get('StartDateTime'))).format('HH:mm'));
        tempMap.put('EndTime', Datetime.valueOfGmt(String.valueOf(ev.get('EndDateTime'))).format('HH:mm'));
        tempMap.put('eventClass', getStyleClassName(ev));
        if(String.isNotBlank(ev.WhatId)) {
            tempMap.put('watermark', ev.WhatId.getSObjectType().getDescribe().getLabel());
        }
    /*    else if(String.isNotBlank(ev.WhatId__c)) {
            tempMap.put('watermark', ev.WhatId__c.getSObjectType().getDescribe().getLabel());
        }
        
        else if(String.isNotBlank(ev.WhatId_Order__c)) {
            tempMap.put('watermark', ev.WhatId_Order__c.getSObjectType().getDescribe().getLabel());
        }
        else if(String.isNotBlank(ev.WhatId_Case__c)) {
            tempMap.put('watermark', ev.WhatId_Case__c.getSObjectType().getDescribe().getLabel());
        }
        else if(String.isNotBlank(ev.WhatId_Asset__c)) {
            tempMap.put('watermark', ev.WhatId_Asset__c.getSObjectType().getDescribe().getLabel());
        }    */
        
        else if(String.isNotBlank(ev.WhoId)) {
            tempMap.put('watermark', ev.WhoId.getSObjectType().getDescribe().getLabel());
        }
        
        
        tempMap.put('Attendees', new List<Object>());
        for(EventRelation ea : ev.EventRelations) {
            if(tempMap.get('Title') == 'ATS Group') {
                System.debug('ea : ' + ea + ea.Relation.Name);
            }
            if(ea.RelationId == ea.Event.WhatId || ea.RelationId == ea.Event.WhoId || ea.RelationId == ea.Event.OwnerId) {
                System.debug(ea.RelationId);
                System.debug(ea.Event.WhatId);
                System.debug(ea.Event.WhoId);
                System.debug(ea.Event.OwnerId);
            }
            else {
                ((List<Object>) tempMap.get('Attendees')).add(
                    new Map<String, String> {
                        'Id' => ea.RelationId,
                        'Name' => ea.Relation.Name
                    }
                );
            }
        }
        
        return tempMap;
    }
    
    
    public static string getStyleClassName(Event ev) {
        if(!ev.Event_created_from_Journey_Planner__c) {
            return 'created-outside';
        }
        
        switch on ev.Approval_Status_IJP__c {
            when null, '', 'Submitted' {
                return 'none-submitted';
            }
            when 'Approved' {
                return 'approved';
            }
            when 'Approved but updated by Manager' {
                return 'approved-and-edited';
            }
            when 'Rejected' {
                return 'rejected';
            }
        }	
        
        return '';
    }
    
    
    
    private class CustomException extends Exception {}
    
}