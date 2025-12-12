public with sharing class VisitRouteController {

    public class RoutePoint {
        @AuraEnabled public Double lat;
        @AuraEnabled public Double lng;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
    }

    // If userId is null, we use current logged-in user
    @AuraEnabled(cacheable=true)
    public static List<RoutePoint> getDailyRoute(Id userId, Date routeDate) {
        if (userId == null) {
            userId = UserInfo.getUserId();
        }

        DateTime startDt = DateTime.newInstance(routeDate, Time.newInstance(0,0,0,0));
        DateTime endDt   = startDt.addDays(1);

        List<Event> visits = [
            SELECT Id, Subject,
                   Check_In_GeoLocation__Latitude__s,
                   Check_In_GeoLocation__Longitude__s,
                   Check_In_Time__c
            FROM Event
            WHERE OwnerId = :userId
              AND Check_In_Time__c >= :startDt
              AND Check_In_Time__c <  :endDt
              AND Check_In_GeoLocation__Latitude__s  != null
              AND Check_In_GeoLocation__Longitude__s != null
            ORDER BY Check_In_Time__c ASC
        ];

        List<RoutePoint> result = new List<RoutePoint>();
        Integer i = 1;
        for (Event v : visits) {
            RoutePoint p = new RoutePoint();
            p.lat  = v.Check_In_GeoLocation__Latitude__s;
            p.lng  = v.Check_In_GeoLocation__Longitude__s;
            p.label = i + '. ' + v.Subject;
            p.description = (v.Check_In_Time__c == null)
                ? ''
                : 'Time: ' + v.Check_In_Time__c.format('HH:mm');
            result.add(p);
            i++;
        }
        return result;
    }
}