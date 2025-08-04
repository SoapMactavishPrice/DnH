import { LightningElement, api } from 'lwc';

export default class LwcCustomDatatable extends LightningDatatable {
    @api value;           // The current value of the picklist
    @api placeholder;     // Placeholder text for the combobox
    @api options;         // Options for the picklist
    @api rowId;           // Row ID to track which row is being edited

    handlePicklistChange(event) {
        // Dispatch an event to the parent datatable component with the new value
        const picklistChangeEvent = new CustomEvent('picklistchange', {
            detail: {
                rowId: this.rowId,
                value: event.detail.value
            }
        });
        this.dispatchEvent(picklistChangeEvent);
    }
}