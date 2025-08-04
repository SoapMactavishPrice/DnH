public with sharing class AccDetails {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchData(String accID) {
        Map<String, Object> result = new Map<String, Object>();

        // Fetch account data
        Account acc = fetchAccountData(accID);
        result.put('account', acc);

        // Fetch counts
        Integer taskCount = getTaskCount(accID);
        Integer eventCount = getEventCount(accID);
        Integer salesOrderCount = getTotalSalesOrders(accID);
        Integer enquiryCount = getTotalEnquiries(accID);

        // Fetch days since last order
        Integer daysSinceLastOrder = getDaysSinceLastOrder(accID);

        // Prepare data to return
        result.put('taskCount', taskCount);
        result.put('eventCount', eventCount);
        result.put('salesOrderCount', salesOrderCount);
        result.put('enquiryCount', enquiryCount);
        result.put('daysSinceLastOrder', daysSinceLastOrder);

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Account fetchAccountData(String accID) {
        return [
            SELECT Id, 
                   Available_Credit_Limit__c, 
                   Open_Orders__c, 
                   Payment_Received__c, 
                   Outstanding_Invoices__c 
            FROM Account 
            WHERE Id = :accID 
            LIMIT 1
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getTaskCount(String accID) {
        return [SELECT COUNT() FROM Task WHERE WhatId = :accID];
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getEventCount(String accID) {
        return [SELECT COUNT() FROM Event WHERE WhatId = :accID];
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getDaysSinceLastOrder(String accID) {
        Integer daysSinceLastOrder = 0;
        
        List<Sales_Order__c> orders = [
            SELECT CreatedDate 
            FROM Sales_Order__c 
            WHERE Account__c = :accID 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        if (!orders.isEmpty()) {
            Date lastOrderDate = orders[0].CreatedDate.date();
            Date today = Date.today();
            daysSinceLastOrder = lastOrderDate.daysBetween(today);
        }
        
        return daysSinceLastOrder;
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getTotalSalesOrders(String accID) {
        Integer totalOrders = [
            SELECT COUNT() 
            FROM Sales_Order__c 
            WHERE Account__c = :accID
        ];
        
        return totalOrders;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalEnquiries(String accID) {
        Integer totalEnquiries = [
            SELECT COUNT() 
            FROM Enquiry__c 
            WHERE Account__c = :accID
        ];
        
        return totalEnquiries;
    }
}