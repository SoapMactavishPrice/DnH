import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCurrentActiveFY from "@salesforce/apex/SalesRegCustomerUpdateCtrl.getCurrentActiveFY";
import getSalesRegisterData from "@salesforce/apex/SalesRegCustomerUpdateCtrl.getSalesRegisterData";
import updateSalesRegisters from "@salesforce/apex/SalesRegCustomerUpdateCtrl.updateSalesRegisters";
import saveSalesRegisterLineItem from "@salesforce/apex/SalesRegCustomerUpdateCtrl.saveSalesRegisterLineItem";

export default class SalesRegCustomerUpdate extends LightningElement {
    @track currentFiscalYearName = '';
    @track currentFiscalYearValue = '';
    @track monthValue = '';
    @track isSaveDisabled = false;
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
                console.log('getCurrentActiveFY result ->', data);
                this.currentFiscalYearName = data.Name;
                this.currentFiscalYearValue = data.Id;
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
        console.log('currentFiscalYearValue', this.currentFiscalYearValue);
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

    validateSalesRegisterLineItem(salesRegisterId) {
        let specificParentData = this.salesRegisterObjects.find(salesRegister => salesRegister.id === salesRegisterId);

        if (specificParentData.lineItems != null) {
            for (let eachItem of specificParentData.lineItems) {
                if (!eachItem.endCustomer) {
                    this.showToast('Error', 'Please select a End Customer for Line Item', 'error');
                    return false;
                }

                if (!eachItem.netInvoiceValue || eachItem.netInvoiceValue == 0) {
                    this.showToast('Error', 'Please enter Net Invoice Value for Line Item', 'error');
                    return false;
                }

                if (!eachItem.quantity || eachItem.quantity == 0) {
                    this.showToast('Error', 'Please enter Quantity for Line Item', 'error');
                    return false;
                }
            }
        }
        return true;
    }

    addLineItem(event) {
        let parentId = event.target.dataset.parent;
        console.log('parentId -->', parentId);
        let specificParentData = this.salesRegisterObjects.find(salesRegister => salesRegister.id === parentId);
        console.log(' before line Item specificParentData -->', JSON.parse(JSON.stringify(specificParentData)));
        if (!specificParentData.lineItems) {
            specificParentData.lineItems = [];
        }
        let result = this.validateSalesRegisterLineItem(parentId);
        if (result) {
            specificParentData.lineItems.push({
                tempId: Date.now().toString() + Math.random().toString(16).slice(2),
                id: '',
                endCustomer: '',
                netInvoiceValue: '',
                quantity: 0,
                isNew: true,
                isOld: false
            })
        }

        console.log(' after line Item specificParentData -->', JSON.parse(JSON.stringify(specificParentData)));

        console.log('this.salesRegisterObjects', JSON.parse(JSON.stringify(this.salesRegisterObjects)));
    }

    removeLineItem(event) {
        let tempId = event.target.dataset.tempid;
        let parentId = event.target.dataset.parent;

        let specificParentData = this.salesRegisterObjects.find(salesRegister => salesRegister.id === parentId);

        specificParentData.lineItems = specificParentData.lineItems.filter(lineItem => lineItem.tempId !== tempId);

        if (specificParentData.lineItems.length === 0) {
            delete specificParentData.lineItems;
        }
    }

    handleAccountChange(event) {
        const salesRegId = event.detail.rowid;
        const custId = event.detail.selectedRecordId;

        let tempId = event.detail.tempid;
        
        let specificParentData = this.salesRegisterObjects.find(salesRegister => salesRegister.id === salesRegId);

        let lineItem = specificParentData.lineItems.find(lineItem => lineItem.tempId === tempId);

        lineItem.endCustomer = custId;
    }

    handleLineItemChanges(event) {
        try {
            let field = event.target.dataset.field;
            let salesRegId = event.target.dataset.parent;
            let tempId = event.target.dataset.tempid;

            let value = event.target.value;
    
            let specificParentData = this.salesRegisterObjects.find(salesRegister => salesRegister.id === salesRegId);

            if (field == 'quantity' && specificParentData.rate != null && specificParentData.rate) {
                let rate = specificParentData.rate;

                let lineItem = specificParentData.lineItems.find(lineItem => lineItem.tempId === tempId);
    
                lineItem[field] = value;

                lineItem.netInvoiceValue = value * rate;
            } 
    
            let lineItem = specificParentData.lineItems.find(lineItem => lineItem.tempId === tempId);
    
            lineItem[field] = value;
        } catch (error) {
            console.error('error in handleLineItemChanges', error);
        }
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

    validateSalesRegister() {
        for (let eachSalesRegister of this.salesRegisterObjects) {
            let result = this.validateSalesRegisterLineItem(eachSalesRegister.id);
            if (!result) {
                return false;
            }

            if (eachSalesRegister.lineItems && eachSalesRegister.lineItems.length > 0) {
                let parentNetInvoiceValue = parseFloat(eachSalesRegister.netInvoiceValue);
                console.log('parentNetInvoiceValue', parentNetInvoiceValue);
                let parentQuantity = parseFloat(eachSalesRegister.quantity);
                console.log('parentQuantity', parentQuantity);
                let lineTotalInvoiceValue = 0;
                let lineTotalQuantity = 0;
    
                for (let eachLineItem of eachSalesRegister.lineItems) {
                    lineTotalInvoiceValue += parseFloat(eachLineItem.netInvoiceValue);
                    lineTotalQuantity += parseFloat(eachLineItem.quantity);
                }

                console.log('lineTotalInvoiceValue' ,lineTotalInvoiceValue);
                console.log('lineTotalQuantity' ,lineTotalQuantity);
    
                // if (lineTotalInvoiceValue > parentNetInvoiceValue) {
                //     this.showToast('Error', 'Sales Register Line Total Invoice Value cannot be greater than Sales Register Invoice Value - ' + eachSalesRegister.salesOrderNo, 'error');
                //     return false;
                // }
    
                if (lineTotalQuantity > parentQuantity) {
                    this.showToast('Error', 'Sales Register Line Total Quantity cannot be greater than Sales Register Quantity - ' + eachSalesRegister.salesOrderNo, 'error');
                    return false;
                }
            }


        }

        return true;
    }

    saveLineItem() {
        this.isSaveDisabled = true;

        let result = this.validateSalesRegister();

        console.log('final Save Data', JSON.parse(JSON.stringify(this.salesRegisterObjects)));

        if (result) {
            saveSalesRegisterLineItem({salesRegisterStringObj: JSON.stringify(this.salesRegisterObjects)})
                .then((result)=>{
                    if (result == 'Success') {
                        this.showToast('Success', 'Saved Successfully', 'success');
    
                        setTimeout(()=>{
                            window.location.reload();
                        }, 1500)
                    }
                }).catch((error)=>{
                    this.isSaveDisabled = false;
                    this.showError(error);
                })
        } else {
            this.isSaveDisabled = false;
        }

    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    showError(error) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.body.message,
            variant: 'error'
        }));
    }
}