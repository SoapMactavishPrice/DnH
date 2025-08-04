trigger CopyAddress on Address_Information__c (before insert, before update){
    
    if(Trigger.isBefore){
        
        if(Trigger.isInsert || Trigger.isUpdate){
          copyAddressHandler.copyAddressToRecord(Trigger.new);
          copyAddressHandler.copySoldAddressToRecord(Trigger.new);
        }
    }
    
}