trigger SetFiscalYearOnSalesRegister on Sales_Register__c (before insert, before update) {
    
    // Step 1: Check if any records need fiscal year or user mapping
    Boolean needsProcessing = false;
    Set<String> salesEngineerIds = new Set<String>();

    for (Sales_Register__c sr : Trigger.new) {
        if ((sr.Fiscal_Year__c == null && sr.Posting_Date__c != null) || sr.Sales_Engineer_Id__c != null) {
            needsProcessing = true;
            if (sr.Sales_Engineer_Id__c != null) {
                salesEngineerIds.add(sr.Sales_Engineer_Id__c);
            }
        }
    }

    if (!needsProcessing) return;

    // Step 2: Query Fiscal Year records
    List<Fiscal_Year__c> fiscalYears = [
        SELECT Id, FY_Start_Date__c, FY_End_Date__c
        FROM Fiscal_Year__c
        WHERE FY_Start_Date__c != null AND FY_End_Date__c != null
        ORDER BY FY_Start_Date__c ASC
    ];

    // Step 3: Query Users by Code__c
    Map<String, User> userMap = new Map<String, User>();
    if (!salesEngineerIds.isEmpty()) {
        for (User u : [
            SELECT Id, Code__c
            FROM User
            WHERE Code__c IN :salesEngineerIds
        ]) {
            userMap.put(u.Code__c, u);
        }
    }

    // Step 4: Loop and update Sales_Register__c records
    for (Sales_Register__c sr : Trigger.new) {
        // Set Fiscal Year
        if (sr.Fiscal_Year__c == null && sr.Posting_Date__c != null) {
            for (Fiscal_Year__c fy : fiscalYears) {
                if (sr.Posting_Date__c >= fy.FY_Start_Date__c &&
                    sr.Posting_Date__c <= fy.FY_End_Date__c) {
                    sr.Fiscal_Year__c = fy.Id;
                    break;
                }
            }
        }

        // Set Owner and Sales Engineer (lookup)
        if (sr.Sales_Engineer_Id__c != null && userMap.containsKey(sr.Sales_Engineer_Id__c)) {
            User matchedUser = userMap.get(sr.Sales_Engineer_Id__c);
            sr.OwnerId = matchedUser.Id;
            sr.Sales_Engineer_Name__c = matchedUser.Id; // lookup to User
        }
    }
}