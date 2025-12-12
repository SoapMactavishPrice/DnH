public class LeadReminderScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new LeadReminderBatch(), 100);
    }
}