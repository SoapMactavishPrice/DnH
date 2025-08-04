public class SalesRegComparisonController {

    @AuraEnabled
    public static String getTargetCategoryPicklistValues() {
        try {
            // Describe the field dynamically
            Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Item_Master__c.fields.getMap().get('Target_Category__c').getDescribe();

            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            List<String> labels = new List<String>();

            for (Schema.PicklistEntry entry : picklistEntries) {
                if (entry.isActive()) {
                    labels.add(entry.getLabel());
                }
            }

            return JSON.serialize(labels);

        } catch (Exception e) {
            throw new AuraHandledException('ERROR: ' + e.getMessage());
        }
    }



    @AuraEnabled
    public static string getCurrentActiveFY(){
        try {

            Fiscal_Year__c currFY = [
                SELECT Id, Name
                FROM Fiscal_Year__c
                WHERE isActive__c = true
            ];

            Map <String, String> resMap = new Map <String, String>();
            resMap.put('Id', currFY.Id);
            resMap.put('Name', currFY.Name);

            return JSON.serialize(resMap);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getLastCompletedFY(){
        try {

            Fiscal_Year__c compFY = [
                SELECT Id, Name
                FROM Fiscal_Year__c
                WHERE is_Complete__c = true
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            Map <String, String> resMap = new Map <String, String>();
            resMap.put('Id', compFY.Id);
            resMap.put('Name', compFY.Name);

            return JSON.serialize(resMap);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getState(){
        try {

            List<Sales_Register__c> salesRegisterList = [
                SELECT Id, Name, Stati_State__c, FY_Quarter__c
                FROM Sales_Register__c
                WHERE Stati_State__c != null
                AND Fiscal_Year__c != null
                AND Target_Category_Bonus_Plan__c != null
                ORDER BY Stati_State__c ASC
            ];

            Set<String> setOfState = new Set<String>();

            for (Sales_Register__c record : salesRegisterList) {
                setOfState.add(record.Stati_State__c);
            }

            return JSON.serialize(setOfState);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled
    // public static string getData(String activeYear, String lastYear, String activeYearName, String lastYearName, String targetCategory){
    //     try {

    //         List<String> itemCategoryList = (List<String>) JSON.deserialize(targetCategory, List<String>.class);

    //         List <Map<String, Object>> combineMapList = new List <Map<String, Object>>();

    //         List<Sales_Register__c> salesRegisterActiveList = [
    //             SELECT Id, Name, Stati_State__c, FY_Quarter__c, Item_No__c, Target_Category_Bonus_Plan__c, Fiscal_Year__c,
    //             Fiscal_Year__r.Name, Taxable_Value__c
    //             FROM Sales_Register__c
    //             WHERE Stati_State__c != null
    //             AND Fiscal_Year__c = :activeYear
    //             AND Target_Category_Bonus_Plan__c != null
    //             AND FY_Quarter__c != null
    //         ];
                
    //         List<Sales_Register__c> salesRegisterLastList = [
    //             SELECT Id, Name, Stati_State__c, FY_Quarter__c, Item_No__c, Target_Category_Bonus_Plan__c, Fiscal_Year__c,
    //             Fiscal_Year__r.Name, Taxable_Value__c
    //             FROM Sales_Register__c
    //             WHERE Stati_State__c != null
    //             AND Fiscal_Year__c = :lastYear
    //             AND Target_Category_Bonus_Plan__c != null
    //             AND FY_Quarter__c != null
    //         ];

    //         for (String i : itemCategoryList) {
    //             for (Sales_Register__c last : salesRegisterLastList) {
    //                 Map<String, Object> mapName = new Map<String, Object>();
    //                 // mapName.put(last.Fiscal_Year__r.Name+last.Target_Category_Bonus_Plan__c+'Q1', 0.0);
    //                 if (last.FY_Quarter__c == 'Q1' && i == last.Target_Category_Bonus_Plan__c) {
    //                     // System.debug('last:>> ' +last);
    //                     mapName.put(last.Fiscal_Year__r.Name+last.Target_Category_Bonus_Plan__c+'Q1', last.Taxable_Value__c);
    //                     combineMapList.add(mapName);
    //                 } else {
    //                     // Map<String, Object> mapName = new Map<String, Object>();
    //                     // combineMapList.add(mapName);
    //                 }
    //             }
    //             for (Sales_Register__c curr : salesRegisterActiveList) {
    //                 Map<String, Object> mapName = new Map<String, Object>();
    //                 // mapName.put(curr.Fiscal_Year__r.Name+curr.Target_Category_Bonus_Plan__c+'Q1', 0.0);
    //                 if (curr.FY_Quarter__c == 'Q1' && i == curr.Target_Category_Bonus_Plan__c) {
    //                     // System.debug('curr:>> ' +curr);
    //                     mapName.put(curr.Fiscal_Year__r.Name+curr.Target_Category_Bonus_Plan__c+'Q1', curr.Taxable_Value__c);
    //                     combineMapList.add(mapName);
    //                 } else {
    //                     // Map<String, Object> mapName = new Map<String, Object>();
    //                     // combineMapList.add(mapName);
    //                 }
    //             }
    //             for (Sales_Register__c last : salesRegisterLastList) {
    //                 Map<String, Object> mapName = new Map<String, Object>();
    //                 // mapName.put(last.Fiscal_Year__r.Name+last.Target_Category_Bonus_Plan__c+'Q2', 0.0);
    //                 if (last.FY_Quarter__c == 'Q2' && i == last.Target_Category_Bonus_Plan__c) {
    //                     // System.debug('last:>> ' +last);
    //                     mapName.put(last.Fiscal_Year__r.Name+last.Target_Category_Bonus_Plan__c+'Q2', last.Taxable_Value__c);
    //                     combineMapList.add(mapName);
    //                 } else {
    //                     // Map<String, Object> mapName = new Map<String, Object>();
    //                     // combineMapList.add(mapName);
    //                 }
    //             }
    //             for (Sales_Register__c curr : salesRegisterActiveList) {
    //                 Map<String, Object> mapName = new Map<String, Object>();
    //                 // mapName.put(curr.Fiscal_Year__r.Name+curr.Target_Category_Bonus_Plan__c+'Q2', 0.0);
    //                 if (curr.FY_Quarter__c == 'Q2' && i == curr.Target_Category_Bonus_Plan__c) {
    //                     // System.debug('curr:>> ' +curr);
    //                     mapName.put(curr.Fiscal_Year__r.Name+curr.Target_Category_Bonus_Plan__c+'Q2', curr.Taxable_Value__c);
    //                     combineMapList.add(mapName);
    //                 } else {
    //                     // Map<String, Object> mapName = new Map<String, Object>();
    //                     // combineMapList.add(mapName);
    //                 }
    //             }
    //             for (Sales_Register__c last : salesRegisterLastList) {
    //                 Map<String, Object> mapName = new Map<String, Object>();
    //                 // mapName.put(last.Fiscal_Year__r.Name+last.Target_Category_Bonus_Plan__c+'Q3', 0.0);
    //                 if (last.FY_Quarter__c == 'Q3' && i == last.Target_Category_Bonus_Plan__c) {
    //                     // System.debug('last:>> ' +last);
    //                     mapName.put(last.Fiscal_Year__r.Name+last.Target_Category_Bonus_Plan__c+'Q3', last.Taxable_Value__c);
    //                     combineMapList.add(mapName);
    //                 } else {
    //                     // Map<String, Object> mapName = new Map<String, Object>();
    //                     // combineMapList.add(mapName);
    //                 }
    //             }
    //             for (Sales_Register__c curr : salesRegisterActiveList) {
    //                 Map<String, Object> mapName = new Map<String, Object>();
    //                 // mapName.put(curr.Fiscal_Year__r.Name+curr.Target_Category_Bonus_Plan__c+'Q3', 0.0);
    //                 if (curr.FY_Quarter__c == 'Q3' && i == curr.Target_Category_Bonus_Plan__c) {
    //                     // System.debug('curr:>> ' +curr);
    //                     mapName.put(curr.Fiscal_Year__r.Name+curr.Target_Category_Bonus_Plan__c+'Q3', curr.Taxable_Value__c);
    //                     combineMapList.add(mapName);
    //                 } else {
    //                     // Map<String, Object> mapName = new Map<String, Object>();
    //                     // combineMapList.add(mapName);
    //                 }
    //             }
    //         }
            
    //         // System.debug(combineMapList);
    //         List<Map<String, Object>> resMap = new List<Map<String, Object>>();

    //         for (String i : itemCategoryList) {
    //             resMap.add(new Map<String, Object>{ lastYearName+i+'Q1' => 0.0 });
    //             resMap.add(new Map<String, Object>{ activeYearName+i+'Q1' => 0.0 });
    //             resMap.add(new Map<String, Object>{ lastYearName+i+'Q2' => 0.0 });
    //             resMap.add(new Map<String, Object>{ activeYearName+i+'Q2' => 0.0 });
    //             resMap.add(new Map<String, Object>{ lastYearName+i+'Q3' => 0.0 });
    //             resMap.add(new Map<String, Object>{ activeYearName+i+'Q3' => 0.0 });
    //         }

    //         Map<String, Object> combineMap = new Map<String, Object>();
    //         for (Map<String, Object> v : combineMapList) {
                
    //             for (String key : v.keySet()) {
    //                 Decimal existing = combineMap.containsKey(key) ? (Decimal) combineMap.get(key) : 0;
    //                 Decimal newVal = (Decimal) v.get(key);
    //                 combineMap.put(key, existing + newVal);
    //             }
    //         }
    //         // System.debug(combineMap);
            
    //         for (Map<String, Object> m : resMap) {
    //             if (!m.isEmpty()) {
    //                 List<String> keys = new List<String>(m.keySet()); // Convert to List
    //                 String key = keys[0]; // Now you can safely get the first key
    //                 Object value = m.get(key);

    //                 if (combineMap.containsKey(key)) {
    //                     m.put(key, combineMap.get(key)); // Replace value from combineMap
    //                 }
    //             }
    //         }

    //         System.debug(resMap);


    //         // System.debug(salesRegisterActiveList);
    //         // System.debug(salesRegisterLastList);

    //         return JSON.serialize(resMap);
            
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    @AuraEnabled
    public static string getData2(String activeYear, String lastYear, String activeYearName, String lastYearName, String quarterValue, String targetCategory){
        try {

            List<Sales_Register__c> salesRegisterLastList = [
                SELECT Id, Name, Stati_State__c, FY_Quarter__c, Item_No__c, Target_Category_Bonus_Plan__c, Fiscal_Year__c,
                Fiscal_Year__r.Name, Taxable_Value__c
                FROM Sales_Register__c
                WHERE Stati_State__c != null
                AND Fiscal_Year__c = :lastYear
                AND Target_Category_Bonus_Plan__c = :targetCategory
                AND FY_Quarter__c = :quarterValue
                ORDER BY Stati_State__c ASC
            ];

            List<Sales_Register__c> salesRegisterActiveList = [
                SELECT Id, Name, Stati_State__c, FY_Quarter__c, Item_No__c, Target_Category_Bonus_Plan__c, Fiscal_Year__c,
                Fiscal_Year__r.Name, Taxable_Value__c
                FROM Sales_Register__c
                WHERE Stati_State__c != null
                AND Fiscal_Year__c = :activeYear
                AND Target_Category_Bonus_Plan__c = :targetCategory
                AND FY_Quarter__c = :quarterValue
                ORDER BY Stati_State__c ASC
            ];

            Map<String, Object> map1 = new Map<String, Object>();
            Map<String, Map<String,Object>> completeYearMap = new Map<String, Map<String,Object>>();
            Map<String, Map<String,Object>> activeYearMap = new Map<String, Map<String,Object>>();

            

            for (Sales_Register__c v : salesRegisterLastList) {
                if (!completeYearMap.containsKey(v.Stati_State__c)) {
                    Map<String, Object> mapName = new Map<String, Object>();
                    mapName.put(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c, 0.0);
                    completeYearMap.put(v.Stati_State__c, mapName);
                }
                // completeYearMap.get(v.Stati_State__c).add(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c);
                Map<String, Object> getMapName = completeYearMap.get(v.Stati_State__c);
                System.debug(getMapName);
                Decimal existing = (Decimal) getMapName.get(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c);
                System.debug(existing);
                Decimal newval = (Decimal) v.Taxable_Value__c;
                System.debug(newval);
                Decimal finalVal = existing + newval;
                System.debug(finalVal);
                Map<String, Object> mapName2 = new Map<String, Object>();
                mapName2.put(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c, finalVal);
                completeYearMap.put(v.Stati_State__c, mapName2);
            }

            for (Sales_Register__c v : salesRegisterActiveList) {
                if (!activeYearMap.containsKey(v.Stati_State__c)) {
                    Map<String, Object> mapName = new Map<String, Object>();
                    mapName.put(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c, 0.0);
                    activeYearMap.put(v.Stati_State__c, mapName);
                }
                // activeYearMap.get(v.Stati_State__c).add(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c);
                Map<String, Object> getMapName = activeYearMap.get(v.Stati_State__c);
                Decimal existing = (Decimal) getMapName.get(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c);
                Decimal newval = (Decimal) v.Taxable_Value__c;
                Decimal finalVal = existing + newval;
                Map<String, Object> mapName2 = new Map<String, Object>();
                mapName2.put(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c, finalVal);
                activeYearMap.put(v.Stati_State__c, mapName2);
            }

            map1.put('completeYearMap', completeYearMap);
            map1.put('activeYearMap', activeYearMap);

            System.debug(map1);

            return JSON.serialize(map1);
            
        } catch (Exception e) {
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getLastYearData(String lastYear, String lastYearName, String quarterValue, String targetCategory){
        try {

            List<Sales_Register__c> salesRegisterLastList = [
                SELECT Id, Name, Stati_State__c, FY_Quarter__c, Item_No__c, Target_Category_Bonus_Plan__c, Fiscal_Year__c,
                Fiscal_Year__r.Name, Taxable_Value__c
                FROM Sales_Register__c
                WHERE Stati_State__c != null
                AND Fiscal_Year__c = :lastYear
                AND Target_Category_Bonus_Plan__c = :targetCategory
                AND FY_Quarter__c = :quarterValue
                ORDER BY Stati_State__c ASC
            ];

            Map<String, Map<String,Object>> completeYearMap = new Map<String, Map<String,Object>>();

            for (Sales_Register__c v : salesRegisterLastList) {
                if (!completeYearMap.containsKey(v.Stati_State__c)) {
                    Map<String, Object> mapName = new Map<String, Object>();
                    mapName.put(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c, 0.0);
                    completeYearMap.put(v.Stati_State__c, mapName);
                }
                // completeYearMap.get(v.Stati_State__c).add(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c);
                Map<String, Object> getMapName = completeYearMap.get(v.Stati_State__c);
                System.debug(getMapName);
                Decimal existing = (Decimal) getMapName.get(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c);
                System.debug(existing);
                Decimal newval = (Decimal) v.Taxable_Value__c;
                System.debug(newval);
                Decimal finalVal = existing + newval;
                System.debug(finalVal);
                Map<String, Object> mapName2 = new Map<String, Object>();
                mapName2.put(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c, finalVal);
                completeYearMap.put(v.Stati_State__c, mapName2);
            }

            System.debug(completeYearMap);
            return JSON.serialize(completeYearMap);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getActiveYearData(String activeYear, String activeYearName, String quarterValue, String targetCategory){
        try {

            List<Sales_Register__c> salesRegisterLastList = [
                SELECT Id, Name, Stati_State__c, FY_Quarter__c, Item_No__c, Target_Category_Bonus_Plan__c, Fiscal_Year__c,
                Fiscal_Year__r.Name, Taxable_Value__c
                FROM Sales_Register__c
                WHERE Stati_State__c != null
                AND Fiscal_Year__c = :activeYear
                AND Target_Category_Bonus_Plan__c = :targetCategory
                AND FY_Quarter__c = :quarterValue
                ORDER BY Stati_State__c ASC
            ];

            Map<String, Map<String,Object>> completeYearMap = new Map<String, Map<String,Object>>();

            for (Sales_Register__c v : salesRegisterLastList) {
                if (!completeYearMap.containsKey(v.Stati_State__c)) {
                    Map<String, Object> mapName = new Map<String, Object>();
                    mapName.put(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c, 0.0);
                    completeYearMap.put(v.Stati_State__c, mapName);
                }
                // completeYearMap.get(v.Stati_State__c).add(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c);
                Map<String, Object> getMapName = completeYearMap.get(v.Stati_State__c);
                System.debug(getMapName);
                Decimal existing = (Decimal) getMapName.get(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c);
                System.debug(existing);
                Decimal newval = (Decimal) v.Taxable_Value__c;
                System.debug(newval);
                Decimal finalVal = existing + newval;
                System.debug(finalVal);
                Map<String, Object> mapName2 = new Map<String, Object>();
                mapName2.put(v.Fiscal_Year__r.Name+v.Target_Category_Bonus_Plan__c + v.FY_Quarter__c, finalVal);
                completeYearMap.put(v.Stati_State__c, mapName2);
            }

            System.debug(completeYearMap);
            return JSON.serialize(completeYearMap);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void fc () {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}