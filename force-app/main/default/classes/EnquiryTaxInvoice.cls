public with sharing class EnquiryTaxInvoice {
    public List < Enquiry_Line_Item__c > enquiryLineItems {
        get;
        set;
    }
    public Id enquiryId {
        get;
        set;
    }
    public String formattedDate {
        get;
        set;
    }
    public String billingAddress1 {
        get;
        set;
    }

    public EnquiryTaxInvoice() {
        enquiryId = ApexPages.currentPage().getParameters().get('enquiryId');
        // Date today = System.today();
        // formattedDate = today.day().format() + '-' + today.month().format() + '-' + today.year().format();
        Date today = System.today();
        String day = String.valueOf(today.day());
        String month = String.valueOf(today.month());
        String year = String.valueOf(today.year());

        formattedDate = day + '-' + month + '-' + year;

        // if (enquiryId != null) {
        enquiryLineItems = [SELECT Id, Name, Enquiry__c, Size_mm__c, Item_No__c, Qty__c, Specification__c,
            RemainingQty__c, Enquiry__r.Name, Suggested_Private_Price__c, Item_Description__c,
            Remarks__c, BUOM__c, SUOM__c, Enquiry__r.Account__r.Name,Enquiry__r.End_Customer__r.Name,Enquiry__r.Account__c,Enquiry__r.End_Customer__c,
            Enquiry__r.Contact__r.Name, Enquiry__r.Contact__r.MobilePhone, Enquiry__r.Contact__r.Email,
            Enquiry__r.End_Customer__r.BillingStreet,
            Enquiry__r.End_Customer__r.BillingCity,
            Enquiry__r.End_Customer__r.BillingState,
            Enquiry__r.End_Customer__r.BillingPostalCode,
            Enquiry__r.End_Customer__r.BillingCountry,
            Enquiry__r.Account__r.BillingAddress, Enquiry__r.Account__r.BillingStreet, Enquiry__r.Account__r.BillingCity,
            Enquiry__r.Account__r.BillingState, Enquiry__r.Account__r.BillingPostalCode, Enquiry__r.Account__r.BillingCountry,
            Enquiry__r.Delivery_Terms__c, Enquiry__r.GST__c, Item_Master__r.Name, Item_Variant__r.UOM__c, Enquiry__r.Field_Staff_Name__c,
            Enquiry__r.Offer_Validity__c, Enquiry__r.Other_Payment_Terms__c, Item_Master__r.Dim_Size__c,Enquiry__r.Field_Staff_Code__r.Phone,
            Enquiry__r.Inco_Terms__c, Enquiry__r.Supply__c, Enquiry__r.Additional_Information__c,Enquiry__r.Field_Staff_Code__c,
            UMO__c,Rate_INR_USD__c,Rate_In__c,Standard_Packing__c,AWS_Grade__c, Item_Variant__r.Code__c
            FROM Enquiry_Line_Item__c
            //WHERE Enquiry__c = 'a03F300000BoKAkIAN'];
            WHERE Enquiry__c =: enquiryId
        ];

        // Assuming you have a list of Enquiry_Line_Items__c
        for (Enquiry_Line_Item__c enqLineItem: enquiryLineItems) {
            // Fetch related account billing address fields
            Account relatedAccount = enqLineItem.Enquiry__r.Account__r;

            if (relatedAccount != null) {
                String billingAddress = '';
                if (relatedAccount.BillingStreet != null) {
                    billingAddress += relatedAccount.BillingStreet + ', ';
                }
                if (relatedAccount.BillingCity != null) {
                    billingAddress += relatedAccount.BillingCity + ', ';
                }
                if (relatedAccount.BillingState != null) {
                    billingAddress += relatedAccount.BillingState + ', ';
                }
                if (relatedAccount.BillingPostalCode != null) {
                    billingAddress += relatedAccount.BillingPostalCode + ', ';
                }
                if (relatedAccount.BillingCountry != null) {
                    billingAddress += relatedAccount.BillingCountry;
                }

                // Remove trailing comma and space, if any
                if (billingAddress.endsWith(', ')) {
                    billingAddress = billingAddress.substring(0, billingAddress.length() - 2);

                }
                billingAddress1 = billingAddress.replace(', ', ',\n');
                System.debug('Billing Address: ' + billingAddress);
            } else {
                System.debug('No related account found for this enquiry line item.');
            }
        }

        // } else {
        //     enquiryLineItems = new List<Enquiry_Line_Item__c>();
        // }

    }
}