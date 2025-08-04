import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getDetails from '@salesforce/apex/IntegrationHandler.getDetails';
export default class SendAccount extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    @track recTypeName = '';
    @track ResponseMessage = '';
    @track errorResponseMessage = '';

    connectedCallback() {
        setTimeout(() => {
            this.handleAPICallout();
        }, 2000);
    }


    handleAPICallout() {
        this.showSpinner = true;
        setTimeout(() => {
            console.log('this.recordId ', this.recordId);
            getDetails({
                accId: this.recordId,
            }).then((result) => {
                console.log('result ', result);
                this.showSpinner = false;
                if(result=='1'){
                    this.ResponseMessage = 'Customer created successfully';
                }else{
                    this.errorResponseMessage=result;
                }
               
                history.replaceState(null, document.title, location.href);
            })
                .catch((error) => {
                    console.log('= erorr', error);
                    this.showSpinner = false;
                })
        }, 0);

    }

    closeModal(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}