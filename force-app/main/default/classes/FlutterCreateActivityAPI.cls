@RestResource(urlMapping='/flutterCreateActivity')
global class FlutterCreateActivityAPI {
    
    public class ActivityRequest {
        public Id customerId;
        public String visitPurpose;
        public String subject;
        public DateTime activityStartDateTime;
        public DateTime activityEndDateTime;
        public String visitResult;
        public DateTime checkInTime;
        public DateTime checkOutTime;
        public Double checkInGeoLocationLatitude;
        public Double checkInGeoLocationLongitude;
        public Double checkOutGeoLocationLatitude;
        public Double checkOutGeoLocationLongitude;
        public Id whoId;
        public String description;
        public Date activityDate;
        public String activityStatus;
        public String id;

        // public Boolean isAllDay;
        // public String status;
        // public String priority;
        // public String type;
        // public Boolean isReminderSet;
        // public DateTime reminderDateTime;
    }

    public class CustomException extends Exception {}

    @HttpPost
    global static void createActivity() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Initialize API Log
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'FlutterCreateActivity';
        api_log.created_date__c = Datetime.now();

        // Initialize response
        Map<String, Object> responseMap = new Map<String, Object> {
            'success' => false,
            'message' => '',
            'totalActivities' => 0,
            'successfulActivities' => 0,
            'failedActivities' => 0,
            'results' => new List<Map<String, Object>>()
        };

        List<Event> eventsToInsert = new List<Event>();
        List<ActivityRequest> activityRequests = new List<ActivityRequest>();

        try {
            // Get request body and log it
            String requestBody = req.requestBody != null ? req.requestBody.toString() : '';
            api_log.Request__c = requestBody;
            
            if (String.isBlank(requestBody)) {
                responseMap.put('message', 'Request body cannot be empty');
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                api_log.Request__c = responseMap.toString();
                insert api_log;
                return;
            }

            // Deserialize the request
            try {
                // Try to parse as a single activity or an array of activities
                Object parsed = JSON.deserializeUntyped(requestBody);
                if (parsed instanceof List<Object>) {
                    // It's an array of activities
                    activityRequests = (List<ActivityRequest>)JSON.deserialize(
                        requestBody, List<ActivityRequest>.class);
                } else {
                    // It's a single activity
                    activityRequests.add((ActivityRequest)JSON.deserialize(
                        requestBody, ActivityRequest.class));
                }
            } catch (Exception e) {
                responseMap.put('message', 'Invalid request format: ' + e.getMessage());
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                api_log.Request__c = responseMap.toString();
                insert api_log;
                return;
            }

            responseMap.put('totalActivities', activityRequests.size());
            
            // Process each activity request
            for (ActivityRequest activityData : activityRequests) {
                Map<String, Object> result = new Map<String, Object>{
                    'success' => false,
                    'message' => '',
                    'recordId' => null
                };

                try {
                    // Validate required fields
                    if (String.isBlank(activityData.subject)) {
                        throw new CustomException('Subject is required');
                    }
                    
                    // Create new Event record
                    Event newEvent = new Event();
                    if (String.isNotBlank(activityData.id)) {
                        newEvent.Id = activityData.id;
                    } else {
                        newEvent.WhatId = activityData.customerId;
                    }
                    newEvent.Visit_Purpose__c = activityData.visitPurpose != null ? activityData.visitPurpose : '';
                    newEvent.Subject = activityData.subject != null ? activityData.subject : '';
                    newEvent.StartDateTime = activityData.activityStartDateTime != null ? activityData.activityStartDateTime : DateTime.now();
                    newEvent.EndDateTime = activityData.activityEndDateTime != null ? activityData.activityEndDateTime : DateTime.now().addHours(1);
                    newEvent.Visit_Result__c = activityData.visitResult != null ? activityData.visitResult : '';
                    newEvent.Check_In_Time__c = activityData.checkInTime != null ? activityData.checkInTime : null;
                    newEvent.Check_Out_Time__c = activityData.checkOutTime != null ? activityData.checkOutTime : null;
                    newEvent.Check_In_GeoLocation__Latitude__s = activityData.checkInGeoLocationLatitude != null ? activityData.checkInGeoLocationLatitude : null;
                    newEvent.Check_In_GeoLocation__Longitude__s = activityData.checkInGeoLocationLongitude != null ? activityData.checkInGeoLocationLongitude : null;
                    newEvent.Check_Out_GeoLocation__Latitude__s = activityData.checkOutGeoLocationLatitude != null ? activityData.checkOutGeoLocationLatitude : null;
                    newEvent.Check_Out_GeoLocation__Longitude__s = activityData.checkOutGeoLocationLongitude != null ? activityData.checkOutGeoLocationLongitude : null;
                    newEvent.WhoId = activityData.whoId;
                    newEvent.Description = activityData.description != null ? activityData.description : '';
                    newEvent.ActivityDate = activityData.activityDate != null ? activityData.activityDate : Date.today();
                    newEvent.Status__c = activityData.activityStatus != null ? activityData.activityStatus : '';
                    
                    // Activity_Type__c = activityData.activityType,
                    // Type = activityData.type,
                    // Status = activityData.status,
                    // Activity_Sub_Type__c = activityData.activitySubType,
                    // IsReminderSet = activityData.isReminderSet != null ? activityData.isReminderSet : false,
                    // ReminderDateTime = activityData.reminderDateTime,
                    // IsAllDayEvent = activityData.isAllDay != null ? activityData.isAllDay : false,
                    
                    eventsToInsert.add(newEvent);
                    result.put('success', true);
                    result.put('message', 'Event queued for creation');
                    responseMap.put('successfulActivities', (Integer)responseMap.get('successfulActivities') + 1);
                } catch (Exception e) {
                    result.put('message', 'Error: ' + e.getMessage());
                    responseMap.put('failedActivities', (Integer)responseMap.get('failedActivities') + 1);
                }
                
                ((List<Map<String, Object>>)responseMap.get('results')).add(result);
            }
            
            // Separate lists for new and existing events
            List<Event> eventsToUpdate = new List<Event>();
            List<Event> newEventsToInsert = new List<Event>();
            
            // Categorize events
            for (Event evt : eventsToInsert) {
                if (evt.Id != null) {
                    eventsToUpdate.add(evt);
                } else {
                    newEventsToInsert.add(evt);
                }
            }
            
            // Handle inserts
            if (!newEventsToInsert.isEmpty()) {
                List<Database.SaveResult> insertResults = Database.insert(newEventsToInsert, false);
                
                // Process insert results
                for (Integer i = 0; i < insertResults.size(); i++) {
                    Database.SaveResult sr = insertResults[i];
                    Map<String, Object> result = ((List<Map<String, Object>>)responseMap.get('results'))[i];
                    
                    if (sr.isSuccess()) {
                        result.put('recordId', sr.getId());
                        result.put('success', true);
                        result.put('message', 'Activity created successfully');
                    } else {
                        // If the queued operation was successful but the insert failed
                        if ((Boolean)result.get('success')) {
                            responseMap.put('successfulActivities', (Integer)responseMap.get('successfulActivities') - 1);
                            responseMap.put('failedActivities', (Integer)responseMap.get('failedActivities') + 1);
                        }
                        
                        String errorMsg = '';
                        for (Database.Error err : sr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage() + '; ';
                        }
                        result.put('success', false);
                        result.put('message', 'Failed to create event: ' + errorMsg);
                    }
                }
            }
            
            // Handle updates
            if (!eventsToUpdate.isEmpty()) {
                List<Database.SaveResult> updateResults = Database.update(eventsToUpdate, false);
                
                // Process update results
                for (Integer i = 0; i < updateResults.size(); i++) {
                    Database.SaveResult sr = updateResults[i];
                    // For updates, the result index is after all the inserts
                    Integer resultIndex = newEventsToInsert.size() + i;
                    Map<String, Object> result = ((List<Map<String, Object>>)responseMap.get('results'))[resultIndex];
                    
                    if (sr.isSuccess()) {
                        result.put('recordId', sr.getId());
                        result.put('success', true);
                        result.put('message', 'Activity updated successfully');
                    } else {
                        // If the queued operation was successful but the update failed
                        if ((Boolean)result.get('success')) {
                            responseMap.put('successfulActivities', (Integer)responseMap.get('successfulActivities') - 1);
                            responseMap.put('failedActivities', (Integer)responseMap.get('failedActivities') + 1);
                        }
                        
                        String errorMsg = '';
                        for (Database.Error err : sr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage() + '; ';
                        }
                        result.put('success', false);
                        result.put('message', 'Failed to update event: ' + errorMsg);
                    }
                }
            }
            
            // Set final response
            Boolean isSuccess = (Integer)responseMap.get('failedActivities') == 0;
            responseMap.put('success', isSuccess);
            responseMap.put('message', isSuccess ? 
                'All activities processed successfully' : 
                'Some activities failed to process');
                
            res.statusCode = isSuccess ? 201 : 207; // 207 for partial success
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            
        } catch (Exception e) {
            responseMap.put('success', false);
            responseMap.put('message', 'Unexpected error: ' + e.getMessage() + ' at ' + e.getLineNumber());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        } finally {
            // Log the response
            api_log.Request__c = responseMap.toString();
            api_log.Log_Status__c = String.valueOf(res.statusCode);
            api_log.Response__c = JSON.serialize(responseMap);
            
            try {
                insert api_log;
            } catch (Exception e) {
                System.debug('Failed to insert API log: ' + e.getMessage());
            }
        }
    }
    
    /*
    Example cURL request:
    
    POST /services/apexrest/api/FlutterCreateActivityAPI
    Content-Type: application/json
    Authorization: Bearer <your_session_id_or_access_token>
    
    {
        "subject": "Test Activity",
        "description": "This is a test activity",
        "status": "In Progress",
        "priority": "High",
        "type": "Call",
        "whatId": "001XXXXXXXXXXXXXXX",
        "whoId": "003XXXXXXXXXXXXXXX",
        "activityDate": "2023-12-11",
        "isReminderSet": true,
        "reminderDateTime": "2023-12-11T15:30:00Z"
    }
    
    Example Flutter code:
    
    Future<Map<String, dynamic>> createActivity(ActivityRequest request) async {
      final response = await http.post(
        Uri.parse('https://yourinstance.salesforce.com/services/apexrest/api/FlutterCreateActivityAPI'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create activity');
      }
    }
    */
}