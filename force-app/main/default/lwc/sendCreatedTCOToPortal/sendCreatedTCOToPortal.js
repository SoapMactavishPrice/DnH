import { LightningElement, track, api, wire } from 'lwc';
import getTCOlineitems from "@salesforce/apex/TechCommOfferController.getTCOlineitems";
import syncTCO_ToNavision from "@salesforce/apex/EnquiryTriggerHandler.syncTCO_ToNavision";

export default class SendCreatedTCOToPortal extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api orderCreatedFrom;
    @track showSpinner = true;
    @track recTypeName = '';
    @track ResponseMessage = '';
    @track errorResponseMessage = '';
    @track TCOlineitems = [];
    
    connectedCallback() {
        setTimeout(() => {
            getTCOlineitems({
                tcoid: this.recordId
            }).then((data)=>{
                this.TCOlineitems = JSON.parse(data);
                console.log('data', this.TCOlineitems);
                window.open(this.TCOlineitems[0].Enquiry__r.Submit_URL__c, '_blank');
                this.showSpinner = false;
                history.replaceState(null, document.title, location.href);
                // this.handleAPICallout();
            })
        }, 1000);

    }

    handleAPICallout() {
        this.showSpinner = true;
        setTimeout(() => {
            console.log('this.recordId ', this.recordId);
            syncTCO_ToNavision({
                newEnquiryLineItems: this.TCOlineitems
            }).then((result) => {
                console.log('result ', result);
                this.showSpinner = false;
                this.ResponseMessage = result;
                // if(result!='false'){
                //     this.ResponseMessage=result;
                // }else{
                //     this.errorResponseMessage='Something went wrong , can you please try again.'
                // }
                console.log('ResponseMessage', this.ResponseMessage);
                console.log('errorResponseMessage', this.errorResponseMessage);

                const customEvent = new CustomEvent('getresponsemsg', {
                    detail: { resmsg: this.ResponseMessage } // Set the parameter in the detail object
                });
                this.dispatchEvent(customEvent);

                history.replaceState(null, document.title, location.href);
                // window.addEventListener('popstate', function () {
                //     history.pushState(null, document.title, location.href);
                // });
                //window.location.href=location.href;
                setTimeout(() => {
                    // this.closeModal();
                    // window.location.href = location.href;
                }, 1000);
            })
                .catch((error) => {
                    console.log('= erorr', error);
                    this.showSpinner = false;
                })
        }, 0);

    }

}