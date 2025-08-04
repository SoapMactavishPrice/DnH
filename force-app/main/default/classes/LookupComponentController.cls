public with sharing class LookupComponentController {

    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(string indusId,string deptId,String searchKey, String objectName, String recdataid, string returnFields, List<String> queryFields, String displayFields, String filter, String sortColumn, String maxResults, Boolean searchWithMiddle) {
        set<id> indId = new set<id> {indusId};
        set<id> depId = new set<id>{deptId};
        
        String a = '';
        if (returnFields != null && returnFields.trim() != '') {
            a = returnFields;
        }
        if (displayFields != null && displayFields.trim() != '') {
            a = (a == ''? displayFields : a + ','+ displayFields) ;
        }
        Set<String> b = new Set<String>();
        String col = '';
        if(a.trim() != ''){
            for(String t: a.split(',')){
                b.add(t.trim());
            }
            for(String t: b){
                col = col + ',' + t;
            }
        }

        /* if (returnFields != null && returnFields != '') {
            returnFields = ',' + returnFields;
        } else {
            returnFields = '';
        } */

        string searchText = '';
        if(searchWithMiddle == true){
            searchText = '\'%' + String.escapeSingleQuotes(searchKey) + '%\'';
        }else {
            searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
        }


        //string vQuery = 'SELECT Id, Name '+ returnFields + ' FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 10';
		String vQuery ='';
        if(objectName  == 'Industry__c'){
             vQuery =  'SELECT Id, Name '+ col + ' FROM ' +objectName+ ' WHERE ';
        }
        
        if(objectName  == 'Department__c'){
             vQuery =  'SELECT Id, Name '+ col + ' FROM ' +objectName+ ' WHERE  Industry__c IN : indId and';
        }
        
        if(objectName  == 'Application__c'){
             vQuery =  'SELECT Id, Name '+ col + ' FROM ' +objectName+ ' WHERE Industry__c IN : indId and Department__c IN :  depId and';
        }


        if(objectName  == 'Opportunity'){
            vQuery =  'SELECT Id, Name '+ col + ' FROM ' +objectName;
        }

        if(objectName  == 'Account'){
            vQuery =  'SELECT Id, Name '+ col + ' FROM ' +objectName+' WHERE ';
        }
        
        if (queryFields == null || queryFields.isEmpty()) {
            vQuery += ' Name LIKE ' + searchText;
        } else {
            string likeField = '';
            for(string field : queryFields) {
                likeField += ' OR ' + field + ' LIKE ' + searchText;
            }
            vQuery += ' (' + likeField.removeStart(' OR ') + ') ';
        }

        if(objectName  == 'Account'){
            vQuery += ' AND Customer_Type__c = \'End Customer\'';
        }

        if (filter != null && filter != '') {
            vQuery += ' AND (' + filter + ')';
        }

        if (sortColumn != null && sortColumn != '') {
            vQuery += ' ORDER BY ' + sortColumn;
        }

        if (maxResults == null || maxResults == '') {
            // maxResults = '10';
        }

        // vQuery += ' LIMIT ' + maxResults;

        System.debug(vQuery);

        return Database.query(vQuery);
    }

    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName, string returnFields) {
        string sRecId = recordId;

        if (returnFields != null && returnFields != '') {
            returnFields = ',' + returnFields;
        } else {
            returnFields = '';
        }

        string sQuery = 'Select Id,Name '+ returnFields + ' From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }

}