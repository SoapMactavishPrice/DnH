@RestResource(urlMapping='/flutterGetCustomer')
global class FlutterGetCustomerDetailAPI {
    @HttpGet
    global static void getCustomerDetail() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'flutterGetCustomerDetail';
        api_log.created_date__c = Datetime.now();
        
        try {
            // Get salesPersonCode from request parameters
            String salesPersonCode = req.params.get('salesPersonCode');
            String fromDate = req.params.get('fromDate');
            String toDate = req.params.get('toDate');
            
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

            if ((String.isNotBlank(fromDate) && String.isBlank(toDate)) || (String.isBlank(fromDate) && String.isNotBlank(toDate))) {
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
            
            // Update the SOQL query to include date range if provided
            List<Account> accounts = new List<Account>();
            String soql = 'SELECT Id, Name, Customer_Code__c, ' +
                        'BillingStreet, BillingCity, BillingState, Customer_Type__c, ' +
                        'Industry__c, Industry__r.Name, BillingPostalCode, ' +
                        'BillingCountry, Phone, Email_Id__c, CreatedDate,' +
                        '(SELECT Id, FirstName, LastName, Email, Phone, ' +
                        'MobilePhone, Title, Department, Anniversary_Date__c ' +
                        'FROM Contacts ' +
                        'ORDER BY LastName, FirstName) ' +
                        'FROM Account ' +
                        'WHERE Owner.Code__c = :salesPersonCode ';

            if (startDate != null && endDate != null) {
                soql += ' AND CreatedDate >= :startDate AND CreatedDate <= :endDate';
            }

            soql += ' ORDER BY Name';

            accounts = Database.query(soql);
            
            if (accounts.isEmpty()) {
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'No customers found for sales person code: ' + salesPersonCode
                };
                sendErrorResponse(res, api_log, 404, 'No customers found', JSON.serialize(errorResponse));
                return;
            }
            
            // Prepare response with list of accounts and their contacts
            List<Map<String, Object>> accountList = new List<Map<String, Object>>();
            for (Account acc : accounts) {
                List<Map<String, Object>> contactList = new List<Map<String, Object>>();
                
                // Process contacts if they exist
                if (acc.Contacts != null) {
                    for (Contact c : acc.Contacts) {
                        contactList.add(new Map<String, Object>{
                            'uniqueId' => c.Id,
                            'firstName' => c.FirstName != null ? c.FirstName : '',
                            'lastName' => c.LastName != null ? c.LastName : '',
                            'fullName' => ((c.FirstName != null ? c.FirstName + ' ' : '') + 
                                         (c.LastName != null ? c.LastName : '')).trim(),
                            'email' => c.Email != null ? c.Email : '',
                            'title' => c.Title != null ? c.Title : '',
                            'department' => c.Department != null ? c.Department : '',
                            'mobile' => c.MobilePhone != null ? c.MobilePhone : '',
                            'anniversary' => c.Anniversary_Date__c != null ? 
                                           String.valueOf(c.Anniversary_Date__c) : '',
                            'phone' => c.Phone != null ? c.Phone : ''
                        });
                    }
                }
                
                // Add account to the list
                accountList.add(new Map<String, Object>{
                    'uniqueId' => acc.Id,
                    'industry' => acc.Industry__r != null ? acc.Industry__r.Name : '',
                    'name' => acc.Name,
                    'type' => acc.Customer_Type__c != null ? acc.Customer_Type__c : '',
                    'customerCode' => acc.Customer_Code__c != null ? acc.Customer_Code__c : '',
                    'billingStreet' => acc.BillingStreet != null ? acc.BillingStreet : '',
                    'billingCity' => acc.BillingCity != null ? acc.BillingCity : '',
                    'billingState' => acc.BillingState != null ? acc.BillingState : '',
                    'billingPostalCode' => acc.BillingPostalCode != null ? acc.BillingPostalCode : '',
                    'billingCountry' => acc.BillingCountry != null ? acc.BillingCountry : '',
                    'phone' => acc.Phone != null ? acc.Phone : '',
                    'email' => acc.Email_Id__c != null ? acc.Email_Id__c : '',
                    'createdDate' => acc.CreatedDate != null ? String.valueOf(acc.CreatedDate) : '',
                    'contacts' => contactList
                });
            }
            
            // Prepare success response
            Map<String, Object> responseMap = new Map<String, Object>{
                'status' => 'true',
                'message' => 'Customers retrieved successfully',
                'customers' => accountList
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
                'message' => 'Customers retrieved successfully',
                'customerCount' => accountList.size()
            };
            api_log.Response__c = JSON.serialize(logResponse);
            api_log.Response_Time__c = Datetime.now();

        } catch (Exception e) {
            System.debug('Catch Error' + e.getStackTraceString());
            System.debug('Catch Error' + e.getMessage());
            System.debug('Catch Error' + e.getLineNumber());

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