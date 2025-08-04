@isTest
public class CreateEnquiryTCOAPITest {

    @isTest
    static void testCreateEnquiryWithLineItems() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account', Customer_Code__c = '12345');
        insert testAccount;

        Enquiry__c testEnquiry = new Enquiry__c(Account__c = testAccount.Id, Enquiry_Name__c = 'Test Enquiry Name');
        insert testEnquiry;

        Item_Master__c testItemMaster = new Item_Master__c(Name = 'Test Item Master', Item_Number__c = 'ITEM123');
        insert testItemMaster;

        Item_Variant__c testItemVariant = new Item_Variant__c(Name = 'Test Variant', Code__c = 'VAR123');
        insert testItemVariant;

        Enquiry_Line_Item__c testLineItem = new Enquiry_Line_Item__c(
            Enquiry__c = testEnquiry.Id,
            Item_Master__c = testItemMaster.Id,
            Item_Category2__c = 'Category1',
            Temp_Line_No__c = 'a05F300000Hd7kP'
        );
        insert testLineItem;

        // Prepare JSON payload for TCO items
        String jsonPayload = JSON.serialize(new Map<String, Object>{
            'CustomerNo' => testAccount.Customer_Code__c,
            'TCO_Name' => 'Updated Enquiry',
            'TCOItems' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'Item_No' => testItemMaster.Item_Number__c,
                    'Variant_Code' => testItemVariant.Code__c,
                    'Item_Category' => 'Category2',
                        'Field_Staff_Code' => 'DNH1077',
                    'Qty' => '10',
                    'Temp_Line_No' => 'Temp123',
                    'Dealer_Rate' => '500.00',
                    'IsDeleted' => 0
                }
            }
        });

        // Mock HTTP request and response
        RestRequest req = new RestRequest();
        req.requestUri = '/CreateTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Execute the method
        Test.startTest();
        CreateEnquiryTCOAPI.doPost();
        Test.stopTest();

        // Validate successful response
      //  System.assertEquals(200, res.statusCode, 'Expected success response.');
       // System.assert(res.responseBody.toString().contains('Enquiry Created'), 'Success message not found in response.');

        // Validate database changes
        List<Enquiry_Line_Item__c> lineItems = [
            SELECT Id, Item_Category2__c, Dealer_Rate__c
            FROM Enquiry_Line_Item__c
            WHERE Enquiry__c = :testEnquiry.Id
        ];
        System.assertEquals(1, lineItems.size(), 'Line item count does not match.');
        //System.assertEquals('Category2', lineItems[0].Item_Category2__c, 'Item category mismatch for updated item.');
    }

    @isTest
    static void testMissingCustomerNo() {
        
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Prepare payload with missing CustomerNo
        String jsonPayload = JSON.serialize(new Map<String, Object>{
            'TCO_Name' => 'Missing CustomerNo',
            'Field_Staff_Code' => 'DNH1077',
                'ApprovedBy'=> 'CUS0012350',
                'Zonal_Head'=> 'DNH1077',
                
            'TCOItems' => new List<Map<String, Object>>{}
        });

        // Mock HTTP request and response
        RestRequest req = new RestRequest();
        req.requestUri = '/CreateTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Execute the method
        Test.startTest();
        CreateEnquiryTCOAPI.doPost();
        Test.stopTest();

        // Validate response for missing CustomerNo
        System.assertEquals(400, res.statusCode, 'Expected failure response for missing CustomerNo.');
        System.assert(res.responseBody.toString().contains('CustomerNo required'), 'Expected error message not found.');
    }

    @isTest
    static void testDoPost_Exception() {
        // Induce an exception using invalid data
        Account acc = new Account(Name = 'Test Account', Customer_Code__c = 'CUS0012350');
        insert acc;
        
        String jsonPayload = JSON.serialize(new Map<String, Object>{
            'CustomerNo' => 'InvalidCustomer',
            'TCO_Name' => 'Invalid Data',
                'Field_Staff_Code' => 'DNH1077',
                'SubmittedBy'=>'CUS0012350',
                'IsCustomer'=>'true',
                'Zonal_Head'=> 'DNH1077',
                'Area_Manager'=>'DNH1077',
                'ApprovedBy'=>'DNH1077',
                'PreparedBy'=>'DNH1077',
            'TCOItems' => null // Invalid payload to trigger exception
                
        });

        // Mock HTTP request and response
        RestRequest req = new RestRequest();
        req.requestUri = '/CreateTCO';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Execute the method
        Test.startTest();
        try {
            CreateEnquiryTCOAPI.doPost(); 
        } catch (Exception e) {
            // Validate exception handling
            System.assertEquals(400, res.statusCode, 'Expected status code 400.');
            System.assert(res.responseBody.toString().contains('Something went wrong'), 'Expected error message not found.');
        }
        Test.stopTest();
    }
}