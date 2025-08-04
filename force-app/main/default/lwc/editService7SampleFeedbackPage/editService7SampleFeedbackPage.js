import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import AddService7SampleFeedback from "@salesforce/apex/AddService7SampleFeedback.AddService7SampleFeedback";
import createService7ToTSD from "@salesforce/apex/Service7_ToTSD.createService7ToTSD";
import addAttachment from "@salesforce/apex/Ser19_GetInvoice.addAttachment";

import { getRecord } from 'lightning/uiRecordApi';
import IS_UPDATE_RECEIVED_DONE from '@salesforce/schema/Service_7_Sample_Feedbacks__c.Is_Update_Received_Done__c';
//import { NavigationMixin } from 'lightning/navigation';

const FIELDS = [IS_UPDATE_RECEIVED_DONE];

export default class EditService7SampleFeedbackPage extends NavigationMixin(LightningElement) {
    @track mainContent = true;
    @track showSpinner = false;
    @track ResponseMessage = '';
    @track errorResponseMessage = '';
    @track doc_MainFile;
    @track doc_MainFileName;
    @track doc_MainFileArray = [];
    @track doc_AddItemFileName;
    @api recordId;

    isUpdateReceivedDone;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.param1 = currentPageReference.state.c__param1;
            console.log('RecordId', this.param1);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.isUpdateReceivedDone = data.fields.Is_Update_Received_Done__c.value;
            console.log('Checkbox Value isUpdateReceivedDone:', this.isUpdateReceivedDone);
        } else if (error) {
            console.error('Error retrieving record:', error);
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

    connectedCallback() {
        console.log('RecordId>>>>>>>', this.recordId);
    }

    handleMainFileUpload(event) {
        // this.doc_MainFile = null;
        // this.doc_MainFileName = '';
        console.log(event.target.files[0].size);

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
        // }
        // } else {
        // this.showToast('Error', '', 'File size should be less than 3MB');
        // }
    }

    handleWorkDetailSubmit(event) {
        console.log(' handleWorkDetailSubmit called');
        this.showSpinner = true;
        event.preventDefault();
        // const fields = event.detail.fields;
        const lwcInputFields = this.template.querySelectorAll('lightning-input-field');
        let validationflag = false;
        console.log('Form submission initiated:', lwcInputFields);
        if (validationflag) {
            // this.showToast('error', 'Please fill all required fields!!!', 'error');
        } else {
            const form1 = this.template.querySelector('lightning-record-edit-form[data-id="form1"]');
            form1.submit();
        }

        // this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleWorkDetailError(event) {
        this.showSpinner = false;
        console.error('Error saving record:', event.detail.message);
        this.showToast('Error saving record: ' + event.detail.message, '', 'error');
    }

    handleWorkDetailSuccess(event) {
        console.log(' handleWorkDetailSuccess called');
        // this.showSpinner = false;
        const updatedRecordId = event.detail.id;
        console.log('Record saved successfully:', this.doc_MainFileArray);

        if (this.doc_MainFileArray.length > 0) {
            this.showToast('Please wait, Attachment is uploading...', '', 'info');
            let promises = this.doc_MainFileArray.map(el => {
                return addAttachment({
                    Id: updatedRecordId, filedata: el.doc_MainFile
                }).catch(error => {
                    console.error('Error in addAttachment:', error);
                });
            });

            // Wait for all insertions to complete
            Promise.all(promises).then(() => {
                this.showToast('All Attachment inserted successfully!', '', 'success');
                this.handleAfterCheckAttachment(updatedRecordId);
            }).catch(error => {
                this.showToast('Error', 'Error inserting attachment', 'error');
                console.log('ERROR IN ALL PROMISE::', error);
            });
        } else {
            this.handleAfterCheckAttachment(updatedRecordId);
        }
    }

    handleAfterCheckAttachment(para) {
        AddService7SampleFeedback({
            Id: para,
            mdoc: ''
        }).then((result) => {
            console.log('AddService7SampleFeedback result:>>> ', result);
            this.mainContent = false;
            if (result == '1') {
                this.handlerSendToTSD(para);
            } else {
                this.showSpinner = false;
                this.errorResponseMessage = result;
                this.showToast('Something Went Wrong!!!', '', 'error');
            }
        }).catch((error) => {
            console.log('error:>>> ', error);
            this.showToast('Error: ' + error, '', 'error');
            this.showSpinner = false;
        });

    }

    handlerSendToTSD(para) {
        createService7ToTSD({
            SoId: para
        }).then((result) => {
            console.log('createService7ToTSD result:>>> ', result);
            this.mainContent = false;
            if (result == '1') {
                this.showToast('Service 7 details has been saved ' + para, '', 'success');
                setTimeout(() => {
                    this.showSpinner = false;
                    this.ResponseMessage = result;
                    // this.closeModal();
                }, 1000);
            } else {
                this.showSpinner = false;
                this.errorResponseMessage = result;
                this.showToast('Something Went Wrong!!', '', 'error');
            }
        }).catch((error) => {
            console.log('error:>>> ', error);
            this.showToast('Error: ' + error, '', 'error');
            this.showSpinner = false;
        });
    }

    handleMainClick() {
        // Navigate to the Enquiry list view
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Service_7_Sample_Feedbacks__c',
                actionName: 'list'
            }
        });
    }

    closeModal(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
        eval("$A.get('e.force:refreshView').fire();");
    }

}