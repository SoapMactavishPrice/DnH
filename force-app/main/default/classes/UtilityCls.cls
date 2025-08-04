public class UtilityCls {
    
    public static Map<String, String> getAllFields(String sObjectName) {
        
        if (!Schema.getGlobalDescribe().containsKey(sObjectName)) {
            Map<String, String> tempMap = new Map<String, String>();
            tempMap.put('Exception', 'Invalid object name');
            return tempMap;
        }
        
        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        
        String allfields = '';
        for (Schema.SObjectField field: fields.values())
            if (field.getDescribe().isAccessible())
            allfields += field.getDescribe().getName() + ', ';
        system.debug('allfields'+allfields);
        allfields = allfields.subString(0, allfields.length() - 2);
        system.debug('allfields'+allfields);
        Map<String, String> tempMap = new Map<String, String>{sobjectname => allfields};
            return tempMap;
    }
    
    /*
    public static Map<String, Pricelist_Master__c>  getPriceList() {
        List<Pricelist_Master__c> pr2 = new List<Pricelist_Master__c>();
        Map < String, String > s3 = UtilityCls.getAllFields('Pricelist_Master__c');
        
        String query3 = 'Select ' + s3.get('Pricelist_Master__c') + '  from Pricelist_Master__c ';
        pr2 = database.query(query3);
        Map<String, Pricelist_Master__c> mapP2 = new Map<String, Pricelist_Master__c>();
        for (Pricelist_Master__c p: pr2) {
            //mapP2.put(p.Price_List_Code__c,p);
        }
        return mapP2;
    }*/
    
    public static Map<String,String> getPickList(String objectName, String fieldName) {
        
        Map<String,String> fieldLabelAndValueMap = new Map<String,String>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            fieldLabelAndValueMap.put(pickListVal.getLabel(), pickListVal.getValue());
            
        }  
        
        return  fieldLabelAndValueMap;
        
    }
    
    
    
    
    
    
    private static List<String> one = new List<String>();
    private static List<String> ten = new List<String>();
    
    public static String getNumberToWords(Decimal n) {
        
        one.add('');
        one.add('One ');
        one.add('Two ');
        one.add('Three ');
        one.add('Four ');
        one.add('Five ');
        one.add('Six ');
        one.add('Seven ');
        one.add('Eight ');
        one.add('Nine ');
        one.add('Ten ');
        one.add('Eleven ');
        one.add('Twelve ');
        one.add('Thirteen ');
        one.add('Fourteen ');
        one.add('Fifteen ');
        one.add('Sixteen ');
        one.add('Seventeen ');
        one.add('Eighteen ');
        one.add('Nineteen ');
        
        ten.add('');
        ten.add('');
        ten.add('Twenty ');
        ten.add('Thirty ');
        ten.add('Forty ');
        ten.add('Fifty ');
        ten.add('Sixty ');
        ten.add('Seventy ');
        ten.add('Eighty ');
        ten.add('Ninety ');
        
        
        String out = '';
        
        out += numToWords((Integer)(n / 10000000), 'Crore ');
        out += numToWords((Integer)(math.mod((Integer)(n / 100000), 100)), 'Lakh ');
        out += numToWords((Integer)(math.mod((Integer)(n / 1000), 100)), 'Thousand ');
        out += numToWords((Integer)(math.mod((Integer)(n / 100), 10)), 'Hundred ');
        if (n > 100 && math.mod((Integer)n, 100) > 0) {
            out += 'And ';
        }
        out += numToWords((Integer)(math.mod((Integer)n, 100)), '');
        out += ' Rupees';
        return out;
    }
    
    private static String numToWords(Integer n, String s) {
        String str = '';
        if (n > 19) {
            str += ten[n / 10] + one[math.mod(n, 10)];
        } else {
            str += one[n];
        }
        
        if (n != 0) {
            str += s;
        }
        return str;
    }
    
    
    
    
    
    private static final String zero = 'Zero';
    private static List<String> oneToNine = new List<String>(); 
    private static List<String> tenToNinteen = new List<String>(); 
    private static List<String> dozens = new List<String>();
    private static Boolean isFirstTime = true;
    
    public static String getNumberToWordsLongNumber(Decimal num) {
        if(isFirstTime) {
            isFirstTime = !isFirstTime;
            
            oneToNine.add('One ');
            oneToNine.add('Two ');
            oneToNine.add('Three ');
            oneToNine.add('Four ');
            oneToNine.add('Five ');
            oneToNine.add('Six ');
            oneToNine.add('Seven ');
            oneToNine.add('Eight ');
            oneToNine.add('Nine ');
            
            tenToNinteen.add('Ten ');
            tenToNinteen.add('Eleven ');
            tenToNinteen.add('Twelve ');
            tenToNinteen.add('Thirteen ');
            tenToNinteen.add('Fourteen ');
            tenToNinteen.add('Fifteen ');
            tenToNinteen.add('Sixteen ');
            tenToNinteen.add('Seventeen ');
            tenToNinteen.add('Eighteen ');
            tenToNinteen.add('Nineteen ');
            
            dozens.add('Ten ');
            dozens.add('Twenty ');
            dozens.add('Thirty ');
            dozens.add('Forty ');
            dozens.add('Fifty ');
            dozens.add('Sixty ');
            dozens.add('Seventy ');
            dozens.add('Eighty ');
            dozens.add('Ninety ');
        }
        
        if(num >= 1000000000000000L) { return getNumberToWordsLongNumber(num / 1000000000000000L) + ' Padma ' + getNumberToWordsLongNumber(Math.mod((Long)num, 1000000000000000L));
            
        } else if(num >= 10000000000000L) {  return getNumberToWordsLongNumber(num / 10000000000000L) + ' Neel ' + getNumberToWordsLongNumber(Math.mod((Long)num, 10000000000000L));
           
        } else if(num >= 100000000000L) {
            return getNumberToWordsLongNumber(num / 100000000000L) + ' Kharab ' + getNumberToWordsLongNumber(Math.mod((Long)num, 100000000000L));
        } else if(num >= 1000000000) {
            return getNumberToWordsLongNumber(num / 1000000000) + ' Arab ' + getNumberToWordsLongNumber(Math.mod((Long)num, 1000000000));
        } else if(num >= 10000000) {
            return getNumberToWordsLongNumber(num / 10000000) + ' Crore ' + getNumberToWordsLongNumber(Math.mod((Long)num, 10000000));
        } else if(num >= 100000) {
            return getNumberToWordsLongNumber(num / 100000) + ' Lakh ' + getNumberToWordsLongNumber(Math.mod((Long)num, 100000));
        } else if(num >= 1000) {
            return getNumberToWordsLongNumber(num / 1000) + ' Thousand ' + getNumberToWordsLongNumber(Math.mod((Long)num, 1000));
        } else if(num >= 100) {
            return getNumberToWordsLongNumber(num / 100) + ' Hundred ' + getNumberToWordsLongNumber(Math.mod((Long)num, 100));
        }
        
        return generate1To99((Integer)num);
    }
    
    private static String generate1To99(Integer num) {
        if (num == 0)
            return '';
        
        if (num <= 9)
            return oneToNine[num - 1];
        else if (num <= 19)  return tenToNinteen[Math.mod(num, 10)];
           
        else
            return dozens[num / 10 - 1] + ' ' + generate1To99(Math.mod(num, 10));
    }
    
}