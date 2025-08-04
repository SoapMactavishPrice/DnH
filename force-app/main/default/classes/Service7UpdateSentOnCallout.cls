public class Service7UpdateSentOnCallout implements Queueable, Database.AllowsCallouts {

    private List<Service_7_Sample_Feedbacks__c> ssfMappingList;
    private Integer index;
    public static Boolean stopChainingInTest = false;
    
    public Service7UpdateSentOnCallout(List<Service_7_Sample_Feedbacks__c> ssfMappingList, Integer index){
        this.index = index;
        this.ssfMappingList = ssfMappingList;
    }

    public void execute(QueueableContext context) {

        if (index < this.ssfMappingList.size()) {
            Service_7_Sample_Feedbacks__c el = this.ssfMappingList[index];

            // Perform the callout
            createService7SamplefeedbackTrigHandler.updateSentAPICallout(el.InvoiceNo__c); // Perform the callout here
            
            // Chain the next job to process the next invoice
            if (!Test.isRunningTest() || !stopChainingInTest) {
                if (index + 1 < this.ssfMappingList.size()) {
                    System.enqueueJob(new Service7UpdateSentOnCallout(this.ssfMappingList, index + 1));
                }
            }
        }

    }

}