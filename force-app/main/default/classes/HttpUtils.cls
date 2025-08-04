public class HttpUtils {
    
    public static String getAllFields(String ObjectName,String SoId) {
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
         String query  = 'SELECT ';
         if(ObjectName=='Sales_Order__c'){
            query=query+'Inserted_By_SP__r.IsApprovedUser__c,Zonal_Head__r.Code__c,Zonal_Head__r.Zonal_Manager__c,Area_Manager__r.Code__c,SubmittedBy__r.Code__c,Inserted_By_SP__r.Code__c,Updated_By_SP__r.Code__c,Enquiry__r.Document_No__c,Enquiry__r.Enquiry_Name__c,Inserted_By_Customer__r.Customer_Code__c,LR_Destination_2__r.Code__c,Transporter__r.Code__c,Transporter__r.Name, ';
        }
        if(ObjectName=='Enquiry__c'){
            query=query+'Field_Staff_Code__r.IsApprovedUser__c,Field_Staff_Code__r.Reporting_Person__c,Area_Manager__r.Code__c,Field_Staff_Code__r.Area_Manager__c,Field_Staff_Code__r.Reporting_Person_ID__c, ';
        }
        if (ObjectName=='Service_5_Sample_Request__c') {
            query = query+'City__r.Name,Field_Staff_Code__r.Code__c,Area_Manager__r.Code__c,Zonal_Head__r.Code__c,Submitted_By__r.Code__c,Inserted_By__r.Code__c, ';
        }
        if (ObjectName=='Customer_Complaint__c') {
            query = query+'Account__r.Customer_Code__c,Field_Engineer_Name__r.Code__c,Area_Manager__r.Code__c,Zonal_Head__r.Code__c,Account__r.Name, ';
        }
        if (ObjectName=='Service_7_Sample_Feedbacks__c') {
            query = query+'Sample_Request_Product__r.Description__c,Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Name,Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Email,Sample_Request_Product__r.Sample_Request__r.Area_Manager__r.Code__c,Sample_Request_Product__r.Sample_Request__r.Zonal_Head__r.Code__c,Sample_Request_Product__r.Sample_Request__r.Field_Staff_Code__r.Code__c,Sample_Request_Product__r.Item_No__r.Item_Description__c,Sample_Request_Product__r.Sample_Order_Number__c,Sample_Request_Product__r.Sample_Request__r.Submitted_By__r.Code__c, ';
        }
        query= query+String.join(fields, ',')+' FROM '+ObjectName+' WHERE Id =:SoId';
        return query;
    }
    
    public static String getOneLevelLineItemRecords(String ObjectName,String pranetObjectName,String parentRecId) {
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
        String query  = 'SELECT ';
        if(ObjectName=='Sales_Order_Line_Item__c'){
            query=query+'Item_Variant__r.UOM__c,Item_Variant__r.Code__c,Item_Master__r.Product_Group_Code__c,Item_Master__r.Item_Description__c,Item_Master__r.Item_Number__c,Item_Master__r.Sales_Unit_of_Measure__c,Sales_Order__r.Name,Sales_Order__r.Rate_Type__c,Item_Master__r.Item_Category_Code__c,Sales_Order__r.Enquiry__r.Document_No__c,Item_Variant__r.Sales_UOM__c,Sales_Order__r.Enquiry__r.Enquiry_Name__c,Sales_Order__r.Is_Created_From_TSD__c, ';
        } else if (ObjectName == 'Sample_Request_Product__c') {
            query = query+'Sample_Request_Item_Category_Code__r.Code__c,Sample_Request__r.Name,Item_No__r.Item_Number__c,Sam_Req_Brand_Name__r.Code__c,Sam_Req_Size_mm__r.Code__c,Sample_Request__r.Inserted_By__r.Code__c, ';
        }
        query= query+String.join(fields, ',')+' FROM '+ObjectName+' WHERE '+pranetObjectName+' =:parentRecId';
        return query;
    }
    
    // Helper method to create Basic Authentication header
    public static String createBasicAuthHeader(String username, String password) {
        String auth = username + ':' + password;
        Blob authBlob = Blob.valueOf(auth);
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(authBlob);
        return authHeader;
    }

    public static String replacer(Object obj){
        if(obj == null){
            return '';
        }else{
            return String.valueOf(obj);
        }
    }

    
     public static APIparamter getAPIdetails(String apiName){
        APICallout__mdt wbs=[SELECT Id,Endpoint__c,Method__c,ContentType__c,Password__c,Request_body__c,SOAPAction__c,Username__c FROM APICallout__mdt WHERE DeveloperName =:apiName];
        APIparamter apiparam=new APIparamter();
        apiparam.Endpoint=wbs.Endpoint__c;
        apiparam.Method=wbs.Method__c;
         apiparam.ContentType=wbs.ContentType__c;
         apiparam.Password=wbs.Password__c;
         apiparam.Request_body=wbs.Request_body__c;
         apiparam.SOAPAction=wbs.SOAPAction__c;
         apiparam.Username=wbs.Username__c;
        
        return apiparam;
    }
    
    public class APIparamter{
        public string Endpoint;
        public string Method;
        public string ContentType;
        public string Password;
        public string Request_body;
        public string SOAPAction;
        public string Username;
    }
}