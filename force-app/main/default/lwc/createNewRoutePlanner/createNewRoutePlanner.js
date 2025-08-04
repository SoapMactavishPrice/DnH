import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import modal from '@salesforce/resourceUrl/modalcss';
import { loadStyle } from 'lightning/platformResourceLoader';

import getLeadRecord from '@salesforce/apex/AddAccountContactToCampController.getLeadRecord';
import saveCampMembers from '@salesforce/apex/AddAccountContactToCampController.saveCampMembers';

const COLS = [
    { label: 'Name', fieldName: 'purl', type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Industry', fieldName: 'Industry', type: 'text' },
    { label: 'BillingCity', fieldName: 'BillingCity', type: 'text' },
    { label: 'BillingState', fieldName: 'BillingState', type: 'text' },
    // { label: 'Mobile', fieldName: 'Mobile', type: 'text' },
    // { label: 'Email', fieldName: 'Email', type: 'text' },
    // { label: 'Lead Status', fieldName: 'LeadStatus', type: 'text' },
];

export default class AddCampaignLeads extends NavigationMixin(LightningElement) {

    cols = COLS;

    @track recId;
    @track showSpinner = false;
    @track mainBodyFlag = false;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        // console.log('currentPageReference', currentPageReference);
        // console.log('state', currentPageReference.state.recordId);
        this.currentPageReference = currentPageReference.state.recordId;
        if (this.currentPageReference) {
            this.recId = this.currentPageReference;
            console.log('Opp Id', this.recId);
        }
    }

    @track SelectedRecordCount = 0;
    @track ShowSelected = true;
    @track ShowTableData = [];
    @track selectedProductCode = [];
    @track AllProductData = [];
    @track tempForFilter = [];
    @track SelectedProductData = [];
    @track hasRecords = true;
    @track searchKey = '';
    @track selectedRows = [];
    @track isProductSelect = true;

    page = 1;
    items = [];
    data = [];

    startingRecord = 1;
    endingRecord = 0;
    pageSize = 9;
    totalRecountCount = 0;
    totalPage = 0;

    get bDisableFirst() {
        return this.page == 1;
    }
    get bDisableLast() {
        return this.page == this.totalPage;
    }

    @track paginationDataList;
    @track tempEvent;
    @track DisableNext = true;

    @track industryGroupValue = '';
    @track leadSourceValue = '';

    connectedCallback() {
        loadStyle(this, modal);
        // console.log('CONNECTED CALL BACK :>> ', this.recordId);
        this.handleGetLeads();
    }

    // -------------- Get Data ----------------

    handleGetLeads() {
        this.showSpinner = true;
        new Promise((resolve, reject) => {

            getLeadRecord({
                campId: this.recId
            }).then((data) => {
                console.log('DATAAA:>> ', data);
                let dataObj = JSON.parse(data);
                console.log(dataObj);
                this.AllProductData = dataObj.leadList;
                this.ShowTableData = dataObj.leadList;
                this.tempForFilter = dataObj.leadList;
                this.paginiateData(JSON.stringify(this.AllProductData));
                resolve();
            })

        }).then(() => {
            this.showSpinner = false;
            this.mainBodyFlag = true;
        })
    }

    // -------------- Get Data End ----------------


    // -------------- Search/Filter Data ----------------

    handlePicklistChangeChange(event) {
        this.showSpinner = true;

        // this.industryGroupValue = '';
        // this.leadSourceValue = '';
        let tempData = this.tempForFilter;
        let tempNewData = [];
        if (event.currentTarget.dataset.name == 'industry') {
            this.industryGroupValue = event.detail.value;
        } else if (event.currentTarget.dataset.name == 'BillingCity') {
            this.leadSourceValue = event.detail.value;
        }

        this.AllProductData = [];
        this.ShowTableData = [];

        tempData.forEach(ele => {
            if (this.industryGroupValue != '' && this.leadSourceValue == '') {
                if (ele.IndustryGroup == this.industryGroupValue) {
                    tempNewData.push(ele);
                }
            } else if (this.industryGroupValue == '' && this.leadSourceValue != '') {
                if (ele.LeadSource == this.leadSourceValue) {
                    tempNewData.push(ele);
                }
            } else if (this.industryGroupValue != '' && this.leadSourceValue != '') {
                if (ele.IndustryGroup == this.industryGroupValue && ele.LeadSource == this.leadSourceValue) {
                    tempNewData.push(ele);
                }
            } else if (this.industryGroupValue == '' && this.leadSourceValue == '') {
                tempNewData.push(ele);
            }
        });
        this.AllProductData = tempNewData;
        this.ShowTableData = tempNewData;
        this.paginiateData(JSON.stringify(this.AllProductData));
    }

    showFilteredProducts(event) {
        // console.log('event.keyCode = ', event.keyCode);
        if (event.keyCode == 13) {
            this.isFirstPage = false;
            this.showErrorMsg = false;
            // findProducts({ recordId: this.recId, productFamily: [] }).then(result => {
            //     let dataObj = JSON.parse(result);
            //     //console.log(dataObj);
            //     this.ShowTableData = dataObj.productList;
            //     this.filteredData = dataObj.productList;
            //     this.fillselectedRows();
            //     this.isFirstPage = true;
            //     this.ShowViewAll = true;
            //     this.ShowSelected = true;
            //     /*const searchBoxWrapper = this.template.querySelector('.lookupContainer');
            //     searchBoxWrapper.classList.remove('slds-show');
            //     searchBoxWrapper.classList.add('slds-hide');*/
            // });
        } else {
            this.handleKeyChange(event);
            const searchBoxWrapper = this.template.querySelector('.lookupContainer');
            searchBoxWrapper.classList.add('slds-show');
            searchBoxWrapper.classList.remove('slds-hide');
        }
    }

    handleKeyChange(event) {
        this.isSearchLoading = true;
        this.searchKey = event.target.value;
        var data = [];
        for (var i = 0; i < this.AllProductData.length; i++) {
            if (this.AllProductData[i] != undefined && this.AllProductData[i].Name.toLowerCase().includes(this.searchKey.toLowerCase())) {
                data.push(this.AllProductData[i]);
            }
        }
        this.paginiateData(JSON.stringify(data));
        this.page = 1;
        this.recordPerPage(1, this.SelectedProductData, data);
    }

    toggleResult(event) {
        console.log('toggleResult called...');
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            // case 'lookupContainer':
            // 	clsList.remove('slds-is-open');
            // 	break;
        }
    }
    // -------------- Search Data End----------------

    // -------------- Pagination ----------------

    paginiateData(results) {
        let data = JSON.parse(results);
        this.paginationDataList = data;
        this.totalRecountCount = data.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.ShowTableData = this.paginationDataList.slice(0, this.pageSize);
        ////console.log('totalRecountCount ', this.totalRecountCount);
        this.endingRecord = this.pageSize;
        this.error = undefined;
        this.showSpinner = false;
    }


    firstPage() {
        this.page = 1;
        this.recordPerPage(this.page, this.SelectedProductData, this.paginationDataList);
        //console.log('this.SelectedProductData 604', this.SelectedProductData.length);
        //this.template.querySelector('[data-id="datatable"]').selectedRows = this.SelectedProductData;
    }

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            //console.log('this.SelectedProductData 611', this.SelectedProductData.length);
            this.recordPerPage(this.page, this.SelectedProductData, this.paginationDataList);
        }
        // this.template.querySelector('[data-id="datatable"]').selectedRows = this.SelectedProductData;
    }

    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            //console.log('this.SelectedProductData 619', this.SelectedProductData.length);
            this.recordPerPage(this.page, this.SelectedProductData, this.paginationDataList);
        }
        //console.log('json -->', JSON.parse(this.template.querySelector('[data-id="datatable"]').selectedRows));
    }

    lastPage() {
        this.page = this.totalPage;
        if (this.page > 1) {
            console.log('this.SelectedProductData 633', this.SelectedProductData.length);
            this.recordPerPage(this.page, this.SelectedProductData, this.paginationDataList);
        }
        //this.template.querySelector('[data-id="datatable"]').selectedRows = this.SelectedProductData;
    }

    recordPerPage(page, selectedRecords, data) {
        let tempdata = data;
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;
        //this.fillselectedRows();
        this.ShowTableData = tempdata.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        console.log('this.selectedProductCode 664', this.selectedProductCode.length);
        this.fillselectedRows();
        this.RecalculateselectedProductCode();
        console.log('this.selectedProductCode 666', this.selectedProductCode.length);
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedProductCode;
    }

    handleviewAll(event) {
        this.ShowSelected = true;
        this.ShowViewAll = false;
        this.SelectedProduct(this.tempEvent);
        this.fillselectedRows();
        this.RecalculateselectedProductCode();
        console.log('method view all');
        this.paginiateData(JSON.stringify(this.AllProductData));
        this.page = 1;
    }

    fillselectedRows() {
        this.selectedRows = []
        for (let i = 0; i < this.ShowTableData.length; i++) {
            if (this.selectedProductCode.includes(this.ShowTableData[i].Id)) {
                this.selectedRows.push(this.ShowTableData[i]);
            }
        }
    }

    RecalculateselectedProductCode() {
        this.selectedProductCode = [];
        for (let i = 0; i < this.SelectedProductData.length; i++) {
            this.selectedProductCode.push(this.SelectedProductData[i].Id);
        }
    }

    // -------------- Pagination End ----------------

    SelectedProduct(event) {
        this.tempEvent = event;
        //console.log('SelectedProduct called..');
        if (true) {
            const selRows = event.detail.selectedRows;

            // console.log('selRows..', selRows.length);
            // console.log('All..', this.selectedRows.length);
            if (this.selectedRows.length < selRows.length) {
                //console.log('Selected');
                for (let i = 0; i < selRows.length; i++) {

                    this.selectedProductCode.push(selRows[i].Id);
                    //this.SelectedProductData.push(selRows[i]);
                }
            } else {

                var selectedRowsProductCode = [];
                var selProductCode = [];
                for (let i = 0; i < this.selectedRows.length; i++) {
                    selectedRowsProductCode.push(this.selectedRows[i].Id);
                }
                // console.log('selectedRowsProductCode..159', selectedRowsProductCode.length);
                for (let i = 0; i < selRows.length; i++) {
                    selProductCode.push(selRows[i].Id);
                }
                //console.log('selProductCode..162', selProductCode.length);
                //console.log('length', selectedRowsProductCode.filter(x => selProductCode.indexOf(x) === -1));
                var deselectedRecProductCode = selectedRowsProductCode.filter(x => selProductCode.indexOf(x) === -1);
                for (let i = 0; i < deselectedRecProductCode.length; i++) {
                    this.selectedProductCode = this.selectedProductCode.filter(function (e) { return e !== deselectedRecProductCode[i] })
                }
            }
            this.selectedRows = selRows;
            this.selectedProductCode = [...new Set(this.selectedProductCode)];
            this.SelectedRecordCount = this.selectedProductCode.length;

            this.SelectedProductData = [];
            for (let i = 0; i < this.selectedProductCode.length; i++) {
                for (let j = 0; j < this.AllProductData.length; j++) {
                    if (this.selectedProductCode.includes(this.AllProductData[j].Id)) {
                        this.SelectedProductData.push(this.AllProductData[j]);
                    }
                }
            }
            this.SelectedProductData = [...new Set(this.SelectedProductData)];
            if (this.selectedProductCode.length > 0) {
                this.DisableNext = false;
            } else {
                this.DisableNext = true;
            }
        }
        //this.paginiateData(JSON.stringify(this.SelectedProductData));
        this.isProductSelect = true;
        // console.log(this.selectedProductCode);
        // console.log(this.SelectedProductData);

    }

    closeComponent() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSaveData() {
        console.log('this.recId:>> ', this.recId);

        this.showSpinner = true;
        if (this.SelectedProductData.length > 0) {

            new Promise((resolve, reject) => {
                saveCampMembers({
                    campId: this.recId,
                    campMemberData: JSON.stringify(this.SelectedProductData),
                    type: 'Lead'
                }).then((data) => {

                    if (data == 'Success') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Accounts Added Successfully',
                                variant: 'success',
                            })
                        );
                        resolve('ok');
                    }

                }).catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Something went wrong!',
                            message: error,
                            variant: 'error',
                        })
                    )
                })
            }).then(() => {
                this.dispatchEvent(new CloseActionScreenEvent());
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            })

        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'Please select atleast one Account',
                    variant: 'error',
                })
            );
            this.showSpinner = false;
        }
    }

}