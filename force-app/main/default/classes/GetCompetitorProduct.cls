public with sharing class GetCompetitorProduct {
    public GetCompetitorProduct() {

    }

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName,string recordId) {   
        
         system.debug('-->'+searchKey+' --' + sObjectApiName +'=---'+' '+ recordId);
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Competitor__c = \''+recordId+'\'';
        
        if(string.isNotbLank(searchKey)){
          sQuery+=' and Name Like : sWildCardText ';
        }
        
        
        sQuery+=' LIMIT 10';
        System.debug(sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        system.debug('returnList'+returnList.size());
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}