import { LightningElement, track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import AddService7SampleFeedback from "@salesforce/apex/AddService7SampleFeedback.AddService7SampleFeedback";

//import { NavigationMixin } from 'lightning/navigation';

export default class AddService7SampleFeedbackPage extends NavigationMixin(LightningElement) {
    @track showSpinner = false;
    @track doc_MainFile;
    @track doc_MainFileName;
    @track doc_AddItemFileName;
    @api recordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.param1 = currentPageReference.state.c__param1;
            console.log('RecordId', this.param1);
        }
    }
    connectedCallback() {

    }

    handleMainFileUpload(event) {
		this.doc_MainFile = null;
		this.doc_MainFileName = '';
		console.log(event.target.files[0].size);

		// if (event.target.files.length > 0 && event.target.files[0].size < 3 * 1024 * 1024) {
		let files = [];
		// for (var i = 0; i < event.target.files.length; i++) {
		let file = event.target.files[0];
		let reader = new FileReader();
		reader.onload = e => {
			let base64 = 'base64,';
			let content = reader.result.indexOf(base64) + base64.length;
			let fileContents = reader.result.substring(content);
			let text = file.name;
			let myArray = text.split(".");
			let titleTemp = 'Document ' + myArray[myArray.length - 1];
			this.doc_MainFileName = 'Document ' + myArray[myArray.length - 1];
			this.doc_MainFile = { PathOnClient: file.name, Title: titleTemp, VersionData: fileContents };
		};
		reader.readAsDataURL(file);
		// }
		// } else {
		// this.showToast('Error', '', 'File size should be less than 3MB');
		// }
	}
    handleWorkDetailSubmit(event) {
        event.preventDefault(); 
        const fields = event.detail.fields;
        console.log('Form submission initiated:', fields);
        console.log('Record ID on submit:', this.recordId);
        
       // this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

  
    handleWorkDetailSuccess(event) {
        this.showSpinner = true; 
        const updatedRecordId = event.detail.id;
        console.log('Record saved successfully:', updatedRecordId);
        console.log(this.doc_MainFile);
        
        new Promise((resolve, reject) => {
			AddService7SampleFeedback({
				Id: updatedRecordId,
				mdoc: this.doc_MainFile != undefined ? JSON.stringify(this.doc_MainFile) : '',
				
			}).then((result) => {
				console.log('result:>>> ', result);
				resolve(result);
			}).catch((error) => {
				console.log('error:>>> ', error);
				reject(error);
				this.showSpinner = false;
			});
		}).then(() => {
			this.showSpinner = false;
			this.showToast('Record has been saved ' + event.detail.id, '', 'success');
			
		})

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: updatedRecordId,
                objectApiName: 'Service_7_Sample_Feedbacks__c',
                actionName: 'edit'
            }
        });

       
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record saved successfully',
                variant: 'success',
            })
        );
    }

    
    handleWorkDetailError(event) {
        this.showSpinner = false; 
        console.error('Error saving record:', event.detail.message);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Error saving record: ' + event.detail.message,
                variant: 'error',
            })
        );
    }
}