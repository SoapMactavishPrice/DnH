trigger ContactAddCountryCode on Contact (before insert, before update) {
    for (Contact con : Trigger.new) {

        if (String.isBlank(con.MC_Mobile_No__c) && String.isNotBlank(con.MobilePhone)) {
            con.MC_Mobile_No__c = con.MobilePhone;
        }

        if (String.isNotBlank(con.MC_Mobile_No__c)) {
            String countryCode = String.isNotBlank(con.Country_Code__c) ? con.Country_Code__c : '91';
            Integer digits = con.Digits__c != null ? Integer.valueOf(con.Digits__c) : 10;

            String mobile = con.MC_Mobile_No__c.replaceAll('[^0-9]', '');

            if (mobile.length() >= digits) {
                mobile = mobile.substring(mobile.length() - digits);
                con.MC_Mobile_No__c = countryCode + mobile;
            } else {
                con.MC_Mobile_No__c = null;
            }
        }
    }
}