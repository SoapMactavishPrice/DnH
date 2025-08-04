public class AllScheduler implements  Queueable , Database.AllowsCallouts{
    private String schedulerName;
    public AllScheduler(String schedulerName){
        this.schedulerName = schedulerName;
    }
    public void execute(QueueableContext context) {
        if(schedulerName.equals('NMD_Item')){
            //NMD_Item nm=new NMD_Item();
            NMD_Item.getItemDataAsJson();
        }
        
        if(schedulerName.equals('NMD_CustSalesPersonMap')){
            NMD_CustSalesPersonMap nm=new NMD_CustSalesPersonMap();
            nm.getCustomerSalesPersonMappingDataAsJson();
        }

        if(schedulerName.equals('NMD_ItemVariant')){
            NMD_ItemVariant nm=new NMD_ItemVariant();
            nm.getItemVariantDataAsJson();
        }

        if(schedulerName.equals('NMD_SalesPriceList')){
            NMD_SalesPriceList nm=new NMD_SalesPriceList();
            nm.getSalesPriceDataAsJson();
        }

        if(schedulerName.equals('NMD_SalesPerson')){
            NMD_SalesPerson nm=new NMD_SalesPerson();
            nm.getSalesPersonDataAsJson();
        }
        
        if(schedulerName.equals('NMD_Customer')){
            NMD_Customer nm=new NMD_Customer();
            nm.getCustomerDataAsJson();
        }

        if(schedulerName.equals('NMD_Transporter')){
            NMD_Transporter nm=new NMD_Transporter();
            nm.getTransporteDataAsJson();
        }
        
        if(schedulerName.equals('NMD_LRDestination')){
            NMD_LRDestination nm=new NMD_LRDestination();
            nm.getLRDataAsJson();
        }
        
        if(schedulerName.equals('NMD_ShipToCode')){
            NMD_ShipToCode nm=new NMD_ShipToCode();
            nm.getShipToCodeDataAsJson();
        }
        
        if(schedulerName.equals('TradeIndia')){
            // TradeIndia_API nm=new TradeIndia_API();
            TradeIndia_API.callApi();
        }
        
        if(schedulerName.equals('IndiaMart')){
            // IndiaMart_API nm=new IndiaMart_API();
            IndiaMart_API.callApi();
        }
    }

}