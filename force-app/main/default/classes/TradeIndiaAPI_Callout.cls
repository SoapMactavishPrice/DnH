public class TradeIndiaAPI_Callout implements Queueable, Database.AllowsCallouts {

    Date calloutDate;

    public TradeIndiaAPI_Callout(Date calloutDate) {
        this.calloutDate = calloutDate;
    }

    public void execute(QueueableContext context) {
        TradeIndia_API.callApi(this.calloutDate);
    }

}