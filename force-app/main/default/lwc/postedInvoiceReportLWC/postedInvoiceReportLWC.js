import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPostedInvoiceReportData from "@salesforce/apex/TSD_ReportsController.getPostedInvoiceReportData";
import getDownloadInvoiceDOC from "@salesforce/apex/TSD_ReportsController.getDownloadInvoiceDOC";
import getDownloadInvoiceNonSORTCDOC from "@salesforce/apex/TSD_ReportsController.getDownloadInvoiceNonSORTCDOC";
import getDownloadInvoiceLRDOC from "@salesforce/apex/TSD_ReportsController.getDownloadInvoiceLRDOC";

const columns = [
    {
        label: 'Download Invoice',
        fieldName: 'No', // This can be any field, not used for display
        type: 'button-icon',
        initialWidth: 150,
        typeAttributes: {
            iconName: { fieldName: 'downloadInvoiceIcon' }, // Conditional icon
            name: 'download_invoice',
            title: 'Download Invoice',
            variant: 'bare',
            alternativeText: 'Download Invoice'
        }
    },
    {
        label: 'Download Non SOR(TC)',
        fieldName: 'No', // This can be any field, not used for display
        type: 'button-icon',
        initialWidth: 150,
        typeAttributes: {
            iconName: { fieldName: 'downloadNonSORTCIcon' }, // Conditional icon
            name: 'download_invoice_sor_tc',
            title: 'Download Non SOR(TC)',
            variant: 'bare',
            alternativeText: 'Download Non SOR(TC)'
        }
    },
    {
        label: 'Download LR',
        fieldName: 'No', // This can be any field, not used for display
        type: 'button-icon',
        initialWidth: 150,
        typeAttributes: {
            iconName: { fieldName: 'downloadLRIcon' }, // Conditional icon
            name: 'download_invoice_lr',
            title: 'Download LR',
            variant: 'bare',
            alternativeText: 'Download LR'
        }
    },
    { label: 'No', fieldName: 'No', type: 'text', initialWidth: 150 },
    { label: 'Posting Date', fieldName: 'PostingDate', type: 'text', initialWidth: 150 },
    { label: 'Customer No', fieldName: 'CustomerNo', type: 'text', initialWidth: 150 },
    { label: 'Customer Name', fieldName: 'CustomerName', type: 'text', initialWidth: 150 },
    { label: 'Amount to Customer', fieldName: 'AmounttoCustomer', type: 'text', initialWidth: 150 },
    { label: 'Location Code', fieldName: 'LocationCode', type: 'text', initialWidth: 150 },
    { label: 'Consignee Name', fieldName: 'ConsigneeName', type: 'text', initialWidth: 150 },
    { label: 'Transporter Name', fieldName: 'TransporterName', type: 'text', initialWidth: 150 },
    { label: 'LR No', fieldName: 'LRNo', type: 'text', initialWidth: 150 },
    { label: 'LR Date', fieldName: 'LRDate', type: 'text', initialWidth: 150 },
    { label: 'LR Destination', fieldName: 'LRDestination', type: 'text', initialWidth: 150 },
    { label: 'LR Favour', fieldName: 'LRFavour', type: 'text', initialWidth: 150 },
    { label: 'Freight Terms', fieldName: 'FreightTerms', type: 'text', initialWidth: 150 },
    { label: 'Delivery Type', fieldName: 'DeliveryType', type: 'text', initialWidth: 150 },
    // { label: 'Is TC', fieldName: 'IsTC', type: 'text', initialWidth: 150 },
    // { label: 'Is LR', fieldName: 'IsLR', type: 'text', initialWidth: 150 },
    { label: 'Field Engineer', fieldName: 'FieldEngineer', type: 'text', initialWidth: 150 },
    { label: 'Area Manager', fieldName: 'AreaManager', type: 'text', initialWidth: 150 },
    { label: 'Zonal Manager', fieldName: 'ZonalManager', type: 'text', initialWidth: 150 }
];

export default class PostedInvoiceReportLWC extends LightningElement {


    @track showSpinner = false;
    @track customerNo = '';
    @track startDate = '';
    @track endDate = '';
    @track tableData = [];
    @track showTableData = false;

    page = 1;
    items = [];
    data = [];
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 20;
    totalRecountCount = 0;
    totalPage = 0;
    @track paginationDataList;
    @track searchKey = '';
    @track COLS = columns;

    showToast(toastTitle, toastMsg, toastType) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMsg,
            variant: toastType,
            mode: "dismissable"
        });
        this.dispatchEvent(event);
    }

    connectedCallback() {

    }

    handleDateChange(event) {
        if (event.target.name == 'startdate') {
            this.startDate = event.target.value;
        }
        if (event.target.name == 'enddate') {
            this.endDate = event.target.value;
        }
    }

    handleSearch() {
        this.paginationDataList= [];
        this.tableData = [];
        this.showTableData = false;
        if (this.handleInputValidation()) {
            console.log('GOOD');
            new Promise((resolve, reject) => {
                getPostedInvoiceReportData({
                    customerNo: this.customerNo,
                    startDate: this.startDate,
                    endDate: this.endDate
                }).then((data) => {
                    console.log(data);
                    if (data != '') {
                        let tempdata = JSON.parse(data);
                        // this.tableData = JSON.parse(data);
                        tempdata.forEach(ele => {
                            ele.downloadInvoiceIcon = 'utility:download';
                            ele.downloadNonSORTCIcon = ele.IsTC == '1' ? 'utility:download' : null;
                            ele.downloadLRIcon = ele.IsLR == '1' ? 'utility:download' : null;
                        });
                        this.showTableData = true;
                        this.paginiateData(JSON.stringify(tempdata))
                    } else {
                        this.showToast('No data found', '', 'info');
                    }
                    this.showSpinner = false;
                }).catch((error) => {
                    console.log(error);
                    this.showSpinner = false;
                    this.showToast(error, '', 'error');
                })
            }).then(() => {

            })
        } else {
            this.showSpinner = false;
            this.showToast('Please fill all the fields', '', 'error');
        }
    }

    handleInputValidation() {
        this.showSpinner = true;
        const fieldInput = this.template.querySelector('.customerno');
        this.customerNo = fieldInput.value;
        if (!this.customerNo) {
            return false;
        } else if (this.startDate == '' || this.endDate == '') {
            return false;
        } else {
            return true;
        }
    }

    paginiateData(results) {
        let data = JSON.parse(results);
        this.paginationDataList = data;
        this.totalRecountCount = data.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.tableData = this.paginationDataList.slice(0, this.pageSize);
        ////console.log('totalRecountCount ', this.totalRecountCount);
        this.endingRecord = this.pageSize;
        this.error = undefined;
    }

    recordPerPage(page, data) {
        let tempdata = data;
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;
        this.tableData = tempdata.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
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

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'download_invoice') {
            this.showSpinner = true;
            console.log('Downloading file for:', row.No);
            // Your download logic here (e.g., call Apex to get file)
            new Promise((resolve, reject) => {
                getDownloadInvoiceDOC({
                    docNo: row.No,
                    customerNo: this.customerNo
                }).then((data) => {
                    console.log(data);
                    this.downloadPdf(data);
                    this.showSpinner = false;
                }).catch((error) => {
                    console.log(error);
                    this.showSpinner = false;
                    this.showToast(error, '', 'error');
                })
            }).then(() => {

            })
        } else if (actionName === 'download_invoice_sor_tc') {
            this.showSpinner = true;
            console.log('Downloading Non SOR TC file for:', row.No);
            // Your download logic here (e.g., call Apex to get file)
            new Promise((resolve, reject) => {
                getDownloadInvoiceNonSORTCDOC({
                    docNo: row.No,
                    customerNo: this.customerNo
                }).then((data) => {
                    // console.log(data);
                    this.downloadZip(data);
                    this.showSpinner = false;
                }).catch((error) => {
                    console.log(error);
                    this.showSpinner = false;
                    this.showToast(error, '', 'error');
                })
            }).then(() => {

            })
        } else if (actionName === 'download_invoice_lr') {
            this.showSpinner = true;
            console.log('Downloading LR file for:', row.No);
            // Your download logic here (e.g., call Apex to get file)
            new Promise((resolve, reject) => {
                getDownloadInvoiceLRDOC({
                    docNo: row.No,
                    customerNo: this.customerNo
                }).then((data) => {
                    // console.log(data);
                    this.downloadPdf(data);
                    this.showSpinner = false;
                }).catch((error) => {
                    console.log(error);
                    this.showSpinner = false;
                    this.showToast(error, '', 'error');
                })
            }).then(() => {

            })
        }
    }

    downloadPdf(para) {
        let tempdata = JSON.parse(para);
        // Convert Base64 to a binary Blob
        const byteCharacters = atob(tempdata.data);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        const blob = new Blob([byteArray], { type: 'application/pdf' });

        // Create a download link and trigger the download
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = tempdata.name;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    downloadZip(para) {
        let tempdata = JSON.parse(para);
        // Convert Base64 to a binary Blob
        const byteCharacters = atob(tempdata.data);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        const blob = new Blob([byteArray], { type: 'application/zip' });

        // Create a download link and trigger the download
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = tempdata.name;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    @api reset() {
        console.log('IN reset 1');
        this.customerNo = '';
        this.startDate = '';
        this.endDate = '';
        this.tableData = [];
        this.showTableData = false;
    }

}