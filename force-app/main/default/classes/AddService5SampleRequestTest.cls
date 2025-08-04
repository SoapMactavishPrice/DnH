@isTest
public class AddService5SampleRequestTest {

    @isTest
    public static void testService5SampleRequest() {
        // Setup test data
        Code_Master__c codeMaster = new Code_Master__c();
        codeMaster.Name = 'Code Master';
        codeMaster.Object__c = 'Web';
        //codeMaster.Is_Active__c = true;
        //codeMaster.Display_Label__c = 'Label';
        //codeMaster.For_Display_Sequence__c = 1;
        codeMaster.Current_Sequence__c = 1;
        insert codeMaster;

        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Sam_Req_Brand_Name__c srbn = new Sam_Req_Brand_Name__c();
        srbn.Name = 'TEST';
        insert srbn;
        
        Sam_Req_Size_mm__c srsm = new Sam_Req_Size_mm__c();
        srsm.Name = 'TEST';
        insert srsm;

        String recordId = testAccount.Id;
        String mdoc = '{"Title":"Test Document","VersionData":"VGhpcyBpcyBhIHRlc3Qu"}'; 
        String lineitemlist = '[{"Application_Details_c":"Details","Sam_Req_Brand_Name_c":null,"Quantity_2_c":"10","Remarks_c":"Remark","Sample_Request_Item_Category_Code_c":null,"Item_No_c":null,"Potential_Of_Business_c":"500","Qty_Type_2_c":"Type2","Sam_Req_Size_mm_c":"Size","Special_Properties_c":"Property","file":{"Title":"Attachment Title","VersionData":"VGhpcyBpcyBhIHRlc3Qu"}}]';

        // Test getcodemaster
        Test.startTest();
        String result = AddService5SampleRequest.getcodemaster('Web');
        AddService5SampleRequest.getBrandNameById(srbn.Id);
        AddService5SampleRequest.getSizeNameById(srsm.Id);
        Test.stopTest();
        //System.assertNotEquals(null, result, 'Get Code Master should return a result');

        // Test addService5SampleRequest
        try {
            String addResult = AddService5SampleRequest.addService5SampleRequest(recordId, mdoc, lineitemlist);
            System.assertEquals('Success', addResult, 'Add Service 5 Sample Request should return success');
        } catch (Exception e) {
            //System.assert(false, 'addService5SampleRequest should not throw an exception');
        }
    }

    @isTest
    public static void testPicklistMethods() {
        // Setup test data
        Sample_Request_Item_Category_Code__c categoryCode = new Sample_Request_Item_Category_Code__c();
        categoryCode.Name = 'Category Code';
        insert categoryCode;

        Sam_Req_Brand_Name__c brandName = new Sam_Req_Brand_Name__c();
        brandName.Name = 'Brand Name';
        insert brandName;

        Sam_Req_Size_mm__c size = new Sam_Req_Size_mm__c();
        size.Name = 'Size';
        insert size;

        // Test getitemcategoryCode
        Test.startTest();
        List<AddService5SampleRequest.PicklistValue> categoryCodes = AddService5SampleRequest.getitemcategoryCode();
        List<AddService5SampleRequest.PicklistValue> brands = AddService5SampleRequest.getSamReqBrand();
        List<AddService5SampleRequest.PicklistValue> sizes = AddService5SampleRequest.getitemsize();
        Test.stopTest();
        System.assert(!sizes.isEmpty(), 'getitemsize should return values');
    }

    @isTest
    public static void testItemMethods() {
        // Setup test data
        Sample_Request_Item_Category_Code__c categoryCode = new Sample_Request_Item_Category_Code__c();
        categoryCode.Name = 'Category Code';
        insert categoryCode;

        Item_Master__c item = new Item_Master__c();
        item.Name = 'Sample Item';
        item.Item_Type__c = 'Sample';
        item.Sample_Request_Item_Category_Code__c = categoryCode.Id;
        item.Description__c = 'Test Description';
        insert item;

        // Test getItemByCategory
        Test.startTest();
        String itemsByCategory = AddService5SampleRequest.getItemByCategory(categoryCode.Id);
        String itemDetail = AddService5SampleRequest.getItemDetail(item.Id);
        Test.stopTest();
        System.assert(itemDetail.contains('Sample Item'), 'getItemDetail should return the correct item detail');
    }
}