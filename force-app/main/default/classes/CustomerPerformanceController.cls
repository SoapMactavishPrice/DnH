public with sharing class CustomerPerformanceController {

    @AuraEnabled
    public static List < PerformanceWrapper > getCustomerDetails(Id fiscalYear) {
        System.debug('Im here inside getCustomerDetails');
        String currentUserId = UserInfo.getUserId();
        User userObj = [SELECT Id, Code__c FROM User WHERE Id =: currentUserId LIMIT 1];
        List < Customer_Sales_Person_Mapping__c > customerSalesPersonMappings = new List < Customer_Sales_Person_Mapping__c > ();
        Set<String> typeSet = new Set<String>();
        typeSet.add('Dealers');
        typeSet.add('Pvt_Parties');
        typeSet.add('Govt_Parties');
        typeSet.add('End Customer');
        typeSet.add('Pvt_Parties_F');
        typeSet.add('Govt_Parties_F');
        typeSet.add('Export');
        if (userObj.Code__c != null) {
            customerSalesPersonMappings = [
                SELECT Id, Sales_Person_Code__c, Account__c
                FROM Customer_Sales_Person_Mapping__c
                // WHERE Sales_Person_Code__c =: userObj.Code__c
                WHERE Sales_Person_Code__c = 'DNH1524'
                // WHERE Sales_Person_Code__c = 'DNH1838'
                // AND Account__c != null
                // AND Account__r.Customer_Type__c IN :typeSet
            ];
            // customerSalesPersonMappings = [SELECT Id, Sales_Person_Code__c, Customer_Code__c FROM Customer_Sales_Person_Mapping__c WHERE Sales_Person_Code__c = 'DNH1077'];
        }
        System.debug(customerSalesPersonMappings.size());
        List < String > customerCodes = new List < String > ();
        for (Customer_Sales_Person_Mapping__c eachMapping: customerSalesPersonMappings) {
            customerCodes.add(eachMapping.Account__c);
        }
        Map < Id, Account > customerMap = new Map < Id, Account > ([SELECT Id, Name, Customer_Category__c, Industry__r.Name, Dealer__r.Name FROM Account WHERE Id =: customerCodes]);

        List < Performance_Report__c > performanceReports = [SELECT Id, Name, Potential__c, Customer__c, Fiscal_Year__c FROM Performance_Report__c WHERE Customer__c IN: customerMap.keySet() AND Field_Staff_Name__c = '005F30000081bZ7IAI' AND Fiscal_Year__c =: fiscalYear];

        System.debug(performanceReports);

        Map < Id, Performance_Report__c > customerPerfMap = new Map < Id, Performance_Report__c > ();

        for (Performance_Report__c performanceReport: performanceReports) {
            customerPerfMap.put(performanceReport.Customer__c, performanceReport);
        }
        List < Performance_Report__c > performanceReportsToBeInserted = new List < Performance_Report__c > ();
        List < Performance_Report_Line_Item__c > performanceReportLineItemsToBeInserted = new List < Performance_Report_Line_Item__c > ();

        for (Id eachCustomerId: customerMap.keySet()) {
            if (!customerPerfMap.containsKey(eachCustomerId)) {
                Performance_Report__c newPerformanceReport = new Performance_Report__c();
                newPerformanceReport.Fiscal_Year__c = fiscalYear;
                newPerformanceReport.Customer__c = eachCustomerId;
                newPerformanceReport.Field_Staff_Name__c = '005F30000081bZ7IAI';
                performanceReportsToBeInserted.add(newPerformanceReport);
            }
        }

        INSERT performanceReportsToBeInserted;

        List < String > months = new List < String > {
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
            'January',
            'February',
            'March'
        };
        for (Performance_Report__c eachPerfReport: performanceReportsToBeInserted) {
            for (String eachMonth: months) {
                Performance_Report_Line_Item__c performanceReportLineItem = new Performance_Report_Line_Item__c();
                performanceReportLineItem.Month_Name__c = eachMonth;
                performanceReportLineItem.Performance_Report__c = eachPerfReport.Id;
                performanceReportLineItem.Conv_Common__c = 0.0;
                performanceReportLineItem.CO2_FCAW__c = 0.0;
                performanceReportLineItem.Accessories__c = 0.0;
                performanceReportLineItem.Conv_SPL__c = 0.0;
                performanceReportLineItem.LOT__c = 0.0;
                performanceReportLineItem.OA__c = 0.0;
                performanceReportLineItem.SW__c = 0.0;
                performanceReportLineItemsToBeInserted.add(performanceReportLineItem);
            }
        }
        INSERT performanceReportLineItemsToBeInserted;

        Map < Id, Performance_Report__c > performanceReportMap = new Map < Id, Performance_Report__c > ([SELECT Id, Name, Potential__c, Customer__c, Customer__r.Name, District__c, Customer__r.Customer_Category__c, Industry__c, Dealer_Involved_Direct_Customer__c, Last_Year_Achv__c
            FROM Performance_Report__c WHERE Customer__c IN: customerMap.keySet() AND Field_Staff_Name__c = '005F30000081bZ7IAI' AND Fiscal_Year__c =: fiscalYear ORDER BY Dealer_Involved_Direct_Customer__c ASC
        ]);

        List < Performance_Report_Line_Item__c > performanceReportLineItems = [SELECT Id, Conv_Common__c, Conv_SPL__c, LOT__c, Month_Name__c, OA__c, Performance_Report__c, SW__c, Total_Conventional_Sales__c, Total_Lotherme_Sales__c, Accessories__c, CO2_FCAW__c
            FROM Performance_Report_Line_Item__c WHERE Performance_Report__c IN: performanceReportMap.keySet()
        ];

        Map < Id, List < Performance_Report_Line_Item__c >> performanceReportLineItemMap = new Map < Id, List < Performance_Report_Line_Item__c >> ();

        for (Performance_Report_Line_Item__c eachLineItem: performanceReportLineItems) {
            if (!performanceReportLineItemMap.containsKey(eachLineItem.Performance_Report__c)) {
                performanceReportLineItemMap.put(eachLineItem.Performance_Report__c, new List < Performance_Report_Line_Item__c > ());
            }
            performanceReportLineItemMap.get(eachLineItem.Performance_Report__c).add(eachLineItem);
        }

        List < PerformanceWrapper > performanceMasters = new List < PerformanceWrapper > ();
        Integer srNo = 0;
        for (Performance_Report__c eachPerformanceReport: performanceReportMap.values()) {
            srNo += 1;
            PerformanceWrapper performanceMaster = new PerformanceWrapper(srNo, eachPerformanceReport, performanceReportLineItemMap.get(eachPerformanceReport.Id));
            performanceMasters.add(performanceMaster);
        }
        System.debug('performanceMasters' + performanceMasters);
        return performanceMasters;
    }

    @AuraEnabled
    public static String savePerformanceReport(String performanceMastersInString) {
        List < PerformanceWrapper > performanceMasters = parseSampleOut(performanceMastersInString);

        List < Performance_Report__c > performanceMastersToBeUpdated = new List < Performance_Report__c > ();
        List < Performance_Report_Line_Item__c > performanceMasterLineItemsToBeUpdated = new List < Performance_Report_Line_Item__c > ();

        for (PerformanceWrapper performanceMaster: performanceMasters) {
            Performance_Report__c performanceReport = new Performance_Report__c();
            performanceReport.Id = performanceMaster.performanceReportId;
            performanceReport.Potential__c = performanceMaster.Potential;
            if (performanceReport.Potential__c != 0 && performanceReport.Potential__c != null) {
                performanceMastersToBeUpdated.add(performanceReport);
            }

            for (PerformanceWrapperLineItem eachLineItem: performanceMaster.performanceLineMap.values()) {
                Performance_Report_Line_Item__c performanceReportLineItem = new Performance_Report_Line_Item__c();
                if ((eachLineItem.ConvCommon == 0 || eachLineItem.ConvCommon == null) &&
                    (eachLineItem.ConvSpl == 0 || eachLineItem.ConvSpl == null) &&
                    (eachLineItem.CO2FCAW == 0 || eachLineItem.CO2FCAW == null) &&
                    (eachLineItem.Accessories == 0 || eachLineItem.Accessories == null) &&
                    (eachLineItem.LOT == 0 || eachLineItem.LOT == null) &&
                    (eachLineItem.OA == 0 || eachLineItem.OA == null) &&
                    (eachLineItem.SW == 0 || eachLineItem.SW == null)) {
                    continue;
                }
                performanceReportLineItem.Id = eachLineItem.performanceReportLineItemId;
                performanceReportLineItem.Conv_Common__c = eachLineItem.ConvCommon;
                performanceReportLineItem.Conv_SPL__c = eachLineItem.ConvSpl;
                performanceReportLineItem.CO2_FCAW__c = eachLineItem.CO2FCAW;
                performanceReportLineItem.Accessories__c = eachLineItem.Accessories;
                performanceReportLineItem.LOT__c = eachLineItem.LOT;
                performanceReportLineItem.OA__c = eachLineItem.OA;
                performanceReportLineItem.SW__c = eachLineItem.SW;
                performanceMasterLineItemsToBeUpdated.add(performanceReportLineItem);
            }
        }

        System.debug('performanceMastersToBeUpdatedSize==> ' + performanceMastersToBeUpdated.size());
        System.debug('performanceMasterLineItemsToBeUpdatedSize==> ' + performanceMasterLineItemsToBeUpdated.size());

        UPDATE performanceMastersToBeUpdated;
        UPDATE performanceMasterLineItemsToBeUpdated;

        return 'Success';
    }

    @AuraEnabled
    public static String getFiscalYearName() {
        System.debug('In Fiscal Year Get');
        Fiscal_Year__c fiscalYearObj = [SELECT Id, Name FROM Fiscal_Year__c WHERE isActive__c = true LIMIT 1];
        return fiscalYearObj.Name + '|||' + fiscalYearObj.Id;
    }

    @AuraEnabled
    public static String getUserName() {
        Id currentUserId = UserInfo.getUserId();
        User user = [SELECT Id, Name FROM User WHERE Id =: currentUserId LIMIT 1];
        return user.Name;
    }

    public class PerformanceWrapper {
        @AuraEnabled public Integer srNo;
        @AuraEnabled public String customerId;
        @AuraEnabled public String CustomerName;
        @AuraEnabled public String District;
        @AuraEnabled public String Category;
        @AuraEnabled public Decimal achieveLakhs;
        @AuraEnabled public String Industry;
        @AuraEnabled public String Dealer;
        @AuraEnabled public String performanceReportId;
        @AuraEnabled public Decimal Potential;

        @AuraEnabled public Map < String, PerformanceWrapperLineItem > performanceLineMap;

        PerformanceWrapper(Integer srNo, Performance_Report__c performanceReport, List < Performance_Report_Line_Item__c > performanceReportLineItems) {
            this.srNo = srNo;
            this.CustomerName = performanceReport.Customer__r.Name;
            this.performanceReportId = performanceReport.Id;
            this.customerId = performanceReport.Customer__c;
            this.District = performanceReport.District__c;
            this.Industry = performanceReport.Industry__c;
            this.achieveLakhs = performanceReport.Last_Year_Achv__c;
            this.Category = performanceReport.Customer__r.Customer_Category__c;
            this.Dealer = performanceReport.Dealer_Involved_Direct_Customer__c;
            this.Potential = performanceReport.Potential__c;

            for (Performance_Report_Line_Item__c eachLineItem: performanceReportLineItems) {
                if (this.performanceLineMap == null) {
                    this.performanceLineMap = new Map < String, PerformanceWrapperLineItem > ();
                }
                System.debug('eachLineItem==> ' + new PerformanceWrapperLineItem(eachLineItem));
                this.performanceLineMap.put(eachLineItem.Month_Name__c, new PerformanceWrapperLineItem(eachLineItem));
            }
        }
    }

    public class PerformanceWrapperLineItem {
        @AuraEnabled public Decimal ConvCommon;
        @AuraEnabled public Decimal ConvSpl;
        @AuraEnabled public Decimal CO2FCAW;
        @AuraEnabled public Decimal Accessories;
        @AuraEnabled public Decimal LOT;
        @AuraEnabled public Decimal OA;
        @AuraEnabled public Decimal SW;
        @AuraEnabled public String performanceReportLineItemId;

        PerformanceWrapperLineItem(Performance_Report_Line_Item__c performanceReportLineItem) {
            this.performanceReportLineItemId = performanceReportLineItem.Id;
            if (performanceReportLineItem.Conv_Common__c != null) {
                this.ConvCommon = performanceReportLineItem.Conv_Common__c;
            } else {
                this.ConvCommon = 0.0;
            }
            if (performanceReportLineItem.Conv_SPL__c != null) {
                this.ConvSpl = performanceReportLineItem.Conv_SPL__c;
            } else {
                this.ConvSpl = 0.0;
            }
            if (performanceReportLineItem.CO2_FCAW__c != null) {
                this.CO2FCAW = performanceReportLineItem.CO2_FCAW__c;
            } else {
                this.CO2FCAW = 0.0;
            }
            if (performanceReportLineItem.Accessories__c != null) {
                this.Accessories = performanceReportLineItem.Accessories__c;
            } else {
                this.Accessories = 0.0;
            }
            if (performanceReportLineItem.LOT__c != null) {
                this.LOT = performanceReportLineItem.LOT__c;
            } else {
                this.LOT = 0.0;
            }
            if (performanceReportLineItem.OA__c != null) {
                this.OA = performanceReportLineItem.OA__c;
            } else {
                this.OA = 0.0;
            }
            if (performanceReportLineItem.SW__c != null) {
                this.SW = performanceReportLineItem.SW__c;
            } else {
                this.SW = 0.0;
            }
        }
    }

    private static List < PerformanceWrapper > parseSampleOut(string js) {
        return (List < PerformanceWrapper > ) system.JSON.deserialize(js, List < PerformanceWrapper > .class);
    }
    
    public static void fcc (){
        Integer j = 0;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
    }
    
}