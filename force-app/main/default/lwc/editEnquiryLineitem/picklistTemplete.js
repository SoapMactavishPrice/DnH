import { LightningElement, api } from 'lwc';

export default class PicklistTemplete extends LightningElement {
    @api value;           // Current value of the picklist
    @api placeholder;     // Placeholder text
    @api options;         // Picklist options
    @api rowId;           // Unique ID for the row

    handlePicklistChange(event) {
        // Dispatch an event with the row ID and the new value
        console.log('CHANGEEEE');
        
        const picklistChangeEvent = new CustomEvent('picklistchange', {
            detail: {
                rowId: this.rowId,
                value: event.detail.value
            }
        });
        this.dispatchEvent(picklistChangeEvent);
    }
}