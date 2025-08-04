trigger convertSLeadtoCLeadTrigger on Lead(before insert, after insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {

        system.debug('**We are Inside Before Insert Lead Trigger');

        Set<String> cloneSet = new Set<String>();
        Map<Id, Boolean> cloneMap = new Map<Id, Boolean>();

        for(Lead ld : Trigger.new){
            cloneSet.add(ld.getCloneSourceId());
        }

        system.debug('cloneSet-->' +cloneSet);

        if(cloneSet!=null){
            List<Lead> ClonedLeadList = [SELECT Id, IsCreatedFromCustomLead__c FROM Lead WHERE Id IN :cloneSet];
            if(ClonedLeadList.size()>0){
                for(Lead ld : ClonedLeadList){
                    cloneMap.put(ld.Id, ld.IsCreatedFromCustomLead__c);
                }
            }
        }

        for(Lead ld : Trigger.new){

            if(!cloneMap.IsEmpty()){

                if(cloneMap.containsKey(ld.getCloneSourceId())){
                    ld.IsCreatedFromCustomLead__c = false;
                    system.debug('IsCreatedFromStandardLead__c is set as False in Before Insert During Clone -> ' +ld.IsCreatedFromCustomLead__c);
                }
            }
        }
    }

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {

            try {

                List < Lead__c > insertCLeadList = new List < Lead__c > ();

                for (Lead ld: Trigger.new) {
                    System.debug('Newly Inserted Lead Trigger 001::> ' + ld);

                    //To stop the Trigger from executing on loops
                    if(ld.IsCreatedFromCustomLead__c == false){
                        Lead__c cld = new Lead__c();
                        cld.Name = ld.FirstName;
                        cld.Last_Name__c = ld.LastName;
                        cld.Salutation__c = ld.Salutation;
                        cld.Company_Name__c = ld.Company;
                        cld.Email__c = ld.Email;
                        cld.Mobile_Number__c = ld.MobilePhone;
                        cld.GSTIN__c = ld.GSTIN__c;
                        cld.Address_ID__c = ld.Address_ID__c;
                        cld.GST_Type__c = ld.GST_Type__c;
                        cld.Industry__c = ld.Industry__c;
                        cld.Key_Person__c = ld.Key_Person__c;
                        cld.Territory__c = ld.Territory__c;
                        cld.Lead_Type__c = ld.Lead_Type__c;
                        cld.Lead_Lost_Reason__c = ld.Lead_Lost_Reason__c;
                        cld.Lead_Source__c = ld.LeadSource;
                        cld.Repeat_Calls_Frequency__c = ld.Repeat_Calls_Frequency__c;
                        cld.Sales_Turnover__c = ld.Sales_Turnover__c;
                        cld.CIN_Number__c = ld.CIN_Number__c;
                        cld.Year_of_Establishment__c = ld.Year_of_Establishment__c;
                        cld.GST_Number__c = ld.GST_Number__c;
                        cld.Number_of_Employees__c = ld.NumberOfEmployees;
                        cld.PAN_Card_Number__c = ld.PAN_Card_Number__c;
                        cld.Website__c = ld.Website;
                        cld.Lead_Status__c = ld.Status;
                        cld.Other_Lost_Reason__c = ld.Other_Lost_Reason__c;     
                        cld.Line_1_Block__c = ld.Line_1_Block__c;
                        cld.Line_2_Building_Floor_Room__c = ld.Line_2_Building_Floor_Room__c;
                        cld.Line_3_Street_PO_Box__c = ld.Line_3_Street_PO_Box__c;
                        cld.City__c = ld.City__c;
                        cld.Area__c = ld.Area__c;
                        cld.District__c = ld.District__c;
                        cld.Zip_Code__c = ld.Zip_Code__c;
                        cld.State__c = ld.State__c;
                        cld.Country__c = ld.Country__c;
                        cld.Repeat_Calls_Allowed__c = ld.Repeat_Calls_Allowed__c;
                        cld.Other_Repeat_Calls_Frequency__c = ld.Other_Repeat_Calls_Frequency__c;
                        cld.Rating__c = ld.Rating;
                        cld.Other_Lead_Source__c = ld.Other_Lead_Source__c;
                        cld.Landline_No__c = ld.Phone;
                        cld.Title__c = ld.Title;
                        cld.IsCreatedFromStandardLead__c = true;
                        //cld.Bill_To__c = ld.Bill_To__c;
                        insertCLeadList.add(cld);
                    }
                }

                if(insertCLeadList.size()>0){
                    INSERT insertCLeadList;
                }

            } catch (Exception e) {
                System.debug('Something went wrong!!! ' + e.getMessage());
            }
        }

        if (Trigger.isUpdate) {

            try {

                Map < Id, Lead > oldLeadMap = Trigger.oldMap;
                Map < Id, Lead > newLeadMap = Trigger.newMap;

                List < Lead__c > upsertCLeadList = new List < Lead__c > ();
                Boolean flag = false;

                for (Integer i = 0; i < newLeadMap.values().size(); i++) {
                    Lead OldLead = oldLeadMap.values()[i];
                    Lead NewLead = newLeadMap.values()[i];
                    List < Lead__c > leadListbyEmail = new List < Lead__c > ();
                    Lead__c cld = new Lead__c();

                    leadListbyEmail = [SELECT Id, Name, Email__c FROM Lead__c WHERE Email__c =: OldLead.Email];

                    cld.Id = leadListbyEmail[0].Id;

                    if (OldLead.Salutation != NewLead.Salutation) {
                        cld.Salutation__c = NewLead.Salutation;
                        flag = true;
                    }

                    if (OldLead.FirstName != NewLead.FirstName) {
                        cld.Name = NewLead.FirstName;
                        flag = true;
                    }

                    if (OldLead.MiddleName != NewLead.MiddleName) {
                        cld.Middle_Name__c = NewLead.MiddleName;
                        flag = true;
                    }

                    if (OldLead.LastName != NewLead.LastName) {
                        cld.Last_Name__c = NewLead.LastName;
                        flag = true;
                    }

                    if (OldLead.Industry__c != NewLead.Industry__c) {
                        cld.Industry__c = NewLead.Industry__c;
                        flag = true;
                    }

                    if (OldLead.Website != NewLead.Website) {
                        cld.Website__c = NewLead.Website;
                        flag = true;
                    }

                    if (OldLead.Status != NewLead.Status) {
                        cld.Lead_Status__c = NewLead.Status;
                        flag = true;
                    }

                    if (OldLead.Territory__c != NewLead.Territory__c) {
                        cld.Territory__c = NewLead.Territory__c;
                        flag = true;
                    }

                    if (OldLead.Lead_Type__c != NewLead.Lead_Type__c) {
                        cld.Lead_Type__c = NewLead.Lead_Type__c;
                        flag = true;
                    }

                    if (OldLead.PAN_Card_Number__c != NewLead.PAN_Card_Number__c) {
                        cld.PAN_Card_Number__c = NewLead.PAN_Card_Number__c;
                        flag = true;
                    }

                    if (OldLead.GST_Type__c != NewLead.GST_Type__c) {
                        cld.GST_Type__c = NewLead.GST_Type__c;
                        flag = true;
                    }

                    if (OldLead.GSTIN__c != NewLead.GSTIN__c) {
                        cld.GSTIN__c = NewLead.GSTIN__c;
                        flag = true;
                    }

                    if (OldLead.CIN_Number__c != NewLead.CIN_Number__c) {
                        cld.CIN_Number__c = NewLead.CIN_Number__c;
                        flag = true;
                    }

                    if (OldLead.Lead_Lost_Reason__c != NewLead.Lead_Lost_Reason__c) {
                        cld.Lead_Lost_Reason__c = NewLead.Lead_Lost_Reason__c;
                        flag = true;
                    }

                    if (OldLead.Year_of_Establishment__c != NewLead.Year_of_Establishment__c) {
                        cld.Year_of_Establishment__c = NewLead.Year_of_Establishment__c;
                        flag = true;
                    }

                    if (OldLead.Key_Person__c != NewLead.Key_Person__c) {
                        cld.Key_Person__c = NewLead.Key_Person__c;
                        flag = true;
                    }

                    if (OldLead.Other_Lost_Reason__c != NewLead.Other_Lost_Reason__c) {
                        cld.Other_Lost_Reason__c = NewLead.Other_Lost_Reason__c;
                        flag = true;
                    }

                    if (OldLead.Address_ID__c != NewLead.Address_ID__c) {
                        cld.Address_ID__c = NewLead.Address_ID__c;
                        flag = true;
                    }

                    if (OldLead.Sales_Turnover__c != NewLead.Sales_Turnover__c) {
                        cld.Sales_Turnover__c = NewLead.Sales_Turnover__c;
                        flag = true;
                    }

                    if (OldLead.GST_Number__c != NewLead.GST_Number__c) {
                        cld.GST_Number__c = NewLead.GST_Number__c;
                        flag = true;
                    }

                    if (OldLead.Repeat_Calls_Allowed__c != NewLead.Repeat_Calls_Allowed__c) {
                        cld.Repeat_Calls_Allowed__c = NewLead.Repeat_Calls_Allowed__c;
                        flag = true;
                    }

                    if (OldLead.Repeat_Calls_Frequency__c != NewLead.Repeat_Calls_Frequency__c) {
                        cld.Repeat_Calls_Frequency__c = NewLead.Repeat_Calls_Frequency__c;
                        flag = true;
                    }
                    if (OldLead.Other_Repeat_Calls_Frequency__c != NewLead.Other_Repeat_Calls_Frequency__c) {
                        cld.Other_Repeat_Calls_Frequency__c = NewLead.Other_Repeat_Calls_Frequency__c;
                        flag = true;
                    } 

                    if (OldLead.LeadSource != NewLead.LeadSource) {
                        cld.Lead_Source__c = NewLead.LeadSource;
                        flag = true;
                    }

                    if (OldLead.Other_Lead_Source__c != NewLead.Other_Lead_Source__c) {
                        cld.Other_Lead_Source__c = NewLead.Other_Lead_Source__c;
                        flag = true;
                    }

                    if (OldLead.Rating != NewLead.Rating) {
                        cld.Rating__c = NewLead.Rating;
                        flag = true;
                    }

                    if (OldLead.Phone != NewLead.Phone) {
                        cld.Landline_No__c = NewLead.Phone;
                        flag = true;
                    }

                    if (OldLead.MobilePhone != NewLead.MobilePhone) {
                        cld.Mobile_Number__c = NewLead.MobilePhone;
                        flag = true;
                    }

                    if (OldLead.Email != NewLead.Email) {
                        cld.Email__c = NewLead.Email;
                        flag = true;
                    }

                    if (OldLead.Company != NewLead.Company) {
                        cld.Company_Name__c = NewLead.Company;
                        flag = true;
                    }

                    if (OldLead.Line_1_Block__c != NewLead.Line_1_Block__c) {
                        cld.Line_1_Block__c = NewLead.Line_1_Block__c;
                        flag = true;
                    }
    
                    if (OldLead.Line_2_Building_Floor_Room__c != NewLead.Line_2_Building_Floor_Room__c) {
                        cld.Line_2_Building_Floor_Room__c = NewLead.Line_2_Building_Floor_Room__c;
                        flag = true;
                    }
    
                    if (OldLead.Line_3_Street_PO_Box__c != NewLead.Line_3_Street_PO_Box__c) {
                        cld.Line_3_Street_PO_Box__c = NewLead.Line_3_Street_PO_Box__c;
                        flag = true;
                    }
    
                    if (OldLead.City__c != NewLead.City__c) {
                        cld.City__c = NewLead.City__c;
                        flag = true;
                    }
    
                    if (OldLead.Area__c != NewLead.Area__c) {
                        cld.Area__c = NewLead.Area__c;
                        flag = true;
                    }
    
                    if (OldLead.District__c != NewLead.District__c) {
                        cld.District__c = NewLead.District__c;
                        flag = true;
                    }
    
                    if (OldLead.Zip_Code__c != NewLead.Zip_Code__c) {
                        cld.Zip_Code__c = NewLead.Zip_Code__c;
                        flag = true;
                    }
    
                    if (OldLead.State__c != NewLead.State__c) {
                        cld.State__c = NewLead.State__c;
                        flag = true;
                    }

                    if (OldLead.Country__c != NewLead.Country__c) {
                        cld.Country__c = NewLead.Country__c;
                        flag = true;
                    }

                    if (OldLead.Title != NewLead.Title) {
                        cld.Title__c = NewLead.Title;
                        flag = true;
                    }

                    if (OldLead.NumberOfEmployees != NewLead.NumberOfEmployees) {
                        cld.Number_of_Employees__c = NewLead.NumberOfEmployees;
                        flag = true;
                    }

    
                    // if (OldLead.city != NewLead.city) {
                    //     cld.City__c = NewLead.city;
                    //     flag = true;
                    // 
                        
                    //if (OldLead.Bill_To__c != NewLead.Bill_To__c) {
                        //cld.Bill_To__c = NewLead.Bill_To__c;
                        //flag = true;
                    //}
                        
                        
                    if (flag = true) {
                        upsertCLeadList.add(cld);
                    }
                        
                }

                if (upsertCLeadList.size() > 0) {
                    UPDATE upsertCLeadList;
                }

            } catch (Exception e) {
                System.debug('Something went wrong!!! ' + e.getMessage());
            }
        }
    }

}