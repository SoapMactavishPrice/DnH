@isTest
private class QueueItemTriggerTest {
    
    @isTest
    static void testQueueItemInsertAndUpdate() {
        
        // Enable the custom label businessCard for testing
        //System.Label.businessCard = 'true';
        
        // Create a test Queue Item record
        eContacts__Queue_Item__c queueItem = new eContacts__Queue_Item__c(
            eContacts__Company__c = 'Test Company',
            eContacts__First_Name__c = 'John',
            eContacts__Last_Name__c = 'Doe',
            eContacts__Email__c = 'johndoe@example.com',
            eContacts__Phone_Mobile__c = '1234567890',
            eContacts__Phone_Office__c = '0987654321',
            eContacts__Designation__c = 'Manager',
            eContacts__Website__c = 'www.testcompany.com',
            eContacts__Address_Street__c = '123 Main St',
            eContacts__Address_City__c = 'New York',
            eContacts__Address_State__c = 'NY',
            eContacts__Address_Zip__c = '10001',
            eContacts__Address_Country__c = 'USA'
        );
        
        Test.startTest();
        insert queueItem;
        
        // Verify Lead is created
        Lead__c createdLead = [SELECT Id, Email__c, First_Name__c, Last_Name__c FROM Lead__c WHERE Email__c = 'johndoe@example.com' LIMIT 1];
        System.assertNotEquals(null, createdLead, 'Lead should have been created.');
        System.assertEquals('John', createdLead.First_Name__c);
        System.assertEquals('Doe', createdLead.Last_Name__c);

        // Update the Queue Item to trigger an update on the Lead
        queueItem.eContacts__Company__c = 'Updated Company';
        queueItem.eContacts__Phone_Mobile__c = '1112223333';
        update queueItem;
        Test.stopTest();

        // Verify Lead is updated
        Lead__c updatedLead = [SELECT Id, Name, Mobile_Number__c FROM Lead__c WHERE Email__c = 'johndoe@example.com' LIMIT 1];
        System.assertEquals('Updated Company', updatedLead.Name, 'Lead Name should be updated.');
        System.assertEquals('1112223333', updatedLead.Mobile_Number__c, 'Lead Mobile Number should be updated.');
    }
}