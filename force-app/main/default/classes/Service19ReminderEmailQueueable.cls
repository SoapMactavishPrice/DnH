public class Service19ReminderEmailQueueable implements Queueable, Database.AllowsCallouts {
    
    private List<User> userList;
    private Integer index;
    // Static flag to stop chaining in tests
    public static Boolean stopChainingInTest = false;
    
    public Service19ReminderEmailQueueable(List<User> userList, Integer index){
        this.index = index;
        this.userList = userList;
    }
    
    public void execute(QueueableContext context) {
        if (index < this.userList.size()) {
            User record = this.userList[index];
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            List<Customer_Complaint__c> ccList = new List<Customer_Complaint__c>();
            DateTime tenDaysAgo = System.now().addDays(-10);
            
            ccList = [
                SELECT Id, Name, TSD_Remarks__c, IsSubmitted__c, Status__c, Submitted_By__c, Close_NAV__c, Close_TSD__c,
                Submitted_Date__c, Inserted_By__c, Updated_By__c, Is_Process__c, Updated_On__c, Field_Engineer_Name__c,
                Field_Engineer_Name__r.Email, Area_Manager__c, Area_Manager__r.Email, Invoice_No__c, InvoiceDate__c,
                Account__r.Name, End_Customer_Name__c, ItemNo__c, Size_mm__c, Batch_No__c, Batch_Quantity__c, Complaint_Quantity__c,
                Area_Manager__r.Name, CreatedBy.Name
                FROM Customer_Complaint__c
                WHERE Status__c = 'Closed By TSD User'
                AND Updated_On__c < :tenDaysAgo
                AND Close_NAV__c = false
                AND Close_TSD__c = false
                AND CreatedById = :record.Id
            ];
            
            System.debug('COMAPLINT REC:>> ' +ccList.size()+' || ' +ccList);
            
            if (ccList.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String recData = '';
                for (Customer_Complaint__c v : ccList) {
                    List<Item_Master__c> im = [SELECT Id, Item_Description__c FROM Item_Master__c WHERE Item_Number__c = :v.ItemNo__c];
                    String itemDesc = im.size()>0 ? im[0].Item_Description__c : '';
                    recData +=
                        '<tr>' +
                        '<td>'+v.Name+'</td>' +
                        '<td>'+v.Submitted_Date__c+'</td>' +
                        '<td>'+v.Invoice_No__c+'</td>' +
                        '<td>'+v.InvoiceDate__c+'</td>' +
                        '<td>'+v.Account__r.Name+'</td>' +
                        '<td>'+v.End_Customer_Name__c+'</td>' +
                        '<td>'+v.ItemNo__c+'</td>' +
                        '<td>'+itemDesc+'</td>' +
                        '<td>'+v.Size_mm__c+'</td>' +
                        '<td>'+v.Batch_No__c+'</td>' +
                        '<td>'+v.Batch_Quantity__c+'</td>' +
                        '<td>'+v.Complaint_Quantity__c+'</td>' +
                        '<td>'+v.TSD_Remarks__c+'</td>' +
                        '<td> </td>' +
                        '<td> </td>' +
                        '</tr>';
                }
                
                String sHelloName = ccList[0].CreatedBy.Name;
                String emailBody =
                    '<html>' +
                    '<head>' +
                    '<style>' +
                    'table { width: 100%; border-collapse: collapse; }' +
                    'th, td { border: 1px solid black; padding: 8px; text-align: left; }' +
                    'th { background-color: #f2f2f2; font-weight: bold; }' +
                    'td { font-size: 14px; }' +
                    '</style>' +
                    '</head>' +
                    '<body>' +
                    '<p>Dear <b>'+sHelloName+',</b></p>' +
                    
                    '<p>Following Complaint/Service19 has been closed by the TSD Team, please login to the portal and check it. ' +
                    'If you’re satisfied with the findings and the TSD closure, please do close the same from your end.</p>' +
                    
                    '<table>' +
                    '<tr>' +
                    '<th>Document No</th>' +
                    '<th>Document Date</th>' +
                    '<th>Invoice No</th>' +
                    '<th>Invoice Date</th>' +
                    '<th>Customer Name</th>' +
                    '<th>End Customer Name</th>' +
                    '<th>Item No</th>' +
                    '<th>Item Description</th>' +
                    '<th>Size</th>' +
                    '<th>Batch No</th>' +
                    '<th>Batch Qty</th>' +
                    '<th>Complaint Qty</th>' +
                    '<th>TSD Remark</th>' +
                    '<th>TSD Closure Date</th>' +
                    '<th>Days Open</th>' +
                    '</tr>' +
                    recData +
                    '</table>' +
                    '</body>' +
                    '</html>';
                if (Test.isRunningTest()) {
                    mail.setToAddresses(new List<String>{'huzaifa@finessedirect.com','vaibhavdnh@gmail.com'});
                } else {
                    mail.setToAddresses(new List<String>{record.Email});
                    mail.setCcAddresses(new String[] {
                        'tsd.rk@dnhsecheron.net','tsd.ak@dnhsecheron.net'
                    });
                }
                mail.setSubject('Follow-up on Closed Status for Service 19');
                mail.setHtmlBody(emailBody);
                emails.add(mail);
            }
            
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
            
            // Chain the next job to process the next invoice
            if (!Test.isRunningTest() || !stopChainingInTest) {
                if (index + 1 < this.userList.size()) {
                    System.enqueueJob(new Service19ReminderEmailQueueable(this.userList, index + 1));
                }
            }
        }
    }
    
}