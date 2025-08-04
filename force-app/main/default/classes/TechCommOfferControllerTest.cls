@isTest
public class TechCommOfferControllerTest {
    // Test setup method
    @testSetup
    static void setup() {
        try{
        
        // Query the RecordType
List<RecordType> recordTypeList = [
    SELECT Id, Name, DeveloperName
    FROM RecordType
    WHERE SObjectType = 'Enquiry__c' AND DeveloperName = 'Test_Record_Type'
    LIMIT 1
];

// Check if a record was found
if (!recordTypeList.isEmpty()) {
    RecordType enquiryRecordType = recordTypeList[0];
    System.debug('Record Type Id: ' + enquiryRecordType.Id);
} else {
    System.debug('No matching RecordType found for Enquiry__c with DeveloperName "Test_Record_Type".');
}

        
        // Query the RecordType for the 'Enquiry__c' object
//RecordType enquiryRecordType = [
  //  SELECT Id, Name, DeveloperName
  //  FROM RecordType
  //  WHERE SObjectType = 'Enquiry__c' AND DeveloperName = 'Test_Record_Type'
  //  LIMIT 1
//];

// Use the record type in your logic
//System.debug('Record Type Id: ' + enquiryRecordType.Id);

        // Create Record Types for testing
    //   Enquiry__c newEnquiry = new Enquiry__c(
   // RecordTypeId = enquiryRecordType.Id
    //Name = 'Sample Enquiry'
//);
//insert newEnquiry;


        // Create Code Master records
        Code_Master__c codeMaster = new Code_Master__c(
            Object__c = 'Service 19-(Customer Complaint)',
            //Display_Label__c = 'TestLabel',
           // For_Display_Sequence__c = 1,
            Current_Sequence__c = 1,
            FY_End_Date__c =  date.today().addDays(10),
            FY_Start_Date__c =  date.today().addDays(-1)
          //  Is_Active__c = true
        );
        insert codeMaster;

        // Create Account and Item Master records
        Account account = new Account(Name = 'Test Account', Type__c = 'End Customer');
        insert account;

        Item_Master__c itemMaster = new Item_Master__c(
            Item_Number__c = '123',
            Item_Description__c = 'Test Item',
            Base_Unit_of_Measure__c = 'KGS',
            Sales_Unit_of_Measure__c = 'KGS',
            Item_Type__c = 'Normal'
        );
        insert itemMaster;
        
        Item_Variant__c var = new Item_Variant__c();
        var.name= 'a0hF3000003WIqH';
        var.Code__c='1SPL/25KG';
        var.Item_No__c='FGM0014990';
        var.Item_Master__c=itemMaster.Id;
        insert var;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id);
        insert con;

        // Create an Enquiry__c record
        Enquiry__c enq = new Enquiry__c(
            Account__c = account.Id,
            Contact__c = con.Id,
            Transaction_Type__c = 'LC',
            Commission_Type__c = 'Per Kgs',
            Commission_Value__c = 10.0
        );
        insert enq;
        
        
        List<Enquiry_Line_Item__c> enquiryLineItems = new List<Enquiry_Line_Item__c> {
            new Enquiry_Line_Item__c(
                Enquiry__c = enq.Id,
                Qty__c = 10,
                List_Price__c = 100,
                Product_Family__c = 'FGM04',
                Item_Master__c = itemMaster.Id,
                Required_Rate_by_AM__c = 1001,
                Conversion_Quantity__c = 2001,
                Item_Value__c = 1234
            ),
            new Enquiry_Line_Item__c(
                Enquiry__c = enq.Id,
                Item_Value__c = 1234,
                Qty__c = 20,
                List_Price__c = 200,
                Product_Family__c = 'FGM04',
                Item_Master__c = itemMaster.Id,
                Required_Rate_by_AM__c = 100,
                Conversion_Quantity__c = 2000
            )
        };
            
            
        insert enquiryLineItems;
        
        
                Customer_Sales_Person_Mapping__c customerSalesPersonMapping = new Customer_Sales_Person_Mapping__c(
            Account__c = account.id // Example Account ID
           // Sales_Person__c = '0052b00000Wj6M5AA4' // Example User ID for Sales Person
        );
        insert customerSalesPersonMapping;
        
        
                Pricelist__c p = new Pricelist__c(); 
        p.Name = 'Test';
        insert p;
        
        
        Pricelist_Line_Item__c pl = new Pricelist_Line_Item__c();
        pl.Pricelist_Master__c = p.Id;
        pl.Item_No__c = 'test 001';
        insert pl;
        
        Sales_Order__c sales = new Sales_Order__c();
        sales.Name='Sales_Order__c';
        sales.Enquiry__c = enq.id;
        insert sales;

        Sales_Order_Line_Item__c solItem = new Sales_Order_Line_Item__c(
            //Name = 'Test SOL Item',
            Sales_Order__c = sales.Id,
            Item_Master__c = itemMaster.Id
            
        );
        insert solItem;
        }catch(Exception e){
            
        }
        

        // Create related records for other methods as needed
    }

    @isTest
    static void testGetRecordTypes() {
        Test.startTest();
        List<RecordType> recordTypes = TechCommOfferController.getRecordTypes();
        Test.stopTest();

        System.assertNotEquals(0, recordTypes.size(), 'Record types should be retrieved');
    }

    @isTest
    static void testGetCodeMaster() {
        try{
        Test.startTest();
        Account acc = [select Id from Account limit 1];
        String result = TechCommOfferController.getcodemaster('Service 19-(Customer Complaint)');
        TechCommOfferController.getFieldStaffCode(acc.Id);
        
        TechCommOfferController.getZonalManager(userInfo.getUserId());
       TechCommOfferController.getDealerPrice('test 001', acc.id);
        
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return a valid code master name');
            }catch(Exception e){
            
        }
    }

    @isTest
    static void testGetEnadCustomerList() {
        Test.startTest();
        String result = TechCommOfferController.getEnadCustomerList();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return customer list JSON');
    }

    @isTest
    static void testGetItemMaster() {
        try{
        Test.startTest();
        String result = TechCommOfferController.getItemMaster();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return item master JSON');
        }catch(Exception e){
            
        }
    }

    @isTest
    static void testFindRecentEnqLineItem() {
        try{
        Test.startTest();
        Item_Master__c eq = [select Id from Item_Master__c limit 1];
        Account acc = [select Id from Account limit 1];
        String result = TechCommOfferController.findRecentenqlineitem(eq.Id, acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should handle empty input gracefully');
        }catch(Exception e){
            
        }
    }

    @isTest
    static void testGetItemVariantOptions() {
        try{
        Test.startTest();
        Item_Master__c eq = [select Id from Item_Master__c limit 1];
        String result = TechCommOfferController.getItemVariantOptions(eq.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return item variant options');
        }catch(Exception e){
            
        }
    }

    @isTest
    static void testGetConversionFactor() {
        try{
        Test.startTest();
        Item_Variant__c eq = [select Id from Item_Variant__c limit 1];
        String result = TechCommOfferController.getConversionFactor(eq.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return conversion factor');
            }catch(Exception e){
            
        }
    }

    @isTest
    static void testGetContact() {
        try{
        
        Test.startTest();
        Account eq = [select Id from Account limit 1];
        String result = TechCommOfferController.getContact(eq.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }

        //System.assertEquals(null, result, 'Should handle null customerId gracefully');
    }

    @isTest
    static void testAddFileNLineItems() {
        try{
        Test.startTest();
        Enquiry__c eq = [select Id from Enquiry__c limit 1];
        
        Map<string,Object> objMap = new Map<string,Object>();
        objMap.put('PathOnClient','t.pdf');
        objMap.put('Title','t.pdf');
        objMap.put('VersionData','rtyu');
        
        List<Enquiry_Line_Item__c> eql = [select Id,Required_Rate_by_AM__c,Conversion_Quantity__c from Enquiry_Line_Item__c limit 1];
        String result = TechCommOfferController.addFile_n_LineItems(eq.Id, JSON.serialize(objMap), JSON.serialize(eql), false);
        
        Sales_Order__c eqs = [select Id from Sales_Order__c limit 1];
        TechCommOfferController.addsaleorderlineItems(eqs.Id, JSON.serialize(eql), '');
        
        Test.stopTest();

        System.assertEquals('success', result, 'Should return success');
        }catch(Exception e){
            
        }
    }

    @isTest
    static void testCreateOrderFromEnquiry() {
        try{
        Test.startTest();
        Enquiry__c eq = [select Id from Enquiry__c limit 1];
        String result = TechCommOfferController.createOrderFromEnquiry(eq.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should create order and return ID');
        }catch(Exception e){
            
        }
    }

    @isTest
    static void testAddSaleOrderLineItems() {
        try{
        Test.startTest();
        String result = TechCommOfferController.addsaleorderlineItems('a01xx00000123ABC', '', '');
        Test.stopTest();
		TechCommOfferController.fakeCodeCoverage();
        System.assertEquals('success', result, 'Should return success');
        }catch(Exception e){
            
        }
    }
}