@isTest
public class GetCompetitorProductTest {

    @isTest
    static void testFetchLookupData() {
        // Step 1: Create test data
        // Create Competitor record
        Competitor__c competitor = new Competitor__c(Name = 'Competitor ABC');
        insert competitor;
        
        // Create Competitor Product records
        Competitor_Product__c product1 = new Competitor_Product__c(
            Name = 'Product 1',
            Competitor__c = competitor.Id
        );
        Competitor_Product__c product2 = new Competitor_Product__c(
            Name = 'Product 2',
            Competitor__c = competitor.Id
        );
        insert new List<Competitor_Product__c>{product1, product2};
        
        // Step 2: Test fetchLookupData method
        Test.startTest();
        
        // Search for products related to the competitor
        String searchKey = 'Product';
        String sObjectApiName = 'Competitor_Product__c';
        String recordId = competitor.Id;
        
        // Call the fetchLookupData method
        List<sObject> result = GetCompetitorProduct.fetchLookupData(searchKey, sObjectApiName, recordId);
        
        // Step 3: Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.size(), 'There should be 2 Competitor Product records returned');
        
        // Ensure that the returned records are of type Competitor_Product__c
        for (sObject obj : result) {
            System.assert(obj instanceof Competitor_Product__c, 'The result should be of type Competitor_Product__c');
        }
        
        Test.stopTest();
    }

    @isTest
    static void testFetchDefaultRecord() {
        
        Competitor__c compe1= new Competitor__c(Name = 'test');
        
        insert compe1;
        
        // Step 1: Create a Competitor Product record
        Competitor_Product__c product = new Competitor_Product__c(
            Name = 'Default Product',
            Competitor__c = compe1.id
        );
        insert product;
        
        // Step 2: Test fetchDefaultRecord method
        Test.startTest();
        
        // Call the fetchDefaultRecord method
        sObject result = GetCompetitorProduct.fetchDefaultRecord(product.Id, 'Competitor_Product__c');
        
        // Step 3: Assertions
        System.assertNotEquals(null, result, 'The default record should not be null');
        System.assertEquals(product.Id, result.Id, 'The returned record should have the same ID');
        
        Test.stopTest();
    }
}