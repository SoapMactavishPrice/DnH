public with sharing class lwcEventCheckInOutController {
    public lwcEventCheckInOutController() {

    }

     @AuraEnabled
    public static string updateCheckIn(String recordId, Decimal latitude, Decimal longitude) {
        try {
            Event ev = new Event();
            ev.Id = recordId;

            ev.Check_In_GeoLocation__Latitude__s = latitude;
            ev.Check_In_GeoLocation__Longitude__s = longitude;
            ev.Check_In_Time__c = System.now();

            update ev;

            return 'Success';
        } catch (Exception e) {
            System.debug(e);
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
     
      @AuraEnabled
    public static string updateEventRecord(String recordId, Decimal latitude, Decimal longitude) {
        try {
            Event ev = new Event();
            ev.Id = recordId;

            ev.Check_In_GeoLocation__Latitude__s = latitude;
            ev.Check_In_GeoLocation__Longitude__s = longitude;
            ev.Check_In_Time__c = System.now();

            update ev;

            return 'Success';
        } catch (Exception e) {
            System.debug(e);
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateCheckOut(String recordId, Decimal latitude, Decimal longitude,String VisitResult,String Description,String Client_Feedback_Or_Insights,String Action_To_Do) {
        
        try {
             if (String.isBlank(recordId)) {throw new AuraHandledException('Event record ID is required.');
        }
            Event ev = new Event();
            ev.Id = recordId;

            ev.Check_Out_GeoLocation__Latitude__s = latitude;
            ev.Check_Out_GeoLocation__Longitude__s = longitude;
            ev.Check_Out_Time__c = System.now();
            ev.Visit_Result__c = VisitResult;
            ev.Description = Description;
            ev.Client_Feedback_Or_Insights__c = Client_Feedback_Or_Insights;
            ev.Action_To_Do__c = Action_To_Do;
            //ev.Action_Date_And_Time__c = System.now();


            //  for (String key : formData.keySet()) {
            //      ev.put(key, formData.get(key));
            // }

            update ev;

            return 'Success';
        } catch (Exception e) {
            System.debug(e);
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Event getEventById(Id recordId) {
        // Query the Event record dynamically based on recordId

       return [SELECT Id,Check_In_Time__c,Check_Out_Time__c, Visit_Result__c, Description, Client_Feedback_Or_Insights__c, Action_To_Do__c, Action_To_Do_Date__c,WhatId,AccountId FROM Event WHERE Id = :recordId];
    }


    @AuraEnabled
    public static Event updateEventById(Id recordId ,Map<String, Object> formData) {
        // List<Object> lineListdata = (List<Object>) JSON.deserializeUntyped(porLineItemList);
        
       try {  
                Event ev = [SELECT Id FROM Event WHERE Id = :recordId LIMIT 1];

    //     Event ev = new Event();
    //     ev.Id = recordId;
    //     ev.Visit_Result__c = 'VisitResult';
    //     ev.Description = 'Description';
    //     ev.Client_Feedback_Or_Insights__c = 'Client_Feedback_Or_Insights';
    //     ev.Action_To_Do__c = 'Action_To_Do';
    //    ev.Action_To_Do_Date__c = 'Action_To_Do_Date';
    for (String fieldName : formData.keySet()) {
            Object fieldValue = formData.get(fieldName);
            
            // Check the field type before assigning (assuming all are Strings for simplicity)
            if (fieldValue != null) {
                ev.put(fieldName, fieldValue);
            }
        }
        update ev;
        
        return ev;
        } catch (Exception e) {
            System.debug(e);
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }

   
    @AuraEnabled
    public static List<Contact> getContacts(String accId) {
        return [SELECT Id, Name FROM Contact WHERE AccountId =:accId];
    }

    @AuraEnabled
    public static String getdepartment(String conId) {
        Contact con=[SELECT Id, Name,Department__c,Department__r.Name FROM Contact WHERE Id =:conId];
        Map<String,String> mpRes=new Map<String,String>();
        mpRes.put('departmentId',con.Department__c);
        mpRes.put('departmentName',con.Department__c!=null ?con.Department__r.Name:'');
        return JSON.serialize(mpRes) ;
    
    }

    @AuraEnabled
    public static Boolean saveMeetingAttendees(List<Map<String, Object>> meetingDetails,String eventid,String accId) {
        try{
        List<Meeting_Attendee__c> attendees = new List<Meeting_Attendee__c>();
        List<Contact> contactList = new List<Contact>();

        for (Map<String, Object> detail : meetingDetails) {
            if((String)detail.get('contactType') =='Existing'){
                attendees.add(new Meeting_Attendee__c(
                    Contact__c = (String)detail.get('contact'),
                    Department__c = (String)detail.get('departmentId'),
                    Next_Follow_Up_Date__c = (String)detail.get('followUpDate')!=''? Date.valueOf((String)detail.get('followUpDate')):null,
                    Meeting_Description__c = (String)detail.get('description'),
                    EventId__c = eventid,
                    Account__c=accId
                ));
            }else{
                Contact con= new Contact();
                   con.FirstName = (String)detail.get('firstName');
                   con.LastName = (String)detail.get('lastName');
                   con.Email = (String)detail.get('Email');
                   con.MobilePhone = (String)detail.get('Mobile');
                  con.Department__c = (String)detail.get('departmentId');
                   con.AccountId=accId;
               Insert con;

                attendees.add(new Meeting_Attendee__c(
                    Contact__c = con.Id,
                    First_Name__c = (String)detail.get('firstName'),
                    Last_Name__c = (String)detail.get('lastName'),
                    Email__c = (String)detail.get('Email'),
                    Mobile__c = (String)detail.get('Mobile'),
                    Department__c = (String)detail.get('departmentId'),
                    Next_Follow_Up_Date__c = (String)detail.get('followUpDate')!=''? Date.valueOf((String)detail.get('followUpDate')):null,
                    Meeting_Description__c = (String)detail.get('description'),
                    EventId__c = eventid,
                    Account__c=accId
                ));
            }
        }

        insert attendees;
        insert contactList;
        return true;
        }catch(Exception e){
            return false;
        }
    
    }

    @AuraEnabled(cacheable=true)
    public static List<Meeting_Attendee__c> getMeetingAttendees(String meetingId) {
        // Query for attendees based on the meeting ID
        return [SELECT Id, Name, Start_Date_Time__c, End_Date_Time__c,Contact_Name__c , Meeting_Description__c , Next_Follow_Up_Date__c
                FROM Meeting_Attendee__c 
                WHERE EventId__c = :meetingId];
    }


}