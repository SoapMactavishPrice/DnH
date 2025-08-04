import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from "lightning/navigation";

import getcodemaster from "@salesforce/apex/Addservice19CustomerComplaints.getcodemaster";
import getInvoiceList from "@salesforce/apex/Ser19_GetInvoice.getInvoiceList";
import getInvoiceLineList from "@salesforce/apex/Ser19_GetInvoice.getInvoiceLineList";
import getInvoiceLotList from "@salesforce/apex/Ser19_GetInvoice.getInvoiceLotList";
import addAttachment from "@salesforce/apex/Ser19_GetInvoice.addAttachment";
import getIds from "@salesforce/apex/Ser19_GetInvoice.getIds";
import closeReopenComplainttoNAV from "@salesforce/apex/Ser19_GetInvoice.closeReopenComplainttoNAV";
import insertComplainttoNAV from "@salesforce/apex/InsertCustomerComplaint_ToNAV.insertComplaint";

import { getRecord } from 'lightning/uiRecordApi';
import Is_Created_To_NAV from '@salesforce/schema/Customer_Complaint__c.Is_Created_To_NAV__c';
import Is_Created_To_TSD from '@salesforce/schema/Customer_Complaint__c.Is_Created_To_TSD__c';

export default class CreateService19LWC extends NavigationMixin(LightningElement){

    @track disabledFieldFlag = false;
    @track showSpinner = true;
    @track showSpinner2 = false;
    @api recordId = '';
    @api recordName = '';
    @track customerComplaintId = '';
    @track isCreatedToNAV;
    @track isCreatedToTSD;
    @track showActionButtons = true;

    @track proceedBtnFlag = true; // Temporary false
    @track isModalOpen = true;
    @track fromDateValue = '';
    @track toDateValue = '';
    @track invoiceNumberValue = '';
    @track invoiceLineValue = '';
    @track invoiceLotValue = '';
    @track invoiceList = [];
    @track selectedInvoiceData = {};
    @track InvoiceOptions = [];
    @track invoiceLineList = [];
    @track selectedInvoiceLineData = {};
    @track InvoiceLineOptions = [];
    @track invoiceLotList = [];
    @track selectedInvoiceLotData = {};
    @track InvoiceLotOptions = [];

    @track FieldEngineer_Value = '';
    @track ZonalManager_Value = '';
    @track AreaManager_Value = '';
    @track Customer_Value = '';

    @track salesLIVariantValue = '';
    @track salesLIVariant_Options = [];
    @track selectedBatchValue = '';
    @track selectBatch_Options = [];

    @track objectname = 'Service 19-(Customer Complaint)';
    @track codeMasterData = []; // To store the processed results
    @track displayLabel;

    @track doc_MainFileArray = [];
    @track doc_MainFile;
    @track doc_MainFileName;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('OUTPUT : ', JSON.stringify(currentPageReference.state));
            if (currentPageReference.state.c__ser19Id != null && currentPageReference.state.c__ser19Id != undefined) {
                this.recordId = currentPageReference.state.c__ser19Id;
            }
            if (currentPageReference.state.c__ser19Name != null && currentPageReference.state.c__ser19Name != undefined) {
                this.recordName = currentPageReference.state.c__ser19Name;
            }
        }
    }

    // Use @wire to get the record data
    @wire(getRecord, { recordId: '$recordId', fields: [Is_Created_To_NAV, Is_Created_To_TSD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.isCreatedToNAV = data.fields.Is_Created_To_NAV__c.value;
            this.isCreatedToTSD = data.fields.Is_Created_To_TSD__c.value;
            if (this.isCreatedToNAV && this.isCreatedToTSD) {
                this.showActionButtons = false;
                this.disabledFieldFlag = true;
            } else {
                // this.disabledFieldFlag = false;
            }

            this.isModalOpen = false;
            this.showSpinner = false;
        } else if (error) {
            console.error('Error retrieving record', error);
        }
    }

    showToast(toastTitle, toastMsg, toastType) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMsg,
            variant: toastType,
            // mode: "dismissable"
        });
        this.dispatchEvent(event);
    }


    get modalContainerClass() {
        // Detect screen size
        if (window.innerWidth <= 768) {
            // Mobile view
            this.showSpinner = false;
            return 'slds-modal__container';
        } else {
            // Desktop view with additional styles
            return 'slds-modal__container custom-modal-width';
        }
    }

    connectedCallback() {
        // this.handlerCloseAddService19();
        if (this.recordId != '') {
            // this.isModalOpen = false;
            // this.showSpinner = false;
            // this.disabledFieldFlag = true;
        } else {
            this.getcodemaster();
        }
        window.addEventListener('resize', this.updateModalClass.bind(this));
    }
    disconnectedCallback() {
        window.removeEventListener('resize', this.updateModalClass.bind(this));
    }

    updateModalClass() {
        this.modalContainerClass; // Trigger re-evaluation on resize
    }
    getcodemaster() {
        getcodemaster({ objectname: this.objectname })
            .then(result => {
                console.log('displayLabel result:', result);

                // No need to parse if result is already an object
                if (result) {
                    //this.displayLabel = result.Display_Label__c; // Access Display_Label__c directly
                    this.displayLabel = result; // Store the entire result if needed


                } else {
                    this.showToast('Error', 'No data received', 'error');
                }
            })
            .catch(error => {
                console.error('Error in getcodemaster:', error);
                this.showToast('Error', 'Failed to fetch data', 'error');
            });
    }

    handlerCloseAddService19() {
        this.isModalOpen = false;
        this.showSpinner = false;
    }

    handlerOnProceedClick() {
        this.handlerCloseAddService19();
    }

    handleFileUploaded1(event) {
        // this.doc_MainFileArray = [];
        // this.doc_MainFile = '';
        // this.doc_MainFileName = '';
        console.log(event.target.files[0].size);
        console.log(event.target.files.length);

        // if (event.target.files.length > 0 && event.target.files[0].size < 3 * 1024 * 1024) {
        let files = [];
        for (var i = 0; i < event.target.files.length; i++) {
            let file = event.target.files[i];
            let reader = new FileReader();
            reader.onload = e => {
                let base64 = 'base64,';
                let content = reader.result.indexOf(base64) + base64.length;
                let fileContents = reader.result.substring(content);
                let text = file.name;
                // let myArray = text.split(".");
                // let titleTemp = 'Original Student receipt.' + myArray[myArray.length - 1];
                // this.doc_MainFileName = text;
                // this.doc_MainFile = { PathOnClient: file.name, Title: text, VersionData: fileContents };
                this.doc_MainFileArray.push(
                    {
                        doc_MainFileName: text,
                        doc_MainFile: JSON.stringify({ PathOnClient: file.name, Title: text, VersionData: fileContents })
                    }
                );
            };
            reader.readAsDataURL(file);
        }
        // } else {
        //     this.showToast('Error', '', 'File size should be less than 3MB');
        // }
    }

    handlerComplaintQtyChange(event) {
        let tempCQ = parseFloat(event.target.value);
        let compQfield = this.template.querySelector('[data-id="complaintQTY"]');

        if (this.selectedInvoiceLotData.BatchQuantity < tempCQ) {
            this.showToast('Complaint Qty cannot be greater then Batch Qty', '', 'error');
            compQfield.value = null;
        }

    }


    handleComplaintSubmit(event) {
        console.log(event.currentTarget.dataset.btnname);

        this.showSpinner = true;
        event.preventDefault();
        this.buttonName = event.currentTarget.dataset.btnname;
        const lwcInputFields = this.template.querySelectorAll('lightning-input-field');
        console.log('lwcInputFields', lwcInputFields);
        let validationFlag = false;

        if (lwcInputFields) {

            lwcInputFields.forEach(field => {
                if (field.fieldName == 'EndCustomerName__c') {
                    if (field.value == null || field.value == '') {
                        validationFlag = true;
                        // emptyFieldName = 'LR Destination';
                    }
                } else if (field.fieldName == 'Complaint_Quantity__c') {
                    if (field.value == null || field.value == '') {
                        validationFlag = true;
                        // emptyFieldName = 'LR Destination';
                    }
                } else if (field.fieldName == 'Type_Of_Complaints__c') {
                    if (field.value == null || field.value == '') {
                        validationFlag = true;
                        // emptyFieldName = 'LR Destination';
                    }
                } else if (field.fieldName == 'Entry_Type__c') {
                    if (field.value == null || field.value == '') {
                        validationFlag = true;
                        // emptyFieldName = 'LR Destination';
                    }
                } else if (field.fieldName == 'Field_Engineer_Remarks__c') {
                    if (field.value == null || field.value == '') {
                        validationFlag = true;
                        // emptyFieldName = 'LR Destination';
                    }
                }
                field.reportValidity();
            });

            if (validationFlag) {
                console.log('validation flag trigger');
                // Optionally show a toast message for validation errors
                this.showSpinner = false;
                this.showToast('error', 'Please fill all required fields!!!', 'error');
            } else {
                const form1 = this.template.querySelector('lightning-record-edit-form[data-id="form1"]');

                if (this.buttonName == 'closebtn' || this.buttonName == 'reopenbtn') {
                    const fieldInput = this.template.querySelector('.SalesPersonConfirmation');
                    if (!fieldInput.value) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: 'Sales Person Confirmation Cannot be empty',
                                variant: 'error',
                            })
                        );
                        this.showSpinner = false;
                    } else {
                        form1.submit();
                    }


                } else {

                    const fields = {};
                    // fields.Type_Of_Complaints__c = '01';
                    // fields.Entry_Type__c = '0';
                    fields.Status__c = 'Submitted';
                    fields.Submitted_By__c = this.selectedInvoiceData.FieldEngineer;
                    fields.Inserted_By__c = this.selectedInvoiceData.FieldEngineer;
                    fields.IsSubmitted__c = '2';
                    fields.Entry_Type__c = '0';
                    const now = new Date();
                    const formattedDateTime = now.toISOString();
                    fields.Submitted_Date__c = formattedDateTime;

                    lwcInputFields.forEach(field => {
                        fields[field.fieldName] = field.value;
                    });

                    form1.submit(fields);
                }


            }
        }

    }

    handleComplaintError(event) {
        console.error('Error details:', JSON.stringify(event.detail, null, 2));

        // Extract specific error messages
        if (event.detail && event.detail.output && event.detail.output.errors) {
            const errors = event.detail.output.errors;
            errors.forEach(error => {
                console.error('Error message:', error.message);
            });
        }

        if (event.detail && event.detail.output && event.detail.output.fieldErrors) {
            const fieldErrors = event.detail.output.fieldErrors;
            Object.keys(fieldErrors).forEach(fieldName => {
                fieldErrors[fieldName].forEach(error => {
                    console.error(`Field error on ${fieldName}:`, error.message);
                });
            });
        }

        // Optionally show the error in a toast message
        this.showToast('Error', 'Record creation failed. Check console for details.', 'error');
        this.showSpinner = false;
    }


    handleComplaintSuccess(event) {
        // this.showSpinner = false;
        const updatedRecordId = event.detail.id;
        console.log('Record saved successfully:', updatedRecordId);

        if (this.buttonName == 'closebtn' || this.buttonName == 'reopenbtn') {
            this.handleSyncCloseReopenComplaint(updatedRecordId);
        } else {

            if (this.doc_MainFileArray.length > 0) {
                this.handleSaveAttachments(updatedRecordId);
            } else {
                this.handleAfterCheckAttachment(updatedRecordId);
            }

        }
    }

    handleSaveAttachments(para) {
        let isDone = true;
        // let lastElement = this.doc_MainFileArray[this.doc_MainFileArray.length - 1];

        this.showToast('Please wait, Attachment is uploading...', '', 'info');

        let promises = this.doc_MainFileArray.map(el => {
            return addAttachment({
                Id: para, filedata: el.doc_MainFile
            }).catch(error => {
                console.error('Error:', error);
            });
        });

        // Wait for all insertions to complete
        Promise.all(promises)
            .then(() => {
                this.showToast('Success', 'All Attachment inserted successfully!', 'success');
                this.handleAfterCheckAttachment(para);
            }).catch(error => {
                this.showToast('Error', 'Error inserting attachment', 'error');
                console.log('ERROR IN ALL PROMISE::', error);

            });
    }

    handleAfterCheckAttachment(para) {
        if (this.buttonName == 'draftbtn') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Service 19 created as Draft',
                    variant: 'success',
                })
            );
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: para,
                    objectApiName: 'Customer_Complaint__c',
                    actionName: 'view'
                }
            });
        } else if (this.buttonName == 'submitbtn') {
            new Promise((resolve, reject) => {
                insertComplainttoNAV({
                    SoId: para
                }).then((result) => {
                    console.log('insertComplainttoNAV:>>> ', result);
                    resolve();
                }).catch((error) => {
                    console.log(error);
                    this.showSpinner = false;
                })
            }).then(() => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Service 19 created successfully',
                        variant: 'success',
                    })
                );
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: para,
                        objectApiName: 'Customer_Complaint__c',
                        actionName: 'view'
                    }
                });
            })
        }
    }

    handleSyncCloseReopenComplaint(recId) {
        new Promise((resolve, reject) => {

            closeReopenComplainttoNAV({
                invno: this.recordName,
                actiontype: this.buttonName
            }).then((result) => {

                console.log('closeReopenComplainttoNAV:>>> ', result);
                resolve();
            }).catch((error) => {

                console.log(error);
                this.showSpinner = false;
            })

        }).then(() => {
            this.showSpinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Success',
                    variant: 'success',
                })
            );
            // window.location.reload();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recId,
                    objectApiName: 'Customer_Complaint__c',
                    actionName: 'view'
                }
            });
        })
    }

    handleClick() {
        if (window.innerWidth >= 768) {
            // Navigate to the Enquiry list view
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Customer_Complaint__c',
                    actionName: 'list'
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Customer_Complaint__c',
                    actionName: 'home',
                },
            });
        }
    }

    handlerDateChange(event) {
        // Get the raw date value from the input
        const rawDate = event.target.value;

        // Ensure it's in the 'yyyy-mm-dd' format
        const date = new Date(rawDate);
        const yyyy = date.getFullYear();
        const mm = String(date.getMonth() + 1).padStart(2, '0'); // Months are zero-based
        const dd = String(date.getDate()).padStart(2, '0');

        let formattedDate = `${yyyy}-${mm}-${dd}`;
        if (event.target.name == 'fromdate') {
            this.fromDateValue = formattedDate;
        }
        if (event.target.name == 'todate') {
            this.toDateValue = formattedDate;
        }
    }

    handlerSearchInvoice() {
        this.showSpinner2 = true;
        new Promise((resolve, reject) => {
            getInvoiceList({
                startdate: this.fromDateValue,
                enddate: this.toDateValue
            }).then((result) => {
                console.log('getInvoiceList:>>> ', result);
                this.invoiceList = JSON.parse(result);
                let temparr = [];
                this.invoiceList.forEach(ele => {
                    let obj = {
                        label: ele.DocNo,
                        value: ele.DocNo
                    };
                    temparr.push(obj);
                });
                console.log(temparr);

                this.InvoiceOptions = temparr;
                console.log(this.InvoiceOptions);
                resolve();
            }).catch((error) => {
                console.log('getInvoiceList error:>> ', error);
                this.showSpinner2 = false;
            })
        }).then(() => {
            this.showSpinner2 = false;
        })
    }

    handlerInvoiceChange(event) {
        this.showSpinner2 = true;
        this.invoiceNumberValue = event.target.value;
        this.selectedInvoiceData = this.invoiceList.find(element => element.DocNo == this.invoiceNumberValue);
        let sdate = this.selectedInvoiceData.InvoiceDate;
        this.selectedInvoiceData.InvoiceDate = sdate.replaceAll('/', '-');
        new Promise((resolve, reject) => {
            getInvoiceLineList({
                invNo: this.invoiceNumberValue
            }).then((result) => {
                console.log('getInvoiceLineList:>>> ', result);
                this.invoiceLineList = JSON.parse(result);
                let temparr = [];
                this.invoiceLineList.forEach(ele => {
                    let obj = {
                        label: ele.Description,
                        value: ele.ItemNo
                    };
                    temparr.push(obj);
                });
                console.log(temparr);

                this.InvoiceLineOptions = temparr;
                console.log(this.InvoiceLineOptions);
                resolve();
            }).catch((error) => {
                console.log('getInvoiceLineList error:>> ', error);
                this.showSpinner2 = false;
            })
        }).then(() => {
            this.showSpinner2 = false;
            this.handlerGetSalesPersonIds();
        })
    }

    handlerGetSalesPersonIds() {
        new Promise((resolve, reject) => {
            getIds({
                fs: this.selectedInvoiceData.FieldEngineer,
                am: this.selectedInvoiceData.AreaManager,
                zm: this.selectedInvoiceData.ZonalManager,
                cn: this.selectedInvoiceData.CustomerNo,
            }).then((result) => {
                console.log('getIds:::> ', result);
                let data = result.split(',');
                this.FieldEngineer_Value = data[0];
                this.ZonalManager_Value = data[2];
                this.AreaManager_Value = data[1];
                this.Customer_Value = data[3];
                resolve('Success');
            }).catch((error) => {
                let errorMessage = 'An error occurred';
                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast(errorMessage, '', 'error');
            });
        }).then(() => {

        })
    }

    handlerInvoiceLineChange(event) {
        this.showSpinner2 = true;
        this.invoiceLineValue = event.target.value;
        console.log(this.invoiceLineValue);
        this.selectedInvoiceLineData = this.invoiceLineList.find(element => element.ItemNo == this.invoiceLineValue);
        let str = this.selectedInvoiceLineData.LineNo;
        this.selectedInvoiceLineData.LineNo = str + '';

        new Promise((resolve, reject) => {
            getInvoiceLotList({
                invNo: this.selectedInvoiceLineData.DocNo,
                itemNo: this.selectedInvoiceLineData.ItemNo,
                lineNo: this.selectedInvoiceLineData.LineNo
            }).then((result) => {
                console.log('getInvoiceLotList:>>> ', result);
                this.invoiceLotList = JSON.parse(result);
                let temparr = [];
                this.invoiceLotList.forEach(ele => {
                    let obj = {
                        label: ele.LotNo,
                        value: ele.LotNo
                    };
                    temparr.push(obj);
                });
                console.log(temparr);

                this.InvoiceLotOptions = temparr;
                console.log(this.InvoiceLotOptions);
                resolve();
            }).catch((error) => {
                console.log('getInvoiceLotList error:>> ', error);
                this.showSpinner2 = false;
            })
        }).then(() => {
            this.showSpinner2 = false;
        })
    }

    handlerInvoiceLotChange(event) {
        this.invoiceLotValue = event.target.value;
        this.selectedInvoiceLotData = this.invoiceLotList.find(element => element.LotNo == this.invoiceLotValue);
        let sdate = this.selectedInvoiceLotData.MfgDate;
        this.selectedInvoiceLotData.MfgDate = sdate.replaceAll('/', '-');
        this.proceedBtnFlag = false;
    }

}