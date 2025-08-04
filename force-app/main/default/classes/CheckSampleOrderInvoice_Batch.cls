global class CheckSampleOrderInvoice_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts, Schedulable {

    global database.QueryLocator start(database.BatchableContext bc) {

        string todayDate = Datetime.now().format();

        if (Test.isRunningTest()) {
            return database.getQueryLocator([
                SELECT Id, Name, Code__c
                FROM User
                WHERE Code__c != null
                ORDER BY Code__c ASC LIMIT 55
            ]);
        } else {
            return database.getQueryLocator([
                SELECT Id, Name, Code__c
                FROM User
                WHERE Code__c != null
                // ORDER BY Code__c ASC LIMIT 1
            ]);
        }

    }

    global void Execute(database.BatchableContext bc, List < User > scope) {

        // Calculate the start and end dates
        Datetime today = Date.today();
        Datetime yesterday = today.addDays(-1);

        // Format the dates in 'yyyy-MM-dd'
        String formattedStartDate = yesterday.format('yyyy-MM-dd');
        String formattedEndDate = today.format('yyyy-MM-dd');

        System.debug(formattedStartDate);
        System.debug(formattedEndDate);

        List<User> userList = new List<User>();
        userList.addAll(scope);

        if (!userList.isEmpty()) {
            // Start processing the first invoice using Queueable
            System.enqueueJob(new Service7QueueableCallout('S7_SalesInvoiceHeader',userList, 0,'2023-01-01', '2025-02-21'));
        }

    }

    // Define a class to map the JSON structure
    public class InvoiceData {
        public String DocNo;
        public String CustomerNo;
        public String CustomerName;
        public String EndCustomerName;
        public String ShiptoCustomerName;
        public String FieldEngineer;
        public String AreaManager;
        public String ZonalManager;
        public String InvoiceDate;
        public String DocketNo;
        public String DocketDate;
    }

    global void finish(Database.BatchableContext BC) {}

    // Implement Schedulable
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CheckSampleOrderInvoice_Batch(), 1); // Set batch size to 1
    }
    
}