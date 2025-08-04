public class AddQuotePageEnqController {
    public AddQuotePageEnqController() {}
    
    @AuraEnabled(cacheable = false)
    public static String getEnqLineItems(String enqId) {
        String returnData = '';
        
        List < Enquiry_Line_Item__c > enqlineItemList = [
            SELECT Id, Name, Qty__c, List_Price__c, Product_Family__c, Item_Master__c
            FROM Enquiry_Line_Item__c
            WHERE Enquiry__c = :enqId
        ];

        Set<String> itemMasterSet = new Set<String>();
        
        list<Quote_Line_Item__c> qlilist = [
            SELECT id, name, Quote__c, Item_Master__c FROM Quote_Line_Item__c WHERE Quote__r.Enquiry__c = :enqId
        ];
        
        map<Id, Id> ppMap = new map<Id, Id>();
        for (Quote_Line_Item__c pp : qlilist) {
            System.debug(pp.Item_Master__c);
            ppMap.put(pp.Item_Master__c, pp.Quote__c);
            itemMasterSet.add(pp.Item_Master__c);
        }
        System.debug(itemMasterSet.size());
        System.debug(enqlineItemList.size());
        
        List<EnquiryLineItemWrapper> eliwList = new List<EnquiryLineItemWrapper>();
        
        for (Enquiry_Line_Item__c eli : enqlineItemList) {
            // if(ppMap.containskey(eli.Item_Master__c)){
                EnquiryLineItemWrapper eliwrapper = new EnquiryLineItemWrapper();
                eliwrapper.liurl = '/lightning/r/' + eli.Id + '/view';
                eliwrapper.Id = eli.Id;
                eliwrapper.name = eli.Name;
                eliwrapper.productFamily = eli.Product_Family__c;
                eliwrapper.qty = eli.Qty__c;
                eliwrapper.listPrice = eli.List_Price__c;
                eliwrapper.itemMaster = eli.Item_Master__c;
                eliwrapper.isSelected = false;
                if (itemMasterSet.contains(eli.Item_Master__c)) {
                    eliwrapper.isDisabled = true; 
                    System.debug('if :>> ' +eliwList.size());
                } else {
                    eliwrapper.isDisabled = false; 
                    eliwList.add(eliwrapper);
                    System.debug('else :>> ' +eliwList.size());
                }
            
            // }
        }

        System.debug('eliwList:>> ' +eliwList.size());
        
        if (eliwList.size() > 0) {
            WrapperClass wc = new WrapperClass();
            wc.enquiryLineItemList = eliwList;
            returnData = JSON.serialize(wc);
        }
        return returnData;
    }
    
    @AuraEnabled(cacheable = false)
    public static String createQuote(String enqId, List<EnquiryLineItemWrapper> lItems) {
        try {
            String retData = '';
            
            // Retrieve the Enquiry__c record
            Enquiry__c enq = [SELECT Id, Name, Account__c, Contact__c, Transaction_Type__c, Commission_Type__c, Commission_Value__c, 
                              Shipment__c, Other_Terms_Conditions__c, Inco_Terms__c, Inco_Terms_Remark__c, Payment_Terms__c, 
                              Other_Payment_Terms__c,Pricelist__r.Name, Pricelist_Status__c
                              FROM Enquiry__c 
                              WHERE Id = :enqId 
                              LIMIT 1];
            
            // Create and insert the Quote__c record
            Quote__c qte = new Quote__c();
            qte.Enquiry__c = enqId;
            qte.Account__c = enq.Account__c;
            qte.Contact__c = enq.Contact__c; 
            qte.Transaction_Type__c = enq.Transaction_Type__c;
            qte.Commission_Type__c = enq.Commission_Type__c;
            qte.Commission_Value__c = enq.Commission_Value__c;
            qte.Shipment__c = enq.Shipment__c;
            qte.Other_Terms_Conditions__c = enq.Other_Terms_Conditions__c;
            qte.Inco_Terms__c = enq.Inco_Terms__c;
            qte.Inco_Terms_Remark__c = enq.Inco_Terms_Remark__c;
            qte.Payment_Terms__c = enq.Payment_Terms__c;
            qte.Other_Payment_Terms__c = enq.Other_Payment_Terms__c;
           // qte.Other_Delivery_Terms__c = enq.Other_Delivery_Terms__c;
            //qte.Delivery_Terms__c = enq.Delivery_Terms__c;
            qte.Pricelist__c = enq.Pricelist__c;
            // qte.Pricelist_Status__c = enq.Pricelist_Status__c;
            insert qte;
            
            // Extract Ids from EnquiryLineItemWrapper list
            Set<Id> lItemIds = new Set<Id>();
            for (EnquiryLineItemWrapper wp : lItems) {
                lItemIds.add(wp.Id);
            }
            
            // Query Enquiry_Line_Item__c records using the extracted Ids
            List<Enquiry_Line_Item__c> eqllist = [SELECT Id, Name, Enquiry__c, Item_Master__c, Qty__c, List_Price__c, Sales_Price__c  , Item_Description__c 
                                                  FROM Enquiry_Line_Item__c 
                                                  WHERE Id IN :lItemIds];
                                              
            
            Set<Id> pId = new Set<Id>();
            Map<Id, EnquiryLineItemWrapper> wps = new Map<Id, EnquiryLineItemWrapper>();
            
            for (EnquiryLineItemWrapper wp : lItems) {
                if (wp.isSelected && !wp.isDisabled) {
                    pId.add(wp.itemMaster);
                    wps.put(wp.itemMaster, wp);
                }
            }
            
            // Create and insert Quote_Line_Item__c records linked to the created Quote__c record
            List<Quote_Line_Item__c> qLines = new List<Quote_Line_Item__c>();
            for (Enquiry_Line_Item__c enqLineItem : eqllist) {
                if(wps.containsKey(enqLineItem.Item_Master__c)){
                if(wps.get(enqLineItem.Item_Master__c).isSelected){
                Quote_Line_Item__c qLine = new Quote_Line_Item__c();
                qLine.Quote__c = qte.Id; // Use the Id of the created Quote__c record
                qLine.Item_Master__c = enqLineItem.Item_Master__c;
                qLine.Quantity__c = (Double)wps.get(enqLineItem.Item_Master__c).qty;  
                qLine.List_Price__c = wps.get(enqLineItem.Item_Master__c).listPrice; 
                qLine.Sales_Price__c = wps.get(enqLineItem.Item_Master__c).salesPrice;
                qLine.Item_Description__c = wps.get(enqLineItem.Item_Master__c).description; 
                System.debug('itemmaster' + qLine.Item_Master__c);
                System.debug('qLine' + qLine);
                qLines.add(qLine);
              }
           }
          }
            insert qLines;
            
            retData = qte.Id;
            return retData;
        } catch (Exception e) {
            String errorMessage = 'Error: ' + e.getMessage() + ' at line: ' + e.getLineNumber() + ' stack trace: ' + e.getStackTraceString();
            System.debug('errorMessage'+errorMessage);
            throw new AuraHandledException(errorMessage);
        }
    }
    
    public with sharing class WrapperClass {
        public List<EnquiryLineItemWrapper> enquiryLineItemList;
    }
      
    public with sharing class EnquiryLineItemWrapper {
        public String liurl;
        public Id Id; // Change to Id type
        public String name;
        public String productFamily;
        public Decimal qty;
        public Decimal listPrice;
        public Decimal salesPrice;
        public String itemMaster;
        public String contact;
        public Boolean isDisabled;
        public Boolean isSelected;
        public string description;
    }
    
    
}