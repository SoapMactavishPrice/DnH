public class CreateCustomerComplaint_ToNav {
    
    // public static Map < String, Object > createComplaint(String orderId) {

    //     // ------------------- API LOG to track the request -------------------
    //     API_Log__c api_log = new API_Log__c();
    //     api_log.Log_Name__c = 'CreateCustomerComplaint_ToNav';
        
    //     String URL = ''; // Set API URL
    //     api_log.Request_Url__c = URL;
        
    //     Map < String, Object > requestDataMap = new Map < String, Object > ();
    //     Map < String, Object > responseDataMap = new Map < String, Object > ();
        
    //     try {
            
    //         // ------------------- Create Hit Request -------------------
    //         HttpRequest httpReq = new HttpRequest();
    //         httpReq.setMethod('POST');
    //         httpReq.setBody(jsonData);
    //         httpReq.setEndpoint(URL);
    //         httpReq.setTimeout(120000);
    //         httpReq.setHeader('Content-Type','application/json');
            
    //         api_log.created_date__c = System.now();

    //         Http h = new Http();
    //         HttpResponse httpRes = h.send(httpReq);

    //         api_log.Response_Code__c = String.valueOf(httpRes.getStatusCode());
    //         api_log.Response__c = httpRes.getBody();
    //         api_log.response_time__c = System.now();

    //         if (httpRes.getStatusCode() == 200) {
    //             api_log.Log_Status__c = 'Success';
    //             Map < String, Object > resBodyMap = (Map < String, Object > ) JSON.deserializeUntyped(httpRes.getBody());
    //             responseDataMap.put('resData', resBodyMap);
    //         } else {
    //             api_log.Log_Status__c = 'Failure';
    //             Map < String, Object > errorBodyMap = (Map < String, Object > ) JSON.deserializeUntyped(httpRes.getBody());
    //             if ((String) errorBodyMap.get('message') != null) {
    //                 resWrapper.put('Fail', (String) errorBodyMap.get('message'));
    //             }
    //         }

    //     } catch (Exception e) {
    //         api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
    //         api_log.response_time__c = Datetime.now();
    //         api_log.Log_Status__c = 'Failure';
    //         resWrapper.put('Error', e.getMessage());
    //     }

    // insert api_log;
        
    // }

}