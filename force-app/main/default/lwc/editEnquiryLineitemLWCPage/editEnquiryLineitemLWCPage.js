import {
	LightningElement,
	track,
	wire,
	api
} from 'lwc';
import {
	ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
	CurrentPageReference
} from 'lightning/navigation';
import {
	NavigationMixin
} from "lightning/navigation";
import customPicklist from 'c/customPicklist';

import {
	getObjectInfo,
	getPicklistValues
} from 'lightning/uiObjectInfoApi';
import enqlineitem_object from '@salesforce/schema/Enquiry_Line_Item__c';
import status_field from '@salesforce/schema/Enquiry_Line_Item__c.Status__c';
import {
	updateRecord
} from 'lightning/uiRecordApi';
import {
	RefreshEvent
} from 'lightning/refresh';
import getComprtitormaster from '@salesforce/apex/EditEnquiryLineitems.getComprtitormaster';
import getEnquiryLineItems from '@salesforce/apex/EditEnquiryLineitems.getEnquiryLineItems';
import getStatusPicklistOptions from '@salesforce/apex/EditEnquiryLineitems.getStatusPicklistOptions';
import getLostReasonPicklistOptions from '@salesforce/apex/EditEnquiryLineitems.getLostReasonPicklistOptions';
import saveProducts from '@salesforce/apex/EditEnquiryLineitems.saveProducts';
import modal from '@salesforce/resourceUrl/modalwidth';
import {
	loadStyle
} from 'lightning/platformResourceLoader';

export default class EditEnquiryLineItemLWCpage extends NavigationMixin(LightningElement) {
	@track isModalOpen = false;
	@track isFirstPage = false;
	@track SelectedProductData = [];
	@track statusOptions = [];
	@track ComprtitormasterOptions = [];
	@track ReasonforlostenquiryOptions = [];
	@track taxcode = [];
	@track selectedtaxcode = '';
	@track Status__c = [];
	@track isCloseWon = false;
	mapIdQuantity = new Map();
	mapstatus = new Map();
	mapIdSalesPrice = new Map();
	mapIdReason = new Map();
	mapIdCompetitor = new Map();
	mapIdCompetitorProduct = new Map();
	mapIdtaxcode = new Map();
	@api recordId;

	@api currentCompetitor;

	@wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			this.EnquiryId = currentPageReference.state.c__refRecordId;
			console.log('this.EnquiryId', this.EnquiryId);
		}
	}
	@track isMobile=false;
	connectedCallback() {
		if (window.innerWidth <= 768) {
			console.log('this.isMobile ',this.recordId);
			
			this.isMobile = true;
			this.EnquiryId=this.recordId;
		}
		this.isModalOpen = true;
		this.isFirstPage = true;
		console.log('this.EnquiryId', this.EnquiryId);

		// this.fetchLineItems();
		//this.handleStatusChange();
		this.fetchLineItems()
			.then(() => {
				// Initialize status for all products after line items are fetched
				this.initializeStatus();
			})
			.catch(error => {
				console.error('Error during initialization:', error);
			});
		
	}

	closeModal() {
		this.isModalOpen = false;

	}
	// goBackToRecord() {
	//     // Close the modal
	//     this.isModalOpen = false;

	//     // Navigate to the Enquiry record page
	//     this[NavigationMixin.Navigate]({
	//         type: 'standard__recordPage',
	//         attributes: {
	//             recordId: this.EnquiryId,
	//             objectApiName: 'Enquiry__c',
	//             actionName: 'view',
	//         }
	//     });
	// }
	goBackToRecord() {
		// Close the modal
		this.isModalOpen = false;

		try {
			// Navigate to the Enquiry record page
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: this.EnquiryId,
					objectApiName: 'Enquiry__c',
					actionName: 'view',
				}
			});
		} catch (error) {
			console.error('Navigation error:', error?.message || 'An unknown error occurred');
		}
	}


	closeAction() {
		this.dispatchEvent(new ShowToastEvent({
			title: 'Error',
			message: 'Please Select Pricebook First',
			variant: 'error',
		}));
		this.dispatchEvent(new RefreshEvent());
	}
	fetchLineItems() {
		return getEnquiryLineItems({
			enquiryId: this.EnquiryId
		}).then(data => {
			this.SelectedProductData = data; // Assign data to your component property
			console.log('Fetched Line Items:', data);
		}).catch(error => {
			console.error('Error fetching line items:', error);
		});
	}


	// fetchLineItems() {
	//     getEnquiryLineItems({ enquiryId: this.EnquiryId })
	//         .then(result => {
	//             this.lineItems = result;
	//             console.log('Fetched lineItems:', this.lineItems);
	//             this.SelectedProductData = [...this.lineItems];
	//         })
	//         .catch(error => {
	//             this.showToast('Error loading line items', error.body.message, 'error');
	//         });
	// }

	@wire(getStatusPicklistOptions)
	wiredStatusValues({
		error,
		data
	}) {
		if (data) {
			this.statusOptions = data;
			console.log('Fetched statusOptions:', this.statusOptions);
		} else if (error) {
			this.statusOptions = [];
		}
	}

	@wire(getLostReasonPicklistOptions)
	wiredValues({
		error,
		data
	}) {
		if (data) {
			this.ReasonforlostenquiryOptions = data;
			console.log('Fetched ReasonforlostenquiryOptions:', this.ReasonforlostenquiryOptions);
		} else if (error) {
			this.ReasonforlostenquiryOptions = [];
		}
	}

	@wire(getComprtitormaster)
	wiredComprtitormaster({
		error,
		data
	}) {
		if (data) {
			this.ComprtitormasterOptions = data;
		} else if (error) {
			this.ComprtitormasterOptions = [];
		}
	}

	handleQuantityChange(event) {
		const key = event.currentTarget.dataset.targetId;
		this.mapIdQuantity.set(key, event.target.value);
	}

	handleSalesPriceChange(event) {
		const key = event.currentTarget.dataset.targetId;
		this.mapIdSalesPrice.set(key, event.target.value);
	}

	// handleStatusChange(event) {
	//     const selectedRow = event.currentTarget;
	//     const selectedvalues = event.target.value;
	//     const index = parseInt(selectedRow.dataset.index, 10);
	//     const key = selectedRow.dataset.targetId;

	//     this.mapstatus.set(key, selectedvalues);
	//     console.log('Selected Values:', selectedvalues);
	//     if(selectedvalues === 'Close Won'){
	//         this.isCloseWon = true;
	//         console.log('isCloseWon',this.isCloseWon);
	//     }
	//     console.log('Updated MapStatus:', this.mapstatus);
	// }

	initializeStatus() {
		try {
			if (this.SelectedProductData && Array.isArray(this.SelectedProductData)) {
				this.SelectedProductData = this.SelectedProductData.map((product, index) => {
					const status = product.Status__c || ''; // Assuming Status__c holds the current status
					const reason = product.Reason_for_lost_enquiry__c || ''; // Assuming Status__c holds the current status
					return {
						...product,
						isCloseWon: (!status || status === 'Close Won'),
						isComp: (!reason || reason != 'Competitor offered better product quality'),
					};
				});

				// Trigger reactivity
				this.SelectedProductData = [...this.SelectedProductData];

				console.log('Initialized Product Data:', this.SelectedProductData);
			}
		} catch (error) {
			console.error('Error initializing status:', error);
		}
	}

	handleStatusChange(event) {
		try {
			const selectedRow = event.currentTarget;
			const selectedValues = event.target.value;
			const index = parseInt(selectedRow.dataset.index, 10);
			const key = selectedRow.dataset.targetId;

			// Update the status in the map
			this.mapstatus.set(key, selectedValues);

			// Create a shallow copy of the product to make it extensible
			let product = {
				...this.SelectedProductData[index]
			};

			// Update isCloseWon based on selected status
			product.isCloseWon = (!selectedValues || selectedValues === 'Close Won');
			product.isComp = true;

			// Replace the old product with the updated product in SelectedProductData array
			this.SelectedProductData[index] = product;

			// Reassign the array to trigger reactivity
			this.SelectedProductData = [...this.SelectedProductData];

			// Log for debugging purposes
			console.log('Selected Status for Line Item:', product);
			console.log('Updated Product Data:', this.mapstatus);
		} catch (error) {
			console.error('Error in handleStatusChange:', error);
		}
	}




	handleReasonforlostChange(event) {
		// const key = event.currentTarget.dataset.targetId;

		const selectedRow = event.currentTarget;
		const selectedValues = event.target.value;
		const index = parseInt(selectedRow.dataset.index, 10);
		const key = selectedRow.dataset.targetId;

		this.mapIdReason.set(key, event.target.value);
		let product = {
			...this.SelectedProductData[index]
		};

		product.isComp = (!selectedValues || selectedValues != 'Competitor offered better product quality');
		this.SelectedProductData[index] = product;
		this.SelectedProductData = [...this.SelectedProductData];


	}

	handleCompetitorChange(event) {
		const key = event.currentTarget.dataset.targetId;
		this.mapIdCompetitor.set(key, event.target.value);
		console.log('Updated mapIdCompetitor:', this.mapIdCompetitor);
		const Competitor = event.target.value;
		console.log('Competitor:', Competitor);
		this.currentCompetitor = Competitor;
		console.log('currentCompetitor:', this.currentCompetitor);
		this.mapIdCompetitor = new Map(this.mapIdCompetitor);
	}


	lookupRecord(event) {
		let selectedCompetitor = event.detail;
		let jsonObject = selectedCompetitor;


		const key = event.currentTarget.dataset.targetId;

		this.mapIdCompetitorProduct.set(key, jsonObject.selectedRecord.Id);
		console.log('this.mapIdCompetitorProduct-->', this.mapIdCompetitorProduct);
		console.log('Dataset:', event.currentTarget.dataset); // Log the entire dataset
		console.log('Target ID:', event.currentTarget.dataset.targetId); // Log targetid specifically

	}


	// saveDetails() {
	//     this.disableSaveButton = true;
	//     console.log('Updated SelectedProductData:', this.SelectedProductData);

	//     // Map over SelectedProductData to create a modifiable copy of each item
	//     let DataToSave = this.SelectedProductData.map(item => {
	//         // Create a shallow copy of item to allow modifications
	//         let updatedItem = { ...item };

	//         console.log(`Processing Item Id: ${updatedItem.Id}`);
	//         console.log('Processing Item Id:', this.mapstatus);
	//         console.log('Before assignment - updatedItem.Status__c:', updatedItem.Status__c);

	//         if (this.mapIdQuantity.has(updatedItem.Id)) {
	//             updatedItem.Qty__c = this.mapIdQuantity.get(updatedItem.Id);
	//         }
	//         if (this.mapstatus.has(updatedItem.Id)) {
	//             console.log('Processing mapstatus:', this.mapstatus.get(updatedItem.Id));
	//             console.log('Before assignment - updatedItem.Status__c:', updatedItem.Status__c);
	//             try {
	//                 updatedItem.Status__c = this.mapstatus.get(updatedItem.Id);
	//                 console.log('After assignment - updatedItem.Status__c:', updatedItem.Status__c);
	//             } catch (error) {
	//                 console.error(`Error assigning Status__c for item ${updatedItem.Id}:`, error);
	//             }
	//         }
	//         if (this.mapIdSalesPrice.has(updatedItem.Id)) {
	//             updatedItem.Sales_Price__c = this.mapIdSalesPrice.get(updatedItem.Id);
	//         }
	//         if (this.mapIdReason.has(updatedItem.Id)) {
	//             updatedItem.Reason_for_lost_enquiry__c = this.mapIdReason.get(updatedItem.Id);
	//         }
	//         if (this.mapIdCompetitor.has(updatedItem.Id)) {
	//             updatedItem.Competitor__c = this.mapIdCompetitor.get(updatedItem.Id);
	//         }
	//         if (this.mapIdCompetitorProduct.has(updatedItem.Id)) {
	//             console.log('Processing mapIdCompetitorProduct:', this.mapIdCompetitorProduct.get(updatedItem.Id));
	//             updatedItem.Competitor_Product__c = this.mapIdCompetitorProduct.get(updatedItem.Id);
	//             console.log('Processing CompetitorProduct:',  updatedItem.CompetitorProduct);
	//         }

	//         return updatedItem;
	//     });

	//     console.log('Updated DataToSave:', DataToSave);

	//     // Pass DataToSave to Apex as JSON string
	//     saveProducts({ recordData: JSON.stringify(DataToSave), recId: this.EnquiryId })
	//         .then(() => {
	//             this.dispatchEvent(new ShowToastEvent({
	//                 title: 'Success',
	//                 message: 'Product Added Successfully',
	//                 variant: 'success',
	//             }));

	//             this.dispatchEvent(new RefreshEvent());
	//             this.goBackToRecord();
	//         })
	//         .catch(error => {
	//             this.dispatchEvent(new ShowToastEvent({
	//                 title: 'Error Product Adding',
	//                 message: error.body.message,
	//                 variant: 'error',
	//             }));
	//         })
	//         .finally(() => {
	//             this.disableSaveButton = false;
	//         });

	// }
	saveDetails() {
		this.disableSaveButton = true;
		console.log('Updated SelectedProductData:', this.SelectedProductData);

		// Map over SelectedProductData to create a modifiable copy of each item
		let DataToSave = this.SelectedProductData.map(item => {
			// Create a shallow copy of item to allow modifications
			let updatedItem = {
				...item
			};

			console.log(`Processing Item Id: ${updatedItem.Id}`);
			console.log('Processing Item Id:', this.mapstatus);
			console.log('Before assignment - updatedItem.Status__c:', updatedItem.Status__c);

			if (this.mapIdQuantity.has(updatedItem.Id)) {
				updatedItem.Qty__c = this.mapIdQuantity.get(updatedItem.Id);
			}
			if (this.mapstatus.has(updatedItem.Id)) {
				console.log('Processing mapstatus:', this.mapstatus.get(updatedItem.Id));
				console.log('Before assignment - updatedItem.Status__c:', updatedItem.Status__c);
				try {
					updatedItem.Status__c = this.mapstatus.get(updatedItem.Id);
					console.log('After assignment - updatedItem.Status__c:', updatedItem.Status__c);
				} catch (error) {
					console.error(`Error assigning Status__c for item ${updatedItem.Id}:`, error);
				}
			}
			if (this.mapIdSalesPrice.has(updatedItem.Id)) {
				updatedItem.Sales_Price__c = this.mapIdSalesPrice.get(updatedItem.Id);
			}
			if (this.mapIdReason.has(updatedItem.Id)) {
				updatedItem.Reason_for_lost_enquiry__c = this.mapIdReason.get(updatedItem.Id);
			}
			if (this.mapIdCompetitor.has(updatedItem.Id)) {
				updatedItem.Competitor__c = this.mapIdCompetitor.get(updatedItem.Id);
			}
			if (this.mapIdCompetitorProduct.has(updatedItem.Id)) {
				console.log('Processing mapIdCompetitorProduct:', this.mapIdCompetitorProduct.get(updatedItem.Id));
				updatedItem.Competitor_Product__c = this.mapIdCompetitorProduct.get(updatedItem.Id);
				console.log('Processing CompetitorProduct:', updatedItem.Competitor_Product__c);
			}

			return updatedItem;
		});

		console.log('Updated DataToSave:', DataToSave);

		// Validation: Check if Status is "Close Lost" and Reason is blank
		let isValid = true;
		let errorMessage = '';

		DataToSave.forEach((item) => {
			if (item.Status__c === 'Close Lost' && !item.Reason_for_lost_enquiry__c) {
				isValid = false;
				errorMessage = 'Please select a reason for lost enquiry for "Close Lost" status.';
			} else if (item.Status__c === 'Close Lost' && !item.Competitor__c) {
				isValid = false;
				errorMessage = 'Please select a Competitor lost enquiry for "Close Lost" status.';
			} else if (item.Status__c === 'Close Lost' && !item.Competitor_Product__c) {
				isValid = false;
				errorMessage = 'Please select a Competitor Product lost enquiry for "Close Lost" status.';
			}
		});


		if (!isValid) {
			// If validation fails, show an error message and stop the save operation
			this.dispatchEvent(new ShowToastEvent({
				title: 'Error',
				message: errorMessage,
				variant: 'error',
			}));
			this.disableSaveButton = false;
			return; // Exit the method early
		}

		// If validation passes, proceed with save operation
		saveProducts({
			recordData: JSON.stringify(DataToSave),
			recId: this.EnquiryId
		}).then(() => {
			this.dispatchEvent(new ShowToastEvent({
				title: 'Success',
				message: 'Product Added Successfully',
				variant: 'success',
			}));
			this.dispatchEvent(new RefreshEvent());
			this.goBackToRecord();
		}).catch(error => {
			this.dispatchEvent(new ShowToastEvent({
				title: 'Error Product Adding',
				message: error.body.message,
				variant: 'error',
			}));
		}).finally(() => {
			this.disableSaveButton = false;
		});
	}




}