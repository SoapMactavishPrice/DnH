public with sharing class CustomLeadConvertController {

    @AuraEnabled
    public static Lead__c getLeadRecord(String recordId) {
        try {
            String allFields = UtilityCls.getAllFields('Lead__c')
                .get('Lead__c');
            String query =
                'SELECT ' +
                allFields +
                ', ' +
                'Owner.FirstName, Owner.LastName, City__r.Name ' +
                'FROM Lead__c WHERE Id =: recordId';
            return Database.query(query);
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List < Object > getAccRecTypes() {
        try {
            List < Object > accRecTypes = new List < Object > ();
            List < Schema.RecordTypeInfo > recordTypes = Account.SObjectType.getDescribe()
                .getRecordTypeInfos();
            for (Schema.RecordTypeInfo rt: recordTypes) {
                if (rt.isAvailable()) {
                    if (rt.getName() != 'Master') {
                        accRecTypes.add(
                            new Map < String, Object > {
                                'value' => rt.getRecordTypeId(),
                                'label' => rt.getName()
                            }
                        );
                    }
                }
            }
            return accRecTypes;
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    //added by NehaP for Enquiry Record Type
    @AuraEnabled(cacheable = true)
    public static List < RecordType > getEnquiryRecordTypes() {
        // Query for active Record Types for the Enquiry object
        return [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Enquiry__c'
            AND IsActive = true
        ];
    }

    /*
@AuraEnabled
public static List<Account> getAccountsByPinCode(String pinCode) {
try {
if (String.isBlank(pinCode)) {
throw new CustomException('Please provide pincode');
}

Set<Id> accIds = new Set<Id>();
for (Address_Information__c address : [
SELECT Id, Account__c
FROM Address_Information__c
WHERE
Address_Type__c = 'Billing'
AND ZipPostal_Code__c = :pinCode
]) {
accIds.add(address.Account__c);
}

return [
SELECT
Id,
Name,
City_Name__c,
Business_Unit__c,
Account_Division_Text__c,
Customer_Code__c,
Owner_Name__c
FROM Account
WHERE Id IN :accIds
];
} catch (Exception e) {
System.debug(e);
throw new AuraHandledException(e.getMessage());
}
}*/

    @AuraEnabled
    public static Map < String, String > convertLead(Lead__c leadRecord, String accName, Boolean isDC, String dealerName, String accRT, String existingAccId, Map < String, String > contactName, String existingContId, String enqName, String enqRT, Boolean enqChk, Boolean isAccountNew, Boolean isContactNew) {
        Savepoint sp = Database.setSavepoint();

        try {

            //RecursiveTriggerHandler.isLeadConvertContext = true;

            //Company_Master__c compMaster;
            //Division_Master__c divMaster;

            /*
            try {
            if (string.isNotBlank(leadRecord.Business_Unit__c)) {
            divMaster = [
            SELECT Id, Name, Company_Master__c, Company_Master__r.Name
            FROM Division_Master__c
            WHERE Name = :leadRecord.Business_Unit__c
            ];
            }
            compMaster = new Company_Master__c(
            Id = divMaster.Company_Master__c,
            Name = divMaster.Company_Master__r.Name
            );
            } catch (Exception e) {
            throw new CustomException('Division Master record not found, please check with administrator');
            }*/

            Account acc = new Account();
            if (isAccountNew == false && String.isNotBlank(existingAccId)) {
                acc.Id = existingAccId;
                System.debug('accountId>>' + acc.Id);
            } else {
                if (String.isNotBlank(accName)) {
                    acc.Name = accName;
                }
                if (isDC == false) {
                    acc.Dealer__c = dealerName;
                } else {
                    //throw new CustomException('Please enter Account Name');
                }

                if (String.isNotBlank(accRt)) {
                    //acc.RecordTypeId = accRT;
                } else {
                    //throw new CustomException('Please select Account Record Type');
                }

                //acc.Account_Company__c = compMaster.Id;
                //acc.Account_Division__c = divMaster.Id;
                //acc.Annual_Potential__c = leadRecord.Annual_Potential__c;
                //acc.Company_Email_ID__c = leadRecord.Email__c;
                //acc.Account_Type_New__c = 'New';
                //acc.Account_Profile__c = leadRecord.Company_Profile__c;
                //acc.Contact_No_Moblie__c = leadRecord.Mobile_Number__c;
                //acc.Currently_Buying_from__c = leadRecord.Currently_Buying_from__c;
                acc.NumberOfEmployees = Integer.valueOf(
                    leadRecord.Number_of_Employees__c
                );
                //acc.Fax = leadRecord.Fax_Number__c;
                //acc.Group_Name__c = leadRecord.Group_Name__c;
                //acc.Industry = leadRecord.Industry_Type__c;
                //acc.LinkedIn__c = leadRecord.LinkedIn__c;
                acc.Mobile_Number_1__c = leadRecord.Mobile_Number__c;
                // acc.Industry = leadRecord.Industry__c;
                acc.Industry__c = leadRecord.Industry__c;
                acc.Website = leadRecord.Website__c;
                acc.Email_Id__c = leadRecord.Email__c;
                acc.Other_Repeat_Calls_Frequency__c = leadRecord.Other_Repeat_Calls_Frequency__c;
                acc.Repeat_Calls_Frequency__c = leadRecord.Repeat_Calls_Frequency__c;
                acc.Repeat_Calls_Allowed__c = leadRecord.Repeat_Calls_Allowed__c;
                acc.Territory__c = leadRecord.Territory__c;
                acc.Pan_No__c = leadRecord.PAN_Card_Number__c;
                acc.Key_Person__c = leadRecord.Key_Person__c;
                acc.Sales_Turnover__c = leadRecord.Sales_Turnover__c;
                acc.Year_of_Establishment__c = leadRecord.Year_of_Establishment__c;
                acc.CIN_Number__c = leadRecord.CIN_Number__c;
                acc.GST_Type__c = leadRecord.GST_Type__c;
                acc.GST_Number__c = leadRecord.GST_Number__c;
                acc.AccountSource = leadRecord.Lead_Source__c;
                // acc.Dealer__c = leadRecord.Dealer__c;
                //acc.Other_Account_source__c = leadRecord.Other_Lead_source__c;

                //acc.Lead_Owner__c = leadRecord.Owner.FirstName + ' ' + leadRecord.Owner.LastName;
                //acc.Lead_Converted_By__c = System.UserInfo.getFirstName() + ' ' + System.UserInfo.getLastName();
                //acc.Lead_Converted_Date__c = System.today();

                //if (Schema.sObjectType.Account.getRecordTypeInfosById().get(accRT).getName().contains('Dealer')) {
                //acc.Agent_Company__c = compMaster.Id;

                //acc.Agent_Source__c = leadRecord.Lead_Source__c;
                //acc.Other_Agent_source__c = leadRecord.Other_Lead_source__c;
                //}

                INSERT acc;

                String curUsr = UserInfo.getUserId();
                User use = [SELECT Id, Name, Code__c, Reporting_Person__c, Reporting_Person_ID__c FROM User WHERE Id = :curUsr];
                
                Customer_Sales_Person_Mapping__c  cspm = new Customer_Sales_Person_Mapping__c ();
                cspm.Account__c = acc.Id;
                cspm.Customer_Name__c = acc.Name;
                cspm.Sales_Person__c = use.Id;
                cspm.Sales_Person_Code__c = use.Code__c;
                cspm.Sales_Person_Name__c = use.Name;
                cspm.Reporting_Person__c = use.Reporting_Person__c;
                cspm.Reporting_person_ID__c = use.Reporting_Person_ID__c;
                insert cspm;
                    

                List < Task > taskToInsert = new List < Task > ();
                List < Event > eventListToInsert = new List < Event > ();
                List < EmailMessage > emailsToInsert = new List < EmailMessage > ();
                List < ContentDocumentLink > newLinksToInsert = new List < ContentDocumentLink > ();

                List < Task > tasklist = [SELECT ActivityDate, Description, Id, IsHighPriority, Priority, Status, Subject, WhatId, WhoId, OwnerId, ReminderDateTime,
                    IsReminderSet FROM Task where WhatId =: leadRecord.Id
                ];

                system.debug('tasks>>>>>>' + tasklist);
                system.debug('tasks size>>>>>>' + tasklist.size());

                List < Event > eventlist = [SELECT ActivityDate, CreatedById, CreatedDate, Description, EndDate, EndDateTime, EventSubtype, Id, IsAllDayEvent, IsReminderSet,
                    Location, OwnerId, ReminderDateTime, StartDateTime, Subject, Type, WhatId, WhoId FROM Event where WhatId =: leadRecord.Id
                ];

                system.debug('events>>>>>>' + eventlist);
                system.debug('events size>>>>>>' + eventlist.size());

                system.debug('leadRecord.Id>>>>>>' + leadRecord.Id);
                List < ContentDocumentLink > ContentDocumentLinkList = [SELECT ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: leadRecord.Id];
                system.debug('ContentDocumentLinkList>>>>>>' + ContentDocumentLinkList);
                system.debug('ContentDocumentLinkList size>>>>>>' + ContentDocumentLinkList.size());

                //Copying Tasks
                for (Task ts: tasklist) {

                    Task ta = new Task();
                    ta.WhatId = acc.Id;
                    ta.Status = ts.Status;
                    ta.Subject = ts.Subject;
                    ta.ActivityDate = ts.ActivityDate;
                    ta.Description = ts.Description;
                    ta.WhoId = ts.WhoId;
                    ta.Priority = ts.Priority;
                    ta.OwnerId = ts.OwnerId;
                    ta.ReminderDateTime = ts.ReminderDateTime;
                    ta.IsReminderSet = ts.IsReminderSet;

                    taskToInsert.add(ta);
                }

                if (taskToInsert.size() > 0)
                    INSERT taskToInsert;

                //Copying Emails (if you have email messages to copy)
                for (EmailMessage em: [SELECT Id, Subject, TextBody, FromAddress, ToAddress, CreatedDate FROM EmailMessage WHERE RelatedToId =: leadRecord.Id]) {
                    system.debug('email.Id -> ' + em.Id);
                    EmailMessage newEmail = new EmailMessage(
                        Subject = em.Subject,
                        TextBody = em.TextBody,
                        FromAddress = em.FromAddress,
                        ToAddress = em.ToAddress,
                        //CreatedDate = em.CreatedDate,
                        RelatedToId = acc.Id // Assuming you have a field to map to the standard Lead ID
                    );
                    emailsToInsert.add(newEmail);
                }

                if (!emailsToInsert.isEmpty()) {
                    system.debug('emailsToInsert Size --> ' + emailsToInsert.size());
                    INSERT emailsToInsert;
                }

                //Copying the Notes and Files
                for (ContentDocumentLink cdlink: ContentDocumentLinkList) {

                    ContentDocumentLink newLink = new ContentDocumentLink();
                    newLink.ContentDocumentId = cdlink.ContentDocumentId;
                    newLink.LinkedEntityId = acc.Id;
                    newLink.ShareType = 'I'; // 'I' for Inferred permissions, you can set 'V' for Viewer or 'C' for Collaborator
                    newLink.Visibility = 'AllUsers'; // Adjust the visibility as needed
                    newLinksToInsert.add(newLink);
                }

                if (!newLinksToInsert.isEmpty()) {
                    system.debug('newLinksToInsert Size --> ' + newLinksToInsert.size());
                    INSERT newLinksToInsert;
                }

                //Copying the Event
                set < Id > eventId = new set < Id > ();
                Map < String, Id > eventMap = new Map < String, Id > ();

                for (Event ev: eventlist) {

                    Event evt = new Event();
                    evt.WhatId = acc.Id;
                    evt.Subject = ev.Subject;
                    evt.ActivityDate = ev.ActivityDate;
                    evt.Description = ev.Description;
                    evt.WhoId = ev.WhoId;
                    evt.OwnerId = ev.OwnerId;
                    evt.ReminderDateTime = ev.ReminderDateTime;
                    evt.IsReminderSet = ev.IsReminderSet;
                    //evt.EndDate=ev.EndDate;
                    evt.EndDateTime = ev.EndDateTime;
                    evt.EventSubtype = ev.EventSubtype;
                    evt.IsAllDayEvent = ev.IsAllDayEvent;
                    evt.Location = ev.Location;
                    evt.StartDateTime = ev.StartDateTime;
                    evt.Type = ev.Type;

                    eventListToInsert.add(evt);
                    eventId.add(ev.Id);
                    eventMap.put(ev.Subject, ev.Id);
                }

                if (eventListToInsert.size() > 0)
                    INSERT eventListToInsert;

                system.debug('eventId' + eventId);
                //Extracting Files and Notes from old Events
                Map < Id, List < ContentDocumentLink >> varMap = new Map < Id, List < ContentDocumentLink >> ();
                if (eventId.size() > 0) {
                    List < ContentDocumentLink > ContentDocumentLinkList2 = [SELECT ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: eventId];

                    if (ContentDocumentLinkList2.size() > 0) {
                        for (ContentDocumentLink cdlink: ContentDocumentLinkList2) {
                            if (varMap.containsKey(cdlink.LinkedEntityId)) {
                                varMap.get(cdlink.LinkedEntityId).add(cdlink);
                            } else {
                                varMap.put(cdlink.LinkedEntityId, new list < ContentDocumentLink > {
                                    cdlink
                                });
                            }

                        }
                    }
                }

                List < ContentDocumentLink > newLinks = new List < ContentDocumentLink > ();
                if (!varMap.isEmpty()) {
                    for (Event ev: eventListToInsert) {
                        Id eventParentId = eventMap.get(ev.Subject);

                        List < ContentDocumentLink > currentList;
                        if (varMap.containsKey(eventParentId)) {
                            currentList = varMap.get(eventParentId);
                        } else {
                            continue;
                        }

                        for (ContentDocumentLink cdlink: currentList) {

                            ContentDocumentLink newLink = new ContentDocumentLink();
                            newLink.ContentDocumentId = cdlink.ContentDocumentId;
                            newLink.LinkedEntityId = ev.Id;
                            newLink.ShareType = 'I'; // 'I' for Inferred permissions, you can set 'V' for Viewer or 'C' for Collaborator
                            newLink.Visibility = 'AllUsers'; // Adjust the visibility as needed
                            newLinks.add(newLink);
                        }
                    }
                }

                if (!newLinks.isEmpty()) {
                    INSERT newLinks;
                    System.debug('Files under Event has been successfully copied to the new parent Account object.');
                }

                //Extracting the Attachments from old Events
                List < Attachment > originalAttachments2 = [SELECT Name, Body, ContentType, Description, IsPrivate, ParentId FROM Attachment
                    WHERE ParentId IN: eventId
                ];
                Map < Id, List < Attachment >> varMap2 = new Map < Id, List < Attachment >> ();

                if (originalAttachments2.size() > 0) {
                    for (Attachment attach: originalAttachments2) {
                        if (varMap2.containsKey(attach.ParentId)) {
                            varMap2.get(attach.ParentId).add(attach);
                        } else {
                            varMap2.put(attach.ParentId, new list < Attachment > {
                                attach
                            });
                        }
                    }
                }

                List < Attachment > newAttachmentList = new List < Attachment > ();
                if (!varMap2.isEmpty()) {
                    for (Event ev: eventListToInsert) {
                        Id eventParentId = eventMap.get(ev.Subject);

                        List < Attachment > currentList;
                        if (varMap2.containsKey(eventParentId)) {
                            currentList = varMap2.get(eventParentId);
                        } else {
                            continue;
                        }

                        for (Attachment attach: currentList) {

                            Attachment newAttach = new Attachment();
                            newAttach.Name = attach.Name;
                            newAttach.Body = attach.Body;
                            newAttach.ContentType = attach.ContentType;
                            newAttach.Description = attach.Description;
                            newAttach.IsPrivate = attach.IsPrivate;
                            newAttach.ParentId = ev.Id;
                            newAttachmentList.add(newAttach);
                        }
                    }
                }

                if (!newAttachmentList.isEmpty()) {
                    INSERT newAttachmentList;
                    System.debug('Attachments under Event has been successfully copied to the new parent Account object.');
                }

                //Address Information creation
                Address_Information__c addInf = new Address_Information__c();
                if (leadRecord.City__r.Name != null) {
                    addInf.Name = 'Bill To - ' + leadRecord.City__r.Name;
                } else {
                    addInf.Name = 'Bill To';
                }
                addInf.Account__c = acc.Id;
                addInf.Line_1_Block__c = leadRecord.Line_1_Block__c;
                addInf.Line_2_Building_Floor_Room__c = leadRecord.Line_2_Building_Floor_Room__c;
                addInf.Line_3_Street_PO_Box__c = leadRecord.Line_3_Street_PO_Box__c;
                addInf.City__c = leadRecord.City__c;
                addInf.Zip_Code__c = leadRecord.Zip_Code__c;
                addInf.State__c = leadRecord.State__c;
                addInf.Country__c = leadRecord.Country__c;
                addInf.Area__c = leadRecord.Area__c;
                addInf.District__c = leadRecord.District__c;
                INSERT addInf;
            }

            List < Contact > contList = new List < Contact > ();

            Contact existingContact;
            if (String.isNotBlank(existingContId)) {
                existingContact = [
                    SELECT Id, Name, Salutation, FirstName, MiddleName, LastName, Title, Fax, //Landline_Number__c, Anniversary_Date__c, Zoom_ID__c, LinkedIn__c, Twitter__c, Website__c,
                    MobilePhone, Email, BirthDate, phone
                    FROM Contact
                    WHERE Id =: existingContId
                ];
            }

            Contact cont = new Contact();
            if (isContactNew == false && String.isNotBlank(existingContId)) {
                cont.Id = existingContId;
            }
            cont.AccountId = acc.Id;
            if (existingContact != null) {

                cont.Salutation = String.isBlank(existingContact.Salutation) ? contactName.get('Salutation') : existingContact.Salutation;
                cont.FirstName = String.isBlank(existingContact.FirstName) ? contactName.get('FirstName') : existingContact.FirstName;
                cont.MiddleName = String.isBlank(existingContact.MiddleName) ? contactName.get('MiddleName') : existingContact.MiddleName;
                cont.LastName = String.isBlank(existingContact.LastName) ? contactName.get('LastName') : existingContact.LastName;
                //cont.Company_Name__c = String.isBlank(existingContact.Company_Name__c) ? leadRecord.Company_Name__c : existingContact.Company_Name__c;
                cont.Title = String.isBlank(existingContact.Title) ? leadRecord.Title__c : existingContact.Title;
                //cont.Role__c = String.isBlank(existingContact.Role__c) ? leadRecord.Role__c : existingContact.Role__c;
                //cont.Fax = String.isBlank(existingContact.Fax) ? leadRecord.Fax_Number__c : existingContact.Fax;
                cont.phone = String.isBlank(existingContact.phone) ? leadRecord.Landline_No__c : existingContact.phone;
                cont.MobilePhone = String.isBlank(existingContact.MobilePhone) ? leadRecord.Mobile_Number__c : existingContact.MobilePhone;
                cont.Email = String.isBlank(existingContact.Email) ? leadRecord.Email__c : existingContact.Email;
                //cont.Website__c = String.isBlank(existingContact.Website__c) ? leadRecord.Website__c : existingContact.Website__c;
                //cont.BirthDate = existingContact.BirthDate == null ? leadRecord.Date_Of_Birth__c : existingContact.BirthDate;
                //cont.Anniversary_Date__c = existingContact.Anniversary_Date__c == null ? leadRecord.Anniversary_Date__c : existingContact.Anniversary_Date__c;
                //cont.Zoom_ID__c = String.isBlank(existingContact.Zoom_ID__c) ? leadRecord.Zoom_ID__c : existingContact.Zoom_ID__c;
                //cont.LinkedIn__c = String.isBlank(existingContact.LinkedIn__c) ? leadRecord.LinkedIn__c : existingContact.LinkedIn__c;
                //cont.Twitter__c = String.isBlank(existingContact.Twitter__c) ? leadRecord.Twitter__c : existingContact.Twitter__c;
            } else {
                cont.Salutation = contactName.get('Salutation');
                cont.FirstName = contactName.get('FirstName');
                cont.MiddleName = contactName.get('MiddleName');
                cont.LastName = contactName.get('LastName');
                //cont.Company_Name__c = leadRecord.Company_Name__c;
                cont.Title = leadRecord.Title__c;
                //cont.Role__c = leadRecord.Role__c;
                //cont.Fax = leadRecord.Fax_Number__c;
                cont.phone = leadRecord.Landline_No__c;
                cont.MobilePhone = leadRecord.Mobile_Number__c;
                cont.Email = leadRecord.Email__c;
                //cont.Website__c = leadRecord.Website__c;
                //cont.Zoom_ID__c = leadRecord.Zoom_ID__c;
                //cont.LinkedIn__c = leadRecord.LinkedIn__c;
                //cont.Twitter__c = leadRecord.Twitter__c;
            }

            if (String.isBlank(cont.LastName)) {
                //throw new CustomException('Please enter Contact Last Name');
            }

            contList.add(cont);

            /*
            if (leadRecord.Role__c != 'Decision Maker') {
            if (String.isNotBlank(leadRecord.Decision_Maker_Name__c)) {
            Contact decMaker = new Contact();
            decMaker.AccountId = acc.Id;
            decMaker.LastName = leadRecord.Decision_Maker_Name__c;
            decMaker.MobilePhone = leadRecord.Decision_Maker_Phone__c;
            decMaker.Title = leadRecord.Decision_Maker_Designation__c;
            decMaker.email = leadRecord.Decision_Maker_Email__c;
            contList.add(decMaker);
            }
            }
            if (leadRecord.Role__c != 'Gate Keeper') {
            if (String.isNotBlank(leadRecord.Gate_Keeper_Name__c)) {
            Contact gateKeeper = new Contact();
            gateKeeper.AccountId = acc.Id;
            gateKeeper.LastName = leadRecord.Gate_Keeper_Name__c;
            gateKeeper.MobilePhone = leadRecord.Gate_Keeper_Phone__c;
            gateKeeper.Title = leadRecord.Gate_Keeper_Designation__c;
            gateKeeper.email = leadRecord.Gate_Keeper_Email__c;
            contList.add(gateKeeper);
            }
            }
            if (leadRecord.Role__c != 'Influencer') {
            if (String.isNotBlank(leadRecord.Influencer_Name__c)) {
            Contact inflCont = new Contact();
            inflCont.AccountId = acc.Id;
            inflCont.LastName = leadRecord.Influencer_Name__c;
            inflCont.MobilePhone = leadRecord.Influencer_Phone__c;
            inflCont.Title = leadRecord.Influencer_Designation__c;
            inflCont.email = leadRecord.Influencer_Email__c;
            contList.add(inflCont);
            }
            }*/

            upsert contList;
            string objectname = 'Techno Commercial Offer';
            List < Code_Master__c > codem = [SELECT Id, Name, Object__c, Display_Label__c, Current_Sequence__c, Starting_Sequence__c,
                Backend_Current_Sequence__c, For_Display_Sequence__c FROM Code_Master__c
                WHERE Object__c =: objectname AND Is_Active__c = true
                LIMIT 1
            ];

            String Documentname = '';

            system.debug('enq Documentname>>>>' + Documentname);
            Enquiry__c enq = new Enquiry__c();
            if (codem.size() > 0) {
                codem[0].Current_Sequence__c += 1;
                Documentname = codem[0].Display_Label__c + '/' + String.valueOf(codem[0].For_Display_Sequence__c);
                enq.Enquiry_Name__c = 'SF-'+Documentname;
            } else {
                
                enq.Enquiry_Name__c = enqName;
            }
            enq.Contact__c = contList[0].Id;
            enq.Account__c = acc.Dealer__c;
            system.debug(' enq.Account__c>>>>' + enq.Account__c);
            enq.End_Customer_Name__c = enqName;
            enq.End_Customer__c = acc.id;
            system.debug(' enq.Account__c>>>>' + enq.Account__c);

            enq.Dealer__c = acc.Dealer__c;
            if (String.isNotBlank(enqRt)) {
                enq.RecordTypeId = enqRt;
            } else {
                //throw new CustomException('Please select Account Record Type');
            }
            //opp.Kind_Attn__c = cont.Id;
            if (!enqChk) {
                system.debug('enq>>>>' + enq);
                insert enq;
            }

            String rtName = '';
            //rtName = Schema.SObjectType.Lead__c.getRecordTypeInfosById().get(leadRecord.RecordTypeId).getName();
            //rtName = rtName.replace('Lead', 'Read Only Lead');
            Lead__c ld = new Lead__c();
            //ld.Id = leadRecord.Id;
            //ld.RecordTypeId = Schema.SObjectType.Lead__c.getRecordTypeInfosByName().get('Read Only Lead').getRecordTypeId();
            //ld.isConverted__c = true;
            //ld.Converted_Account__c = acc.Id;
            //ld.Converted_Contact__c = cont.Id;
            //ld.Converted_Opportunity__c = opp.Id;
            //update ld;

            /*
            List<Task> taskList = [
                SELECT Id
                FROM Task
                WHERE WhatId = :leadRecord.Id
            ];
            for (Task ts : taskList) {
                ts.whatId = acc.Id;
                ts.whoId = cont.Id;
                //ts.Lead_Dont_populate_manually__c = leadRecord.Id;
            }
            update taskList;
            
            List<Event> eventList = [
                SELECT Id
                FROM Event
                WHERE WhatId = :leadRecord.Id
            ];
            for (Event ev : eventList) {
                ev.whatId = acc.Id;
                ev.WhoId = cont.Id;
                //ev.Lead_Dont_populate_manually__c = leadRecord.Id;
            }
            update eventList;*/

            /*
            List<Address_Information__c> addressList = [
            SELECT Id
            FROM Address_Information__c
            WHERE Lead__c = :leadRecord.Id
            ];
            for (Address_Information__c adress : addressList) {
            adress.Account__c = acc.Id;
            }
            update addressList;
            
            List<KYC__c> kycList = [
            SELECT Id
            FROM KYC__c
            WHERE Lead__c = :leadRecord.Id
            ];
            for (KYC__c kyc : kycList) {
            kyc.Account__c = acc.Id;
            }
            update kycList;
            
            List<Market_Intelligence__c> marketList = [
            SELECT Id
            FROM Market_Intelligence__c
            WHERE Lead__c = :leadRecord.Id
            ];
            for (Market_Intelligence__c mark : marketList) {
            mark.Account__c = acc.Id;
            }
            update marketList;*/

            //Final Update of the LeadRecord
            leadRecord.Is_Converted__c = true;
            UPDATE leadRecord;

            Map < String, String > finalMap = new Map < String, String > ();
            finalMap.put('accountId', acc.Id);
            finalMap.put('contactId', cont.Id);
            if (!enqChk) {
                finalMap.put('EnquiryId', enq.Id);
            }

            return finalMap;
        } catch (DmlException e) {
            Database.rollback(sp);

            System.debug(e);
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            String msg;
            if (e.getNumDml() > 0) {
                msg = e.getDmlMessage(0);
            } else {
                msg = e.getMessage();
            }
            System.debug(msg);
            throw new AuraHandledException(msg);
        } catch (Exception e) {
            Database.rollback(sp);

            System.debug(e);
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

}