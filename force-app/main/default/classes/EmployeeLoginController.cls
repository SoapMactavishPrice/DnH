public with sharing class EmployeeLoginController {

    @AuraEnabled
    public static Employee_Login__c getEmployeeLoginDetails() {
        String currentUserId = UserInfo.getUserId();

        // Query to fetch Employee_Login__c record for the current user created today
        List < Employee_Login__c > empLoginList = [SELECT Id, Check_In__c, Check_Out__c, Employee__c
            FROM Employee_Login__c
            WHERE CreatedById =: currentUserId
            AND Employee__c =: currentUserId
            AND CreatedDate = TODAY
        ];

        // If the list has a record, return it; otherwise, return null
        if (empLoginList.isEmpty()) {
            return null;
        }

        return empLoginList[0]; // Return the first record if available
    }

    @AuraEnabled
    public static String insertCheckIn() {
        User currentUser = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String userName = currentUser.Name;
        String currentDateTime = System.now().format('yyyy-MM-dd hh:mm a');

        // Query to fetch Employee_Login__c record created today
        List < Employee_Login__c > empLoginList = [SELECT Id, Check_In__c, Employee__c, Check_Out__c, CreatedDate
            FROM Employee_Login__c
            WHERE CreatedById =: currentUser.Id
            AND Employee__c =: currentUser.Id
            AND CreatedDate = TODAY
        ];

        // Check if record exists
        if (empLoginList.size() > 0) {
            throw new AuraHandledException('Check-In already done today');
        } else {
            // Create a new Employee_Login__c record
            Employee_Login__c empLogin = new Employee_Login__c();
            empLogin.Name = userName + ' - ' + currentDateTime;
            empLogin.Employee__c = currentUser.Id;
            empLogin.Check_In__c = System.now();
            insert empLogin;
            return 'Check-In success';
        }

    }

    @AuraEnabled
    public static String updateCheckOut(String recordId) {
        Id currentUserId = UserInfo.getUserId();

        // Query to fetch Employee_Login__c record created today
        List < Employee_Login__c > empLoginList = [SELECT Id, Check_In__c, Employee__c, Check_Out__c, CreatedDate
            FROM Employee_Login__c
            WHERE CreatedById =: currentUserId
            AND Employee__c =: currentUserId
            AND CreatedDate = TODAY
        ];

        // Check if record exists
        if (empLoginList.isEmpty()) {
            throw new AuraHandledException('No record found created today or user not authorized.');
        }

        Employee_Login__c empLogin = empLoginList[0];

        // Proceed to update Check-Out time if the record exists
        if (empLogin.Employee__c == currentUserId) {
            empLogin.Check_Out__c = System.now();
            update empLogin;
            return 'Check-Out Success';
        } else {
            throw new AuraHandledException('User not authorized to update this record.');
        }
    }
}