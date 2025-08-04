import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSalesRegisterReportData from "@salesforce/apex/TSD_ReportsController.getSalesRegisterReportData";

export default class SalesRegisterReportLWC extends LightningElement {

    @track showSpinner = false;
    @track customerNo = '';
    @track startDate = '';
    @track endDate = '';

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
                getSalesRegisterReportData({
                    customerNo: this.customerNo,
                    startDate: this.startDate,
                    endDate: this.endDate
                }).then((data) => {
                    console.log('getSalesRegisterReportData:>> ', data);
                    if (data != 'No data found') {
                        // this.tableData = JSON.parse(data);
                        window.open(data, '_blank');
                        // this.downloadExcel(data);
                        this.showTableData = true;
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

    downloadExcel(para) {
        let tempdata = JSON.parse(para);
        try {
            // Convert Base64 to binary
            const byteCharacters = atob(tempdata.data);
            const byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }
            const byteArray = new Uint8Array(byteNumbers);

            // Correct MIME type for Excel
            const blob = new Blob([byteArray], {
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            });

            // Debugging: Check Blob Size
            console.log('Blob Size:', blob.size);

            // Create a download link
            const link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'downloaded_file.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } catch (error) {
            console.error('Error downloading Excel:', error);
        }
    }

}