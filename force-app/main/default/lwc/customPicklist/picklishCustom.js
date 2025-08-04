import { LightningElement, api } from 'lwc';

export default class PicklishCustom extends LightningElement {
    @api typeAttributes; // Expected to be an object with value, placeholder, options, and context

    handlePicklistChange(event) {
        console.log('CHANGEEEE');
        const selectedValue = event.detail.value; // Get the selected value
        const context = this.typeAttributes.context; // Retrieve context

        // Dispatch a custom event to notify the parent component
        const picklistChange = new CustomEvent('picklistchange', {
            detail: {
                value: selectedValue,
                context: context // Send the context along with the value
            }
        });
        
        this.dispatchEvent(picklistChange); // Dispatch the event
    }
}