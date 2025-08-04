public class CustomLeadAfterUpdateTriggerHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        system.debug('**We are Inside After Update**');

        Map<Id, Lead__c> oldMap = (Map<Id, Lead__c>)tp.oldMap;
        Map<Id, Lead__c> newMap = (Map<Id, Lead__c>)tp.newMap;
        Set<String> emailId = new Set<String>();

        Map<String, Lead__c> oldLeadMap = new Map<String, Lead__c>();
        Map<String, Lead__c> newLeadMap = new Map<String, Lead__c>();
        
        //This block runs on Custom Lead and Extracts the Email as Key
        for (Integer i = 0; i < newMap.values().size(); i++) {
            Lead__c oldLead = oldMap.values()[i];
            Lead__c newLead = newMap.values()[i];

            emailId.add(newLead.Email__c);
            oldLeadMap.put(oldLead.Email__c, oldLead);
            newLeadMap.put(newLead.Email__c, newLead);
        }

        if (emailId.size() > 0) {
            //Based on Key email, we are filtering the Standard Leads of which we wanted to modify the values.
            List<Lead> leadList = [SELECT Id, Salutation, FirstName, MiddleName, LastName, Industry, Website, Status, Territory__c, 
                                   Custom_Lead__c, Lead_Type__c, PAN_Card_Number__c, GST_Type__c, 
                                   GSTIN__c, 
                                   CIN_Number__c, 
                                   Lead_Lost_Reason__c, 
                                   Year_of_Establishment__c, 
                                   Key_Person__c, Other_Lost_Reason__c, 
                                   Address_ID__c, Sales_Turnover__c, GST_Number__c, Repeat_Calls_Frequency__c, LeadSource, 
                                   NumberOfEmployees, Other_Lead_Source__c, MobilePhone, Company, Email 
                                   FROM Lead WHERE Email IN :emailId];

            List<Lead> leadsToUpdate = new List<Lead>();
            for (Lead lead : leadList) {

                system.debug('Lead Record is -> ' +lead);

                Boolean isChanged = false;
                Lead__c oldLead = oldLeadMap.get(lead.Email);
                Lead__c newLead = newLeadMap.get(lead.Email);

                system.debug('oldLead Record of Custom Lead is -> ' +oldLead);
                system.debug('newLead Record of Custom Lead is -> ' +newLead);

                //All the comparsions is made on Custom Lead to Update the Standard Lead

                if (oldLead.Salutation__c != newLead.Salutation__c) {
                    lead.Salutation = newLead.Salutation__c;
                    isChanged = true;
                }
                if (oldLead.Name != newLead.Name) {
                    lead.FirstName = newLead.Name;
                    isChanged = true;
                }
                if (oldLead.Middle_Name__c != newLead.Middle_Name__c) {
                    lead.MiddleName = newLead.Middle_Name__c;
                    isChanged = true;
                }
                if (oldLead.Last_Name__c != newLead.Last_Name__c) {
                    lead.LastName = newLead.Last_Name__c;
                    isChanged = true;
                }
                if (oldLead.Industry__c != newLead.Industry__c) {
                    lead.Industry__c = newLead.Industry__c;
                    isChanged = true;
                } 
                if (oldLead.Website__c != newLead.Website__c) {
                    lead.Website = newLead.Website__c;
                    isChanged = true;
                }
                if (oldLead.Lead_Status__c != newLead.Lead_Status__c) {
                    lead.Status = newLead.Lead_Status__c;
                    isChanged = true;
                }
                if (oldLead.Territory__c != newLead.Territory__c) {
                    lead.Territory__c = newLead.Territory__c;
                    isChanged = true;
                }
                if (oldLead.Lead_Type__c != newLead.Lead_Type__c) {
                    lead.Lead_Type__c = newLead.Lead_Type__c;
                    isChanged = true;
                }
                if (oldLead.PAN_Card_Number__c != newLead.PAN_Card_Number__c) {
                    lead.PAN_Card_Number__c = newLead.PAN_Card_Number__c;
                    isChanged = true;
                }
                if (oldLead.GST_Type__c != newLead.GST_Type__c) {
                    lead.GST_Type__c = newLead.GST_Type__c;
                    isChanged = true;
                }
                if (oldLead.GSTIN__c != newLead.GSTIN__c) {
                    lead.GSTIN__c = newLead.GSTIN__c;
                    isChanged = true;
                }
                if (oldLead.CIN_Number__c != newLead.CIN_Number__c) {
                    lead.CIN_Number__c = newLead.CIN_Number__c;
                    isChanged = true;
                }
                if (oldLead.Lead_Lost_Reason__c != newLead.Lead_Lost_Reason__c) {
                    lead.Lead_Lost_Reason__c = newLead.Lead_Lost_Reason__c;
                    isChanged = true;
                }
              	if (oldLead.Year_of_Establishment__c != newLead.Year_of_Establishment__c) {
                    lead.Year_of_Establishment__c = newLead.Year_of_Establishment__c;
                    isChanged = true;
                }
                if (oldLead.Key_Person__c != newLead.Key_Person__c) {
                    lead.Key_Person__c = newLead.Key_Person__c;
                    isChanged = true;
                }
                if (oldLead.Other_Lost_Reason__c != newLead.Other_Lost_Reason__c) {
                    lead.Other_Lost_Reason__c = newLead.Other_Lost_Reason__c;
                    isChanged = true;
                }
                if (oldLead.Address_ID__c != newLead.Address_ID__c) {
                    lead.Address_ID__c = newLead.Address_ID__c;
                    isChanged = true;
                }
                if (oldLead.Sales_Turnover__c != newLead.Sales_Turnover__c) {
                    lead.Sales_Turnover__c = newLead.Sales_Turnover__c;
                    isChanged = true;
                }
                if (oldLead.GST_Number__c != newLead.GST_Number__c) {
                    lead.GST_Number__c = newLead.GST_Number__c;
                    isChanged = true;
                }
                if (oldLead.Repeat_Calls_Allowed__c != newLead.Repeat_Calls_Allowed__c) {
                    lead.Repeat_Calls_Allowed__c = newLead.Repeat_Calls_Allowed__c;
                    isChanged = true;
                }
                if (oldLead.Repeat_Calls_Frequency__c != newLead.Repeat_Calls_Frequency__c) {
                    lead.Repeat_Calls_Frequency__c = newLead.Repeat_Calls_Frequency__c;
                    isChanged = true;
                }
                if (oldLead.Other_Repeat_Calls_Frequency__c != newLead.Other_Repeat_Calls_Frequency__c) {
                    lead.Other_Repeat_Calls_Frequency__c = newLead.Other_Repeat_Calls_Frequency__c;
                    isChanged = true;
                }
                if (oldLead.Lead_Source__c != newLead.Lead_Source__c) {
                    lead.LeadSource = newLead.Lead_Source__c;
                    isChanged = true;
                }
                if (oldLead.Other_Lead_Source__c != newLead.Other_Lead_Source__c) {
                    lead.Other_Lead_Source__c = newLead.Other_Lead_Source__c;
                    isChanged = true;
                }
                if (oldLead.Rating__c != newLead.Rating__c) {
                    lead.Rating = newLead.Rating__c;
                    isChanged = true;
                }
                if (oldLead.Landline_No__c != newLead.Landline_No__c) {
                    lead.Phone = newLead.Landline_No__c;
                    isChanged = true;
                }
                if (oldLead.Mobile_Number__c != newLead.Mobile_Number__c) {
                    lead.MobilePhone = newLead.Mobile_Number__c;
                    isChanged = true;
                }
                if (oldLead.Email__c != newLead.Email__c) {
                    lead.Email = newLead.Email__c;
                    isChanged = true;
                }
                if (oldLead.Company_Name__c != newLead.Company_Name__c) {
                    lead.Company = newLead.Company_Name__c;
                    isChanged = true;
                }

                //18-06-2024

                if (oldLead.Line_1_Block__c != newLead.Line_1_Block__c) {
                    lead.Line_1_Block__c = newLead.Line_1_Block__c;
                    isChanged = true;
                }

                if (oldLead.Line_2_Building_Floor_Room__c != newLead.Line_2_Building_Floor_Room__c) {
                    lead.Line_2_Building_Floor_Room__c = newLead.Line_2_Building_Floor_Room__c;
                    isChanged = true;
                }

                if (oldLead.Line_3_Street_PO_Box__c != newLead.Line_3_Street_PO_Box__c) {
                    lead.Line_3_Street_PO_Box__c = newLead.Line_3_Street_PO_Box__c;
                    isChanged = true;
                }

                if (oldLead.City__c != newLead.City__c) {
                    lead.City__c = newLead.City__c;
                    isChanged = true;
                }

                if (oldLead.Area__c != newLead.Area__c) {
                    lead.Area__c = newLead.Area__c;
                    isChanged = true;
                }


                if (oldLead.District__c != newLead.District__c) {
                    lead.District__c = newLead.District__c;
                    isChanged = true;
                }

                if (oldLead.Zip_Code__c != newLead.Zip_Code__c) {
                    lead.Zip_Code__c = newLead.Zip_Code__c;
                    isChanged = true;
                }

                if (oldLead.State__c != newLead.State__c) {
                    lead.State__c = newLead.State__c;
                    isChanged = true;
                }

                if (oldLead.Country__c != newLead.Country__c) {
                    lead.Country__c = newLead.Country__c;
                    isChanged = true;
                }

                if (oldLead.Title__c != newLead.Title__c) {
                    lead.Title = newLead.Title__c;
                    isChanged = true;
                }

                if (oldLead.Number_of_Employees__c != newLead.Number_of_Employees__c) {

                    if(newLead.Number_of_Employees__c !=null){
                        lead.NumberOfEmployees = newLead.Number_of_Employees__c.intValue();
                        isChanged = true;
                    }
                }

                if (isChanged) {
                    leadsToUpdate.add(lead);
                }
            }

            if (leadsToUpdate.size() > 0) {
                UPDATE leadsToUpdate;
            }
        }
   //process((List<Lead__c>)tp.newList);
	}
	
	private void process(List<Lead__c> listNewCustomLeads) {
		for(Lead__c lead : listNewCustomLeads) {
			Lead__c newCustomLead = new Lead__c();
			//newCustomLead.Id = lead.Id;
			//newCustomLead.Website__c = 'www.salesforce.com';
			//sObjectsToUpdate.put(newCustomLead.Id, newCustomLead);
		}
	}
	
	public override void inProgressEntry(TriggerParameters tp) {
		
	}
	
	public override void updateObjects() {
		// for demonstration purposes, don't do anything here...
	}
}