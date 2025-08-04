global class AllSchedulerJob1 implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new AllScheduler('NMD_CustSalesPersonMap'));

        // Enqueue job for NMD_SalesPerson
    }
}