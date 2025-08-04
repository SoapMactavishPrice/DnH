import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCustomerLedgerReportData from "@salesforce/apex/TSD_ReportsController.getCustomerLedgerReportData";

const columns = [
    { label: 'Customer No', fieldName: 'CustomerNo', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } },
    { label: 'Customer Name', fieldName: 'CustomerName', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } },
    { label: 'Posting Date', fieldName: 'PostingDate', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } },
    { label: 'Type', fieldName: 'Type', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } },
    { label: 'Document No', fieldName: 'DocumentNo', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } },
    { label: 'Narration', fieldName: 'Narration', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } },
    { label: 'Debit Amount', fieldName: 'DebitAmount', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } },
    { label: 'Credit Amount', fieldName: 'CreditAmount', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } },
    // { label: 'Opening Balance', fieldName: 'OpeningBalance', type: 'text', initialWidth: 170 },
    { label: 'Balance', fieldName: 'Balance', type: 'text', initialWidth: 170, cellAttributes: { style: { fieldName: 'rowClass' } } }
];

export default class CustomerLedgerReportLWC extends LightningElement {

    @track showSpinner = false;
    @track customerNo = '';
    @track startDate = '';
    @track endDate = '';
    @track tableData = [];
    @track showTableData = false;

    @track customerName = '';
    @track openingBalance = '';
    @track totalDebit = 0;
    @track totalCredit = 0;
    @track finalBalance = 0;
    @track totalRow = false;

    page = 1;
    items = [];
    data = [];
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 10;
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
        this.paginationDataList = [];
        this.tableData = [];
        this.showTableData = false;
        if (this.handleInputValidation()) {
            console.log('GOOD');
            new Promise((resolve, reject) => {
                getCustomerLedgerReportData({
                    customerNo: this.customerNo,
                    startDate: this.startDate,
                    endDate: this.endDate
                }).then((data) => {
                    console.log(data);
                    if (data != '') {
                        // this.tableData = JSON.parse(data);
                        this.showTableData = true;
                        this.handlerOtherData(data);
                        // this.paginiateData(data)
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
        // this.handlerOtherData();
    }

    recordPerPage(page, data) {
        let tempdata = data;
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;
        this.tableData = tempdata.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        // this.handlerOtherData();
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

    handlerOtherData(para) {
        let rawData = JSON.parse(para);
        let actualData;
        if (rawData.length > 0) {
            this.openingBalance = rawData[0].OpeningBalance;
            this.customerName = rawData[0].CustomerName;
        }

        let totalDr = 0;
        let totalCr = 0;
        let balance = parseFloat(this.openingBalance.replace(',', ''));

        actualData = rawData.map((record, index) => {
            let debit = record.DebitAmount ? parseFloat(record.DebitAmount.replace(',', '')) : 0;
            let credit = record.CreditAmount ? parseFloat(record.CreditAmount.replace(',', '')) : 0;

            totalDr += debit;
            totalCr += credit;

            balance += debit;
            balance -= credit;

            return {
                ...record,
                DebitAmount: debit,
                CreditAmount: credit,
                Balance: balance,
                rowClass: ''
            };
        });

        // Set total values
        // console.log();
        this.totalDebit = parseFloat(this.openingBalance.replace(',', '')) + totalDr;
        this.totalDebit = this.totalDebit.toLocaleString();
        this.totalCredit = totalCr.toLocaleString();
        this.finalBalance = balance.toLocaleString();
        // this.totalRow = true;

        let tadd = { "CustomerNo": "", "CustomerName": "", "PostingDate": "", "Type": "", "DocumentNo": "", "Narration": "Total", "DebitAmount": this.totalDebit, "CreditAmount": this.totalCredit, "Balance": this.finalBalance, rowClass: 'background: #c9c9c9; font-weight: 700; color: black;' };
        let fadd = { "CustomerNo": "", "CustomerName": "", "PostingDate": "", "Type": "", "DocumentNo": "", "Narration": "Opening Balance", "DebitAmount": this.openingBalance, "CreditAmount": '', "Balance": '', rowClass: 'font-weight: 700; color: blue;' };
        actualData.push(tadd);
        actualData.unshift(fadd);
        console.log('After Calc:>>> ', actualData);
        this.paginiateData(JSON.stringify(actualData));
    }

    @api reset() {
        console.log('IN reset 1');
        this.customerNo = '';
        this.startDate = '';
        this.endDate = '';
        this.tableData = [];
        this.showTableData = false;
    }

    // ------- Download ----------
    downloadExcel() {
        if (this.paginationDataList.length > 0) {
            let csv = this.convertToCSV(this.paginationDataList);
            let hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
            hiddenElement.target = '_blank';
            hiddenElement.download = this.paginationDataList[1].CustomerNo + '_' + this.startDate + '_' + this.endDate + '.csv';
            document.body.appendChild(hiddenElement);
            hiddenElement.click();
            document.body.removeChild(hiddenElement);
        }
    }

    convertToCSV(data) {
        if (!data || !data.length) return '';

        const headers = Object.keys(data[0]).filter(key => key !== 'rowClass');
        const rows = data.map(row => headers.map(field => `"${row[field] ?? ''}"`).join(','));
        return [headers.join(','), ...rows].join('\n');
    }

}