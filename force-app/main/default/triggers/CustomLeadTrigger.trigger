trigger CustomLeadTrigger on Lead__c (after insert, after update, before insert, before update) {
    
    // This is the only line of code that is required.
    TriggerFactory.createTriggerDispatcher(Lead__c.sObjectType);
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        
        for(Lead__c ld : Trigger.New) {
            if(string.isNotBlank(ld.Mobile_Number__c )) {
                String mobilePhone = ld.Mobile_Number__c ;
                mobilePhone = mobilePhone.replaceAll(' ', '');
                if(mobilePhone.length() == 10) {
                    mobilePhone = '91' + mobilePhone;
                } else if(mobilePhone.startsWith('0')) {
                    mobilePhone = mobilePhone.replaceFirst('0', '91');
                }
                mobilePhone = mobilePhone.replaceAll('\\+', '');
                ld.MC_Mobile_No__c = mobilePhone;
            }
        }
    }
}