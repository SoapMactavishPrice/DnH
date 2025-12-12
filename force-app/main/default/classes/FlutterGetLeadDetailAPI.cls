@RestResource(urlMapping='/flutterGetLead')
global class FlutterGetLeadDetailAPI {
    @HttpGet
    global static void getLeadDetail() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'flutterGetLeadDetail';
        api_log.created_date__c = Datetime.now();
        
        try {
            // Get parameters from request
            String salesPersonCode = req.params.get('salesPersonCode');
            String fromDate = req.params.get('fromDate');
            String toDate = req.params.get('toDate');
            
            // Validate salesPersonCode
            if (String.isBlank(salesPersonCode)) {
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'salesPersonCode parameter is required'
                };
                sendErrorResponse(res, api_log, 400, 'Missing required parameter', JSON.serialize(errorResponse));
                return;
            }
            
            // Log the request
            api_log.Request__c = JSON.serialize(req.params);
            
            // Validate salesPersonCode parameter
            if (String.isBlank(salesPersonCode)) {
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'salesPersonCode is required'
                };
                sendErrorResponse(res, api_log, 400, 'Missing salesPersonCode parameter', JSON.serialize(errorResponse));
                return;
            }

            // Date range validation
            if ((String.isNotBlank(fromDate) && String.isBlank(toDate)) || 
                (String.isBlank(fromDate) && String.isNotBlank(toDate))) {
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'Both fromDate and toDate must be provided together or both left blank'
                };
                sendErrorResponse(res, api_log, 400, 'Invalid date range parameters', JSON.serialize(errorResponse));
                return;
            }

            Date startDate;
            Date endDate;

            // Parse dates if provided
            if (String.isNotBlank(fromDate) && String.isNotBlank(toDate)) {
                try {
                    startDate = Date.valueOf(fromDate);
                    endDate = Date.valueOf(toDate);
                    
                    if (endDate < startDate) {
                        Map<String, String> errorResponse = new Map<String, String>{
                            'status' => 'false',
                            'message' => 'toDate must be greater than or equal to fromDate'
                        };
                        sendErrorResponse(res, api_log, 400, 'Invalid date range', JSON.serialize(errorResponse));
                        return;
                    }
                } catch (Exception e) {
                    Map<String, String> errorResponse = new Map<String, String>{
                        'status' => 'false',
                        'message' => 'Invalid date format. Please use YYYY-MM-DD format'
                    };
                    sendErrorResponse(res, api_log, 400, 'Invalid date format', JSON.serialize(errorResponse));
                    return;
                }
            }

            // Query for active user with the given sales person code
            List<User> usrList = [SELECT Id FROM User WHERE Code__c = :salesPersonCode AND IsActive = true LIMIT 1];
            if (usrList.isEmpty()) {
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'Active user not found for sales person code: ' + salesPersonCode
                };
                sendErrorResponse(res, api_log, 404, 'User not found', JSON.serialize(errorResponse));
                return;
            }
            Id usrId = usrList[0].Id;
            // Build and execute SOQL query for leads
            List<Lead__c> leads = new List<Lead__c>();
            try {
                String soql = 'SELECT Id, Name, First_Name__c, Last_Name__c, Industry__c, Industry__r.Name, Department__c, Department__r.Name, ' +
                             'Salutation__c, Email__c, Mobile_Number__c, Lead_Source__c, Website__c,  ' +
                             'Line_3_Street_PO_Box__c, Line_2_Building_Floor_Room__c, Line_1_Block__c, ' +
                             'City__c, City__r.Name, District__c, District__r.Name, State__c, State__r.Name, CreatedDate, ' +
                             'Country__c, Country__r.Name, Lead_Type__c, Customer_Category__c ' +
                             'FROM Lead__c ' +
                             'WHERE OwnerId = :usrId ';

                if (startDate != null && endDate != null) {
                    soql += ' AND CreatedDate >= :startDate AND CreatedDate <= :endDate';
                }

                soql += ' ORDER BY Last_Name__c, First_Name__c';
                
                // Log the query for debugging (remove in production if not needed)
                System.debug('Executing SOQL: ' + soql);
                
                leads = Database.query(soql);
            } catch (Exception queryEx) {
                System.debug('Query Error: ' + queryEx.getMessage() + ' at line ' + queryEx.getLineNumber());
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'Error querying leads: ' + queryEx.getMessage()
                };
                sendErrorResponse(res, api_log, 500, 'Query error', JSON.serialize(errorResponse));
                return;
            }
            
            if (leads.isEmpty()) {
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'No leads found for sales person code: ' + salesPersonCode
                };
                sendErrorResponse(res, api_log, 404, 'No leads found', JSON.serialize(errorResponse));
                return;
            }
            
            // Prepare response with list of leads
            List<Map<String, Object>> leadList = new List<Map<String, Object>>();
            for (Lead__c ld : leads) {
                leadList.add(new Map<String, Object>{
                    'uniqueId' => ld.Id,
                    'name' => ld.Name != null ? ld.Name : '',
                    'firstName' => ld.First_Name__c != null ? ld.First_Name__c : '',
                    'lastName' => ld.Last_Name__c != null ? ld.Last_Name__c : '',
                    'fullName' => ((ld.First_Name__c != null ? ld.First_Name__c + ' ' : '') + 
                                (ld.Last_Name__c != null ? ld.Last_Name__c : '')).trim(),
                    // 'industry' => ld.Industry__c != null ? ld.Industry__c : '',
                    'industryName' => ld.Industry__r?.Name != null ? ld.Industry__r.Name : '',
                    // 'department' => ld.Department__c != null ? ld.Department__c : '',
                    'departmentName' => ld.Department__r?.Name != null ? ld.Department__r.Name : '',
                    'salutation' => ld.Salutation__c != null ? ld.Salutation__c : '',
                    'email' => ld.Email__c != null ? ld.Email__c : '',
                    'mobile' => ld.Mobile_Number__c != null ? ld.Mobile_Number__c : '',
                    'leadSource' => ld.Lead_Source__c != null ? ld.Lead_Source__c : '',
                    'website' => ld.Website__c != null ? ld.Website__c : '',
                    'address' => new Map<String, String>{
                        'line1' => ld.Line_1_Block__c != null ? ld.Line_1_Block__c : '',
                        'line2' => ld.Line_2_Building_Floor_Room__c != null ? ld.Line_2_Building_Floor_Room__c : '',
                        'line3' => ld.Line_3_Street_PO_Box__c != null ? ld.Line_3_Street_PO_Box__c : '',
                        // 'city' => ld.City__c != null ? ld.City__c : '',
                        'cityName' => ld.City__r?.Name != null ? ld.City__r.Name : '',
                        // 'district' => ld.District__c != null ? ld.District__c : '',
                        'districtName' => ld.District__r?.Name != null ? ld.District__r.Name : '',
                        // 'state' => ld.State__c != null ? ld.State__c : '',
                        'stateName' => ld.State__r?.Name != null ? ld.State__r.Name : '',
                        // 'country' => ld.Country__c != null ? ld.Country__c : '',
                        'countryName' => ld.Country__r?.Name != null ? ld.Country__r.Name : ''
                    },
                    'leadType' => ld.Lead_Type__c != null ? ld.Lead_Type__c : '',
                    'customerCategory' => ld.Customer_Category__c != null ? ld.Customer_Category__c : '',
                    'createdDate' => ld.CreatedDate != null ? String.valueOf(ld.CreatedDate) : ''
                });
            }
            
            // Prepare success response
            Map<String, Object> responseMap = new Map<String, Object>{
                'status' => 'true',
                'message' => 'Leads retrieved successfully',
                'leads' => leadList
            };
            
            // Send success response
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 200;
            
            // Update log with success status
            api_log.Log_Status__c = 'Success';
            api_log.Response_Code__c = '200';
            Map<String, Object> logResponse = new Map<String, Object>{
                'status' => 'true',
                'message' => 'Leads retrieved successfully',
                'leadCount' => leadList.size()
            };
            api_log.Response__c = JSON.serialize(logResponse);
            api_log.Response_Time__c = Datetime.now();

        } catch (Exception e) {
            System.debug('Catch Error: ' + e.getStackTraceString());
            System.debug('Catch Error: ' + e.getMessage());
            System.debug('Catch Error at line: ' + e.getLineNumber());

            // Create and send error response
            Map<String, String> errorResMap = new Map<String, String> {
                'status' => 'false',
                'message' => 'Something went wrong',
                'error' => e.getMessage() + ' || ' + e.getLineNumber() + ' || ' + String.valueOf(e)
            };
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorResMap));
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 500;

            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '500';
            api_log.Exception_desc__c = 'Line Number: ' + e.getLineNumber() + 
                                      ' \n\n ' + e.getMessage() + 
                                      '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();
            api_log.Response__c = JSON.serialize(errorResMap);
        } finally {
            insert api_log;
        }
    }
    
    // Helper method to send error responses
    private static void sendErrorResponse(RestResponse res, API_Log__c log, 
                                        Integer statusCode, String errorMessage, 
                                        String responseBody) {
        res.responseBody = Blob.valueOf(responseBody);
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = statusCode;
        
        log.Log_Status__c = 'Failure';
        log.Response_Code__c = String.valueOf(statusCode);
        log.Exception_desc__c = errorMessage;
        log.Response__c = responseBody;
    }
}