import {
	LightningElement,
	api,
	wire,
	track
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


import getApprovalStatus from "@salesforce/apex/AddSalesOrder.getApprovalStatus";
import getRateType from "@salesforce/apex/AddSalesOrder.getRateType";
import getItemVariantOptions from "@salesforce/apex/TechCommOfferController.getItemVariantOptions";
import getConversionFactor from "@salesforce/apex/TechCommOfferController.getConversionFactor";
import getVariantList from "@salesforce/apex/AddSalesOrder.getVariantList";
import getShipmentCodeList from "@salesforce/apex/AddSalesOrder.getShipmentCodeList";
import getIsWithRevision from "@salesforce/apex/AddSalesOrder.getIsWithRevision";
import getselectedTechnoCommercialOffer from "@salesforce/apex/AddSalesOrder.getselectedTechnoCommercialOffer";
import getStdSalesOrderLineItem from "@salesforce/apex/AddSalesOrder.getStdSalesOrderLineItem";
import addsaleorderlineItems from "@salesforce/apex/AddSalesOrder.addsaleorderlineItems";
import addSOLIattachments from "@salesforce/apex/AddSalesOrder.addSOLIattachments";
import getAddress from "@salesforce/apex/AddSalesOrder.getAddress";
import getZonalnAreaManager from "@salesforce/apex/AddSalesOrder.getZonalnAreaManager";
import getcodemaster from "@salesforce/apex/AddSalesOrder.getcodemaster";
import getSOLI from "@salesforce/apex/AddSalesOrder.getSOLI";
import deleteSOLI from "@salesforce/apex/AddSalesOrder.deleteSOLI";
import getSOheaderAtt from "@salesforce/apex/AddSalesOrder.getSOheaderAtt";
import isValidForApproval from "@salesforce/apex/AddSalesOrder.isValidForApproval";
import insertStandardSalesOrderToTSD from "@salesforce/apex/CreateSalesOrder_ToTSDportal.insertStandardSalesOrderToTSD";
import getSOCreatedBy from "@salesforce/apex/CreateSalesOrder_ToTSDportal.getSOCreatedBy";
import salesOrderApproval from "@salesforce/apex/IntegrationHandler.salesOrderApproval";
import updateSalesOrderApprovalStatus from "@salesforce/apex/IntegrationHandler.updateSalesOrderApprovalStatus";
import getShipToCodeDetail from "@salesforce/apex/AddSalesOrder.getShipToCodeDetail";
import getSetShiptoCodeData from "@salesforce/apex/AddSalesOrder.getSetShiptoCodeData";

import getEnadCustomerList from "@salesforce/apex/TechCommOfferController.getEnadCustomerList";

import {
	getRecord
} from 'lightning/uiRecordApi';
import Sales_Order_Doc_No from '@salesforce/schema/Sales_Order__c.Sales_Document_Number__c';
import Is_Created_From_TSD from '@salesforce/schema/Sales_Order__c.Is_Created_From_TSD__c';
import Attachment_LINK from '@salesforce/schema/Sales_Order__c.Attachment_Link__c';
import Status_FIELD from '@salesforce/schema/Sales_Order__c.Status__c';
import IS_APPROVED_FIELD from '@salesforce/schema/User.IsApprovedUser__c';
import USER_ID from '@salesforce/user/Id';


const Cols = [
	// {
	//     label: 'Select',
	//     type: 'radioButton', // Custom data type
	//     fieldName: 'select', // The field name that will be used to bind this column
	//     typeAttributes: {
	//         name: 'radioButtonGroup',
	//         value: { fieldName: 'id' }, // Bind the value of the radio button to the row's id
	//         checked: { fieldName: 'isSelected' }, // Bind the checked state to a row attribute
	//         onChange: { fieldName: 'handleRadioChange' } // Method to call on radio button change
	//     },
	//     initialWidth: 70
	// },
	// { label: 'Techo Document No', fieldName: 'technoCName', type: 'text', initialWidth: 300, sortable: true },
	{
		label: 'Item No',
		fieldName: 'ItemNo',
		type: 'text',
		initialWidth: 200,
		sortable: true
	},
	{
		label: 'Description',
		fieldName: 'Description',
		type: 'text',
		initialWidth: 400,
		sortable: true
	},
	{
		label: 'Remaining Qty',
		fieldName: 'RemQty',
		type: 'text',
		initialWidth: 200,
		sortable: true
	},
	{
		label: 'Actual Qty',
		fieldName: 'Qty',
		type: 'text',
		initialWidth: 200,
		sortable: true
	},

]

const MobCols = [{
	label: 'Item No',
	fieldName: 'ItemNo',
	type: 'text',
	initialWidth: 100,
	sortable: true
},
{
	label: 'Description',
	fieldName: 'Description',
	type: 'text',
	initialWidth: 350,
	sortable: true
},
{
	label: 'Remaining Qty',
	fieldName: 'RemQty',
	type: 'text',
	initialWidth: 100,
	sortable: true
},
{
	label: 'Actual Qty',
	fieldName: 'Qty',
	type: 'text',
	initialWidth: 100,
	sortable: true
},
	// { label: 'Qty', fieldName: 'Qty', type: 'text', initialWidth: 50, sortable: true },
]




export default class CreateSalesOrder extends NavigationMixin(LightningElement) {
	@api param1;
	@track recId = '';
	@track salesOrderDocumentNumber = '';
	@track isnewproductmodelOpen = false;
	@track showSpinner = false;
	@track showSpinner2 = false;
	@track selectedRowData;
	@track NewProductList = [{
		index: 0,
		Item_Master__c: '',
		Item_Description__c: ''
	}];
	@track buttonClickedName = '';
	@track showTableProduct = [];
	@track attachmentsTableDataArray = [];
	@track headerAttView = false;
	@track lineItemAttArray = [];
	@track isAttachmentModalOpen = false;
	@track addedItemList = [];
	@track showTechnoCommercialoffer = [];
	@track submittedServiceData = [];
	@track selectedModalRow = [];
	@track AllData = [];
	@track rateType = ''; // Track the rate type
	@track allowCreateOrder;
	@track showTechnoCommercialField = false; // To control visibility of Techno_Commercial_Offer__c field
	@track selectedTechnoCommercialOffer = ''; // Track selected Techno Commercial Offer
	@track modalData = {};
	@track doc_MainFile;
	@track doc_MainFileName;
	orderBookingDate;
	poDate;

	get addedItemListLength() {
		return this.addedItemList.length > 0;
	}
	columns = Cols;
	mobcolumns = MobCols;

	@track isPriceChangeModalOpen = false;
	@track EnquiryId;
	@track AccountId;
	@track rate;
	@track city;
	@track accountDetail = '';
	@track rateType
	@track modalTableData = [];
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
	@track objectname = 'Sales Order';
	//modalData = {};
	@track codeMasterData = []; // To store the processed results
	@track displayLabel;

	@track areaManagerOptions = [];
	@track areaManagerValue = '';
	@track salesPersonOptions = [];
	@track salesPersonValue = '';
	@track lrDestinationValue = '';
	@track transporterValue = '';
	@track zonalHeadOptions = [];
	@track zonalHeadValue = '';
	@track shipmentCodeListOptions = [];
	@track shipmentCodeListValue = '';
	@track shipmentCodeValue = '';

	@track itemVariantOptions = [];

	userId = USER_ID; // Get current user's Id automatically
	isApproved = false;
	@track isPlaceOrderBtnFlag = false;
	@track isRejectOrderBtnFlag = false;
	@track userdata;
	@track isCreatedFromTSD;
	@track isHeaderAttLinkPresent;
	@track salesOrderStatus;

	@track isplacedOrderClick = false;
	@track pushToNavDisabled = true;
	@track isTSDResponse = null;

	@track isNonSalesEngineer = false;
	@track isSalesEngineer = false;

	@track orderValueAmt = 0;
	@track discountValueAmt = 0;
	@track orderValueGSTAmt = 0;

	@track endCustomerOptions = [];
	@track endCustomerNameValue = '';

	get acceptedFormats() {
		return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx'];
	}

	@wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			this.EnquiryId = currentPageReference.state.c__enquiryId;
			this.AccountId = currentPageReference.state.c__accountId;
			this.recordtype = currentPageReference.state.c__recordtypeId;
			console.log('OUTPUT : ', JSON.stringify(currentPageReference.state));
			if (currentPageReference.state.c__orderId != null && currentPageReference.state.c__orderId != undefined) {
				this.recId = currentPageReference.state.c__orderId;

			} else {
				//console.log('OUTPUT : ', JSON.stringify(this.userdata));
				// this.isRejectOrderBtnFlag = true;
				// this.isApproved=this.userdata.fields.IsApprovedUser__c.value
			}
			isValidForApproval({
				soIdvar: this.recId
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
			// if(this.recordtype =='012F3000002BKRf'){
			//     this.rateType = 'Special Rate';
			// }else{
			//     this.rateType = 'Standard Rate';
			// }
			console.log('this.EnquiryId', this.EnquiryId);
			console.log('this.AccountId', this.AccountId);
			console.log('this.recordtype', this.recordtype);
		}
	}

	// Use @wire to get the record data
	@wire(getRecord, {
		recordId: '$recId',
		fields: [Attachment_LINK, Is_Created_From_TSD, Status_FIELD, Sales_Order_Doc_No]
	})
	wiredRecord({
		error,
		data
	}) {
		if (data) {
			// Access field value
			this.isCreatedFromTSD = data.fields.Is_Created_From_TSD__c.value; // Replace with your field name
			if (this.isCreatedFromTSD) {
				if (data.fields.Attachment_Link__c.value != null) {
					this.isHeaderAttLinkPresent = true;
				} else {
					this.isHeaderAttLinkPresent = false;
				}
			} else {
				this.isHeaderAttLinkPresent = false;
			}
			this.salesOrderStatus = data.fields.Status__c.value; // Replace with your field name
			this.salesOrderDocumentNumber = data.fields.Sales_Document_Number__c.value; // Replace with your field name
			console.log('salesOrderDocumentNumber:>>> ', this.salesOrderDocumentNumber);
			console.log('salesOrderStatus:>>> ', this.salesOrderStatus);
			if (this.salesOrderStatus == 'Approved') {
				this.isRejectOrderBtnFlag = true;
			} else if (this.salesOrderStatus == 'Rejected') {
				this.isPlaceOrderBtnFlag = true;
				this.isRejectOrderBtnFlag = true;
			}

		} else if (error) {
			console.error('Error retrieving record', error);
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
				recordId: this.recId,
				objectApiName: 'Sales_Order__c',
				actionName: 'view'
			}
		});
	}


	@track isMobile;
	connectedCallback() {

		this.isMobile = window.matchMedia('(max-width: 768px)').matches;
		if (this.isMobile) {
			// Add an event listener for the browser back button
			window.onpopstate = this.handleBackButton.bind(this);
		}

		// this.updateColumns();
		const today = new Date();
		const year = today.getFullYear();
		const month = (today.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-based, so add 1
		const day = today.getDate().toString().padStart(2, '0');

		this.orderBookingDate = `${year}-${month}-${day}`; // Format YYYY-MM-DD
		this.poDate = `${year}-${month}-${day}`; // Format YYYY-MM-DD

		this.isnewproductmodelOpen = false;
		console.log('recid', this.recId);
		new Promise((resolve, reject) => {
			getApprovalStatus({
				EnqId: this.EnquiryId
			}).then((result) => {
				console.log('getApprovalStatus:: ', this.recordTypeName);
				console.log('getApprovalStatus:: ', result);
				let data = JSON.parse(result);
				this.allowCreateOrder = data.retData;
				// this.endCustomerNameValue = data.endCustomerName;
				// if (!data) {
				// this.showToast('TCO not Approved yet', '', 'error');
				// this[NavigationMixin.Navigate]({
				//     type: 'standard__recordPage',
				//     attributes: {
				//         recordId: this.EnquiryId,
				//         objectApiName: 'Enquiry__c',
				//         actionName: 'view'
				//     }
				// });
				// }
			})
		})
		this.getcodemaster();
		this.getaccAddress();
		this.getRateType();
		this.handlerGetShipmentCode();
		if (this.recId != '' && this.recId != null) {
			this.handlerGetSalesOrderLineItem();
		} else {
			// console.log('endcustomername valueee:>>> ', field.value);
		}
		this.showSpinner = true;
		setTimeout(() => {
			this.handleGetEnadCustomerList();
		}, 5000);
	}

	// ----------- End Customer changes -----------------
	handleGetEnadCustomerList() {
		getEnadCustomerList().then((data) => {
			console.log('END CUSTOMER LIST:>>> ', data);
			this.endCustomerOptions = JSON.parse(data);
			const field = this.template.querySelector('[data-name="endcustomername"]');
			this.endCustomerNameValue = field.value;
			this.showSpinner = false;
		})
	}

	handleEndCustomerChange(event) {
		const field = this.template.querySelector('[data-name="endcustomername"]');
		field.value = event.detail.value;
		this.endCustomerNameValue = event.detail.value;
	}
	// ----------- End Customer changes -----------------

	handlerGetSalesOrderLineItem() {
		new Promise((resolve, reject) => {

			getSOLI({
				soid: this.recId
			}).then((result) => {

				let tempdata = JSON.parse(result);
				// this.addedItemList = JSON.parse(result);
				this.addedItemList = tempdata.map(record => {
					let displayDiscount = 0;
					if (record.Cash_Discount__c) {
						displayDiscount = record.Cash_Discount__c;
					} else if (record.Discount_In_Percentage__c) {
						displayDiscount = record.Discount_In_Percentage__c;
					}
					return {
						...record,
						displayDiscount: displayDiscount
					};
				});
				console.log('SalesOrder Line Items:>> ', this.addedItemList);
				this.salesPersonValue = this.addedItemList[0].Sales_Order__r.Enquiry__r.Field_Staff_Code__c;
				if (this.addedItemList[0].Sales_Order__r.Created_to_NAV__c && (this.addedItemList[0].Sales_Order__r.Created_to_TSD__c || this.isCreatedFromTSD)) {
					this.showToast('This Order is already placed', '', 'info');
					this.navigateToRecordPage();
				}
				this.handleGetZonalnAreaManager();
				this.handleGetShipmentCode();
				let ind = 1;
				this.addedItemList.forEach(item => {
					item.Item_Variant_Name = item.Item_Variant__r.Code__c;
					item.SrNo = ind;
					ind++;
				});
				resolve();
			})

		}).then(() => {
			this.handleCalculateValue();
			// this.handlerGetSalesOrderHeaderAttachment(); // Commented because attachment taking from field data
			if (this.addedItemList[0].Sales_Order__r.Attachment_Link__c && this.addedItemList[0].Sales_Order__r.Attachment_Link__c != null && this.addedItemList[0].Sales_Order__r.Attachment_Link__c != '') {
				console.log('HEADER ATT :>> ', this.addedItemList[0].Sales_Order__r.Attachment_Link__c);
				this.headerAttView = true;
				console.log('HEADER ATT :>> ', this.attachmentsTableDataArray);
			}
		})
	}

	handlerGetSalesOrderHeaderAttachment() {
		this.showSpinner = true;
		new Promise((resolve, reject) => {
			getSOheaderAtt({
				soId: this.recId
			}).then((data) => {
				console.log('Header Attachment:>>> ', data);
				if (data != null) {
					this.doc_MainFileName = data.Title;
				}
				resolve();
			})
		}).then(() => {
			this.showSpinner = false;
		})
	}

	handleAttachmentViewModal(event) {
		this.showSpinner = true;

		if (event.currentTarget.dataset.viewfor == 'header') {
			window.scrollTo({
				top: 0,
				behavior: 'smooth', // Smooth scrolling
			});
			this.attachmentsTableDataArray = JSON.parse(this.addedItemList[0].Sales_Order__r.Attachment_Link__c);
		} else if (event.currentTarget.dataset.viewfor == 'line') {
			this.showSpinner2 = true;
			let tdata = event.currentTarget.dataset.attdata;
			console.log('line item attachment:>> ', tdata);
			this.attachmentsTableDataArray = tdata != null ? JSON.parse(tdata) : [];
		}
		console.log('attachmentsTableDataArray:>> ', this.attachmentsTableDataArray);
		if (this.attachmentsTableDataArray.length > 0) {
			this.isAttachmentModalOpen = true;
		} else {
			this.showToast('No Attachments are attached from dealer portal', '', 'info');
			this.showSpinner2 = false;
			this.showSpinner = false;
		}

	}

	closeAttachmentModal() {
		this.isAttachmentModalOpen = false;
		this.showSpinner = false;
		this.showSpinner2 = false;
	}

	getcodemaster() {
		if (this.recId != null && this.recId != '') {

		} else {
			getcodemaster({
				objectname: this.objectname
			}).then(result => {
				console.log('displayLabel result:', result);

				// No need to parse if result is already an object
				if (result) {
					//this.displayLabel = result.Display_Label__c; // Access Display_Label__c directly
					this.displayLabel = result; // Store the entire result if needed
					//this.displayLabel = this.codeMasterData;
					console.log('Result Keys:', Object.keys(result)); // Log all keys of the result object
					//console.log('Display_Label__c:', result.data.Display_Label__c); 
					console.log('displayLabel result:', result?.Display_Label__c);

				} else {
					this.showToast('Error', 'No data received', 'error');
				}
			}).catch(error => {
				console.error('Error in getcodemaster:', error);
				this.showToast('Error', 'Failed to fetch data', 'error');
			});
		}
	}
	// updateColumns() {
	//     this.columns = this.showTableProduct.length === 0 ? [] : COLS;
	//     console.log('cols on page', this.columns);
	// }

	// updateColumnsinpopup() {
	//     this.columns = this.showTechnoCommercialoffer.length === 0 ? [] : COLS;
	//     console.log('cols on popup', this.columns);
	// }

	handleNewProductModal() {
		this.isnewproductmodelOpen = true;
		//  this.updateColumnsinpopup();
		this.updateNewProductModal();
	}

	goBackToRecord() {
		this.clearModalData();
		this.modalData = {};
		this.isnewproductmodelOpen = false;
		this.handleCalculateValue();
	}

	@track showItems = false;
	handleClick() {
		const technoCommercialField = this.template.querySelector("[data-id='Enquiry__c']");
		console.log('technoCommercialField', technoCommercialField);
		if (this.isMobile) {
			this.isnewproductmodelOpen = false;
			this.showItems = true;
		} else {
			this.isnewproductmodelOpen = true;
			this.showItems = false;
		}

		console.log('isnewproductmodelOpen', this.EnquiryId);

		this.callApexMethod();
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

	clearModalData() {
		const table1 = this.template.querySelector('lightning-datatable[data-id="table1"]');
		const table2 = this.template.querySelector('lightning-datatable[data-id="table2"]');
		console.log(table1);
		console.log(table2);
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
		this.modalData.Quantity__c = '';
		this.modalData.Is_SOR__c = false;
		this.modalData.Special_Order_Type__c = '';
		this.modalData.SOR_Remark__c = '';
		this.modalData.doc_MainFile = '';
		this.searchKey = '';
		this.selectedModalRow = [];
		this.isEditing = false;
	}


	// handleOnChange(event) {
	//     const fieldName = event.target.fieldName;
	//     const inputFieldValue = event.target.value;

	//     if (fieldName === 'Rate_Type__c') {
	//         this.rateType = inputFieldValue;
	//         this.showTechnoCommercialField = this.rateType === 'Special Rate';
	//         console.log('showTechnoCommercialField', this.showTechnoCommercialField);
	//     } else if (fieldName === 'Enquiry__c') {
	//         this.selectedTechnoCommercialOffer = inputFieldValue;
	//         console.log('selectedTechnoCommercialOffer elseif', this.selectedTechnoCommercialOffer);
	//         this.updateNewProductModal();
	//         console.log('showTechnoCommercialField elseif', this.showTechnoCommercialField);
	//         this.callApexMethod(); // Call the Apex method to pass the value
	//     }

	//     const index = parseInt(event.target.dataset.index, 10);
	//     if (!isNaN(index) && index >= 0 && index < this.NewProductList.length) {
	//         this.NewProductList[index][fieldName] = inputFieldValue;
	//         this.NewProductList = [...this.NewProductList];
	//     }
	// }

	getaccAddress() {
		getAddress({
			accountId: this.AccountId
		}).then(result => {
			console.log('AccountId result:', JSON.parse(result));
			this.accountDetail = JSON.parse(result);
			this.salesPersonOptions = this.accountDetail.SalesPerson;
			if (this.salesPersonOptions.length == 1) {
				this.salesPersonValue = this.salesPersonOptions[0].value;
				this.handleGetZonalnAreaManager();
			}
			// this.pincode = result.Pincode;
			// this.state = result.State;
			// this.street = result.Street;
		})
	}

	handleGetZonalnAreaManager() {
		this.showSpinner = true;
		new Promise((resolve, reject) => {
			getZonalnAreaManager({
				spId: this.salesPersonValue
			}).then((data) => {
				console.log('data:>>> ', data);
				let tdata = data.split(';');
				this.zonalHeadValue = tdata[0];
				this.areaManagerValue = tdata[1];
				resolve(data);
			}).catch((error) => {
				console.log('error:', error);
				this.showSpinner = false;
			})
		}).then(() => {
			this.showSpinner = false;
		})
	}

	handleGetShipmentCode() {
		// console.log(this.addedItemList[0].Sales_Order__r.ShipmentCode__c);
		// console.log(this.addedItemList[0].Sales_Order__r.Account__r.Customer_Code__c);
		getSetShiptoCodeData({
			code: this.addedItemList[0].Sales_Order__r.ShipmentCode__c,
			custCode: this.addedItemList[0].Sales_Order__r.Account__r.Customer_Code__c
		}).then((result) => {
			let tdata = JSON.parse(result);
			this.accountDetail.add = tdata.add;
			this.accountDetail.add2 = tdata.add2;
			this.shipmentCodeValue = tdata.id;
		})
	}

	getRateType() {
		if (this.EnquiryId != undefined && this.EnquiryId != null) {
			getRateType({
				enqrecordtypeid: this.recordtype,
				enqid: this.EnquiryId
			}).then(result => {
				console.log('getRateType result:', result);
				this.recordTypeName = result;
				console.log('recordTypeName result:', this.recordTypeName);
				if (this.recordTypeName == 'Techno Commercial Offer') {
					this.rateType = '1';
					if (!this.allowCreateOrder) {
						this.showToast('TCO not Approved yet or Validity Expire', '', 'error');
						this[NavigationMixin.Navigate]({
							type: 'standard__recordPage',
							attributes: {
								recordId: this.EnquiryId,
								objectApiName: 'Enquiry__c',
								actionName: 'view'
							}
						});
					} else {
						if (this.recId != '' && this.recId != null) { } else {
							this.handlerIsWithRevision();
						}

					}
				} else {
					this.rateType = '2';
				}
			})
		} else {
			this.rateType = '2';
		}
	}

	handlerGetShipmentCode() {
		getShipmentCodeList({
			accId: this.AccountId
		}).then((result) => {
			// console.log('result:', result);
			this.shipmentCodeListOptions = JSON.parse(result);
		});

	}

	handlerIsWithRevision() {
		// this.showSpinner = true;
		getIsWithRevision({
			enqId: this.EnquiryId
		}).then((result) => {
			console.log('getIsWithRevision result:', JSON.parse(result));
			let tempLI = JSON.parse(result);
			let isChanged = false;
			tempLI.forEach(ele => {
				if (ele.Dealer_Rate__c != ele.Approved_Price__c) {
					isChanged = true;
				}
			});
			if (isChanged) {
				this.isPriceChangeModalOpen = true;
				// this.showToast('Price Changed','','info');
			} else {
				this.showSpinner = false;
			}
		})
	}

	closePriceChangeModal() {
		this.isPriceChangeModalOpen = false;
		this.showSpinner = false;
	}

	onCancel() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.EnquiryId,
				objectApiName: 'Enquiry__c',
				actionName: 'view'
			}
		});
	}

	callApexMethod() {
		this.showSpinner = true;

		if (this.EnquiryId != undefined && this.EnquiryId != null) {

			getselectedTechnoCommercialOffer({
				technoid: this.EnquiryId
			})
				.then(result => {
					console.log('Apex call result: 1', result); // Log the raw JSON result
					try {
						const parsedResult = JSON.parse(result); // Parse the JSON string
						this.submittedServiceData = parsedResult.dataList; // Access dataList from parsed JSON
						console.log('Parsed Apex call result>>>>>:', this.submittedServiceData);
						if (this.submittedServiceData.length > 0) {
							this.cashDiscflag = true;
						}
						this.paginiateData(JSON.stringify(this.submittedServiceData));
						// this.AllData = [...parsedResult.dataList]; // Keeping a backup of all data
					} catch (parseError) {
						console.error('Error parsing JSON from Apex result:', parseError);
					}
					this.showSpinner = false;
				})
				.catch(error => {
					console.error('Error calling Apex:', error);
					this.showSpinner = false;
					// Handle errors (optional: display a user-friendly message)
				});

		} else {

			getStdSalesOrderLineItem({
				technoid: this.EnquiryId
			})
				.then(result => {
					console.log('Apex call result: 2', result); // Log the raw JSON result
					try {
						const parsedResult = JSON.parse(result); // Parse the JSON string
						this.submittedServiceData = parsedResult.dataList; // Access dataList from parsed JSON
						console.log('Parsed Apex call result>>>>>:', this.submittedServiceData);
						this.paginiateData(JSON.stringify(this.submittedServiceData));
						// this.AllData = [...parsedResult.dataList]; // Keeping a backup of all data
					} catch (parseError) {
						console.error('Error parsing JSON from Apex result:', parseError);
					}
					this.showSpinner = false;
				})
				.catch(error => {
					console.error('Error calling Apex:', error);
					this.showSpinner = false;
					// Handle errors (optional: display a user-friendly message)
				});

		}


	}
	// handelSelectedRecord(event) {
	//     var objId = event.target.dataset.recid;
	//     console.log('objId'+objId);


	// }

	handleOnRowSelection(event) {
		// console.log(event.detail.selectedRows);
		this.clearModalData();
		this.selectedModalRow = event.detail.selectedRows;
		console.log('selectedModalRow', this.selectedModalRow);


		// console.log('modaldata', this.modalData);
		this.modalData.Material_Code__c = this.selectedModalRow[0].ItemMaster;
		this.modalData.Item_Master__c = this.selectedModalRow[0].ItemMaster;
		this.modalData.Item_Number__c = this.selectedModalRow[0].ItemNo;
		// console.log('ItemNo', this.modalData.Item_Number__c);
		this.modalData.Description__c = this.selectedModalRow[0].Description;
		// console.log('Description', this.modalData.Description__c);
		// this.modalData.SUOM__c = this.selectedModalRow[0].SUOM;
		// this.modalData.BUOM__c = this.selectedModalRow[0].BUOM;
		this.modalData.Sales_Price__c = this.selectedModalRow[0].StdDealerRate;
		this.modalData.TempLineNo__c = this.selectedModalRow[0].TempLineNo != null ? this.selectedModalRow[0].TempLineNo : this.selectedModalRow[0].Id;
		this.modalData.Cash_Discount__c = this.rateType == '1' ? 0 : 5.00;
		// this.modalData.Discount_In_Percentage__c = this.rateType == '1' ? 0 : 5.00;
		//this.modalData.Sales_Order__c = this.recId;
		// console.log(this.modalData.SUOM__c);
		// console.log(this.selectedModalRow[0].BUOM,);
		// console.log('ItemVariant', this.selectedModalRow[0].ItemMaster);

		const today = new Date();
		const future = new Date();
		future.setDate(today.getDate() + 7);
		this.modalData.Shipment_Date__c = future.toISOString().split('T')[0];

		this.handleGetItemVariant(this.selectedModalRow[0].ItemMaster);
	}

	handleGetItemVariant(pid) {
		new Promise((resolve, reject) => {
			getItemVariantOptions({
				productId: pid
			}).then((data) => {
				console.log('Item Variant Option::>> ', data);

				let tdata = JSON.parse(data);
				//this.modalData.itemMaster = pid;
				this.itemVariantOptions = tdata;
				if (this.itemVariantOptions.length > 0) {
					let eve = {
						detail: {
							value: this.selectedModalRow[0].ItemVariant
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
	handlePicklistChange(event) {

		this.modalData.Item_Variant__c = event.detail.value;
		this.handlerGetConversionFactor();

		// For displaying in Frontend only
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
			})

		}).then(() => {

		})
	}

	handleModalInputChange(event) {
		const field = event.target.fieldName;

		this.modalData[field] = event.target.value;
		console.log('modalData>>>>>', this.modalData);
		console.log('modalData>>>>>', this.modalData.Cash_Discount__c);
		if (field == 'Quantity__c') {
			if (this.selectedModalRow[0].RemQty < this.modalData.Quantity__c) {
				this.showToast('Qty cannot be greater then Remaining Qty', '', 'error');
				this.modalData.Quantity__c = null;
			} else {
				this.modalData.Conversion_Quantity__c = parseFloat(this.modalData.Conversion_Factor__c) * parseFloat(this.modalData.Quantity__c);
				this.modalData.Item_Value__c = parseFloat(this.modalData.Conversion_Quantity__c) * parseFloat(this.modalData.Sales_Price__c);
				if (this.modalData.Cash_Discount__c != 0 && this.modalData.Cash_Discount__c != undefined && this.modalData.Cash_Discount__c != '') {
					let totalval = this.modalData.Item_Value__c;
					let discval = this.modalData.Item_Value__c * (this.modalData.Cash_Discount__c * 0.01);
					console.log(discval);
					this.modalData.LineDiscountAmount__c = totalval - discval;
				}
			}
			// this.modalData.Conversion_Quantity__c = parseFloat(this.modalData.Conversion_Factor__c) * parseFloat(this.modalData.Quantity__c);
			// this.modalData.Item_Value__c = parseFloat(this.modalData.Conversion_Quantity__c) * parseFloat(this.modalData.Sales_Price__c);
			// if (this.modalData.Cash_Discount__c != 0) {
			//     let totalval = this.modalData.Item_Value__c;
			//     let discval = this.modalData.Item_Value__c * (this.modalData.Cash_Discount__c * 0.01);
			//     console.log(discval);
			//     this.modalData.LineDiscountAmount__c = totalval - discval;
			// }
		}
	}

	handleMainFileUpload(event) {
		// this.modalData.doc_MainFile = null;
		// this.modalData.doc_MainFileName = '';
		this.modalData.doc_MainFileArray = this.modalData.doc_MainFileArray ? this.modalData.doc_MainFileArray : [];
		console.log(event.target.files[0].size);

		// if (event.target.files.length > 0 && event.target.files[0].size < 3 * 1024 * 1024) {
		let files = [];
		// for (var i = 0; i < event.target.files.length; i++) {
		let file = event.target.files[0];
		const maxSizeInBytes = 3 * 1024 * 1024;
		let reader = new FileReader();
		if (file.size > maxSizeInBytes) {
			this.showToast('File size should be less then 3 MB', '', 'error');
		} else {
			reader.onload = e => {
				let base64 = 'base64,';
				let content = reader.result.indexOf(base64) + base64.length;
				let fileContents = reader.result.substring(content);
				let text = file.name;
				let myArray = text.split(".");
				let titleTemp = 'Document.' + myArray[myArray.length - 1];
				let objtemp = {
					doc_MainFileName: text,
					doc_MainFile: JSON.stringify({
						PathOnClient: file.name,
						Title: text,
						VersionData: fileContents
					})
				}
				// this.doc_MainFileName = 'Document.' + myArray[myArray.length - 1];
				// this.doc_MainFile = { PathOnClient: file.name, Title: titleTemp, VersionData: fileContents };
				// this.modalData.doc_MainFileName = 'Document.' + myArray[myArray.length - 1];
				this.modalData.doc_MainFileArray.push(objtemp);

				// this.modalData.doc_MainFileName = text;
				// this.modalData.doc_MainFile = JSON.stringify({ PathOnClient: file.name, Title: text, VersionData: fileContents });
			};
			reader.readAsDataURL(file);
		}
		console.log(this.modalData);

		// }
		// } else {
		// this.showToast('Error', '', 'File size should be less than 3MB');
		// }
	}

	handleSaveModalData(event) {
		console.log(this.modalData);
		console.log('modalData CHECK::>>> ', this.modalData.doc_MainFileArray);
		let bclick = event.currentTarget.dataset.name;

		// if (this.modalData.Is_SOR__c == undefined || this.modalData.Is_SOR__c == null) {
		//     this.modalData.Is_SOR__c = false;
		// }

		if (this.modalData.Item_Variant__c == undefined || this.modalData.Item_Variant__c == null || this.modalData.Item_Variant__c == '') {
			this.showToast('Item Variant Required!', '', 'error');
		} else if (this.modalData.Quantity__c == undefined || this.modalData.Quantity__c == null || this.modalData.Quantity__c == '') {
			this.showToast('Quantity Required!', '', 'error');
		} else if (this.modalData.Is_SOR__c && (this.modalData.Special_Order_Type__c == undefined || this.modalData.Special_Order_Type__c == '')) {
			this.showToast('Select Special Order Type!', '', 'error');
		} else if (this.modalData.Is_SOR__c && (this.modalData.SOR_Remark__c == undefined || this.modalData.SOR_Remark__c == '')) {
			this.showToast('Enter Special Order remark!', '', 'error');
		} else if (this.modalData.Is_SOR__c && (this.modalData.doc_MainFileArray == undefined || this.modalData.doc_MainFileArray == '')) {
			this.showToast('Attachment Required!', '', 'error');
		} else if (this.modalData.Shipment_Date__c == undefined || this.modalData.Shipment_Date__c == null || this.modalData.Shipment_Date__c == '') {
			this.showToast('Shipment Date Required!', '', 'error');
		} else {

			if (this.isEditing) {
				this.addedItemList[this.editIndex] = {
					...this.modalData
				};
			} else {
				this.addedItemList = [...this.addedItemList, {
					...this.modalData
				}];
			}
			let ind = 1;
			this.addedItemList.forEach(item => {
				item.SrNo = ind;
				ind++;
			});

			console.log('Newly Added addedItemList:>>> ', this.addedItemList);
			this.isnewproductmodelOpen = false;
			this.modalData = {};
			if (this.isMobile) { //
				this.showItems = true;
			} else {
				this.showItems = false;
			}

			if (bclick == 'save') {
			} else if (bclick == 'add') {
				this.showSpinner = true;
				setTimeout(() => {
					this.handleClick();
				}, 500);
			}
		}
		this.handleCalculateValue();


	}

	handleRemoveRow(event) {
		this.showSpinner = true;
		const index = event.currentTarget.dataset.index;
		let lineItemId = this.addedItemList[index].Id;
		if (lineItemId != undefined) {
			deleteSOLI({
				Id: lineItemId
			}).then((data) => {
				console.log('delete SOLI data:>>> ', data);
			}).catch((error) => {
				console.log('delete SOLI error:>>> ', error);
			})
		}
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

	@track selectedRowKeys = [];

	handleEditRow(event) {
		this.callApexMethod();
		this.showSpinner = true;
		const index = event.currentTarget.dataset.index;
		console.log(index);

		this.modalData = {
			...this.addedItemList[index]
		};
		this.isEditing = true;
		this.editIndex = index;
		this.handleGetVariantList();
		// this.handleNewProductModal();
		this.handleClick();
		this.handlerGetConversionFactor();
		setTimeout(() => {

			const itemToSelect = this.modalData.Item_Number__c; // Replace with the desired ItemNo
			// console.log(itemToSelect);
			// console.log(this.submittedServiceData);
			const rowToSelect = this.submittedServiceData.find(row => row.ItemNo === itemToSelect);
			// console.log(rowToSelect);

			if (rowToSelect) {
				this.selectedRowKeys = [rowToSelect.Id];
			}

			// console.log(this.modalData.Conversion_Factor__c);
			// console.log(this.modalData.Quantity__c);
			// console.log(this.modalData.Sales_Price__c);


			this.modalData.Conversion_Quantity__c = parseFloat(this.modalData.Conversion_Factor__c) * parseFloat(this.modalData.Quantity__c);
			this.modalData.Item_Value__c = parseFloat(this.modalData.Conversion_Quantity__c) * parseFloat(this.modalData.Sales_Price__c);
		}, 2000);
		this.showSpinner = false;
	}

	handleGetVariantList() {
		new Promise((resolve, reject) => {
			getVariantList({
				varId: this.modalData.Item_Number__c
			}).then((result) => {
				this.itemVariantOptions = [];
				let data = JSON.parse(result);
				console.log('data', data);
				this.itemVariantOptions = data;
				resolve(data);
			})
		}).then(() => {

		})
	}

	updateNewProductModal() {
		console.log('selectedTechnoCommercialOffer', this.selectedTechnoCommercialOffer);
		this.showTechnoCommercialoffer.push({
			Enquiry__c: this.selectedTechnoCommercialOffer,
			index: this.NewProductList.length
		});
		this.showTechnoCommercialoffer = [...this.showTechnoCommercialoffer];
		console.log('showTechnoCommercialoffer', this.showTechnoCommercialoffer);

	}

	// -------------- Pagination ----------------

	paginiateData(results) {
		let data = JSON.parse(results);
		console.log('Data', data);
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

	// handlerLRchange(){
	//     const lrdestinationfield = this.template.querySelector('[data-id="lrdestinationfield"]');
	//     this.lrDestinationValue = lrdestinationfield.value;
	//     console.log(this.lrDestinationValue);
	// }

	// handlerTransporterchange(){
	//     const transporterfield = this.template.querySelector('[data-id="transporterfield"]');
	//     this.transporterValue = transporterfield.value;
	//     console.log(this.transporterValue);
	// }

	handlesalesPersonChange(event) {
		this.salesPersonValue = event.target.value;
		this.handleGetZonalnAreaManager();
	}

	handleshiptoCodeChange(event) {
		this.shipmentCodeValue = event.target.value;
		getShipToCodeDetail({
			sId: this.shipmentCodeValue
		}).then((data) => {
			let tdata = JSON.parse(data);
			console.log(this.accountDetail);
			this.accountDetail.add = tdata.add;
			this.accountDetail.add2 = tdata.add2;
			this.shipmentCodeListValue = tdata.code;
			console.log(this.accountDetail);

		})
	}

	handleSalesOrderSubmit(event) {
		event.preventDefault();

		this.buttonClickedName = event.currentTarget.dataset.btnname;
		console.log('buttonClickedName:>> ', this.buttonClickedName);
		console.log('buttonClickedName:>> ', this.endCustomerNameValue);

		const lwcInputFields = this.template.querySelectorAll('lightning-input-field');
		let validationFlag = false;
		let emptyFieldName = '';

		if (this.addedItemList.length == 0) {
			this.showToast('Item not added', '', 'error');
			validationFlag = true;
		} else if (this.salesPersonValue == '') {
			validationFlag = true;
			emptyFieldName = 'Sales Person';
			this.showToast(emptyFieldName + ' Cannot be empty', '', 'error');
		} else if (this.endCustomerNameValue == '' || this.endCustomerNameValue == null) {
			validationFlag = true;
			this.showToast('End Customer Required!', '', 'error');
		} else if (lwcInputFields) {
			lwcInputFields.forEach(field => {
				if (field.fieldName == 'External_Doc_No_PO__c') {
					if (field.value == null || field.value == '') {
						validationFlag = true;
						// emptyFieldName = 'Freight Terms';
					}
				} else if (field.fieldName == 'Freight_Terms__c') {
					if (field.value == null || field.value == '') {
						validationFlag = true;
						// emptyFieldName = 'Freight Terms';
					}
				} else if (field.fieldName == 'Delivery_Type__c') {
					if (field.value == null || field.value == '') {
						validationFlag = true;
						// emptyFieldName = 'Delivery Type';
					}
				} else if (field.fieldName == 'LR_Destination_2__c') {
					if (field.value == null || field.value == '') {
						validationFlag = true;
						// emptyFieldName = 'LR Destination';
					}
				} else if (field.fieldName == 'LR_favour__c') {
					if (field.value == null || field.value == '') {
						validationFlag = true;
						// emptyFieldName = 'Delivery Type';
					}
				} else if (field.fieldName == 'Transporter__c') {
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
				this.showToast('Please fill all the mandatory fields', '', 'error');
			} else if (!this.allowCreateOrder) {
				this.showToast('TCO not Approved yet or Validity Expire', '', 'error');
				window.location.reload();
				// this[NavigationMixin.Navigate]({
				//     type: 'standard__recordPage',
				//     attributes: {
				//         recordId: this.EnquiryId,
				//         objectApiName: 'Enquiry__c',
				//         actionName: 'view'
				//     }
				// });
			} else {
				const form1 = this.template.querySelector('lightning-record-edit-form[data-id="form1"]');

				const fields = {};
				fields.Inserted_By_SP__c = this.salesPersonValue;
				fields.SubmittedBy__c = this.salesPersonValue;
				fields.Updated_By_SP__c = this.areaManagerValue;
				fields.Sales_Person__c = this.salesPersonValue;
				fields.ShipmentCode__c = this.shipmentCodeListValue;
				if (this.shipmentCodeListValue != null && this.shipmentCodeListValue != '') {
					fields.Shipment__c = this.accountDetail.add;
					fields.Shipmentaddress2__c = this.accountDetail.add2;
				}
				// fields.LR_Destination_2__c = this.lrDestinationValue;
				// fields.LR_Destination_2__c = this.transporterValue;

				lwcInputFields.forEach(field => {
					fields[field.fieldName] = field.value;
				});
				console.log('Added Item List 1', JSON.stringify(this.addedItemList));
				this.attachmentMap = new Map();
				this.addedItemList.forEach(ele => {
					if (ele.Is_SOR__c == true) {
						// this.attachmentMap.set(ele.Item_Number__c + ele.Item_Variant__c, ele.doc_MainFile);
						// ele.doc_MainFile = '';
						this.attachmentMap.set(ele.Item_Number__c + ele.Item_Variant__c, ele.doc_MainFileArray);
						ele.doc_MainFileArray = [];
					}
				})
				form1.submit(fields);
				console.log('Added Item List 2', JSON.stringify(this.addedItemList));
				console.log('DONE');

			}
		}
	}

	handleNewError(event) {
		// This will display the error in the lightning-messages component
		const error = event.detail;
		console.log('Error occurred: ', error);

		// Optionally show an error toast message
		this.dispatchEvent(
			new ShowToastEvent({
				title: 'Error',
				message: 'An error occurred: ' + error.detail,
				variant: 'error'
			})
		);

	}

	@track attachmentMap;
	handleSalesOrderSuccess(event) {
		this.recId = event.detail.id;
		console.log('Record Created!!!! ', this.recId);

		this.showToast('Sales Order Header Created', '', 'success');
		window.scrollTo({
			top: 0,
			behavior: 'smooth', // Smooth scrolling
		});
		this.showSpinner = true;
		let tempFile = this.doc_MainFile != undefined && this.doc_MainFile != '' ? JSON.stringify(this.doc_MainFile) : '';

		// this.attachmentMap = new Map();
		// this.addedItemList.forEach(ele => {
		//     if (ele.Is_SOR__c == true) {
		//         // this.attachmentMap.set(ele.Item_Number__c + ele.Item_Variant__c, ele.doc_MainFile);
		//         // ele.doc_MainFile = '';
		//         this.attachmentMap.set(ele.Item_Number__c + ele.Item_Variant__c, ele.doc_MainFileArray);
		//         ele.doc_MainFileArray = [];
		//     }
		// })

		console.log('Added Item List:>>> ', this.addedItemList);

		new Promise((resolve, reject) => {
			addsaleorderlineItems({
				Id: this.recId,
				mdoc: tempFile,
				lineitemlist: this.addedItemList.length > 0 ? JSON.stringify(this.addedItemList) : '',
				URL: this.buttonClickedName
			}).then(result => {
				console.log('Result:>>> ', result);
				resolve(result);
			}).catch(error => {
				console.error('Error:>>> ', error);
				this.showToast('Something went wrong while creating line item(s)', '', 'error');
				this.showSpinner = false;
				reject(error);
			});
		}).then((data) => {
			this.showToast('Sales Order Line Item(s) Created', '', 'success');
			this.handleSaveLineItemAttachments(data);
			// this.showSpinner = false;
			// this.showToast('Sales Order created successfully', '', 'success');
			// if (this.buttonClickedName == 'placeorderbtn') {
			//     if (this.isApproved) {
			//         this.sendSo(); // For direct click on Place order
			//     } else {
			//         this.navigateToRecordPage();
			//     }
			// } else {
			//     this.navigateToRecordPage();
			// }
		});
	}

	handleSaveLineItemAttachments(para) {
		console.log('After Line Item ADD :>> ', JSON.parse(para));
		let newlyAddedLineItem = JSON.parse(para);
		let tempLIwithAttachment = [];

		newlyAddedLineItem.forEach(elem => {
			// if (this.attachmentMap.has(elem.Item_Number__c + elem.Item_Variant__c) && this.attachmentMap.get(elem.Item_Number__c + elem.Item_Variant__c) != undefined && this.attachmentMap.get(elem.Item_Number__c + elem.Item_Variant__c) != '') {
			//     let obj = {
			//         Id: elem.Id,
			//         doc_MainFileArray: this.attachmentMap.get(elem.Item_Number__c + elem.Item_Variant__c)
			//     };
			//     tempLIwithAttachment.push(obj);
			// }
			const key = elem.Item_Number__c + elem.Item_Variant__c;
			const attachments = this.attachmentMap.get(key);
			if (attachments && attachments.length > 0) {
				tempLIwithAttachment.push({
					Id: elem.Id,
					doc_MainFileArray: attachments
				});
			}
		});

		console.log('tempLIwithAttachment:>> ', tempLIwithAttachment);
		if (tempLIwithAttachment.length > 0) {
			// let isDone = true;
			// let lastMainElement = tempLIwithAttachment[tempLIwithAttachment.length - 1];
			// let lastMainElementFileArray = lastMainElement.doc_MainFileArray;
			// let lastElement = lastMainElement.Id + '||' + lastMainElementFileArray[lastMainElementFileArray.length - 1].doc_MainFileName;
			// tempLIwithAttachment.forEach(ldata => {
			//     console.log('ldata:>>>>>>>>>> ', ldata);
			//     let farr = ldata.doc_MainFileArray;
			//     console.log('farr:>>>>>>>>>> ', farr);
			//     for (let el of farr) {
			//         this.showToast('Attachment Uploading Please wait......', '', 'info');
			//         // new Promise((resolve, reject) => {
			//         addSOLIattachments({
			//             lineItemId: ldata.Id,
			//             fileatt: el.doc_MainFile
			//         }).then((data) => {
			//             console.log('After Save :>> ', data);
			//             this.showToast('Attachment Uploaded', '', 'success');
			//             // resolve(data);
			//         }).catch((error) => {
			//             console.log('while uploading attachment::>> ', error);
			//             this.showSpinner = false;
			//             this.showToast('Something went wrong while uploading attachment(s)', '', 'error');
			//             isDone = false;
			//         })
			//         // }).then(() => {
			//         // console.log('DONE ATTACHMENT UPLOAD');
			//         // this.showToast('Attachment(s) Uploaded', '', 'success');
			//         // })
			//         if (!isDone) {
			//             console.log('IN BREAKK');
			//             break;
			//         } else {
			//             let sCheck = ldata.Id + '||' + el.doc_MainFileName;
			//             if (sCheck == lastElement) {
			//                 console.log('IN LAST ELEMENT');
			//                 this.handlerLastElementCall(isDone);
			//             }
			//         }
			//     }

			// });

			this.showToast('Uploading attachments, please wait...', '', 'info');

			// Build all promises
			let allUploadPromises = [];

			tempLIwithAttachment.forEach(ldata => {
				ldata.doc_MainFileArray.forEach(fileObj => {
					allUploadPromises.push(
						addSOLIattachments({
							lineItemId: ldata.Id,
							fileatt: fileObj.doc_MainFile
						})
					);
				});
			});

			// Wait for all uploads
			Promise.all(allUploadPromises)
				.then(results => {
					console.log('All uploads completed: ', results);
					this.showToast('All attachments uploaded successfully', '', 'success');
					this.handlerLastElementCall(true);
				})
				.catch(error => {
					console.error('Error uploading attachments: ', error);
					this.showSpinner = false;
					this.showToast('Error uploading one or more attachments', '', 'error');
					this.handlerLastElementCall(false);
				});

		} else {
			// this.navigateToRecordPage();
			if (this.buttonClickedName == 'placeorderbtn') {
				if (this.isApproved) {
					this.sendSo(); // For direct click on Place order
				} else {
					this.navigateToRecordPage();
				}
			} else {
				this.navigateToRecordPage();
			}
		}

	}

	handlerLastElementCall(para) {
		setTimeout(() => {
			console.log('IN SETTIME OUT ');

			if (para) {
				if (this.buttonClickedName == 'placeorderbtn') {
					if (this.isApproved) {
						this.sendSo(); // For direct click on Place order
					} else {
						this.navigateToRecordPage();
					}
				} else {
					this.navigateToRecordPage();
				}
			}
		}, 10000);
	}

	handleMainClick() {
		// Navigate to the Enquiry list view
		if (!this.isMobile) {
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'Sales_Order__c',
					actionName: 'list'
				}
			});
		} else {
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'Sales_Order__c',
					actionName: 'home'
				}
			});
		}
	}

	sendSo() {
		if (this.recId != '') {
			this.isplacedOrderClick = true;
		} else {
			this.showToast('Please submit the order before place order', '', 'error');
		}
	}

	closeModal() {
		this.isplacedOrderClick = false;
		this.handlerGetSalesOrderLineItem();
	}


	handlerNavResponse(event) {
		this.pushToNavDisabled = true;
		console.log('Event: ', event.detail.resmsg);
		var tempData = event.detail.resmsg;
		if (tempData.includes('SOB/') && this.isCreatedFromTSD == false) {
			// this.pushToNavDisabled = false;
			this.pushToNav();
		}
	}

	handlerTSDcalloutResponse() {
		this.pushToNav();
	}

	pushToNav() {
		this.isTSDResponse = null;
		insertStandardSalesOrderToTSD({
			SoId: this.recId
		}).then((result) => {
			console.log('OUTPUT : ', result);
			this.isTSDResponse = result;
		})
	}

	handlerRejectSO() {
		getSOCreatedBy({
			soid: this.recId
		}).then(result => {
			console.log('result: ', result);
			if (result == 'TSD') {

				setTimeout(() => {
					new Promise((resolve, reject) => {
						salesOrderApproval({
							soid: this.recId,
							statustype: 3,
							sonumber: ''
						}).then((data) => {
							this.showToast(data, '', 'success');
						}).catch((error) => {

						})
					}).then(() => {

					})
				}, 0);
			} else {
				updateSalesOrderApprovalStatus({
					soid: this.recId,
					statustype: 3
				}).then(result => {
					console.log('result: ', result);
					this.showToast('SalesOrder Rejected', '', 'success');
					this.navigateToRecordPage();
				})
			}
		})
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

	disconnectedCallback() {
		// Clean up the event listener when the component is disconnected
		window.onpopstate = null;
	}

	handleBackButton(event) {
		this.showItems = false;
		// Select all input fields
		const inputFields = this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox, lightning-input-field');

		// Reset each field
		inputFields.forEach(field => {
			if (!field.disabled) {
				if (field.tagName.toLowerCase() === 'lightning-input-field') {
					// Reset lightning-input-field if not disabled
					field.reset();
				} else {
					// Clear value for standard inputs like lightning-input, lightning-textarea, etc.
					field.value = '';
				}
			}
		});
	}

	// Header Attachment
	handleMainHeaderFileUpload(event) {
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
				this.doc_MainFile = {
					PathOnClient: file.name,
					Title: text,
					VersionData: fileContents
				};
			};
			reader.readAsDataURL(file);
			// }
		} else {
			this.showToast('Error', '', 'File size should be less than 3MB');
		}
	}

	handleCalculateValue() {
		console.log('IN handleCalculateValue Method........');
		this.orderValueAmt = 0;
		this.discountValueAmt = 0;
		this.orderValueGSTAmt = 0;
		if (this.addedItemList.length > 0) {
			this.addedItemList.forEach(element => {
				console.log(element.Item_Value__c);
				console.log(element.LineDiscountAmount__c);
				this.orderValueAmt += element.Item_Value__c;
				if (element.LineDiscountAmount__c != undefined) {
					let val = element.Item_Value__c - element.LineDiscountAmount__c;
					this.discountValueAmt += val;
				}
			});
			// this.gstAmount = (this.amount * this.gstPercentage) / 100;
			this.orderValueGSTAmt = this.orderValueAmt + ((this.orderValueAmt * 18) / 100);
		} else { }
	}

}