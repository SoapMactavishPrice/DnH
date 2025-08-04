import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getIJPRecord from '@salesforce/apex/JourneyPlannerController.getIJPRecord';
import checkIsInApprovalProcess from '@salesforce/apex/JourneyPlannerController.checkIsInApprovalProcess';
import getRoutePlanner from '@salesforce/apex/JourneyPlannerController.getRoutePlanner';
// import getIndustryList from '@salesforce/apex/JourneyPlannerController.getIndustryList';
import getPicklistValues from '@salesforce/apex/JourneyPlannerController.getPicklistValues';
import getIndustryValues from '@salesforce/apex/JourneyPlannerController.getIndustryValues';
import getMainPrincipal from '@salesforce/apex/JourneyPlannerController.getMainPrincipal';
// import getCityValues from '@salesforce/apex/JourneyPlannerController.getCityValues';
import getRecords from '@salesforce/apex/JourneyPlannerController.getRecords';
import generateEvent from '@salesforce/apex/JourneyPlannerController.generateEvent';
import getEventsForCurrentMonth from '@salesforce/apex/JourneyPlannerController.getEventsForCurrentMonth';
import getSingleEvent from '@salesforce/apex/JourneyPlannerController.getSingleEvent';
import updateEvent from '@salesforce/apex/JourneyPlannerController.updateEvent';
import updateEventDragDrop from '@salesforce/apex/JourneyPlannerController.updateEventDragDrop';
import deleteEvent from '@salesforce/apex/JourneyPlannerController.deleteEvent';
import submitForApproval from '@salesforce/apex/JourneyPlannerController.submitForApproval';
//import getOfficeLocations from '@salesforce/apex/GoogleMapController.getOfficeLocations';

import FORM_FACTOR from '@salesforce/client/formFactor';



// import LightningModal from 'lightning/modal';

export default class LwcJourneyPlannerHome extends LightningElement {
	@api recordId;

	@track allAcountId = []

	@track showSpinner;
	@track lwcName = 'lwc-27ch0pokfge';

	@track componentSizes = {};

	@track selectedRoutePlanner;
	@track selectedMainPrincipal;

	@track industryGrpOptions;
	@track selectedIndustryGrp;

	@track isSmallDevice;
	@track isMediumDevice;
	@track isLargeDevice;

	@track cityMasterList;
	@track masterEntityList = [];
	@track entityList = [];

	@track objApiName = 'Account';
	@track selectedCityList = new Set();

	@track entitySearchTimeout;

	@track routePlannerOptions;
	@track mainPrincipalOptions;

	@track isAttendeesVisible = true;

	@track today = new Date();
	@track current_view_day = this.today.getDay();
	@track current_view_month = this.today.getMonth();
	@track current_view_year = this.today.getFullYear();

	@track visibleMonthdatesList;
	@track visibleWeekdatesList;

	@track activeDay;
	@track isCalenderPopulated = false;
	@track currentEvents;

	@track isMapVisible = false;
	@track accountNameParam = '';
	@track toggleaccId = '';


	@track selectedWeekMonthMode = 'Month';

	@track dropZoneId;                                  // Touch Event - target is stored in this
	@track currentTouchedEntityRecord;
	@track currentTouchedEventRecord;
	@track currentTouchedType;
	@track currentTouchedEventDay;
	@track currentTouchedEventIndex;

	@track currentIndexOfDayOpenInRightComponent;

	@track selectedDateEventsList;

	@track selectedStage = [];

	@track isAccount = true;
	@track isLead = false;
	@track isContact = false;

	@track months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

	@track cityEventModeItems = [{
		idx: 2,
		icon: 'utility:location',
		label: 'City',
		disabled: false,
		checked: false,
		isChecked: false,
		pickerSize: 'slds-visual-picker'
	}, {
		idx: 3,
		icon: 'utility:event',
		label: 'Events',
		disabled: false,
		checked: true,
		isChecked: true,
		pickerSize: 'slds-visual-picker'
	}];

	get entityOptions() {
		console.log("method call => entityOptions");

		return [
			{ value: 'Lead__c', label: 'Lead' },
			{ value: 'Account', label: 'Account' },
			{ value: 'Contact', label: 'Contact' },
			// { value: 'Opportunity__c', label: 'Opportunity' },
			// { value: 'Order__c', label: 'Order' },
			// { value: 'Case__c', label: 'Case' },
			// { value: 'Asset__c', label: 'Asset' }
		];
	}

	// @track oppStageOptions = [
	//     { id: 'selectAll', title: 'Select All', isSelected: false },
	//     { id: 'Prospecting', title: 'Prospecting', isSelected: false },
	//     { id: 'Discovery', title: 'Discovery', isSelected: false },
	//     { id: 'Proposal', title: 'Proposal', isSelected: false },
	//     { id: 'Evaluation', title: 'Evaluation', isSelected: false },
	//     { id: 'Closing', title: 'Closing', isSelected: false },
	//     { id: 'Closed Won', title: 'Closed Won', isSelected: false },
	//     { id: 'Closed Lost', title: 'Closed Lost', isSelected: false }
	// ];

	get meetingPurposeOptions() {
		console.log("method call => meetingPurposeOptions");

		return [
			{ value: '', label: '--None--' },
			{ value: 'Quotation follow-up', label: 'Quotation follow-up' },
			{ value: 'Payment follow-up', label: 'Payment follow-up' },
			{ value: 'Application study', label: 'Application study' },
			{ value: 'Prospecting for cross-selling', label: 'Prospecting for cross-selling' },
			{ value: 'Attending AMC service', label: 'Attending AMC service' },
			{ value: 'Attending service complaint', label: 'Attending service complaint' },
			{ value: 'Installation & Commissioning', label: 'Installation & Commissioning' },
			{ value: 'Cold Call', label: 'Cold Call' },
			{ value: 'Machine Demo', label: 'Machine Demo' },
			{ value: 'Inspection', label: 'Inspection' },
			{ value: 'New Product Promotion', label: 'New Product Promotion' },
			{ value: 'Send Quote', label: 'Send Quote' },
			{ value: 'Delivery Status', label: 'Delivery Status' },
			{ value: 'Close the enquiry/Order amendment', label: 'Close the enquiry/Order amendment' },
			{ value: 'Enquiry follow-up', label: 'Enquiry follow-up' },
			{ value: 'Technical Discussion', label: 'Technical Discussion' },
			{ value: 'Send Credential', label: 'Send Credential' },
			{ value: 'Warranty visit', label: 'Warranty visit' },
			{ value: 'Travel', label: 'Travel' },
			{ value: 'Holiday', label: 'Holiday' },
			{ value: 'Weekly off', label: 'Weekly off' }
		];
	}

	get visitPurposeOptions() {
		console.log("method call => visitPurposeOptions");

		return [
			{ value: '', label: '--None--' },
			{ value: 'Generating Enquiries', label: 'Generating Enquiries' },
			{ value: 'Quality Related Issues', label: 'Quality Related Issues' },
			{ value: 'Payment Follow Up', label: 'Payment Follow Up' },
			{ value: 'Quotation Follow Up', label: 'Quotation Follow Up' },
			{ value: 'Introduction', label: 'Introduction' },
			{ value: 'Order Finalisation', label: 'Order Finalisation' },
			{ value: 'Collecting Rejection', label: 'Collecting Rejection' },
			{ value: 'Sample Collection', label: 'Sample Collection' },
			{ value: 'Serving Customer', label: 'Serving Customer' },
			{ value: 'Regular Visit', label: 'Regular Visit' },
			{ value: 'Other', label: 'Other' },

		];
	}

	get appointmentTakenOptions() {
		console.log("method call => appointmentTakenOptions");
		return [
			{ value: '', label: '--None--' },
			{ value: 'Yes', label: 'Yes' },
			{ value: 'No', label: 'No' }
		];
	}

	get cityEventModeOptions() {
		console.log("method call => cityEventModeOptions");

		return [
			{ value: 'City__c', label: 'City' },
			{ value: 'Events', label: 'Events' }
		];
	}

	get WhoIdOptions() {
		console.log("method call => WhoIdOptions");

		return [
			{ value: "Lead__c", label: "Lead" },
			{ value: "Contact", label: "Contact" }
		];
	}

	get WhatIdOptions() {
		console.log("method call => WhatIdOptions");

		return [

			{ value: "Account", label: "Account" }

			// { value: "Opportunity__c", label: "Opportunity" },
			// { value: "Order__c", label: "Order" },
			// { value: "Case__c", label: "Case" },
			// { value: "Asset__c", label: "Asset" }
		];
	}

	connectedCallback() {
		console.log("method call => connectedCallback");

		this.isLargeDevice = false;
		this.isMediumDevice = false;
		this.isSmallDevice = false;

		switch (FORM_FACTOR) {
			case 'Large': {
				this.isLargeDevice = true;
				break;
			}
			case 'Medium': {
				this.isMediumDevice = true;
				break;
			}
			case 'Small': {
				this.isSmallDevice = true;
				break;
			}
		}

		if (this.recordId) {
			this.componentSizes = {
				first: {
					small: '12',
					medium: '9',
					large: '9'
				},
				middle: {
					small: '12',
					medium: '9',
					large: '9'
				},
				left: {
					small: '12',
					medium: '3',
					large: '3'
				},
				right: {
					small: '12',
					medium: '3',
					large: '3'
				}
			};
		}
		else {
			this.componentSizes = {
				first: {
					small: '12',
					medium: '2',
					large: '2'
				},
				left: {
					small: '12',
					medium: '2',
					large: '0'
				},
				middle: {
					small: '12',
					medium: '7',
					large: '7'
				},
				right: {
					small: '12',
					medium: '3',
					large: '3'
				}
			};
		}

		if (this.recordId == undefined || this.recordId == null) {
			this.getRoutePlannerValues();
			this.getMainPrincipalValues();
		}

		// Mobile - Disable "drag to Scroll"
		this.dispatchEvent(
			new CustomEvent("updateScrollSettings", {
				detail: {
					isPullToRefreshEnabled: false
				},
				bubbles: true,
				composed: true
			})
		);
	}

	disconnectedCallback() {
		// Mobile - Enable "drag to Scroll" after closing to page
		this.dispatchEvent(
			new CustomEvent("updateScrollSettings", {
				detail: {
					isPullToRefreshEnabled: true
				},
				bubbles: true,
				composed: true
			})
		);
	}

	renderedCallback() {
		console.log("method call => renderedCallback");

		if (!this.isCalenderPopulated)
			console.log('this.isCalenderPopulated', this.isCalenderPopulated); {
			this.isCalenderPopulated = true;
			if (this.recordId) {
				this.getIJPRecord();
			}
			else {
				this.initCalendar();
			}

			if (!this.recordId) {
				this.template.addEventListener('click', this.handleTemplateClick);
			}
		}
		const coords = this.template.querySelector('.slds-coordinates__item');
		if (coords) {
			coords.style.display = 'none';
		}

	}

	getIJPRecord = (event) => {
		new Promise((resolve, reject) => {
			setTimeout(() => {
				getIJPRecord({ recordId: this.recordId })
					.then((data) => {
						console.log(data);
						this.current_view_month = new Date(data.IJP_Start_Date__c).getMonth();
						this.current_view_year = new Date(data.IJP_Start_Date__c).getFullYear();

						this.current_view_day = null;

						this.initCalendar();
					})
					.catch((error) => {
						this.showToastOnError(error);
					})
			});
		});
	}

	handleTemplateClick = (event) => {
		console.log("method call => handleTemplateClick");

		if (this.refs.customDropdown1) {
			if (this.refs.customDropdown1.contains(event.target)) { }
			else {
				this.refs.customDropdown1.closeDropdown();
			}
		}
		if (this.refs.customDropdownStageName) {
			if (this.refs.customDropdownStageName.contains(event.target)) { }
			else {
				this.refs.customDropdownStageName.closeDropdown();
			}
		}
	}

	getRoutePlannerValues = () => {
		console.log("method call => getRoutePlannerValues");

		new Promise((resolve, reject) => {
			setTimeout(() => {
				getRoutePlanner()
					.then((data) => {
						this.routePlannerOptions = JSON.parse(data);

						// this.getCityValues();
						this.getRecords();
					})
					.catch((error) => {
						this.showToastOnError(error);
					});
			});
		});
	}

	handleRoutePlannerChange = (event) => {
		console.log("method call => handleRoutePlannerChange");

		if (this.isAccount == null || this.isAccount == undefined) {
			if (this.objApiName == 'Opportunity__c') {
				this.isOpportunity = true;
			}
		}
		if (this.isContact == null || this.isContact == undefined) {
			if (this.objApiName == 'Opportunity__c') {
				this.isOpportunity = true;
			}
		}

		this.selectedRoutePlanner = event.detail.value;
		console.log('this.selectedRoutePlanner', this.selectedRoutePlanner);
		this.selectedCityList = new Set();
		// this.getCityValues();
		this.getRecords();

	}
	handleIndustryGrpChange = (event) => {
		console.log("method call => handleIndustryGrpChange");

		if (this.isAccount == null || this.isAccount == undefined) {
			if (this.objApiName == 'Opportunity__c') {
				this.isOpportunity = true;
			}
		}
		if (this.isLead__c == null || this.isLead__c == undefined) {
			if (this.objApiName == 'Opportunity__c') {
				this.isOpportunity = true;
			}
		}

		this.selectedIndustryGrp = event.detail.value;
		console.log('this.selectedRoutePlanner', this.selectedIndustryGrp);
		this.selectedCityList = new Set();
		// this.getCityValues();
		this.getRecords();

	}

	// For lead 
	getIndustryListValues = () => {
		console.log("method call => getIndustryListValues");

		new Promise((resolve, reject) => {
			setTimeout(() => {
				// getPicklistValues({
				// 	objectName: 'Lead__c',
				// 	fieldName: 'Industry__c'
				// })
				// 	.then((data) => {
				// 		console.log('VALUE:>> ', data);
				// 		let tempData = [];
				// 		data.forEach(element => {
				// 			let sdata = {};
				// 			sdata.label = element;
				// 			sdata.value = element;
				// 			tempData.push(sdata);
				// 		});
				// 		this.industryGrpOptions = tempData;

				// 		// this.getCityValues();
				// 		this.getRecords();
				// 	})
				// 	.catch((error) => {
				// 		this.showToastOnError(error);
				// 	});

				getIndustryValues()
					.then((data) => {
						console.log('VALUE:>> ', data);
						let tempData = [];
						data.forEach(element => {
							let sdata = {};
							sdata.label = element.Name;
							sdata.value = element.Id;
							tempData.push(sdata);
						});
						this.industryGrpOptions = tempData;

						// this.getCityValues();
						this.getRecords();
					})
					.catch((error) => {
						this.showToastOnError(error);
					});
			});
		});
	}

	handleStageChange = (event) => {
		console.log("method call => handleStageChange");

		this.selectedStage = new Set();
		this.selectedStage = event.detail.allids;
		this.selectedCityList = new Set();
		// this.getCityValues();
		this.getRecords();
	}

	getMainPrincipalValues = (event) => {
		console.log("method call => getMainPrincipalValues");

		new Promise((resolve, reject) => {
			setTimeout(() => {
				getMainPrincipal()
					.then((data) => {
						this.mainPrincipalOptions = JSON.parse(data);

						// this.getCityValues();
						this.getRecords();
					})
					.catch((error) => {
						this.showToastOnError(error);
					});
			});
		});
	}

	handleMainPrincipleChange = (event) => {
		console.log("method call => handleMainPrincipleChange");
		this.allAcountId = [];
		this.selectedMainPrincipal = event.currentTarget.value;
		this.selectedCityList = new Set();
		// this.getCityValues();
		this.getRecords();
	}

	/*
		getCityValues = () => {
			console.log("method call => getCityValues");
    
			new Promise((resolve, reject) => {
				setTimeout(() => {
					getCityValues({
						routePlannerId: this.selectedRoutePlanner,
						objName: this.objApiName,
						selectedStage: Array.from(this.selectedStage).join(','),
						selectedMainPrincipal: this.selectedMainPrincipal
					})
						.then((data) => {
							this.selectedCityList = new Set();
							let cityList = JSON.parse(data);
							cityList.forEach(item => {
								item.isSelected = true;
								if (cityList.id != 'selectAll')
									this.selectedCityList.add(item.title);
							});
							this.selectedCityList.delete('selectAll');
							this.selectedCityList.delete(undefined);
							if (!(cityList == undefined || cityList == null)) {
								this.cityMasterList = cityList;
							}
							this.getRecords();
						})
						.catch((error) => {
							this.showToastOnError(error);
						});
				});
			});
		}
	*/

	getRecords = () => {
		console.log("method call => getRecords");

		/*
		if (this.selectedCityList == undefined || this.selectedCityList == null || this.selectedCityList.size == 0) {
			this.entityList = undefined;
			return;
		}
*/

		this.showSpinner = true;
		new Promise((resolve, reject) => {
			setTimeout(() => {

				getRecords({
					routePlannerId: this.selectedRoutePlanner,
					selectedindustry: this.selectedIndustryGrp,
					objApiName: this.objApiName,
					selectedStage: Array.from(this.selectedStage).join(','),
					selectedMainPrincipal: this.selectedMainPrincipal,
					cityList: Array.from(this.selectedCityList).join(',')
				})
					.then((data) => {
						console.log("test data", data);

						let recs = [];

						for (var i = 0; i < data.length; i++) {
							let opp = {}
							let abc = data[i];
							opp = Object.assign(opp, abc);
							recs.push(opp.Id);
						}

						this.allAcountId = recs;

						console.log('allAcountId', this.allAcountId);


						this.masterEntityList = data;
						this.entityList = data;

						this.handleComponentHeight();

						this.showSpinner = false;
					})
					.catch((error) => {
						this.showToastOnError(error);
					});

			}, 0);
		});
	}

	handleSelectedCityNames = (event) => {
		console.log("method call => handleSelectedCityNames");

		this.selectedCityList = event.detail.allids;
		this.selectedCityList.delete('selectAll');

		this.getRecords();

	}

	handleObjApiNameChange = (event) => {
		console.log("method call => handleObjApiNameChange");

		this.cityMasterList = undefined;

		this.isLead = false;
		this.isAccount = false;
		this.isContact = false;
		this.isOpportunity__c = false;
		this.isOrder__c = false;
		this.isCase__c = false;
		this.isAsset__c = false;

		this.selectedMainPrincipal = null;

		this.objApiName = event.target.value;
		console.log('this.objApiName', this.objApiName);

		switch (this.objApiName) {
			case 'Lead__c':
				this.isLead = true;
				this.isAccount = false;
				this.isContact = false;
				this.getIndustryListValues();
				this.industryGrpOptions = true;
				break;
			case 'Account':
				this.isAccount = true;
				this.isContact = false;
				this.isLead = false;
				break;
			case 'Contact':
				this.isContact = true;
				this.isLead = false;
				this.isAccount = false;
				break;
			// case 'Opportunity__c':
			//     this.isOpportunity = false;
			//     break;
			// case 'Order__c':
			//     this.isOrder = true;
			//     this.isOpportunity = false;
			//     break;
			// case 'Case__c':
			//     this.isCase = true;
			//     this.isOpportunity = false;
			//     break;
			// case 'Asset__c':
			//     this.isAsset = true;
			//     this.isOpportunity = false;
			//     break;
		}

		if (this.selectedRoutePlanner) {
			this.selectedCityList = new Set();
			// this.getCityValues();

		}

		this.getRecords();
	}

	// handleEntitySearch = (event) => {
	//     console.log("method call => handleEntitySearch");

	//     clearTimeout(this.entitySearchTimeout);

	//     let searchkey = event.target.value;

	//     this.entitySearchTimeout = setTimeout(() => {
	//         if (searchkey == '' || searchkey == null) {
	//             this.entityList = this.masterEntityList;
	//         } else {
	//             this.entityList = [];
	//             this.masterEntityList.forEach(item => {
	//                 if (item.Name.toLowerCase().includes(searchkey.toLowerCase())) {
	//                     this.entityList.push(item);
	//                 }
	//                 else if (item.CityName.toLowerCase().includes(searchkey.toLowerCase())) {
	//                     this.entityList.push(item);
	//                 }
	//                 else if (item.StageName && item.StageName.toLowerCase().includes(searchkey.toLowerCase())) {
	//                     this.entityList.push(item);
	//                 }
	//                 else if (item.Principal__c && item.Principal__c.toLowerCase().includes(searchkey.toLowerCase())) {
	//                     this.entityList.push(item);
	//                 }
	//                 else if (item.AssetName && item.AssetName.toLowerCase().includes(searchkey.toLowerCase())) {
	//                     this.entityList.push(item);
	//                 }
	//             });
	//         }
	//     }, 1000);
	// }

	handleEntitySearch = (event) => {
		console.log("method call => handleEntitySearch");

		clearTimeout(this.entitySearchTimeout);

		const searchKey = event.target.value.trim().toLowerCase();

		this.entitySearchTimeout = setTimeout(() => {
			if (searchKey === '') {
				this.entityList = [...this.masterEntityList];
			} else {
				this.entityList = this.masterEntityList.filter(item =>
					(item.Name && item.Name.toLowerCase().includes(searchKey)) ||
					(item.CityName && item.CityName.toLowerCase().includes(searchKey)) ||
					(item.StageName && item.StageName.toLowerCase().includes(searchKey)) ||
					(item.Principal__c && item.Principal__c.toLowerCase().includes(searchKey)) ||
					(item.AssetName && item.AssetName.toLowerCase().includes(searchKey))
				);
			}

			console.log("Filtered entityList:", this.entityList);
		}, 1000);
	}


	initCalendar = () => {
		console.log("method call => initCalendar");

		const firstDay = new Date(this.current_view_year, this.current_view_month, 1);
		const lastDay = new Date(this.current_view_year, this.current_view_month + 1, 0);
		const prevLastDay = new Date(this.current_view_year, this.current_view_month, 0);
		const prevDays = prevLastDay.getDate();
		const lastDate = lastDay.getDate();
		const day = firstDay.getDay();
		const nextDays = 7 - lastDay.getDay() - 1;

		/*
		let date_header = this.template.querySelector('.date_header');
		if (date_header) {
			if (this.isLargeDevice || this.isMediumDevice)
				date_header.innerHTML = this.months[this.current_view_month] + " " + this.current_view_year;
			this.isSmallDevice
			date_header.innerHTML = this.months[this.current_view_month].substring(0, 3) + " " + this.current_view_year;
		}
		*/

		let month_days = "";
		this.visibleMonthdatesList = [];

		let index = 0;
		for (let i = day; i > 0; i--) {
			let tempVar = prevDays - i + 1;
			month_days += '<div class="day prev-date"><span class="day_day">' + tempVar + '</span></div>';
			// this.visibleMonthdatesList.push({ year: this.current_view_year, month: this.current_view_month - 1, day: tempVar });
			index++;
			this.current_view_day = tempVar;
		}

		for (let i = 1; i <= lastDate; i++) {
			if (
				i === new Date().getDate() &&
				this.current_view_year === new Date().getFullYear() &&
				this.current_view_month === new Date().getMonth()
			) {
				month_days += '<div class="day calendar-day today" data-day=' + i + '><span class="day_day">' + i + '</span><span class="month_day_event" data-day=' + i + '></span></div>';
				this.visibleMonthdatesList.push({ year: this.current_view_year, month: this.current_view_month, day: i });
			} else {
				month_days += '<div class="day calendar-day" data-day=' + i + '><span class="day_day">' + i + '</span><span class="month_day_event" data-day=' + i + '></span></div>';
				this.visibleMonthdatesList.push({ year: this.current_view_year, month: this.current_view_month, day: i });
			}
			index++;
		}

		for (let i = 1; i <= nextDays; i++) {
			month_days += '<div class="day next-date"><span class="day_day">' + i + '</span></div>';
			// this.visibleMonthdatesList.push({ year: this.current_view_year, month: this.current_view_month + 1, day: i });
			index++;
		}

		let daysContainer = this.template.querySelector(".month_days");
		if (daysContainer)
			daysContainer.innerHTML = month_days;

		this.addListner();
		this.getEventsForCurrentMonth();
	}

	addListner = () => {
		console.log("method call => addListner");

		let dayContainer = this.template.querySelector('.calendar').querySelector('.month_days').querySelectorAll('.day');
		for (let i = 0; i < dayContainer.length; i++) {
			dayContainer[i].setAttribute(this.lwcName, '');
			const day_day = dayContainer[i].querySelector('.day_day')
			if (day_day)
				day_day.setAttribute(this.lwcName, '');
			const month_day_event = dayContainer[i].querySelector('.month_day_event')
			if (month_day_event)
				month_day_event.setAttribute(this.lwcName, '');

			if (!(dayContainer[i].classList.contains('prev-date') || dayContainer[i].classList.contains('next-date'))) {
				dayContainer[i].addEventListener('dragover', this.handleDragOver);
				dayContainer[i].addEventListener('drop', this.handleDrop);
				// dayContainer[i].addEventListener('touchend', this.handleTouchEnd);
				dayContainer[i].addEventListener('click', this.handleDayClick);
			}
		}
	}

	getEventsForCurrentMonth = () => {
		console.log("method call => getEventsForCurrentMonth");

		this.currentEvents = null;
		new Promise((resolve, reject) => {
			setTimeout(() => {
				getEventsForCurrentMonth({
					currentYear: this.current_view_year,
					currentMonth: this.current_view_month + 1,
					ijpId: this.recordId
				})
					.then((data) => {
						this.currentEvents = JSON.parse(data);
						console.log('currentEvents ->', this.currentEvents);
						this.addEventsToCalendar();
					})
					.catch((error) => {
						this.showToastOnError(error);
					});
			}, 0);
		});
	}

	addEventsToCalendar = () => {
		console.log("method call => addEventsToCalendar");

		const dayElements = this.template.querySelectorAll('.day');
		for (let i = 0; i < dayElements.length; i++) {
			if (!(dayElements[i].classList.contains('prev-date') || dayElements[i].classList.contains('next-date'))) {

				const month_day_event = this.template.querySelector('.month_day_event[data-day="' + dayElements[i].getAttribute('data-day') + '"]');

				if (month_day_event && this.currentEvents) {
					let day = dayElements[i].getAttribute('data-day');
					const events = this.currentEvents[day];
					if (events) {
						let eventsListHtml = '';
						if (this.selectedWeekMonthMode == 'Month') {
							for (let i = 0; i < events.length; i++) {
								console.log('events', events[i]);
								console.log('events class', events[i].eventClass);

								if (events[i].watermark == 'Lead*') {
									events[i].eventClass = 'none-submitteds';
								}

								if (events[i].watermark == 'Contact') {
									events[i].eventClass = 'none-submittedss';
								}

								if (events[i].watermark == 'Account') {
									events[i].eventClass = 'none-submitted';
								}

								eventsListHtml += '<div class="month_day_event_item ' + events[i].eventClass + '" ' +
									'data-day="' + day + '" data-index="' + i + '" data-type="Event" draggable="true" >' +
									'<div class="ellipsis" title="' + events[i].Title + '">' + events[i].Title + '</div>';
								if (FORM_FACTOR == "Large" || FORM_FACTOR == 'Medium') {
									eventsListHtml += '<div class="watermark">' + events[i].watermark + '</div>' +
										'<div class="month_day_event_item_duration">' + events[i].StartTime + ' - ' + events[i].EndTime + '</div>';

								}
								eventsListHtml += '</div>';
							}
						}
						else if (this.selectedWeekMonthMode == 'Week') {

						}
						month_day_event.innerHTML = eventsListHtml;
					}
				}
			}
		}

		let date_header = this.template.querySelector('.date_header');
		if (date_header) {
			if (this.recordId) {
				if (this.currentEvents) {
					try {
						let headerDtFromEvent = this.currentEvents[Object.keys(this.currentEvents)[0]][0].StartDateTime;
						headerDtFromEvent = new Date(headerDtFromEvent);
						this.current_view_month = headerDtFromEvent.getMonth();
						this.current_view_year = headerDtFromEvent.getFullYear();
					}
					catch (error) { }
				}
			}

			if (this.isLargeDevice || this.isMediumDevice)
				date_header.innerHTML = this.months[this.current_view_month] + " " + this.current_view_year;
			this.isSmallDevice
			date_header.innerHTML = this.months[this.current_view_month].substring(0, 3) + " " + this.current_view_year;
		}

		const month_day_event_items = this.template.querySelectorAll('.month_day_event_item');
		for (let i = 0; i < month_day_event_items.length; i++) {
			month_day_event_items[i].setAttribute(this.lwcName, '');
			month_day_event_items[i].addEventListener('dragstart', this.handleDragStart);

			month_day_event_items[i].addEventListener('touchstart', this.handleTouchStart);
			month_day_event_items[i].addEventListener('touchmove', this.handleTouchMove);
			month_day_event_items[i].addEventListener('touchend', this.handleTouchEnd);
		}
		const watermark = this.template.querySelectorAll('.watermark');
		for (let i = 0; i < watermark.length; i++) {
			watermark[i].setAttribute(this.lwcName, '');
		}
		const month_day_event_items_duration = this.template.querySelectorAll('.month_day_event_item_duration');
		for (let i = 0; i < month_day_event_items_duration.length; i++) {
			month_day_event_items_duration[i].setAttribute(this.lwcName, '');
		}
		const ellipsis = this.template.querySelectorAll('.ellipsis');
		for (let i = 0; i < ellipsis.length; i++) {
			ellipsis[i].setAttribute(this.lwcName, '');
		}
		const day_city_items = this.template.querySelectorAll('.day_city_item');
		for (let i = 0; i < day_city_items.length; i++) {
			day_city_items[i].setAttribute(this.lwcName, '');
		}

		//this.checkIsInApprovalProcess();
		this.handleComponentHeight();
	}

	// checkIsInApprovalProcess = () => {
	//     console.log('method checkIsInApprovalProcess', this.current_view_month, this.current_view_year);
	//     new Promise((resolve, reject) => {
	//         setTimeout(() => {
	//             checkIsInApprovalProcess({
	//                 currentMonth: this.current_view_month,
	//                 currentYear: this.current_view_year
	//             })
	//                 .then((data) => {
	//                     this.isInApprovalProcess = data;
	//                     console.log('isInApprovalProcess', this.isInApprovalProcess);
	//                 })
	//                 .catch((error) => {
	//                     console.log('isInApprovalProcess', error);
	//                     this.showToastOnError(error);
	//                 })
	//         });
	//     });
	// }

	handleComponentHeight = () => {
		console.log("method call => handleComponentHeight");

		let totalHeights = this.template.querySelectorAll('.total-height');
		if (totalHeights && totalHeights.length == 3) {
			let height = totalHeights[1].getBoundingClientRect().height;
			console.log('height', height);

			switch (FORM_FACTOR) {
				case 'Large':
				case 'Medium': {
					let entityListHeight = height - totalHeights[0].querySelector('.entity-dropdown').getBoundingClientRect().height - 2;
					totalHeights[0].querySelector('.entity-list').style.height = entityListHeight + 'px';
					console.log('entityListHeight', entityListHeight);

					let eventHeaderHeight = height - totalHeights[2].querySelector('.event-header').getBoundingClientRect().height - 2;
					totalHeights[2].querySelector('.event-list').style.height = eventHeaderHeight + 'px';
					console.log('eventHeaderHeight', eventHeaderHeight);

					break;
				}
				case 'Small': {
					let entityListHeight = height - totalHeights[0].querySelector('.entity-dropdown').getBoundingClientRect().height - 2;
					entityListHeight = entityListHeight / 4;
					totalHeights[0].querySelector('.entity-list').style.height = entityListHeight + 'px';

					let eventHeaderHeight = height - totalHeights[2].querySelector('.event-header').getBoundingClientRect().height - 2;
					totalHeights[2].querySelector('.event-list').style.height = eventHeaderHeight + 'px';

					break;
				}
			}
		}
	}

	prevDateHeader = (event) => {
		console.log("method call => prevDateHeader");

		this.current_view_month--;
		if (this.current_view_month < 0) {
			this.current_view_month = 11;
			this.current_view_year--;
		}
		this.initCalendar();
	}

	nextDateHeader = (event) => {
		console.log("method call => nextDateHeader");

		this.current_view_month++;
		if (this.current_view_month > 11) {
			this.current_view_month = 0;
			this.current_view_year++;
		}
		this.initCalendar();
	}

	handleDragStart = (event) => {
		console.log("method call => handleDragStart");

		let type = event.currentTarget.dataset.type;
		if (type == 'Entity') {
			event.dataTransfer.setData("entityData", JSON.stringify(this.entityList[event.target.dataset.index]));
			event.dataTransfer.setData("type", type);

			event.target.classList.add('drag_source');
			this.template.querySelector('.drag_source_parent').style.opacity = '0.9';
		}
		else if (type == 'Event') {
			console.log(JSON.stringify(event.currentTarget.dataset));
			let day = event.currentTarget.dataset.day;
			let index = event.currentTarget.dataset.index;

			event.dataTransfer.setData("eventData", JSON.stringify(this.currentEvents[day][index]));
			event.dataTransfer.setData("type", type);
			event.dataTransfer.setData("day", day);
			event.dataTransfer.setData("index", index);
		}
	}

	handleDragEnd = () => {
		console.log("method call => handleDragEnd");

		let drag_source = this.template.querySelectorAll('.drag_source');

		for (let i = 0; i < drag_source.length; i++) {
			drag_source[i].classList.remove('drag_source');
			this.template.querySelector('.drag_source_parent').style.opacity = '1';
		}
	}

	handleDragOver = (event) => {
		console.log("method call => handleDragOver");

		event.preventDefault();
	}

	handleDrop = (event) => {
		console.log("method call => handleDrop");

		event.preventDefault();

		let type = event.dataTransfer.getData('type');

		if (type == 'Entity') {
			let day = Number(event.currentTarget.dataset.day);
			let entityData = event.dataTransfer.getData("entityData");

			new Promise((resolve, reject) => {
				setTimeout(() => {
					generateEvent({
						entityData: entityData,
						selectedDate: JSON.stringify(this.visibleMonthdatesList[day - 1])
					})
						.then((data) => {
							if (this.currentEvents[day] == null)
								this.currentEvents[day] = [];
							this.currentEvents[day].push(JSON.parse(data));
							this.addEventsToCalendar();
						})
						.catch((error) => {
							this.showToastOnError(error);
						});
				});
			});
		}
		else if (type == 'Event') {
			let newDay = Number(event.currentTarget.dataset.day);
			let eventData = JSON.parse(event.dataTransfer.getData("eventData"));
			let oldDay = Number(JSON.parse(event.dataTransfer.getData("day")));
			let index = Number(event.dataTransfer.getData('index'));

			let diffInNewDays = newDay - oldDay;

			new Promise((resolve, reject) => {
				setTimeout(() => {
					updateEventDragDrop({
						eventId: eventData.Id,
						diffInNewDays: diffInNewDays
					})
						.then((data) => {
							this.currentEvents[oldDay].splice(index, 1);
							if (this.currentEvents[newDay] == null)
								this.currentEvents[newDay] = [];
							this.currentEvents[newDay].push(JSON.parse(data));

							this.addEventsToCalendar();
						})
						.catch((error) => {
							this.showToastOnError(error);
						})
				});
			});
		}
	}

	handleTouchStart = (event) => {
		console.log("method call => handleTouchStart", event.targetTouches);
		event.preventDefault();

		this.currentTouchedType = event.currentTarget.dataset.type;
		if (this.currentTouchedType == 'Entity') {
			if (event.currentTarget.classList.contains('draggable')) {
				this.currentTouchedEntityRecord = this.entityList[event.currentTarget.dataset.index];
				console.log('handleTouchStart currentTouchedEntityRecord : ', this.currentTouchedEntityRecord);

				const dot = document.createElement('div');
				dot.classList.add('dot');
				dot.style.top = event.touches[0].pageY + 'px';
				dot.style.left = event.touches[0].pageX + 'px';
				dot.id = event.touches[0].identifier;

				const dots = this.template.querySelectorAll('.dot');
				for (let i = 0; i < dots.length; i++) {
					dots[i].setAttribute(this.lwcName, '');
				}
			}
		}
		else if (this.currentTouchedType == 'Event') {
			let day = event.currentTarget.dataset.day;
			let index = event.currentTarget.dataset.index;

			console.log('day index', day, index);

			this.currentTouchedEventRecord = this.currentEvents[day][index];
			this.currentTouchedEventDay = day;
			this.currentTouchedEventIndex = index;
		}
	}

	handleTouchMove = (event) => {
		console.log('method handleTouchMove');

		let touchX = event.touches[0].pageX;
		let touchY = event.touches[0].pageY - window.scrollY;

		let calendar_days = this.template.querySelector('.calendar').querySelector('.month_days').querySelectorAll('.day');

		this.dropZoneId = '';
		for (let i = 0; i < calendar_days.length; i++) {
			if (!(calendar_days[i].classList.contains('prev-date') || calendar_days[i].classList.contains('next-date'))) {

				let rect = calendar_days[i].getBoundingClientRect();

				var overlap1 = !(rect.right < touchX || rect.left > touchX || rect.bottom < touchY || rect.top > touchY);

				if (overlap1) {
					if (this.currentTouchedType == 'Entity') {
						calendar_days[i].style.border = "dotted";
						calendar_days[i].style.borderColor = "#0b79d0";

						this.dropZoneId = calendar_days[i];
					}
					else if (this.currentTouchedType == 'Event') {
						console.log('dataset day', calendar_days[i].dataset.day);
						console.log('currentTouchedEventDay day', this.currentTouchedEventDay);
						if (calendar_days[i].dataset.day == this.currentTouchedEventDay) {

						}
						else {
							calendar_days[i].style.border = "dotted";
							calendar_days[i].style.borderColor = "#0b79d0";

							this.dropZoneId = calendar_days[i];
						}
					}
				}
				else {
					calendar_days[i].style.removeProperty('border');
				}
			}
		}
	}

	handleTouchEnd = (event) => {
		console.log('method handleTouchEnd');

		if (this.dropZoneId) {
			this.dropZoneId.style.border = "none";

			if (this.currentTouchedType == 'Entity') {
				let day = Number(this.dropZoneId.dataset.day);

				console.log('handleTouchEnd day', day);
				console.log('handleTouchEnd currentTouchedEntityRecord', this.currentTouchedEntityRecord);
				let jsonData = JSON.stringify(this.currentTouchedEntityRecord);
				console.log('handleTouchEnd currentTouchedEntityRecord', jsonData);

				new Promise((resolve, reject) => {
					setTimeout(() => {
						generateEvent({
							entityData: jsonData,
							selectedDate: JSON.stringify(this.visibleMonthdatesList[day - 1])
						})
							.then((data) => {
								if (this.currentEvents[day] == null)
									this.currentEvents[day] = [];
								this.currentEvents[day].push(JSON.parse(data));
								this.addEventsToCalendar();
							})
							.catch((error) => {
								this.showToastOnError(error);
							});
					})
				});
			}
			else if (this.currentTouchedType == 'Event') {
				let newDay = Number(this.dropZoneId.dataset.day);

				let oldDay = Number(this.currentTouchedEventDay);
				let index = Number(this.currentTouchedEventIndex);

				let diffInNewDays = newDay - oldDay;

				console.log('handleTouchEnd currentTouchedEventRecord', this.currentTouchedEventRecord);
				this.currentTouchedEventRecord = JSON.parse(JSON.stringify(this.currentTouchedEventRecord));
				console.log('handleTouchEnd currentTouchedEventRecord', this.currentTouchedEventRecord);
				let recordId = this.currentTouchedEventRecord.Id;

				new Promise((resolve, reject) => {
					setTimeout(() => {
						updateEventDragDrop({
							eventId: recordId,
							diffInNewDays: diffInNewDays
						})
							.then((data) => {
								this.currentEvents[oldDay].splice(index, 1);
								if (this.currentEvents[newDay] == null)
									this.currentEvents[newDay] = [];
								this.currentEvents[newDay].push(JSON.parse(data));

								this.addEventsToCalendar();
							})
							.catch((error) => {
								this.showToastOnError(error);
							})
					});
				});
			}

			this.dropZoneId = null;

			this.currentTouchedEntityRecord = null;
			this.currentTouchedEventRecord = null;
			this.currentTouchedEventDay = null;
			this.currentTouchedType = null;
			this.currentTouchedEventIndex = null;
		}
	}



	handleDayClick = (event) => {
		console.log("method call => handleDayClick");

		// Resetting properties
		this.selectedDateEventsList = null; // Reset the selected events list
		this.allAcountId = [];
		this.toggleaccId = '';

		// Get the index of the clicked day
		const dayIndex = event.currentTarget.dataset.day;
		this.currentIndexOfDayOpenInRightComponent = dayIndex;

		// Build the event view current date string
		const selectedDay = this.visibleMonthdatesList[dayIndex - 1];
		this.eventViewCurrentDate = `${selectedDay.day} ${this.months[this.current_view_month]} ${selectedDay.year}`;

		// Check if there are events for the selected date
		if (!this.currentEvents[dayIndex] || this.currentEvents[dayIndex].length === 0) {
			console.warn('Clicked on a blank date');

			// Ensure selectedDateEventsList is reset when clicking on a blank date
			this.selectedDateEventsList = [];
			this.handleComponentHeight(); // Adjust component height if needed
			return; // Early return if clicked on a blank date
		}

		// Retrieve events for the selected date
		this.selectedDateEventsList = this.currentEvents[dayIndex];
		console.log('event id', this.selectedDateEventsList);

		let recs = [];

		// Loop through selected events to gather WhatIds
		for (let i = 0; i < this.selectedDateEventsList.length; i++) {
			const eventItem = this.selectedDateEventsList[i];
			if (eventItem) {
				let opp = Object.assign({}, eventItem);
				recs.push(opp.WhatId);
			}
		}

		console.log('allAccountId++', recs);
		this.toggleaccId = recs;
		this.accountNameParam = recs;
		console.log('toggleaccId', this.toggleaccId);

		// Process each event item
		if (this.selectedDateEventsList) {
			this.selectedDateEventsList.forEach(item => {
				item.isExpanded = false;
				this.handleWhoAndWhatLookups(item);

				// Uncomment this section for specific WhoId and WhatId handling if needed
				/*
				if (item.WhoId) {
					if (item.WhoId.startsWith('00Q')) {
						item.WhoName = 'Lead';
						item.isLead = true;
						item.isContact = false;
						item.isSale = true;
						item.isService = false;
					} else if (item.WhoId.startsWith('003')) {
						item.WhoName = 'Contact';
						item.isLead = false;
						item.isContact = true;
						item.isSale = true;
						item.isService = false;
					}
				}
    
				if (item.WhatId) {
					if (item.WhatId.startsWith('001')) {
						item.WhatName = 'Account';
						item.isAccount = true;
						item.isOpportunity = false;
						item.isOrder = false;
						item.isAsset = false;
						item.isCase = false;
						item.isSale = true;
						item.isService = false;
					} else if (item.WhatId.startsWith('006')) {
						item.WhatName = 'Opportunity';
						item.isOpportunity = true;
						item.isAccount = false;
						item.isOrder = false;
						item.isAsset = false;
						item.isCase = false;
						item.isSale = true;
						item.isService = false;
					} else if (item.WhatId.startsWith('801')) {
						item.WhatName = 'Order';
						item.isOrder = true;
						item.isAccount = false;
						item.isOpportunity = false;
						item.isAsset = false;
						item.isCase = false;
						item.isSale = true;
						item.isService = false;
					} else if (item.WhatId.startsWith('02i')) {
						item.WhatName = 'Asset';
						item.isAsset = true;
						item.isAccount = false;
						item.isOpportunity = false;
						item.isOrder = false;
						item.isCase = false;
						item.isSale = false;
						item.isService = true;
					} else if (item.WhatId.startsWith('500')) {
						item.WhatName = 'Case';
						item.isCase = true;
						item.isAccount = false;
						item.isOpportunity = false;
						item.isOrder = false;
						item.isAsset = false;
						item.isSale = false;
						item.isService = true;
					}
				}
				*/
			});
		}

		this.handleComponentHeight(); // Adjust component height
		this.toggleaccId = recs; // Finalize toggleaccId
	};

	handleExpandEvent = (event) => {
		console.log("method call => handleExpandEvent");

		this.selectedDateEventsList.forEach(item => {
			item.isExpanded = false;

		});
		this.selectedDateEventsList[event.currentTarget.dataset.index].isExpanded = true;
		this.handleWhoAndWhatLookups(this.selectedDateEventsList[event.currentTarget.dataset.index]);
	}

	handleWhoAndWhatLookups = (item) => {
		console.log("method call => handleWhoAndWhatLookups");

		if (item.WhoId) {
			if (item.WhoId.startsWith('00Q')) {
				item.WhoName = 'Lead__c';
				item.isLead = true;
				item.isContact = false;

				item.isSale = true;
				item.isService = false;
			}
			else if (item.WhoId.startsWith('003')) {
				item.WhoName = 'Contact';
				item.isLead = false;
				item.isContact = true;

				item.isSale = true;
				item.isService = false;
			}
		}
		if (item.WhatId) {
			if (item.WhatId.startsWith('001')) {
				item.WhatName = 'Account';
				item.isAccount = true;
				item.isOpportunity = false;
				item.isOrder = false;
				item.isAsset = false;
				item.isCase = false;

				item.isSale = true;
				item.isService = false;
			}
			else if (item.WhatId.startsWith('006')) {
				item.WhatName = 'Opportunity__c';
				item.isOpportunity = true;
				item.isAccount = false;
				item.isOrder = false;
				item.isAsset = false;
				item.isCase = false;

				item.isSale = true;
				item.isService = false;
			}
			else if (item.WhatId.startsWith('801')) {
				item.WhatName = 'Order__c';
				item.isOrder = true;
				item.isAccount = false;
				item.isOpportunity = false;
				item.isAsset = false;
				item.isCase = false;

				item.isSale = true;
				item.isService = false;
			}
			else if (item.WhatId.startsWith('02i')) {
				item.WhatName = 'Asset__c';
				item.isAsset = true;
				item.isAccount = false;
				item.isOpportunity = false;
				item.isOrder = false;
				item.isCase = false;

				item.isSale = false;
				item.isService = true;
			}
			else if (item.WhatId.startsWith('500')) {
				item.WhatName = 'Case__c';
				item.isCase = true;
				item.isAccount = false;
				item.isOpportunity = false;
				item.isOrder = false;
				item.isAsset = false;

				item.isSale = false;
				item.isService = true;
			}
		}
	}

	handleEventDetailsChange = (event) => {
		console.log("method call => handleEventDetailsChange");

		if (JSON.stringify(event.currentTarget.dataset) == '') {
			return;
		}

		let currentEvent = this.selectedDateEventsList[event.currentTarget.dataset.index];

		switch (event.currentTarget.dataset.api) {
			case 'Subject':
			case 'Description':
			case 'Meeting_Purpose__c':
			case 'Visit_Purpose__c':
			case 'Appointment_Taken__c':
			case 'EndDateTime':
			case 'Description':
				{
					currentEvent[event.currentTarget.dataset.api] = event.target.value;
					break;
				}
			case 'StartDateTime': {
				currentEvent.StartDateTime = event.target.value;

				let indexOfT = currentEvent.StartDateTime.indexOf('T') + 1;
				let startHour = currentEvent.StartDateTime.substr(indexOfT, 2);
				startHour = (parseInt(startHour) + 1).toString();
				if (startHour.length < 2) {
					startHour = '0' + startHour;
				}
				currentEvent.EndDateTime = currentEvent.StartDateTime.substr(0, indexOfT) + startHour +
					currentEvent.StartDateTime.substr(indexOfT + 2, currentEvent.StartDateTime.length - 1);
				break;
			}
			case 'Attendees': {
				if (currentEvent.Attendees == null || currentEvent.Attendees == undefined) {
					currentEvent.Attendees = [];
				}
				if (event.detail.selectedData) {
					currentEvent.Attendees.push({ Id: event.detail.selectedData.Id, Name: event.detail.selectedData.Name });
					this.isAttendeesVisible = !this.isAttendeesVisible;
				}
				break;
			}
			case 'WhoName': {
				switch (event.detail.value) {
					case 'Lead__c': {
						currentEvent.isLead = true;
						currentEvent.isContact = false;

						currentEvent.isSale = true;
						currentEvent.isService = false;
						break;
					}
					case 'Contact': {
						currentEvent.isLead = false;
						currentEvent.isContact = true;

						currentEvent.isSale = true;
						currentEvent.isService = false;
						break;
					}
				}
				break;
			}
			case 'WhoId': {
				currentEvent.WhoId = event.detail.selectedRecordId;
				break;
			}
			case 'WhatName': {
				switch (event.detail.value) {
					case 'Account': {
						currentEvent.isAccount = true;
						currentEvent.isOpportunity = false;
						currentEvent.isOrder = false;
						currentEvent.isCase = false;
						currentEvent.isAsset = false;

						currentEvent.isSale = true;
						currentEvent.isService = false;
						break;
					}
					case 'Opportunity__c': {
						currentEvent.isOpportunity = true;
						currentEvent.isAccount = false;
						currentEvent.isOrder = false;
						currentEvent.isCase = false;
						currentEvent.isAsset = false;

						currentEvent.isSale = true;
						currentEvent.isService = false;
						break;
					}
					case 'Order__c': {
						currentEvent.isOrder = true;
						currentEvent.isAccount = false;
						currentEvent.isOpportunity = false;
						currentEvent.isCase = false;
						currentEvent.isAsset = false;

						currentEvent.isSale = true;
						currentEvent.isService = false;
						break;
					}
					case 'Case__c': {
						currentEvent.isCase = true;
						currentEvent.isOrder = false;
						currentEvent.isAccount = false;
						currentEvent.isOpportunity = false;
						currentEvent.isAsset = false;

						currentEvent.isSale = false;
						currentEvent.isService = true;
						break;
					}
					case 'Asset__c': {
						currentEvent.isAsset = true;
						currentEvent.isAccount = false;
						currentEvent.isOpportunity = false;
						currentEvent.isOrder = false;
						currentEvent.isCase = false;

						currentEvent.isSale = false;
						currentEvent.isService = true;
						break;
					}
				}
				break;
			}
			case 'WhatId': {
				currentEvent.WhatId = event.detail.selectedRecordId;
				break;
			}
		}
	}

	handleRemoveAttendee = (event) => {
		console.log("method call => handleRemoveAttendee");

		let currentEvent = this.selectedDateEventsList[event.currentTarget.dataset.index];
		currentEvent.Attendees.splice(event.currentTarget.dataset.attendeeIndex, 1);
	}

	updateEventAction = (event) => {
		console.log("method call => updateEventAction");

		if (event.currentTarget.dataset.action == 'Cancel') {
			let index = event.currentTarget.dataset.index;

			this.selectedDateEventsList[index].isExpanded = false;

			new Promise((resolve, reject) => {
				setTimeout(() => {
					getSingleEvent({
						eventId: this.selectedDateEventsList[index].Id
					})
						.then((data) => {
							this.selectedDateEventsList[index] = JSON.parse(data);
						})
						.catch((error) => {
							this.showToastOnError(error);
						});
				});
			});
		}
		else if (event.currentTarget.dataset.action == 'Submit') {
			this.showSpinner = true;
			let index = event.currentTarget.dataset.index;

			new Promise((resolve, reject) => {
				setTimeout(() => {
					updateEvent({
						eventData: JSON.stringify(this.selectedDateEventsList[index])
					})
						.then((data) => {
							this.selectedDateEventsList[index] = JSON.parse(data);

							this.dispatchEvent(new ShowToastEvent({
								title: 'Success',
								message: 'Record updated successfully',
								variant: 'success'
							}));

							this.addEventsToCalendar();

							this.showSpinner = false;
						})
						.catch((error) => {
							this.showToastOnError(error);
						});
				});
			});
		}
		else if (event.currentTarget.dataset.action == 'Delete') {
			this.showSpinner = true;
			let index = event.currentTarget.dataset.index;

			new Promise((resolve, reject) => {
				setTimeout(() => {
					deleteEvent({
						eventId: this.selectedDateEventsList[index].Id
					})
						.then((data) => {
							this.selectedDateEventsList.splice(index, 1);

							this.dispatchEvent(new ShowToastEvent({
								title: 'Success',
								message: 'Record deleted successfully',
								variant: 'success'
							}));

							this.addEventsToCalendar();

							this.showSpinner = false;
						})
						.catch((error) => {
							this.showToastOnError(error);
						})

				});
			});
		};
	}

	handleSubmitForApproval = (event) => {
		console.log("method call => handleSubmitForApproval");

		if (!this.recordId) {
			new Promise((resolve, reject) => {
				setTimeout(() => {
					submitForApproval({
						currentYear: this.current_view_year,
						currentMonth: this.current_view_month + 1
					})
						.then((data) => {
							this.dispatchEvent(new ShowToastEvent({
								//	title: 'Success',
								message: 'Successfully submitted for Approval',
								variant: 'success'
							}));
						})
						.catch((error) => {
							this.showToastOnError(error);
						})
				});
			});
		}
	}


	showToastOnError(error) {
		console.log("method call => showToastOnError");

		console.warn(error);

		let msg;
		if (error.message)
			msg = error.message;
		else if (error.body.message)
			msg = error.body.message;

		this.dispatchEvent(new ShowToastEvent({
			title: 'Error',
			message: msg,
			variant: 'error',
			mode: 'sticky'
		}));

		this.showSpinner = false;
	}

	handleToggleChange(event) {
		this.isMapVisible = event.target.checked;
		this.accountNameParam = this.toggleaccId;
		//this.accountNameParam = '001dM00000JOftbQAD';
		console.log('accountNameParam id', this.accountNameParam);
	}

}