trigger SalesOrderLineItemTrigger on Sales_Order_Line_Item__c (after insert, after delete) {
    // A list to hold the Enquiry Line Items to be updated
    List<Enquiry_Line_Item__c> enquiryItemsToUpdate = new List<Enquiry_Line_Item__c>();
    
    // A set to store unique Sales Order IDs to query their related Enquiry__c field
    Set<Id> salesOrderIds = new Set<Id>();

    List<Sales_Order_Line_Item__c> soliLIST = new List<Sales_Order_Line_Item__c>();
    if (Trigger.isInsert) {
        soliLIST = Trigger.New;
    } else if (Trigger.isDelete) {
        soliLIST = Trigger.Old;
    }
    
    // Loop through all newly inserted Sales Order Line Items and gather Sales Order IDs
    for (Sales_Order_Line_Item__c orderLine : soliLIST) {
        salesOrderIds.add(orderLine.Sales_Order__c);
    }
    
    // Query the Sales Order records to get their associated Enquiry__c values
    Map<Id, Id> salesOrderToEnquiryMap = new Map<Id, Id>();
    for (Sales_Order__c salesOrder : [
        SELECT Id, Enquiry__c
        FROM Sales_Order__c
        WHERE Id IN :salesOrderIds
    ]) {
        salesOrderToEnquiryMap.put(salesOrder.Id, salesOrder.Enquiry__c);
    }
    
    // A map to quickly access Enquiry_Line_Item__c records by Item_No__c
    Map<String, Enquiry_Line_Item__c> enquiryLineItemMap = new Map<String, Enquiry_Line_Item__c>();
    
    // Now loop through the Sales Order Line Items to find the corresponding Enquiry_Line_Item__c records
    for (Sales_Order_Line_Item__c orderLine : soliLIST) {
        Id enquiryId = salesOrderToEnquiryMap.get(orderLine.Sales_Order__c);
        String itemNumber = orderLine.Item_Number__c;
        String itemVariant = orderLine.Item_Variant__c;
        
        // Query for Enquiry_Line_Item__c records that match the Item_No__c and Enquiry__c
        List<Enquiry_Line_Item__c> enquiryLineItems = [
            SELECT Id, Item_No__c, Qty__c , Enquiry__c, RemainingQty__c,Order_Qty__c
            FROM Enquiry_Line_Item__c
            WHERE Enquiry__c = :enquiryId AND Item_No__c = :itemNumber AND Item_Variant__c =: itemVariant
            LIMIT 1
        ];

        System.debug('enquiryLineItems:>> ' +enquiryLineItems.size());
        
        // If a matching Enquiry_Line_Item__c is found, update its Quantity
        if (!enquiryLineItems.isEmpty()) {
            if (enquiryItemsToUpdate.size() > 0) {
                Enquiry_Line_Item__c duplicateELI = new Enquiry_Line_Item__c();
                Boolean isDup = false;
                for (Enquiry_Line_Item__c vELI : enquiryItemsToUpdate) {
                    if (vELI.Id == enquiryLineItems[0].Id) {
                        vELI.RemainingQty__c = vELI.RemainingQty__c - orderLine.Quantity__c ; // Update the Remaining Quantity
                        vELI.Order_Qty__c = vELI.Order_Qty__c != null ? vELI.Order_Qty__c + orderLine.Quantity__c : orderLine.Quantity__c ; // Update the total placed order Quantity
                        duplicateELI = vELI;
                        isDup = true;
                        break;
                    }
                }
                if (isDup) {
                } else {
                    Enquiry_Line_Item__c enquiryLine = enquiryLineItems[0];
                    enquiryLine.RemainingQty__c = enquiryLine.RemainingQty__c - orderLine.Quantity__c ; // Update the Remaining Quantity
                    enquiryLine.Order_Qty__c = enquiryLine.Order_Qty__c != null ? enquiryLine.Order_Qty__c + orderLine.Quantity__c : orderLine.Quantity__c ; // Update the total placed order Quantity
                    enquiryItemsToUpdate.add(enquiryLine);
                }
            } else {
                Enquiry_Line_Item__c enquiryLine = enquiryLineItems[0];
                if (Trigger.isInsert) {
                    enquiryLine.RemainingQty__c = enquiryLine.RemainingQty__c - orderLine.Quantity__c ; // Update the Remaining Quantity
                    enquiryLine.Order_Qty__c = enquiryLine.Order_Qty__c != null ? enquiryLine.Order_Qty__c + orderLine.Quantity__c : orderLine.Quantity__c ; // Update the total placed order Quantity
                    System.debug('Trigger isInsert :>>>> ');
                } else if (Trigger.isDelete) {
                    enquiryLine.RemainingQty__c = enquiryLine.RemainingQty__c + orderLine.Quantity__c ; // Update the Remaining Quantity
                    enquiryLine.Order_Qty__c = enquiryLine.Order_Qty__c != null ? enquiryLine.Order_Qty__c - orderLine.Quantity__c : orderLine.Quantity__c ; // Update the total placed order Quantity
                    System.debug('Trigger isDelete :>>>> ');
                }
                enquiryItemsToUpdate.add(enquiryLine);
            }
        }
    }
    
    // If there are any Enquiry_Line_Item__c records to update, perform the DML update
    if (!enquiryItemsToUpdate.isEmpty()) {
        update enquiryItemsToUpdate;
    }
}