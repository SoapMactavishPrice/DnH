import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import updateCheckIn from '@salesforce/apex/lwcEventCheckInOutController.updateCheckIn';
import
getEventById
    from
    '@salesforce/apex/lwcEventCheckInOutController.getEventById'
    ;

export default class LwcEventCheckIn extends NavigationMixin(LightningElement) {

    @api recordId;
    @track latitude = '';
    @track longitude = '';
    @track mapMarkers = null; // Stores map markers
    @track center = null; // Stores center coordinates for the map
    @track showSpinner = true;
    @track showMap = false;

    connectedCallback() {
        console.log('recordId', this.recordId);
        // Fetch the event record details first
        getEventById({ recordId: this.recordId })
            .then(result => {
                console.log('OUTPUT : ',JSON.stringify(result));
                if (result.Check_In_Time__c!=null && result.Check_In_Time__c!='') {
                    this.showToastOnError('Check-In already completed. You cannot check in again.');
                    this.showSpinner = false;
                    this.redirectToRecordPage(this.recordId);
                    return;
                }else{
                      // If check-in is allowed, proceed with update
                      this.getLatLongAndUpdate();
                }
              

            })
            .catch(error => {
                this.showToastOnError(error);
                this.showSpinner = false;
            });
        
    }

    showToastOnError(error) {
        console.warn(error);

        let msg;
        if (error.message)
            msg = error.message;
        else if (error.body?.message)
            msg = error.body.message;
        else
            msg = error;

        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error',
            mode: 'sticky'
        }));

        this.showSpinner = false;
    }

    getLatLongAndUpdate() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                this.latitude = position.coords.latitude;
                this.longitude = position.coords.longitude;
                console.log('qwertyui', this.latitude);

                //Set mapMarkers and center for the lightning-map component
                this.mapMarkers = [
                    {
                        location: {
                            Latitude: this.latitude,
                            Longitude: this.longitude,
                        },
                        title: 'You Are Here',
                        description: 'This is your current location.',
                    },
                ];

                this.center = {
                    Latitude: this.latitude,
                    Longitude: this.longitude,
                };

                setTimeout(() => {
                    this.showMap = true;
                    this.showSpinner = false;
                    console.log('showSpinner call : ');
                }, 2000); // Simulate a 2-second delay
            });
        }
        else {
            this.showToastOnError('Location permission is not available');
        }
    }

    handleConfirm() {
        updateCheckIn({
            recordId: this.recordId,
            latitude: this.latitude,
            longitude: this.longitude
        }).then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Check-In Successfully',
                message: '',
                variant: 'Success'
            }));
            this.redirectToRecordPage(this.recordId);
        }).catch((error) => {
            this.showToastOnError(error);
        });
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


}