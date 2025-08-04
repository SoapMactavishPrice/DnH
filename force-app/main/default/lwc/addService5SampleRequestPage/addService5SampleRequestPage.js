import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import addService5SampleRequest from "@salesforce/apex/AddService5SampleRequest.addService5SampleRequest";
import codeMaster_object from '@salesforce/schema/Code_Master__c';
import Name_field from '@salesforce/schema/Code_Master__c.Name';
import getcodemaster from "@salesforce/apex/AddService5SampleRequest.getcodemaster";
import getitemcategoryCode from "@salesforce/apex/AddService5SampleRequest.getitemcategoryCode";
import getBrandNameById from "@salesforce/apex/AddService5SampleRequest.getBrandNameById";
import getSizeNameById from "@salesforce/apex/AddService5SampleRequest.getSizeNameById";
import getCurrentUserDetail from "@salesforce/apex/CreateSampleRequest_ToTSDportal.getCurrentUserDetail";
import getItemByCategory from "@salesforce/apex/AddService5SampleRequest.getItemByCategory";
import getItemDetail from "@salesforce/apex/AddService5SampleRequest.getItemDetail";
import getLineItem from "@salesforce/apex/AddService5SampleRequest.getLineItem";
import getSamReqBrand from "@salesforce/apex/AddService5SampleRequest.getSamReqBrand";
import getitemsize from "@salesforce/apex/AddService5SampleRequest.getitemsize";
import deleteSampleLI from "@salesforce/apex/AddService5SampleRequest.deleteSampleLI";
import addAttachment from "@salesforce/apex/Ser19_GetInvoice.addAttachment";

// const COLS = [
//     { label: 'Item Category', fieldName: 'Item_Category_Code__c', type: 'text', initialWidth: 190, sortable: true },
//     { label: 'Item No', fieldName: 'Item_No__c',type: 'text', initialWidth: 190, sortable: true },
//     { label: 'Description', fieldName: 'Description__c',type: 'text', initialWidth: 190, sortable: true },
//     { label: 'Brand Name', fieldName: 'Brand_Name__c',type: 'text', initialWidth: 190, sortable: true },
//     { label: 'Quantity', fieldName: 'Quantity__c',type: 'text', initialWidth: 100, sortable: true },
//     { label: 'UOM', fieldName: 'UOM__c',type: 'text', initialWidth: 100, sortable: true },
//     { label: 'Potential of Business', fieldName: 'Potential_Of_Business',type: 'text', initialWidth: 120, sortable: true },
//     { label: 'Application Details', fieldName: 'Application_Details__c',type: 'text', initialWidth: 150, sortable: true },
//     { label: 'Special Properties', fieldName: 'Special_Properties__c',type: 'text', initialWidth: 120, sortable: true },
//     { label: 'Remarks', fieldName: 'Remarks__c',type: 'text', initialWidth: 100, sortable: true },
// ];

export default class AddService5SampleRequestPage extends NavigationMixin(LightningElement) {
    @api param1; // To hold parameter value
    @api sampReqRecId = '';
    @track showSpinner = false;
    @track showSpinner2 = false;
    @track isnewproductmodelOpen = false;
    @track isSendSampleOrderFlag = false;
    @track isEditing = false;
    @track editIndex;
    @track doc_MainFile;
    @track doc_MainFileName;
    @track doc_MainFileArray = [];
    // @track doc_AddItemFileName;
    @track service5Name;
    @track objectname = 'Service 5-(Sample Request)';
    modalData = {};
    @track codeMasterData = []; // To store the processed results
    @track displayLabel;
    @track service5Date
    @track buttonClickedName = '';
    @track sendSampleOrderResponse = '';

    // @track NewProductList = [{ 
    //     index: 0, 
    //     Item_Category_Code__c: '',
    //     Item_No__c: '',
    //     Description__c: '',
    //     Brand_Name__c: '',
    //     Size_mm__c: '',
    //     Quantity__c: '',
    //     Qty_Type__c: '',
    //     Potential_Of_Business__c: '',
    //     Application_Details__c: '',
    //     Special_Properties__c: '',
    //     Remarks__c: ''
    // }];
    @track showTableProduct = []; // Track the list of products to display in the table
    //columns = COLS;
    @track NewProductList = [];
    @track itemcategoryCodeOptions = [];
    @track itemMasterOptions = [];
    @track SamReqBrandOptions = [];
    @track quantityOptions = [];
    @track qtyTypeOptions = [];
    @track itemsizeOptions = [];

    @track fieldStaffCodeValue = '';
    @track zonalManagerValue = '';
    @track areaManagerValue = '';

    get NewProductListLength() {
        return this.NewProductList.length > 0;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('OUTPUT RECID: ', JSON.stringify(currentPageReference.state));
            if (currentPageReference.state.c__recId != null && currentPageReference.state.c__recId != undefined) {
                this.sampReqRecId = currentPageReference.state.c__recId;
            }
        }
    }

    showToast(toastTitle, toastMsg, toastType) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMsg,
            variant: toastType,
            mode: "dismissable"
        });
        this.dispatchEvent(event);
    }

    navigateToRecordPage() {
        if (this[NavigationMixin.Navigate]) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.sampReqRecId,
                    objectApiName: 'Service_5_Sample_Request__c',
                    actionName: 'view'
                }
            });
        } else {
            console.error('NavigationMixin is not available on this component.');
        }
    }

    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.param1 = currentPageReference.state.c__param1;
    //         console.log('RecordId', this.param1);
    //     }
    // }

    @track isMobile = false;
    connectedCallback() {
        const today = new Date();
        const year = today.getFullYear();
        const month = (today.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-based, so add 1
        const day = today.getDate().toString().padStart(2, '0');

        this.service5Date = `${year}-${month}-${day}`; // Format YYYY-MM-DD

        this.isnewproductmodelOpen = false;
        if (this.sampReqRecId == '') {
            this.getcodemaster();
        } else {
            setTimeout(() => {
                this.getSampleRequestLineItem();
            }, 2000);
        }
        this.handleGetUsersDetail();

        // this.getitemcategoryCode();

        if (window.innerWidth <= 768) {
            this.isMobile = true;
        }
    }
    //getcodemaster
    // getcodemaster(){
    //     getcodemaster({objectname: this.objectname})
    //     .then(result =>{
    //         console.log('getcodemaster result:', result);
    //         const data = JSON.parse(result);

    //     })


    // }
    getcodemaster() {
        getcodemaster({ objectname: this.objectname })
            .then(result => {
                console.log('displayLabel result:', result);

                // No need to parse if result is already an object
                if (result) {
                    //this.displayLabel = result.Display_Label__c; // Access Display_Label__c directly
                    this.displayLabel = result; // Store the entire result if needed
                    //this.displayLabel = this.codeMasterData;
                    console.log('Result Keys:', Object.keys(result));  // Log all keys of the result object
                    //console.log('Display_Label__c:', result.data.Display_Label__c); 
                    console.log('displayLabel result:', result?.Display_Label__c);

                } else {
                    this.showToast('Error', 'No data received', 'error');
                }
            })
            .catch(error => {
                console.error('Error in getcodemaster:', error);
                this.showToast('Error', 'Failed to fetch data', 'error');
            });
    }

    @wire(getitemcategoryCode)
    getitemcategoryCode({ error, data }) {
        if (data) {
            this.itemcategoryCodeOptions = data;
            console.log('itemcategoryCodeOptions', this.itemcategoryCodeOptions);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.itemcategoryCodeOptions = [];
        }
    }

    @wire(getSamReqBrand)
    getSamReqBrand({ error, data }) {
        if (data) {
            this.SamReqBrandOptions = data;
            console.log('SamReqBrandOptions', this.SamReqBrandOptions);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.SamReqBrandOptions = [];
        }
    }
    @wire(getitemsize)
    getitemsize({ error, data }) {
        if (data) {
            this.itemsizeOptions = data;
            console.log('itemsizeOptions', this.itemsizeOptions);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.itemsizeOptions = [];
        }
    }

    handleGetUsersDetail() {
        new Promise((resolve, reject) => {
            getCurrentUserDetail().then((data) => {
                console.log('data:>>> ', data);
                let tdata = data.split(';');
                this.fieldStaffCodeValue = tdata[0];
                this.zonalManagerValue = tdata[1];
                this.areaManagerValue = tdata[2];
                resolve(data);
            })
        }).then(() => {

        })
    }

    getSampleRequestLineItem() {
        getLineItem({
            rId: this.sampReqRecId
        }).then((data) => {
            let sData = JSON.parse(data);
            console.log('getLineItemdata: ', sData);
            let ind = 1;
            sData.forEach(item => {
                item.Item_Category_Name = item.Sample_Request_Item_Category_Code__r.Name;
                item.Item_Number__c = item.Item_No__r.Item_Number__c;
                item.SR_Brand_Name = item.Sam_Req_Brand_Name__r.Name;
                item.SR_Size_Name = item.Sam_Req_Size_mm__r.Name;
                item.SrNo = ind;
                ind++;
            });
            this.NewProductList = sData;
            console.log('NewProductList:>>>> : ', this.NewProductList);
        })
    }


    handleNewItemClick() {
        // this.showSpinner = true;
        this.isnewproductmodelOpen = true; // Open the modal
        // this.doc_AddItemFileName = '';
        if (this.sampReqRecId != '') {
            this.handlerGetItemByCategory();
        }
    }

    goBackToMainpage() {
        this.isnewproductmodelOpen = false; // Close the modal
        this.showSpinner = false;
        this.modalData = {};
        this.isEditing = false;
    }

    handleOnChange(event) {
        // console.log(event.target.fieldName);
        // console.log(event.currentTarget.dataset.name);
        // console.log(event.target.value);
        // console.log(event.target.dataset.lookupLabel);

        if (event.target.fieldName != undefined) {
            const field = event.target.fieldName;
            this.modalData[field] = event.target.value;
            if (field == 'Sam_Req_Brand_Name__c') {
                getBrandNameById({
                    Id: event.target.value
                }).then((data) => {
                    this.modalData['SR_Brand_Name'] = data;
                })
            } else if (field == 'Sam_Req_Size_mm__c') {
                getSizeNameById({
                    Id: event.target.value
                }).then((data) => {
                    this.modalData['SR_Size_Name'] = data;
                })
            }
        } else {
            if (event.currentTarget.dataset.name == 'itemcategorycode') {
                this.modalData.Sample_Request_Item_Category_Code__c = event.target.value;
                const selectedOption = this.itemcategoryCodeOptions.find(option => option.value === this.modalData.Sample_Request_Item_Category_Code__c);
                const selectedLabel = selectedOption ? selectedOption.label : '';
                this.modalData.Item_Category_Name = selectedLabel;
                this.handlerGetItemByCategory();
            } else if (event.currentTarget.dataset.name == 'itemsize') {
                this.modalData.Sam_Req_Size_mm__c = event.target.value;
                const selectedOption = this.itemsizeOptions.find(option => option.value === this.modalData.Sam_Req_Size_mm__c);
                const selectedLabel = selectedOption ? selectedOption.label : '';
                this.modalData.SR_Size_Name = selectedLabel;
            } else if (event.currentTarget.dataset.name == 'itemno') {
                this.modalData.Item_No__c = event.target.value;
                this.handlerGetSelectedItemDetail();
            } else if (event.currentTarget.dataset.name == 'brandname') {
                this.modalData.Sam_Req_Brand_Name__c = event.target.value;
                const selectedOption = this.SamReqBrandOptions.find(option => option.value === this.modalData.Sam_Req_Brand_Name__c);
                const selectedLabel = selectedOption ? selectedOption.label : '';
                this.modalData.SR_Brand_Name = selectedLabel;
            } else if (event.currentTarget.dataset.name == 'qtytype') {
                this.modalData.Qty_Type_2__c = event.target.value;
            } else if (event.currentTarget.dataset.name == 'quantity') {
                this.modalData.Quantity_2__c = event.target.value;
            }
        }

    }

    handlerGetItemByCategory() {
        new Promise((resolve, reject) => {
            getItemByCategory({
                catId: this.modalData.Sample_Request_Item_Category_Code__c
            }).then(result => {
                this.itemMasterOptions = JSON.parse(result);
                resolve(result);
            })
        }).then(() => {
            if (this.sampReqRecId != '') {
                this.handlerGetSelectedItemDetail();
            }
        })
    }

    handlerGetSelectedItemDetail() {
        new Promise((resolve, reject) => {
            getItemDetail({
                itemId: this.modalData.Item_No__c
            }).then(result => {
                console.log(JSON.parse(result));
                let data = JSON.parse(result);
                this.quantityOptions = data.Sample_Quantity__c.split('~').map((item) => ({
                    label: item,
                    value: item
                }));
                this.qtyTypeOptions = data.Sample_UOM__c.split('~').map((item) => ({
                    label: item,
                    value: item
                }));

                this.modalData.Description__c = data.Description__c;
                this.modalData.Item_Number__c = data.Item_Number__c;
                if (this.qtyTypeOptions.length == 1) {
                    this.modalData.Qty_Type_2__c = this.qtyTypeOptions[0].value;
                }
                resolve(result);
            })
        }).then(() => {

        })
    }

    AddNewProduct() {
        console.log('NewProductList', this.NewProductList);

        if (this.modalData.Sample_Request_Item_Category_Code__c == '' || this.modalData.Sample_Request_Item_Category_Code__c == null) {
            this.showToast('Please Select Item Category', '', 'error');
        } else if (this.modalData.Item_No__c == '' || this.modalData.Item_No__c == null) {
            this.showToast('Please Select Any Item', '', 'error');
        } else if (this.modalData.Sam_Req_Brand_Name__c == '' || this.modalData.Sam_Req_Brand_Name__c == null) {
            this.showToast('Please Select Brand', '', 'error');
        } else if (this.modalData.Sam_Req_Size_mm__c == '' || this.modalData.Sam_Req_Size_mm__c == null) {
            this.showToast('Please Select Size', '', 'error');
        } else if (this.modalData.Quantity_2__c == '' || this.modalData.Quantity_2__c == null) {
            this.showToast('Please Select Quantity', '', 'error');
        } else if (this.modalData.Qty_Type_2__c == '' || this.modalData.Qty_Type_2__c == null) {
            this.showToast('Please Select Qty Type', '', 'error');
        } else if (this.modalData.Application_Details__c == '' || this.modalData.Application_Details__c == null) {
            this.showToast('Application Detail Cannot be blank', '', 'error');
        } else if (this.modalData.Special_Properties__c == '' || this.modalData.Special_Properties__c == null) {
            this.showToast('Special Properties Cannot be blank', '', 'error');
        } else if (this.modalData.Potential_Of_Business__c == '' || this.modalData.Potential_Of_Business__c == null) {
            this.showToast('Potential of business Cannot be blank', '', 'error');
        } else {

            if (this.isEditing) {
                this.NewProductList[this.editIndex] = { ...this.modalData };
            } else {
                this.NewProductList = [...this.NewProductList, { ...this.modalData }];
            }
            let ind = 1;
            this.NewProductList.forEach(item => {
                item.SrNo = ind;
                ind++;
            });
            this.handleCloseAddNewItems();

            console.log('NewProductList after adding new product:', this.NewProductList);
            // this.isnewproductmodelOpen = false;
            //console.log('Newly Added addedItemList:>>> ', this.showTableProduct);
        }

    }

    handleCloseAddNewItems() {
        this.isnewproductmodelOpen = false;
        this.showSpinner = false;
        this.modalData = {};
        this.isEditing = false;
    }

    handleRemoveRow(event) {
        const index = event.currentTarget.dataset.index;
        let lineItemId = this.NewProductList[index].Id;
        if (lineItemId != undefined) {
            deleteSampleLI({
                Id: lineItemId
            }).then((data) => {
                console.log('delete Sample LI data:>>> ', data);
            }).catch((error) => {
                console.log('delete Sample LI error:>>> ', error);
            })
        }
        this.NewProductList.splice(index, 1);
        this.NewProductList = [...this.NewProductList];
        console.log('Updated showTableProduct after deletion', this.NewProductList.length);
    }

    handleEditRow(event) {
        this.showSpinner = true;
        const index = event.currentTarget.dataset.index;
        this.modalData = { ...this.NewProductList[index] };
        this.isEditing = true;
        this.editIndex = index;
        this.handleNewItemClick();
        this.showSpinner = false;
    }

    handleMainFileUpload(event) {
        // this.doc_MainFile = null;
        // this.doc_MainFileName = '';
        // console.log(event.target.files[0].size);

        // if (event.target.files.length > 0 && event.target.files[0].size < 3 * 1024 * 1024) {
        let files = [];
        // for (var i = 0; i < event.target.files.length; i++) {
        let file = event.target.files[0];
        let reader = new FileReader();
        reader.onload = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            let text = file.name;
            // let myArray = text.split(".");
            // let titleTemp = 'Document ' + myArray[myArray.length - 1];
            // this.doc_MainFileName = 'Document ' + myArray[myArray.length - 1];
            // this.doc_MainFileName = text;
            // this.doc_MainFile = { PathOnClient: file.name, Title: text, VersionData: fileContents };
            this.doc_MainFileArray.push(
                {
                    doc_MainFileName: text,
                    doc_MainFile: JSON.stringify({ PathOnClient: file.name, Title: text, VersionData: fileContents })
                }
            );
        };
        reader.readAsDataURL(file);
        // }
        // } else {
        // this.showToast('Error', '', 'File size should be less than 3MB');
        // }
    }

    handleMainOnSubmit(event) {
        event.preventDefault();
        this.buttonClickedName = event.currentTarget.dataset.btnname;
        const lwcInputFields = this.template.querySelectorAll('lightning-input-field');
        let validationflag = false;
        // console.log('ooooooo');

        if (lwcInputFields) {
            // console.log('ooooooo ' ,this.NewProductList.length);

            lwcInputFields.forEach(field => {
                console.log(field.fieldName);
                console.log(field.value);

                if (field.fieldName == 'Customer_Name__c') {
                    if (field.value == null || field.value == '') {
                        console.log(field.fieldName);
                        // field.setCustomValidity('Please Fill this field!');
                        validationflag = true;
                    }
                }
                if (field.fieldName == 'Address_1__c') {
                    if (field.value == null || field.value == '') {
                        // field.setCustomValidity('Please Fill this field!');
                        validationflag = true;
                    }
                }
                if (field.fieldName == 'City__c') {
                    if (field.value == null || field.value == '') {
                        // field.setCustomValidity('Please Fill this field!');
                        validationflag = true;
                    }
                }
                if (field.fieldName == 'Contact_No__c') {
                    if (field.value == null || field.value == '') {
                        // field.setCustomValidity('Please Fill this field!');
                        validationflag = true;
                    }
                }
                if (field.fieldName == 'Contact_Person_Name__c') {
                    if (field.value == null || field.value == '') {
                        // field.setCustomValidity('Please Fill this field!');
                        validationflag = true;
                    }
                }
                if (field.fieldName == 'Postal_Code__c') {
                    if (field.value == null || field.value == '') {
                        // field.setCustomValidity('Please Fill this field!');
                        validationflag = true;
                    }
                }
                if (field.fieldName == 'Mode_of_Dispatch__c') {
                    if (field.value == null || field.value == '') {
                        // field.setCustomValidity('Please Fill this field!');
                        validationflag = true;
                    }
                }
                field.reportValidity();
            });
            if (this.NewProductList.length < 1) {
                // console.log('ooooooo');
                validationflag = true;
                this.showToast('error', 'Add one item atleast', 'error');
            } else if (validationflag) {
                this.showToast('error', 'Please fill all required fields!!!', 'error');
                return;
            } else {
                const form1 = this.template.querySelector('lightning-record-edit-form[data-id="form1"]');
                const fields = {};
                fields.Field_Staff_Code__c = this.fieldStaffCodeValue;
                fields.Area_Manager__c = this.areaManagerValue;
                fields.Zonal_Head__c = this.zonalManagerValue;
                fields.Submitted_By__c = this.fieldStaffCodeValue;
                fields.Inserted_By__c = this.fieldStaffCodeValue;
                fields.Is_Submitted__c = true;
                const now = new Date();
                const formattedDateTime = now.toISOString();
                fields.Submitted_Date__c = formattedDateTime;
                lwcInputFields.forEach(field => {
                    fields[field.fieldName] = field.value;
                });

                form1.submit(fields);
            }
        }
    }

    handleErrorSubmit(event) {
        console.log(event.target.detail);

    }

    handleMainOnSuccess(event) {
        this.sampReqRecId = event.detail.id;
        // console.log(this.showTableProduct);
        // console.log(this.NewProductList);
        this.showSpinner = true;

        if (this.doc_MainFileArray.length > 0) {
            console.log(this.doc_MainFileArray);
            this.handleSaveAttachments(this.sampReqRecId);
        } else {
            this.handleAfterCheckAttachment();
        }
    }

    handleSaveAttachments(para) {
        let isDone = true;
        let lastElement = this.doc_MainFileArray[this.doc_MainFileArray.length - 1];

        this.showToast('Please wait, Attachment is uploading...', '', 'info');

        let promises = this.doc_MainFileArray.map(el => {
            return addAttachment({
                Id: para, filedata: el.doc_MainFile
            }).catch(error => {
                console.error('Error:', error);
            });
        });

        // Wait for all insertions to complete
        Promise.all(promises)
            .then(() => {
                this.showToast('Success', 'All Attachment inserted successfully!', 'success');
                this.handleAfterCheckAttachment();
            }).catch(error => {
                this.showToast('Error', 'Error inserting attachment', 'error');
                console.log('ERROR IN ALL PROMISE::', error);

            });

    }

    handleAfterCheckAttachment() {
        new Promise((resolve, reject) => {
            addService5SampleRequest({
                Id: this.sampReqRecId,
                mdoc: this.doc_MainFile != undefined ? JSON.stringify(this.doc_MainFile) : '',
                lineitemlist: this.NewProductList.length > 0 ? JSON.stringify(this.NewProductList) : ''
            }).then((result) => {
                console.log('result:>>> ', result);
                resolve(result);
            }).catch((error) => {
                console.log('error:>>> ', error);
                reject(error);
                this.showSpinner = false;
            });
        }).then(() => {
            this.showSpinner = false;
            this.showToast('Sample Request Created', '', 'success');
            if (this.buttonClickedName == 'savebtn') {
                this.navigateToRecordPage();
            } else if (this.buttonClickedName == 'submitbtn') {
                this.handlerSendSampleOrder();
            }
        })
    }

    closeModal() {
        this.isSendSampleOrderFlag = false;
        if (this.sendSampleOrderResponse == 'Sample Order Created Successfully') {
            this.navigateToRecordPage();
        } else {
            console.log('not created');
            location.reload();
        }
    }

    handlerSendSampleOrder() {
        this.isSendSampleOrderFlag = true;
    }

    handleAfterSend(event) {
        this.sendSampleOrderResponse = event.detail.value;

    }

    handleMainClick() {
        if (!this.isMobile) {
            // Navigate to the Enquiry list view
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Service_5_Sample_Request__c',
                    actionName: 'list'
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Service_5_Sample_Request__c',
                    actionName: 'home',
                },
            });
        }

    }

    // handleReplaceEvent(event) {
    //     const inputField = event.target;
    //     let value = inputField.value;

    //     // Restrict "&" character
    //     if (value.includes('&')) {
    //         // Replace "&" with an empty string or another character (e.g., "and")
    //         value = value.replace(/&/g, '&amp;');

    //         // Assign the sanitized value back to the field
    //         inputField.value = value;
    //     }
    //     console.log('= >', value);
    //     console.log('= >', inputField.value);

    // }

}