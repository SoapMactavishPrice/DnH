/********************************************************************************************
* Author    : Prashant Padal
* Date      : 19/07/2024
--------------------------------------------------------------------------------------------
Version      Date             Author          Remarks 
v1           19/07/2024       Prashant Padal                    
=======      ===========      ==============  ======================
*******************************************************************************************/

public class SyncQuote {
    public Id recordId { get; set; }
    public Boolean showError { get; set; }
     
    public SyncQuote() {
        recordId = Apexpages.currentPage().getParameters().get('id');
        showError = false;
    }

    public PageReference syncQuoteOpp() {
        set<Id> qId = new set<Id>(); 
        set<Id> opptyId = new set<Id>(); 
        map<Id, Id> quoToOppty = new map<Id, Id>();
        system.debug('recordId' + recordId);
        
        string Quote = 'Select  ' + Utilitycls.getAllFields('Quote__c').get('Quote__c') + ' from Quote__c where Id  =:  recordId';
        Quote__c quo = database.query(Quote);
        string oppId = quo.Enquiry__c;
        
        if (quo.Quote_Status__c != 'Accepted') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Make Sure Quote Stage Is Accepted Before Sync'));
            showError = true;
            return null;
        }

        string lineItem = 'Select Quote__r.Enquiry__c, ' + Utilitycls.getAllFields('Quote_Line_Item__c').get('Quote_Line_Item__c') + ' from Quote_Line_Item__c where Quote__c =:  recordId order by SystemModstamp';
        List<Quote_Line_Item__c> quoLineItem = database.query(lineItem);
        system.debug('quoLineItem' + quoLineItem.size() + '  ' + quoLineItem);
        
        List<Enquiry_Line_Item__c> UpdateQpllist = new List<Enquiry_Line_Item__c>();
        string opptylineItem = 'Select ' + Utilitycls.getAllFields('Enquiry_Line_Item__c').get('Enquiry_Line_Item__c') + ' from Enquiry_Line_Item__c where Enquiry__c =: oppId order by SystemModstamp';
        List<Enquiry_Line_Item__c> optyline = database.query(opptylineItem);
        map<Id, Enquiry_Line_Item__c> lineMap = new map<Id, Enquiry_Line_Item__c>();
        
        for (Enquiry_Line_Item__c qp : optyline) {
            lineMap.put(qp.Item_Master__c, qp);
        }

        Enquiry__c op = new Enquiry__c();
        op.Id = oppId;
        
        system.debug(quoLineItem.size());
        for (Quote_Line_Item__c QLI : quoLineItem) {
            if (lineMap.containsKey(QLI.Item_Master__c) && optyline.size() > 0) {
                system.debug('inside if');
                Enquiry_Line_Item__c opt = new Enquiry_Line_Item__c();
                opt.Enquiry__c = quo.Enquiry__c;
                opt.Id = lineMap.get(QLI.Item_Master__c).Id; 
                opt.Qty__c = QLI.Quantity__c;
                opt.Sales_Price__c = QLI.Sales_Price__c;
                opt.List_Price__c = QLI.List_Price__c;
                opt.Discount_In_Percentage__c = QLI.Discount_In_Percentage__c;
                opt.Item_Master__c = QLI.Item_Master__c;
                opt.Unit_of_Measure_Code__c = QLI.Unit_of_Measure_Code__c;
               // opt.Item_Description__c = QLI.Item_Description__c;
                opt.HSN_SAC_Code__c = QLI.HSN_SAC_Code__c;
                opt.Item_Display_Name__c = QLI.Item_Display_Name__c;
                opt.Specification__c = QLI.Specification__c;
                opt.Sync__c = true;
                UpdateQpllist.add(opt);
            } else {
                system.debug('inside else');
                Enquiry_Line_Item__c opt = new Enquiry_Line_Item__c();
                opt.Enquiry__c = quo.Enquiry__c;
                opt.Item_Master__c = QLI.Item_Master__c;
                opt.Sales_Price__c = QLI.Sales_Price__c;
                opt.List_Price__c = QLI.List_Price__c;
                opt.Qty__c = QLI.Quantity__c;
                opt.Discount_In_Percentage__c = QLI.Discount_In_Percentage__c;
               // opt.Item_Description__c = QLI.Item_Description__c;
                opt.Unit_of_Measure_Code__c = QLI.Unit_of_Measure_Code__c;
                opt.HSN_SAC_Code__c = QLI.HSN_SAC_Code__c;
                opt.Item_Display_Name__c = QLI.Item_Display_Name__c;
                opt.Specification__c = QLI.Specification__c;
                opt.Sync__c = true;
                UpdateQpllist.add(opt);
            }
        }
        
        if (UpdateQpllist.size() > 0) {
            upsert UpdateQpllist;
        }       

        PageReference pgref = new PageReference('/' + quo.Enquiry__c);
        pgref.setRedirect(true);
        return pgref;
    }
}