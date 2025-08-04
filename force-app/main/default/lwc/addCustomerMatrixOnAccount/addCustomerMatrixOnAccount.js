import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from "lightning/actions";
import modal from '@salesforce/resourceUrl/modalwidth';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getdefalutData from '@salesforce/apex/AddCustomerMatrixOnAccountController.getdefalutData';

import saveRecord from '@salesforce/apex/AddCustomerMatrixOnAccountController.saveRecord';



export default class AddCustomerMatrixOnAccount extends NavigationMixin(LightningElement) {
    recordId;
    @track keyIndex = 0;
    @track arrData = [
        // {
        //     Id: 0,
        //     label: 'Company Name',
        //     Product_Brand: '',
        //     Product_Category: '',
        //     Product_Name: '',
        //     Product_Size: '',
        //     com_label: 'Company Name',
        //     com_Product_Brand: '',
        //     com_Product_Category: '',
        //     com_Product_Name: '',
        //     com_Product_Size: '',
        //     empName: '',
        //     empId: '',
        //     customer: '',
        //     customerId: '',
        //     industry: '',
        //     industryId: '',
        //     dept: '',
        //     deptId: '',
        //     newApp: '',
        //     appliction: '',
        //     applictionId: '',

        // }
    ]

    @track empId;
    @track industryId;
    @track showSpinner = false;


    @track isOpen = true;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
        console.log(this.recordId + ' in 0000000');


    }


    connectedCallback() {
        loadStyle(this, modal);
        console.log('-->', this.recordId);
        this.getDetail();

    }

    getDetail() {
        getdefalutData({ recordId: this.recordId }).then(result => {
            console.log('json', result);
            let data = JSON.parse(result);
            //this.arrData[0].empId = data.logUserId;
            this.empId = data.logUserId;
            this.industryId = data.industry;

            this.arrData = [
                {
                    Id: 0,
                    label: 'D&H Secheron',
                    Product_Brand: '',
                    Product_Category: '',
                    Product_Name: '',
                    Product_Size: '',
                    com_label: '',
                    com_Product_Brand: '',
                    com_Product_Category: '',
                    com_Product_Name: '',
                    com_Product_Size: '',
                    empName: '',
                    empId: data.logUserId,
                    customer: '',
                    customerId: this.recordId,
                    industry: '',
                    industryId: data.industry,
                    dept: '',
                    deptId: '',
                    newApp: '',
                    appliction: '',
                    applictionId: '',
                    alloy: '0',
                    potential: '0',
                    com_alloy: '0',
                    com_potential: '0',
                    com_Name_error: false,
                    com_poten_error: false,
                    com_alloy_error: false,
                    poten_error: false,
                    alloy_error: false,

                }
            ]
        })

    }

    handleChange(event) {
        console.log('index', event.target.dataset.index, ' key ', event.target.dataset.name);


        let index = event.target.dataset.index;
        let fieldName = event.target.dataset.name;


        this.arrData.forEach(element => {

            if (element.Id == index) {
                console.log('OUTPUT New Value: ', this.arrData[index][fieldName], event.target.value);
                console.log('OUTPUT --2: ', this.arrData[index][fieldName]);
                this.arrData[index][fieldName] = event.target.value;
            }
        })
    }


    onRMItemChange(event) {
        this.showSpinner = true;
        let v_i = event.detail.index;
        this.arrData[v_i].industryId = event.detail.selectedRecordId;
        this.showSpinner = false;
    }


    onDeptChange(event) {
        this.showSpinner = true;
        let v_i = event.detail.index;
        this.arrData[v_i].deptId = event.detail.selectedRecordId;
        this.showSpinner = false;
    }

    onAppChange(event) {
        this.showSpinner = true;
        let v_i = event.detail.index;
        this.arrData[v_i].applictionId = event.detail.selectedRecordId;
        this.showSpinner = false;
    }


    saveRecord() {
        console.log('save ::>>>', JSON.stringify(this.arrData));

        //let checker = true;

        saveRecord({ js: JSON.stringify(this.arrData) }).then(result => {
            for (let key in result)
                if (key == 'success') {
                    this.ShowToastMessage('Success', 'Record Saved Successfully');
                    this.goBackToRecord();

                } else if (key != 'success') {
                    this.ShowToastMessage('Error', result[key]);
                }
        })
        // if (this.arrData.length > 0) {

        //     for (let i = 0; i < this.arrData.length; i++) {

        //         if (this.arrData[i].com_label == '' || this.arrData[i].com_label == undefined) {

        //             checker = false;
        //             this.arrData[i].com_Name_error = true;
        //             console.log('inside -1', this.arrData[i].com_Name_error);
        //         } else {
        //             this.arrData[i].com_Name_error = false;
        //         }

        //         if (Number(this.arrData[i].alloy) <= 0) {

        //             checker = false;
        //             this.arrData[i].alloy_error = true;
        //             console.log('inside 1', this.arrData[i].alloy_error);
        //         } else {
        //             this.arrData[i].alloy_error = false;
        //         }

        //         if (Number(this.arrData[i].potential) <= 0) {

        //             checker = false;
        //             this.arrData[i].poten_error = true;
        //             console.log('inside 2', this.arrData[i].poten_error);
        //             //break;
        //         } else {
        //             this.arrData[i].poten_error = false;
        //         }


        //         if (Number(this.arrData[i].com_alloy) <= 0) {
        //             checker = false;
        //             this.arrData[i].com_alloy_error = true;
        //             console.log('inside 3', this.arrData[i].com_alloy_error);
        //             //break;
        //         } else {
        //             this.arrData[i].com_alloy_error = false;
        //         }

        //         if (Number(this.arrData[i].com_potential) <= 0) {
        //             checker = false;
        //             this.arrData[i].com_poten_error = true;
        //             console.log('inside 4', this.arrData[i].com_poten_error);
        //             //break;
        //         } else {
        //             this.arrData[i].com_poten_error = false;
        //         }
        //     }
        // }

        // console.log('checker', checker);
        // if (checker) {
        //     console.log('checker', checker);

        //     // saveRecord({ js: JSON.stringify(this.arrData) }).then(result => {
        //     //     for (let key in result)
        //     //         if (key == 'success') {
        //     //             this.ShowToastMessage('Success', 'Record Saved Successfully');
        //     //             this.goBackToRecord();

        //     //         } else if (key != 'success') {
        //     //             this.ShowToastMessage('Error', result[key]);
        //     //         }
        //     // })
        // }
    }


    goBackToRecord() {
        setTimeout(() => {
            window.location.reload();
        }, 100);


        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'view',

            }
        });
    }

    addRow() {
        ++this.keyIndex;
        console.log('test one', this.keyIndex);
        //  let newItem = [{ id: this.keyIndex,cb:'', c1:'',c2:'',qty:'' }];
        let newItem = {
            Id: this.keyIndex,
            label: 'D&H Product',
            Product_Brand: '',
            Product_Category: '',
            Product_Name: '',
            Product_Size: '',
            com_label: '',
            com_Product_Brand: '',
            com_Product_Category: '',
            com_Product_Name: '',
            com_Product_Size: '',
            empName: '',
            empId: this.empId,
            customer: '',
            customerId: this.recordId,
            industry: '',
            industryId: this.industryId,
            dept: '',
            deptId: '',
            newApp: '',
            appliction: '',
            applictionId: '',
            alloy: '0',
            potential: '0',
            com_alloy: '0',
            com_potential: '0',
            com_Name_error: false,
            com_poten_error: false,
            com_alloy_error: false,
            poten_error: false,
            alloy_error: false,
        }
        this.arrData.push(newItem);

    }

    removeRow(event) {
        if (this.arrData.length > 1) {
            console.log('index => ', event.target.dataset.index);
            this.arrData.splice(this.arrData.findIndex(row => row.Id == event.target.dataset.id), 1);
            //this.arrData.splice(this.mar_Item.findIndex(row => row.id === event.target.dataset.index), 1);
        }

    }

    ShowToastMessage(variant, msg) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant,
                message: msg,
                variant: variant,
            }),
        );
    }

}