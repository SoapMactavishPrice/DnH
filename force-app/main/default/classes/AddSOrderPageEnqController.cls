public class AddSOrderPageEnqController {
    public AddSOrderPageEnqController() {}

    @AuraEnabled(cacheable = false)
    public static String getEnqLineItems(String enqId) {
        String returnData = '';

        List < Enquiry_Line_Item__c > enqlineItemList = [
            SELECT Id, Name, Qty__c, List_Price__c, Product_Family__c, Item_Master__c
            FROM Enquiry_Line_Item__c
            WHERE Enquiry__c = :enqId
        ];

        List<EnquiryLineItemWrapper> eliwList = new List<EnquiryLineItemWrapper>();

        for (Enquiry_Line_Item__c eli : enqlineItemList) {
            EnquiryLineItemWrapper eliwrapper = new EnquiryLineItemWrapper();
            eliwrapper.liurl = '/lightning/r/' + eli.Id + '/view';
            eliwrapper.Id = eli.Id;
            eliwrapper.name = eli.Name;
            eliwrapper.productFamily = eli.Product_Family__c;
            eliwrapper.qty = eli.Qty__c;
            eliwrapper.price = eli.List_Price__c;
            eliwrapper.itemMaster = eli.Item_Master__c;
            eliwList.add(eliwrapper);
        }

        if (eliwList.size() > 0) {
            WrapperClass wc = new WrapperClass();
            wc.enquiryLineItemList = eliwList;
            returnData = JSON.serialize(wc);
            system.debug('returnData'+returnData);
        }
        return returnData;
        
    }

    @AuraEnabled(cacheable = false)
    public static String createQuote(String enqId, List<Enquiry_Line_Item__c> lItems) {
        try {
            String retData = '';

            // Retrieve the Enquiry__c record
            Enquiry__c enq = [SELECT Id, Name, Account__c, Contact__c, Transaction_Type__c, Commission_Type__c, Commission_Value__c, 
                                      Shipment__c, Other_Terms_Conditions__c, Inco_Terms__c, Inco_Terms_Remark__c, Payment_Terms__c, 
                                      Other_Payment_Terms__c, Pricelist__r.Name, Pricelist_Status__c,Delivery_Terms__c
                              FROM Enquiry__c 
                              WHERE Id = :enqId 
                              LIMIT 1];
                              
                              //Delivery_Terms__c,Other_Delivery_Terms__c,

            // Create and insert the Quote__c record
            Sales_Order__c  qte = new Sales_Order__c ();
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
            qte.Delivery_Terms__c = enq.Delivery_Terms__c;
            qte.Pricelist__c = enq.Pricelist__c;
            // qte.Pricelist_Status__c = enq.Pricelist_Status__c;
            insert qte;
            
            List<Enquiry_Line_Item__c> eqllist = new List<Enquiry_Line_Item__c>();
            eqllist = [SELECT Id, Name, Enquiry__c, Item_Master__c, Qty__c, List_Price__c, Sales_Price__c 
                       FROM Enquiry_Line_Item__c 
                       WHERE Id IN :lItems];
           
            //, Item_Description__c

            
            // Create and insert Quote_Line_Item__c records linked to the created Quote__c record
            List<Sales_Order_Line_Item__c> qLines = new List<Sales_Order_Line_Item__c>();
            for (Enquiry_Line_Item__c enqLineItem : eqllist) {
                system.debug('lItems' + eqllist);
                system.debug('enqLineItem' + enqLineItem.Item_Master__c);
                system.debug('enqLineItem: ' + enqLineItem);
                system.debug('enqLineItem.Item_Master__c: ' + enqLineItem.Item_Master__c);
                system.debug('enqLineItem.Qty__c: ' + enqLineItem.Qty__c);
                system.debug('enqLineItem.List_Price__c: ' + enqLineItem.List_Price__c);
                system.debug('enqLineItem.Sales_Price__c: ' + enqLineItem.Sales_Price__c);
               // system.debug('enqLineItem.Item_Description__c: ' + enqLineItem.Item_Description__c);
    
                Sales_Order_Line_Item__c qLine = new Sales_Order_Line_Item__c();
                qLine.Sales_Order__c  = qte.Id; // Use the Id of the created Quote__c record
                qLine.Item_Master__c = enqLineItem.Item_Master__c;
                qLine.Quantity__c = enqLineItem.Qty__c; // Mapping Qty from Enquiry Line Item to Quote Line Item
                qLine.List_Price__c = enqLineItem.List_Price__c; // Mapping List Price from Enquiry Line Item to Quote Line Item
                qLine.Sales_Price__c = enqLineItem.Sales_Price__c;
               // qLine.Item_Description__c = enqLineItem.Item_Description__c; // Mapping Item Description from Enquiry Line Item to Quote Line Item
                
                system.debug('qLine' + qLine);
                qLines.add(qLine);
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
        public List < EnquiryLineItemWrapper > enquiryLineItemList;
    }

    public with sharing class EnquiryLineItemWrapper {
        public String liurl;
        public String Id;
        public String name;
        public String productFamily;
        public Decimal qty;
        public Decimal price;
        public String itemMaster;
        public String contact;
    }

}