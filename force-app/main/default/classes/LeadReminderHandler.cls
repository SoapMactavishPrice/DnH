public class LeadReminderHandler {

    public static void initializeFlags(List<Lead__c> leads) {
        for (Lead__c l : leads) {
            if (l.Lead_Status__c == 'New') {

                l.Day2_Reminder_Sent__c  = false;
                l.Day5_Reminder_Sent__c  = false;
                l.Day10_Reminder_Sent__c = false;
                l.Day15_Reminder_Sent__c = false;
                
            }
        }
    }
}