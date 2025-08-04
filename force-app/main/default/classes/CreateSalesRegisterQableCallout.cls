public class CreateSalesRegisterQableCallout implements Queueable, Database.AllowsCallouts {
    
    private List<Customer_Sales_Person_Mapping__c> cspMappingList;
    private Integer index;
    public static Boolean stopChainingInTest = false;
    
    public CreateSalesRegisterQableCallout(List<Customer_Sales_Person_Mapping__c> cspMappingList, Integer index){
        this.index = index;
        this.cspMappingList = cspMappingList;
    }
    
    public void execute(QueueableContext context) {
        if (index < this.cspMappingList.size()) {
            Customer_Sales_Person_Mapping__c el = this.cspMappingList[index];
            
            Date filterTodayDate = Date.today();
            Date filterYestDate = filterTodayDate.addDays(-1);
            
            String startDate = String.valueOf(filterTodayDate);
            String endDate = String.valueOf(filterYestDate);
            
            
            // Perform the callout
            // CreateSalesRegisterFromNAV_API.getPostedInvoiceReportData(el.Account__c, el.Sales_Person__c, startDate, endDate); // Perform the callout here
            CreateSalesRegisterFromNAV_API.getPostedInvoiceReportData(el.Account__c, el.Sales_Person__c, '2025-04-01', '2025-04-30'); // Perform the callout here
            
            // Chain the next job to process the next invoice
            if (!Test.isRunningTest() || !stopChainingInTest) {
                if (index + 1 < this.cspMappingList.size()) {
                    System.enqueueJob(new CreateSalesRegisterQableCallout(this.cspMappingList, index + 1));
                }
            }
        }
    }
    
}