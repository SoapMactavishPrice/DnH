import { LightningElement, api, wire,track } from 'lwc';
import getMeetingAttendees from '@salesforce/apex/lwcEventCheckInOutController.getMeetingAttendees';

const columns = [
    { label: 'Contact (Department)', fieldName: 'Contact_Name__c' },
    { label: 'Description', fieldName: 'Meeting_Description__c' },
    { label: 'Next follow-up', fieldName: 'formattedStartDate', type: 'text' },
];
export default class ShowMeetingAttendee extends LightningElement {
    @api recordId; // This will hold the meeting ID passed from the parent component or page
    attendees;
    error;
    columns = columns;
    @track isMobile = false;

    // @wire(getMeetingAttendees, { meetingId: '$recordId' })
    // wiredAttendees({ data, error }) {
    //     if (data) {
    //         this.attendees = data.map(item => {
    //             return {
    //                 ...item,
    //                 formattedStartDate: this.convertToLocalTime(item.Start_Date_Time__c),
    //                 formattedEndDate: this.convertToLocalTime(item.End_Date_Time__c)

    //             };
    //         });
    //         this.error = undefined;
    //     } else if (error) {
    //         this.error = error.body.message;
    //         this.attendees = undefined;
    //     }
    // }

    // Convert the date to local time
    convertToLocalTime(date) {
         // Ensure date is a Date object
        const localDate = new Date(date);

        // Format the date
        const formatter = new Intl.DateTimeFormat(navigator.language, {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
        });

        return formatter.format(localDate);
    }

    connectedCallback() {
         // Detect screen size
        this.isMobile = window.matchMedia('(max-width: 768px)').matches;
        this.fetchAttendeesJS();
    }
    fetchAttendeesJS(){
        // if(this.isMobile){
        //     getMeetingAttendees({meetingId:this.recordId})
        //     .then((res)=>{
        //         if (res) {
        //         this.attendees = res.map(item => {
        //             return {
        //                 ...item,
        //                 formattedStartDate:this.convertToLocalTime(item.Next_Follow_Up_Date__c),
        //             };
        //         });
        //         this.error = undefined;
        //     } else if (error) {
        //         this.error = error.body.message;
        //         this.attendees = undefined;
        //     }
        //     })
        // }else{
            getMeetingAttendees({meetingId:this.recordId})
            .then((res)=>{
                if (res) {
                this.attendees = res.map(item => {
                    return {
                        ...item,
                       formattedStartDate: item.Next_Follow_Up_Date__c,
                    //    formattedEndDate: this.convertToLocalTime(item.End_Date_Time__c)
                        //  formattedStartDate: item.Start_Date_Time__c,
                        //  formattedEndDate: item.End_Date_Time__c

                    };
                });
                this.error = undefined;
            } else if (error) {
                this.error = error.body.message;
                this.attendees = undefined;
            }
            })
        // }
        
    }


}