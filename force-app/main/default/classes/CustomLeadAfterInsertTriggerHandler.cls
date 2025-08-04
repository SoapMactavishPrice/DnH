public class CustomLeadAfterInsertTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		system.debug('**We are Inside After Insert Lead__C Trigger**');

		List<Lead__c> customLeadList =(List<Lead__c>)tp.newList;
		List<Lead> LeadToInsert = new List<Lead>();

		for(Lead__c cusld : customLeadList){
			//To stop the Trigger from executing on loops
			if(cusld.IsCreatedFromStandardLead__c == false){
				Lead ld = new Lead();
				ld.FirstName = cusld.Name;
				ld.MiddleName = cusld.Middle_Name__c;
				ld.LastName  = cusld.Last_Name__c;
				ld.Salutation = cusld.Salutation__c;
				ld.Company = cusld.Company_Name__c;
				ld.Email = cusld.Email__c;
				ld.MobilePhone = cusld.Mobile_Number__c;
				ld.GSTIN__c = cusld.GSTIN__c;
				ld.Address_ID__c = cusld.Address_ID__c;
				ld.GST_Type__c = cusld.GST_Type__c;
				ld.Industry = cusld.Industry__c;
				ld.Key_Person__c = cusld.Key_Person__c;
				ld.Territory__c = cusld.Territory__c;
				ld.Lead_Type__c = cusld.Lead_Type__c;
				ld.Lead_Lost_Reason__c = cusld.Lead_Lost_Reason__c;
				ld.LeadSource = cusld.Lead_Source__c;
				ld.Repeat_Calls_Frequency__c = cusld.Repeat_Calls_Frequency__c;
				ld.Sales_Turnover__c = cusld.Sales_Turnover__c;
				ld.CIN_Number__c = cusld.CIN_Number__c;
				ld.Year_of_Establishment__c = cusld.Year_of_Establishment__c;
				ld.GST_Number__c = cusld.GST_Number__c;
				if(cusld.Number_of_Employees__c !=null){
					ld.NumberOfEmployees = cusld.Number_of_Employees__c.intValue();
				}
				ld.PAN_Card_Number__c = cusld.PAN_Card_Number__c;
				ld.Website = cusld.Website__c;
				ld.Status = cusld.Lead_Status__c;
				ld.Other_Lost_Reason__c = cusld.Other_Lost_Reason__c;            
				ld.Line_1_Block__c = cusld.Line_1_Block__c;
				ld.Line_2_Building_Floor_Room__c = cusld.Line_2_Building_Floor_Room__c;
				ld.Line_3_Street_PO_Box__c = cusld.Line_3_Street_PO_Box__c;
				ld.City__c = cusld.City__c;
				ld.Area__c = cusld.Area__c;
				ld.District__c = cusld.District__c;
				ld.Zip_Code__c = cusld.Zip_Code__c;
				ld.State__c = cusld.State__c;
				ld.Country__c = cusld.Country__c;
				ld.Repeat_Calls_Allowed__c = cusld.Repeat_Calls_Allowed__c;
				ld.Rating = cusld.Rating__c;
				ld.Other_Lead_Source__c = cusld.Other_Lead_Source__c;
				ld.Phone = cusld.Landline_No__c;
				ld.Title = cusld.Title__c;
				ld.IsCreatedFromCustomLead__c = true;
				LeadToInsert.add(ld);
			}
		}

		if(LeadToInsert.size()>0){
			INSERT LeadToInsert;
		}
	}
}