import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSalesOrderReportData from "@salesforce/apex/TSD_ReportsController.getSalesOrderReportData";

const columns = [
    { label: 'Statistics Zone', fieldName: 'StatisticsZone', type: 'text', initialWidth: 150 },
    { label: 'State', fieldName: 'StatiState', type: 'text', initialWidth: 150 },
    { label: 'Document No', fieldName: 'DocumentNo', type: 'text', initialWidth: 150 },
    { label: 'Booking Date', fieldName: 'BookingDate', type: 'text', initialWidth: 150 },
    { label: 'Line No', fieldName: 'LineNo', type: 'text', initialWidth: 150 },
    { label: 'Customer Name', fieldName: 'CustomerName', type: 'text', initialWidth: 150 },
    { label: 'City', fieldName: 'City', type: 'text', initialWidth: 150 },
    { label: 'Description', fieldName: 'Description', type: 'text', initialWidth: 150 },
    { label: 'Variant Code', fieldName: 'VariantCode', type: 'text', initialWidth: 150 },
    { label: 'Item No', fieldName: 'ItemNo', type: 'text', initialWidth: 150 },
    { label: 'Quantity', fieldName: 'Quantity', type: 'text', initialWidth: 150 },
    { label: 'Quantity (KGS)', fieldName: 'Quantity(KGS)', type: 'text', initialWidth: 150 },
    { label: 'Line Amount', fieldName: 'LineAmt', type: 'text', initialWidth: 150 },
    { label: 'Wh Shipment No', fieldName: 'WhShipmentNo', type: 'text', initialWidth: 150 },
    { label: 'Wh Shipment Date', fieldName: 'WhShipmentDate', type: 'text', initialWidth: 150 },
    { label: 'Allocated Qty', fieldName: 'AllocatedQty', type: 'text', initialWidth: 150 },
    { label: 'Allocation Amt GST', fieldName: 'AllocationAmtGST', type: 'text', initialWidth: 150 },
    { label: 'Outstanding Qty (BOX)', fieldName: 'OutstandingQtyinBOX', type: 'text', initialWidth: 150 },
    { label: 'Outstanding Amt', fieldName: 'OutstandingAmt', type: 'text', initialWidth: 150 },
    { label: 'Customer Balance', fieldName: 'CustomerBal', type: 'text', initialWidth: 150 },
    { label: 'Outstanding Qty (KGS)', fieldName: 'OutstandingQtyinKGS', type: 'text', initialWidth: 150 },
    { label: 'External Document No', fieldName: 'ExternalDocumentNo', type: 'text', initialWidth: 150 },
    { label: 'Order Date', fieldName: 'OrderDate', type: 'text', initialWidth: 150 },
    { label: 'Location Code', fieldName: 'LocationCode', type: 'text', initialWidth: 150 },
    { label: 'Order Type', fieldName: 'OrderType', type: 'text', initialWidth: 150 },
    { label: 'SOR No', fieldName: 'SORNo', type: 'text', initialWidth: 150 },
    { label: 'Special Category', fieldName: 'SpecialCategoty', type: 'text', initialWidth: 150 },
    { label: 'Shipment Date', fieldName: 'ShipmentDate', type: 'text', initialWidth: 150 },
    { label: 'Qty Shipped Not Invoiced', fieldName: 'QtyShippedNotInvoiced', type: 'text', initialWidth: 150 },
    { label: 'Shipped Not Invoiced', fieldName: 'ShippedNotInvoiced', type: 'text', initialWidth: 150 },
    { label: 'Sales UOM Qty', fieldName: 'SalesUOMQty.', type: 'text', initialWidth: 150 },
    { label: 'Sales UOM', fieldName: 'SalesUOM', type: 'text', initialWidth: 150 },
    { label: 'Ship to Name', fieldName: 'ShiptoName', type: 'text', initialWidth: 150 },
    { label: 'End Customer Name', fieldName: 'EndCustomerName', type: 'text', initialWidth: 150 },
    { label: 'Quantity Invoiced (KGS)', fieldName: 'QuantityInvoiced(KGS)', type: 'text', initialWidth: 150 },
    { label: 'Quantity Invoiced', fieldName: 'QuantityInvoiced', type: 'text', initialWidth: 150 },
    { label: 'Qty Invoiced Amount', fieldName: 'QtyInvoicedAmount', type: 'text', initialWidth: 150 },
    { label: 'Sales Price', fieldName: 'SalesPrice', type: 'text', initialWidth: 150 },
    { label: 'Special Discount', fieldName: 'SpecialDiscount', type: 'text', initialWidth: 150 },
    { label: 'Cash Discount', fieldName: 'CashDiscount', type: 'text', initialWidth: 150 },
    { label: 'Net Pending Qty', fieldName: 'NetPendingQty', type: 'text', initialWidth: 150 },
    { label: 'Pending Days', fieldName: 'PendingDays', type: 'text', initialWidth: 150 },
    { label: 'Customer No', fieldName: 'CustomerNo', type: 'text', initialWidth: 150 },
    { label: 'Engineer ID', fieldName: 'EngineerID', type: 'text', initialWidth: 150 },
    { label: 'Area Manager', fieldName: 'AreaManager', type: 'text', initialWidth: 150 },
    { label: 'Last Ship No', fieldName: 'LastShipNo', type: 'text', initialWidth: 150 },
    { label: 'Last Ship Date', fieldName: 'LastShipDate', type: 'text', initialWidth: 150 },
    { label: 'Dealer Price', fieldName: 'DealerPrice', type: 'text', initialWidth: 150 },
    { label: 'Private Price', fieldName: 'PrivatePrice', type: 'text', initialWidth: 150 }
];

export default class SalesOrderReportLWC extends LightningElement {

    @track showSpinner = false;
    @track customerNo = '';
    @track startDate = '';
    @track endDate = '';
    @track osDtl = false;
    @track tableData = [];
    @track showTableData = false;

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

    handleCheckboxChange(event) {
        this.osDtl = event.target.checked;
    }

    handleSearch() {
        this.paginationDataList= [];
        this.tableData = [];
        this.showTableData = false;
        if (this.handleInputValidation()) {
            console.log('GOOD');
            new Promise((resolve, reject) => {
                getSalesOrderReportData({
                    customerNo: this.customerNo,
                    startDate: this.startDate,
                    endDate: this.endDate,
                    osDtl: this.osDtl
                }).then((data) => {
                    console.log(data);
                    if (data != '') {
                        // this.tableData = JSON.parse(data);
                        this.showTableData = true;
                        this.paginiateData(data)
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

    @api reset() {
        console.log('IN reset 1');
        this.customerNo = '';
        this.startDate = '';
        this.endDate = '';
        this.tableData = [];
        this.showTableData = false;
    }

}