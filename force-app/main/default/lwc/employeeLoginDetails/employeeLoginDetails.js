import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertCheckIn from '@salesforce/apex/EmployeeLoginController.insertCheckIn';
import updateCheckOut from '@salesforce/apex/EmployeeLoginController.updateCheckOut';
import getEmployeeLoginDetails from '@salesforce/apex/EmployeeLoginController.getEmployeeLoginDetails'; // Apex method to get login details
import userId from '@salesforce/user/Id';  // Import the current user's ID

export default class EmployeeCheckOut extends LightningElement {
    @track checkInTime = 'Not checked in yet';  // Default value for check-in time
    @track checkOutTime = 'Not checked out yet';  // Default value for check-out time
    error;

    // Helper function to format date and time in DD/MM/YYYY HH:MM:SS
    formatDateTime(date) {
        if (!date) return 'Not checked in yet'; // Return default text if no date

        let d = new Date(date);
        let day = String(d.getDate()).padStart(2, '0');
        let month = String(d.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        let year = d.getFullYear();
        let hours = String(d.getHours()).padStart(2, '0');
        let minutes = String(d.getMinutes()).padStart(2, '0');
        let seconds = String(d.getSeconds()).padStart(2, '0');

        return `${day}/${month}/${year} ${hours}:${minutes}:${seconds}`;
    }

    // Wire method to get the employee login details
    // @wire(getEmployeeLoginDetails)
    // employeeLogin({ error, data }) {
    //     console.log('DATA:>> ', data);

    //     if (data) {
    //         // Set the Check-In and Check-Out times if the data is present
    //         this.checkInTime = data.Check_In_Time__c ? this.formatDateTime(data.Check_In_Time__c) : 'Not checked in yet';
    //         this.checkOutTime = data.Check_Out_Time__c ? this.formatDateTime(data.Check_Out_Time__c) : 'Not checked out yet';
    //     } else if (error) {
    //         this.error = error.body.message;
    //     }
    // }

    connectedCallback() {
        getEmployeeLoginDetails()
            .then(data => {
                console.log('DATA:>> ', data);
                // Set the Check-In and Check-Out times if the data is present
                this.checkInTime = data.Check_In__c ? this.formatDateTime(data.Check_In__c) : 'Not checked in yet';
                this.checkOutTime = data.Check_Out__c ? this.formatDateTime(data.Check_Out__c) : 'Not checked out yet';
            })
    }

    handleCheckOut() {
        const currentUserId = userId;

        // Check if Check-In time is available before proceeding to Check-Out
        if (this.checkInTime === 'Not checked in yet') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Check-In first before Check-Out.',
                    variant: 'error'
                })
            );
            return;
        }

        // Check if Check-Out time is already set
        if (this.checkOutTime !== 'Not checked out yet') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'You have already checked out today.',
                    variant: 'error'
                })
            );
            return;
        }

        updateCheckOut({ userId: currentUserId })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Check-Out successful.',
                        variant: 'success'
                    })
                );
                // Update the Check-Out time after successful check-out
                this.checkOutTime = this.formatDateTime(new Date()); // Update with current time formatted
            })
            .catch((error) => {
                this.error = error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: this.error,
                        variant: 'error'
                    })
                );
            });
    }

    handleCheckIn() {
        console.log('HIIIIIIIIIIII : ', this.checkInTime);

        // Check if Check-In is already done
        if (this.checkInTime != 'Not checked in yet') {
            this.dispatchEvent(
                new ShowToastEvent({
                    // title: 'Error',
                    message: 'You have already checked in today.',
                    variant: 'error'
                })
            );
            return;
        } else {
            insertCheckIn().then((result) => {
                console.log(result);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Check-In successful.',
                        variant: 'success'
                    })
                );
                // Update the Check-Out time after successful check-out
                this.checkInTime = this.formatDateTime(new Date()); // Update with current time formatted
            })
                .catch((error) => {
                    this.error = error.body.message;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: this.error,
                            variant: 'error'
                        })
                    );
                });
        }

        // Perform Check-In action (not implemented in this code, but this is where you'd call an Apex method)
        // After Check-In is successful, update checkInTime
        // this.checkInTime = this.formatDateTime(new Date()); // Update with current time formatted
        // this.dispatchEvent(
        //     new ShowToastEvent({
        //         title: 'Success',
        //         message: 'Check-In successful.',
        //         variant: 'success'
        //     })
        // );
    }
}