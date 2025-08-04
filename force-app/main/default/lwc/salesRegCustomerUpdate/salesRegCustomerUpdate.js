import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCurrentActiveFY from "@salesforce/apex/SalesRegCustomerUpdateCtrl.getCurrentActiveFY";
import getSalesRegisterData from "@salesforce/apex/SalesRegCustomerUpdateCtrl.getSalesRegisterData";
import updateSalesRegisters from "@salesforce/apex/SalesRegCustomerUpdateCtrl.updateSalesRegisters";

export default class SalesRegCustomerUpdate extends LightningElement {
    @track currentFiscalYearName = '';
    @track currentFiscalYearValue = '';
    @track monthValue = '';
    @track salesRegisterObjects = [];

    monthOptions = [
        { label: 'March', value: 'March' },
        { label: 'April', value: 'April' },
        { label: 'May', value: 'May' },
        { label: 'June', value: 'June' },
        { label: 'July', value: 'July' },
        { label: 'August', value: 'August' },
        { label: 'September', value: 'September' },
        { label: 'October', value: 'October' },
        { label: 'November', value: 'November' },
        { label: 'December', value: 'December' },
        { label: 'January', value: 'January' },
        { label: 'February', value: 'February' }
    ];

    get srdFlag() {
        return this.salesRegisterObjects.length > 0;
    }

    connectedCallback() {
        this.handlerGetCurrentActiveFY();
    }

    handlerGetCurrentActiveFY() {
        getCurrentActiveFY()
            .then(result => {
                let data = JSON.parse(result);
                this.currentFiscalYearName = data.Name;
                this.currentFiscalYearValue = data.id;
            })
            .catch(error => {
                this.showError(error);
            });
    }

    handleMonthChange(event) {
        this.monthValue = event.target.value;
        this.handleGetData();
    }

    handleGetData() {
        getSalesRegisterData({
            fyId: this.currentFiscalYearValue,
            month: this.monthValue
        })
            .then(result => {
                console.log('getSalesRegisterData result ->', result);
                this.salesRegisterObjects = result;
            })
            .catch(error => {
                this.showError(error);
            });
    }

    addLineItem(event) {
        let parentId = event.target.dataset.parent;
        console.log('parentId -->', parentId);
        let specificParentData = this.salesRegisterObjects.find(salesRegister => salesRegister.id === parentId);
        console.log(' before line Item specificParentData -->', JSON.parse(JSON.stringify(specificParentData)));
        if (!specificParentData.lineItems) {
            specificParentData.lineItems = [];
        }
        specificParentData.lineItems.push({
            tempId: Date.now().toString() + Math.random().toString(16).slice(2),
            id: '',
            endCustomer: '',
            netInvoiceValue: '',
            quantity: 0
        })

        console.log(' after line Item specificParentData -->', JSON.parse(JSON.stringify(specificParentData)));

        console.log('this.salesRegisterObjects', JSON.parse(JSON.stringify(this.salesRegisterObjects)));
    }

    handleAccountChange(event) {
        const salesRegId = event.detail.rowid;
        const custId = event.detail.selectedRecordId;

        let draft = this.draftValues.find(d => d.id === salesRegId);
        if (!draft) {
            draft = { id: salesRegId };
            this.draftValues.push(draft);
        }
        draft['End_Customer__c'] = custId;
    }

    handleUpdateSalesRegisters() {
        const parentDrafts = this.draftValues.filter(d => d.End_Customer__c);

        updateSalesRegisters({ recordsToUpdate: parentDrafts })
            .then(result => {
                if (result === 'ok') {
                    this.showToast('Success', 'Records updated successfully', 'success');
                    window.location.reload();
                } else {
                    this.showToast('Error', result, 'error');
                }
            })
            .catch(error => this.showError(error));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    showError(error) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.message,
            variant: 'error'
        }));
    }
}
