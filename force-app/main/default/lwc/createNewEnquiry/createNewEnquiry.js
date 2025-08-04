import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from "lightning/navigation";

import LABEL_CUSTURL from '@salesforce/label/c.Cust_URL';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ENQUIRY_OBJECT from '@salesforce/schema/Enquiry__c';

import getEnadCustomerList from "@salesforce/apex/TechCommOfferController.getEnadCustomerList";
import getRecordTypes from "@salesforce/apex/TechCommOfferController.getRecordTypes";
import getItemMaster from "@salesforce/apex/TechCommOfferController.getItemMaster";
import getItemVariantOptions from "@salesforce/apex/TechCommOfferController.getItemVariantOptions";
import getDealerPrice from "@salesforce/apex/TechCommOfferController.getDealerPrice";
import findRecentenqlineitem from '@salesforce/apex/TechCommOfferController.findRecentenqlineitem';
import getContact from '@salesforce/apex/TechCommOfferController.getContact';
import getFieldStaffCode from '@salesforce/apex/TechCommOfferController.getFieldStaffCode';
import getZonalManager from '@salesforce/apex/TechCommOfferController.getZonalManager';
import getcodemaster from "@salesforce/apex/TechCommOfferController.getcodemaster";
import createOrderFromEnquiry from "@salesforce/apex/TechCommOfferController.createOrderFromEnquiry";
import deleteENQLI from "@salesforce/apex/TechCommOfferController.deleteENQLI";
import addsaleorderlineItems from "@salesforce/apex/TechCommOfferController.addsaleorderlineItems";
import getConversionFactor from "@salesforce/apex/TechCommOfferController.getConversionFactor";

import isValidForApproval from "@salesforce/apex/AddSalesOrder.isValidForApproval";

import addFile_n_LineItems from "@salesforce/apex/TechCommOfferController.addFile_n_LineItems";
import getTCOlineitems from "@salesforce/apex/TechCommOfferController.getTCOlineitems";
const COLS = [
	{ label: 'Item No', fieldName: 'ItemNo', type: 'text', initialWidth: 130 },
	{ label: 'Description', fieldName: 'Description', type: 'text', initialWidth: 640 },
	{
		label: "View",
		type: "button",
		initialWidth: 230,
		typeAttributes: {
			label: "View Last 5 Price",
			name: "view_details",
			title: "click to view Details"

		}
	}
];
const COLS1 = [
	{ label: 'Customer', fieldName: 'EnquiryAccount' },
	{ label: 'Enquiry Name', fieldName: 'EqName' },
	{ label: 'Enquiry', fieldName: 'EnquiryName' },
	{ label: 'Quantity', fieldName: 'Qty__c' },
	{ label: 'Sales Price', fieldName: 'Approved_Price__c' }
];

const MobCols = [
	// { label: 'Item No', fieldName: 'ItemNo', type: 'text', initialWidth: 50, sortable: true },
	{ label: 'Description', fieldName: 'Description', type: 'text', initialWidth: 300, sortable: true },
	// {
	// 	label: "View",
	// 	type: "button",
	// 	initialWidth: 200,
	// 	typeAttributes: {
	// 		label: "View Last 5 Price",
	// 		name: "view_details",
	// 		title: "click to view Details"

	// 	}
	// }
	// { label: 'Qty', fieldName: 'Qty', type: 'text', initialWidth: 50, sortable: true },
]

export default class CreateNewEnquiry extends NavigationMixin(LightningElement) {
	@api recordId;
	@track showMain = false;
	@track showSpinner = true;
	@track showSpinner2 = false;
	@track showPopup = false;
	@track IsSubmitBtnFlag = false;
	@track IsPlaceOrderBtnFlag = true;
	@track IsDisableFields = false;
	@track IsSaveBtnFlag = true;
	@track buttonClickedName = '';
	//@track newEnquiry = false;
	@track recId;
	@track isAddItemModalOpen = false;
	@track isEditing = false;
	@track editIndex;
	@track addedItemList = [];
	@track modalData = {};
	@track itemMasterId = {};
	@track selectedRecordTypeId;
	@api recordTypeOptions = [];
	@api recordTypelabel = [];
	@track selectedOptions;
	@track selectedEnquiryTypeName = '';
	@track RecordTypeOptionsn = [];
	get addedItemListLength() {
		return this.addedItemList.length > 0;
	}

	@track doc_MainFile;
	@track doc_MainFileName;
	@track attachmentsTableDataArray = [];
	@track headerAttView = false;
	@track isAttachmentModalOpen = false;
	@track selectedRows = [];

	@track modalTableData = [];
	@track AllData = [];
	@track selectedModalRow = [];
	@track showrecentEnqItems = [];
	@track showFirstRecentEnqItems = '';
	columns = COLS;
	// cols = COLS;
	@track cols1 = COLS1;
	mobcolumns = MobCols;

	@track itemVariantOptions = [];  // To store combobox options
	@track modalData = {};
	@track dealerprice;

	@track paginationDataList;
	@track searchKey = '';
	@track dataForFilter;
	@track itemMasterId;
	page = 1;
	items = [];
	data = [];
	startingRecord = 1;
	endingRecord = 0;
	pageSize = 10;
	totalRecountCount = 0;
	totalPage = 0;

	@track endCustomerName = '';
	@track endCustomerOptions = [];

	@track fieldStaffCodeValue = '';
	@track customerId = '';
	@track customerType = '';
	@track contactId = null;
	@track fieldStaffCodeOptions = [];
	@track zonalManagerValue = '';
	@track areaManagerValue = '';

	@track objectname = 'Techno Commercial Offer';
	@track codeMasterData = []; // To store the processed results
	@track displayLabel;
	@track enquiryId = '';
	DocumentDate;

	@track isTechnoApprovalCompOpen = false;

	@track isApproved = false;
	@track isSalesEngineer = false;
	@track isNonSalesEngineer = false;

	@wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			console.log('OUTPUT : ', JSON.stringify(currentPageReference.state));
			if (currentPageReference.state.c__EnqId != null && currentPageReference.state.c__EnqId != undefined) {
				this.enquiryId = currentPageReference.state.c__EnqId;
			}
			if (currentPageReference.state.c__rectypeid != null && currentPageReference.state.c__rectypeid != undefined) {
				this.selectedRecordTypeId = currentPageReference.state.c__rectypeid;
			}
		}
	}

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
				recordId: this.enquiryId,
				objectApiName: 'Enquiry__c',
				actionName: 'view'
			}
		});
	}

	@track isMobile;
	connectedCallback() {

		this.isMobile = window.matchMedia('(max-width: 768px)').matches;

		const today = new Date();
		const year = today.getFullYear();
		const month = (today.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-based, so add 1
		const day = today.getDate().toString().padStart(2, '0');

		this.DocumentDate = `${year}-${month}-${day}`;
		this.loadRecordTypes();


		if (this.enquiryId != '') {

			setTimeout(() => {

				for (let index = 0; index < this.recordTypeOptions.length; index++) {
					let vall = this.recordTypeOptions[index].value;
					console.log(vall, '    ', this.selectedRecordTypeId);

					if (vall.includes(this.selectedRecordTypeId)) {
						this.selectedOptions = vall;
					}
				}

				let obj = {
					detail: {
						value: this.selectedOptions
					}
				};
				this.handleComboChange(obj);
				setTimeout(() => {
					this.handleCustomerChange('');
					if (this.enquiryId != '') {
						this.handlerGetTCOlineitems();
					}
				}, 1000);
			}, 1000);
		} else {
			this.getcodemaster();
			this.showSpinner = false;
		}

		// for checking current user is isApprover/manager
		isValidForApproval({
			soIdvar: ''
		}).then((res) => {
			console.log('OUTPUT : isValidForApproval ', JSON.parse(res));
			this.userdata = JSON.parse(res)
			this.isApproved = this.userdata.IsApprovedUser;
			if (this.userdata.profileName == 'Sales Engineer' || this.userdata.profileName == 'System Administrator') {
				this.isSalesEngineer = true;
				this.isNonSalesEngineer = false;
			} else {
				this.isNonSalesEngineer = true;
				this.isSalesEngineer = false;

			}
		})

		this.handleGetEnadCustomerList();

	}

	handleGetEnadCustomerList() {
		getEnadCustomerList().then((data) => {
			console.log('END CUSTOMER LIST:>>> ', data);
			this.endCustomerOptions = JSON.parse(data);
		})
	}

	handleEndCustomerChange(event) {
		const field = this.template.querySelector('[data-name="endcustomername"]');
		field.value = event.detail.value;
	}

	loadRecordTypes() {
		this.recordTypeOptions = [];
		this.recordTypelabel = [];


		getRecordTypes()
			.then(result => {
				// Check if result is a valid array
				if (Array.isArray(result)) {
					console.log('Record Types fetched:', result);

					// Map the result and log each Name
					this.recordTypeOptions = result.map(recordType => {
						// console.log('Record Type Name:', recordType.Name); // Print the name here
						// console.log('Record Type id:', recordType.Id);
						// if(recordType.Name =='Normal Enquiry'){
						// 	this.newEnquiry = true;
						// 	console.log('newEnquiry:', this.newEnquiry);
						// }else{
						// 	this.newEnquiry = false;
						// 	console.log('newEnquiry>>>:', this.newEnquiry);
						// }
						console.log('newEnquiry>>>:', this.newEnquiry);
						return {
							label: recordType.Name,
							value: recordType.Id
						};
					});

					console.log('Processed Record Type Options:', this.recordTypeOptions); // Print the processed options
				} else {
					console.error('Unexpected result format:', result);
				}
			})
			.catch(error => {
				console.error('Error fetching record types', error);
			});
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

	handlerGetTCOlineitems() {
		new Promise((resolve, reject) => {
			getTCOlineitems({
				tcoid: this.enquiryId
			}).then((result) => {
				this.addedItemList = JSON.parse(result);
				console.log('getTCOlineitems:>>> ', this.addedItemList);
				if (this.addedItemList && this.addedItemList.length > 0) {
					if (this.addedItemList[0].Enquiry__r.Status__c == 'Approved By Shivi Chaturvedi') {
						this.showToast('TCO Already Approved', '', 'info');
						this.navigateToRecordPage();
					} else if (this.addedItemList[0].Enquiry__r.Status__c == 'Rejected By Shivi Chaturvedi') {
						this.showToast('TCO Already Rejected', '', 'info');
						this.navigateToRecordPage();
					} else if (this.addedItemList[0].Enquiry__r.Status__c == 'Requested For Approval' || this.addedItemList[0].Enquiry__r.Status__c == 'Approved') {
						this.showToast('This TCO already send for approval to Shivi Chaturvedi', '', 'info');
						this.navigateToRecordPage();
					}
					let ind = 1;
					this.addedItemList.forEach(item => {
						item.Item_Variant_Name = item.Item_Variant__r.Code__c;
						item.SrNo = ind;
						ind++;
					});
				} else {
					this.showToast('No Line Item present', '', 'info');
					this.showSpinner = false;
					console.log('NO Line Item present');
				}
				resolve();
			}).catch((error) => {
				this.showSpinner = false;
				console.log('getTCOlineitems ERROR:> ', error);
			})
		}).then(() => {
			if (this.addedItemList[0].Enquiry__r.Is_Created_From_TSD__c) {
				this.headerAttView = true;
			}
			setTimeout(() => {
				this.fieldStaffCodeValue = this.addedItemList[0].Enquiry__r.Field_Staff_Code__c;
				this.handlerGetZonalManager();
			}, 2000);
		})
	}

	handleAttachmentViewModal(event) {
		this.showSpinner = true;

		window.scrollTo({
			top: 0,
			behavior: 'smooth', // Smooth scrolling
		});
		this.attachmentsTableDataArray = JSON.parse(this.addedItemList[0].Enquiry__r.Attachment_Link__c);
		console.log('attachmentsTableDataArray:>> ', this.attachmentsTableDataArray);
		if (this.attachmentsTableDataArray.length > 0) {
			this.isAttachmentModalOpen = true;
		} else {
			this.showToast('No Attachment', '', 'info');
		}

	}

	closeAttachmentModal() {
		this.isAttachmentModalOpen = false;
		this.showSpinner = false;
	}

	handleComboChange(event) {
		const selectedtype = this.recordTypeOptions.find(option => option.value === event.detail.value);
		const selectedTypeLabel = selectedtype ? selectedtype.label : '';


		this.selectedEnquiryTypeName = selectedTypeLabel;
		console.log('selectedEnquiryTypeName:>>> ', this.selectedEnquiryTypeName);


		this.selectedOptions = event.detail.value;
		this.showMain = true;

		//const selectedLabel = this.recordTypeMap[this.selectedOptions];

		// Add any additional logic you need based on the selected option
		if (this.selectedEnquiryTypeName == 'Normal Enquiry') {
			this.IsPlaceOrderBtnFlag = true; // this is also use for disable the price field coz in normal enq price could not be change
			this.IsSubmitBtnFlag = false;
			this.IsDisableFields = false;
		} else {
			this.IsPlaceOrderBtnFlag = false;
			this.IsSubmitBtnFlag = true;
			this.IsDisableFields = true;
		}
	}

	@wire(getObjectInfo, { objectApiName: ENQUIRY_OBJECT })
	objectInfo({ data, error }) {
		if (data) {
			// Get the record type ID by developer name
			const recordTypeId = Object.keys(data.recordTypeInfos).find(recordTypeId =>
				data.recordTypeInfos[recordTypeId].name === 'Techno_Commercial_Offer');
			this.recordTypeId = recordTypeId;
			console.log('recordTypeId>>>>>', this.recordTypeId);
		} else if (error) {
			console.error('Error retrieving record type info:', error);
		}
	}

	handleRadioChange(event) {
		this.showMain = false;
	}
	// ------------------------------ Add Items ------------------------------

	handleMainFileUpload(event) {
		this.doc_MainFile = null;
		this.doc_MainFileName = '';
		console.log(event.target.files[0].size);

		if (event.target.files.length > 0 && event.target.files[0].size < 3 * 1024 * 1024) {
			let files = [];
			// for (var i = 0; i < event.target.files.length; i++) {
			let file = event.target.files[0];
			let reader = new FileReader();
			reader.onload = e => {
				let base64 = 'base64,';
				let content = reader.result.indexOf(base64) + base64.length;
				let fileContents = reader.result.substring(content);
				let text = file.name;
				// let myArray = text.split(".");
				// let titleTemp = 'Document ' + myArray[myArray.length - 1];
				// this.doc_MainFileName = 'Document ' + myArray[myArray.length - 1];
				this.doc_MainFileName = text;
				this.doc_MainFile = { PathOnClient: file.name, Title: text, VersionData: fileContents };
			};
			reader.readAsDataURL(file);
			// }
		} else {
			this.showToast('File size should be less than 3MB', '', 'error');
		}
	}

	@track showItems = false;
	handleOpenAddNewItems() {
		let inputField1 = this.template.querySelector('[data-id="customerno"]');
		// let inputField2 = this.template.querySelector('[data-id="fieldstaffcode"]');
		// 
		if (this.fieldStaffCodeValue == null || this.fieldStaffCodeValue == '') {
			this.showToast('Customer and Sales Person (Field Staff) Required!', '', 'error');
		} else {
			this.showMain = true;
			this.clearModalData();
			if (this.isMobile) {
				this.isAddItemModalOpen = false;
				this.showItems = true;
			} else {
				this.isAddItemModalOpen = true;
				this.showItems = false;
			}

			this.handlerGetModalTableData();
		}
	}

	closeitems() {
		this.showItems = false;
	}

	clearForm() {
		if (this.isMobile) {
			this.showItems = false;
			this.modalData = null;
			setTimeout(() => {
				this.showItems = true;
			}, 2000);
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
				this.dataForFilter = data.dataList;
				this.paginiateData(JSON.stringify(this.AllData));
				resolve(result);
			}).catch((error) => {
				reject(error);
				this.showSpinner2 = false;
				this.showToast('Something went wrong!', error, 'error');
			})
		}).then(() => {
			this.showSpinner2 = false;
			// const element = this.template.querySelector('.scrollable-container');
			// // const ltable = this.template.querySelector('lightning-datatable');
			// const lpage = this.template.querySelector('.pagination-container');
			// console.log(element);
			// console.log(lpage);
			// element.classList.add('formob-scrollable-container');
			// lpage.classList.add('formob-pagination-container');
			// if (this.isMobile && element && lpage) {

			// }
		})
	}
	// handleOnRowSelection(event) {
	// 	console.log(event.detail.selectedRows);
	// 	this.selectedModalRow = event.detail.selectedRows;
	// 	console.log(this.selectedModalRow[0].Itemid);
	// 	console.log(this.selectedModalRow[0].ItemNo);
	// 	console.log(this.selectedModalRow[0].Description);
	// 	console.log(this.selectedModalRow[0].SUOM);
	// 	console.log(this.selectedModalRow[0].BUOM);
	// 	this.modalData.Item_No__c = this.selectedModalRow[0].ItemNo;
	// 	this.modalData.Item_Description__c = this.selectedModalRow[0].Description;
	// 	this.modalData.Sales_Unit_of_Measure__c = this.selectedModalRow[0].SUOM;
	// 	this.modalData.Base_Unit_of_Measure__c = this.selectedModalRow[0].BUOM;
	// }
	// handleRowAction(event) {
	// 	console.log(this.selectedModalRow[0].Itemid);
	// 	const actionName = event.detail.action.name;
	// 	const row = event.detail.row;
	// 	console.log('row',row);
	// 	if (actionName === 'view_details') {
	// 		this.handleButtonClick(row); // Ensure row is passed correctly
	// 	}
	// }
	// handleButtonClick(event) {
	// 	//const actionName = event.detail.action.name;
	// 	//const row = event.detail.row;

	// 	//columns = COLS1;
	// 	// if (actionName === 'view_details') {
	// 	// 	//this.showPopup(row);
	// 	// 	this.showPopup = true;
	// 	// }
	// 	console.log('insidebuttonclick',this.selectedModalRow[0].Itemid);
	// 	console.error('handleButtonClick found.',this.selectedModalRow);
	// 	console.log('selectedRows',event.detail.selectedRows);
	// 	   this.itemMasterId = this.selectedModalRow[0].Itemid;
	// 	console.error('Item Master ID found.',itemMasterId);
	// 	if (!itemMasterId) {
	// 		console.error('No Item Master ID found.');
	// 		return;
	// 	}

	// 	findRecentenqlineitem({ productId: itemMasterId })
	// 		.then(result => {
	// 			console.log('Apex Result:', result);

	// 			// Parse the result from JSON string to JavaScript array
	// 			let parsedResult = JSON.parse(result);

	// 			// Ensure parsedResult is an array
	// 			if (Array.isArray(parsedResult)) {
	// 				// Prepare the data for lightning-datatable
	// 				let formattedData = parsedResult.map(item => {
	// 					return {
	// 						...item,
	// 						EnquiryName: item.Enquiry__r ? item.Enquiry__r.Name : '',
	// 						EqName : item.Enquiry__r ? item.Enquiry__r.Enquiry_Name__c : '',
	// 						EnquiryAccount: item.Enquiry__r && item.Enquiry__r.Account__r ? item.Enquiry__r.Account__r.Name : ''
	// 					};
	// 				});

	// 				this.showrecentEnqItems = formattedData;
	// 				console.log('Recent Enquiry Items:', this.showrecentEnqItems);
	// 			} else {
	// 				console.error('Parsed result is not an array:', parsedResult);
	// 			}
	// 		})
	// 		.catch(error => {
	// 			console.error('Error:', error);
	// 		});

	// 	this.showPopup = true;
	// }
	// handleClose(){
	// 	this.showPopup = false;
	// }

	filterData() {
		console.log('filtervalues are', this.searchKey);
		// this.modalTableData = this.AllData;
		const searchTerm = this.searchKey.toLowerCase();
		if (searchTerm != '') {
			console.log('indside  1:>> ', this.modalTableData);
			// this.dataForFilter = this.modalTableData.filter(
			// 	row => Object.keys(row).some(ItemNo => row[ItemNo].includes(searchTerm))
			// );

			this.dataForFilter = this.AllData.filter(
				row => Object.values(row).some(value =>
					String(value).toLowerCase().includes(searchTerm)
				)
			);

			console.log('indside  2:>> ', this.dataForFilter);
			this.showErrorMsg = false;
			this.modalTableData = this.dataForFilter;
			console.log('indside  3:>> ', this.modalTableData);

			this.isProductSelect = false;
			// this.fillselectedRows();
			// this.RecalculateselectedProductCode();



			this.paginiateData(JSON.stringify(this.modalTableData));
			this.page = 1;
		} else {
			this.handlerGetModalTableData();
		}
	}

	fillselectedRows() {
		this.selectedRows = []
		for (let i = 0; i < this.modalTableData.length; i++) {
			if (this.selectedProductCode.includes(this.modalTableData[i].Id)) {
				this.selectedRows.push(this.modalTableData[i]);
			}
		}
	}

	// RecalculateselectedProductCode() {
	//     this.selectedProductCode = [];
	//     for (let i = 0; i < this.SelectedProductData.length; i++) {
	//         this.selectedProductCode.push(this.SelectedProductData[i].Id);
	//     }
	// }

	handleOnRowSelection(event) {
		console.log(event.detail.selectedRows);

		// Assuming only one row is selected at a time, if multiple rows can be selected, adjust the logic accordingly
		this.selectedModalRow = event.detail.selectedRows.length > 0 ? event.detail.selectedRows[0] : null;

		if (this.selectedModalRow) {
			// console.log(this.selectedModalRow.Itemid);
			// console.log(this.selectedModalRow.ItemNo);
			// console.log(this.selectedModalRow.Description);
			// console.log(this.selectedModalRow.SUOM);
			// console.log(this.selectedModalRow.BUOM);
			// console.log(this.modalData.Conversion_Quantity__c);


			// Assigning modalData values from the selected row
			this.modalData.Item_No__c = this.selectedModalRow.ItemNo;
			this.modalData.Item_Description__c = this.selectedModalRow.Description;
			// this.modalData.BUOM__c = this.selectedModalRow.BUOM;
			// this.modalData.SUOM__c = this.selectedModalRow.BUOM;
			this.modalData.Item_Master__c = this.selectedModalRow.Itemid;
			// this.modalData.Conversion_Quantity__c = this.modalData.Conversion_Factor__c * this.modalData.Qty__c;
		} else {
			console.error("No row selected.");
		}
		this.handleGetItemVariant(this.selectedModalRow.Itemid);
		this.handleDealerPrice(this.selectedModalRow.ItemNo, this.customerId);
	}

	handleGetItemVariant(pid) {
		new Promise((resolve, reject) => {
			getItemVariantOptions({
				productId: pid
			}).then((data) => {
				console.log('Option::>> ', data);

				let tdata = JSON.parse(data);
				//this.modalData.itemMaster = pid;
				this.itemVariantOptions = tdata;
				if (this.itemVariantOptions.length == 1) {
					let eve = {
						detail: {
							value: this.itemVariantOptions[0].value
						}
					}
					this.handlePicklistChange(eve);
				} else {

				}
				resolve();
			}).catch((error) => {

			})
		}).then(() => {

		})

	}
	handleDealerPrice(itemNo, custId) {
		new Promise((resolve, reject) => {
			getDealerPrice({
				ItemNo: itemNo,
				customerId: this.customerId
			}).then((data) => {
				console.log('dealerprice>> ', data);

				let dealerprice = JSON.parse(data);
				this.dealerprice = dealerprice;
				this.modalData.Standard_Dealer_Rate__c = dealerprice;
				this.modalData.Required_Rate_by_AM__c = dealerprice;

				//Discount_In_Percentage = ((Standard_Dealer_Rate - Dealer_Rate)/Standard_Dealer_Rate)*100
				//console.log('dealerprice',dealerprice);

				resolve();
			}).catch((error) => {

			})
		}).then(() => {

		})
	}


	handleRowAction(event) {
		const actionName = event.detail.action.name;
		const row = event.detail.row;

		// console.log('row:', row.Itemid);

		if (actionName === 'view_details') {
			this.handleButtonClick(row.Itemid); // Passing the row data correctly
		}
	}
	@track showPopupMobile = false;
	handleButtonClick(iId) {
		// console.log('Inside handleButtonClick:', this.selectedModalRow.Itemid);
		// let itemMasterId = this.selectedModalRow.Itemid;
		// console.error('No Item Master ID found.', itemMasterId);
		let itemMasterId = iId;
		if (itemMasterId == null) {
			console.error('No Item Master ID found.');
			return;
		}

		// Calling the Apex method to get recent enquiry line items
		findRecentenqlineitem({
			productId: itemMasterId,
			custId: this.customerId
		}).then(result => {
			console.log('Apex Result:', result);

			// Parse the result from JSON string to JavaScript array
			let parsedResult = JSON.parse(result);

			// Ensure parsedResult is an array
			if (Array.isArray(parsedResult)) {
				// Prepare the data for lightning-datatable
				let formattedData = parsedResult.map(item => ({
					...item,
					EnquiryName: item.Enquiry__r ? item.Enquiry__r.Name : '',
					EqName: item.Enquiry__r ? item.Enquiry__r.Enquiry_Name__c : '',
					EnquiryAccount: item.Enquiry__r && item.Enquiry__r.Account__r ? item.Enquiry__r.Account__r.Name : ''
				}));
				console.log('Recent Enquiry Items>>:', formattedData);
				this.showrecentEnqItems = formattedData;
				if (this.showrecentEnqItems.length > 0) {
					this.showFirstRecentEnqItems = this.showrecentEnqItems[0];
				}
				console.log('Recent Enquiry Items:', this.showrecentEnqItems);
			} else {
				console.error('Parsed result is not an array:', parsedResult);
			}
		}).catch(error => {
			console.error('Error:', error);
		});


		// if (this.selectedModalRow) {
		// } else {
		// 	console.error('No row selected before button click.');
		// }
		if (this.isMobile) {
			this.showPopupMobile = true;
			this.showPopup = false;
			window.scrollTo({
				top: 0,
				behavior: 'smooth', // Smooth scrolling
			});
		} else {
			this.showPopup = true; // Show the modal popup
			this.showPopupMobile = false;
		}
	}

	handleClose() {
		this.showPopup = false; // Close the modal
		this.showPopupMobile = false;
	}



	handleCloseAddNewItems() {
		this.showMain = true;
		this.isAddItemModalOpen = false;
		this.modalData = {};
		this.isEditing = false;
		this.editIndex = null;
		if (this.isMobile) { //
			// this.showItems = true;
		} else {
			this.showItems = false;
		}
	}

	handleModalInputChange(event) {
		console.log(event.target.fieldName);

		const field = event.target.fieldName;
		this.modalData[field] = event.target.value;

		if (field == 'Qty__c' || field == 'Required_Rate_by_AM__c') {
			this.modalData.Conversion_Quantity__c = parseFloat(this.modalData.Conversion_Factor__c) * parseFloat(this.modalData.Qty__c);
			this.modalData.Item_Value__c = parseFloat(this.modalData.Conversion_Quantity__c) * parseFloat(this.modalData.Required_Rate_by_AM__c);
		}

		if (this.selectedEnquiryTypeName == 'Techno Commercial Offer') {
			this.modalData.Discount_In_Percentage__c = ((parseFloat(this.modalData.Standard_Dealer_Rate__c) - parseFloat(this.modalData.Required_Rate_by_AM__c)) / parseFloat(this.modalData.Standard_Dealer_Rate__c)) * 100;
			let dval = this.modalData.Discount_In_Percentage__c;
			this.modalData.Discount_In_Percentage__c = dval.toFixed(2);
		} else {
			this.modalData.Discount_In_Percentage__c = 0;
		}
	}

	handleSaveModalData(event) {
		console.log(this.modalData.Qty__c);
		console.log(this.modalData.Dealer_Price__c);
		console.log(this.modalData.Item_Variant__c);
		console.log(this.modalData.Discount_In_Percentage__c);

		if (this.modalData.Qty__c == undefined || this.modalData.Qty__c == '' || this.modalData.Qty__c == null) {

			this.showToast('Qty Required!', '', 'error');

		} else if (this.modalData.Required_Rate_by_AM__c == undefined || this.modalData.Required_Rate_by_AM__c == '' || this.modalData.Required_Rate_by_AM__c == null) {

			this.showToast('Dealer Rate Required!', '', 'error');

		} else if (this.modalData.Item_Variant__c == undefined || this.modalData.Item_Variant__c == '' || this.modalData.Item_Variant__c == null) {
			this.showToast('Item Variant Required!', '', 'error');

		} else {

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
			if (event.currentTarget.dataset.btnname == 'Add') {
				this.selectedModalRow = [];
				this.modalData = {};
				this.isEditing = false;
				this.editIndex = null;
				if (this.isMobile) { //
					// this.showItems = true;
				} else {
					this.showItems = false;
				}
				this.clearModalData();
			} else if (event.currentTarget.dataset.btnname == 'Save') {
				this.showItems = false;
				this.handleCloseAddNewItems();
			}
			console.log('Newly Added addedItemList:>>> ', this.addedItemList);
		}

	}

	handleRemoveRow(event) {
		this.showMain = true;
		const index = event.currentTarget.dataset.index;
		let lineItemId = this.addedItemList[index].Id;
		if (lineItemId != undefined) {
			deleteENQLI({
				Id: lineItemId
			}).then((data) => {
				console.log('delete ENQ LI data:>>> ', data);
			}).catch((error) => {
				console.log('delete ENQ LI error:>>> ', error);
			})
		}
		this.addedItemList.splice(index, 1);
		this.addedItemList = [...this.addedItemList];
		let ind = 1;
		this.addedItemList.forEach(item => {
			item.SrNo = ind;
			ind++;
		});
		// this.showMain = false;
		console.log('After delete addedItemList:>>> ', this.addedItemList);
	}

	handleEditRow(event) {
		this.handleOpenAddNewItems();
		this.showMain = true;
		const index = event.currentTarget.dataset.index;
		this.modalData = { ...this.addedItemList[index] };
		this.isEditing = true;
		this.editIndex = index;
		console.log(this.modalData);

		this.handleGetItemVariant(this.modalData.Item_Master__c);
		// this.showMain = false;
	}

	// ------------------------------ Add Items End ------------------------------

	handleLookupChange(event) { }

	handleCustomerChange(event) {
		// console.log(event.detail.name);

		// Get the selected Account ID from the input field
		const accountField = this.template.querySelector('[data-id="accountField"]');
		this.customerId = accountField.value;
		console.log('Selected Account ID:', this.customerId);
		if (this.customerId != null && this.customerId != '') {
			this.handlerGetFieldStaffCodeByCustomer();
			this.handlerGetContact();
		} else {
			this.fieldStaffCodeOptions = [];
			this.fieldStaffCodeValue = '';
			this.zonalManagerValue = '';
			this.areaManagerValue = '';
		}
	}

	handlerGetContact() {
		new Promise((resolve, reject) => {
			getContact({
				customerId: this.customerId
			}).then((data) => {
				console.log('Contact data:>>> ', data);
				if (data != '') {
					let tempdata = JSON.parse(data);
					this.contactId = tempdata.Id;
				}
				resolve(data);
			}).catch((error) => {
			})
		}).then(() => {

		})
	}

	handlerGetFieldStaffCodeByCustomer() {
		new Promise((resolve, reject) => {
			getFieldStaffCode({
				custId: this.customerId
			}).then((data) => {
				console.log('data:>>> ', data);
				if (data != '') {
					let tempdata = JSON.parse(data);
					console.log(tempdata[tempdata.length - 1]);

					this.fieldStaffCodeOptions = tempdata;
					if (tempdata.length == 1) {
						this.fieldStaffCodeValue = tempdata[0].value;
					} else {
						this.fieldStaffCodeValue = '';
					}
				} else {

				}
				resolve(data);
			}).catch((error) => {
				reject(error);
			})
		}).then(() => {
			if (this.fieldStaffCodeValue != '') {
				this.handlerGetZonalManager();
			}
		})
	}

	handleFieldStaffCodeChange(event) {
		this.fieldStaffCodeValue = event.target.value;
		if (this.fieldStaffCodeValue != '') {
			this.handlerGetZonalManager();
		}
	}

	handlerGetZonalManager() {
		new Promise((resolve, reject) => {
			getZonalManager({
				staffId: this.fieldStaffCodeValue
			}).then((data) => {
				console.log('data:>>> ', data);
				let tdata = data.split(';');
				this.zonalManagerValue = tdata[0];
				this.areaManagerValue = tdata[1];
				resolve(data);
			}).catch((error) => {
				console.log('ERROR getZonalManager:>> ', error);
				this.showSpinner = false;
				reject(error);
			})
		}).then(() => {
			this.showSpinner = false;
			const field = this.template.querySelector('[data-name="endcustomername"]');
			console.log('endcustomername valueee:>>> ', field.value);
			this.endCustomerName = field.value;
		})
	}

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
		this.clearModalData();
		if (this.page > 1) {
			this.page = this.page - 1;
			//console.log('this.SelectedProductData 611', this.SelectedProductData.length);
			this.recordPerPage(this.page, this.paginationDataList);
		}
	}

	nextHandler() {
		this.clearModalData();
		if ((this.page < this.totalPage) && this.page !== this.totalPage) {
			this.page = this.page + 1;
			//console.log('this.SelectedProductData 619', this.SelectedProductData.length);
			this.recordPerPage(this.page, this.paginationDataList);
		}
	}

	clearModalData() {
		const table1 = this.template.querySelector('lightning-datatable[data-id="table1"]');
		const table2 = this.template.querySelector('lightning-datatable[data-id="table2"]');
		if (table1) {
			table1.selectedRows = [];
		}
		if (table2) {
			table2.selectedRows = [];
		}
		this.modalData.Item_No__c = '';
		this.modalData.Item_Description__c = '';
		this.modalData.Item_Master__c = '';
		this.modalData.Standard_Dealer_Rate__c = '';
		this.modalData.Required_Rate_by_AM__c = '';
		this.modalData.Item_Variant__c = '';
		this.modalData.BUOM__c = '';
		this.modalData.SUOM__c = '';
		this.modalData.Conversion_Factor__c = '';
		this.modalData.Conversion_Quantity__c = '';
		this.modalData.Item_Value__c = '';
		this.modalData.Qty__c = '';
		this.searchKey = '';
		this.selectedModalRow = [];
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
		this.clearModalData();
		if (event.keyCode == 13) {
			this.isFirstPage = false;
			this.showErrorMsg = false;
		} else {
			//this.handleKeyChange(event);
			this.searchKey = event.target.value;
			this.filterData();
			// const searchBoxWrapper = this.template.querySelector('.lookupContainer');
			// searchBoxWrapper.classList.add('slds-show');
			// searchBoxWrapper.classList.remove('slds-hide');
		}
	}

	handleMainOnSubmit(event) {
		this.buttonClickedName = event.currentTarget.dataset.btnname;
		console.log('Submit button clicked:> ', event.currentTarget.dataset.btnname);
		event.preventDefault(); // Prevent the default form submission behavior
		const lwcInputFields = this.template.querySelectorAll('lightning-input-field');
		let validationflag = false;
		let emptyFieldName = '';

		console.log('Record ID on submit:', this.recordId);

		if (this.addedItemList.length == 0) {
			this.showToast('Please add at least one item', '', 'error');
			validationflag = true;
		} else if (lwcInputFields) {
			// lwcInputFields.forEach(field => {
			// 	if (field.fieldName == 'End_Customer_Name__c') {
			// 		if (field.value == null || field.value == '') {
			// 			validationflag = true;
			// 			emptyFieldName = 'End Customer Name';
			// 		}
			// 	}
			// 	field.reportValidity();
			// });
		}

		if (validationflag) {
			if (emptyFieldName != '') {
				this.showToast(emptyFieldName + ' Required!', '', 'error');
			}
			// return;
			console.log(this.selectedEnquiryTypeName);
			console.log(this.buttonClickedName);

		} else {
			const form1 = this.template.querySelector('lightning-record-edit-form[data-id="form1"]');

			const fields = {};
			if (this.enquiryId == '') {
				// Use dynamically retrieved RecordTypeId instead of hardcoding it
				fields.RecordTypeId = this.recordTypeId; // Dynamically set Record Type ID
				fields.Field_Staff_Code__c = this.fieldStaffCodeValue; // Dynamically set Customer
				fields.Zonal_Head__c = this.zonalManagerValue; // Dynamically set Zonal Manager
				fields.Area_Manager__c = this.areaManagerValue; // Dynamically set Area Manager
				if (this.selectedEnquiryTypeName == 'Techno Commercial Offer') {
					// fields.Status__c = 'Requested For Approval';
					fields.Status__c = 'Drafted';
				}
				fields.SubmittedBy__c = this.fieldStaffCodeValue;
				const now = new Date();
				const formattedDateTime = now.toISOString();
				fields.SubmittedOn__c = formattedDateTime;
				fields.Submittedby_Customer__c = this.customerId;
				fields.PreparedBy__c = this.fieldStaffCodeValue;
				fields.Contact__c = this.contactId;
			}
			fields.IsSubmit__c = true;
			lwcInputFields.forEach(field => {
				fields[field.fieldName] = field.value;
			});

			form1.submit(fields);
		}
	}

	// @wire(getItemVariantOptions, { productId: '$itemMasterId'})
	// wiredItemVariantOptions({ error, data }) {
	//     if (data) {
	//         this.itemVariantOptions = data.map(option => {
	//             return { label: option.label, value: option.value };
	//         });
	//     } else if (error) {
	//         console.error('Error fetching item variants:', error);
	//     }
	// }

	handlePicklistChange(event) {
		// console.log(event.detail.name);

		this.modalData.Item_Variant__c = event.detail.value;

		this.handlerGetConversionFactor();

		const selectedOption = this.itemVariantOptions.find(option => option.value === this.modalData.Item_Variant__c);
		const selectedLabel = selectedOption ? selectedOption.label : '';

		this.modalData.Item_Variant_Name = selectedLabel;

	}

	handlerGetConversionFactor() {
		new Promise((resolve, reject) => {

			getConversionFactor({
				varId: this.modalData.Item_Variant__c
			}).then((data) => {
				console.log('ConversionFactor::>> ', data);
				let tdata = JSON.parse(data);
				if (tdata != '') {
					this.modalData.BUOM__c = tdata.UOM__c;
					this.modalData.SUOM__c = tdata.Sales_UOM__c;
					this.modalData.Conversion_Factor__c = tdata.Qty_in_SOUM__c;
				}
				resolve(data);
			})

		}).then(() => {
			this.modalData.Conversion_Quantity__c = parseFloat(this.modalData.Conversion_Factor__c) * parseFloat(this.modalData.Qty__c);
			this.modalData.Item_Value__c = parseFloat(this.modalData.Conversion_Quantity__c) * parseFloat(this.modalData.Required_Rate_by_AM__c);
		})
	}


	handleMainOnSuccess(event) {
		// this.showMain = false;
		const updatedRecordId = event.detail.id;
		console.log('Record saved successfully:', updatedRecordId);
		console.log('addedItemList', this.addedItemList);
		// this.showMain = true;
		// console.log('0');

		let tempissync;
		if (this.buttonClickedName == 'submitbtn') {
			// console.log('1');
			if (this.enquiryId != '' && this.addedItemList.length > 0 && this.addedItemList[0].Enquiry__r.Is_Created_From_TSD__c) {
				// console.log('2');
				tempissync = false;
				// console.log('3');
			} else {
				// console.log('4');
				tempissync = true;
				// console.log('5');
			}
		} else {
			// console.log('6');
			tempissync = false;
		}

		new Promise((resolve, reject) => {
			addFile_n_LineItems({
				Id: updatedRecordId,
				mdoc: this.doc_MainFile != undefined ? JSON.stringify(this.doc_MainFile) : '',
				lineitemlist: this.addedItemList.length > 0 ? JSON.stringify(this.addedItemList) : '',
				issync: tempissync
			}).then((result) => {
				console.log('result:>>> ', result);
				resolve(result);
			}).catch((error) => {
				console.log('addFile_n_LineItems error:>>> ', error);
				this.showToast('Something went wrong!', '', 'error');
				this.showSpinner = false;
				reject(error);
				// this.showMain = false;
			});
		}).then(() => {
			//this.template.querySelector('lightning-record-edit-form[data-id="form1"]').reset();
			setTimeout(() => {
				// this.showMain = false;
				if (this.selectedEnquiryTypeName == 'Techno Commercial Offer') {
					// this.navigateToRecordPage();
					if (this.buttonClickedName == 'submitbtn') {
						if (this.isApproved && this.enquiryId != '' && this.addedItemList.length > 0 && this.addedItemList[0].Enquiry__r.Is_Created_From_TSD__c) {
							this.isTechnoApprovalCompOpen = true;
							this.enquiryId = updatedRecordId;
						} else {
							this[NavigationMixin.Navigate]({
								type: 'standard__recordPage',
								attributes: {
									recordId: updatedRecordId,
									objectApiName: 'Enquiry__c',
									actionName: 'view'
								}
							});
						}
					} else if (this.buttonClickedName == 'savebtn') {
						this[NavigationMixin.Navigate]({
							type: 'standard__recordPage',
							attributes: {
								recordId: updatedRecordId,
								objectApiName: 'Enquiry__c',
								actionName: 'view'
							}
						});
					}

				} else {
					//this.IsSubmitBtnFlag = true;
					//this.IsPlaceOrderBtnFlag = false;

					console.log('After Line Item creation :> ', this.buttonClickedName);

					if (this.buttonClickedName == 'savebtn') {

						this[NavigationMixin.Navigate]({
							type: 'standard__recordPage',
							attributes: {
								recordId: updatedRecordId,
								objectApiName: 'Enquiry__c',
								actionName: 'view'
							}
						});

					} else if (this.buttonClickedName == 'createorderbtn') {

						createOrderFromEnquiry({
							enquiryId: updatedRecordId
						}).then((result) => {
							console.log('OUTPUT createOrderFromEnquiry: ', result);
							console.log('OUTPUT addedItemList: ', this.addedItemList);
							addsaleorderlineItems({
								Id: result,
								lineitemlist: this.addedItemList.length > 0 ? JSON.stringify(this.addedItemList) : '', URL: ''
							}).then((res) => {
								const selectedtype = this.recordTypeOptions.find(option => option.label === this.selectedEnquiryTypeName);
								var url = LABEL_CUSTURL + '/lightning/n/Create_Sales_Order?c__enquiryId=' + updatedRecordId + '&c__accountId=' + this.customerId + '&c__recordtypeId=' + selectedtype.value + '&c__orderId=' + result;
								// var url = 'https://dream-inspiration-9915.lightning.force.com/lightning/n/Create_Sales_Order?c__enquiryId=' + updatedRecordId + '&c__accountId=' + this.customerId + '&c__recordtypeId=' + selectedtype.value + '&c__orderId=' + result;
								window.open(url);
							}).catch((err) => {
								console.log('OUTPUT err: ', err);
							})
						})
					}

				}
			}, 500);
		})



		this.dispatchEvent(
			new ShowToastEvent({
				title: 'Success',
				message: 'Record saved successfully.',
				variant: 'success',
			})
		);
		// window.location.reload();

	}

	handleMainClick() {
		if (!this.isMobile) {
			// Navigate to the Enquiry list view
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'Enquiry__c',
					actionName: 'list'
				}
			});
		} else {
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'Enquiry__c',
					actionName: 'home'
				}
			});
		}
	}


	@track isplacedOrderClick = false;
	closeModal() {
		this.isplacedOrderClick = false;
	}

	@track isTSDResponse = null;
	handlerNavResponse(event) {
		this.isTSDResponse = event.detail.resmsg;

	}

	@track isTCOapprovalResponse = null;
	handlerTCOApprovalResponse(event) {
		this.isTCOapprovalResponse = event.detail.resmsg;

	}

	closeTACmodal() {
		this.isTechnoApprovalCompOpen = false;
		if (this.isTCOapprovalResponse == 'TCO has been sent to Shivi for Approval') {
			this.navigateToRecordPage();
		} else {
			window.location.reload();
		}
	}

	// handleReplaceEvent(event){
	//     const inputField = event.target;
	//     let value = inputField.value;

	//     // Restrict "&" character
	//     if (value.includes('&')) {
	//         // Replace "&" with an empty string or another character (e.g., "and")
	//         value = value.replace(/&/g, '&amp;');

	//         // Assign the sanitized value back to the field
	//         inputField.value = value;
	//      }
	//      console.log('= >',value);
	//      console.log('= >',inputField.value);

	// }



}