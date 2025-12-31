public class LeadTriggerHandler {
    
    public static void updateLeadAddresses(List<Lead__c> newLeads) {
        
        Set<Id> postalCodeIds = new Set<Id>();
        Set<Id> areaIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        
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
    
    public static void handleStatusDate(List<Lead__c> newList, Map<Id, Lead__c> oldMap) {
        
        for (Lead__c ld : newList) {
            
            if (oldMap == null || !oldMap.containsKey(ld.Id)) {
                if (ld.Lead_Status__c == 'New') {
                    ld.New_Status_Date__c  = Date.today();
                }
                continue;
            }
            
            Lead__c oldLead = oldMap.get(ld.Id);
            
            if (ld.Lead_Status__c == 'New' && oldLead.Lead_Status__c != 'New') {
                ld.New_Status_Date__c  = Date.today();
            }
        }
    }
    
    public static void addCountryCodeToMobile(List<Lead__c> newLeads) {
        
        for (Lead__c lead : newLeads) {
            
            if (String.isBlank(lead.MC_Mobile_No__c) && String.isNotBlank(lead.Mobile_Number__c)) {
                lead.MC_Mobile_No__c = lead.Mobile_Number__c;
            }
            
            if (String.isNotBlank(lead.MC_Mobile_No__c)) {
                String countryCode = String.isNotBlank(lead.Country_Code__c) ? lead.Country_Code__c : '91';
                Integer digits = lead.Digits__c != null ? Integer.valueOf(lead.Digits__c) : 10;
                
                String mobile = lead.MC_Mobile_No__c.replaceAll('[^0-9]', '');
                
                if (mobile.length() >= digits) {
                    mobile = mobile.substring(mobile.length() - digits);
                    lead.MC_Mobile_No__c = countryCode + mobile;
                } else {
                    lead.MC_Mobile_No__c = null;
                }
            }
        }
    }
}