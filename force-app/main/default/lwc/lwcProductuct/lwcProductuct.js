import { LightningElement, api } from 'lwc';

export default class CustomPicklist extends LightningElement {
    @api value;  // The current value of the picklist
    @api options;  // The options for the picklist
    @api context;  // Context for the picklist to know which row is being edited

    handleChange(event) {
        const selectedValue = event.detail.value;
        
        // Dispatch an event with the new value and the context (row ID)
        const picklistChange = new CustomEvent('picklistchange', {
            detail: {
                value: selectedValue,
                context: this.context
            }
        });
        this.dispatchEvent(picklistChange);
    }
}