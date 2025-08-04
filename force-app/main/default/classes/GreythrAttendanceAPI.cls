public class GreythrAttendanceAPI {
    // public static void sendSwipesToGreyHR() {
    public static void sendSwipesToGreyHR(DateTime checkIn, DateTime checkOut, String userCode) {
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'GreythrAttendanceAPI';
        api_log.created_date__c = Datetime.now();
        try {
            // Replace with actual API ID
            // String agentId = '<agent-id>';
            
            // Get current DateTime
            Datetime dt = Datetime.now();
            
            // Convert to Indian Time Zone (Asia/Kolkata, UTC+5:30)
            // String formattedCheckIn_dt = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ', 'Asia/Kolkata');
            // String formattedCheckOut_dt = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ', 'Asia/Kolkata');
            String formattedCheckIn_dt = checkIn != null ? checkIn.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ', 'Asia/Kolkata') : '';
            String formattedCheckOut_dt = checkOut != null ? checkOut.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ', 'Asia/Kolkata') : '';
            System.debug(formattedCheckIn_dt);
            System.debug(formattedCheckOut_dt);
            
            // Fetch swipes data (assuming stored in a Custom Metadata, Custom Object, or a Static Resource)
            // Sample swipes data
            String swipes = formattedCheckIn_dt+','+userCode+',Main Door,1';
            if (formattedCheckOut_dt != '') {
                swipes = formattedCheckIn_dt+','+userCode+',Main Door,1\n'+formattedCheckOut_dt+','+userCode+',Main Door,0';
            }

            String privateKeyLabel = '-----BEGIN PRIVATE KEY-----\n' +
            'MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAJkW2TBg1MLzQMJR\n' +
            'xmSU2VGAF4SBfyzRZIqN0IBHjxX31rHEdPSa7yMkYFu9PNJLK4rJAgQG+vcGFKc6\n' +
            'ExvFbWY8n0PdEJxM8ZgXI7QmQrbrcMQxDb2SpdBqWNB+sI/Wx9B8rwtLqMl6mvl2\n' +
            'NTMmrz6gX/wgn4ZL38/zOSA4kfB7AgMBAAECgYAaz8ueE3dv5VaUMepDN2aQRZTY\n' +
            '2i1B1jJ7qba4oM/Iky2A2N168Z+sUfSmXJBIbG3l0qqNtgNCPEhluWAbXwp3tH4H\n' +
            'pAuGU1eKx2O7ls8M48NQCt28yuxrHTxyUd5fUDKqUVmnGBxpMGwurCvr+KRtyjgR\n' +
            'p1ZUvAk0OzN1Sz6SIQJBAPT2tM7nq5/C8wq0lS4L5YneMDTuMHvCD93v4sb2gL1Z\n' +
            'uPcCWvMsOoAEtQ9yECzNOos3MPiEYpeIUrCyI9ug7lkCQQCf/IGgfV+BeGClKENb\n' +
            'XISBSJ+2aEStaVl4H5q90pEG6yibOG7SuJIVL9MuRsTXtHZlaR6sokwcO6YFjmyU\n' +
            'KwLzAkA7N8Sf3At2NKeSZ/NETWXw/UCEGyynTlONoGcfGAopPB5lwDECZifCOOEY\n' +
            'WcelPPuxGeeBvGclILR0uKvIdVAJAkBIxCBxTpTR3l6Wv+li9IGQC+gYnvQdq3z2\n' +
            'FenbzJoJ+4tMji5ZyXkoCciTk7yUH5B6L4W0H11eugKZJF5eRfHhAkEA8BLe+qh2\n' +
            '3H52+w8Fsr1dCYU5bY806HyBp268EmH7XCXQ2N2ZiqLycAI8S8xZGk2TtGX+KWC9\n' +
            'n+oclEUvkH57qQ==\n' +
            '-----END PRIVATE KEY-----';

            // Generate RSA Signature
            String sign = signRSA(swipes, privateKeyLabel);

            // Prepare HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(System.label.GreythrEndPoint);
            req.setMethod('POST');
            req.setHeader('X-Requested-With', 'XMLHttpRequest');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            String body = 'id=' + EncodingUtil.urlEncode('c3a3011f-1289-445e-8e67-f29caaec98de', 'UTF-8') + 
                        '&swipes=' + EncodingUtil.urlEncode(swipes, 'UTF-8') + 
                        '&sign=' + EncodingUtil.urlEncode(sign, 'UTF-8');
            req.setBody(body);

            api_log.Request__c = body;

            // Send request
            Http http = new Http();
            HttpResponse res = http.send(req);
           
            System.debug('Check res.getStatusCode(): ' + res.getStatusCode());
            System.debug('Check res.getBody(): ' + res.getBody());

            if(res.getStatusCode() == 200) {
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = '200';
            } if (res.getStatusCode() == 302) {
                String newLocation = res.getHeader('Location');
                System.debug(newLocation);
                api_log.Log_Status__c = 'Success';
                api_log.Response_Code__c = '302';
            }
            api_log.Response__c = String.valueOf(res);
            api_log.response_time__c = Datetime.now();
        } catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
            System.debug('Exception: ' + e.getLineNumber());
            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();
        }

        insert api_log;
    }

    private static String signRSA(String data, String privateKeyPem) {
        // Convert PEM format to binary
        String pemKey = privateKeyPem.replace('-----BEGIN PRIVATE KEY-----', '')
                                     .replace('-----END PRIVATE KEY-----', '')
                                     .replaceAll('\\s+', '');
        Blob privateKeyBlob = EncodingUtil.base64Decode(pemKey);

        // Sign data
        Blob dataBlob = Blob.valueOf(data);
        Blob signedBlob = Crypto.sign('RSA-SHA1', dataBlob, privateKeyBlob);

        // Encode the signature
        return EncodingUtil.base64Encode(signedBlob);
    }

}