public class TradeIndia_API {

    // @Future(callout=true)
    public static void callApi() {
        // public static void callApi(Date datepara) {

        Date today = Date.today();
        Date datepara = today.addDays(-1);

        // String formattedDate = today.format(); // 'YYYY-MM-DD'

        String formattedDate = today.year() + '-' +
            (today.month() < 10 ? '0' + today.month() : String.valueOf(today.month())) + '-' +
            (today.day() < 10 ? '0' + today.day() : String.valueOf(today.day()));

        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'TradeIndia_API : ' + formattedDate;
        api_log.created_date__c = Datetime.now();

        try {

            // Construct URL with dynamic date
            String url = System.Label.tradeindiaURL +
                '?userid=' + System.Label.tradeindiauserid +
                '&profile_id=' + System.Label.tradeindiaprofileid +
                '&key=' + System.Label.tradeindiakey +
                '&from_date=' + formattedDate +
                '&to_date=' + formattedDate;
            // + '&from_date=2025-06-25'
            // + '&to_date=2025-06-25';

            // Initialize the HTTP request
            HttpRequest req = new HttpRequest();
            Http http = new Http();

            // Set the endpoint (URL)
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setTimeout(120000);

            api_log.Request_Url__c = url;

            HttpResponse res = http.send(req);

            System.debug(res.getBody());

            if (res.getStatusCode() == 200) {

                List < InquiryWrapper > inquiries = (List < InquiryWrapper > ) JSON.deserialize(res.getBody(), List < InquiryWrapper > .class);

                Set < String > citySet = new Set < String > ();
                Set < String > stateSet = new Set < String > ();
                Set < String > countrySet = new Set < String > ();
                Set < String > mobileSet = new Set < String > ();
                Set < String > emailSet = new Set < String > ();

                for (InquiryWrapper iw: inquiries) {
                    citySet.add(iw.sender_city);
                    stateSet.add(iw.sender_state);
                    countrySet.add(iw.sender_country);
                    mobileSet.add(iw.sender_mobile);
                    emailSet.add(iw.sender_email);
                }

                List < City__c > cityList = [SELECT Name, Id FROM City__c WHERE Name IN: citySet];
                List < State__c > stateList = [SELECT Name, Id FROM State__c WHERE Name IN: stateSet];
                List < Country__c > countryList = [SELECT Name, Id FROM Country__c WHERE Name IN: countrySet];
                List < Lead__c > leadList = [SELECT Id, Mobile_Number__c FROM Lead__c WHERE Mobile_Number__c IN: mobileSet];
                List < Lead > stdLeadList = [SELECT Id, MobilePhone, Email FROM Lead WHERE MobilePhone IN: mobileSet OR Email IN: emailSet];

                Map < String, String > cityMap = new Map < String, String > ();
                Map < String, String > stateMap = new Map < String, String > ();
                Map < String, String > countryMap = new Map < String, String > ();
                Map < String, String > leadMap = new Map < String, String > ();
                Map < String, String > stdLeadMap = new Map < String, String > ();
                Set < String > leadIdSet = new Set < String > ();
                Set < String > stdLeadIdSet = new Set < String > ();

                for (City__c c: cityList) {
                    cityMap.put(c.Name, c.Id);
                }

                for (State__c s: stateList) {
                    stateMap.put(s.Name, s.Id);
                }

                for (Country__c c: countryList) {
                    countryMap.put(c.Name, c.Id);
                }

                for (Lead__c l: leadList) {
                    leadMap.put(l.Mobile_Number__c, l.Id);
                    leadIdSet.add(l.Id);
                }

                for (Lead l: stdLeadList) {
                    if (String.isNotBlank(l.MobilePhone)) {
                        stdLeadMap.put(l.MobilePhone, l.Id);
                    }
                    if (String.isNotBlank(l.Email)) {
                        stdLeadMap.put(l.Email, l.Id);
                    }
                    stdLeadIdSet.add(l.Id);
                }

                List < Lead_Source__c > leadSourceList = [SELECT Id, UID__c, Lead__c FROM Lead_Source__c WHERE Lead__c IN: leadIdSet];

                Map < String, String > leadSourceMap = new Map < String, String > ();
                for (Lead_Source__c ls: leadSourceList) {
                    leadSourceMap.put(ls.UID__c, ls.Id);
                }

                List < Lead__c > leadsToInsert = new List < Lead__c > ();

                for (InquiryWrapper inq: inquiries) {
                    Lead__c l = new Lead__c();
                    if (leadMap.containsKey(inq.sender_mobile)) {
                        l.Id = leadMap.get(inq.sender_mobile);
                        l.TradeIndia__c = true;
                    } else {
                        l.Lead_Source__c = 'TradeIndia';
                        l.TradeIndia__c = true;
                        l.Last_Name__c = 'Esteemed Client';
                        l.Name = 'Esteemed Client';
                        if (String.isNotBlank(inq.sender_name)) {
                            l.Last_Name__c = inq.sender_name;
                        }
                        if (String.isNotBlank(inq.sender_co)) {
                            l.Name = inq.sender_co;
                        }
                        l.Email__c = inq.sender_email;
                        l.Mobile_Number__c = inq.sender_mobile;
                    }
                    l.Subject__c = inq.subject;
                    l.Description__c = inq.message;
                    l.City__c = cityMap.get(inq.sender_city);
                    l.State__c = stateMap.get(inq.sender_state);
                    l.Country__c = countryMap.get(inq.sender_country);
                    l.Product__c = inq.product_name;

                    API_Log__c apilog = new API_Log__c();
                    apilog.Log_Name__c = 'TradeIndia_API_Subdata : ' + formattedDate + ' (' + inq.sender_mobile + ')';
                    apilog.created_date__c = Datetime.now();
                    apilog.Request_Url__c = url;
                    apilog.Response__c = JSON.serialize(inq);
                    insert apilog;

                    l.API_Log__c = apilog.id;

                    leadsToInsert.add(l);
                }

                if (!leadsToInsert.isEmpty()) {
                    upsert leadsToInsert;
                    System.debug('Inserted ' + leadsToInsert.size() + ' inquiry records.');
                    List < Lead_Source__c > childRecords = new List < Lead_Source__c > ();

                    for (Integer i = 0; i < leadsToInsert.size(); i++) {
                        Lead__c insertedLead = leadsToInsert[i];
                        InquiryWrapper originalData = inquiries[i];

                        String rawMobile = originalData.sender_mobile;
                        // String cleanedMobile = rawMobile.replaceAll('[^0-9]', '');
                        // Get the last 10 digits
                        String tenDigitMobile = rawMobile.right(10);

                        String stdLeadId = '';
                        Lead insertStdLead = new Lead();

                        if (stdLeadMap.containsKey(originalData.sender_email)) {
                            stdLeadId = stdLeadMap.get(originalData.sender_email);
                        } else if (stdLeadMap.containsKey(originalData.sender_mobile)) {
                            stdLeadId = stdLeadMap.get(originalData.sender_mobile);
                        } else {
                            // insertStdLead.FirstName   = originalData.sender_name != null ? cl.Last_Name__c : 'Unknown';
                            insertStdLead.LastName = originalData.sender_name != null ? originalData.sender_name : 'Esteemed Client'; // LastName required
                            insertStdLead.Company = originalData.sender_co != null ? originalData.sender_co : 'Esteemed Client'; // Company required
                            insertStdLead.Email = originalData.sender_email;
                            insertStdLead.MobilePhone = originalData.sender_mobile;
                            insertStdLead.MC_Mobile_No__c = '91' + tenDigitMobile;
                            insertStdLead.LeadSource = 'TradeIndia'; // map source too
                            insertStdLead.Lead_created_via_TI_and_IM__c = true;
                            insert insertStdLead;
                            stdLeadId = insertStdLead.Id;
                        }

                        System.debug('stdLeadId:>>> ' + stdLeadId);

                        if (!leadSourceMap.containsKey(originalData.rfi_id)) {
                            Lead_Source__c child = new Lead_Source__c(
                                Lead__c = insertedLead.Id,
                                Receiver_Mobile__c = originalData.receiver_mobile,
                                Subject__c = originalData.subject,
                                Message__c = originalData.message,
                                Product_Name__c = originalData.product_name,
                                Lead_Source__c = 'TradeIndia',
                                Mobile_No__c = originalData.sender_mobile,
                                UID__c = originalData.rfi_id,
                                MC_Mobile_No__c = '91' + tenDigitMobile,
                                Email__c = originalData.sender_email,
                                Std_Lead__c = stdLeadId
                            );
                            childRecords.add(child);
                        }
                    }

                    if (childRecords.size() > 0) {
                        insert childRecords;
                    }
                }

                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();

            } else {

                System.debug('Error: ' + res.getStatus());
                System.debug('Error: ' + res.getBody());

                api_log.Log_Status__c = 'Failure';
                api_log.Response_Code__c = String.valueOf(res.getStatusCode());
                api_log.Response__c = String.valueOf(res.getBody());
                api_log.response_time__c = Datetime.now();
                // insert api_log;

            }

        } catch (Exception e) {
            System.debug('Exception: ' + e.getLineNumber());
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Response__c = String.valueOf(e.getMessage());
            api_log.response_time__c = Datetime.now();
            // insert api_log;

            System.debug('Exception: ' + e.getMessage());
            // return 'Exception: ' + e.getMessage();
        }

        insert api_log;

    }

    public class InquiryWrapper {
        public String view_status;
        public String sender_email;
        public String source;
        public String receiver_co;
        public String subject;
        public Integer unread_res_cnt;
        public String inquiry_type;
        public String generated_date;
        public Long receiver_uid;
        public Integer responded;
        public String message;
        public String sender_name;
        public String rfi_id;
        public String sender_country;
        public String sender_state;
        public String sender_mobile;
        public Long sender_uid;
        public String sender_co;
        public Long generated;
        public String receiver_mobile;
        public String ago_time;
        public String sender_other_mobiles;
        public String sender_city;
        public String sender;
        public String generated_time;
        public String month_slot;
        public String receiver_name;
        public String product_id;
        public String product_source;
        public String product_name;
    }

}