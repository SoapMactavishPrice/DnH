import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from "lightning/navigation";

import getItemMaster from "@salesforce/apex/TechCommOfferController.getItemMaster";

import addFile_n_LineItems from "@salesforce/apex/TechCommOfferController.addFile_n_LineItems";
const COLS = [
	{ label: 'Item No', fieldName: 'ItemNo', type: 'text' },
	{ label: 'Description', fieldName: 'Description', type: 'text' }
];

export default class TechnoCommercialOfferEnqlwc extends NavigationMixin(LightningElement) {
	@api recordId;
	@track showSpinner = false;
	@track showSpinner2 = false;
	@track recId;
	@track isAddItemModalOpen = false;
	@track isEditing = false;
	@track editIndex;
	@track addedItemList = [];
	@track modalData = {};

	get addedItemListLength() {
		return this.addedItemList.length > 0;
	}

	@track doc_MainFile;
	@track doc_MainFileName;


	@track modalTableData = [];
	@track AllData = [];
	@track selectedModalRow = [];

	columns = COLS;

	@track paginationDataList;
	@track searchKey = '';
	page = 1;
	items = [];
	data = [];
	startingRecord = 1;
	endingRecord = 0;
	pageSize = 5;
	totalRecountCount = 0;
	totalPage = 0;

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

	}

	// ------------------------------ Add Items ------------------------------

	handleOpenAddNewItems() {
		let inputField1 = this.template.querySelector('[data-id="customerno"]');
		let inputField2 = this.template.querySelector('[data-id="fieldstaffcode"]');
		// if (inputField1.value == null || inputField1.value == '') {
		// 	this.showToast('Customer Name Required!', '', 'error');
		// } else
         if (inputField2.value == null || inputField2.value == '') {
			this.showToast('Sales Person Required!', '', 'error');
		} else {
			//this.showSpinner = true;
			this.isAddItemModalOpen = true;
			this.handlerGetModalTableData();
		}
	}

	handlerGetModalTableData() {
		  this.showSpinner2 = true;
		new Promise((resolve, reject) => {
			getItemMaster().then((result) => {
				let data = JSON.parse(result);
				console.log(data);
				this.modalTableData = data.dataList;
				this.AllData = data.dataList;
				this.showSpinner2 = false;
				this.paginiateData(JSON.stringify(this.AllData));
				resolve(result);
			}).catch((error) => {
				reject(error);
				this.showSpinner2 = false;
				this.showToast('Something went wrong!', error, 'error');
			})
		}).then(() => {
			this.showSpinner2 = false;
		})
	}

	handleOnRowSelection(event) {
		console.log(event.detail.selectedRows);
		this.selectedModalRow = event.detail.selectedRows;
		console.log(this.selectedModalRow[0].ItemNo);
		console.log(this.selectedModalRow[0].Description);
		console.log(this.selectedModalRow[0].SUOM);
		console.log(this.selectedModalRow[0].BUOM);
		this.modalData.Item_No__c = this.selectedModalRow[0].ItemNo;
		this.modalData.Item_Description__c = this.selectedModalRow[0].Description;
		this.modalData.Sales_Unit_of_Measure__c = this.selectedModalRow[0].SUOM;
		this.modalData.Base_Unit_of_Measure__c = this.selectedModalRow[0].BUOM;
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

	// ------------------------------ Add Items End ------------------------------

	// -------------- Pagination ----------------

	paginiateData(results) {
		let data = JSON.parse(results);
		this.paginationDataList = data;
		this.totalRecountCount = data.length;
		this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
		this.modalTableData = this.paginationDataList.slice(0, this.pageSize);
		////console.log('totalRecountCount ', this.totalRecountCount);
		this.endingRecord = this.pageSize;
		this.error = undefined;
	}

	previousHandler() {
		if (this.page > 1) {
			this.page = this.page - 1;
			//console.log('this.SelectedProductData 611', this.SelectedProductData.length);
			this.recordPerPage(this.page, this.paginationDataList);
		}
	}

	nextHandler() {
		if ((this.page < this.totalPage) && this.page !== this.totalPage) {
			this.page = this.page + 1;
			//console.log('this.SelectedProductData 619', this.SelectedProductData.length);
			this.recordPerPage(this.page, this.paginationDataList);
		}
	}

	recordPerPage(page, data) {
		let tempdata = data;
		this.startingRecord = ((page - 1) * this.pageSize);
		this.endingRecord = (this.pageSize * page);
		this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;
		this.modalTableData = tempdata.slice(this.startingRecord, this.endingRecord);
		this.startingRecord = this.startingRecord + 1;
	}

	toggleResult(event) {
		const clsList = lookupInputContainer.classList;
		const whichEvent = event.target.getAttribute('data-source');
		switch (whichEvent) {
			case 'searchInputField':
				clsList.add('slds-is-open');
				break;
		}
	}

	showFilteredProducts(event) {
		if (event.keyCode == 13) {
			this.isFirstPage = false;
			this.showErrorMsg = false;
		} else {
			this.handleKeyChange(event);
			const searchBoxWrapper = this.template.querySelector('.lookupContainer');
			searchBoxWrapper.classList.add('slds-show');
			searchBoxWrapper.classList.remove('slds-hide');
		}
	}

	// -------------- Pagination ----------------

	handleMainOnSubmit(event) {
		event.preventDefault();
		const lwcInputFields = this.template.querySelectorAll('lightning-input-field');
		let validationflag = false;
		console.log('Record ID on submit:', this.recordId);
		if (this.addedItemList.length == 0) {
			this.showToast('Please add atleast one item', '', 'error');
			validationflag = true;
		}
		
		if (validationflag) {
			// this.showToast('error', 'Please fill all required fields!!!', 'error');
		} else {
			const form1 = this.template.querySelector('lightning-record-edit-form[data-id="form1"]');
			form1.submit();
		}
		
		// ------------------------------- Commented Coz in HTML required tag is already added -------------------------------
		// if (lwcInputFields) {
		// 	lwcInputFields.forEach(field => {
		// 		if (field.fieldName == 'Customer_No__c') {
		// 			if (field.value == null || field.value == '') {
		// 				console.log(field.fieldName);
		// 				field.setCustomValidity('Please Fill this field!');
		// 				validationflag = true;
		// 			}
		// 		}
		// 		field.reportValidity();
		// 	});
		// 	if (validationflag) {
		// 		// this.showToast('error', 'Please fill all required fields!!!', 'error');
		// 	} else {
		// 		const form1 = this.template.querySelector('lightning-record-edit-form[data-id="form1"]');
		// 		form1.submit();
		// 	}
		// }
	}

	handleMainOnSuccess(event) {
		this.showSpinner = false;
		const updatedRecordId = event.detail.id;
		console.log('Record saved successfully:', updatedRecordId);
		console.log('addedItemList', this.addedItemList);
		this.showSpinner = true;

		new Promise((resolve, reject) => {
			addFile_n_LineItems({
				Id: updatedRecordId,
				//mdoc: this.doc_MainFile != undefined ? JSON.stringify(this.doc_MainFile) : '',
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
			//this.showToast('Record has been saved ' + event.detail.id, '', 'success');
			this.navigateToRecordPage();
		});

		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: updatedRecordId,
				objectApiName: 'Enquiry__c',
				actionName: 'view'
			}
		});


		this.dispatchEvent(
			new ShowToastEvent({
				title: 'Success',
				message: 'Record saved successfully.',
				variant: 'success',
			})
		);
	}
	// handleMainClick(event){
	// 	this[NavigationMixin.Navigate]({
	// 	type: 'standard__recordPage',
	// 	attributes: {
	// 		recordId: updatedRecordId,
	// 		objectApiName: 'Enquiry__c',
	// 		actionName: 'view'
	// 	}
	// });}

}