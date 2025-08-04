@isTest
public class LookupComponentControllerTest {

    @isTest
    public static void testLookupComponentControllerMethods() {
        Industry__c industry = new Industry__c();
        industry.Name = 'Test Industry';
        insert industry;

        Department__c department = new Department__c();
        department.Name = 'Test Department';
        department.Industry__c = industry.Id;
        insert department;

        Application__c application = new Application__c();
        application.Name = 'Test Application';
        application.Industry__c = industry.Id;
        application.Department__c = department.Id;
        insert application;

        String indusId = industry.Id;
        String deptId = department.Id;
        String searchKey = 'Test';
        String objectName = 'Application__c';
        String recdataid = null;
        String returnFieldsForApplication = '';
        List<String> queryFields = new List<String>{'Name'};
        String displayFields = '';
        String filter = '';
        String sortColumn = 'Name';
        String maxResults = '10';

        List<sObject> results = LookupComponentController.findRecords(indusId, deptId, searchKey, objectName, recdataid, returnFieldsForApplication, queryFields, displayFields, filter, sortColumn, maxResults, false);
        
        results = LookupComponentController.findRecords(indusId, deptId, searchKey, objectName, recdataid, returnFieldsForApplication, queryFields, displayFields, filter, sortColumn, maxResults, true);

        objectName = 'Industry__c';
        List<sObject> industryResults = LookupComponentController.findRecords(indusId, null, searchKey, objectName, recdataid, returnFieldsForApplication, queryFields, displayFields, filter, sortColumn, maxResults, false);
        
        objectName = 'Department__c';
        List<sObject> departmentResults = LookupComponentController.findRecords(indusId, deptId, searchKey, objectName, recdataid, returnFieldsForApplication, queryFields, displayFields, filter, sortColumn, maxResults, false);
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        String recordId = acc.Id;
        String sObjectApiName = 'Account';
        String returnFieldsForAccount = 'Phone, Website';

        sObject result = LookupComponentController.fetchDefaultRecord(recordId, sObjectApiName, returnFieldsForAccount);
    }
}