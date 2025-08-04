import { LightningElement, api } from 'lwc';
import lightningDatatable from 'lightning/datatable';
import picklishCustom from './picklishCustom.html'; // Your custom HTML template for the picklist

export default class CustomPicklist extends lightningDatatable {
    static customTypes = {
        picklist: {
            template: picklishCustom,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context']
        }
    };

    // Create a private variable for context
    contextValue;

    // Getter for the context property
    @api get context() {
        return this.contextValue;
    }

    // Setter for the context property
    set context(value) {
        this.contextValue = value; // Set context from parent
    }

    handleChange(event) {
        console.log('CHANGEEEE');
        const selectedValue = event.detail.value;

        // Dispatch an event with the new value and the context (row ID)
        const picklistChange = new CustomEvent('picklistchange', {
            detail: {
                value: selectedValue,
                context: this.contextValue // Use the private variable
            }
        });
        this.dispatchEvent(picklistChange);
    }
}