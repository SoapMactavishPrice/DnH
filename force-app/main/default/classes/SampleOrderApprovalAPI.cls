@RestResource(urlMapping='/ApproveSampleOrder')
global class SampleOrderApprovalAPI {
    
    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');
        
        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Approve_SampleOrderAPI';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();
        
        // JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        List<JSON2ApexSaveWebToLead> jsonObjList = (List<JSON2ApexSaveWebToLead>) JSON.deserialize(jSONRequestBody, List<JSON2ApexSaveWebToLead>.class);
        System.debug('======----->jsonObjList' + jsonObjList);
        
        try {
            
            JSON2ApexSaveWebToLead jsonObj = jsonObjList[0];
            
            Map<String, String> responseMap = new Map<String, String>();
            
            List<Service_5_Sample_Request__c> sampleOrderList = [
                SELECT Id, Name, Status__c, TSD_Remark__c, Approved_On__c, Is_Approved__c
                FROM Service_5_Sample_Request__c
                WHERE Name =: jsonObj.DocumentNo
            ];
            
            if (sampleOrderList.size() > 0) {
                api_log.Service_5_Sample_Request__c = sampleOrderList[0].Id;
                
                Service_5_Sample_Request__c sor = new Service_5_Sample_Request__c();
                sor.Id = sampleOrderList[0].Id;
                sor.Status__c = jsonObj.Status;
                sor.Approved_On__c = Datetime.valueOf(jsonObj.ApprovedOn);
                sor.TSD_Remark__c = jsonObj.TSDRemark;
                sor.Is_Approved__c = jsonObj.IsApproved;
                
                update sor;
                
                String emailsub;
                
                responseMap.put('status', '1');
                if (jsonObj.Status.contains('Approved')) {
                    responseMap.put('message', 'APPROVED');
                    emailsub = 'Service5 Document Approved';
                } else if (jsonObj.Status.contains('Reject')) {
                    responseMap.put('message', 'REJECTED');
                    emailsub = 'Service5 Document Rejected';
                }
                
                // -------- After update send email -------
                
                Service_5_Sample_Request__c x = [
                    SELECT Id, Name, Date__c, Customer_Name__c, Contact_Person_Name__c, Address_1__c, Address_2__c,
                    City__c, Postal_Code__c, Contact_No__c, Mode_of_Dispatch__c, Remark__c, TSD_Remark__c, Area_Manager__r.Email,
                    Area_Manager__r.Name, Field_Staff_Code__c, Field_Staff_Code__r.Name, Field_Staff_Code__r.Email
                    FROM Service_5_Sample_Request__c
                    WHERE Id =: sor.Id
                ];
                
                List <Sample_Request_Product__c> soLineItem = [
                    SELECT Id, Sample_Request_Item_Category_Code__r.Name, Item_No__r.Item_Number__c, Sample_Request__c,
                    Description__c, Sam_Req_Brand_Name__r.Name, Sam_Req_Size_mm__r.Name, Quantity_2__c
                    FROM Sample_Request_Product__c
                    WHERE Sample_Request__c =: sor.Id
                ];
                
                String lineItemStr = '';
                
                for (Sample_Request_Product__c o : soLineItem) {
                    String a = 
                        + '<tr>'
                        + '<td>'+o.Sample_Request_Item_Category_Code__r.Name+'</td><td>'+o.Item_No__r.Item_Number__c+'</td><td>'+o.Description__c+'</td>'
                        + '<td>'+o.Sam_Req_Brand_Name__r.Name+'</td><td>'+o.Sam_Req_Size_mm__r.Name+'</td><td>'+o.Quantity_2__c+'</td>'
                        + '</tr>';
                    
                    lineItemStr += a;
                }
                
                String emailBody = '<html>'
                    + '<body>'
                    + '<h3>Hello '+x.Customer_Name__c+',</h3>'
                    + '<p>DocumentNo For Service 5 Approved successfully: '+x.Name+'</p>'
                    + '<table border="1" style="border-collapse:collapse; width:100%;">'
                    + '<tr>'
                    + '<td><b>Document No:</b></td><td>'+x.Name+'</td>'
                    + '<td><b>Document Date:</b></td><td>'+x.Date__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>Customer Name:</b></td><td>'+x.Customer_Name__c+'</td>'
                    + '<td><b>Contact Person Name:</b></td><td>'+x.Contact_Person_Name__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>Address1:</b></td><td>'+x.Address_1__c+'</td>'
                    + '<td><b>Address 2:</b></td><td>'+x.Address_2__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>City:</b></td><td>'+x.City__c+'</td>'
                    + '<td><b>PostCode:</b></td><td>'+x.Postal_Code__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>Contact No:</b></td><td>'+x.Contact_No__c+'</td>'
                    + '<td><b>Mod Of Dispatch:</b></td><td>'+x.Mode_of_Dispatch__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>Remark:</b></td><td colspan="3">'+x.Remark__c+'</td>'
                    + '</tr>'
                    + '<tr>'
                    + '<td><b>TSD Remark:</b></td><td colspan="3">'+x.TSD_Remark__c+'</td>'
                    + '</tr>'
                    + '</table>'
                    + '<br>'
                    + '<table border="1" style="border-collapse:collapse; width:100%;">'
                    + '<tr>'
                    + '<th>Item Category</th><th>Item No</th><th>Description</th>'
                    + '<th>BrandName</th><th>Size</th><th>Quantity</th>'
                    + '</tr>'
                    + lineItemStr
                    + '</table>'
                    + '</body>'
                    + '</html>';
                
                String managerEmail = '';
                String staffEmail = '';
                if (!Test.isRunningTest()) {
                    managerEmail = x.Area_Manager__r.Email;
                    staffEmail = x.Field_Staff_Code__r.Email;
                } else {
                    managerEmail = 'huzaifa@finessedirect.com';
                    staffEmail = 'huzaifa@finessedirect.com';
                }
                
                if (managerEmail != null && staffEmail != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if (managerEmail == staffEmail) {
                        email.setToAddresses(new String[] {
                            managerEmail
                                });
                    } else {
                        email.setToAddresses(new String[] {
                            managerEmail, staffEmail
                                });
                    }
                    email.setSubject(emailsub);
                    email.setHtmlBody(emailBody);
                    
                    // Set related record ID for activity tracking
                    email.setWhatId(sor.Id);
                    email.setSaveAsActivity(true);

                    OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address = 'info@dnhsecheron.net'];
                    if (owea.size() > 0) {
                        System.debug('inside');
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    
                    // Send the email
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                        email
                            });
                }
                
                // -------- After update send email -------
                
            } else {
                responseMap.put('status', '0');
                responseMap.put('message', 'No Sample Order Found!!');
            }
            
            String resp = JSON.serialize(responseMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;
            
            api_log.Log_Status__c = 'Success';
            api_log.Response_Code__c = '200';
            api_log.Response__c = String.valueOf(resp);
            api_log.response_time__c = Datetime.now();
            
            
        } catch (Exception e) {
            System.debug('Catch Error' + e.getStackTraceString());
            System.debug('Catch Error' + e.getMessage());
            System.debug('Catch Error' + e.getlineNumber());
            
            // ------------------- Create Response Map -------------------
            Map < string, string > errorResMap = new Map < string, string > ();
            errorResMap.put('Message', 'Something went wrong');
            errorResMap.put('Error1', e.getMessage());
            errorResMap.put('Error2', '' + e.getlineNumber());
            errorResMap.put('Error3', '' + String.valueOf(e));
            
            // ------------------- Send Response Map -------------------
            String resp = JSON.serialize(errorResMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();
            
        }
        
        insert api_log;
        
    }
    
    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }
    
    public class JSON2ApexSaveWebToLead {
        public String DocumentNo;
        public String Status;
        public String IsApproved;
        public String ApprovedBy;
        public String ApprovedOn;
        public String IsSubmitted;
        public String TSDRemark;
        
    }
    
    
}