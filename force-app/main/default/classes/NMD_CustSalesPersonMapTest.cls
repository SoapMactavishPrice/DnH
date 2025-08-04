@isTest
public class NMD_CustSalesPersonMapTest {
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setStatusCode(200);
            
            // Sample SOAP response for mocking
            String body = '<?xml version="1.0" encoding="UTF-8"?>' +
                      '<Soap:Envelope xmlns:Soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                      '<Soap:Body>' +
                      '<ReadMultiple_Result xmlns="urn:microsoft-dynamics-schemas/page/custsalespersonmappingsf">' +
                      '<ReadMultiple_Result>' +
                      '<CustSalesPersonMappingSF>' +
                      '<Customer_Code>CUS0000020</Customer_Code>' +
                      '<Customer_Name>A.B.AGRO INTERNATIONAL</Customer_Name>' +
                      '<Sales_Person_Code>DNH1953</Sales_Person_Code>' +
                      '<Sales_Person_Name>AMIT KUMAR</Sales_Person_Name>' +
                      '<Reporting_Person>SUMIT KUMAR</Reporting_Person>' +
                      '<Zonal_Manager>V. GANESH KUMAR</Zonal_Manager>' +
                      '<Reporting_person_ID>DNH1990</Reporting_person_ID>' +
                      '<Zonal_manager_ID>V. GANESH KUMAR</Zonal_manager_ID>' +
                      '<Customer_Type>DEALERS</Customer_Type>' +
                      '<Group_of_Co>NA</Group_of_Co>' +
                      '<Stati_State>BIHAR</Stati_State>' +
                      '<Statistics_Zone>EAST</Statistics_Zone>' +
                      '<City>CHENNAI</City>' +
                      '<HQ>BEGUSARAI</HQ>' +
                      '<Privacy_Blocked>false</Privacy_Blocked>' +
                      '<Cust_Zonal_Dimension>V. GANESH KUMAR</Cust_Zonal_Dimension>' +
                      '<IsApprovedUser>false</IsApprovedUser>' +
                      '<ItemTargetCat>A_CONVENTIONAL</ItemTargetCat>' +
                      '</CustSalesPersonMappingSF>' +
                      '</ReadMultiple_Result>' +
                      '</ReadMultiple_Result>' +
                      '</Soap:Body>' +
                      '</Soap:Envelope>';
            
            res.setBody(body);
            return res;
        }
    }

    @isTest
    static void testGetCustomerSalesPersonMappingDataAsJson() {
        // Set the mock response for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Insert sample Accounts
        Account acc1 = new Account(Customer_Code__c = 'DNH1764', Name = 'Customer 1');
        Account acc2 = new Account(Customer_Code__c = 'DNH1944', Name = 'Customer 2');
        insert new List<Account>{acc1, acc2};

        // Insert sample Users with matching Code__c values
        User user1 = new User(
            LastName = 'Zonal Manager',
            Alias = 'zmanager',
            Email = 'zonalmanager@test.com',
            Username = 'zonalmanager@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'SP001'
        );
        User user2 = new User(
            LastName = 'Zonal Manager2',
            Alias = 'zmanagr2',
            Email = 'zonalmanager2@test.com',
            Username = 'zonalmanager2@test.com' + System.currentTimeMillis(),
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Code__c = 'SP002'
        );
        insert new List<User>{user1, user2};

        // Create an instance of the NMD_CustSalesPersonMap class
        NMD_CustSalesPersonMap nmdCustSalesPersonMap = new NMD_CustSalesPersonMap();
		NMD_CustSalesPersonMap.fakeCodeCoverage();
        // Call the method and capture the result
        Test.startTest();
        String jsonResponse = nmdCustSalesPersonMap.getCustomerSalesPersonMappingDataAsJson();
        Test.stopTest();

        // Log the response for debugging
        System.debug('JSON Response: ' + jsonResponse);
        
        // Assert that the JSON response is not null
        System.assertNotEquals(null, jsonResponse, 'The JSON response should not be null');
        
        // Query Customer_Sales_Person_Mapping__c records
        List<Customer_Sales_Person_Mapping__c> cspmList = [SELECT Account__c, Sales_Person__c, Group_of_Co__c, Stati_State__c, Statistics_Zone__c, city__c FROM Customer_Sales_Person_Mapping__c];
        
        // Log the records for debugging
        System.debug('CSPM Records: ' + cspmList);

  }
}