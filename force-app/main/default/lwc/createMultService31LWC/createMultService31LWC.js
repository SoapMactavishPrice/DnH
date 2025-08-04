import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from "lightning/navigation";

import getcodemaster from "@salesforce/apex/CreateMultService31Controller.getcodemaster";
import addFile_n_LineItems from "@salesforce/apex/CreateMultService31Controller.addFile_n_LineItems";

export default class CreateMultService31LWC extends NavigationMixin(LightningElement) {
	@track showSpinner = false;
	@track showSpinner2 = false;
	@track recId;

	@track isAddItemModalOpen = false;
	@track isEditing = false;
	@track editIndex;
	@track addedItemList = [];
	@track objectname ='Service 31';
	@track codeMasterData = []; // To store the processed results
    @track displayLabel; 
	modalData = {};

	get addedItemListLength() {
		return this.addedItemList.length > 0;
	}

	@track doc_MainFile;
	@track doc_MainFileName;
	@track doc_AddItemFileName;

	showToast(toastTitle, toastMsg, toastType) {
		const event = new ShowToastEvent({
			title: toastTitle,
			message: toastMsg,
			variant: toastType,
			mode: "dismissable"
		});
		this.dispatchEvent(event);
	}

	navigateToRecordPage() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.recId,
				objectApiName: 'Multiple_Service_31__c',
				actionName: 'view'
			}
		});
	}

	connectedCallback() {
		this.getcodemaster();
	}

	getcodemaster() {
        getcodemaster({ objectname: this.objectname })
            .then(result => {
                console.log('displayLabel result:', result);
                
                // No need to parse if result is already an object
                if (result) {
                    //this.displayLabel = result.Display_Label__c; // Access Display_Label__c directly
                    this.displayLabel = result; // Store the entire result if needed
                    //this.displayLabel = this.codeMasterData;
                    console.log('Result Keys:', Object.keys(result));  // Log all keys of the result object
                    //console.log('Display_Label__c:', result.data.Display_Label__c); 
                    console.log('displayLabel result:', result?.Display_Label__c);
                
                } else {
                    this.showToast('Error', 'No data received', 'error');
                }
            })
            .catch(error => {
                console.error('Error in getcodemaster:', error);
                this.showToast('Error', 'Failed to fetch data', 'error');
            });
    }
	// ------------------------------ Add Items ------------------------------

	handleOpenAddNewItems() {
		this.showSpinner = true;
		this.isAddItemModalOpen = true;
		this.doc_AddItemFileName = '';
	}

	handleCloseAddNewItems() {
		this.showSpinner = false;
		this.isAddItemModalOpen = false;
		this.modalData = {};
		this.isEditing = false;
		this.editIndex = null;
	}

	handleModalInputChange(event) {
		const field = event.target.fieldName;
		this.modalData[field] = event.target.value;
	}

	handleSaveModalData() {
		if (this.isEditing) {
			this.addedItemList[this.editIndex] = { ...this.modalData };
		} else {
			this.addedItemList = [...this.addedItemList, { ...this.modalData }];
		}
		let ind = 1;
		this.addedItemList.forEach(item => {
			item.SrNo = ind;
			ind++;
		});
		this.handleCloseAddNewItems();
		console.log('Newly Added addedItemList:>>> ', this.addedItemList);
	}

	handleRemoveRow(event) {
		this.showSpinner = true;
		const index = event.currentTarget.dataset.index;
		this.addedItemList.splice(index, 1);
		this.addedItemList = [...this.addedItemList];
		let ind = 1;
		this.addedItemList.forEach(item => {
			item.SrNo = ind;
			ind++;
		});
		this.showSpinner = false;
		console.log('After delete addedItemList:>>> ', this.addedItemList);
	}

	handleEditRow(event) {
		this.showSpinner = true;
		const index = event.currentTarget.dataset.index;
		this.modalData = { ...this.addedItemList[index] };
		this.isEditing = true;
		this.editIndex = index;
		this.handleOpenAddNewItems();
		this.showSpinner = false;
	}

	handleAddItemFileUpload(event) {

		if (this.isEditing) {
			this.doc_AddItemFileName = this.modalData.file ? this.modalData.file.Title : '';
		}

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
			let titleTemp = 'Document2 ' + myArray[myArray.length - 1];
			this.doc_AddItemFileName = 'Document2 ' + myArray[myArray.length - 1];
			this.modalData['file'] = { PathOnClient: file.name, Title: titleTemp, VersionData: fileContents };
		};
		reader.readAsDataURL(file);
		// }
		// } else {
		// this.showToast('Error', '', 'File size should be less than 3MB');
		// }

	}

	// ------------------------------ Add Items End ------------------------------

	handleMainClick(event) {

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

	handleMainOnSubmit(event) {
		event.preventDefault();
		const lwcInputFields = this.template.querySelectorAll('lightning-input-field');
		let validationflag = false;
		if (lwcInputFields) {
			lwcInputFields.forEach(field => {
				if (field.fieldName == 'Name_Of_The_Customer__c') {
					if (field.value == null || field.value == '') {
						console.log(field.fieldName);
						field.setCustomValidity('Please Fill this field!');
						validationflag = true;
					}
				}
				if (field.fieldName == 'Sales_Person__c') {
					if (field.value == null || field.value == '') {
						field.setCustomValidity('Please Fill this field!');
						validationflag = true;
					}
				}
				if (field.fieldName == 'Zonal_Head__c') {
					if (field.value == null || field.value == '') {
						field.setCustomValidity('Please Fill this field!');
						validationflag = true;
					}
				}
				if (field.fieldName == 'Area_Manager__c') {
					if (field.value == null || field.value == '') {
						field.setCustomValidity('Please Fill this field!');
						validationflag = true;
					}
				}
				field.reportValidity();
			});
			if (validationflag) {
				// this.showToast('error', 'Please fill all required fields!!!', 'error');
			} else {
				const form1 = this.template.querySelector('lightning-record-edit-form[data-id="form1"]');
				form1.submit();
			}
		}
	}

	handleMainOnSuccess(event) {
		this.recId = event.detail.id;
		console.log(this.doc_MainFile);
		console.log(this.addedItemList);
		this.showSpinner = true;
		new Promise((resolve, reject) => {
			addFile_n_LineItems({
				Id: this.recId,
				mdoc: this.doc_MainFile != undefined ? JSON.stringify(this.doc_MainFile) : '',
				lineitemlist: this.addedItemList.length > 0 ? JSON.stringify(this.addedItemList) : ''
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
			this.navigateToRecordPage();
		})

	}

}