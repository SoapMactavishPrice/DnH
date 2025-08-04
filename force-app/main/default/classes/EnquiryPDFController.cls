public class EnquiryPDFController {
    public id enqId {
        get;
        set;
    }
    public Enquiry__c enqData {
        get;
        set;
    }
    public boolean isValid {
        get;
        set;
    }
    public Boolean formSubmitted {
        get;
        set;
    }
    public string emailId {
        get;
        set;
    }
    public string CC_Addresses {
        get;
        set;
    }
    public String subject {
        get;
        set;
    }
    public boolean showSaveOrder {
        get;
        set;
    }
    public String body {
        get;
        set;
    }
    public string Enquirytype {
        get;
        set;
    }
    public String pdfUrl {
        get;
        set;
    }
    public EnquirydataWrapper enquiryRecord {
        get;
        set;
    }
    public string Salestype {
        get;
        set;
    }
    public Boolean createNew {
        get;
        set;
    }
    public PageReference pdf {
        get;
        set;
    }
    public string pdfName {
        get;
        set;
    }

    public EnquiryPDFController() {
        enqId = ApexPages.currentPage().getparameters().get('id');
        system.debug('enqId' + enqId);

        // enqId = 'a03F300000BoHwTIAV'; 

        enquiryRecord = new EnquirydataWrapper();
        showSaveOrder = true;
        enqData = [SELECT Id, Enquiry_Type__c, Name, Contact__r.Email, End_Customer__c, End_Customer__r.Email_Id__c
            FROM Enquiry__c
            where ID =: enqId
        ];
        Salestype = enqData.Enquiry_Type__c;
        pdf = Page.EnquiryTaxInvoice;
        pdf.getParameters().put('enquiryId', enqId);
        pdfURL = '/apex/EnquiryTaxInvoice?enquiryId=' + enqId + '#toolbar=0';

        pdfName = enqData.Name;
        formSubmitted = false;
        isValid = true;
        createNew = true;

        subject = '';
        subject += 'Quotation';

        body = '';
        body += 'Dear Sir/Madam, <br/><br/>';
        body += 'Please find attached Quotation PDF.';
        if (string.isNotBlank(enqData.End_Customer__c)) {emailId = enqData.End_Customer__r.Email_Id__c;
            
        } else {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'Please Fill Email in Enquiry Contact.'));
            //isValid = false;
        }

    }

    public PageReference save() {
        try {
            if (String.isBlank(Salestype)) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Sales type must be selected.'));
                //return null;

            }

            String finalString = '%' + enqData.Name + '%';
            List < ContentDocument > contentDocs = [SELECT Id, title FROM ContentDocument WHERE title LIKE: finalString ORDER BY createdDate DESC LIMIT 1];
            String version = '0';

            if (contentDocs.size() > 0) {  version = contentDocs[0].title.substringAfterLast('_').substringBeforeLast('.');
               

            }

            if (!createNew) {  if (contentDocs.size() > 0) {   Database.delete(contentDocs, false);
                   
               

                }
            }

            formSubmitted = true;

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S';
            Integer newVersion = Integer.valueOf(version) + 1;
            contentVersion.PathOnClient = String.valueOf(enqData.Name + '_' + newVersion + '.pdf');
            contentVersion.Title = String.valueOf(enqData.Name + '_' + newVersion + '.pdf');
            contentVersion.isMajorVersion = false;

            if (Test.isRunningTest()) {
                contentVersion.versionData = Blob.toPdf('test');  } else {contentVersion.versionData = pdf.getContentAsPDF();
           
                
            }

            upsert contentVersion;

            contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id];

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
            contentDocumentLink.LinkedEntityId = enqData.Id;
            contentDocumentLink.ShareType = 'V';

            upsert contentDocumentLink;

            PageReference pageRef = new PageReference('/' + enqId);
            pageRef.setRedirect(true);
            return pageRef;
        } catch (DmlException e) {
            // Handle DML-specific errors and include line number
            String errorMessage = 'DML Error: ' + e.getMessage() + ' at line ' + e.getStackTraceString();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        } catch (QueryException e) {
            // Handle query errors and include line number
            String errorMessage = 'Query Error: ' + e.getMessage() + ' at line ' + e.getStackTraceString();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        } catch (Exception e) {
            // Handle all other exceptions and include line number
            String errorMessage = 'Unexpected Error: ' + e.getMessage() + ' at line ' + e.getStackTraceString();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }

        return null;
    }

    public PageReference saveAndSend() {

        // Check if Salestype is null
        if (String.isBlank(Salestype)) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Sales type must be selected.')); return null; 
            // Prevent further processing and stay on the same page
            // Add an error message to the page
            
        }

        if (emailId != '' && subject != '') {
            String finalString = '%' + enqData.Name + '%';
            List < ContentDocument > contentDocs = [select Id, title from ContentDocument where title like: finalString order by createdDate desc limit 1];
            String version = '0';
            if (contentDocs.size() > 0) version = contentDocs[0].title.substringAfterLast('_').subStringBeforelast('.');
                
            if (!createNew) {   if (contentDocs.size() > 0) Database.delete(contentDocs, false);
                    
              
            }
            formSubmitted = true;
            List < ContentDocumentLink > cdls = new List < ContentDocumentLink > ();
            if (enqId != null)
                cdls = [select id, ContentDocument.LatestPublishedVersionId from ContentDocumentLink where LinkedEntityId =: enqId];
            Set < String > LatestPublishedVersionIds = new Set < String > ();

            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S';
            Integer newVersion = Integer.valueOf(version) + 1;
            contentVersion.PathOnClient = String.valueOf(enqData.Name + '_' + newVersion + '.pdf');
            contentVersion.Title = String.valueOf(+enqData.Name + '_' + newVersion + '.pdf');
            contentVersion.isMajorVersion = false;
            if (Test.isRunningTest())
                ContentVersion.versionData = Blob.toPdf('test'); else  ContentVersion.versionData = pdf.getContentAsPDF();
            
                
            upsert contentVersion;

            contentVersion = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, Title, versionData
                FROM ContentVersion WHERE Id =: contentVersion.Id
            ];
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
            contentDocumentLink.LinkedEntityId = enqId;
            contentDocumentLink.ShareType = 'V';
            upsert contentDocumentLink;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            System.debug(emailId);
            email.setToAddresses(new String[] {
                emailId
            });
            if (String.isNotBlank(CC_Addresses)) { CC_Addresses = CC_Addresses.replaceAll('[;,:]', ',');   Set < String > CCEmails = new Set < String > ();  for (String str: CC_Addresses.split(',')) { if (String.isNotBlank(str)) CCEmails.add(str);
                        
                    
                
               
               
                } email.setCcAddresses(new List < String > (CCEmails));  System.debug(CC_Addresses);  }
               

                
           

            LatestPublishedVersionIds.add(contentVersion.ContentDocument.LatestPublishedVersionId);

            if (LatestPublishedVersionIds.size() > 0) {
                List < String > LatestPublishedVersionIdList = new List < String > ();
                LatestPublishedVersionIdList.addAll(LatestPublishedVersionIds);
                email.setEntityAttachments(LatestPublishedVersionIdList);
            }

            email.setSubject(subject);
            email.setHtmlBody(body);

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                email  }); } else {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Email Id and subject are the mandatory fields, please verify'));  return null;
           

          
       
            
        }

        Pagereference pageRef = new PageReference('/' + enqId);
        pageRef.setRedirect(true);
        return pageRef;

    }

    public PageReference cancel() {
        Pagereference pageRef = new PageReference('/' + enqId);
        pageRef.setRedirect(true);
        formSubmitted = false;
        return pageRef;
    }

    class EnquirydataWrapper {

        //public string PINo {get;set;}

        //public string PIDate {get;set;}
        //public string DeliveryDate {get;set;}
        //public string BillingName {get;set;}
        //   public string Baddress {get;set;}
        public List < EnquiryItemWrapper > orderItems {
            get;
            set;
        }

        public EnquirydataWrapper() {
            orderItems = new List < EnquiryItemWrapper > ();
        }
    }

    class EnquiryItemWrapper {
        public string Name {
            get;
            set;
        }
        public string Line_Item_Id {
            get;
            set;
        }
        public string Part_No_c {
            get;
            set;
        }
        public string Goodsservices {
            get;
            set;
        }
        public string BPCat {
            get;
            set;
        }
        public string Product_Description {
            get;
            set;
        }
        public string HSNCODE {
            get;
            set;
        }
        public string MainApplication {
            get;
            set;
        }
        public Date CustomerExpectedDate {
            get;
            set;
        }
        public Decimal Quantity {
            get;
            set;
        }
        public Decimal Rate {
            get;
            set;
        }
        public Decimal CGSTRate {
            get;
            set;
        }
        public Decimal SGSTRate {
            get;
            set;
        }
        public Decimal Totalvalue {
            get;
            set;
        }
        public decimal TotalGst {
            get;
            set;
        }
        public Decimal TotalTaxableValue {
            get;
            set;
        }
        public Decimal CGSTAmount {
            get;
            set;
        }
        public Decimal SGSTAmount {
            get;
            set;
        }
        public integer UnitPrice {
            get;
            set;
        }
    }

}