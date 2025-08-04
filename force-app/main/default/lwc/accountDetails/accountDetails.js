import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import fetchData from '@salesforce/apex/AccDetails.fetchData';
import Available_Credit_Limit__c from '@salesforce/schema/Account.Available_Credit_Limit__c';
import Open_Orders__c from '@salesforce/schema/Account.Open_Orders__c';
import Payment_Received__c from '@salesforce/schema/Account.Payment_Received__c';
import Outstanding_Invoices__c from '@salesforce/schema/Account.Outstanding_Invoices__c';

export default class AccountDetails extends LightningElement {
    @api recordId;
    @track account;
    @track taskCount = 0;
    @track eventCount = 0;
    @track salesOrderCount = 0;
    @track enquiryCount = 0;
    @track daysSinceLastOrder = 0;
    @track count = 0;
    error;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [Available_Credit_Limit__c, Open_Orders__c, Payment_Received__c, Outstanding_Invoices__c]
    })
    account;

    get Available_Credit_Limit__c() {
        return getFieldValue(this.account.data, Available_Credit_Limit__c);
    }

    get Open_Orders__c() {
        return getFieldValue(this.account.data, Open_Orders__c);
    }

    get Payment_Received__c() {
        return getFieldValue(this.account.data, Payment_Received__c);
    }

    get Outstanding_Invoices__c() {
        return getFieldValue(this.account.data, Outstanding_Invoices__c);
    }


    connectedCallback() {
        this.loadData();
    }

    loadData() {
        fetchData({ accID: this.recordId })
            .then(result => {
                this.account = result.account;
                this.taskCount = result.taskCount;
                this.eventCount = result.eventCount;
                this.salesOrderCount = result.salesOrderCount;
                this.enquiryCount = result.enquiryCount;
                this.daysSinceLastOrder = result.daysSinceLastOrder;


                this.updateCount();
            })
            .catch(error => {
                console.error('Error fetching data:', error);
                this.error = error;
            });
    }

    updateCount() {

        this.count = parseInt(this.taskCount, 10) + parseInt(this.eventCount, 10);
    }
}