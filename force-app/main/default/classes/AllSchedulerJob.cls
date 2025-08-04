global class AllSchedulerJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        // System.enqueueJob(new AllScheduler('NMD_Item'));
        System.enqueueJob(new AllScheduler('NMD_ItemVariant'));
        System.enqueueJob(new AllScheduler('NMD_Customer'));
        // Enqueue job for NMD_CustSalesPersonMap
        System.enqueueJob(new AllScheduler('NMD_SalesPerson'));
        
        System.enqueueJob(new AllScheduler('NMD_CustSalesPersonMap'));
        System.enqueueJob(new AllScheduler('NMD_SalesPriceList'));
        System.enqueueJob(new AllScheduler('NMD_Transporter'));
        System.enqueueJob(new AllScheduler('NMD_LRDestination'));
        System.enqueueJob(new AllScheduler('NMD_ShipToCode'));
        System.enqueueJob(new AllScheduler('TradeIndia'));
        System.enqueueJob(new AllScheduler('IndiaMart'));

        // Enqueue job for NMD_SalesPerson
    }
}