public class NMD_CustomerSchedule implements  Queueable , Database.AllowsCallouts{
    
    public void execute(QueueableContext context) {
        NMD_Customer nm=new NMD_Customer();
        nm.getCustomerDataAsJson();
    }

}