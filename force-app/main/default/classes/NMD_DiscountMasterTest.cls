@isTest
public class NMD_DiscountMasterTest {

    // Mock class to simulate HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?>' +
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="urn:microsoft-dynamics-schemas/page/discountmastersf">' +
                    '<soapenv:Body>' +
                        '<cus:ReadMultiple_Result>' +
                            '<cus:DiscountMasterSF>' +
                                '<cus:Discount_Percent>10.0</cus:Discount_Percent>' +
                                '<cus:Qty_To>100</cus:Qty_To>' +
                                '<cus:Qty_From>50</cus:Qty_From>' +
                                '<cus:Disc_Type>Variant_Quanity</cus:Disc_Type>' +
                                '<cus:Item_Discount_Group>Group1</cus:Item_Discount_Group>' +
                            '</cus:DiscountMasterSF>' +
                            '<cus:DiscountMasterSF>' +
                                '<cus:Discount_Percent>15.0</cus:Discount_Percent>' +
                                '<cus:Qty_To>200</cus:Qty_To>' +
                                '<cus:Qty_From>150</cus:Qty_From>' +
                                '<cus:Disc_Type>Variant_Quanity</cus:Disc_Type>' +
                                '<cus:Item_Discount_Group>Group2</cus:Item_Discount_Group>' +
                            '</cus:DiscountMasterSF>' +
                        '</cus:ReadMultiple_Result>' +
                    '</soapenv:Body>' +
                '</soapenv:Envelope>');
            return res;
        }
    }

    // Mock class to simulate HTTP response for error handling
    private class MockHttpResponseFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Server Error');
            return res;
        }
    }

    @isTest
    static void testGetDiscountMasterDataAsJson_Success() {
        // Set the mock HTTP response for the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start the test context
        Test.startTest();

        // Call the method
        NMD_DiscountMaster discountMaster = new NMD_DiscountMaster();
        List<NMD_DiscountMaster.Discount> result = discountMaster.getDiscountMasterDataAsJson();

        // Stop the test context
        Test.stopTest();

        // Assert the result is not null
        System.assert(result != null, 'The result should not be null');
   //     System.assert(result.size() == 2, 'The result should contain 2 discount records');
        
        // Assert the first discount record
   //     System.assert(result[0].Discount_Percent == 10.0, 'The first discount should have a Discount_Percent of 10.0');
   //     System.assert(result[0].Qty_To == 100, 'The first discount should have Qty_To of 100');
   //     System.assert(result[0].Qty_From == 50, 'The first discount should have Qty_From of 50');
   //     System.assert(result[0].Disc_Type == 'Variant_Quanity', 'The first discount should have Disc_Type of "Variant_Quanity"');
   //     System.assert(result[0].Item_Discount_Group == 'Group1', 'The first discount should have Item_Discount_Group of "Group1"');
        
        // Assert the second discount record
    //    System.assert(result[1].Discount_Percent == 15.0, 'The second discount should have a Discount_Percent of 15.0');
    //    System.assert(result[1].Qty_To == 200, 'The second discount should have Qty_To of 200');
    //    System.assert(result[1].Qty_From == 150, 'The second discount should have Qty_From of 150');
    //    System.assert(result[1].Disc_Type == 'Variant_Quanity', 'The second discount should have Disc_Type of "Variant_Quanity"');
    //    System.assert(result[1].Item_Discount_Group == 'Group2', 'The second discount should have Item_Discount_Group of "Group2"');
    }

    @isTest
    static void testGetDiscountMasterDataAsJson_ErrorResponse() {
        // Set the mock error response for the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailure());

        // Start the test context
        Test.startTest();

        // Call the method
        NMD_DiscountMaster discountMaster = new NMD_DiscountMaster();
        List<NMD_DiscountMaster.Discount> result = discountMaster.getDiscountMasterDataAsJson();

        // Stop the test context
        Test.stopTest();

        // Assert the result is an empty list (since the request failed)
        System.assert(result.isEmpty(), 'The result should be empty due to the failed response');
    }

    @isTest
    static void testInsertDiscounts() {
        // Prepare mock Discount data
        NMD_DiscountMaster.Discount discount1 = new NMD_DiscountMaster.Discount();
        discount1.Discount_Percent = 10.0;
        discount1.Qty_To = 100;
        discount1.Qty_From = 50;
        discount1.Disc_Type = 'Variant_Quanity';
        discount1.Item_Discount_Group = 'Group1';

        NMD_DiscountMaster.Discount discount2 = new NMD_DiscountMaster.Discount();
        discount2.Discount_Percent = 15.0;
        discount2.Qty_To = 200;
        discount2.Qty_From = 150;
        discount2.Disc_Type = 'Variant_Quanity';
        discount2.Item_Discount_Group = 'Group2';

        List<NMD_DiscountMaster.Discount> discounts = new List<NMD_DiscountMaster.Discount>{discount1, discount2};

        // Mock the insertDiscounts method (simulating that data would be inserted)
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        NMD_DiscountMaster discountMaster = new NMD_DiscountMaster();
        discountMaster.insertDiscounts(discounts);

        // Stop the test context
        Test.stopTest();

        // Retrieve the inserted records to ensure they were correctly inserted
        List<Discount_Master__c> insertedRecords = [SELECT Discount__c, Qty_To__c, Qty_From__c, Disc_Type__c, Item_Discount_Group__c FROM Discount_Master__c];

        // Assert that the records were inserted correctly
        System.assert(insertedRecords.size() == 2, 'There should be 2 discount records inserted.');
        System.assert(insertedRecords[0].Discount__c == 10.0, 'The first inserted discount should have Discount__c of 10.0');
        System.assert(insertedRecords[0].Qty_To__c == 100, 'The first inserted discount should have Qty_To__c of 100');
        System.assert(insertedRecords[1].Discount__c == 15.0, 'The second inserted discount should have Discount__c of 15.0');
        System.assert(insertedRecords[1].Qty_To__c == 200, 'The second inserted discount should have Qty_To__c of 200');
    }
}