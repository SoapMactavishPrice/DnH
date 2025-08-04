global class CheckSampleOrdInv_BatchScheduler implements schedulable {
    global void execute(SchedulableContext sc) {
        ID BatchId = Database.executeBatch(new CheckSampleOrderInvoice_Batch(),1);
    }
}