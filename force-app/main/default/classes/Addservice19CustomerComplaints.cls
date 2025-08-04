public class Addservice19CustomerComplaints {
    @AuraEnabled
    public static string getcodemaster(String objectname) {
       list<Code_Master__c>codem = [SELECT Id, Name, Object__c, Display_Label__c, Current_Sequence__c, Starting_Sequence__c, 
                                    Backend_Current_Sequence__c,For_Display_Sequence__c FROM Code_Master__c 
                                    WHERE Object__c =:objectname AND Is_Active__c = true 
                                    LIMIT 1 FOR UPDATE];
         if (!codem.isEmpty()) {
             
              String name = codem[0].Display_Label__c +'/'+ String.valueOf(codem[0].For_Display_Sequence__c);
             codem[0].Current_Sequence__c += 1;
             update codem;
                  //+ String.valueOf(codem.Backend_Current_Sequence__c);
           return name;
            } else {
        return null; // or you can throw an exception if you expect at least one result
     }
    }  
}