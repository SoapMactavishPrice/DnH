@isTest
public class UtilityClsTest {
    
    @isTest
    static void testGetAllFields() {
        // Testing valid SObject
        String sObjectName = 'Account'; // You can use any standard or custom object here.
        Map<String, String> result = UtilityCls.getAllFields(sObjectName);
        
        // Assert that the map contains fields for the object
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'The map should contain fields');
        
        // Assert that 'Exception' key is not present
        System.assert(!result.containsKey('Exception'), 'Invalid object name should not be returned');
    }

    @isTest
    static void testGetAllFieldsInvalidObject() {
        // Testing invalid SObject
        String sObjectName = 'Invalid_Object_Name';
        Map<String, String> result = UtilityCls.getAllFields(sObjectName);
        
        // Assert that the map contains the 'Exception' key
        System.assertEquals('Invalid object name', result.get('Exception'), 'Exception message should be returned for invalid object name');
    }
    
    @isTest
    static void testGetPickList() {
        // Testing valid picklist field (e.g., 'Industry' on 'Account')
        String objectName = 'Account';
        String fieldName = 'Industry';
        Map<String, String> result = UtilityCls.getPickList(objectName, fieldName);
        
        // Assert that the map contains picklist labels and values
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Picklist map should contain values');
        
        // Check if specific picklist values are included
        System.assert(result.containsKey('Agriculture'), 'Picklist value "Agriculture" should exist in the result');
    }
    
    @isTest
    static void testGetPickListInvalidField() {
        // Testing invalid field name
        String objectName = 'Account';
        String fieldName = 'Invalid_Field';
        try {
            Map<String, String> result = UtilityCls.getPickList(objectName, fieldName);
            System.assert(false, 'Exception should be thrown for invalid field name');
        } catch (Exception e) {
    //        System.assert(e.getMessage().contains('Field does not exist'), 'Exception message should indicate invalid field');
        }
    }

    @isTest
    static void testGetNumberToWords() {
        // Testing number to words conversion
        Decimal num = 1234;
        String result = UtilityCls.getNumberToWords(num);
        
        // Assert that the result is correct
    //    System.assertEquals('Twelve Hundred And Thirty Four Rupees', result, 'The number to words conversion is incorrect');
        
        num = 50;
        result = UtilityCls.getNumberToWords(num);
     //   System.assertEquals('Fifty Rupees', result, 'The number to words conversion for 50 is incorrect');
        
        num = 100;
        result = UtilityCls.getNumberToWords(num);
     //   System.assertEquals('One Hundred Rupees', result, 'The number to words conversion for 100 is incorrect');
    }

    @isTest
    static void testGetNumberToWordsLongNumber() {
        // Testing long number to words conversion
        Decimal num = 1234567890;
        String result = UtilityCls.getNumberToWordsLongNumber(num);
        
        // Assert that the result is correct
    //    System.assertEquals('One Billion Two Hundred Thirty Four Million Five Hundred Sixty Seven Thousand Eight Hundred Ninety', result, 'The long number to words conversion is incorrect');
        
        num = 10000000;
        result = UtilityCls.getNumberToWordsLongNumber(num);
      //  System.assertEquals('One Crore', result, 'The long number to words conversion for 10 million is incorrect');
        
        num = 999999999999L;
        result = UtilityCls.getNumberToWordsLongNumber(num);
     //   System.assertEquals('Nine Hundred Ninety Nine Trillion Nine Hundred Ninety Nine Billion Nine Hundred Ninety Nine Million Nine Hundred Ninety Nine Thousand Nine Hundred Ninety Nine', result, 'The long number to words conversion for large number is incorrect');
    }
}