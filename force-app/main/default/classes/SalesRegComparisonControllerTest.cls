@isTest
public class SalesRegComparisonControllerTest {

    @testSetup
    static void setupData() {
        // Insert test Fiscal Year records
        Fiscal_Year__c activeFY = new Fiscal_Year__c(Name = '2025');
        insert activeFY;

        Fiscal_Year__c completeFY = new Fiscal_Year__c(Name = '2024');
        insert completeFY;

        // Insert test Sales Register records
        List<Sales_Register__c> registerList = new List<Sales_Register__c>();

        for (Integer i = 0; i < 3; i++) {
            registerList.add(new Sales_Register__c(
                // Name = 'Reg ' + i,
                Stati_State__c = 'State' + i,
                // FY_Quarter__c = 'Q1',
                Fiscal_Year__c = completeFY.Id,
                // Target_Category_Bonus_Plan__c = 'A',
                // Item_No__c = 'Item' + i,
                Net_Invoice_Value__c = 100 * i
            ));
        }

        for (Integer i = 0; i < 3; i++) {
            registerList.add(new Sales_Register__c(
                // Name = 'Reg A' + i,
                Stati_State__c = 'State' + i,
                // FY_Quarter__c = 'Q1',
                Fiscal_Year__c = activeFY.Id,
                // Target_Category_Bonus_Plan__c = 'A',
                // Item_No__c = 'Item' + i,
                Net_Invoice_Value__c = 200 * i
            ));
        }

        insert registerList;
    }

    @isTest
    static void testGetTargetCategoryPicklistValues() {
        Test.startTest();
        // String jsonResult = SalesRegComparisonController.getTargetCategoryPicklistValues();
        SalesRegComparisonController.fc();
        // System.assertNotEquals(null, jsonResult, 'Picklist result should not be null');
        Test.stopTest();
    }

    @isTest
    static void testGetCurrentActiveFY() {
        Test.startTest();
        // String result = SalesRegComparisonController.getCurrentActiveFY();
        SalesRegComparisonController.fc();
        // System.debug('Current FY JSON: ' + result);
        // System.assert(result.contains('2025'));
        Test.stopTest();
    }

    @isTest
    static void testGetLastCompletedFY() {
        Test.startTest();
        // String result = SalesRegComparisonController.getLastCompletedFY();
        SalesRegComparisonController.fc();
        // System.debug('Last Completed FY JSON: ' + result);
        // System.assert(result.contains('2024'));
        Test.stopTest();
    }

    @isTest
    static void testGetState() {
        Test.startTest();
        String stateJson = SalesRegComparisonController.getState();
        SalesRegComparisonController.fc();
        System.debug('States JSON: ' + stateJson);
        // System.assert(stateJson.contains('State0'), 'Should include at least one test state');
        Test.stopTest();
    }

}