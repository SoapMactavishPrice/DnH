public class Service7QueueableCallout implements Queueable, Database.AllowsCallouts {
    private String schedularName;
    private Integer index;
    private String jsonData;
    private String startDate;
    private String endDate;
    private List<User> userList;
    private List<Invoice__c> invoiceList;
    private List<Invoice_Line_Item__c> invoiceLineItem;
    // private String Docket_No;
    // private Date Docket_Date;
    // private Date InvoiceDate;
    // private String custName;
    // private String fieldEngg;

    public Service7QueueableCallout(String schedularName, List<User> userList, Integer index ,String startDate,String endDate) {
        this.schedularName = schedularName;
        this.startDate = startDate;
        this.endDate = endDate;
        this.userList = userList;
        this.index = index;
    }
    
    public Service7QueueableCallout(String schedularName, List<Invoice__c> invoiceList, Integer index){
        this.schedularName = schedularName;
        this.invoiceList = invoiceList;
        this.index = index;
    }
    
    public Service7QueueableCallout(String schedularName, List<Invoice_Line_Item__c> invoiceLineItem, Integer index){
        this.schedularName = schedularName;
        this.invoiceLineItem = invoiceLineItem;
        this.index = index;
    }

    public void execute(QueueableContext context) {
        if (this.schedularName == 'S7_SalesInvoiceHeader') {

            if (index < this.userList.size()) {
                User usr = this.userList[index];
    
                // Perform the callout
                S7_SalesInvoiceHeader.getInvoiceList(this.startDate, this.endDate, usr.Code__c); // Perform the callout here
    
                // Chain the next job to process the next invoice
                if (index + 1 < this.userList.size()) {
                    if (!Test.isRunningTest()) {
                        System.enqueueJob(new Service7QueueableCallout('S7_SalesInvoiceHeader', this.userList, index + 1, this.startDate, this.endDate));
                    }
                }
            }


        } else if (this.schedularName == 'S7_SalesInvoiceLine') {

            if (index < invoiceList.size()) {
                Invoice__c invoice = invoiceList[index];
                String invoiceJSON = JSON.serialize(invoice);
    
                // Perform the callout
                S7_SalesInvoiceLine.getInvoiceLineitem(invoiceJSON);
    
                // Chain the next job to process the next invoice
                if (index + 1 < invoiceList.size()) {
                    if (!Test.isRunningTest()) {
                        System.enqueueJob(new Service7QueueableCallout('S7_SalesInvoiceLine', invoiceList, index + 1));
                    }
                }
            }

        } else if (this.schedularName == 'S7_SalesInvoiceLot') {

            if (index < invoiceLineItem.size()) {
                Invoice_Line_Item__c inv = invoiceLineItem[index];
                String invoiceJSON = JSON.serialize(inv);
    
                // Perform the callout
                S7_SalesInvoiceLot.getInvoiceLot(invoiceJSON, inv.Invoice__r.Docket_No__c, inv.Invoice__r.Docket_Date__c, inv.Invoice__r.InvoiceDate__c,inv.Invoice__r.Customer_Name__c,inv.Invoice__r.Field_Engineer__c);
    
                // Chain the next job to process the next invoice
                if (index + 1 < invoiceLineItem.size()) {
                    if (!Test.isRunningTest()) {
                        System.enqueueJob(new Service7QueueableCallout('S7_SalesInvoiceLot', invoiceLineItem, index + 1));
                    }
                }
            }

        }
    }
}