public class updateSOCountOnEnquiry {
    
    private static Set<Id> processedEnquiries = new Set<Id>();
    
    public static void updateSOCount(List<Enquiry__c> enquiries) {
        
        Set<Id> enquiryIds = new Set<Id>();
        
        // Collect IDs, but ensure they haven't been processed already
        for (Enquiry__c enq : enquiries) {
            if (!processedEnquiries.contains(enq.Id)) {
                enquiryIds.add(enq.Id);
            }
        }
        
        if (!enquiryIds.isEmpty()) {
            // Prevent infinite loop by adding processed IDs
            processedEnquiries.addAll(enquiryIds);
            
            // Aggregate Query to count related Sales Orders
            Map<Id, Integer> enquirySOCountMap = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT Enquiry__c, COUNT(Id) totalCount
                FROM Sales_Order__c
                WHERE Enquiry__c IN :enquiryIds
                GROUP BY Enquiry__c
            ]) {
                enquirySOCountMap.put((Id) ar.get('Enquiry__c'), (Integer) ar.get('totalCount'));
            }
            
            List<Enquiry__c> enquiriesToUpdate = new List<Enquiry__c>();
            
            // Prepare records for update
            for (Id enqId : enquiryIds) {
                Enquiry__c enq = new Enquiry__c(Id = enqId);
                enq.SO_Count__c = enquirySOCountMap.containsKey(enqId) ? enquirySOCountMap.get(enqId) : 0;
                enquiriesToUpdate.add(enq);
            }
            
            if (!enquiriesToUpdate.isEmpty()) {
                update enquiriesToUpdate;
            }
        }
    }
    
    // Method to update SO_Count__c when a Sales_Order__c is inserted
    public static void updateSOCountOnSalesOrder(List<Sales_Order__c> salesOrders) {
        
        Set<Id> enquiryIds = new Set<Id>();
        
        for (Sales_Order__c so : salesOrders) {
            if (so.Enquiry__c != null) {
                enquiryIds.add(so.Enquiry__c);
            }
        }
        
        if (!enquiryIds.isEmpty()) {
            updateSOCount([SELECT Id FROM Enquiry__c WHERE Id IN :enquiryIds]);
        }
    }
}