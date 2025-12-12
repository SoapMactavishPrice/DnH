@RestResource(urlMapping='/flutterGetActivities')
global class FlutterGetActivitiesAPI {
    
    public class ActivityResponse {
        public Boolean success;
        public String message;
        public List<Map<String, Object>> events;
        public Integer totalRecords;
    }
    
    public class EventWrapper {
        public String customerId;
        public String visitPurpose;
        public String subject;
        public DateTime activityStartDateTime;
        public DateTime activityEndDateTime;
        public String visitResult;
        public DateTime checkInTime;
        public DateTime checkOutTime;
        public Decimal checkInGeoLocationLatitude;
        public Decimal checkInGeoLocationLongitude;
        public Decimal checkOutGeoLocationLatitude;
        public Decimal checkOutGeoLocationLongitude;
        public String description;
        public Date activityDate;
        public String activityStatus;
        public String id;
        
        public EventWrapper(Event evt) {
            this.customerId = evt.WhatId;
            this.visitPurpose = evt.Visit_Purpose__c;
            this.subject = evt.Subject;
            this.activityStartDateTime = evt.StartDateTime;
            this.activityEndDateTime = evt.EndDateTime;
            this.visitResult = evt.Visit_Result__c;
            this.checkInTime = evt.Check_In_Time__c;
            this.checkOutTime = evt.Check_Out_Time__c;
            this.checkInGeoLocationLatitude = evt.Check_In_GeoLocation__Latitude__s;
            this.checkInGeoLocationLongitude = evt.Check_In_GeoLocation__Longitude__s;
            this.checkOutGeoLocationLatitude = evt.Check_Out_GeoLocation__Latitude__s;
            this.checkOutGeoLocationLongitude = evt.Check_Out_GeoLocation__Longitude__s;
            this.description = evt.Description;
            this.activityDate = evt.ActivityDate;
            this.activityStatus = evt.Status__c;
            this.id = evt.Id;
        }
        
        public Map<String, Object> toMap() {
            return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(this));
        }
    }

    @HttpGet
    global static void getUpcomingEvents() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Initialize response
        ActivityResponse response = new ActivityResponse();
        response.success = false;
        response.events = new List<Map<String, Object>>();
        
        try {
            // Get query parameters with defaults
            String salesPersonCode = req.params.get('salesPersonCode');
            
            // Validate salesPersonCode if provided
            if (req.params.containsKey('salesPersonCode') && String.isBlank(salesPersonCode)) {
                response.success = false;
                response.message = 'salesPersonCode parameter cannot be blank';
                response.events = new List<Map<String, Object>>();
                response.totalRecords = 0;
                
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(response, true));
                return;
            }
            
            // Build dynamic query
            String query = 'SELECT Id, Subject, ActivityDate, StartDateTime, EndDateTime, ' +
                         'Visit_Purpose__c, Visit_Result__c, Status__c, Description, ' +
                         'WhatId, What.Name, WhoId, Who.Name, ' +
                         'Check_In_Time__c, Check_Out_Time__c, ' +
                         'Check_In_GeoLocation__Latitude__s, Check_In_GeoLocation__Longitude__s, ' +
                         'Check_Out_GeoLocation__Latitude__s, Check_Out_GeoLocation__Longitude__s ' +
                         'FROM Event ' +
                         'WHERE EndDateTime >= TODAY AND Status__c = \'Open\'';
            
            // Query for user with the given salesPersonCode if provided
            Id ownerId = null;
            if (String.isNotBlank(salesPersonCode)) {
                List<User> salesUsers = [SELECT Id FROM User WHERE Code__c = :salesPersonCode LIMIT 1];
                if (!salesUsers.isEmpty()) {
                    ownerId = salesUsers[0].Id;
                    query += ' AND OwnerId = :ownerId ';
                } else {
                    // If no user found with the code, return empty result
                    response.success = true;
                    response.message = 'No sales person found with code: ' + salesPersonCode;
                    response.events = new List<Map<String, Object>>();
                    response.totalRecords = 0;
                    
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(JSON.serialize(response, true));
                    return;
                }
            }
            
            // Add order by
            query += ' ORDER BY EndDateTime ASC ';
            
            // Execute query for events
            List<Event> events = Database.query(query);
            
            // Query for total count
            String countQuery = 'SELECT COUNT() FROM Event WHERE EndDateTime >= TODAY AND Status__c = \'Open\'';
            if (ownerId != null) {
                countQuery += ' AND OwnerId = :ownerId';
            }
            Integer totalRecords = Database.countQuery(countQuery);
            
            // Prepare response
            response.success = true;
            response.message = 'Successfully retrieved upcoming events';
            // Convert events to the desired format
            List<Map<String, Object>> formattedEvents = new List<Map<String, Object>>();
            for(Event evt : events) {
                formattedEvents.add(new EventWrapper(evt).toMap());
            }
            response.events = formattedEvents;
            response.totalRecords = totalRecords;
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response, true));
            
        } catch (Exception e) {
            // Handle any errors
            response.success = false;
            response.message = 'Error: ' + e.getMessage();
            response.events = new List<Map<String, Object>>();
            
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(response, true));
        }
    }
}