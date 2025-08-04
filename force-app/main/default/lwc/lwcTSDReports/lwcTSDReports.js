import { LightningElement, track } from 'lwc';

export default class LwcTSDReports extends LightningElement {

    @track isTab1Active = false;
    @track isTab2Active = false;
    @track isTab3Active = false;
    @track isTab4Active = false;
    @track isTab5Active = false;

    connectedCallback() {
        // this.isTab1Active = true;
    }

    handleTabChange(event) {

        // this.template.querySelectorAll('c-posted-invoice-report-l-w-c').forEach(child => {
        //     if (child.reset) {
        //         child.reset();
        //     }
        // });

        // Reset all tabs
        this.isTab1Active = false;
        this.isTab2Active = false;
        this.isTab3Active = false;
        this.isTab4Active = false;
        this.isTab5Active = false;

        // Activate the selected tab
        const selectedTabLabel = event.target.label;
        switch (selectedTabLabel) {
            case 'Posted Invoice':
                this.isTab1Active = true;
                break;
            case 'Credit Note':
                this.isTab2Active = true;
                break;
            case 'Sales Order Detail':
                this.isTab3Active = true;
                break;
            case 'Customer Ledger':
                this.isTab4Active = true;
                break;
            case 'Sales Register':
                this.isTab5Active = true;
                break;
            default:
                break;
        }
    }
}