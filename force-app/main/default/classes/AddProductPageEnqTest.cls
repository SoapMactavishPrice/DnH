@isTest
public class AddProductPageEnqTest {
    
    @isTest
    static void testGetProducts() {
        Item_Master__c item1 = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (NORMA-V)');
        Item_Master__c item2 = new Item_Master__c(Name = 'Product 2', Item_Category__c = '6013 (REST)');
        insert new List<Item_Master__c>{ item1, item2 };

        Test.startTest();
        List<Item_Master__c> products = AddProductPageEnq.getProducts('6013 (NORMA-V)');
        Test.stopTest();
        
    }

    @isTest
    static void testFindProduct() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Enquiry__c enquiry = new Enquiry__c(Account__c = account.Id);
        insert enquiry;

        Item_Master__c item = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (NORMA-V)');
        insert item;

        Enquiry_Line_Item__c enquiryLine = new Enquiry_Line_Item__c(Enquiry__c = enquiry.Id, Item_Master__c = item.Id);
        insert enquiryLine;

        Test.startTest();
        String result = AddProductPageEnq.findProduct(enquiry.Id, new List<String>{ 'Family A'});
        Test.stopTest();
    }

    @isTest
    static void testFindRecentEnqLineItem() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Enquiry__c enquiry = new Enquiry__c(Account__c = account.Id);
        insert enquiry;

        Item_Master__c item = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (REST)');
        insert item;

        Enquiry_Line_Item__c enquiryLine = new Enquiry_Line_Item__c(Enquiry__c = enquiry.Id, Item_Master__c = item.Id);
        insert enquiryLine;

        Test.startTest();
        String result = AddProductPageEnq.findRecentenqlineitem(item.Id);
        Test.stopTest();

    }

    @isTest
    static void testGetProductFamily() {
        Test.startTest();
        Map<String, List<AddProductPageEnq.PicklistValue>> families = AddProductPageEnq.getproductfamily();
        Test.stopTest();
        
    }

    @isTest
    static void testGetItemCategory() {
        Test.startTest();
        List<AddProductPageEnq.PicklistValue> categories = AddProductPageEnq.getItemCategory();
        Test.stopTest();

    }

    @isTest
    static void testSaveProducts() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Enquiry__c enquiry = new Enquiry__c(Account__c = account.Id);
        insert enquiry;

        Item_Master__c item = new Item_Master__c(Name = 'Product 1', Item_Category__c = '6013 (REST)');
        insert item;

        List<AddProductPageEnq.ProductWrapper> products = new List<AddProductPageEnq.ProductWrapper>();
        AddProductPageEnq.ProductWrapper wrapper = new AddProductPageEnq.ProductWrapper();
        wrapper.Product2Id = item.Id;
        wrapper.Price = 100;
        wrapper.Quantity = 2;
        products.add(wrapper);

        Test.startTest();
        String result = AddProductPageEnq.saveProducts(JSON.serialize(products), enquiry.Id);
        Test.stopTest();

    }
}