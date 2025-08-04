import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getTargetCategoryPicklistValues from "@salesforce/apex/SalesRegComparisonController.getTargetCategoryPicklistValues";
import getCurrentActiveFY from "@salesforce/apex/SalesRegComparisonController.getCurrentActiveFY";
import getLastCompletedFY from "@salesforce/apex/SalesRegComparisonController.getLastCompletedFY";
import getState from "@salesforce/apex/SalesRegComparisonController.getState";
import getData2 from "@salesforce/apex/SalesRegComparisonController.getData2";
import getLastYearData from "@salesforce/apex/SalesRegComparisonController.getLastYearData";
import getActiveYearData from "@salesforce/apex/SalesRegComparisonController.getActiveYearData";

export default class SalesRegisterComparison extends LightningElement {

    @track showSpinner = false;
    @track showData = false;
    @track targetCategoryPicklistValues = [];
    @track currentActiveFY = '';
    @track lastCompletedFY = '';
    @track currentActiveFYName = '';
    @track lastCompletedFYName = '';
    @track stateValues = [];

    @track salesRegisterActiveList = [];
    @track salesRegisterLastList = [];

    @track quarterValues = ["Q1", "Q2", "Q3"];
    @track mappedResults = [];


    connectedCallback() {
        this.handlerGetPicklistValue();
        this.handlerGetCurrentActiveFY();
        this.handlerGetLastCompletedFY();
        this.handlerGetState();
        setTimeout(() => {
            // this.handlerGetData2();
            this.showData = true;
        }, 2000);
    }

    handlerGetPicklistValue() {
        this.showSpinner = true;
        getTargetCategoryPicklistValues().then(result => {
            // console.log(result);
            this.targetCategoryPicklistValues = JSON.parse(result);
            // this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                })
            );
        });
    }

    handlerGetCurrentActiveFY() {
        this.showSpinner = true;
        getCurrentActiveFY().then(result => {
            // console.log(result);
            let data = JSON.parse(result);
            this.currentActiveFY = data.Id;
            this.currentActiveFYName = data.Name;
            // this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                })
            );
        });
    }

    handlerGetLastCompletedFY() {
        this.showSpinner = true;
        getLastCompletedFY().then(result => {
            // console.log(result);
            let data = JSON.parse(result);
            this.lastCompletedFY = data.Id;
            this.lastCompletedFYName = data.Name;
            // this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                })
            );
        });
    }

    handlerGetState() {
        this.showSpinner = true;
        getState().then(result => {
            console.log(result);
            this.stateValues = JSON.parse(result);
            // this.showSpinner = false;
            setTimeout(() => {
                this.fetchData();
            }, 1000);
        }).catch(error => {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                })
            );
        });
    }

    @track showLastYearData = [];
    @track showCurrentYearData = [];

    async fetchData() {
        for (const qele of this.quarterValues) {
            for (const tcpele of this.targetCategoryPicklistValues) {
                try {
                    const result = await getLastYearData({ lastYear: this.lastCompletedFY, lastYearName: this.lastCompletedFYName, quarterValue: qele, targetCategory: tcpele });
                    // Handle your result properly here, like:
                    // console.log('qele:>> ', qele);
                    // console.log('tcpele:>> ', tcpele);
                    // console.log('getLastYearData:>> ', result);
                    this.showLastYearData.push(JSON.parse(result));

                    const result2 = await getActiveYearData({ activeYear: this.currentActiveFY, activeYearName: this.currentActiveFYName, quarterValue: qele, targetCategory: tcpele });
                    // console.log('getActiveYearData:>> ', result2);
                    this.showCurrentYearData.push(JSON.parse(result2));
                    // You may also accumulate results in an array
                } catch (error) {
                    console.error(`Error for ${qele} - ${tcpele}:`, error);
                }
            }
        }
        this.handlerStructureData();

    }

    @track lastYearDetailedValues = [];
    @track currentYearDetailedValues = [];
    @track mainData = [];

    handlerStructureData() {
        // let lastYearDetailedValues = [];

        this.showLastYearData.forEach(record => {
            // console.log('showLastYearData record:>> ', record);

            if (!record || Object.keys(record).length === 0) {
                let temp = [];
                this.stateValues.forEach(e => {
                    temp.unshift(0.0);
                });
                this.lastYearDetailedValues.unshift(temp);
            } else {
                let temp = [];
                Object.entries(record).forEach(([state, fyData]) => {
                    Object.entries(fyData).forEach(([fyKey, value]) => {
                        // console.log(fyKey);

                        temp.unshift(value);
                    });
                });
                this.lastYearDetailedValues.unshift(temp);
            }
        });

        this.showCurrentYearData.forEach(record => {
            // console.log('showCurrentYearData record:>> ', record);

            if (!record || Object.keys(record).length === 0) {
                let temp = [];
                this.stateValues.forEach(e => {
                    temp.unshift(0.0);
                });
                this.currentYearDetailedValues.unshift(temp);
            } else {
                let temp = [];
                Object.entries(record).forEach(([state, fyData]) => {
                    Object.entries(fyData).forEach(([fyKey, value]) => {
                        // console.log(fyKey);

                        temp.unshift(value);
                    });
                });
                this.currentYearDetailedValues.unshift(temp);
            }
        });

        // console.log(this.showLastYearData);
        // console.log(this.showCurrentYearData);

        this.lastYearDetailedValues = this.lastYearDetailedValues.reverse();
        this.currentYearDetailedValues = this.currentYearDetailedValues.reverse();
        // console.log(this.lastYearDetailedValues);
        // console.log(this.currentYearDetailedValues);

        let ind = 0;
        this.quarterValues.forEach(ele => {
            this.targetCategoryPicklistValues.forEach(element => {
                this.mainData.push({
                    label: `${this.lastCompletedFYName} ${ele}`,
                    label2: `${element}`,
                    value: this.lastYearDetailedValues[ind]
                });
                this.mainData.push({
                    label: `${this.currentActiveFYName} ${ele}`,
                    label2: `${element}`,
                    value: this.currentYearDetailedValues[ind]
                });
                this.mainData.push({
                    label: 'Growth %',
                    label2: `${element}`,
                    value: this.calculateGrowth(this.lastYearDetailedValues[ind], this.currentYearDetailedValues[ind])
                });
                ind++;
            });
        });

        // console.log(this.mainData);

        let originalData = this.mainData;

        this.mainData = originalData.map(row => {
            return {
                label: row.label,
                label2: row.label2,
                value: row.value.map(val => {
                    return {
                        raw: val,
                        formatted: this.formatCurrency(val)
                    };
                })
            };
        });


        this.showSpinner = false;

        this.changeDataStructure();

    }

    calculateGrowth(p1, p2) {
        let growthArray = [];

        for (let i = 0; i < p1.length; i++) {
            let growth = 0;

            if (typeof p1[i] === 'number' && typeof p2[i] === 'number' && p2[i] !== 0) {
                growth = (p2[i] - p1[i]) / p2[i];
            }

            let growthPercent = (growth * 100).toFixed(2);
            growthArray.push(growthPercent);
        }

        return growthArray;
    }

    formatCurrency(val) {
        return new Intl.NumberFormat('en-IN', {
            maximumFractionDigits: 2,
            minimumFractionDigits: 2
        }).format(val);
    }

    @track transposedData = [];
    @track headers = []; // ['Common', 'SPL']
    @track headers2 = []; // ['Common', 'SPL']

    changeDataStructure() {
        this.headers = this.mainData.map(item => item.label);
        let tempheaders = this.mainData.map(item => item.label2);

        this.headers2 = tempheaders.filter((item, index, arr) => {
            return index === 0 || item !== arr[index - 1];
        });
        console.log('header2:>>> ', this.headers2);


        let rowCount = this.mainData[0]?.value.length || 0;
        let tempTransposed = [];

        for (let i = 0; i < rowCount; i++) {
            let row = {
                label: this.stateValues[i],
                values: []
            };

            for (let j = 0; j < this.mainData.length; j++) {
                row.values.push(this.mainData[j].value[i]?.formatted || '');
            }

            tempTransposed.push(row);
        }

        this.transposedData = tempTransposed;
        console.log(this.transposedData);


    }


}