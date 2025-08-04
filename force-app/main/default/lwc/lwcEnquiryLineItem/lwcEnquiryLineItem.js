import { LightningElement, track, wire, api } from 'lwc';
//import CUSTOM_STYLES from '@salesforce/resourceUrl/customStyles'; 
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LINEITEM_OBJECT from '@salesforce/schema/Enquiry_Line_Item__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import REASON from '@salesforce/schema/Enquiry_Line_Item__c.Reason_for_lost_enquiry__c';
import STATUS from '@salesforce/schema/Enquiry_Line_Item__c.Status__c';

import getEnquiryLineItems from '@salesforce/apex/LwcEnquiryLineItemContoller.getEnquiryLineItems';
import getComprtitormaster from '@salesforce/apex/LwcEnquiryLineItemContoller.getComprtitormaster';
import saveProducts from '@salesforce/apex/LwcEnquiryLineItemContoller.saveProducts';


import modalWidthInLwc from '@salesforce/resourceUrl/modalWidthInLwc';
import { loadStyle } from 'lightning/platformResourceLoader';


export default class LwcEnquiryLineItem extends NavigationMixin(LightningElement) {


	connectedCallback() {
		// Load the external CSS for modal
		loadStyle(this, modalWidthInLwc)
			.then(() => {
				console.log('CSS loaded successfully!');
			})
			.catch(error => {
				console.log('Error loading CSS:', error);
			});
	}


	recordId
	@wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			this.recordId = currentPageReference.state.recordId;
			console.log('OUTPUT : ', this.recordId);
		}
	}

	tableData;
	@wire(getEnquiryLineItems, { 'enquiryId': '$recordId' })
	lineItems({ data, error }) {
		if (data) {
			if (data.length > 0) {
				this.tableData = data.map(item => ({
					...item,
					reasondisable: item.Status__c === 'Close Lost' ? false : true,
					compititordisable: item.Status__c === 'Close Won' ? true : (item.Reason_for_lost_enquiry__c === 'Competitor offered better product quality' || item.Reason_for_lost_enquiry__c == 'Price-Competitor offered better price') ? false : true
				}));
			} else {
				this.showToast('Info', 'Enquiry Line Item Data not Found', 'Info');
			}
			console.log('Datatable listtt:>> ' , this.tableData);
			
		}

	}

	defaultRecordTypeId;

	// Fetch object information to get the default record type ID
	@wire(getObjectInfo, { objectApiName: LINEITEM_OBJECT })
	objectInfo({ data, error }) {
		if (data) {
			// Get the default Record Type Id from the object metadata
			this.defaultRecordTypeId = data.defaultRecordTypeId;
			console.log('Default Record Type ID:', this.defaultRecordTypeId);
		} else if (error) {
			console.error('Error retrieving object info:', error);
		}
	}

	status;
	@wire(getPicklistValues, {
		recordTypeId: '$defaultRecordTypeId',
		fieldApiName: STATUS
	})
	wiredstatus({ data, error }) {

		if (data) {
			console.log('Picklist data: ', data); // Log the picklist data
			this.status = data.values; // Assign picklist values to _countries
			//console.log('Countries: ', this._countries); // Log the country values
		} else if (error) {
			console.error('Error fetching picklist values:', error); // Log the error if it occurs
		}
	}

	reason;
	@wire(getPicklistValues, {
		recordTypeId: '$defaultRecordTypeId',
		fieldApiName: REASON
	})
	wiredCountires({ data, error }) {

		if (data) {
			console.log('Picklist data: ', data); // Log the picklist data
			this.reason = data.values; // Assign picklist values to _countries
			//console.log('Countries: ', this._countries); // Log the country values
		} else if (error) {
			console.error('Error fetching picklist values:', error); // Log the error if it occurs
		}
	}


	handleChange(event) {
		let id = event.target.dataset.id; // Fixed typo from datset to dataset
		let label = event.target.dataset.label;
		let index = this.tableData.findIndex(rev => rev.Id == id); // Find the index of the row based on Id
		console.log('OUTPUT : index', index, label, ' ', event.target.value);
		if (index > -1) {
			// Update the property (Qty__c) of the item
			// Use Object.assign or the spread operator to ensure reactivity in LWC
			let updatedItem = {};
			updatedItem = { ...this.tableData[index], [label]: event.target.value };

			if (label == 'Status__c') {
				if (event.target.value == "Close Lost") {
					updatedItem.reasondisable = false;
					if (updatedItem.Reason_for_lost_enquiry__c == 'Competitor offered better product quality' || updatedItem.Reason_for_lost_enquiry__c == 'Price-Competitor offered better price') {
						updatedItem.compititordisable = false;
					}
				} else {
					updatedItem.reasondisable = true;
					updatedItem.compititordisable = true;
				}
			} else if (label == 'Reason_for_lost_enquiry__c') {
				if (event.target.value == "Competitor offered better product quality" || event.target.value == 'Price-Competitor offered better price') {
					updatedItem.compititordisable = false;
				} else {
					updatedItem.compititordisable = true;
				}
			}
			console.log(updatedItem);


			// Replace the item in the array to trigger reactivity
			this.tableData = [
				...this.tableData.slice(0, index),
				updatedItem,
				...this.tableData.slice(index + 1)
			];

			console.log('OUTPUT : ', this.tableData);
		}
	}

	mapIdCompetitor = new Map();
	mapIdCompetitorProduct = new Map();
	@api currentCompetitor;

	@track ComprtitormasterOptions = [];

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

	handleCompetitorChange(event) {
		const Competitor = event.target.value;
		console.log('Competitor:', Competitor);
		this.currentCompetitor = Competitor;

		let id = event.target.dataset.id; // Fixed typo from datset to dataset
		let label = event.target.dataset.label;
		let index = this.tableData.findIndex(rev => rev.Id == id); // Find the index of the row based on Id
		console.log('OUTPUT : index', index, label);
		if (index > -1) {
			// Update the property (Qty__c) of the item
			// Use Object.assign or the spread operator to ensure reactivity in LWC
			const updatedItem = { ...this.tableData[index], [label]: event.target.value };

			// Replace the item in the array to trigger reactivity
			this.tableData = [
				...this.tableData.slice(0, index),
				updatedItem,
				...this.tableData.slice(index + 1)
			];

			console.log('OUTPUT : ', JSON.stringify(this.tableData));
		}
	}

	lookupRecord(event) {
		let selectedCompetitor = event.detail;
		let jsonObject = selectedCompetitor;
		let id = event.target.dataset.id; // Fixed typo from datset to dataset
		let label = event.target.dataset.label;
		let index = this.tableData.findIndex(rev => rev.Id == id); // Find the index of the row based on Id
		console.log('OUTPUT : index', index, label);
		if (index > -1) {
			// Update the property (Qty__c) of the item
			// Use Object.assign or the spread operator to ensure reactivity in LWC
			const updatedItem = { ...this.tableData[index], [label]: jsonObject.selectedRecord.Id };

			// Replace the item in the array to trigger reactivity
			this.tableData = [
				...this.tableData.slice(0, index),
				updatedItem,
				...this.tableData.slice(index + 1)
			];

			console.log('OUTPUT : ', JSON.stringify(this.tableData));
		}// Log targetid specifically

	}

	Save() {

		saveProducts({
			recordData: JSON.stringify(this.tableData),
			recId: this.recordId
		}).then(() => {

			this.closeRecordAction();
			this.dispatchEvent(new ShowToastEvent({
				title: 'Success',
				message: 'Enqiury Updated Successfully',
				variant: 'success',
			}));
			setTimeout(() => {
				window.location.reload();

				//this.dispatchEvent(new RefreshEvent());
			}, 2000);
			setTimeout()
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

	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: 'dismissable'  // Toast will be dismissable
		});
		this.dispatchEvent(event);
	}


	closeRecordAction() {
		// Use the navigation service to navigate back or close
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.recordId,
				objectApiName: 'Enquiry__c', // Or your specific object API name
				actionName: 'view'
			}
		});
	}
}