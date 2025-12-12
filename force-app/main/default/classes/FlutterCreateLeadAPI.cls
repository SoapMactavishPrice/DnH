@RestResource(urlMapping = '/flutterCreateLead')
global with sharing class FlutterCreateLeadAPI {

    @HttpPost
    global static void createLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Initialize API Log
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'FlutterCreateLead';
        api_log.created_date__c = Datetime.now();

        // Initialize response
        Map < String, Object > responseMap = new Map < String, Object > {
            'success' => false,
            'message' => '',
            'totalLeads' => 0,
            'successfulLeads' => 0,
            'failedLeads' => 0,
            'results' => new List < Map < String, Object >> ()
        };

        List < Lead__c > leadsToInsert = new List < Lead__c > ();
        List < LeadRequest > leadRequests = new List < LeadRequest > ();

        try {
            // Get request body and log it
            String requestBody = req.requestBody != null ? req.requestBody.toString() : '';
            api_log.Request__c = requestBody;

            if (String.isBlank(requestBody)) {
                throw new CustomException('Request body is empty');
            }

            // Parse JSON request - Check if it's a single lead or array of leads
            Object requestData = JSON.deserializeUntyped(requestBody);

            if (requestData instanceof List < Object > ) {
                // It's an array of leads
                for (Object obj: (List < Object > ) requestData) {
                    leadRequests.add((LeadRequest) JSON.deserialize(JSON.serialize(obj), LeadRequest.class));
                }
            } else if (requestData instanceof Map < String, Object > ) {
                // It's a single lead, convert to list
                leadRequests.add((LeadRequest) JSON.deserialize(JSON.serialize(requestData), LeadRequest.class));
            } else {
                throw new CustomException('Invalid request format. Expected a lead object or array of leads.');
            }

            if (leadRequests.isEmpty()) {
                throw new CustomException('No lead data provided');
            }

            Set<String> industrySet = new Set<String>();
            Set<String> phoneSet = new Set<String>();
            for (LeadRequest leadReq: leadRequests) {
                // Validate required fields
                if (String.isBlank(leadReq.lastName)) {
                    throw new CustomException('Last Name is required');
                }
                if (String.isBlank(leadReq.phone)) {
                    throw new CustomException('Phone is required');
                }
                if (String.isNotBlank(leadReq.phone)) {
                    phoneSet.add(leadReq.phone);
                }
                if (String.isNotBlank(leadReq.industry)) {
                    industrySet.add(leadReq.industry);
                }
            }

            Map<String, String> exLeadMap = new Map<String, String>();
            List<Lead__c> exLeadList = [
                SELECT Id, Name, Mobile_Number__c
                FROM Lead__c
                WHERE Mobile_Number__c IN :phoneSet
            ];

            for (Lead__c lead: exLeadList) {
                exLeadMap.put(lead.Mobile_Number__c, lead.Id);
            }
            
            Map<String, String> industryMap = new Map<String, String>();
            List <Industry__c> industryList = [
                SELECT Id, Name
                FROM Industry__c
                WHERE Name IN :industrySet
            ];

            for (Industry__c industry: industryList) {
                industryMap.put(industry.Name, industry.Id);
            }
 
            // Process each lead in the request
            for (Integer i = 0; i < leadRequests.size(); i++) {
                LeadRequest leadReq = leadRequests[i];
                Map < String, Object > result = new Map < String, Object > {
                    'index' => i,
                    'success' => false,
                    'message' => '',
                    'leadId' => null,
                    'errors' => new List < String > ()
                };

                try {
                    // Create new Lead__c and map fields manually
                    Lead__c newLead = new Lead__c();
                    if (exLeadMap.containsKey(leadReq.phone)) {
                        newLead.Id = exLeadMap.get(leadReq.phone);
                    }
                    // Required fields
                    newLead.Name = leadReq.lastName;
                    newLead.Last_Name__c = leadReq.lastName;
                    newLead.Mobile_Number__c = leadReq.phone;
                    if (String.isNotBlank(leadReq.email)) newLead.Email__c = leadReq.email;
                    if (String.isNotBlank(leadReq.salutation)) newLead.Salutation__c = leadReq.salutation;
                    if (String.isNotBlank(leadReq.firstName)) newLead.First_Name__c = leadReq.firstName;
                    if (String.isNotBlank(leadReq.title)) newLead.Title__c = leadReq.title;
                    if (String.isNotBlank(leadReq.leadSource)) newLead.Lead_Source__c = leadReq.leadSource;
                    if (String.isNotBlank(leadReq.industry) && industryMap.containsKey(leadReq.industry)) {
                        newLead.Industry__c = industryMap.get(leadReq.industry);
                    }
                    if (String.isNotBlank(leadReq.customerCategory)) newLead.Customer_Category__c = leadReq.customerCategory;
                    // if (String.isNotBlank(leadReq.rating)) newLead.Rating__c = leadReq.rating;
                    // if (String.isNotBlank(leadReq.phone)) newLead.Phone__c = leadReq.phone;
                    // if (String.isNotBlank(leadReq.industry)) newLead.Industry__c = leadReq.industry;
                    // if (String.isNotBlank(leadReq.status)) newLead.Status__c = leadReq.status;
                    // if (leadReq.annualRevenue != null) newLead.Annual_Revenue__c = leadReq.annualRevenue;
                    // if (String.isNotBlank(leadReq.description)) newLead.Description__c = leadReq.description;

                    leadsToInsert.add(newLead);

                    result.put('success', true);
                    result.put('message', 'Lead will be processed');

                } catch (Exception e) {
                    result.put('message', 'Error processing lead: ' + e.getMessage());
                    List < String > errors = (List < String > ) result.get('errors');
                    errors.add(e.getMessage());
                }

                // Add result to response
                List < Object > resultsList = (List < Object > ) responseMap.get('results');
                resultsList.add(result);
            }

            // Handle updates and inserts separately since Mobile_Number__c is not an External ID
            if (!leadsToInsert.isEmpty()) {
                List<Lead__c> leadsToUpdate = new List<Lead__c>();
                List<Lead__c> leadsToInsertNew = new List<Lead__c>();
                
                // Separate leads into updates and inserts
                for (Lead__c lead : leadsToInsert) {
                    if (lead.Id != null) {
                        leadsToUpdate.add(lead);
                    } else {
                        leadsToInsertNew.add(lead);
                    }
                }
                
                // Process updates
                if (!leadsToUpdate.isEmpty()) {
                    List<Database.SaveResult> updateResults = Database.update(leadsToUpdate, false);
                    for (Integer i = 0; i < updateResults.size(); i++) {
                        Database.SaveResult sr = updateResults[i];
                        Integer resultIndex = leadsToInsert.indexOf(leadsToUpdate[i]);
                        List<Object> resultsList = (List<Object>)responseMap.get('results');
                        Map<String, Object> result = (Map<String, Object>)resultsList[resultIndex];
                        
                        if (sr.isSuccess()) {
                            result.put('success', true);
                            result.put('message', 'Lead updated successfully');
                            result.put('leadId', sr.getId());
                            result.put('isCreated', false);
                            responseMap.put('successfulLeads', (Integer)responseMap.get('successfulLeads') + 1);
                        } else {
                            handleError(result, sr, responseMap);
                        }
                    }
                }
                
                // Process inserts
                if (!leadsToInsertNew.isEmpty()) {
                    List<Database.SaveResult> insertResults = Database.insert(leadsToInsertNew, false);
                    for (Integer i = 0; i < insertResults.size(); i++) {
                        Database.SaveResult sr = insertResults[i];
                        Integer resultIndex = leadsToInsert.indexOf(leadsToInsertNew[i]);
                        List<Object> resultsList = (List<Object>)responseMap.get('results');
                        Map<String, Object> result = (Map<String, Object>)resultsList[resultIndex];
                        
                        if (sr.isSuccess()) {
                            result.put('success', true);
                            result.put('message', 'Lead created successfully');
                            result.put('leadId', sr.getId());
                            result.put('isCreated', true);
                            responseMap.put('successfulLeads', (Integer)responseMap.get('successfulLeads') + 1);
                        } else {
                            handleError(result, sr, responseMap);
                        }
                    }
                }
            }

            // Update response summary
            responseMap.put('totalLeads', leadRequests.size());
            responseMap.put('success', (Integer) responseMap.get('successfulLeads') > 0);

            if ((Integer) responseMap.get('successfulLeads') > 0) {
                responseMap.put('message', 'Successfully processed ' + responseMap.get('successfulLeads') +
                    ' out of ' + responseMap.get('totalLeads') + ' leads');
                res.statusCode = 200; // OK (since we're not always creating)
            } else {
                responseMap.put('message', 'Failed to process any leads. ' +
                    responseMap.get('failedLeads') + ' failures.');
                res.statusCode = 207; // Multi-status
            }

            // Log success
            api_log.Log_Status__c = (Boolean) responseMap.get('success') ? 'Success' : 'Partial Success';
            api_log.Response_Code__c = String.valueOf(res.statusCode);

        } catch (Exception e) {
            System.debug('Error processing leads: ' + e.getMessage() + '\n' + e.getStackTraceString());

            // Prepare error response
            responseMap.put('message', 'Error: ' + e.getMessage());
            res.statusCode = 400; // Bad Request

            // Log error
            api_log.Log_Status__c = 'Error';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number: ' + e.getLineNumber() + '\n\n' +
                'Message: ' + e.getMessage() + '\n\n' +
                'Stack Trace: ' + e.getStackTraceString();
        } finally {
            try {
                // Always log the response
                Map < String, Object > logResponse = new Map < String, Object > {
                    'status' => responseMap.get('success'),
                    'message' => responseMap.get('message'),
                    'totalLeads' => responseMap.get('totalLeads'),
                    'successfulLeads' => responseMap.get('successfulLeads'),
                    'failedLeads' => responseMap.get('failedLeads')
                };

                api_log.Response__c = JSON.serialize(logResponse);
                api_log.response_time__c = Datetime.now();

                // Insert the API log
                insert api_log;
            } catch (Exception logEx) {
                System.debug('Error saving API log: ' + logEx.getMessage());
            }
        }

        // Set final response
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }

    // Helper method to handle DML errors
    private static void handleError(Map<String, Object> result, Database.SaveResult sr, Map<String, Object> responseMap) {
        result.put('success', false);
        String errorMsg = 'Failed to process lead: ';
        for (Database.Error err : sr.getErrors()) {
            errorMsg += err.getStatusCode() + ': ' + err.getMessage();
            if (err.getFields() != null) {
                errorMsg += ' (Fields: ' + String.join(err.getFields(), ', ') + ')';
            }
            errorMsg += '; ';
            List<String> errors = (List<String>)result.get('errors');
            errors.add(err.getMessage());
        }
        result.put('message', errorMsg);
        responseMap.put('failedLeads', (Integer)responseMap.get('failedLeads') + 1);
    }

    // Wrapper class for lead data
    public class LeadRequest {
        // Required fields
        public String lastName;
        public String company;

        // Optional fields
        public String firstName;
        public String email;
        public String phone;
        public String mobilePhone;
        public String title;
        public String leadSource;
        public String industry;
        public String status;
        public String rating;
        public Decimal annualRevenue;
        public String description;
        public String salutation;
        public String customerCategory;
    }

    // Custom exception class
    public class CustomException extends Exception {}
}