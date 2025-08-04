public with sharing class TargetModule {

  public TargetModule() {

    }

    @AuraEnabled(cacheable = true)
    public static string getDefaultFilterValues() {
        try {
            Map < String, Object > result = new Map < String, Object > ();
            result.put('Fiscal_Year__c', [SELECT Id FROM Fiscal_Year__c WHERE isActive__c = true LIMIT 1].Id);

            Map < Id, List < Map < String, String >>> userMapCompanyWise = new Map < Id, List < Map < String, String >>> ();
            for (User u: [SELECT Id, Name FROM User]) { // DataCls.getUserMaster()
                Map < String, String > tempMap = new Map < String, String > ();
                {
                    List < Map < String, String >> tempList = new List < Map < String, String >> ();
                    tempMap.put('label', u.Name);
                    tempMap.put('value', u.Id);
                    tempList.add(tempMap);
                    userMapCompanyWise.put(u.Id, tempList);
                }
            }
            System.debug('Before====>' + result);
            result.put('userMapCompanyWise', userMapCompanyWise);
            System.debug('A====>' + result);

            return JSON.serialize(result);
        } catch (Exception e) {            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    }

    @AuraEnabled
    public static string getYearly(String prodId, String fiscId, String empId, String parentTab, String prodCatVal) {
        try {

            system.debug('prodId' + prodId);
            system.debug('fiscId' + fiscId);
            system.debug('empId' + empId);
            system.debug('parentTab' + parentTab);

            if (String.isBlank(fiscId) || String.isBlank(parentTab)) {                return '{}';
            }

            Boolean isComplete = [select is_Complete__c from Fiscal_Year__c where Id =: fiscId].is_Complete__c;

            Map < String, Object > result = new Map < String, Object > ();
            List < Map < String, Object >> parameterData = new List < Map < String, Object >> ();

            Set < String > masterRecordIds = new Set < String > ();
            Integer index = 0;

            String queryFront = '';
            String whr = '';
            String ordBy = ' ORDER BY Name ASC ';

            whr += ' WHERE Fiscal_Year__c = \'' + fiscId + '\' ';
            System.debug(whr);
            system.debug(parentTab + ' ' + masterRecordIds);
            switch on parentTab {

                when 'User_Wise_Target__c' {
                    queryFront = 'SELECT Id, User__c, User__r.Name, ' +
                        'Fiscal_Year__c, Fiscal_Year__r.Name, Fiscal_Year__r.isActive__c, Fiscal_Year__r.is_Complete__c, Fiscal_Year__r.Is_Planning__c, ' +
                        'Target_Amount__c ' +
                        'FROM ' + parentTab + ' ';

                    whr += ' AND User__C IN: masterRecordIds ';

                    //String userQuery = 'SELECT Id, Name, isActive from User WHERE isActive = TRUE AND Profile.UserLicense.Name = \'Salesforce\'';
                    String userQuery = 'SELECT Id, Name, isActive FROM User WHERE isActive = TRUE AND Profile.UserLicense.Name IN (\'Salesforce\', \'Salesforce Platform\') ORDER BY Name ASC';
                    
                    List < User > users = Database.query(userQuery);
                    System.debug(users.size());
                    if (users.size() == 0) {                        return '{}';
                    }

                    for (User u: users) {
                        Map < String, Object > tempMap = new Map < String, Object > ();
                        tempMap.put('ParameterId', u.Id);
                        tempMap.put('ParameterName', u.Name);
                        tempMap.put('ParameterEdit', false);
                        tempMap.put('Target_Amount__c', null);
                        tempMap.put('Target_Amount_New__c', null);
                        tempMap.put('targetAmountEdit', !isComplete);

                        parameterData.add(tempMap);
                        masterRecordIds.add(u.Id);
                    }
                }

            /*    when 'Employee_Wise_Product_Target__c' {
                    queryFront = 'SELECT Id, Name, Item_Master__c, Product__r.Name, User__C,' +
                        'Fiscal_Year__c, Fiscal_Year__r.Name, Fiscal_Year__r.isActive__c, Fiscal_Year__r.is_Complete__c, Fiscal_Year__r.Is_Planning__c, ' +
                        'Target_Amount__c ' +
                        'FROM ' + parentTab + ' ';

                    whr += ' AND User__C =: empId ';
                    whr += ' AND Item_Master__c IN: masterRecordIds ';
                    whr += ' AND Product__r.Family =: prodCatVal ';

                    String ProductQuery = 'SELECT Id, Name, Family from Product2 order by Name ASC';
                    List < Product2 > Product = Database.query(ProductQuery);
                    system.debug('Product' + Product.size());
                    system.debug('Product' + Product);

                    if (Product.size() == 0) {
                        return JSON.serialize(parameterData);

                    }

                    Schema.DescribeFieldResult fieldResult = Employee_Wise_Product_Target__c.Item_Master__c.getDescribe();
                    List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
                    for (Product2 p: Product) {
                        if (p.Family == prodCatVal) {
                            Map < String, Object > tempMap = new Map < String, Object > ();
                            tempMap.put('ParameterId', p.Id);
                            tempMap.put('ParameterName', p.Name);
                            tempMap.put('ParameterEdit', false);
                            tempMap.put('Target_Amount__c', null);
                            tempMap.put('Target_Amount_New__c', null);
                            tempMap.put('targetAmountEdit', !isComplete);
                            masterRecordIds.add(p.Id);
                            parameterData.add(tempMap);
                        }

                    }
                }   */
            
                when 'User_Wise_Product_Category_Target__c' {
                    system.debug('masterRecordIds'+masterRecordIds);
                    queryFront = 'SELECT Id, Product_Category1__c, Product_Category__r.Name, User__C,' +
                        'Fiscal_Year__c, Fiscal_Year__r.Name, Fiscal_Year__r.isActive__c, Fiscal_Year__r.is_Complete__c, Fiscal_Year__r.Is_Planning__c, ' +
                        'Target_Amount__c ' +
                        'FROM ' + parentTab + ' ';

                    whr += ' AND User__C =: empId ';
                    whr += ' AND Product_Category1__c IN: masterRecordIds ';

                    String ProductGroupQuery = 'SELECT Id, Name, Family__C from Item_Master__c order by Family__C ASC';
                    List < Item_Master__c > ProductCategory = Database.query(ProductGroupQuery);
                    system.debug('ProductCategory__HA' + ProductCategory);

                    if (ProductCategory.size() == 0) {
                        return JSON.serialize(parameterData);

                    }

                    //Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
                    Schema.DescribeFieldResult fieldResult = User_Wise_Product_Category_Target__c.Product_Category__c.getDescribe();
                    List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
                    // ======================================== COMMENTED BY HA on 26/02 ========================================
                    Set<String> prodCatSet = new Set<String>();
                    for( Item_Master__c pc:  ProductCategory){
                        
                        prodCatSet.add(pc.Family__C);

                    	// Map<String, Object> tempMap = new Map<String, Object>();
                        // tempMap.put('ParameterId', pc.Id);
                        // tempMap.put('ParameterName', pc.Name);
                        // tempMap.put('ParameterEdit', false);
                        // tempMap.put('Target_Amount__c', null);
                        // tempMap.put('Target_Amount_New__c', null);
                        // tempMap.put('targetAmountEdit', !isComplete);  

                        // parameterData.add(tempMap);
                    }
                    for( String str:  prodCatSet){

                    	Map<String, Object> tempMap = new Map<String, Object>();
                        tempMap.put('ParameterId', str);
                        tempMap.put('ParameterName', str);
                        tempMap.put('ParameterEdit', false);
                        tempMap.put('Target_Amount__c', null);
                        tempMap.put('Target_Amount_New__c', null);
                        tempMap.put('targetAmountEdit', !isComplete);  
                        masterRecordIds.add(str);
                        parameterData.add(tempMap);
                    }

                    // ============================== UMCOMMENTED =================================
                    // for (Product2 u: ProductCategory) {
                    //     Map < String, Object > tempMap = new Map < String, Object > ();
                    //     tempMap.put('ParameterId', u.Id);
                    //     tempMap.put('ParameterName', u.Name);
                    //     tempMap.put('ParameterEdit', false);
                    //     tempMap.put('Target_Amount__c', null);
                    //     tempMap.put('Target_Amount_New__c', null);
                    //     tempMap.put('targetAmountEdit', !isComplete);

                    //     parameterData.add(tempMap);
                    //     masterRecordIds.add(u.Id);
                    // }
                    // ============================== UMCOMMENTED =================================

                }

            }

            String query = queryFront + whr + ordBy;
            System.debug('masterRecordIds:>> ' + masterRecordIds);
            System.debug('query:>> ' + query);
            System.debug('queryex:>> ' + [SELECT Id, Product_Category1__c, Product_Category__r.Name,Fiscal_Year__c, Fiscal_Year__r.Name, Fiscal_Year__r.isActive__c, Fiscal_Year__r.is_Complete__c, 
                                          Fiscal_Year__r.Is_Planning__c, Target_Amount__c FROM User_Wise_Product_Category_Target__c  
                                          WHERE Fiscal_Year__c = 'a0ZF3000007Ica8MAC'  AND Product_Category1__c IN: masterRecordIds  ORDER BY Name ASC]);

            for (sObject record: Database.query(query)) {
                System.debug(record);
                Map < String, Object > tempMap = new Map < String, Object > ();
                tempMap.put('Id', record.Id);
                switch on parentTab {
                    when 'User_Wise_Target__c' {
                        User_Wise_Target__c rec = (User_Wise_Target__c) record;
                        tempMap.put('ParameterId', rec.User__C);
                        tempMap.put('ParameterName', rec.User__r.Name);
                        tempMap.put('ParameterEdit', false);
                        tempMap.put('Target_Amount__c', rec.Target_Amount__c.setScale(2));
                        tempMap.put('Target_Amount_New__c', rec.Target_Amount__c.setScale(2));

                        if (rec.Fiscal_Year__r.Is_Planning__c || rec.Fiscal_Year__r.isActive__c) {
                            tempMap.put('targetAmountEdit', true);
                        } else if (rec.Fiscal_Year__r.is_Complete__c) {
                            tempMap.put('targetAmountEdit', true);
                        }

                        for (Integer j = 0; j < parameterData.size(); j++) {
                            Map < String, Object > empData = (Map < String, Object > ) parameterData[j];
                            if (tempMap.get('ParameterName') == empData.get('ParameterName')) {
                                parameterData[j] = tempMap;
                                break;
                            }
                        }
                    }

         /*           when 'Employee_Wise_Product_Target__c' {
                        Employee_Wise_Product_Target__c rec = (Employee_Wise_Product_Target__c) record;
                        tempMap.put('ParameterId', rec.Item_Master__c);
                        tempMap.put('ParameterName', rec.Product__r.Name);
                        tempMap.put('ParameterEdit', false);
                        tempMap.put('Target_Amount__c', rec.Target_Amount__c.setScale(2));
                        tempMap.put('Target_Amount_New__c', rec.Target_Amount__c.setScale(2));

                        if (rec.Fiscal_Year__r.Is_Planning__c || rec.Fiscal_Year__r.isActive__c) {
                            tempMap.put('targetAmountEdit', true);
                        } else if (rec.Fiscal_Year__r.is_Complete__c) {
                            tempMap.put('targetAmountEdit', false);
                        }

                        for (Integer j = 0; j < parameterData.size(); j++) {
                            Map < String, Object > empData = (Map < String, Object > ) parameterData[j];
                            if (tempMap.get('ParameterName') == empData.get('ParameterName')) {
                                parameterData[j] = tempMap;
                                break;
                            }
                        }
                    }    */

                    when 'User_Wise_Product_Category_Target__c' {
                        User_Wise_Product_Category_Target__c rec = (User_Wise_Product_Category_Target__c) record;
                        tempMap.put('ParameterId', rec.Product_Category1__c);
                        tempMap.put('ParameterName', rec.Product_Category1__c);
                        tempMap.put('ParameterEdit', false);
                        tempMap.put('Target_Amount__c', rec.Target_Amount__c.setScale(2));
                        tempMap.put('Target_Amount_New__c', rec.Target_Amount__c.setScale(2));

                        if (rec.Fiscal_Year__r.Is_Planning__c || rec.Fiscal_Year__r.isActive__c) {
                            tempMap.put('targetAmountEdit', true);
                        } else if (rec.Fiscal_Year__r.is_Complete__c) {
                            tempMap.put('targetAmountEdit', false);
                        }

                        for (Integer j = 0; j < parameterData.size(); j++) {
                            Map < String, Object > empData = (Map < String, Object > ) parameterData[j];
                            System.debug('check:>> ' +tempMap.get('ParameterName') + ' || ' +empData.get('ParameterName'));
                            if (tempMap.get('ParameterName') == empData.get('ParameterName')) {
                                parameterData[j] = tempMap;
                                break;
                            }
                        }
                    }

                }

                System.debug(parameterData.size());
                System.debug('---------------------------------------------------------------------------');
                index++;
            }

            result.put('parameterData', parameterData);

            return JSON.serialize(result);

        } catch (Exception e) {            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
            /*
            Map<String, Object> result = new Map<String, Object>();
            result.put('status', 'Error');
            result.put('message', e.getMessage());
            return JSON.serialize(result);
            */
        }
    }

    @AuraEnabled
    public static string getMonthly(String fiscId, String empId, String parentTab, String prodCatVal) {
        try {

            if (String.isBlank(fiscId) || String.isBlank(parentTab)) {                return '{}';
            }

            Map < String, Object > result = new Map < String, Object > ();

            List < String > months = new List < String > ();
            for (sObject res: [SELECT Month_Name__c, Start_Date__c
                    FROM User_Wise_Target_Line_Item__c
                    WHERE User_Wise_Target__r.Fiscal_Year__c =: fiscId
                    GROUP BY Start_Date__c, Month_Name__c ORDER BY Start_Date__c
                ]) {
                months.add(String.valueOf(res.get('Month_Name__c')));
            }

            result.put('months', months);

            String queryFront = '';
            String whr = '';
            String ordBy = '';

            whr += ' WHERE Fiscal_Year__c = \'' + fiscId + '\' ';

            switch on parentTab {
                when 'User_Wise_Target__c' {
                    queryFront = 'SELECT Id, User__C, User__r.Name, Start_Date__c, ' +
                        '(SELECT Id, Start_Date__c, End_Date__c, Monthly_Target_Amount__c FROM User_Wise_Target_Line_Item__r ORDER BY Start_Date__c) ' +
                        ' FROM ' + parentTab + ' ';
                    ordBy = ' ORDER BY User__r.Name ASC ';
                }

                when 'User_Wise_Product_Category_Target__c' {
                    queryFront = 'SELECT Id, Product_Category__c, Product_Category__r.Name, Start_Date__c, Product_Category1__c, ' +
                        '(SELECT Id, Start_Date__c, End_Date__c, Monthly_Target_Amount__c,Month_Name__c FROM User_Wise_Product_Category_Target_Line__r ORDER BY Start_Date__c) ' +
                        ' FROM ' + parentTab + ' ';
                    whr += ' AND User__C = \'' + empId + '\' ';
                    ordBy = ' ORDER BY Product_Category1__c ASC ';
                }

            /*    when 'Employee_Wise_Product_Target__c' {
                    queryFront = 'SELECT Id, Item_Master__c, Product__r.Name, Start_Date__c, Product__r.Family__c, ' +
                        '(SELECT Id, Start_Date__c, End_Date__c, Monthly_Target_Amount__c FROM Employee_Wise_Product_Target_Line_Item__r ORDER BY Start_Date__c) ' +
                        ' FROM ' + parentTab + ' ';
                    whr += ' AND User__C = \'' + empId + '\' ';
                    whr += ' AND Product__r.Family = \'' + prodCatVal + '\' ';
                    ordBy = ' ORDER BY Product__r.Name ASC ';
                }  */

            }

            String query = queryFront + whr + ordBy;
            System.debug(query);
            for (sObject record: Database.query(query)) {
                Map < String, Object > tempMap = new Map < String, Object > ();
                tempMap.put('Id', record.Id);
                switch on parentTab {
                    when 'User_Wise_Target__c' {
                        User_Wise_Target__c rec = (User_Wise_Target__c) record;
                        tempMap.put('ParameterId', rec.User__C);
                        tempMap.put('ParameterName', rec.User__r.Name);

                        for (User_Wise_Target_Line_Item__c childRec: rec.User_Wise_Target_Line_Item__r) {
                            Map < String, Object > childMap = new Map < String, Object > ();
                            childMap.put('ParameterId', childRec.Id);
                            childMap.put('Monthly_Target_Amount__c', childRec.Monthly_Target_Amount__c.setScale(2));
                            childMap.put('Monthly_Target_Amount_New__c', childRec.Monthly_Target_Amount__c.setScale(2));
                            if (childRec.Start_Date__c > System.today()) {
                                childMap.put('targetAmountEdit', true);
                            } else if (childRec.Start_Date__c <= System.today() && System.today() <= childRec.End_Date__c) {
                                childMap.put('targetAmountEdit', true);
                            } else {
                                childMap.put('targetAmountEdit', false);
                            }

                            if (tempMap.containsKey('childData')) {
                                List < Object > tempList = (List < object > ) tempMap.get('childData');
                                tempList.add(childMap);
                            } else {
                                tempMap.put('childData', new List < Object > {
                                    childMap
                                });
                            }
                        }
                    }

          /*          when 'Employee_Wise_Product_Target__c' {
                        Employee_Wise_Product_Target__c rec = (Employee_Wise_Product_Target__c) record;
                        tempMap.put('ParameterId', rec.Item_Master__c);
                        tempMap.put('ParameterName', rec.Product__r.Name);

                        for (Employee_Wise_Product_Target_Line_Item__c childRec: rec.Employee_Wise_Product_Target_Line_Item__r) {
                            Map < String, Object > childMap = new Map < String, Object > ();
                            childMap.put('ParameterId', childRec.Id);
                            childMap.put('Monthly_Target_Amount__c', childRec.Monthly_Target_Amount__c.setScale(2));
                            childMap.put('Monthly_Target_Amount_New__c', childRec.Monthly_Target_Amount__c.setScale(2));
                            if (childRec.Start_Date__c > System.today()) {
                                childMap.put('targetAmountEdit', true);
                            } else if (childRec.Start_Date__c <= System.today() && System.today() <= childRec.End_Date__c) {
                                childMap.put('targetAmountEdit', true);
                            } else {
                                childMap.put('targetAmountEdit', false);
                            }

                            if (tempMap.containsKey('childData')) {
                                List < Object > tempList = (List < object > ) tempMap.get('childData');
                                tempList.add(childMap);
                            } else {
                                tempMap.put('childData', new List < Object > {
                                    childMap
                                });
                            }
                        }
                    }  */

                    when 'User_Wise_Product_Category_Target__c' {
                        User_Wise_Product_Category_Target__c rec = (User_Wise_Product_Category_Target__c) record;
                        tempMap.put('ParameterId', rec.Product_Category1__C);
                        tempMap.put('ParameterName', rec.Product_Category1__c);

                        for (User_Wise_Product_Category_Target_Line__c childRec: rec.User_Wise_Product_Category_Target_Line__r) {
                            Map < String, Object > childMap = new Map < String, Object > ();
                            childMap.put('ParameterId', childRec.Id);
                            childMap.put('Monthly_Target_Amount__c', childRec.Monthly_Target_Amount__c.setScale(2));
                            childMap.put('Monthly_Target_Amount_New__c', childRec.Monthly_Target_Amount__c.setScale(2));
                            if (childRec.Start_Date__c > System.today()) {
                                childMap.put('targetAmountEdit', true);
                            } else if (childRec.Start_Date__c <= System.today() && System.today() <= childRec.End_Date__c) {
                                childMap.put('targetAmountEdit', true);
                            } else {
                                childMap.put('targetAmountEdit', false);
                            }

                            if (tempMap.containsKey('childData')) {
                                List < Object > tempList = (List < object > ) tempMap.get('childData');
                                tempList.add(childMap);
                            } else {
                                tempMap.put('childData', new List < Object > {
                                    childMap
                                });
                            }
                        }
                    }
                }

                if (result.containsKey('parameterData')) {
                    List < Object > tempList = (List < Object > ) result.get('parameterData');
                    tempList.add(tempMap);
                } else {
                    result.put('parameterData', new List < Object > {
                        tempMap
                    });
                }
            }

            return JSON.serialize(result);

        } catch (Exception e) {            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
            /*
        result.put('status', 'Error');
        result.put('message', e.getMessage());
        return JSON.serialize(result);
        */
        }
    }

    @AuraEnabled(cacheable = false)
    public static string saveRecords(String data, String fiscalYearId, String employeeId, String type, String subType) {
        try {
            System.debug(data);
            System.debug('fiscalYearId' + fiscalYearId);
            System.debug('subType' + subType);
            System.debug('type' + type);
            System.debug('employeeId' + employeeId);
            Map < String, Object > result = new Map < String, Object > ();

            List < sObject > records = new List < sObject > ();

            List < Object > dataMap = (List < Object > ) JSON.deserializeUntyped(data);
            if (subType == 'Yearly') {
                for (Object obj: dataMap) {
                    Map < String, Object > recMap = (Map < String, Object > ) obj;
                    System.debug(recMap);
                    switch on type {
                        when 'User_Wise_Target__c' {
                            User_Wise_Target__c rec = new User_Wise_Target__c();
                            if (String.isNotBlank(String.valueOf(recMap.get('Id')))) {
                                rec.Id = String.valueOf(recMap.get('Id'));
                            } else {

                                rec.Fiscal_Year__c = fiscalYearId;
                            }
                            rec.User__C = String.valueOf(recMap.get('ParameterId'));
                            rec.Target_Amount__c = Decimal.valueOf(String.valueOf(recMap.get('Target_Amount_New__c')));
                            records.add(rec);
                        }

                /*        when 'Employee_Wise_Product_Target__c' {
                            Employee_Wise_Product_Target__c rec = new Employee_Wise_Product_Target__c();
                            if (String.isNotBlank(String.valueOf(recMap.get('Id')))) {
                                rec.Id = String.valueOf(recMap.get('Id'));
                            } else {

                                rec.Fiscal_Year__c = fiscalYearId;
                                rec.User__C = employeeId;
                            }
                            rec.Item_Master__c = String.valueOf(recMap.get('ParameterId'));
                            rec.Target_Amount__c = Decimal.valueOf(String.valueOf(recMap.get('Target_Amount_New__c')));
                            records.add(rec);
                        }     */
                        when 'User_Wise_Product_Category_Target__c' {
                            User_Wise_Product_Category_Target__c rec = new User_Wise_Product_Category_Target__c();

                            if (String.isNotBlank(String.valueOf(recMap.get('Id')))) {                                rec.Id = String.valueOf(recMap.get('Id'));
                            } else {
                                rec.Fiscal_Year__c = fiscalYearId;
                                rec.User__C = employeeId;
                            }
                            rec.Product_Category1__C = String.valueOf(recMap.get('ParameterId')); // Added by HA 26/02
                            rec.Target_Amount__c = Decimal.valueOf(String.valueOf(recMap.get('Target_Amount_New__c')));
                            system.debug('rec 520' + rec);
                            records.add(rec);
                        }
                    }
                }

                result.put('status', 'Success');

                List < Object > errorList = new List < Object > ();
                system.debug('rec 529' + records.size());
                Integer i = 0;
                for (Database.upsertResult res: Database.upsert(records, false)) {
                    System.debug('res -> ' + res);
                    Map < String, Object > tempMap = new Map < String, Object > ();
                    tempMap.put('status', res.isSuccess());
                    System.debug(records[i]);
                    switch on type {
                        when 'User_Wise_Target__c' {
                            tempMap.put('ParameterId', records[i].get('User__C'));
                        }

                        when 'User_Wise_Product_Category_Target__c' {
                            tempMap.put('ParameterId', records[i].get('Product_Category1__c'));
                        }
                        when 'Employee_Wise_Product_Target__c' {                            tempMap.put('ParameterId', records[i].get('Item_Master__c'));
                        }
                    }

                    if (!res.isSuccess()) {
                        tempMap.put('message', res.getErrors()[0].getMessage());

                        result.put('status', 'PartialError');
                    }
                    errorList.add(tempMap);
                    i++;
                }

                result.put('errorList', errorList);

            } else if (subType == 'Monthly') {

                for (Object obj: dataMap) {
                    Map < String, Object > recMap = (Map < String, Object > ) obj;
                    if (String.isNotBlank(String.valueOf(recMap.get('Monthly_Target_Amount__c')))) {
                        switch on type {
                            when 'User_Wise_Target__c' {
                                User_Wise_Target_Line_Item__c rec = new User_Wise_Target_Line_Item__c();
                                rec.Id = String.valueOf(recMap.get('ParameterId'));
                                rec.Monthly_Target_Amount__c = Decimal.valueOf(String.valueOf(recMap.get('Monthly_Target_Amount_New__c')));
                                records.add(rec);
                            }

                            when 'User_Wise_Product_Category_Target__c' {
                                User_Wise_Product_Category_Target_Line__c rec = new User_Wise_Product_Category_Target_Line__c();
                                rec.Id = String.valueOf(recMap.get('ParameterId'));
                                rec.Monthly_Target_Amount__c = Decimal.valueOf(String.valueOf(recMap.get('Monthly_Target_Amount_New__c')));
                                records.add(rec);
                            }
                       /*     when 'Employee_Wise_Product_Target__c' {
                                Employee_Wise_Product_Target_Line_Item__c rec = new Employee_Wise_Product_Target_Line_Item__c();
                                rec.Id = String.valueOf(recMap.get('ParameterId'));
                                rec.Monthly_Target_Amount__c = Decimal.valueOf(String.valueOf(recMap.get('Monthly_Target_Amount_New__c')));
                                records.add(rec);
                            }   */
                        }
                    }
                }

                result.put('status', 'Success');

                List < Object > errorList = new List < Object > ();

                for (Database.upsertResult res: Database.upsert(records, false)) {
                    System.debug('res -> ' + res);
                    Map < String, Object > tempMap = new Map < String, Object > ();
                    tempMap.put('status', res.isSuccess());
                    tempMap.put('ParameterId', res.getId());
                    if (!res.isSuccess()) {
                        tempMap.put('message', res.getErrors()[0].getMessage());

                        result.put('status', 'PartialError');
                    }
                    errorList.add(tempMap);
                }

                result.put('errorList', errorList);

            }

            return JSON.serialize(result);
        } catch (Exception e) {
            Map < String, Object > result = new Map < String, Object > ();
            result.put('status', 'Error');
            result.put('message', e.getMessage());
            return JSON.serialize(result);
        }
    }

    @AuraEnabled(cacheable = false)
    public static string getTargetQuantityByEmpId(String empId){
        try {

            List<User_Wise_Target__c> ewtList = new List<User_Wise_Target__c>();
            ewtList = [
                SELECT Id, Name, Target_Amount__c, User__C
                FROM User_Wise_Target__c
                WHERE User__C =: empId
            ];

            System.debug(ewtList[0].Name);
            System.debug(ewtList[0].Target_Amount__c);

            if (ewtList.size() > 0) {                return String.valueOf(ewtList[0].Target_Amount__c);
            } else {
                return '';
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static string getProductTargetQtyByProdCatVal(String prodCatVal, String empId){
        try {

            List<User_Wise_Product_Category_Target__c> ewtList = new List<User_Wise_Product_Category_Target__c>();
            ewtList = [
                SELECT Id, Name, Target_Amount__c, User__C
                FROM User_Wise_Product_Category_Target__c
                WHERE User__C =: empId AND Product_Category1__c =: prodCatVal
            ];

            System.debug('659:>> ' +ewtList);

            if (ewtList.size() > 0) {                return String.valueOf(ewtList[0].Target_Amount__c);
            } else {
                return '';
            }
            
        } catch (Exception e) {            throw new AuraHandledException(e.getLineNumber() + e.getMessage());
        }
    } 

}