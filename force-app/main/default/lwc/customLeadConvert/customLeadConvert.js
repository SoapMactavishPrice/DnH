import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


import FORM_FACTOR from '@salesforce/client/formFactor';

import getLeadRecord from '@salesforce/apex/CustomLeadConvertController.getLeadRecord';
import getAccRecTypes from '@salesforce/apex/CustomLeadConvertController.getAccRecTypes';
import getEnquiryRecordTypes from '@salesforce/apex/CustomLeadConvertController.getEnquiryRecordTypes';
//import getAccountsByPinCode from '@salesforce/apex/CustomLeadConvert.getAccountsByPinCode';
import convertLead from '@salesforce/apex/CustomLeadConvertController.convertLead';

export default class CustomLeadConvert extends NavigationMixin(LightningElement) {
	@track showSpinner;

	@api recordId;

	@track isMobile;
	@track isTablet;
	@track isDesktop;
	@track isNewAccountFlag = false;
	@track isExistingAccountFlag = false;
	@track is_Account_OR = false;
	@track isNewContactFlag = false;
	@track isExistingContactFlag = false;
	@track is_Contact_OR = false;
	@track isNewEnquiryFlag = false;
	@track isExistingEnquiryFlag = false;
	@track is_Enquiry_OR = false;
	@track isCreateEnquiryChecked = false;

	@track leadRecord;
	@track leadName;
	@track accRecordTypes;

	@track modalHeader;

	/* Required, disabled handlers starts here */
	@track AccountCreateNew = true;
	@track AccountCreateNewName;
	@track AccountCreateNewRT;
	@track AccountExisting;
	@track AccountExistingShowError = false;

	@track ContactCreateNew = true;
	@track ContactName;
	@track ContactExisting;
	@track contactExistingFilter = '';
	@track ContactExistingShowError = false;

	@track OpportunityCreateNew = true;
	@track OpportunityCreateNewName = true;
	@track OpportunityExisting;
	@track OpportunityExistingShowError = false;
	/* Required, disabled handlers ends here */

	/* Variables to store values starts here */
	@track accountName;
	@track accountRecordType;
	@track selectedAccountId;
	@track refreshSelectedAccountId = false;

	@track isDirectCustomerChecked = false;
	@track dealerValue = '';

	@track contactSalutation;
	@track contactFirstName;
	@track contactMiddleName;
	@track contactLastName;
	@track selectedContactId;
	@track refreshSelectedContactId = false;

	@track opportunityName;
	@track selectedOpportunityId;
	@track refreshSelectedOpportunityId = false;
	@track recordTypeOptions = [];
	@track selectedRecordTypeId;

	/* Variables to store values ends here */

	/* Variables for Datatable starts here */
	@track accountNameRef;
	pinCode;
	timeoutInstance;
	sortDirection = 'asc';
	sortedBy = 'Name';

	records;
	filteredRecords;
	recordsToDisplay;
	columns;
	totalRecords = 0;
	totalPages;
	pageSize = 10;
	totalPages;
	pageNumber = 1;
	searchKeyword = '';

	showExistingAccountsSection = false;
	/* Variables for Datatable ends here */

	salutationOptions = [
		{ label: 'Mr.', value: 'Mr.' },
		{ label: 'Ms.', value: 'Ms.' },
		{ label: 'Mrs.', value: 'Mrs.' },
		{ label: 'Dr.', value: 'Dr.' },
		{ label: 'Prof.', value: 'Prof.' }
	];

	fieldList = ['salutation', 'firstName', 'middleName', 'lastName'];

	pageSizeOptions = [
		{ label: 10, value: 10 },
		{ label: 20, value: 20 },
		{ label: 30, value: 30 },
		{ label: 40, value: 40 },
		{ label: 50, value: 50 }
	];

	connectedCallback() {
		// this.recordId = 'a0I1m000002BjTH';
		this.getLeadRecord();
		//this.getAccRecTypes();

		if (this.isMobile != (FORM_FACTOR == "Small")) {
			this.isMobile = FORM_FACTOR === "Small";
		}
		if (this.isTablet != (FORM_FACTOR == "Medium")) {
			this.isTablet = FORM_FACTOR === "Medium";
		}
		if (this.isDesktop != (FORM_FACTOR == "Large")) {
			this.isDesktop = FORM_FACTOR === "Large";
		}
		console.log('isMobile =>> ', this.isMobile);
		console.log('isTablet =>> ', this.isTablet);
		console.log('isDesktop =>> ', this.isDesktop);

		if (this.isDesktop) {
			this.isNewAccountFlag = true;
			this.isExistingAccountFlag = true;
			this.is_Account_OR = true;
			this.isNewContactFlag = true;
			this.isExistingContactFlag = true;
			this.is_Contact_OR = true;
			this.isNewEnquiryFlag = true;
			this.isExistingEnquiryFlag = true;
			this.is_Enquiry_OR = true;
		} else if (this.isMobile) {
			this.isNewAccountFlag = true;
			this.isExistingAccountFlag = false;
			this.is_Account_OR = false;
			this.isNewContactFlag = true;
			this.isExistingContactFlag = false;
			this.is_Contact_OR = false;
			this.isNewEnquiryFlag = true;
			this.isExistingEnquiryFlag = false;
			this.is_Enquiry_OR = false;
		}

		this.decideRequiredOrNot();
	}

	renderedCallback() {
		// Query the lightning-input with the name attribute or any other identifier
		console.log('kk');
		console.log('FORM_FACTOR =>> ', FORM_FACTOR === "Large");
		//if (!this.refs.accountNameRef) {
		//this.refs.accountNameRef = this.template.querySelector('lightning-input[name="accountName"]');
		// }

	}



	getLeadRecord() {
		new Promise((resolve, reject) => {
			setTimeout(() => {
				getLeadRecord({ recordId: this.recordId })
					.then((data) => {
						let isError = false;
						/*
						if (data.Lead_Stage__c != 'Qualified') {
								this.showToastOnError(
										Error('Please Ensure Lead Is Qualified')
								);
								isError = true;
						}
						if (
								(data.Industry_Type__c == null ||
										data.Industry_Type__c == undefined) &&
								(data.Business_Unit__c == 'FCD' ||
										data.Business_Unit__c == 'FSD' ||
										data.Business_Unit__c == 'SCVD')
						) {
								this.showToastOnError(
										Error(
												'Industry type is mandatory while converting the Lead'
										)
								);
								isError = true;
						}
					 
						if (
								(data.Email__c == null ||
										data.Email__c == undefined) &&
								(data.Business_Unit__c == 'FCD' ||
										data.Business_Unit__c == 'FSD' ||
										data.Business_Unit__c == 'SCVD')
						) {
								this.showToastOnError(
										Error(
												'Email is mandatory while converting the Lead'
										)
								);
								isError = true;
						}
						/*
						if (
								data.Business_Unit__c == null ||
								data.Business_Unit__c == undefined
						) {
								this.showToastOnError(
										Error(
												'Business unit is required field, please verify'
										)
								);
								isError = true;
						}
						if (
								(data.Products__c == null ||
										data.Products__c == undefined) &&
								(data.Product_Interested__c == null ||
										data.Product_Interested__c == undefined)
						) {
								this.showToastOnError(
										Error(
												'Product interested is required field, please verify'
										)
								);
								isError = true;
						}*/
						if (isError) {
							this.closeComponent();
							return;
						}

						this.leadRecord = data;

						this.accountName = this.leadRecord.Name;

						this.contactSalutation = this.leadRecord.Salutation__c;
						this.contactFirstName = this.leadRecord.First_Name__c;
						this.contactMiddleName = this.leadRecord.Middle_Name__c;
						this.contactLastName = this.leadRecord.Last_Name__c;

						this.opportunityName = this.leadRecord.Name;

						this.modalHeader =
							'Convert ' +
							//this.leadRecord.First_Name__c +
							//' ' +
							this.leadRecord.Name;

						/*
						if (this.leadRecord.Address_Informations__r) {
								console.log(this.pinCode);
								this.pinCode =
										this.leadRecord.Address_Informations__r[0].ZipPostal_Code__c;
								console.log(this.pinCode);

								this.getAccountRecords();
						}*/
					})
					.catch((error) => {
						this.showToastOnError(error);
					});
			}, 0);
		});
	}

	getAccRecTypes() {
		new Promise((resolve, reject) => {
			setTimeout(() => {
				getAccRecTypes()
					.then((data) => {
						this.accRecordTypes = data;
					})
					.catch((error) => {
						this.showToastOnError(error);
					});
			}, 0);
		});
	}


	@wire(getEnquiryRecordTypes)
	wiredRecordTypes({ data, error }) {
		if (data) {
			this.recordTypeOptions = data.map(recordType => ({
				label: recordType.Name,
				value: recordType.Id
			}));
		} else if (error) {
			console.error('Error fetching record types: ', error);
		}
	}
	decideRequiredOrNot(event) {

		if (event == null || event.target.value == 'AccountCreateNew') {

			if (this.isMobile) {
				this.isNewAccountFlag = true;
				this.isExistingAccountFlag = false;
			}

			// for Account
			this.AccountCreateNew = true;
			this.AccountExisting = false;

			// for Contact
			const radios = this.template.querySelectorAll('.contact-radio');
			if (radios.length == 2) {
				radios[0].checked = true;
				radios[1].checked = false;
			}
			this.ContactCreateNew = true;
			this.ContactExisting = false;
			this.ContactName = true;
			this.ContactExistingShowError = false;

			// for validations (required)
			this.AccountCreateNewName = true;
			this.AccountCreateNewRT = true;

			this.AccountExistingName = false;
			this.AccountExistingShowError = false;
		} else if (event.target.value == 'AccountExisting') {

			if (this.isMobile) {
				this.isNewAccountFlag = false;
				this.isExistingAccountFlag = true;
			}

			// for Account
			this.AccountCreateNew = false;
			this.AccountExisting = true;

			// remove validation from create new
			// const accountFields = this.template.querySelectorAll('.account-fields');
			// for (let i = 0; i < accountFields.length; i++) {
			//     accountFields[i].setCustomValidity(' ');
			//     accountFields[i].reportValidity();
			//     console.log(accountFields[i].className);
			//     accountFields[i].className = accountFields[i].className.replace('slds-has-error', '');
			// }

			// for validations (required)
			this.AccountCreateNewName = false;
			this.AccountCreateNewRT = false;

			this.AccountExistingName = true;
			this.AccountExistingShowError = false;
		} else if (event.target.value == 'ContactCreateNew') {

			if (this.isMobile) {
				this.isNewContactFlag = true;
				this.isExistingContactFlag = false;
			}

			// for Contact
			this.ContactCreateNew = true;
			this.ContactExisting = false;

			// for validations (required)
			this.ContactName = true;
			this.ContactExistingShowError = false;
		} else if (event.target.value == 'ContactExisting') {

			if (this.isMobile) {
				this.isNewContactFlag = false;
				this.isExistingContactFlag = true;
			}

			// for Contact
			this.ContactCreateNew = false;
			this.ContactExisting = true;

			// for validations (required)
			this.ContactName = false;
			this.ContactExistingShowError = false;
		} else if (event.target.value == 'OpportunityCreateNew') {

			if (this.isMobile) {
				this.isNewEnquiryFlag = true;
				this.isExistingEnquiryFlag = false;
			}

			// for Opportunity
			this.OpportunityCreateNew = true;
			this.OpportunityExisting = false;

			// for validations (required)
			this.OpportunityCreateNewName = true;
		} else if (event.target.value == 'OpportunityExisting') {

			if (this.isMobile) {
				this.isNewEnquiryFlag = false;
				this.isExistingEnquiryFlag = true;
			}

			// for Opportunity
			this.OpportunityCreateNew = false;
			this.OpportunityExisting = true;

			// for validations (required)
			this.OpportunityCreateNewName = false;
		}

		if (event) this.reportValidity();
	}

	reportValidity() {

		if (this.AccountCreateNew) {
			if (this.refs.accountNameRef || this.refs.accountRTRef) {
				const element = this.template.querySelector('#acc-create-new');
				if (element) {
					element.setCustomValidity('');
					element.reportValidity();
				} else {
					console.error('Element not found');
				}
				// this.refs.accountNameRef.setCustomValidity('');
				// console.log('this.refs.accountNameRef customvalidity if',this.refs.accountNameRef);
				// this.refs.accountNameRef.reportValidity();
				// console.log('this.refs.accountNameRef Reportvalidity if',this.refs.accountNameRef);
				// this.refs.accountRTRef.setCustomValidity('');
				// console.log('this.refs.accountRTRef customvalidity if',this.refs.accountRTRef);
				// this.refs.accountRTRef.reportValidity();
				// console.log('this.refs.accountRTRef Reportvalidity if',this.refs.accountRTRef);
			}
		} else {
			if (this.refs.accountNameRef || this.refs.accountRTRef) {
				console.log('11');
				const element = this.template.querySelector('#acc-create-new');
				if (element) {
					element.setCustomValidity('');
					element.reportValidity();
					element.classList.remove('slds-has-error');
				} else {
					console.error('Element not found');
				}
				// this.refs.accountNameRef.setCustomValidity('');
				// console.log('this.refs.accountNameRef customvalidity', this.refs.accountNameRef);
				// this.refs.accountNameRef.reportValidity();
				// console.log('this.refs.accountNameRef Reportvalidity', this.refs.accountNameRef);
				// this.accountRTRef.setCustomValidity('');
				// console.log('this.refs.accountRTRef customvalidity', this.accountRTRef);
				// this.accountRTRef.reportValidity();
				// console.log('this.refs.accountRTRef Reportvalidity', this.accountRTRef);
				// this.accountNameRef.classList.remove('slds-has-error');
				// this.accountRTRef.classList.remove('slds-has-error');

				console.log('13');
			}

		}

		/*
		if (this.ContactCreateNew) {
				this.refs.contactNameRef.setCustomValidityForField('', 'lastName');
				this.refs.contactNameRef.reportValidity();
		} else {
				this.refs.contactNameRef.setCustomValidityForField(' ', 'lastName');
				this.refs.contactNameRef.reportValidity();
				const lastName = this.refs.contactNameRef.querySelector('.slds-has-error');
				if (lastName)
						lastName.classList.remove('slds-has-error');
		}
		*/

		if (this.OpportunityCreateNew) {
			// this.refs.opportunityNameRef.setCustomValidity('');
			// this.refs.opportunityNameRef.reportValidity();
			const element = this.template.querySelector('#opp-create-new');
			if (element) {
				element.setCustomValidity('');
				element.reportValidity();
			} else {
				console.error('Element not found');
			}
		} else {
			console.log('23');
			// this.refs.opportunityNameRef.setCustomValidity(' ');
			// this.refs.opportunityNameRef.reportValidity();
			const element = this.template.querySelector('#opp-create-new');
			if (element) {
				element.setCustomValidity('');
				element.reportValidity();
				element.classList.remove('slds-has-error');
			} else {
				console.error('Element not found');
			}
			// this.refs.opportunityNameRef.classList.remove('slds-has-error');

		}
	}



	handleValueChange(event) {
		if (event.target.name != 'ContactName') {
			// event.target.setCustomValidity("");
			// event.target.reportValidity();
		}

		if (event.target.name == 'ContactName') {
			this.contactSalutation = event.target.salutation;
			this.contactFirstName = event.target.firstName;
			this.contactMiddleName = event.target.middleName;
			this.contactLastName = event.target.lastName;
		} else if (event.target.name == 'PageSize') {
			this.pageSize = parseInt(event.target.value);
			console.log('pageSize', this.pageSize);
			this.paginationHelper();
		} else if (event.target.name == 'Search') {
			this.searchKeyword = event.target.value;

			clearTimeout(this.timeoutInstance);
			this.timeoutInstance = setTimeout(() => {
				if (
					this.searchKeyword == null ||
					this.searchKeyword == undefined ||
					this.searchKeyword == ''
				)
					this.searchKeyword = '';
				this.filterRecords();
			}, 500);
		} else if (event.target.name == 'PinCode') {
			if (event.target.checkValidity()) {
				this.pinCode = event.target.value;

				clearTimeout(this.timeoutInstance);
				this.timeoutInstance = setTimeout(() => {
					this.getAccountRecords();
				}, 500);
			} else {
				clearTimeout(this.timeoutInstance);
			}
		} else {
			this[event.target.name] = event.target.value;
			console.log('accountRecordType', this.accountRecordType);
		}
	}

	handleIsDirectCustomerCheck(event) {
		// console.log(event.detail.value);
		// console.log(event.detail.checked);

		this.isDirectCustomerChecked = event.detail.checked;
	}

	handleExistingAccountSelect(event) {
		if (event.detail.selectedRecordId) {
			this.selectedAccountId = event.detail.selectedRecordId;
			this.AccountExistingShowError = false;

			this.contactExistingFilter =
				"AccountId = '" + this.selectedAccountId + "'";
		} else {
			this.selectedAccountId = null;
			this.contactExistingFilter = '';
		}
		this.refreshSelectedContactId = !this.refreshSelectedContactId;
	}

	handleExistingContactSelect(event) {
		if (event.detail.selectedRecordId) {
			this.selectedContactId = event.detail.selectedRecordId;
			this.ContactExistingShowError = false;
		} else {
			this.selectedContactId = null;
		}
	}

	handleExistingOpportunitySelect(event) {
		if (event.detail.selectedRecordId) {
			this.selectedOpportunityId = event.detail.selectedRecordId;
		} else {
			this.selectedOpportunityId = null;
		}
	}

	getAccountRecords() {
		this.columns = [
			{
				label: 'Account Name',
				fieldName: 'Name',
				type: 'text',
				cellAttributes: { alignment: 'left' }
			},
			{
				label: 'City Name',
				fieldName: 'City_Name__c',
				type: 'text',
				cellAttributes: { alignment: 'left' }
			},
			{
				label: 'Business Unit',
				fieldName: 'Business_Unit__c',
				type: 'text',
				cellAttributes: { alignment: 'left' }
			},
			{
				label: 'Account Division Name',
				fieldName: 'Account_Division_Text__c',
				type: 'text',
				cellAttributes: { alignment: 'left' }
			},
			{
				label: 'Customer Code',
				fieldName: 'Customer_Code__c',
				type: 'text',
				cellAttributes: { alignment: 'left' }
			},
			{
				label: 'Owner Name',
				fieldName: 'Owner_Name__c',
				type: 'text',
				cellAttributes: { alignment: 'left' }
			}
		];
		// , type: 'text', sortable: true, cellAttributes: { alignment: 'left'

		if (!this.showSpinner) this.showSpinner = true;
		/*
		getAccountsByPinCode({ pinCode: this.pinCode })
				.then((data) => {
						if (data) {
								this.records = data;
								this.filteredRecords = data;
								this.showExistingAccountsSection = true;
								console.log('records', this.records);
								this.paginationHelper();
						} else {
								this.records = null;
								this.filteredRecords = null;
								this.recordsToDisplay = null;
						}
				})
				.catch((error) => {
						this.records = null;
						this.showToastOnError(error);
				});*/
	}

	/*
		sortBy(field, reverse, primer) {
				const key = primer
						? function (x) {
								return primer(x[field]);
						}
						: function (x) {
								return x[field];
						};

				return function (a, b) {
						a = key(a);
						b = key(b);
						return reverse * ((a > b) - (b > a));
				};
		}


		onHandleSort(event) {
				const { fieldName: sortedBy, sortDirection } = event.detail;
				const cloneData = [...this.filteredRecords];

				cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
				this.filteredRecords = cloneData;
				this.sortDirection = sortDirection;
				this.sortedBy = sortedBy;

				const cloneDataRecords = [...this.records];
				cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
				this.records = cloneDataRecords;

				this.paginationHelper();
		}
	*/

	filterRecords() {
		if (!this.showSpinner) this.showSpinner = true;

		this.filteredRecords = this.records.filter((rec) =>
			JSON.stringify(rec)
				.toLowerCase()
				.includes(this.searchKeyword.toLowerCase())
		);

		if (this.filteredRecords.length == 0) {
			this.showToastOnWarning('Warning', 'No matching records found!');
		}

		console.log('records', this.records.length, this.records);
		console.log(
			'filteredRecords',
			this.filteredRecords.length,
			this.filteredRecords
		);

		this.paginationHelper();
	}

	get bDisableFirst() {
		return this.pageNumber == 1;
	}

	get bDisableLast() {
		return this.pageNumber == this.totalPages;
	}

	handleRecordsPerPage(event) {
		this.pageSize = event.target.value;
		this.paginationHelper();
	}

	previousPage() {
		this.pageNumber = this.pageNumber - 1;
		this.paginationHelper();
	}

	nextPage() {
		this.pageNumber = this.pageNumber + 1;
		this.paginationHelper();
	}

	/*
		firstPage() {
				this.pageNumber = 1;
				this.paginationHelper();
		}

		lastPage() {
				this.pageNumber = this.totalPages;
				this.paginationHelper();
		}
	*/

	paginationHelper() {
		if (!this.showSpinner) this.showSpinner = true;

		if (this.records) {
			// if (this.filteredRecords == null || this.filteredRecords.length == 0)
			// this.filteredRecords = this.records;

			this.totalRecords = this.filteredRecords.length;

			this.recordsToDisplay = [];
			// calculate total pages
			this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
			// set page number
			if (this.pageNumber <= 1) {
				this.pageNumber = 1;
			} else if (this.pageNumber >= this.totalPages) {
				this.pageNumber = this.totalPages;
			}
			// set records to display on current page
			for (
				let i = (this.pageNumber - 1) * this.pageSize;
				i < this.pageNumber * this.pageSize;
				i++
			) {
				if (i === this.totalRecords) {
					break;
				}
				this.recordsToDisplay.push(this.filteredRecords[i]);
			}
			console.log(
				'recordsToDisplay',
				this.recordsToDisplay.length,
				this.recordsToDisplay
			);
		}

		this.showSpinner = false;
	}

	handleRowSelection(event) {
		console.log(event.detail.selectedRows);
		this.refreshSelectedAccountId = !this.refreshSelectedAccountId;
		this.refreshSelectedContactId = !this.refreshSelectedContactId;
		this.selectedContactId = undefined;

		if (event.detail.selectedRows.length > 0) {
			this.selectedAccountId = event.detail.selectedRows[0].Id;
			this.contactExistingFilter =
				"AccountId = '" + this.selectedAccountId + "'";

			const col1 = this.template.querySelector('.col1');
			if (col1)
				col1.scrollIntoView({
					behavior: 'smooth',
					block: 'center',
					inline: 'nearest'
				});

			this.AccountCreateNew = false;
			this.AccountExisting = true;

			setTimeout(() => {
				const existingAccountLookup = this.template.querySelector(
					'.existing-account-lookup'
				);
				if (existingAccountLookup) {
					existingAccountLookup.classList.add('highlight');
				}
				setTimeout(() => {
					existingAccountLookup.classList.remove('highlight');
				}, 3000);
			}, 500);
		}
	}

	validateOnSubmit(event) {
		let isError = false;

		console.log(this.isDirectCustomerChecked);

		if (!this.isDirectCustomerChecked) {
			const dealerField = this.template.querySelector('[data-id="dealerField"]');
			if (!dealerField.value) {
				let ms = {
					message: 'Assign with Dealer is required'
				};
				this.showToastOnError(ms);
				isError = true;
			} else {
				this.dealerValue = dealerField.value;
			}
		}

		/*
		console.log('11');
		if (this.AccountCreateNew) {
				console.log('22');
				if (this.refs.accountNameRef.checkValidity() == false) {
						console.log('33');
						this.refs.accountNameRef.setCustomValidity('Complete this field.');
						this.refs.accountNameRef.reportValidity();
						isError = true;
				}
				console.log('drr');
				if (this.refs.accountRTRef.checkValidity() == false) {
						console.log('44');
						this.refs.accountRTRef.setCustomValidity('Complete this field.');
						this.refs.accountRTRef.reportValidity();
						isError = true;
				}
		  
		} else if (this.AccountExisting) {
				console.log('55');
				if (this.selectedAccountId == null || this.selectedAccountId == undefined || this.selectedAccountId == '') {
						this.AccountExistingShowError = true;
						isError = true;
				}
		}
	 
		if (this.ContactCreateNew) {
				console.log('66');
				if (this.refs.contactNameRef.checkValidity() == false) {
						console.log('77');
						this.refs.contactNameRef.setCustomValidity('Complete this field.');
						this.refs.contactNameRef.reportValidity();
						isError = true;
				}
		} else if (this.ContactExisting) {
				if (this.selectedContactId == null || this.selectedContactId == undefined || this.selectedContactId == '') {
						this.ContactExistingShowError = true;
						isError = true;
				}
		}

		if (this.OpportunityCreateNew) {
				console.log('88');
				if (this.refs.opportunityNameRef.checkValidity() == false) {
						console.log('99');
						this.refs.opportunityNameRef.setCustomValidity('Complete this field.');
						this.refs.opportunityNameRef.reportValidity();
						isError = true;
				}
		} else if (this.OpportunityExisting) {
				if (this.selectedOpportunityId == null || this.selectedOpportunityId == undefined) {
						this.OpportunityExistingShowError = true;
						isError = true;
				}
		}

		if (isError) {
				const col1 = this.template.querySelector('.col1');
				if (col1) {
						col1.scrollIntoView({
								behavior: 'smooth',
								block: 'center',
								inline: 'nearest'
						});
				}

				if (this.showSpinner)
						this.showSpinner = false;
		}*/

		return !isError;
	}
	handleRecordTypeChange(event) {
		this.selectedRecordTypeId = event.detail.value;
		console.log('Selected Record Type ID: ', this.selectedRecordTypeId);
	}

	handleisCreateEnquiryCheck(event) {
		this.isCreateEnquiryChecked = event.target.checked;
	}

	async handleConfirmClick() {
		this.showSpinner = true;
		console.log('1');
		if (this.AccountCreateNew) {
			console.log('2');
			if (this.validateOnSubmit()) {
				console.log('3333');
				//const result = await LightningConfirm.open({ message: 'Kindly confirm the lead is not present in the below listed accounts.', variant: 'headerless', label: '' });
				//console.log('Result: ' + result);
				//if (result) {
				this.handleSubmit();
				//} else {
				//if (this.showSpinner)
				// this.showSpinner = false;
				//}
			} else {

				this.showSpinner = false;
			}
		}
		else {
			console.log('31');
			/*
			if (this.selectedAccountId == null || this.selectedAccountId == undefined || this.selectedAccountId == '') {
					this.AccountExistingShowError = true;
					const col1 = this.template.querySelector('.col1');
					if (col1)
							col1.scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'nearest' });
					this.showSpinner = false;
					return;
			}
			*/

			// this.handleSubmit();
		}
	}

	handleCancel(event) {
		if (event.target.name == 'Cancel') {
			this.closeComponent();
		}
	}

	handleSubmit() {
		if (this.validateOnSubmit()) {
			if (!this.showSpinner) this.showSpinner = true;
			new Promise((resolve, reject) => {
				setTimeout(() => {
					convertLead({
						leadRecord: this.leadRecord,
						accName: this.accountName,
						isDC: this.isDirectCustomerChecked,
						dealerName: this.dealerValue,
						accRT: this.accountRecordType,
						existingAccId: this.selectedAccountId,
						contactName: {
							Salutation: this.contactSalutation,
							FirstName: this.contactFirstName,
							MiddleName: this.contactMiddleName,
							LastName: this.contactLastName
						},
						existingContId: this.selectedContactId,
						enqName: this.opportunityName,
						enqRT: this.selectedRecordTypeId,
						enqChk: this.isCreateEnquiryChecked,
						isAccountNew: this.AccountCreateNew,
						isContactNew: this.ContactCreateNew
					}).then((data) => {
						this.showSpinner = false;
						this[NavigationMixin.Navigate]({
							type: 'standard__recordPage',
							attributes: {
								recordId: data.accountId,
								objectApiName: 'Account',
								actionName: 'view'
							}
						});
					})
						.catch((error) => {
							this.showSpinner = false;
							this.showToastOnError(error);
						});
				}, 0);
			});
		}
	}


	// closeComponent(event) {
	//     this.dispatchEvent(new CloseActionScreenEvent());
	// }

	closeComponent(event) {
		console.log('closeComponent method triggered');
		// setTimeout(() => {
		//     window.location.reload();
		// }, 100);


		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.recordId,
				objectApiName: 'Lead__c',
				actionName: 'view',

			}
		});
	}


	showToastOnSuccess(title, msg) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: msg,
				variant: 'success'
			})
		);
	}

	showToastOnWarning(title, msg) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: msg,
				variant: 'warn'
			})
		);
	}

	showToastOnError(error) {
		console.warn(error);

		let msg;
		if (error.message) msg = error.message;
		else if (error.body.message) msg = error.body.message;

		this.dispatchEvent(
			new ShowToastEvent({
				// title: 'Error',
				message: msg,
				variant: 'error'
			})
		);

		this.showSpinner = false;
	}
}