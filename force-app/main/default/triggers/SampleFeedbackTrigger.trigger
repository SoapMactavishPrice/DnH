trigger SampleFeedbackTrigger on Service_7_Sample_Feedbacks__c (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        for (Service_7_Sample_Feedbacks__c fb : Trigger.new) {
            createService7SamplefeedbackTrigHandler.updateSentAPICallout(fb.InvoiceNo__c);
        }
    }

}