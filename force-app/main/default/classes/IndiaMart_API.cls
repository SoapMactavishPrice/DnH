public class IndiaMart_API {

    // @Future(callout=true)
    // public static void callApi(Date datepara) {
    public static void callApi() {

        Date today = Date.today(); // gets today's date
        Date datepara = today.addDays(-1);

        DateTime myDateTime = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));

        String formattedDate = myDateTime.format('dd-MMM-yyyy');
        
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'IndiaMart_API : '+formattedDate;
        api_log.created_date__c = Datetime.now();

        try {

            // Construct URL with dynamic date
            String url = System.Label.indiamartURL
            + '?glusr_crm_key='+System.Label.indiamartcrmkey
            + '&start_time=' + formattedDate
            + '&end_time=' + formattedDate;
            // + '&start_time=06-Jan-2025'
            // + '&end_time=06-Jan-2025';

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
                IndiaMartApiResponse result = (IndiaMartApiResponse) JSON.deserialize(res.getBody(), IndiaMartApiResponse.class);

                if (result.CODE == 200) {
    
                    List<InquiryWrapper> inquiries = result.RESPONSE;
    
                    Set<String> citySet = new Set<String>();
                    Set<String> stateSet = new Set<String>();
                    // Set<String> countrySet = new Set<String>();
                    Set<String> mobileSet = new Set<String>();
                    Set < String > emailSet = new Set < String > ();
    
                    for(InquiryWrapper iw : inquiries) {
                        citySet.add(iw.SENDER_CITY);
                        stateSet.add(iw.SENDER_STATE);
                        // countrySet.add(iw.SENDER_COUNTRY_ISO);
                        mobileSet.add(iw.sender_mobile);
                        emailSet.add(iw.sender_email);
                    }
    
                    List<City__c> cityList = [SELECT Name, Id FROM City__c WHERE Name IN :citySet];
                    List<State__c> stateList = [SELECT Name, Id FROM State__c WHERE Name IN :stateSet];
                    // List<Country__c> countryList = [SELECT Name, Id FROM Country__c WHERE Name IN :countrySet];
                    List<Lead__c> leadList = [SELECT Id, Mobile_Number__c FROM Lead__c WHERE Mobile_Number__c IN :mobileSet];
                    List < Lead > stdLeadList = [SELECT Id, MobilePhone, Email FROM Lead WHERE MobilePhone IN: mobileSet OR Email IN: emailSet];
    
                    Map<String, String> cityMap = new Map<String, String>();
                    Map<String, String> stateMap = new Map<String, String>();
                    // Map<String, String> countryMap = new Map<String, String>();
                    Map<String, String> leadMap = new Map<String, String>();
                    Map < String, String > stdLeadMap = new Map < String, String > ();
                    Set<String> leadIdSet = new Set<String>();
                    Set < String > stdLeadIdSet = new Set < String > ();
    
                    for(City__c c : cityList) {
                        cityMap.put(c.Name, c.Id);
                    }
    
                    for(State__c s : stateList) {
                        stateMap.put(s.Name, s.Id);
                    }
    
                    // for(Country__c c : countryList) {
                    //     countryMap.put(c.Name, c.Id);
                    // }
    
                    for(Lead__c l : leadList) {
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

                    List<Lead_Source__c> leadSourceList = [SELECT Id, UID__c, Lead__c FROM Lead_Source__c WHERE Lead__c IN :leadIdSet];

                    Map<String, String> leadSourceMap = new Map<String, String>();
                    for(Lead_Source__c ls : leadSourceList) {
                        leadSourceMap.put(ls.UID__c, ls.Id);
                    }
    
                    List<Lead__c> leadsToInsert = new List<Lead__c>();
    
                    for(InquiryWrapper inq : inquiries) {
                        Lead__c l = new Lead__c();
                        if (leadMap.containsKey(inq.SENDER_MOBILE)) {
                            l.Id = leadMap.get(inq.SENDER_MOBILE);
                            l.IndiaMart__c = true;
                        } else {
                            l.Lead_Source__c = 'Indiamart';
                            l.IndiaMart__c = true;
                            l.Last_Name__c = 'Esteemed Client';
                            l.Name = 'Esteemed Client';
                            if (String.isNotBlank(inq.SENDER_NAME)) {
                                l.Last_Name__c = inq.SENDER_NAME;
                            }
                            if (String.isNotBlank(inq.SENDER_COMPANY)) {
                                l.Name = inq.SENDER_COMPANY;
                            }
                            l.Mobile_Number__c = inq.SENDER_MOBILE;
                            l.Email__c = inq.SENDER_EMAIL;
                        }
                        l.Subject__c = inq.SUBJECT;
                        // l.Company_Name__c = inq.SENDER_COMPANY;
                        l.Street_Address__c = inq.SENDER_ADDRESS;
                        l.City__c = cityMap.get(inq.SENDER_CITY);
                        l.State__c = stateMap.get(inq.SENDER_STATE);
                        l.Description__c = inq.QUERY_MESSAGE;
                        l.Alternate_Mobile__c = inq.SENDER_MOBILE_ALT;
                        l.Alternate_Email__c = inq.SENDER_EMAIL_ALT;
                        l.Query_Product_Name__c = inq.QUERY_PRODUCT_NAME;
                        l.Receiver_Mobile__c = inq.RECEIVER_MOBILE;


                        API_Log__c apilog = new API_Log__c();
                        apilog.Log_Name__c = 'IndiaMart_API_Subdata : '+formattedDate+' ('+inq.SENDER_MOBILE+')';
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
                        List<Lead_Source__c> childRecords = new List<Lead_Source__c>();

                        for (Integer i = 0; i < leadsToInsert.size(); i++) {
                            Lead__c insertedLead = leadsToInsert[i];
                            InquiryWrapper originalData = inquiries[i];

                            String rawMobile = originalData.SENDER_MOBILE;
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
                                insertStdLead.LastName = originalData.SENDER_NAME != null ? originalData.SENDER_NAME : 'Esteemed Client'; // LastName required
                                insertStdLead.Company = originalData.SENDER_COMPANY != null ? originalData.SENDER_COMPANY : 'Esteemed Client'; // Company required
                                insertStdLead.MobilePhone = originalData.SENDER_MOBILE;
                                insertStdLead.Email = originalData.SENDER_EMAIL;
                                insertStdLead.MC_Mobile_No__c = '91' + tenDigitMobile;
                                insertStdLead.LeadSource = 'Indiamart'; // map source too
                                insertStdLead.Lead_created_via_TI_and_IM__c = true;
                                insert insertStdLead;
                                stdLeadId = insertStdLead.Id;
                            }

                            System.debug('stdLeadId:>>> ' + stdLeadId);

                            if (!leadSourceMap.containsKey(originalData.UNIQUE_QUERY_ID)) {
                                Lead_Source__c child = new Lead_Source__c(
                                    Lead__c = insertedLead.Id,
                                    Receiver_Mobile__c = originalData.RECEIVER_MOBILE,
                                    Subject__c = originalData.SUBJECT,
                                    Message__c = originalData.QUERY_MESSAGE,
                                    Product_Name__c = originalData.QUERY_PRODUCT_NAME,
                                    Lead_Source__c = 'Indiamart',
                                    Mobile_No__c = originalData.SENDER_MOBILE,
                                    UID__c = originalData.UNIQUE_QUERY_ID,
                                    MC_Mobile_No__c = '91'+tenDigitMobile,
                                    Email__c = originalData.SENDER_EMAIL,
                                    Std_Lead__c = stdLeadId
                                );
                                childRecords.add(child);
                            }
                        }

                        if (childRecords.size() > 0) {
                            insert childRecords;
                        }
                    }
                } else {
                    
                }
                api_log.Log_Status__c = 'Success';
            } else {
                api_log.Log_Status__c = 'Failure';
            }
            
            api_log.Response_Code__c = String.valueOf(res.getStatusCode());
            api_log.Response__c = String.valueOf(res.getBody());
            api_log.response_time__c = Datetime.now();

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

    public class IndiaMartApiResponse {
        public Integer CODE;
        public String STATUS;
        public String MESSAGE;
        public Integer TOTAL_RECORDS;
        public List<InquiryWrapper> RESPONSE;
    }
    
    public class InquiryWrapper {
        public String UNIQUE_QUERY_ID;
        public String QUERY_TYPE;
        public String QUERY_TIME;
        public String SENDER_NAME;
        public String SENDER_MOBILE;
        public String SENDER_EMAIL;
        public String SUBJECT;
        public String SENDER_COMPANY;
        public String SENDER_ADDRESS;
        public String SENDER_CITY;
        public String SENDER_STATE;
        public String SENDER_PINCODE;
        public String SENDER_COUNTRY_ISO;
        public String SENDER_MOBILE_ALT;
        public String SENDER_PHONE;
        public String SENDER_PHONE_ALT;
        public String SENDER_EMAIL_ALT;
        public String QUERY_PRODUCT_NAME;
        public String QUERY_MESSAGE;
        public String QUERY_MCAT_NAME;
        public String CALL_DURATION;
        public String RECEIVER_MOBILE;
        public String RECEIVER_CATALOG;
    }

}