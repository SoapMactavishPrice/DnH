trigger LeadToCustomLead on Lead (after insert) {
    
    // Collect only Leads where Lead_created_via_TI_and_IM__c = false
    List<Lead> validLeads = new List<Lead>();
    for (Lead ld : Trigger.new) {
        if (ld.Lead_created_via_TI_and_IM__c == false) {
            validLeads.add(ld);
        }
    }
    
    if (validLeads.isEmpty()) {
        return; // exit trigger if nothing valid
    }
    
    Set<String> emails = new Set<String>();
    Set<String> mobiles = new Set<String>();
    
    for (Lead ld : validLeads) {
        if (String.isNotBlank(ld.Email)) {
            emails.add(ld.Email.toLowerCase());
        }
        if (String.isNotBlank(ld.MobilePhone)) {
            mobiles.add(ld.MobilePhone);
        }
    }
    
    // Fetch existing Custom Leads
    Map<String, Lead__c> existingByEmail = new Map<String, Lead__c>();
    Map<String, Lead__c> existingByMobile = new Map<String, Lead__c>();
    
    if (!emails.isEmpty() || !mobiles.isEmpty()) {
        for (Lead__c cl : [
            SELECT Id, Email__c, Mobile_Number__c 
            FROM Lead__c 
            WHERE Email__c IN :emails OR Mobile_Number__c IN :mobiles
        ]) {
            if (cl.Email__c != null) existingByEmail.put(cl.Email__c.toLowerCase(), cl);
            if (cl.Mobile_Number__c != null) existingByMobile.put(cl.Mobile_Number__c, cl);
        }
    }
    
    List<Lead__c> toInsertCustomLeads = new List<Lead__c>();
    List<Lead_Source__c> toInsertLeadSources = new List<Lead_Source__c>();
    List<Lead> toUpdateStdLeads = new List<Lead>(); // ✅ collect std leads for MC update
    
    // temporary map: standard Lead Id → Lead_Source__c (for parent assignment later)
    Map<Id, Lead_Source__c> pendingSourceMap = new Map<Id, Lead_Source__c>();
    
    for (Lead ld : validLeads) {
        Lead__c parentLead = null;
        
        if (ld.Email != null && existingByEmail.containsKey(ld.Email.toLowerCase())) {
            parentLead = existingByEmail.get(ld.Email.toLowerCase());
        } else if (ld.MobilePhone != null && existingByMobile.containsKey(ld.MobilePhone)) {
            parentLead = existingByMobile.get(ld.MobilePhone);
        }
        
        String tenDigitMobile = null;
        if(ld.MobilePhone != null){
            tenDigitMobile = ld.MobilePhone.right(10);
        }
        
        // ✅ always prepare Std Lead update for MC_Mobile_No__c
        if (tenDigitMobile != null) {
            Lead updateLd = new Lead(Id = ld.Id);
            updateLd.MC_Mobile_No__c = '91' + tenDigitMobile;
            toUpdateStdLeads.add(updateLd);
        }
        
        if (parentLead != null) {
            // Found existing Custom Lead → Create new Lead_Source__c
            Lead_Source__c ls = new Lead_Source__c();
            ls.Lead__c  = parentLead.Id;
            ls.Std_Lead__c = ld.Id; // 🔗 link to Standard Lead
            ls.Lead_Source__c  = (ld.How_did_you_find_us__c != null) ? 'Website' : ld.LeadSource;
            ls.How_did_you_find_us__c = ld.How_did_you_find_us__c;
            ls.Select_your_enquiry_category__c = ld.Select_your_enquiry_category__c;
            ls.Product_Name__c = ld.Product__c;
            ls.Message__c = ld.Description;
            ls.Mobile_No__c = ld.MobilePhone;
            ls.MC_Mobile_No__c = (tenDigitMobile != null ? '91' + tenDigitMobile : null);
            ls.Email__c = ld.Email;
            ls.Quantity__c = ld.Quantity__c;
            ls.Location__c = ld.Location__c; 
            ls.Captured_Lead_Id__c = ld.Id;
            toInsertLeadSources.add(ls);
            
        } else {
            // Create new Custom Lead
            Lead__c newCl = new Lead__c();
            newCl.Lead__c = ld.Id;
            newCl.Name = ld.Company;
            newCl.First_Name__c = ld.FirstName;
            newCl.Last_Name__c = ld.LastName;
            newCl.Email__c = ld.Email;
            newCl.Mobile_Number__c = ld.MobilePhone;
            newCl.Location__c = ld.Location__c;
            newCl.How_did_you_find_us__c = ld.How_did_you_find_us__c;
            newCl.Select_your_enquiry_category__c = ld.Select_your_enquiry_category__c;
            newCl.Description__c = ld.Description;
            newCl.Quantity__c = ld.Quantity__c;
            newCl.Website_to_Lead__c = true;
            if(ld.How_did_you_find_us__c != null){
                newCl.Lead_Source__c  = 'Website'; 
                newCl.Website_to_Lead__c = true;
            }
            toInsertCustomLeads.add(newCl);
            
            // prepare child LeadSource, parent will be linked after insert
            Lead_Source__c ls = new Lead_Source__c();
            ls.Lead_Source__c  = (ld.How_did_you_find_us__c != null) ? 'Website' : ld.LeadSource;
            ls.Std_Lead__c = ld.Id; // 🔗 link to Standard Lead
            ls.Captured_Lead_Id__c = ld.Id;
            ls.How_did_you_find_us__c = ld.How_did_you_find_us__c;
            ls.Select_your_enquiry_category__c = ld.Select_your_enquiry_category__c;
            ls.Product_Name__c = ld.Product__c;
            ls.Message__c = ld.Description;
            ls.Mobile_No__c = ld.MobilePhone;
            ls.MC_Mobile_No__c = (tenDigitMobile != null ? '91' + tenDigitMobile : null);
            ls.Email__c = ld.Email;
            ls.Quantity__c = ld.Quantity__c;
            ls.Location__c = ld.Location__c; 
            pendingSourceMap.put(ld.Id, ls);
        }
    }
    
    if (!toInsertCustomLeads.isEmpty()) insert toInsertCustomLeads;
    
    // After insert, map new Custom Leads back to their LeadSources
    if (!toInsertCustomLeads.isEmpty()) {
        Map<String, Id> emailOrMobileToClId = new Map<String, Id>();
        for (Lead__c cl : toInsertCustomLeads) {
            if (cl.Email__c != null) {
                emailOrMobileToClId.put(cl.Email__c.toLowerCase(), cl.Id);
            } else if (cl.Mobile_Number__c != null) {
                emailOrMobileToClId.put(cl.Mobile_Number__c, cl.Id);
            }
        }
        
        for (Lead ld : validLeads) {
            if (pendingSourceMap.containsKey(ld.Id)) {
                Lead_Source__c ls = pendingSourceMap.get(ld.Id);
                
                if (ld.Email != null && emailOrMobileToClId.containsKey(ld.Email.toLowerCase())) {
                    ls.Lead__c = emailOrMobileToClId.get(ld.Email.toLowerCase());
                } else if (ld.MobilePhone != null && emailOrMobileToClId.containsKey(ld.MobilePhone)) {
                    ls.Lead__c = emailOrMobileToClId.get(ld.MobilePhone);
                }
                toInsertLeadSources.add(ls);
            }
        }
    }
    
    if (!toInsertLeadSources.isEmpty()) insert toInsertLeadSources;
    if (!toUpdateStdLeads.isEmpty()) update toUpdateStdLeads; // ✅ update MC_Mobile_No__c in std lead
}