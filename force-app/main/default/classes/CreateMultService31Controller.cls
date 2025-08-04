public class CreateMultService31Controller {
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
    
    
    @AuraEnabled
    public static string addFile_n_LineItems(String Id, String mdoc, String lineitemlist){
        try {
            if (mdoc != '') {
                // String fileJson = System.JSON.serialize(mdoc);
                relatedFile relatedDocument = (relatedFile) System.JSON.deserialize(mdoc, relatedFile.class);
                Attachment att = new Attachment();
                att.ParentId = Id;
                att.Name = relatedDocument.Title;
                att.Body = relatedDocument.VersionData;
                insert att;

            }


            if (lineitemlist != '') {

                String s = lineitemlist.replace('__c','_c');

                List<Multiple_Service_31_Line_Item__c> MSLItoInsertList = new List<Multiple_Service_31_Line_Item__c>();
                List < Attachment > attlist = new List < Attachment > ();

                List <MultiServiceLineItemList > vList = parseJsonData(s);
                for (MultiServiceLineItemList v: vList) {
                    Multiple_Service_31_Line_Item__c msli = new Multiple_Service_31_Line_Item__c();
                    msli.Multiple_Service_31__c = Id;
                    msli.Existing_TDS_TPS_Reference_No__c = v.Existing_TDS_TPS_Reference_No_c;
                    msli.Field_Staff_TDC_Remark__c = v.Field_Staff_TDC_Remark_c;
                    msli.Quantity__c = Decimal.valueOf(v.Quantity_c);
                    msli.Revision__c = v.Revision_c;
                    msli.TDC_TPS_No__c = v.TDC_TPS_No_c;
                    msli.Unit_of_Measure__c = v.Unit_of_Measure_c;
                    MSLItoInsertList.add(msli);

                    // Handle the file attachment
                    // Map<String, Object> fileData = (Map<String, Object>) recordData.get('file');
                    if (v.file != null) {
                        Attachment att = new Attachment();
                        // relatedFile relatedDocument = (relatedFile) System.JSON.deserialize(v.file, relatedFile.class);
                        att.Name = v.file.Title;
                        att.Body = v.file.VersionData;
                        attlist.add(att);
                    }

                }
                insert MSLItoInsertList;
                system.debug('MSLItoInsertList');

                // Attach files to the corresponding records
                for (Integer i = 0; i < MSLItoInsertList.size(); i++) {
                    if (i < attlist.size()) {
                        attlist[i].ParentId = MSLItoInsertList[i].Id;
                    }
                }
                insert attlist;

            }
            return 'ok';
            
        } catch (Exception e) {
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }

    public static List < MultiServiceLineItemList > parseJsonData(String json) {
        return (List < MultiServiceLineItemList > ) System.JSON.deserialize(json, List < MultiServiceLineItemList > .class);
    }
    public class MultiServiceLineItemList {
        public String Existing_TDS_TPS_Reference_No_c;
        public String Field_Staff_TDC_Remark_c;
        public String Quantity_c;
        public String Revision_c;
        public String TDC_TPS_No_c;
        public String Unit_of_Measure_c;
        public relatedFile file;
    }

    public static void deleteOldRecords() {
        // Get today's date
        Date today = Date.today();
        
        // Query records that were not created today
        List<API_Log__c> recordsToDelete = [SELECT Id FROM API_Log__c 
                                               WHERE CreatedDate < :today];
        
        // Check if there are records to delete
        if (!recordsToDelete.isEmpty()) {
            try {
                // Delete the records
                delete recordsToDelete;
                System.debug('Successfully deleted ' + recordsToDelete.size() + ' records.');
            } catch (DmlException e) {
                System.debug('Failed to delete records: ' + e.getMessage());
            }
        } else {
            System.debug('No records found to delete.');
        }
    }

}