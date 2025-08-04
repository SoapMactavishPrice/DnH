import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSubmittedServiceData from "@salesforce/apex/SubmittedService19Controller.getSubmittedServiceData";

const COLS = [
	{ label: 'Document No', fieldName: 'DocumentNo', type: 'text' },
	{ label: 'Customer Name', fieldName: 'CustomerName', type: 'text' },
	{ label: 'Invoice No', fieldName: 'InvoiceNo', type: 'text' },
	{ label: 'Brand Name', fieldName: 'BrandName', type: 'text' },
	{ label: 'Batch No', fieldName: 'BatchNo', type: 'text' },
	{ label: 'Type of Complaint', fieldName: 'TypeofComplaint', type: 'text' },
];

export default class SubmittedService19LWC extends LightningElement {

	columns = COLS;

	@track showSpinner = false;
	@track showSpinner2 = false;
	@track submittedServiceData = [];
	@track AllData = [];

	@track paginationDataList;
	@track searchKey = '';
	page = 1;
	items = [];
	data = [];
	startingRecord = 1;
	endingRecord = 0;
	pageSize = 10;
	totalRecountCount = 0;
	totalPage = 0;

	get bDisableFirst() {
		return this.page == 1;
	}
	get bDisableLast() {
		return this.page == this.totalPage;
	}

	@track isModalOpen = false;
	@track fromDateValue = '';
	@track toDateValue = '';
	@track invoiceNumberValue = '';
	@track selectInvoiceNo_Options = [];
	@track salesLIVariantValue = '';
	@track salesLIVariant_Options = [];
	@track selectedBatchValue = '';
	@track selectBatch_Options = [];

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
		this.handlerSubmittedServiceData();
	}

	handlerSubmittedServiceData() {
		this.showSpinner = true;
		new Promise((resolve, reject) => {
			getSubmittedServiceData().then((result) => {
				let data = JSON.parse(result);
				console.log(data);

				this.submittedServiceData = data.dataList;
				this.AllData = data.dataList;
				this.showSpinner = false;
				this.paginiateData(JSON.stringify(this.AllData));
				resolve(result);
			}).catch((error) => {
				reject(error);
				this.showSpinner = false;
				this.showToast('Something went wrong!', error, 'error');
			})
		}).then(() => {
			this.showSpinner = false;
		})
	}

	// -------------- Pagination ----------------

	paginiateData(results) {
		let data = JSON.parse(results);
		this.paginationDataList = data;
		this.totalRecountCount = data.length;
		this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
		this.submittedServiceData = this.paginationDataList.slice(0, this.pageSize);
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
		// this.template.querySelector('[data-id="datatable"]').selectedRows = this.SelectedProductData;
	}

	nextHandler() {
		if ((this.page < this.totalPage) && this.page !== this.totalPage) {
			this.page = this.page + 1;
			//console.log('this.SelectedProductData 619', this.SelectedProductData.length);
			this.recordPerPage(this.page, this.paginationDataList);
		}
		//console.log('json -->', JSON.parse(this.template.querySelector('[data-id="datatable"]').selectedRows));
	}

	recordPerPage(page, data) {
		let tempdata = data;
		this.startingRecord = ((page - 1) * this.pageSize);
		this.endingRecord = (this.pageSize * page);
		this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;
		//this.fillselectedRows();
		this.submittedServiceData = tempdata.slice(this.startingRecord, this.endingRecord);
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

	handleKeyChange(event) {
		this.isSearchLoading = true;
		this.searchKey = event.target.value;
		var data = [];
		for (var i = 0; i < this.AllData.length; i++) {
			console.log(this.AllData[i]);

			if (this.AllData[i] != undefined && this.AllData[i].DocumentNo.toLowerCase().includes(this.searchKey.toLowerCase())) {
				data.push(this.AllData[i]);
			}
			// else if (this.AllData[i] != undefined && this.AllData[i].CustomerName.toLowerCase().includes(this.searchKey.toLowerCase())) {
			// 	data.push(this.AllData[i]);
			// } else if (this.AllData[i] != undefined && this.AllData[i].InvoiceNo.toLowerCase().includes(this.searchKey.toLowerCase())) {
			// 	data.push(this.AllData[i]);
			// } else if (this.AllData[i] != undefined && this.AllData[i].BrandName.toLowerCase().includes(this.searchKey.toLowerCase())) {
			// 	data.push(this.AllData[i]);
			// } else if (this.AllData[i] != undefined && this.AllData[i].BatchNo.toLowerCase().includes(this.searchKey.toLowerCase())) {
			// 	data.push(this.AllData[i]);
			// } else if (this.AllData[i] != undefined && this.AllData[i].TypeofComplaint.toLowerCase().includes(this.searchKey.toLowerCase())) {
			// 	data.push(this.AllData[i]);
			// }
		}
		this.paginiateData(JSON.stringify(data));
		this.page = 1;
		this.recordPerPage(1, data);
	}

	handlerCloseAddService19() {
		this.isModalOpen = false;
		this.showSpinner = false;
	}

	handlerAddService19() {
		this.showSpinner = true;
		this.isModalOpen = true;
		this.showSpinner2 = true;
		this.showSpinner2 = false;
	}

	handlerDateChange(event) {
		if (event.target.name == 'fromdate') {
			this.fromDateValue = event.target.value;
		} else if (event.target.name == 'todate') {
			this.toDateValue = event.target.value;
		}
	}

}