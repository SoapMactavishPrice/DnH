@IsTest
public class ContactAddCountryCodeTest {

    @IsTest
    static void testManualContactCreation_Add91Prefix() {
        // Case 1: User enters number manually without 91
        Contact con = new Contact(
            LastName = 'Manual Test',
            MC_Mobile_No__c = '9876543210'
        );
        insert con;

        Contact insertedCon = [
            SELECT MC_Mobile_No__c
            FROM Contact
            WHERE Id = :con.Id
        ];

       
    }

    @IsTest
    static void testLeadConversionScenario_CopyFromMobilePhone() {
        // Case 2: MC_Mobile_No__c is blank, but MobilePhone has a value
        Contact con = new Contact(
            LastName = 'From MobilePhone',
            MobilePhone = '9999999999'
        );
        insert con;

        Contact insertedCon = [
            SELECT MC_Mobile_No__c
            FROM Contact
            WHERE Id = :con.Id
        ];

        
    }

    @IsTest
    static void testAlreadyHas91Prefix() {
        // Case 3: Number already has 91 prefix
        Contact con = new Contact(
            LastName = 'Already Has 91',
            MC_Mobile_No__c = '919876543210'
        );
        insert con;

        Contact insertedCon = [
            SELECT MC_Mobile_No__c
            FROM Contact
            WHERE Id = :con.Id
        ];

        
    }

    @IsTest
    static void testBlankNumber() {
        // Case 4: Blank MobilePhone and MC_Mobile_No__c
        Contact con = new Contact(LastName = 'Blank Test');
        insert con;

        Contact insertedCon = [
            SELECT MC_Mobile_No__c
            FROM Contact
            WHERE Id = :con.Id
        ];

       
    }

    @IsTest
    static void testUpdateScenario() {
        // Case 5: Updating existing Contact
        Contact con = new Contact(
            LastName = 'Update Test',
            MC_Mobile_No__c = '8888888888'
        );
        insert con;

        con.MC_Mobile_No__c = '7777777777';
        update con;

        Contact updatedCon = [
            SELECT MC_Mobile_No__c
            FROM Contact
            WHERE Id = :con.Id
        ];

       
    }
}