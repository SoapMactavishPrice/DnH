import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import enqlineitem_object from '@salesforce/schema/Enquiry_Line_Item__c';
import status_field from '@salesforce/schema/Enquiry_Line_Item__c.Status__c';
import lost_enquiry_reason_field from '@salesforce/schema/Enquiry_Line_Item__c.Reason_for_lost_enquiry__c';
import { updateRecord } from 'lightning/uiRecordApi';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';


import getEnquiryLineItems from '@salesforce/apex/EditEnquiryLineitems.getEnquiryLineItems'; // Apex method to fetch line items
import modal from '@salesforce/resourceUrl/modalwidth';
import { loadStyle } from 'lightning/platformResourceLoader';
import { refreshApex } from '@salesforce/apex';

export default class EnquirylineitemEdit extends NavigationMixin(LightningElement) {
    @track lineItems; // Stores line items data
    @track draftValues = []; // Stores the draft values when editing
    @track isModalOpen = false;
    @api enqrecordid;
    lineitemrefreshproperty;
    statuspicklistoption =[];
    lostreasonpicklistoption =[];
    @track showSpinner = false;
    
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
            label: 'Status',
            fieldName: 'Status__c',
            type: 'customPicklist', // Custom type for the picklist
            editable: true,
            wrapText: true,
            typeAttributes: {
                options: { fieldName: 'picklistOptions' },// Pass the correct picklist options
                value: { fieldName: 'Status__c' }, // The current value of the picklist
                placeholder: 'Select Status',
                context: { fieldName: 'Id' } // The context for the picklist
            }
        },
        {
            label: 'Reason for lost enquiry',
            fieldName: 'Reason_for_lost_enquiry__c',
            type: 'customPicklist', // Custom type for the picklist
            editable: true,
            wrapText: true,
            typeAttributes: {
                options: { fieldName: 'lostpicklistOptions' },// Pass the correct picklist options
                value: { fieldName: 'Reason_for_lost_enquiry__c' }, // The current value of the picklist
                placeholder: 'Select Reason',
                context: { fieldName: 'Id' } // The context for the picklist
            }
        }

    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.EnquiryId = currentPageReference.state.c__refRecordId;
            console.log('this.EnquiryId', this.EnquiryId);
           

        }
    }
    @wire(getEnquiryLineItems, {
         enquiryId: "$EnquiryId",
         picklist:"$statuspicklistoption"})
     wiredLineItems(result) {
        this.lineitemrefreshproperty = result;
        if (result.data) {
            //this.lineItems = result.data;
            this.lineItems = result.data.map((currItem) => {
                let picklistOptions = this.statuspicklistoption;
                let lostpicklistOptions = this.lostreasonpicklistoption;
                return{
                    ...currItem,
                    Item_Master_Name: currItem.Item_Master__r ? currItem.Item_Master__r.Name : '',
                    picklistOptions: picklistOptions,
                    lostpicklistOptions:lostpicklistOptions
                }
            }
            )
            console.log('Fetched lineItems:', this.lineItems);
        } else if (result.error) {
            // this.error = error;
            this.showToast('Error loading line items', error.body.message, 'error');
        }
    }
    // fetchLineItems() {
    //     getEnquiryLineItems({
    //         enquiryId: this.EnquiryId
    //     }).then(result => {
    //         // Store line items
    //         this.lineItems = result;
    //         console.log('Fetched lineItems:', this.lineItems);
    //         // Only update if statusOptions is already available
            
    //     }).catch(error => {
    //         this.showToast('Error loading line items', error.body.message, 'error');
    //     });
    // }
    @wire(getObjectInfo, { objectApiName: enqlineitem_object })
    ObjectData;
    @wire(getPicklistValues, {
         recordTypeId: "$ObjectData.data.defaultRecordTypeId", 
         fieldApiName: status_field 
        })
        getPicklistValues({ data, error }) {
            if (data) {
                this.statuspicklistoption = data.values;
                console.log('PICKLIST VALUES :>> ', this.statuspicklistoption);
            } else if (error) {
                console.log('ERROR :>> ', error);
            }
        }
     @wire(getPicklistValues, {
            recordTypeId: "$ObjectData.data.defaultRecordTypeId", 
            fieldApiName:  lost_enquiry_reason_field
           })
           wiredLostReasonPicklistValues({ data, error }) {
               if (data) {
                   this.lostreasonpicklistoption = data.values;
                   console.log('lostreasonpicklistoption PICKLIST VALUES :>> ', this.lostreasonpicklistoption);
               } else if (error) {
                   console.log('ERROR :>> ', error);
               }
           }

    connectedCallback() {

        loadStyle(this, modal);
		// console.log('CONNECTED CALL BACK :>> ', this.recordId);
          this.isModalOpen = true;
       // this.fetchLineItems(); // Fetch the Enquiry Line Items when component loads
       

    }
    
    handleClosepopup(){
        this.isModalOpen = false;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.EnquiryId, // Assuming EnquiryId is available
                objectApiName: 'Enquiry__c',
                //relationshipApiName: 'Enquiry_Line_Items__r', // Replace with the correct relationship name
                actionName: 'view'
            }
        });
    }
    handleCancel() {
        this.isModalOpen = false;  // Close the modal

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.EnquiryId, // Assuming EnquiryId is available
                objectApiName: 'Enquiry__c',
                //relationshipApiName: 'Enquiry_Line_Items__r', // Replace with the correct relationship name
                actionName: 'view'

            }
        });
    }
    async handleSave(event){
        this.showSpinner = true;
        let records = event.detail.draftValues;
        let updateRecordsArray = records.map((currItem) =>{
            let fieldInput ={...currItem};
            return {
                fields : fieldInput
            };
        });
        this.draftValues = []
        let updateRecordsArraypromise = updateRecordsArray.map(currItem => updateRecord(currItem));

        await Promise.all(updateRecordsArraypromise);

        const toastevent = new ShowToastEvent({
            title: 'Success',
            message: 'Line Items Updated successfully',
            variant: 'success',
        });
        this.dispatchEvent(toastevent);
        await refreshApex(this.lineitemrefreshproperty);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.EnquiryId, // Assuming EnquiryId is available
                objectApiName: 'Enquiry__c',
                //relationshipApiName: 'Enquiry_Line_Items__r', // Replace with the correct relationship name
                actionName: 'view'

            }
        });
        this.showSpinner = false;
    }
 
}