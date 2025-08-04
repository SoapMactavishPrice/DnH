trigger EnquirySharingTrigger on Enquiry__c (after insert, after update) {
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        EnquirySharingHandler.shareEnquiryWithUsers(Trigger.new);
    }
    if (Trigger.isUpdate) {
        //updateSOCountOnEnquiry.updateSOCount(Trigger.new);
    }
}