public class SendEmailJob implements Queueable, Database.AllowsCallouts {
    String salesOrderId;

    public SendEmailJob(Id salesOrderId) {
        this.salesOrderId = salesOrderId;
    }

    public void execute(QueueableContext context) {
        AddSalesOrder.sendEmailToAreaManager(salesOrderId, '');
    }
}