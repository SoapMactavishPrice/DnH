@isTest
public class CreateSalesRegisterQableCalloutTest {

    public class MockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","data":[]}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testQueueableCallout() {
        Test.setMock(HttpCalloutMock.class, new MockCallout());

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        User salesUser = [SELECT Id FROM User WHERE Profile.Name='Sales Engineer' LIMIT 1];

        Customer_Sales_Person_Mapping__c mapping1 = new Customer_Sales_Person_Mapping__c(
            Account__c = acc.Id,
            Sales_Person__c = salesUser.Id
        );
        Customer_Sales_Person_Mapping__c mapping2 = new Customer_Sales_Person_Mapping__c(
            Account__c = acc.Id,
            Sales_Person__c = salesUser.Id
        );
        insert new List<Customer_Sales_Person_Mapping__c>{mapping1, mapping2};

        List<Customer_Sales_Person_Mapping__c> mappingList = [
            SELECT Id, Account__c, Sales_Person__c FROM Customer_Sales_Person_Mapping__c
        ];

        // ✅ Stop chaining in test mode!
        CreateSalesRegisterQableCallout.stopChainingInTest = true;

        Test.startTest();
        System.enqueueJob(new CreateSalesRegisterQableCallout(mappingList, 0));
        Test.stopTest();

        System.assertEquals(2, mappingList.size(), 'Should have 2 mapping records');
    }
}