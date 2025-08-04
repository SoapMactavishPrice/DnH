global class CheckInvoiceLot_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts, Schedulable {
    
    global database.QueryLocator start(database.BatchableContext bc) {

        DateTime now = DateTime.now();
        DateTime last24Hours = now.addHours(-24);
        
        return database.getQueryLocator([
            SELECT Id, Invoice__c,Invoice__r.Customer_Name__c, Doc_No__c, Item_No__c, Line_No__c, Description__c, Description2__c,
            Sample_Sales_Order_Number__c, Quantity__c, Size__c, Item_Brand__c, UOM__c,
            Invoice__r.Docket_No__c, Invoice__r.Docket_Date__c, Invoice__r.InvoiceDate__c,Invoice__r.Field_Engineer__c
            FROM Invoice_Line_Item__c
            WHERE CreatedDate >= :last24Hours
        ]);

    }

    global void Execute(database.BatchableContext bc, List < Invoice_Line_Item__c > scope) {

        // for (Invoice_Line_Item__c inv: scope) {
        //     System.debug(inv.Invoice__r.Docket_Date__c);
        //     String invJSON = JSON.serialize(inv);
        //     S7_SalesInvoiceLot.getInvoiceLot(invJSON, inv.Invoice__r.Docket_No__c, inv.Invoice__r.Docket_Date__c, inv.Invoice__r.InvoiceDate__c,inv.Invoice__r.Customer_Name__c,inv.Invoice__r.Field_Engineer__c);
        // }

        List<Invoice_Line_Item__c> invoiceLIList = new List<Invoice_Line_Item__c>();
        invoiceLIList.addAll(scope);

        if (!invoiceLIList.isEmpty()) {
            // Start processing the first invoice using Queueable
            System.enqueueJob(new Service7QueueableCallout('S7_SalesInvoiceLot', invoiceLIList, 0));
        }

    }

    global void finish(Database.BatchableContext BC) {}

    // Implement Schedulable
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CheckInvoiceLot_Batch(), 1); // Set batch size to 1
    }

}