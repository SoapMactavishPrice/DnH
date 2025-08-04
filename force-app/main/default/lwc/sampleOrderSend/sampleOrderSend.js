import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import insertSampleSalesOrderToTSD from '@salesforce/apex/CreateSampleRequest_ToTSDportal.insertSampleSalesOrderToTSD';
// import insertSampleSalesOrderToNav from '@salesforce/apex/CreateSampleRequest_ToNav.insertSampleSalesOrderToNav';


export default class SampleOrderSend extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api orderCreatedFrom;
    @track showSpinner = true;
    @track recTypeName = '';
    @track ResponseMessage = '';
    @track ResponseMessage2 = '';
    @track errorResponseMessage = '';

    @track isMobile = false;
    connectedCallback() {
        if (window.innerWidth <= 768) {
            this.isMobile = true;
            this.showSpinner=false
        } else {
            setTimeout(() => {
                this.handleAPICallout();
                // this.handlerSendToNav();
            }, 2000);
        }
        
    }

    // handlerSendToNav() {
    //     new Promise((resolve, reject) => {
    //         insertSampleSalesOrderToNav({
    //             SoId: this.recordId,
    //         }).then((result) => {
    //             console.log('insertSampleSalesOrderToNav result:>> ', result);
    //             this.showSpinner = false;
    //             // if(result=='1'){

    //             // }else{
    //             //     this.errorResponseMessage=result;
    //             // }
    //             // if (result == '') {

    //             //     this.ResponseMessage = 'Approved';
    //             // } else {

    //             //     this.ResponseMessage = result;
    //             // }
    //             this.ResponseMessage = result;



    //             history.replaceState(null, document.title, location.href);
    //             resolve(result);
    //         }).catch((error) => {
    //             console.log('= erorr', error);
    //             this.showSpinner = false;
    //         });
    //     }).then(() => {
    //         setTimeout(() => {
    //             if (this.ResponseMessage.includes('SMO')) {
    //                 this.handleAPICallout();
    //             }
    //         }, 1000);
    //     })
    // }

    handleAPICallout() {
        this.showSpinner = true;
        setTimeout(() => {
            console.log('this.recordId ', this.recordId);
            insertSampleSalesOrderToTSD({
                SoId: this.recordId,
            }).then((result) => {
                console.log('result ', result);
                this.showSpinner = false;
                // if(result=='1'){

                // }else{
                //     this.errorResponseMessage=result;
                // }
                // if (result == '') {

                //     this.ResponseMessage = 'Approved';
                // } else {

                //     this.ResponseMessage = result;
                // }
                this.ResponseMessage2 = result;
                history.replaceState(null, document.title, location.href);
                this.closeModal();
            }).catch((error) => {
                console.log('= erorr', error);
                this.showSpinner = false;
            })
        }, 0);

    }

    // closeModal(event) {
    //     this.dispatchEvent(new CloseActionScreenEvent());
    // }

    closeModal() {
        const responseEvent = new CustomEvent('sendsampleorder', {
            detail: {
                value: this.ResponseMessage2
            }
        });
        this.dispatchEvent(responseEvent);
    }

}