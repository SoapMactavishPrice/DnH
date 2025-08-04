trigger SampleOrderTrigger on Service_5_Sample_Request__c (after update) {

    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {

            Map < Id, Service_5_Sample_Request__c > oldAccAddRecs = Trigger.oldMap;
            Map < Id, Service_5_Sample_Request__c > newAccAddRecs = Trigger.newMap;

            for (Integer i = 0; i < newAccAddRecs.values().size(); i++) {

                Service_5_Sample_Request__c oldPA = oldAccAddRecs.values()[i];
                Service_5_Sample_Request__c newPA = newAccAddRecs.values()[i];

                if (oldPA.Status__c != 'Approved by TSD Exe' && newPA.Status__c == 'Approved by TSD Exe') {
                    if (newPA.Sample_Order_Number__c != null && newPA.Sample_Order_Number__c != '' && newPA.Sample_Order_Number__c.contains('SMO/') && !newPA.Sample_Order_Number__c.contains(' ')) {
                        CreateSampleRequest_ToNav.saveResponseToSampleOrder(newPA.Id, newPA.Sample_Order_Number__c);
                    } else {
                        CreateSampleRequest_ToNav.insertSampleSalesOrderToNav(newPA.Id);
                    }
                }
            }

        }
    }

}