@isTest
public class copyAddressHandlerTest {

    @isTest
    static void testCopyAddressToRecord() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        
         Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;
        
        State__c testState = new State__c(Name = 'Test State', Country__c = testCountry.Id);
        insert testState;
        
        City__c testCity = new City__c(Name = 'Test City');
        insert testCity;
      /*  
        Area__c testArea = new Area__c(Name = 'Test Area');
        insert testArea;
       
        Postal_Code__c testPostalCode = new Postal_Code__c(Name = '12345', Area__c = testArea.Id, City__c = testCity.Id, State__c = testState.Id, Country__c = testCountry.Id);
        insert testPostalCode;
*/

        Address_Information__c billToAddress = new Address_Information__c();
        billToAddress.Name = 'Test Bill To';
        billToAddress.Account__c = testAccount.Id;
        billToAddress.Line_1_Block__c = '123 Main St';
        billToAddress.Line_2_Building_Floor_Room__c = 'Suite 100';
        billToAddress.Line_3_Street_PO_Box__c = 'PO Box 456';
        billToAddress.City__c = testCity.Id; 
        billToAddress.Zip_Code__c = '12345';
        billToAddress.State__c = testState.Id; 
        billToAddress.Country__c = testCountry.Id; 
        billToAddress.Tax_Type__c = 'Composition Levy';
        billToAddress.TAX_Number__c = 123456789;
        billToAddress.Copy_Ship_To_From_Bill_To__c = true;

        insert billToAddress;

        Test.startTest();
        copyAddressHandler.copyAddressToRecord(new List<Address_Information__c>{ billToAddress });
        Test.stopTest();
    }

    @isTest
    static void testCopySoldAddressToRecord() {
		Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
          Country__c testCountry = new Country__c(Name = 'India');
        insert testCountry;
        
        State__c testState = new State__c(Name = 'Test State', Country__c = testCountry.Id);
        insert testState;
        
        City__c testCity = new City__c(Name = 'Test City');
        insert testCity;


        Address_Information__c billToAddress = new Address_Information__c();
        billToAddress.Name = 'Test Bill To';
        billToAddress.Account__c = testAccount.Id;
        billToAddress.Line_1_Block__c = '123 Main St';
        billToAddress.Line_2_Building_Floor_Room__c = 'Suite 100';
        billToAddress.Line_3_Street_PO_Box__c = 'PO Box 456';
        billToAddress.City__c = testCity.Id; 
        billToAddress.Zip_Code__c = '12345';
        billToAddress.State__c = testState.Id; 
        billToAddress.Country__c = testCountry.Id; 
        billToAddress.Tax_Type__c = 'Composition Levy';
        billToAddress.TAX_Number__c = 123456789;
        billToAddress.Copy_Sold_To_From_Bill_To__c = true;

        insert billToAddress;

        Test.startTest();
        copyAddressHandler.copySoldAddressToRecord(new List<Address_Information__c>{ billToAddress });
        Test.stopTest();

    }
}