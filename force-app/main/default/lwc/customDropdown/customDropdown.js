import { LightningElement, api, track } from 'lwc';
// import getDropdownValues from '@salesforce/apex/BenefitAssignmentController.getDropdownValues';

export default class CustomDropdown extends LightningElement {

    @api
    get masterList() {
        return this._masterList;
    };
    set masterList(value) {
        let newValue = JSON.parse(JSON.stringify(value));

        this.selectedTitles = new Set();
        this.selectedIds = new Set();

        newValue.forEach(item => {
            if (item.isSelected) {
                if (item.title != 'Select All') {
                    this.selectedIds.add(item.id);
                    this.selectedTitles.add(item.title);
                }
            }
        });

        this.handlePlaceholder();

        this._masterList = JSON.parse(JSON.stringify(newValue));
        this.filteredList = JSON.parse(JSON.stringify(newValue));


    };

    @track filteredList = [];
    @track selectedTitles = new Set();

    @api selectedIds = new Set();
    @api objName;
    @api objApiName;
    @api isFirstDropdown;
    @api filterField;

    @track isDropdownVisible = false;


    @track placeHolder;
    iconName = 'utility:chevrondown';
    searchText = '';

    connectedCallback() {
        console.log('customDropdown connectedCallback');
        this.handlePlaceholder();
    }

    renderedCallback() {
        const firstDiv = this.template.querySelector('.firstDiv');
        const dropdownContent = this.template.querySelector('.dropdownContent');
        if (firstDiv) {
            if (dropdownContent) {
                dropdownContent.style.width = firstDiv.getBoundingClientRect().width + 'px';
            }
        }
    }

    handleSearch(event) {
        this.searchText = event.target.value;

        this.filteredList = [];
        if (this.searchText == '') {
            this.filteredList = this.masterList;
        }
        else {
            let isFirst = true;
            this.masterList.forEach(item => {
                if (item.id != 'selectAll') {
                    if (item.title.toLowerCase().includes(this.searchText.toLowerCase())) {
                        if (isFirst == true) {
                            this.filteredList.push({ id: 'selectAll', title: '', isSelected: false });
                            isFirst = false;
                        }
                        this.filteredList.push(item);
                    }
                }
            });
        }
        this.handleSelectAllCheckbox();
    }

    handleSelectItem(event) {
        if (event.currentTarget.dataset.id == 'selectAll') {
            this.handleMasterCheckbox(event);
        }
        else {
            let index = this.filteredList.map(object => object.id).indexOf(event.currentTarget.dataset.id);
            if (index != -1) {
                console.log(this.filteredList[index]);
                this.filteredList[index].isSelected = event.target.checked;
            }

            index = this.masterList.map(object => object.id).indexOf(event.currentTarget.dataset.id);
            if (index != -1) {
                console.log(this.masterList[index]);
                this.masterList[index].isSelected = event.target.checked;
                this.handleTitleAndIds(event, this.masterList[index]);
            }
        }

        this.handlePlaceholder();
        this.handleSelectAllCheckbox();

        console.log('selectedIds.length', Array.from(this.selectedIds).length);

        this.selectedIds.delete('selectAll');
        this.dispatchEvent(new CustomEvent('getselectedids', {
            detail: { allids: this.selectedIds }
        }));
    }

    handleDropdownClick() {
        console.log('handleDropdownClick', this.objApiName);
        if (this.isDropdownVisible) {
            this.isDropdownVisible = false;
            this.iconName = 'utility:chevrondown';
        }
        else {
            this.isDropdownVisible = true;
            this.iconName = 'utility:chevronup';

            // this.searchText = '';
            if (this.masterList != undefined || this.masterList != null)
                this.filteredList = this.masterList;

            /*
        const firstDiv = this.template.querySelector('.firstDiv');
        if (firstDiv) {
            this.template.querySelector('.dropdownContent').style.width = firstDiv.getBoundingClientRect().width + 'px';
        }
        */
        }
        console.log('dropdown name', this.objName);
        this.dispatchEvent(new CustomEvent('dropdownopenevent', {
            detail: this.objName
        }));
    }

    @api
    closeDropdown() {
        this.isDropdownVisible = false;
        this.iconName = 'utility:chevrondown';

        this.searchText = '';
        this.filteredList = this.masterList;
    }

    handleMasterCheckbox(event) {
        this.filteredList.forEach((item, index) => {
            if (item.id != 'selectAll') {
                this.filteredList[index].isSelected = event.target.checked;
                let i = this.masterList.map(object => object.id).indexOf(item.id);
                if (i != -1) {
                    this.masterList[i].isSelected = event.target.checked;
                    this.handleTitleAndIds(event, this.masterList[i]);
                }
            }
        });
    }

    handleSelectAllCheckbox() {
        if (this.filteredList.length > 0) {
            this.filteredList[0].isSelected = true;
            if (this.masterList.length == this.filteredList.length) {
                console.log(this.objName, 'handleSelectAllCheckbox Deselect All');
                this.filteredList[0].title = 'Deselect All';
            } else {
                console.log(this.objName, 'handleSelectAllCheckbox Deselect All Visible');
                this.filteredList[0].title = 'Deselect All Visible';
            }
        }
        for (let i = 0; i < this.filteredList.length; i++) {
            if (this.filteredList[i].id != 'selectAll') {
                if (this.filteredList[i].isSelected == false) {
                    this.filteredList[0].isSelected = false;
                    if (this.masterList.length == this.filteredList.length) {
                        console.log(this.objName, 'handleSelectAllCheckbox Select All');
                        this.filteredList[0].title = 'Select All';
                    } else {
                        console.log(this.objName, 'handleSelectAllCheckbox Select All Visible');
                        this.filteredList[0].title = 'Select All Visible';
                    }
                    break;
                }
            }
        }
        console.log(this.objName, 'handleSelectAllCheckbox first loop complete');
        this.filteredList.forEach(item => {
            if (item.id != 'selectAll') {
                if (item.isSelected == null || item.isSelected == undefined || item.isSelected == false) {
                    this.filteredList[0].isSelected = false;
                }
            }
        });
        console.log(this.objName, 'handleSelectAllCheckbox done');
    }

    handleTitleAndIds(event, obj) {
        if (obj.id != 'selectAll') {
            if (event.target.checked) {
                this.selectedTitles.add(obj.title);
                this.selectedIds.add(obj.id);
            }
            else {
                this.selectedTitles.delete(obj.title);
                this.selectedIds.delete(obj.id);
            }
        }
    }

    handlePlaceholder() {
        this.placeHolder = Array.from(this.selectedTitles).sort().join(', ');
        if (this.placeHolder == '')
            this.placeHolder = 'Select ' + this.objName;
    }

}