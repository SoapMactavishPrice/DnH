trigger ContactAddCountryCode on Contact (before insert, before update) {
    for (Contact con : Trigger.new) {

        if (String.isBlank(con.MC_Mobile_No__c) && String.isNotBlank(con.MobilePhone)) {
            con.MC_Mobile_No__c = con.MobilePhone;
        }

        if (
            String.isNotBlank(con.MC_Mobile_No__c) &&
            con.Digits__c != null &&
            String.isNotBlank(con.Country_Code__c)
        ) {
            String mobile = con.MC_Mobile_No__c.replaceAll('[^0-9]', '');
            Integer digits = Integer.valueOf(con.Digits__c);

            if (mobile.length() >= digits) {
                mobile = mobile.substring(mobile.length() - digits);
                con.MC_Mobile_No__c = con.Country_Code__c + mobile;
            } else {
                con.MC_Mobile_No__c = null;
            }
        }
    }
}
