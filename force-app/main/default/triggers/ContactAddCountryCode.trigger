trigger ContactAddCountryCode on Contact (before insert, before update) {
    for (Contact con : Trigger.new) {

        // --- STEP 1: Sync MC_Mobile_No__c from MobilePhone if blank ---
        if (String.isBlank(con.MC_Mobile_No__c) && String.isNotBlank(con.MobilePhone)) {
            con.MC_Mobile_No__c = con.MobilePhone;
        }

        // --- STEP 2: Clean up number and add 91 prefix using last 10 digits ---
        if (String.isNotBlank(con.MC_Mobile_No__c)) {
            String mobile = con.MC_Mobile_No__c;

            // Remove everything except digits
            mobile = mobile.replaceAll('[^0-9]', '');

            // Only take the last 10 digits if length > 10
            if (mobile.length() > 10) {
                mobile = mobile.substring(mobile.length() - 10);
            }

            // If exactly 10 digits, prefix 91
            if (mobile.length() == 10) {
                con.MC_Mobile_No__c = '91' + mobile;
            } else {
                // If invalid (too short), just keep blank or original as fallback
                con.MC_Mobile_No__c = null;
            }
        }
    }
}