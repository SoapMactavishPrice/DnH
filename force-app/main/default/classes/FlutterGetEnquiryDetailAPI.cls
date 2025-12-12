@RestResource(urlMapping='/flutterGetEnquiry')
global class FlutterGetEnquiryDetailAPI {
    
    @HttpGet
    global static void getEnquiryDetail() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'flutterGetEnquiryDetail';
        api_log.created_date__c = Datetime.now();
        
        try {
            // Get parameters from URL
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
            
            // Build and execute SOQL query for enquiries
            List<Enquiry__c> enquiries = new List<Enquiry__c>();
            try {
                String soql = 'SELECT Id, Name, Enquiry_Name__c, Account__c, Status__c, End_Customer__c, End_Customer__r.Name, ' +
                             'Field_Staff_Code__c, Field_Staff_Code__r.Name, Area_Manager__c, Area_Manager__r.Name, ' +
                             'Zonal_Head__c, Zonal_Head__r.Name, RecordTypeId, RecordType.Name, Date_DD_MM_YYYY__c, Valid_Up_To__c, ' +
                             'Remarks__c, FS_Remarks__c, Competition_Brand__c, Application_Optional__c, Any_Special_Technical_Requirement__c, ' +
                             'Technical_Requirement_Agreed__c, Customer_Name__c, Field_Staff_Code__r.Code__c, Area_Manager__r.Code__c, Zonal_Head__r.Code__c ' +
                             'FROM Enquiry__c ' +
                             'WHERE Enquiry_Name__c != null ' +
                             'AND Field_Staff_Code__c = :usrId ';

                if (startDate != null && endDate != null) {
                    soql += ' AND CreatedDate >= :startDate AND CreatedDate <= :endDate';
                }

                soql += ' ORDER BY CreatedDate DESC';
                
                // Log the query for debugging
                System.debug('Executing SOQL: ' + soql);
                
                enquiries = Database.query(soql);
            } catch (Exception queryEx) {
                System.debug('Query Error: ' + queryEx.getMessage() + ' at line ' + queryEx.getLineNumber());
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'Error querying enquiries: ' + queryEx.getMessage()
                };
                sendErrorResponse(res, api_log, 500, 'Query error', JSON.serialize(errorResponse));
                return;
            }
            
            if (enquiries.isEmpty()) {
                Map<String, String> errorResponse = new Map<String, String>{
                    'status' => 'false',
                    'message' => 'No enquiries found for sales person code: ' + salesPersonCode
                };
                sendErrorResponse(res, api_log, 404, 'No enquiries found', JSON.serialize(errorResponse));
                return;
            }
            
            // Get all enquiry IDs for querying line items
            Set<Id> enquiryIds = new Map<Id, Enquiry__c>(enquiries).keySet();
            
            // Query all line items for these enquiries
            Map<Id, List<Enquiry_Line_Item__c>> enquiryLineItemsMap = new Map<Id, List<Enquiry_Line_Item__c>>();
            for (Enquiry_Line_Item__c item : [
                SELECT Id, Name, Item_Master__c, Enquiry__c, Item_Master__r.Item_Number__c, Item_Master__r.Name,
                Qty__c, Order_Qty__c, Approved_Price__c, Reason_for_lost_enquiry__c, Competitor__c, Competitor_Product__c,
                Competitor__r.Name, Competitor_Product__r.Name
                FROM Enquiry_Line_Item__c 
                WHERE Enquiry__c IN :enquiryIds
                ORDER BY Item_No__c
            ]) {
                if (!enquiryLineItemsMap.containsKey(item.Enquiry__c)) {
                    enquiryLineItemsMap.put(item.Enquiry__c, new List<Enquiry_Line_Item__c>());
                }
                enquiryLineItemsMap.get(item.Enquiry__c).add(item);
            }
            
            // Prepare response with list of enquiries and their line items
            List<Map<String, Object>> enquiryList = new List<Map<String, Object>>();
            for (Enquiry__c enq : enquiries) {
                // Prepare line items for this enquiry
                List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
                if (enquiryLineItemsMap.containsKey(enq.Id)) {
                    for (Enquiry_Line_Item__c item : enquiryLineItemsMap.get(enq.Id)) {
                        lineItems.add(new Map<String, Object>{
                            'uniqueId' => item.Id,
                            'itemCode' => item.Item_Master__c != null ? item.Item_Master__r.Item_Number__c : '',
                            'itemName' => item.Item_Master__c != null ? item.Item_Master__r.Name : '',
                            // 'qty' => item.Qty__c != null ? item.Qty__c : '',
                            'qty' => item.Order_Qty__c != null ? String.valueOf(item.Order_Qty__c) : '',
                            'salesPrice' => item.Approved_Price__c != null ? String.valueOf(item.Approved_Price__c) : '',
                            'reasonForLost' => item.Reason_for_lost_enquiry__c != null ? item.Reason_for_lost_enquiry__c : '',
                            'competitor' => item.Competitor__c != null ? item.Competitor__r.Name : '',
                            'competitorProduct' => item.Competitor_Product__c != null ? item.Competitor_Product__r.Name : ''
                        });
                    }
                }
                
                enquiryList.add(new Map<String, Object>{
                    'uniqueId' => enq.Id,
                    'name' => enq.Name,
                    'enquiryNumber' => enq.Name,
                    'documentNumber' => enq.Enquiry_Name__c != null ? enq.Enquiry_Name__c : '',
                    'customerName' => enq.Customer_Name__c != null ? enq.Customer_Name__c : '',
                    'status' => enq.Status__c,
                    'endCustomerName' => enq.End_Customer__c != null ? enq.End_Customer__r.Name : '',
                    'fieldStaffName' => enq.Field_Staff_Code__c != null ? enq.Field_Staff_Code__r.Name : '',
                    'fieldStaffCode' => enq.Field_Staff_Code__c != null ? enq.Field_Staff_Code__r.Code__c : '',
                    'areaManager' => enq.Area_Manager__c != null ? enq.Area_Manager__r.Name : '',
                    'areaManagerCode' => enq.Area_Manager__c != null ? enq.Area_Manager__r.Code__c : '',
                    'zonalHead' => enq.Zonal_Head__c != null ? enq.Zonal_Head__r.Name : '',
                    'zonalHeadCode' => enq.Zonal_Head__c != null ? enq.Zonal_Head__r.Code__c : '',
                    'recordType' => enq.RecordType.Name,
                    'dateDDMMYYYY' => enq.Date_DD_MM_YYYY__c != null ? String.valueOf(enq.Date_DD_MM_YYYY__c) : '',
                    'validUpTo' => enq.Valid_Up_To__c != null ? enq.Valid_Up_To__c.format('yyyy-MM-dd') : '',
                    'remarks' => enq.Remarks__c != null ? enq.Remarks__c :'',
                    'fsRemarks' => enq.FS_Remarks__c != null ? enq.FS_Remarks__c :'',
                    'competitionBrand' => enq.Competition_Brand__c != null ? enq.Competition_Brand__c :'',
                    'applicationOptional' => enq.Application_Optional__c != null ? enq.Application_Optional__c :'',
                    'anySpecialTechnicalRequirement' => enq.Any_Special_Technical_Requirement__c != null ? enq.Any_Special_Technical_Requirement__c :'',
                    'technicalRequirementAgreed' => enq.Technical_Requirement_Agreed__c != null ? enq.Technical_Requirement_Agreed__c :'',
                    'lineItems' => lineItems
                });
            }
            
            // Prepare success response
            Map<String, Object> responseMap = new Map<String, Object>{
                'status' => 'true',
                'message' => 'Enquiries retrieved successfully',
                'enquiries' => enquiryList
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
                'message' => 'Enquiries retrieved successfully',
                'enquiryCount' => enquiryList.size(),
                'enquiryIds' => new List<Id>(enquiryIds)
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
            sendErrorResponse(res, api_log, 500, 'Unexpected error', JSON.serialize(errorResMap));
            return;
        } finally {
            try {
                // Insert the API log
                if (api_log != null) {
                    insert api_log;
                }
            } catch (Exception logEx) {
                System.debug('Error saving API log: ' + logEx.getMessage());
            }
        }
    }
    
    // Helper method to send error responses
    private static void sendErrorResponse(RestResponse res, API_Log__c log, 
                                        Integer statusCode, String errorMessage, 
                                        String errorDetails) {
        if (res != null) {
            res.responseBody = Blob.valueOf(errorDetails);
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = statusCode;
        }
        
        if (log != null) {
            log.Log_Status__c = 'Error';
            log.Exception_desc__c = errorMessage;
            log.Response_Code__c = String.valueOf(statusCode);
            log.Response__c = errorDetails;
            log.Response_Time__c = Datetime.now();
        }
    }
}