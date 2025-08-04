import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

// import getCountryList from '@salesforce/apex/RoutePlannerController.getCountryList';
import getStateList from '@salesforce/apex/RoutePlannerController.getStateList';
import getCityList from '@salesforce/apex/RoutePlannerController.getCityList';
import getLocationList from '@salesforce/apex/RoutePlannerController.getLocationList';

import getEntityRecords from '@salesforce/apex/RoutePlannerController.getEntityRecords';
import updateEntities from '@salesforce/apex/RoutePlannerController.updateEntities';


export default class LwcRoutePlanner extends LightningElement {

    @api recordId;

    @track showSpinner;


    @track accessAllRecords = false;

    @track stateOptions;
    @track cityOptions;

    @track selectedEntityType = 'Account';
    @track isAccount;
    @track isLead;
    @track isAsset;

    @track selectedState;
    @track selectedCity;

    @track selectedPageSize = 10;


    masterList = [];
    filteredList = [];
    visibleList = [];

    @track hasDataInTable = false;
    @track isMasterCheckboxSelected;

    @track pageNo = 0;
    @track totalPages;

    @track columns;

    @track searchThrottlingTimeout;
    @track SEARCH_DELAY = 500;
    @track isLoading;




    get entityTypes() {
        return [{ value: 'Lead', label: 'Lead' }, { value: 'Account', label: 'Customer' }, { value: 'Asset', label: 'Asset' }];
    }

    get pageSizeOptions() {
        return [{ value: '10', label: '10' }, { value: '20', label: '20' }, { value: '30', label: '30' }];
    }


    connectedCallback() {
        this.accessAllRecords = false;
        this.selectedEntityType = 'Account';
        this.isAccount = true;

        this.getStateList();
    }



    handleEntityChange = (event) => {
        this.selectedEntityType = event.currentTarget.value;

        if (this.selectedEntityType == 'Account') {
            this.isLead = false;
            this.isAccount = true;
            this.isAsset = false;
        }
        else if (this.selectedEntityType == 'Lead') {
            this.isLead = true;
            this.isAccount = false;
            this.isAsset = false;
        }
        else if (this.selectedEntityType == 'Asset') {
            this.isLead = false;
            this.isAccount = false;
            this.isAsset = true;
        }

        this.stateOptions = [];
        this.cityOptions = [];
        this.locationOptions = [];

        this.selectedState = null;
        this.selectedCity = null;
        this.selectedLocation = null;

        this.accessAllRecords = false;

        this.masterList = [];
        this.filteredList = [];
        this.visibleList = [];

        this.hasDataInTable = this.masterList.length > 0;

        this.getStateList();
    }


    /*
    getCountryList = (event) => {
        new Promise((resolve, reject) => {
            setTimeout(() => {
                getCountryList({
                    accessAllRecords: this.accessAllRecords,
                    entityType: this.selectedEntityType
                })
                    .then((data) => {
                        this.countryOptions = JSON.parse(data);
                        this.selectedCountry = 'India';

                        this.getStateList();
                    })
                    .catch((error) => {
                        this.showToastOnError(error);
                    });
            }, 0);
        });
    }
*/


    getStateList = (event) => {
        this.showSpinner = true;
        new Promise((resolve, reject) => {
            setTimeout(() => {
                getStateList({
                    accessAllRecords: this.accessAllRecords,
                    entityType: this.selectedEntityType
                })
                    .then((data) => {
                        console.log('stateList', data);
                        this.stateOptions = JSON.parse(data);
                        console.log('stateList', this.stateOptions);

                        this.selectedState = '--None--';

                        this.showSpinner = false;
                    })
                    .catch((error) => {
                        this.showToastOnError(error);
                    });
            }, 0);
        });
    }

    handleStateChange = (event) => {
        this.selectedState = event.currentTarget.value;

        this.masterList = [];
        this.filteredList = [];
        this.visibleList = [];
        this.hasDataInTable = this.masterList.length > 0;

        this.selectedCity = null;
        this.selectedLocation = null;

        this.getEntityRecords();
        this.getCityList();
        this.getLocationList();
    }


    getCityList = (event) => {
        if (this.selectedState == 'None') {
            this.cityOptions = [];
            this.locationOptions = [];

            this.selectedCity = null;
            this.selectedLocation = null;

            this.masterList = [];
            this.filteredList = [];
            this.visibleList = [];

            this.hasDataInTable = this.masterList.length > 0;
            return;
        }

        new Promise((resolve, reject) => {
            setTimeout(() => {
                getCityList({
                    accessAllRecords: this.accessAllRecords,
                    entityType: this.selectedEntityType,
                    stateName: this.selectedState
                })
                    .then((data) => {
                        console.log('cityList', data);
                        this.cityOptions = JSON.parse(data);
                        console.log('cityList', this.cityOptions);
                    })
                    .catch((error) => {
                        this.showToastOnError(error);
                    });
            }, 0);
        });
    }

    handleCityChange = (event) => {
        this.selectedCity = event.currentTarget.value;

        this.masterList = [];
        this.filteredList = [];
        this.visibleList = [];
        this.hasDataInTable = this.masterList.length > 0;

        this.selectedLocation = null;

        this.getEntityRecords();
        if (this.isAsset) {
            this.getLocationList();
        }
    }


    getLocationList = (event) => {
        if (this.isAsset) {
            new Promise((resolve, reject) => {
                setTimeout(() => {
                    getLocationList({
                        accessAllRecords: this.accessAllRecords,
                        entityType: this.selectedEntityType,
                        stateName: this.selectedState,
                        cityName: this.selectedCity
                    })
                        .then((data) => {
                            this.locationOptions = JSON.parse(data);

                            this.getEntityRecords();
                        })
                        .catch((error) => {
                            this.showToastOnError(error);
                        });
                }, 0);
            });
        }
    }


    handleLocationChange = (event) => {
        this.selectedLocation = event.currentTarget.value;

        this.getEntityRecords();
    }


    handleAccessLevelChange = (event) => {
        this.accessAllRecords = event.currentTarget.checked;

        this.getStateList();
        this.getCityList();
        this.getLocationList();

        this.getEntityRecords();
    }


    getEntityRecords = (event) => {
        this.showSpinner = true;
        new Promise((resolve, reject) => {
            setTimeout(() => {
                getEntityRecords({
                    recordId: this.recordId,
                    accessAllRecords: this.accessAllRecords,
                    entityType: this.selectedEntityType,
                    stateName: this.selectedState,
                    cityName: this.selectedCity,
                    locationName: this.selectedLocation
                })
                    .then((data) => {
                        this.masterList = data;

                        this.setDefaultView();

                        this.showSpinner = false;
                    })
                    .catch((error) => {
                        this.showToastOnError(error);
                    })
            }, 0);
        });
    }


    setDefaultView = (event) => {
        this.assignColumnNames();

        this.pageNo = 0;

        this.filteredList = this.masterList;

        if (this.filteredList.length >= this.selectedPageSize)
            this.visibleList = this.filteredList.slice(0, this.selectedPageSize);
        else
            this.visibleList = this.filteredList;

        this.hasDataInTable = this.masterList.length > 0;

        this.decideFirstLastPage();
    }


    handlePageSizeChange = (event) => {
        this.selectedPageSize = event.currentTarget.value;

        this.totalPages = Math.floor(this.filteredList.length / this.selectedPageSize);

        this.populateDataAccordingToPagination();
    }


    handleSearch = (event) => {
        if (this.searchThrottlingTimeout)
            clearTimeout(this.searchThrottlingTimeout);

        const searchKeyword = event.target.value.trim().replace(/\*/g, '').toLowerCase();

        if (searchKeyword == '' || searchKeyword == null || searchKeyword == undefined) {
            this.filteredList = this.masterList;
            this.pageNo = 0;
            this.decideFirstLastPage();
            this.populateDataAccordingToPagination();
        }
        else {
            this.searchThrottlingTimeout = setTimeout(() => {
                this.isLoading = true;

                this.filteredList = this.masterList.filter(function (result) {
                    if (result.Id && result.Id.toLowerCase().includes(searchKeyword))
                        return true;
                    if (result.Column1 && result.Column1.toLowerCase().includes(searchKeyword))
                        return true;
                    if (result.Column2 && result.Column2.toLowerCase().includes(searchKeyword))
                        return true;
                    if (result.Column3 && result.Column3.toLowerCase().includes(searchKeyword))
                        return true;
                    if (result.Column4 && result.Column4.toLowerCase().includes(searchKeyword))
                        return true;
                    if (result.Column5 && result.Column5.toLowerCase().includes(searchKeyword))
                        return true;
                    if (result.Column6 && result.Column6.toLowerCase().includes(searchKeyword))
                        return true;
                    if (result.Column7 && result.Column7.toLowerCase().includes(searchKeyword))
                        return true;
                    if (result.Column8 && result.Column8.toLowerCase().includes(searchKeyword))
                        return true;
                });

                this.pageNo = 0;

                this.decideFirstLastPage();
                this.populateDataAccordingToPagination();

                this.isLoading = false;
            }, this.SEARCH_DELAY);
        }
    }


    handleRowSelect = (event) => {
        this.visibleList[event.currentTarget.dataset.index].isSelected = event.target.checked;

        let filterIndex = this.filteredList.map(object => object.Id).indexOf(event.currentTarget.dataset.id);
        this.filteredList[filterIndex].isSelected = event.target.checked;

        let masterIndex = this.masterList.map(object => object.Id).indexOf(event.currentTarget.dataset.id);
        this.masterList[masterIndex].isSelected = event.target.checked;

        /*
        let visibleCount = 0;
        this.visibleList.forEach(item => {
            if (item.isSelected)
                visibleCount += 1;
        });
        let filterCount = 0;
        this.filteredList.forEach(item => {
            if (item.isSelected)
                filterCount += 1;
        });
        let masterCount = 0;
        this.masterList.forEach(item => {
            if (item.isSelected)
                masterCount += 1;
        });
        console.log('visibleCount - ' + visibleCount + ' --------- ' + 'filterCount - ' + filterCount + ' --------- ' + 'masterCount - ' + masterCount);
*/
        this.handleMasterCheckboxOnPageChange();
    }


    handlePrevClick = (event) => {
        /*
        if (this.isFirstPage) {
            return;
        }
        else {
*/

        this.pageNo -= 1;
        this.decideFirstLastPage();
        this.populateDataAccordingToPagination();

        /*
        let selectedRows = [];
        this.visibleList.forEach(item => {
            if (item.isSelected)
                selectedRows.push({ Id: item.Id });
        });

        if (selectedRows.length > 0) {
            this.showSpinner = true;

            new Promise((resolve, reject) => {
                setTimeout(() => {
                    updateEntities({
                        entityType: this.selectedEntityType,
                        routeMapperId: this.recordId,
                        selectedRows: JSON.stringify(selectedRows)
                    })
                        .then((data) => {
                            this.pageNo -= 1;
                            this.decideFirstLastPage();
                            this.populateDataAccordingToPagination();

                            this.showSpinner = false;
                        })
                        .catch((error) => {
                            this.showToastOnError(error);
                        })
                });
            });
        }
        else {
            this.pageNo -= 1;
            this.decideFirstLastPage();
            this.populateDataAccordingToPagination();
        }
*/
    }


    handleNextClick = (event) => {
        /*
        if (this.isLastPage) {
            return;
        }
        else {
*/

        this.pageNo += 1;
        this.decideFirstLastPage();
        this.populateDataAccordingToPagination();

        /*
        let selectedRows = [];
        this.visibleList.forEach(item => {
            if (item.isSelected)
                selectedRows.push({ Id: item.Id });
        });

        if (selectedRows.length > 0) {
            this.showSpinner = true;

            new Promise((resolve, reject) => {
                setTimeout(() => {
                    updateEntities({
                        entityType: this.selectedEntityType,
                        routeMapperId: this.recordId,
                        selectedRows: JSON.stringify(selectedRows)
                    })
                        .then((data) => {
                            this.pageNo += 1;
                            this.decideFirstLastPage();
                            this.populateDataAccordingToPagination();

                            this.showSpinner = false;
                        })
                        .catch((error) => {
                            this.showToastOnError(error);
                        })
                });
            });
        }
        else {
            this.pageNo += 1;
            this.decideFirstLastPage();
            this.populateDataAccordingToPagination();
        }
*/
    }


    decideFirstLastPage = (event) => {
        this.totalPages = Math.floor(this.filteredList.length / this.selectedPageSize);

        let upperBound = (this.pageNo * this.selectedPageSize) + this.selectedPageSize;
        upperBound = upperBound < this.filteredList.length ? upperBound : this.filteredList.length;
        this.paginationString = ((this.pageNo * this.selectedPageSize) + 1) + '-' + upperBound +
            ' | Page ' + (this.pageNo + 1) + ' of ' + (this.totalPages + 1);

        if (this.pageNo == 0) {
            if (this.pageNo == this.totalPages) {
                this.isFirstPage = true;
                this.isLastPage = true;
            } else {
                this.isFirstPage = true;
                this.isLastPage = false;
            }
        }
        else if (this.pageNo < this.totalPages) {
            this.isFirstPage = false;
            this.isLastPage = false;
        }
        else if (this.pageNo == this.totalPages) {
            this.isFirstPage = false;
            this.isLastPage = true;
        }
    }


    populateDataAccordingToPagination = (event) => {
        this.visibleList = [];

        if (this.pageNo > this.totalPages) {
            this.pageNo = this.totalPages;
        }
        const startIndex = this.pageNo * this.selectedPageSize;
        const endIndex = (startIndex + this.selectedPageSize) > this.filteredList.length ? this.filteredList.length : (startIndex + this.selectedPageSize);
        this.visibleList = JSON.parse(JSON.stringify(this.filteredList.slice(startIndex, endIndex)));

        this.handleMasterCheckboxOnPageChange();
    }


    handleMasterCheckboxOnPageChange = (event) => {
        this.isMasterCheckboxSelected = null;
        let allRowsChecked = true;
        for (let i = 0; i < this.visibleList.length; i++) {
            if (this.visibleList[i].isSelected) {

            } else {
                allRowsChecked = false;
                break;
            }
        }
        this.isMasterCheckboxSelected = allRowsChecked;
    }


    handleMasterCheckboxClick = (event) => {
        this.isMasterCheckboxSelected = event.target.checked;
        this.visibleList.forEach(item => {
            item.isSelected = this.isMasterCheckboxSelected;

            let filterIndex = this.filteredList.map(object => object.Id).indexOf(item.Id);
            this.filteredList[filterIndex].isSelected = event.target.checked;

            let masterIndex = this.masterList.map(object => object.Id).indexOf(item.Id);
            this.masterList[masterIndex].isSelected = event.target.checked;
        });

        /*
        let visibleCount = 0;
        this.visibleList.forEach(item => {
            if (item.isSelected)
                visibleCount += 1;
        });
        let filterCount = 0;
        this.filteredList.forEach(item => {
            if (item.isSelected)
                filterCount += 1;
        });
        let masterCount = 0;
        this.masterList.forEach(item => {
            if (item.isSelected)
                masterCount += 1;
        });
        console.log('visibleCount - ' + visibleCount + ' --------- ' + 'filterCount - ' + filterCount + ' --------- ' + 'masterCount - ' + masterCount + ' --------- handleMasterCheckboxClick');
        */
    }


    handleFooterAction = (event) => {
        if (event.currentTarget.dataset.action == 'Cancel') {
            this.visibleList.forEach(item => {
                item.isSelected = false;
            });
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        else if (event.currentTarget.dataset.action == 'Save') {
            let selectedRows = [];
            let notSelectedRows = [];
            for (let i = 0; i < this.masterList.length; i++) {
                console.log(i, '->', this.masterList[i]);
                if (this.masterList[i].isSelected)
                    selectedRows.push(this.masterList[i].Id);
                else
                    notSelectedRows.push(this.masterList[i].Id);
            };

            console.log('selectedRows', selectedRows);
            console.log('notSelectedRows', notSelectedRows);

            this.showSpinner = true;

            new Promise((resolve, reject) => {
                setTimeout(() => {
                    updateEntities({
                        entityType: this.selectedEntityType,
                        routeMapperId: this.recordId,
                        selectedRows: JSON.stringify(selectedRows),
                        notSelectedRows: JSON.stringify(notSelectedRows)
                    })
                        .then((data) => {
                            this.showSpinner = false;
                            this.dispatchEvent(new CloseActionScreenEvent());
                        })
                        .catch((error) => {
                            this.showToastOnError(error);
                        })
                });
            });
        }
    }


    assignColumnNames = () => {
        switch (this.selectedEntityType) {
            case 'Account': {
                this.columns = [
                    { index: 'Column1', label: 'Name' },
                    { index: 'Column2', label: 'Street' },
                    { index: 'Column3', label: 'City' },
                    { index: 'Column4', label: 'Pin Code' },
                    { index: 'Column5', label: 'Owner Name' }
                ];
                break;
            }
            case 'Lead': {
                this.columns = [
                    { index: 'Column1', label: 'Name' },
                    { index: 'Column2', label: 'Account Name' },
                    { index: 'Column3', label: 'Site Location' },
                    { index: 'Column4', label: 'Street' },
                    { index: 'Column5', label: 'City' },
                    { index: 'Column6', label: 'Product Name' },
                    { index: 'Column7', label: 'Owner Name' }
                ];
                break;
            }
            case 'Asset': {
                this.columns = [
                    { index: 'Column1', label: 'Name' },
                    { index: 'Column2', label: 'Email' },
                    { index: 'Column3', label: 'Street' },
                    { index: 'Column4', label: 'Site Location' },
                    { index: 'Column5', label: 'City' },
                    { index: 'Column6', label: 'Product Name' },
                    { index: 'Column7', label: 'Owner Name' }
                ];
                break;
            }
        }
    }



    showToastOnError(error) {
        console.log(error);

        let msg;
        if (error.message)
            msg = error.message;
        else if (error.body.message)
            msg = error.body.message;

        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error',
            mode: 'sticky'
        }));

        this.showSpinner = false;
    }


}