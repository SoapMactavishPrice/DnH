public without sharing class  AddCustomerMatrixOnAccountController {
    
    @AuraEnabled
    public static string getdefalutData(string recordId){
       Account acc = [Select Id, Industry__c from Account where Id=:recordId];
        wrapdata wrp = new wrapdata();
        wrp.logUserId = userInfo.getUserId();
        //wrp.application = acc. application;
        wrp.industry =acc.Industry__c;
        wrp.accId = acc.Id;
        return JSON.serialize(wrp);
    }
    
    @AuraEnabled
    public static map<string,string> saveRecord(string js){
        //string js = '{"Id":1,"label":"Company Name","Product_Brand":"34354","Product_Category":"yte","Product_Name":"a04F300000Gk6lVIAR","Product_Size":"1e","com_label":"Company Name","com_Product_Brand":"435","com_Product_Category":"cat","com_Product_Name":"dfghjk","com_Product_Size":"4g","empName":"","empId":"005GB00000YJ9QIYA1","customer":"","customerId":"001F300001hrlyLIAQ","industry":"","industryId":"a0NF3000004SSScMAO","dept":"","deptId":"a0MF3000004TbgyMAC","newApp":"","appliction":"","applictionId":"","alloy":"2345","potential":"23456","com_alloy":"12345","com_potential":0,"com_potential}":"23456"}';
        
        map<string,string> result = new map<string,string>();
        try{
            
       
        
        List<Object> objList  = (List<Object>)JSON.deserializeUntyped(js);
        
        List<Customer_Application_Matrix__c> camListToInsert = new List<Customer_Application_Matrix__c>();
        for(Object obj : objList){
            map<string,object> objMap =(map<string,object>)obj; 
            Customer_Application_Matrix__c comap = new Customer_Application_Matrix__c();
 			comap.Employee_Name__c = (Id)objMap.get('empId');
            
            if(string.IsNotBlank((string)objMap.get('customerId'))) comap.Customer__c = (Id)objMap.get('customerId');
            if(string.IsNotBlank((string)objMap.get('industryId'))) comap.Industry__c = (Id)objMap.get('industryId');
            if(string.IsNotBlank((string)objMap.get('deptId'))) comap.Department__c = (Id)objMap.get('deptId');
            if(string.IsNotBlank((string)objMap.get('applictionId'))) comap.Application__c = (Id)objMap.get('applictionId');
            comap.New_Application__c = (string)objMap.get('newApp');
            
            comap.Company_Name__c = (string)objMap.get('label');
            comap.Product_Brand__c = (string)objMap.get('Product_Brand');
            comap.Product_Category__c = (string)objMap.get('Product_Category');
            if(string.IsNotBlank((string)objMap.get('Product_Name'))) comap.Product_Name__c = (Id)objMap.get('Product_Name');
            comap.Product_Size__c = (string)objMap.get('Product_Size');
            
            //if((double)objMap.get('alloy') > 0){
                 comap.Alloy_Kgs_Annum__c =double.valueOf((string)objMap.get('alloy'));
            //}
            
            //if((double)objMap.get('potential')  > 0){
                 comap.Potential_Lakhs__c = double.valueOf((string)objMap.get('potential'));
            //}
            
            if(string.IsNotBlank((string)objMap.get('com_label')))  comap.Competitor_Name__c = (Id)objMap.get('com_label');
            comap.Competitor_Product_Brand__c = (string)objMap.get('com_Product_Brand');
            comap.Competitor_Product_Category__c = (string)objMap.get('com_Product_Category');
            comap.Competitor_Product_Name__c = (string)objMap.get('com_Product_Name');
            comap.Competitor_Product_Size__c = (string)objMap.get('com_Product_Size');
            //if((double)objMap.get('com_alloy') !=null){
                 comap.Competitor_Alloy_Kgs_Annum__c = double.valueOf((string)objMap.get('com_alloy'));
            //}
            
            //if((double)objMap.get('com_potential') > 0){
                 comap.Competitor_Potential_Lakhs__c =double.valueOf((string)objMap.get('com_potential'));
            //}
            
            
            camListToInsert.add(comap);
        }
        
            if(camListToInsert.size() > 0){
                insert camListToInsert;
                result.put('success','success');
            }
        }catch(exception e){
            result.put('error',e.getLineNumber()+' '+e.getMessage());
        }
           
        system.debug(result);
        return result;
        
        
    }
    
    public class wrapdata{
        public string logUserId;
        public string application;
        public string industry;
        public string accId;
    }
}