public with sharing class addService7SampleRequestcontroller {
    @AuraEnabled(cacheable=true)
    public static List<Service_7_Sample_Feedbacks__c> getSampleFeedbacks(List<Id> feedbackIds) {
        System.debug('Feedback IDs: ' + feedbackIds);
        List<Service_7_Sample_Feedbacks__c> feedbacks = [SELECT Id FROM Service_7_Sample_Feedbacks__c WHERE Id IN :feedbackIds];
        System.debug('Fetched Feedbacks: ' + feedbacks);
        return feedbacks;
    }
}