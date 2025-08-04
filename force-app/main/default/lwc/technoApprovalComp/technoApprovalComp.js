import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import sendForApproval from '@salesforce/apex/IntegrationHandler.sendForApproval';
export default class TechnoApprovalComp extends LightningElement {
     @api recordId;
    @api objectApiName;
    @track showSpinner = true;
    @track recTypeName = '';
    @track ResponseMessage = '';
    @track errorResponseMessage = '';

    connectedCallback() {
        setTimeout(() => {
            this.handleAPICallout();
            // this.showSpinner = false;
            // this.ResponseMessage = 'HEHEHE';
            
        }, 2000);
    }


    handleAPICallout() {
        this.showSpinner = true;
        setTimeout(() => {
            console.log('this.recordId ', this.recordId);
            sendForApproval({
                tcoId: this.recordId,
            }).then((result) => {
                console.log('result ', result);
                this.showSpinner = false;
                // if(result=='1'){
                    
                // }else{
                //     this.errorResponseMessage=result;
                // }
                if (result == '') {
                    
                    this.ResponseMessage = 'TCO has been sent to Shivi for Approval';
                } else {
                    
                    this.ResponseMessage = result;
                }

                const customEvent = new CustomEvent('getresponsemsg', {
                    detail: { resmsg: this.ResponseMessage } // Set the parameter in the detail object
                });
                this.dispatchEvent(customEvent);
               
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