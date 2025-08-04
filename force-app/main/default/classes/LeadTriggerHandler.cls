public class LeadTriggerHandler {
    
    public static void updateLeadAddresses(List<Lead__c> newLeads) {
        
        Set<Id> postalCodeIds = new Set<Id>();
        Set<Id> areaIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        
        // Collect all relevant IDs from the leads being processed
        for (Lead__c lead : newLeads) {
            if (lead.Pin_Code__c  != null) {
                postalCodeIds.add(lead.Pin_Code__c );
            }
            if (lead.Area_Name__c != null) {
                areaIds.add(lead.Area_Name__c );
            }
            if (lead.City__c != null) {
                cityIds.add(lead.City__c);
            }
            if (lead.State__c != null) {
                stateIds.add(lead.State__c);
            }
        }
        
        // Query the related records
        Map<Id, Pin_Code__c > postalCodeMap = new Map<Id, Pin_Code__c>(
            [SELECT Id, Area__c, Area__r.City__c, Area__r.City__r.State__c, Area__r.City__r.State__r.Country__c 
             FROM Pin_Code__c  WHERE Id IN :postalCodeIds]
        );
        Map<Id, Area__c> areaMap = new Map<Id, Area__c>(
            [SELECT Id, City__c, City__r.State__c, City__r.State__r.Country__c FROM Area__c WHERE Id IN :areaIds]
        );
        Map<Id, City__c> cityMap = new Map<Id, City__c>(
            [SELECT Id, State__c, State__r.Country__c FROM City__c WHERE Id IN :cityIds]
        );
        Map<Id, State__c> stateMap = new Map<Id, State__c>(
            [SELECT Id, Country__c FROM State__c WHERE Id IN :stateIds]
        );
        
        // Update the lead fields based on the selected values
        for (Lead__c lead : newLeads) {
            if (lead.Pin_Code__c != null && postalCodeMap.containsKey(lead.Pin_Code__c)) {
                Pin_Code__c postalCode = postalCodeMap.get(lead.Pin_Code__c);
                lead.Area_Name__c = postalCode.Area__c;
                lead.City__c = postalCode.Area__r.City__c;
                lead.State__c = postalCode.Area__r.City__r.State__c;
                lead.Country__c = postalCode.Area__r.City__r.State__r.Country__c;
            } else if (lead.Area_Name__c != null && areaMap.containsKey(lead.Area_Name__c)) {
                Area__c area = areaMap.get(lead.Area_Name__c);
                lead.City__c = area.City__c;
                lead.State__c = area.City__r.State__c;
                lead.Country__c = area.City__r.State__r.Country__c;
            } else if (lead.City__c != null && cityMap.containsKey(lead.City__c)) {
                City__c city = cityMap.get(lead.City__c);
                lead.State__c = city.State__c;
                lead.Country__c = city.State__r.Country__c;
            } else if (lead.State__c != null && stateMap.containsKey(lead.State__c)) {
                State__c state = stateMap.get(lead.State__c);
                lead.Country__c = state.Country__c;
            }
        }
    }
}