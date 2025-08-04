public  class NotifyAreaManagerController {

    public string recordID;
    public Id LeadId {get;set;}

    public NotifyAreaManagerController() {
        LeadId = ApexPages.currentPage().getparameters().get('id');
    }

    public void sendEmail(){

        system.debug('LeadId --> ' +LeadId);

        Lead__c LeadData = [SELECT Id, Name, Last_Name__c, Industry__c, Company_Name__c, Territory__c, 
                            Mobile_Number__c, Email__c, Lead_Status__c, Lead_Type__c, Owner.Name, Lead_Source__c,
                            Website__c FROM Lead__c WHERE Id = :LeadId];

        String recordId = LeadData.Id; // Replace with your actual record Id
        String instanceUrl = System.Url.getOrgDomainUrl().toExternalForm();
        String recordUrl = instanceUrl + '/lightning/r/Lead__c/' + recordId + '/view';
        System.debug('Record URL: ' + recordUrl);

        Id loggedInUserId = UserInfo.getUserId();
        System.debug('Logged-in User ID: ' + loggedInUserId);

        List<User> userList = [SELECT Id, Name, Email, ManagerId FROM User WHERE Id = :loggedInUserId AND ManagerId != null];

        if(userList.size()>0){

            user Manager = [SELECT Id, Name, Email FROM user WHERE ID =:userList[0].ManagerId];

            try {

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> ToAddresses = new List<String>();
                List<String> ccAddresses = new List<String>();
                ToAddresses.add(Manager.Email);
                email.setToAddresses(ToAddresses);
                email.setSubject('Lead needs your immediate attention !!');
                email.setHtmlBody(
                    '<html>' +
                    '<body>' +
                    '<div>' +
                    'Dear ' + Manager.Name +',<br/><br/>Following lead needs your immediate attention. ' +
                    '<br/><br/>Lead First Name : ' + LeadData.Name +
                    '<br/><br/>Lead Last Name : ' + LeadData.Last_Name__c +
                    '<br/>Company Name : ' + LeadData.Company_Name__c +
                    '<br/>Mobile : ' + LeadData.Mobile_Number__c +
                    '<br/>Email : ' + LeadData.Email__c +
                    '<br/>Lead Source : ' + LeadData.Lead_Source__c +
                    '<br/>Lead URL : ' + recordUrl +
                    '<br/><br/>Regards,' +
                    '<br/>' + userList[0].Name +
                    '</div>' +
                    '</body>' +
                    '</html>'
                );
    
                Messaging.SendEmailResult[] r = Messaging.SendEmail(new Messaging.SingleEmailMessage[] {
                    email
                });
    
                EmailMessage em = new EmailMessage();
                em.Subject = 'Lead needs your immediate attention !!';
                em.RelatedToId = LeadData.Id;
                if(test.isRunningTest()){
                    em.ToAddress = 'test@gmail.com';
                }else{
                em.ToAddress = 'huzaifa@finessedirect.com';
                }
                em.MessageDate = system.today();
                em.Incoming = false;
                em.Status = '3';
                insert em;

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'The Manager has been Notified'));
                //return new PageReference('/'+cs.Id);
            }  
            catch(Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Failed to Update the Manager'));
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
                //return null;
            }
        
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No Manager is assigned to the User'));
        }

    }

    public pageReference getSomething() {
        // Do your crazy stuff
        // Oppoid= ApexPages.currentPage().getParameters().get('id');
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
    }
   
}