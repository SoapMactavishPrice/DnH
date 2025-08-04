public class GreythrAttendanceQueueableCallout implements Queueable, Database.AllowsCallouts {

    private List<Employee_Login__c> empLoginList;
    private Integer index;
    
    public GreythrAttendanceQueueableCallout(List<Employee_Login__c> empLoginList, Integer index){
        this.index = index;
        this.empLoginList = empLoginList;
    }

    public void execute(QueueableContext context) {
        if (index < this.empLoginList.size()) {
            Employee_Login__c el = this.empLoginList[index];

            // Perform the callout
            GreythrAttendanceAPI.sendSwipesToGreyHR(el.Check_In__c, el.Check_Out__c, el.Employee__r.Code__c); // Perform the callout here

            // Chain the next job to process the next invoice
            if (index + 1 < this.empLoginList.size()) {
                System.enqueueJob(new GreythrAttendanceQueueableCallout(this.empLoginList, index + 1));
            }
        }
    }

}