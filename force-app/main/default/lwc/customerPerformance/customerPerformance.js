import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getCustomerDetails from "@salesforce/apex/CustomerPerformanceController.getCustomerDetails";
import savePerformanceReport from "@salesforce/apex/CustomerPerformanceController.savePerformanceReport";
import getFiscalYearName from "@salesforce/apex/CustomerPerformanceController.getFiscalYearName";
import getUserName from "@salesforce/apex/CustomerPerformanceController.getUserName";

export default class CustomerPerformance extends LightningElement {

    @track showSpinner = true;

    @track months = [
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
        "January",
        "February",
        "March"
    ];

    @track performanceReportNotNull = false;

    @track fiscalYearName = '';

    @track performanceMasters = null;

    @track fiscalYearId = null;

    @track userName = null;

    connectedCallback() {
        getFiscalYearName()
            .then((data) => {
                this.fiscalYearName = data.split('|||')[0];
                this.fiscalYearId = data.split('|||')[1];
                this.showToast('Please wait', '', 'info');
                // Now call getCustomerDetails after fiscalYearId is set
                return getCustomerDetails({ fiscalYear: this.fiscalYearId });
            })
            .then((data) => {
                if (data.length > 0) {
                    const inputData = JSON.parse(JSON.stringify(data));
                    this.performanceMasters = inputData.map((customer, index) => {
                        const total = this.calculateTotal(customer.performanceLineMap);
                        return {
                            ...customer,
                            totalPerformance: total,
                            rowIndex: index // useful for event handling
                        };
                    });
                    // this.performanceMasters = data;
                    console.log('performanceMasters:>>>> ', this.performanceMasters);
                }
                return getUserName().then((data) => {
                    this.userName = data;
                    this.showSpinner = false;
                    this.handlerTotalByTypeCalculation();
                });
            })
            .catch((error) => {
                console.log(error);
                this.showSpinner = false;
                this.showToast('Error', error, 'error');
            });
    }


    showToast(title, msg, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    handlePerformanceChange(event) {
        const masterId = event.target.dataset.id;
        const value = parseFloat(event.target.value) || 0;

        let updatedPerformanceMasters = JSON.parse(JSON.stringify(this.performanceMasters));

        let record = updatedPerformanceMasters.find(item => item.performanceReportId === masterId);

        record.Potential = value;

        this.performanceMasters = updatedPerformanceMasters;
    }


    handlePerformanceLineItemChange(event) {

        // console.log(this.performanceMasters[0].performanceLineMap);


        let inputValue = event.target.value;

        // Safely handle empty or invalid values
        if (!inputValue) {
            event.target.setCustomValidity("Value cannot be empty");
            event.target.reportValidity();
            return;
        }

        // Optional: Convert to float and back to string for strict format checking
        const floatVal = parseFloat(inputValue);
        const formattedVal = floatVal.toFixed(2); // force 2 decimals
        const regex = /^\d{1,2}(\.\d{1,2})?$/;

        if (!regex.test(inputValue)) {
            event.target.setCustomValidity("Enter number in 00.00 format");
        } else {
            event.target.setCustomValidity(""); // clear any custom error
            // You can optionally round and set the value:
            // event.target.value = formattedVal;
            const lineItemId = event.target.dataset.id; // performanceReportLineItemId
            const field = event.target.dataset.field;
            // const value = parseFloat(event.target.value) || 0;
            const value = event.target.value || 0;

            // Clone to trigger reactivity
            let updatedPerformanceMasters = JSON.parse(JSON.stringify(this.performanceMasters));

            // Find the correct record based on performanceReportLineItemId inside each month's performanceLineMap
            for (let record of updatedPerformanceMasters) {
                const months = record.performanceLineMap;
                for (let monthKey in months) {
                    if (months[monthKey].performanceReportLineItemId === lineItemId) {
                        months[monthKey][field] = value;
                        break;
                    }
                }
            }

            this.performanceMasters = updatedPerformanceMasters;
            this.handlerTotalByTypeCalculation();
            this.handlerTotalByCustomerCalculation(event);
        }

        event.target.reportValidity();

        // const lineItemId = event.target.dataset.id; // performanceReportLineItemId
        // const field = event.target.dataset.field;
        // const value = parseFloat(event.target.value) || 0;

        // // Clone to trigger reactivity
        // let updatedPerformanceMasters = JSON.parse(JSON.stringify(this.performanceMasters));

        // // Find the correct record based on performanceReportLineItemId inside each month's performanceLineMap
        // for (let record of updatedPerformanceMasters) {
        //     const months = record.performanceLineMap;
        //     for (let monthKey in months) {
        //         if (months[monthKey].performanceReportLineItemId === lineItemId) {
        //             months[monthKey][field] = value;
        //             break;
        //         }
        //     }
        // }

        // this.performanceMasters = updatedPerformanceMasters;
    }

    validateFormat(event) {
        const value = event.target.value;
        const regex = /^\d{1,2}(\.\d{1,2})?$/;
        if (!regex.test(value)) {
            event.target.setCustomValidity("Please enter a number in 00.00 format");
        } else {
            event.target.setCustomValidity(""); // Clear error
        }
        event.target.reportValidity();
    }

    handleSave() {
        savePerformanceReport({ performanceMastersInString: JSON.stringify(this.performanceMasters) }).then((data) => {
            if (data == 'Success') {
                this.showToast('Success', 'Saved Successfully', 'success');
            }
        }).catch((error) => {
            this.showToast('Error', error, 'error');
        })
    }

    @track monthlyTotals;
    @track isTotalFlag = false;
    handlerTotalByTypeCalculation() {
        const months = [
            'April', 'May', 'June', 'July', 'August', 'September',
            'October', 'November', 'December', 'January', 'February', 'March'
        ];

        const types = [
            'ConvCommon', 'ConvSpl', 'CO2FCAW',
            'Accessories', 'LOT', 'OA', 'SW'
        ];

        // Initialize totals as: { April: { ConvCommon: 0, ... }, May: { ... }, ... }
        let monthlyTotals = {};

        months.forEach(month => {
            monthlyTotals[month] = {};
            types.forEach(type => {
                monthlyTotals[month][type] = 0;
            });
        });

        // Accumulate values
        this.performanceMasters.forEach(master => {
            months.forEach(month => {
                const line = master.performanceLineMap[month];
                if (line) {
                    types.forEach(type => {
                        const val = parseFloat(line[type]) || 0;
                        monthlyTotals[month][type] += val;
                    });
                }
            });
        });

        // Log results
        // console.log('=== Monthly Totals ===');
        months.forEach(month => {
            // console.log(`-- ${month} --`);
            types.forEach(type => {
                // console.log(`${type}: ${monthlyTotals[month][type]}`);
            });
        });

        // Optional: store for use in template
        this.monthlyTotals = monthlyTotals;

        console.log(this.monthlyTotals);
        setTimeout(() => {
            this.isTotalFlag = true;
        }, 2000);
    }

    handlerTotalByCustomerCalculation(event) {
        const { rowindex, month, field } = event.target.dataset;
        const value = Number(event.target.value);

        // Update specific field
        this.performanceMasters[rowindex].performanceLineMap[month][field] = value;

        // Recalculate total
        const updatedTotal = this.calculateTotal(this.performanceMasters[rowindex].performanceLineMap);
        this.performanceMasters[rowindex].totalPerformance = updatedTotal;

        // Force reactivity
        this.performanceMasters = [...this.performanceMasters];
    }

    @track totalByCustomer;
    calculateTotal(performance) {

        let total = 0;
        for (const month in performance) {
            const monthData = performance[month];
            for (const category in monthData) {
                if (category != 'performanceReportLineItemId') {
                    total += Number(monthData[category]);
                }
            }
        }
        return total;
    }

    get tableCells() {
        // Flatten for rendering as <template for:each={tableCells}>
        const cells = [];
        const types = [
            'ConvCommon', 'ConvSpl', 'CO2FCAW',
            'Accessories', 'LOT', 'OA', 'SW'
        ];
        this.months.forEach(month => {
            types.forEach(type => {
                const value = this.monthlyTotals?.[month]?.[type] ?? 0;
                cells.push({ key: `${month}-${type}`, value });
            });
        });
        return cells;
    }


}