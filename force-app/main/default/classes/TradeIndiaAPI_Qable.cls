public class TradeIndiaAPI_Qable implements Queueable, Database.AllowsCallouts {
    
    Date currentDate;
    Date endDate;
    
    public TradeIndiaAPI_Qable(Date currentDate, Date endDate) {
        this.currentDate = currentDate;
        this.endDate = endDate;
    }
    
    public void execute(QueueableContext context) {
        TradeIndia_API.callApi(currentDate);
        // --- Chain next job if dates remain ---
        Date nextDate = currentDate.addDays(1);
        
        if (nextDate <= endDate) {
            if (!Test.isRunningTest()) {
                System.enqueueJob(new TradeIndiaAPI_Qable(nextDate, endDate));
            }
        }
    }
    
}