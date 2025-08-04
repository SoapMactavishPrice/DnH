import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

import getEnqLineItems from '@salesforce/apex/AddSOrderPageEnqController.getEnqLineItems';
import createQuote from '@salesforce/apex/AddSOrderPageEnqController.createQuote';

const COLS = [
	{ label: 'Name', fieldName: 'liurl', type: 'url', typeAttributes: { label: { fieldName: 'name' } } },
	{ label: 'Product Family', fieldName: 'productFamily', type: 'text' },
	{ label: 'Quantity', fieldName: 'qty', type: 'number' },
	{ label: 'Price', fieldName: 'price', type: 'number' },
	{ label: 'Specification', fieldName: 'specification', type: 'text' },
	{ label: 'Description', fieldName: 'description', type: 'text' },
]

export default class AddSOrderPageEnq extends NavigationMixin(LightningElement) {
	cols = COLS;

	@track showSpinner = false;
	@track recId;
	@track SelectedRecordCount = 0;
	@track isModalOpen = false;
	@track isFirstPage = true;
	@track isSecondPage = false;

	@track ShowTableData = [];
	@track selectedProductCode = [];
	@track selectedLineItems = [];
	@track AllProductData = [];
	@track SelectedProductData = [];
	@track paginationDataList;

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference.state.c__refRecordId;
		if (this.currentPageReference) {
			this.recId = this.currentPageReference;
			console.log('Enq Id', this.recId);
		}
	}

	connectedCallback() {
		this.showSpinner = true;
		console.log('connectedCallback call.......');
		this.handlerGetEnqLineItems();
	}

	handlerGetEnqLineItems() {
		this.isModalOpen = true;
		this.showSpinner = true;
		new Promise((resolve, reject) => {

			getEnqLineItems({
				enqId: this.recId
			}).then((data) => {
				if (data != '') {
					console.log('CHECK getEnqLineItems:>> ', data);
					let tData = JSON.parse(data);
					this.AllProductData = tData.enquiryLineItemList;
					this.ShowTableData = tData.enquiryLineItemList;
					this.dataForFilter = tData.enquiryLineItemList;
					this.paginiateData(JSON.stringify(this.AllProductData));

					this.showSpinner = false;
					resolve(data);
				}
			}).catch((error) => {
				console.log('error:>> ', error);
				reject(error);
			});

		}).then((data) => {
		});
	}

	handleRowSelection(event) {
		this.selectedLineItems = event.detail.selectedRows
		console.log(this.selectedLineItems);
	}

	saveDetails() {
		this.handleCreateQuote();
	}

	handleCreateQuote() {
		this.showSpinner = true;
		new Promise((resolve, reject) => {

			createQuote({
				enqId: this.recId,
				lItems: this.selectedLineItems
			}).then((data) => {
				console.log('CHECK createQuote:>> ', data);
				resolve(data);
			}).catch((error) => {
				console.log('error:>> ', error);
				reject(error);
			});
			
		}).then((res) => {
			this.showSpinner = false;
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: res,
					objectApiName: 'Sales_Order__c',
					actionName: 'view',

				}
			});
		})
	}

	paginiateData(results) {
		let data = JSON.parse(results);
		this.paginationDataList = data;
		this.totalRecountCount = data.length;
		this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
		this.ShowTableData = this.paginationDataList.slice(0, this.pageSize);
		////console.log('totalRecountCount ', this.totalRecountCount);
		this.endingRecord = this.pageSize;
		this.error = undefined;

	}

	fillselectedRows() {
		this.selectedRows = []
		for (let i = 0; i < this.ShowTableData.length; i++) {
			if (this.selectedProductCode.includes(this.ShowTableData[i].Id)) {
				this.selectedRows.push(this.ShowTableData[i]);
			}
		}
	}

	goBackToRecord() {
		setTimeout(() => {
			window.location.reload();
		}, 2000);

		this.isFirstPage = true;
		this.isSecondPage = false;
		this.SelectedProductData = [];
		this.selectedProductCode = [];
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.recId,
				objectApiName: 'Enquiry__c',
				actionName: 'view',

			}
		});
		this.isModalOpen = false;
	}

}