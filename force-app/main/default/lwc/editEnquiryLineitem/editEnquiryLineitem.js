import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from "lightning/navigation";
import customPicklist from 'c/customPicklist';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import enqlineitem_object from '@salesforce/schema/Enquiry_Line_Item__c';
import status_field from '@salesforce/schema/Enquiry_Line_Item__c.Status__c';
import { updateRecord } from 'lightning/uiRecordApi';

import getEnquiryLineItems from '@salesforce/apex/EditEnquiryLineitems.getEnquiryLineItems'; // Apex method to fetch line items
import getStatusPicklistOptions from '@salesforce/apex/EditEnquiryLineitems.getStatusPicklistOptions'; // Apex method to fetch line items

import modal from '@salesforce/resourceUrl/modalwidth';
import { loadStyle } from 'lightning/platformResourceLoader';


export default class EditEnquiryLineItems extends LightningElement {
    @track lineItems; // Stores line items data
    @track draftValues = []; // Stores the draft values when editing
    @track isModalOpen = false;
    @api enqrecordid;
    statusOptn = [];

    @track columns = [
        {
            label: 'Item Name',
            fieldName: 'Item_Master_Name',
            type: 'text',
            editable: true
        },
        {
            label: 'Item Description',
            fieldName: 'Item_Description__c',
            type: 'text',
            editable: true
        },
        {
            label: 'Quantity',
            fieldName: 'Qty__c',
            type: 'text',
            editable: true
        },
        {
            label: 'Sales Price',
            fieldName: 'Sales_Price__c',
            type: 'text',
            editable: true
        },
        {
            label: 'Discount',
            type: 'text',
            editable: true
        },
        {
            label: 'Status',
            fieldName: 'Status__c',
            type: 'picklist', // Custom type for the picklist
            editable: true,
            wrapText: true,
            typeAttributes: {
                // options: { fieldName: 'customPicklist' },// Pass the correct picklist options
                options: [
                    { label: 'Close Won', value: 'Close Won' },
                    {label : 'Close Lost',value:'Close Lost'}
                ],
                value: { fieldName: 'Status__c' }, // The current value of the picklist
                placeholder: 'Select Status',
                context: { fieldName: 'Id' } // The context for the picklist
            }
        }
    ];


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.EnquiryId = currentPageReference.state.c__refRecordId;
            // this.AccountId = currentPageReference.state.c__accountId;
            //this.recordtype =  currentPageReference.state.c__recordtypeId;
            // if(this.recordtype =='012F3000002BKRf'){
            //     this.rateType = 'Special Rate';
            // }else{
            //     this.rateType = 'Standard Rate';
            // }
            console.log('this.EnquiryId', this.EnquiryId);


        }
    }
    connectedCallback() {

        loadStyle(this, modal);
		// console.log('CONNECTED CALL BACK :>> ', this.recordId);
        this.isModalOpen = true;
        this.fetchLineItems(); // Fetch the Enquiry Line Items when component loads
        // this.statusOptions1 = [
        //     { label: 'Close Won', value: 'Close Won' },
        //     { label: 'Close Lost', value: 'Close Lost' }
        // ];

    }

    @wire(getObjectInfo, { objectApiName: enqlineitem_object })
    enqlineitemobjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$enqlineitemobjectMetadata.data.defaultRecordTypeId', fieldApiName: status_field })
    wiredPicklistValues({ error, data }) {
        if (data) {
            console.log('Inside wiredPicklistValues', data.values);
            this.statusOptions = data.values;
            // Check if lineItems exist and then assign statusOptions
            if (this.lineItems && this.lineItems.length > 0) {
                this.updateLineItemsWithStatusOptions();
            }
        } else if (error) {
            console.error('Error loading picklist values:', error);
        }
    }

    fetchLineItems() {
        getEnquiryLineItems({
            enquiryId: this.EnquiryId
        }).then(result => {
            // Store line items
            this.lineItems = result;
            console.log('Fetched lineItems:', this.lineItems);
            // Only update if statusOptions is already available
            if (this.statusOptions) {
                this.updateLineItemsWithStatusOptions();
            }
        }).catch(error => {
            this.showToast('Error loading line items', error.body.message, 'error');
        });
    }

    updateLineItemsWithStatusOptions() {
        // Add status options to each line item
        this.lineItems = this.lineItems.map(item => ({
            ...item,
            Item_Master_Name: item.Item_Master__r ? item.Item_Master__r.Name : '',
            statusOptions: this.statusOptions, // Add picklist options to each row,
            Status__c: item.Status__c
        }));
        console.log('this.lineItems Updated:', this.lineItems);
    }
    handleCellChange(event) {
        event.preventDefault();
        this.updateDraftValues(event.detail.draftValues[0]);
        console.log('this.updateDraftValues',this.updateDraftValues(event.detail.draftValues[0]));
        // console.log('event.detail.draftValues[0]',event.detail.draftValues[0]);
    }
    handleValueChange(event) {        

        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log('dataRecieved',dataRecieved);
        let updatedItem;
    }
    // @wire(getObjectInfo, { objectApiName: enqlineitem_object })
    // enqlineitemobjectMetadata;


    // @wire(getPicklistValues, { recordTypeId: '$enqlineitemobjectMetadata.data.defaultRecordTypeId', fieldApiName: status_field })
    //     wiredPicklistValues({ error, data }) {
    //     if (data) {
    //         console.log('InsidewiredPicklistValues',data.value);
    //         this.statusOptions = data.value;
    //         this.fetchLineItems();
    //        // statusOptions;

    //         }
    //         else if (error) {
    //      }
    //     }
    // fetchLineItems() {
    //     getEnquiryLineItems({ enquiryId: this.EnquiryId })
    //         .then(result => {
    //             // Add status options to each line item
    //             this.lineItems = result.map(item => ({
    //                 ...item,
    //                 statusOptions: this.statusOptions // Add picklist options to each row
    //             }));
    //             console.log('this.lineItems with status options:', this.lineItems);
    //         })
    //         .catch(error => {
    //             this.showToast('Error loading line items', error.body.message, 'error');
    //         });
    // }


    // fetchLineItems() {
    //     getEnquiryLineItems({enquiryId: this.EnquiryId})
    //         .then(result => {
    //             this.lineItems = result;
    //             console.log('this.lineItems',this.lineItems);
    //         })
    //         .catch(error => {
    //             this.showToast('Error loading line items', error.body.message, 'error');
    //         });
    // }
    handlePicklistChange(event) {
        const { value, context } = event.detail; // Destructure the event detail
        console.log('Selected Value:', value, 'Context:', context);

        // Find the draft value for the row being edited and update the status
        const draft = this.draftValues.find(draft => draft.Id === context);
        console.log('draftValues',JSON.stringify(draft));
        if (draft) {
            draft.Status__c = value;
        } else {
            this.draftValues.push({ Id: context, Status__c: value });
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }


    handleSave(event) {
        this.fetchLineItems();
        console.log('Event Detail:', event.detail); // Log the event detail
        this.draftValues = event.detail.draftValues || []; // Ensure draftValues is an array
        console.log('draftValues:', JSON.stringify(this.draftValues));
    
        // Proceed only if there are draft values to save
        if (this.draftValues.length > 0) {
            const fieldsArray = this.draftValues.map(draft => ({
                fields: { ...draft } // Make sure to spread the draft values correctly
            }));
    
            const promises = fieldsArray.map(recordInput => updateRecord(recordInput));
    
            Promise.all(promises)
                .then(() => {
                    this.showToast('Success', 'Records updated successfully', 'success');
                    this.draftValues = []; // Clear draft values after save
                    return this.fetchLineItems(); // Refresh data
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to save records: ' + error.body.message, 'error');
                });
        } else {
            console.warn('No draft values to save');
        }
    }
    
    // handleSave(event) {
    //     console.log('Event Detail:', event.detail);
    //     // Get the draft values (edited values)
    //     this.draftValues = event.detail.draftValues;
    //     console.log('draftValues',JSON.stringify(this.draftValues));
        
    //   // }

    //  // //Save the changes when the user clicks the "Save Changes" button
    //  // saveChanges() {
    //     this.draftValues = event.detail.draftValues;
    //     console.log('draftValues',JSON.stringify(this.draftValues));
    //     const fieldsArray = this.draftValues.map(draft => {
    //         return { fields: { ...draft } }; // Map the draft values to record fields for update
    //     });

    //     const promises = fieldsArray.map(recordInput => updateRecord(recordInput)); // Create a promise for each record update

    //     Promise.all(promises)
    //         .then(() => {
    //             this.showToast('Success', 'Records updated successfully', 'success');

    //             // Clear draft values after save
    //             this.draftValues = [];

    //             // Refresh data
    //             return this.fetchLineItems();
    //         })
    //         .catch(error => {
    //             this.showToast('Error', 'Failed to save records: ' + error.body.message, 'error');
    //         });
    // }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}