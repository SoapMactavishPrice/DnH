import { LightningElement, track, api, wire } from 'lwc';
import APIcalloutSalesOrder from '@salesforce/apex/IntegrationHandler.insertStandardSalesOrder';
import getRecType from '@salesforce/apex/IntegrationHandler.getRecType';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class SaleOrderSend extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api orderCreatedFrom;
    @api salesDocNo;
    @track showSpinner = true;
    @track recTypeName = '';
    @track ResponseMessage = '';
    @track errorResponseMessage = '';

    connectedCallback() {
        setTimeout(() => {

            console.log('this.recordId ', this.recordId);
            new Promise((resolve, reject) => {
                getRecType({
                    SoId: this.recordId
                }).then((data) => {
                    this.recTypeName = data;
                    console.log(this.recTypeName);
                    resolve('ok');
                })
            }).then(() => {
                if (this.salesDocNo != null && this.salesDocNo.includes('SOB/')) {
                    console.log('CHILD COMP');
                    
                    this.ResponseMessage = this.salesDocNo;
                    const customEvent = new CustomEvent('directtsdcallout', {
                        detail: { resmsg: this.ResponseMessage } // Set the parameter in the detail object
                    });
                    this.dispatchEvent(customEvent);
                    this.showSpinner = false;
                } else {
                    this.handleAPICallout();
                }
            }).catch((error) => {
                console.log('error ', error);
            })
        }, 2500);
    }


    handleAPICallout() {
        this.showSpinner = true;
        setTimeout(() => {
            console.log('this.recordId ', this.recordId);
            APIcalloutSalesOrder({
                SoId: this.recordId,
                rectype: this.recTypeName == 'Normal Enquiry' ? '2' : '1'
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

    closeModal(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}