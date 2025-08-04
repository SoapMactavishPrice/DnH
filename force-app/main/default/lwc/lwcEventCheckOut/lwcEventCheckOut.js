import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
import
getEventById
    from
    '@salesforce/apex/lwcEventCheckInOutController.getEventById'
    ;
import updateCheckOut from '@salesforce/apex/lwcEventCheckInOutController.updateCheckOut';
import getContacts from '@salesforce/apex/lwcEventCheckInOutController.getContacts';
import saveMeetingAttendees from '@salesforce/apex/lwcEventCheckInOutController.saveMeetingAttendees';
import getdepartment from '@salesforce/apex/lwcEventCheckInOutController.getdepartment';

export default class LwcEventCheckOut extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    @track Visit_Result__c = '';
    @track Description = '';
    @track Client_Feedback_Or_Insights__c = '';
    @track Action_To_Do__c = '';
    @track accountId = '';
    @track isHide = false;
    //@track Action_To_Do_Date = '';
    // @track Array = {
    //     VisitResult: '',
    //     Description: '',
    //     Client_Feedback_Or_Insights: '',
    //     Action_To_Do: ''
    // };
    @track Array = [];




    connectedCallback() {
        console.log(this.recordId);
        getEventById({ recordId: this.recordId })
            .then(result => {
                console.log('OUTPUT : ',JSON.stringify(result));
                if (result.Check_In_Time__c==null) {
                    this.showToastOnError('Please check-in first .');
                    this.redirectToRecordPage(this.recordId);
                    return;
                }

                if (result.Check_Out_Time__c!=null && result.Check_Out_Time__c!='') {
                    this.showToastOnError('Check-Out already completed. You cannot check out again.');
                    this.redirectToRecordPage(this.recordId);
                    return;
                }

            })
            .catch(error => {
                this.showToastOnError(error);
                //this.showSpinner = false;
            });
        // this.getLatLongAndUpdate();
        //this.addRow();
    }

    // Wire the Apex method to fetch Event record dynamically by recordId
    @wire(getEventById, { recordId: '$recordId' })
    wiredEvent({ error, data }) {
        if (data) {
            console.log('data----', JSON.stringify(data));
            this.Visit_Result__c = data.Visit_Result__c;
            this.Description = data.Description;
            this.Client_Feedback_Or_Insights__c = data.Client_Feedback_Or_Insights__c;
            this.Action_To_Do__c = data.Action_To_Do__c;
            this.accountId = data.WhatId;
            if (data.AccountId != null) {
                this.isHide = true;
            }
            this.getContactJS(this.accountId);
            // this.Action_To_Do_Date__c = data.Action_To_Do_Date__c;
        } else if (error) {
            console.log('error----', error);
        }
    }

    getLatLongAndUpdate() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
                console.log('this.array', this.Array);
                updateCheckOut({
                    recordId: this.recordId,
                    latitude: latitude,
                    longitude: longitude,
                    VisitResult: this.Array.Visit_Result__c,
                    Description: this.Array.Description,
                    Client_Feedback_Or_Insights: this.Array.Client_Feedback_Or_Insights__c,
                    Action_To_Do: this.Array.Action_To_Do__c,
                    //Action_To_Do_Date: this.Array.Action_To_Do_Date__c,
                })
                    .then(() => {
                        if (this.isHide) {
                            this.saveMeetingDetails(this.recordId);
                        } else {
                            this.redirectToRecordPage(this.recordId);
                        }

                        //this.redirectToRecordPage(this.recordId);
                    })
                    .catch((error) => {
                        this.showToastOnError(error);
                    });

            });
        }
        else {
            this.showToastOnError('Location permission is not available');
        }
    }

    redirectToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view',
            }
        });
    }

    showToastOnError(error) {
        //console.warn(error);

         this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error,
            variant: 'error',
            mode: 'sticky'
        }));
        //this.showSpinner = false;
    }

    handleReset(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.redirectToRecordPage(this.recordId);
    }
    handleSuccess(event) {
        this.dispatchEvent(new CloseActionScreenEvent())
        // .then(() => {
        //     this.redirectToRecordPage(this.recordId);
        // })
        // .catch((error) => {
        //     this.showToastOnError(error);
        // });
    }


    handleSave(event) {
        this.getLatLongAndUpdate();


    }

    handleContactType(event){
        console.log('OUTPUT : event.detail.value ',event.detail.value);
        console.log('OUTPUT : event.detail.value ',event.target.value);
        var idx = event.target.dataset.index;
        if(event.detail.value =='New'){
            this.rows[idx].isNew = true;
            this.rows[idx].isExisting = false;
        }

         if(event.detail.value =='Existing'){
            this.rows[idx].isNew = false;
            this.rows[idx].isExisting = true;
        }
        this.rows[idx].contactType = event.detail.value;

        
    }

    handleInputChange(event) {
        var fieldName = event.target.dataset.id;
        this.Array[fieldName] = event.target.value;
        console.log('event.target.value; ', fieldName, this.Array[fieldName]);
        console.log(this.Array);
    }

    @track contactOptions = []; // Options for contacts
    @track rows = []; // Dynamic rows for attendee details

    rowIndex = 1; // Unique ID for each row

    // Fetch contacts for combobox
    getContactJS(val) {
        getContacts({ accId: val })
            .then((res) => {
                if (res) {
                    this.contactOptions = res.map(contact => ({
                        label: contact.Name,
                        value: contact.Id
                    }));
                } else if (error) {
                    console.error('Error fetching contacts: ', error);
                }
            })

    }
    // Add a new row
    addRow() {
        this.rows = [
            ...this.rows,
            {
                id: this.rowIndex++,
                contact: null,
                department: '',
                departmentId: '',
                description: '',
                followUpDate: '',
                contactType:null,
                isNew:false,
                isExisting:false,
                firstName:'',
                lastName:'',
                Mobile:'',
                Email:'',
            }
        ];
    }

    // Remove a row
    removeRow(event) {
        const rowId = event.target.dataset.id;
        this.rows = this.rows.filter(row => row.id != rowId);
    }

    // Handle input changes
    handleTableStandardInputChange(event) {
        const rowId = event.target.dataset.id;
        const field = event.target.dataset.field || 'contact';

        // Update the specific row data
        this.rows = this.rows.map(row => {
            if (row.id == rowId) {
                return { ...row, [field]: event.detail.value };
            }
            return row;
        });
        console.log('OUTPUT : ', JSON.stringify(this.rows));
    }
    handleDepartmenChange(event){
         var idx = event.target.dataset.index;
         console.log('OUTPUT : handleDepartmenChange ',JSON.stringify(event.detail.value));
         var s=event.detail.value;
         if(s.length ==0){
             this.rows[idx].departmentId = '';
         }
        s.forEach(currentItem => {
            this.rows[idx].departmentId = currentItem;
        });
        
        console.log('OUTPUT : ', JSON.stringify(this.rows));
    }


    // Handle input changes
    handleTableInputChange(event) {
        const rowId = event.target.dataset.id;
        const field = event.target.dataset.field || 'contact';

        // Update the specific row data
        this.rows = this.rows.map(row => {
            if (row.id == rowId) {
                return { ...row, [field]: event.target.value };
            }
            return row;
        });
        console.log('OUTPUT : ', JSON.stringify(this.rows));
    }


    handleContactInput(event) {
        console.log('OUTPUT : ', event.detail.value);
        console.log('OUTPUT : ', event.target.dataset.index);
        var conid = event.detail.value;
        var idx = event.target.dataset.index;
        getdepartment({ conId: event.detail.value })
            .then((res) => {
                console.log('OUTPUT : getdepartment', res);
                var result = JSON.parse(res);
                this.rows[idx].department = result.departmentName;
                this.rows[idx].departmentId = result.departmentId;
            })
        this.rows[idx].contact = event.detail.value;
        console.log('OUTPUT : ', JSON.stringify(this.rows));

    }


    // Save meeting details
    saveMeetingDetails(valeventId) {
        const allRowsValid = this.validateRows();

        if (allRowsValid) {
            this.showToast('Error', 'Please enter last name of contact', 'error');
            return;
        }

        if (this.validateStartdateenddate()) {
            this.showToast('Error', 'Follow-up date should be greater then today ', 'error');
            return;
        }


        saveMeetingAttendees({
            meetingDetails: this.rows,
            eventid: valeventId,
            accId: this.accountId
        })
            .then((res) => {
                if (res) {
                    this.showToast('Check-Out Successfully', '', 'success');
                    this.rows = []; // Clear rows after saving
                    this.addRow(); // Add an empty row for fresh input
                    this.redirectToRecordPage(this.recordId);
                } else {
                    this.showToast('Error', 'Something went wrong please try again later', 'error');
                }

            }).catch(error => {
                console.error('Error saving meeting attendees:', error);
                this.showToast('Error', 'Failed to save attendees.', 'error');
            });
    }

    // Validate rows
    validateRows() {
        return this.rows.every(row =>
            row.contactType=='New' && row.lastName ==''?true:false
        );

    }

    validateStartdateenddate() {
        return this.rows.every(row =>
            new Date(row.followUpDate) < new Date()
        );

    }

    // Show toast messages
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }


}