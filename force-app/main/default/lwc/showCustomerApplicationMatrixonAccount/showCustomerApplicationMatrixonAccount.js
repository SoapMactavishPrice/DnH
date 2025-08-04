import { LightningElement, wire, track,api} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import modal from '@salesforce/resourceUrl/modalwidth';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomerApplicationMatrix from '@salesforce/apex/showCustomerApplicationMatrixonAccount.getCustomerApplicationMatrix';
import { CloseActionScreenEvent } from "lightning/actions";

const DELAY = 300;

const COLS = [
    { label: 'Sr.No.', fieldName: 'SrNo', type: 'text', initialWidth: 100, sortable: true },
    { label: 'Customer Application Matrix No', fieldName: 'purl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, initialWidth: 250, sortable: true },
    { label: 'Employee Name', fieldName: 'empName', type: 'text', initialWidth: 150, sortable: true },
    { label: 'Customer', fieldName: 'customer', type: 'text', initialWidth: 150, sortable: true },
    { label: 'Industry', fieldName: 'industry', type: 'Picklist', initialWidth: 150, sortable: true },
    { label: 'Department', fieldName: 'department', type: 'text', initialWidth: 150, sortable: true },
    { label: 'New Application', fieldName: 'newApplication', type: 'text', initialWidth: 150, sortable: true },
    { label: 'Application', fieldName: 'application', type: 'Picklist', initialWidth: 150, sortable: true },
    { label: 'Company Name', fieldName: 'companyName', type: 'Picklist', initialWidth: 150, sortable: true },
    { label: 'Product Brand', fieldName: 'productBrand', type: 'text', initialWidth: 150, sortable: true },
    { label: 'Product Category', fieldName: 'productCategory', cellAttributes: { alignment: 'left' }, initialWidth: 150, sortable: true },
    { label: 'Product Name', fieldName: 'productname', type: 'text', initialWidth: 150, sortable: true },
    { label: 'Product Size', fieldName: 'productSize', type: 'text', initialWidth: 150 ,sortable: true},
    { label: 'Alloy Kgs/Annum', fieldName: 'alloyKgsAnnum', type: 'text', initialWidth: 150 ,sortable: true},
    { label: 'Potential (Lakhs)', fieldName: 'potentialLakhs', type: 'text', initialWidth: 150 ,sortable: true},
    { label: 'Competitor Company Name', fieldName: 'competitorName', type: 'text', initialWidth: 150 ,sortable: true},
    { label: 'Competitor Product Brand', fieldName: 'competitorProductBrand', type: 'text', initialWidth: 250 ,sortable: true},
    { label: 'Competitor Product Category', fieldName: 'competitorProductCategory', type: 'text', initialWidth: 250,sortable: true },
    { label: 'Competitor Product Name', fieldName: 'competitorProductname', type: 'text', initialWidth: 250 ,sortable: true},
    { label: 'Competitor Product Size', fieldName: 'competitorProductSize', type: 'text', initialWidth: 250 ,sortable: true},
    { label: 'Competitor Alloy Kgs/Annum', fieldName: 'competitorAlloyKgsAnnum', type: 'text', initialWidth: 250,sortable: true },
    { label: 'Competitor Potential (Lakhs)', fieldName: 'competitorPotentialLakhs', type: 'text', initialWidth: 250,sortable: true }
];

export default class showCustomerApplicationMatrixonAccount extends NavigationMixin(LightningElement) {
   // @track recordId;
    @track sortBy;
    @track sortDirection;
    @track showTableProduct = [];
    @track totalRecords = 0;
    @track pageSizeOptions = [10, 25, 50, 75, 100];
    @track pageSize;
    @track totalPages;
    @track pageNumber = 1;
    @track records;



    cols = COLS;

    @api recordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
        console.log(this.recordId + ' in 0000000');
    }

    connectedCallback() {
        // Load modal styles
        this.getCustomerApplicationMatrix();
        loadStyle(this, modal)
            .then(() => {
                // Successfully loaded styles
                console.log('Modal styles loaded.');

            })
            .catch(error => {
                // Handle error loading styles
                console.error('Error loading modal styles: ', error);
            });
    }

 

    // handleRecordIdChange() {
    //     if (this.recordId) {
    //         this.getCustomerApplicationMatrix();
    //     }
    // }

    getCustomerApplicationMatrix() {
            getCustomerApplicationMatrix({ })
                .then(result => {
                    let data = JSON.parse(result);
                    console.log('data',data);
                    if (data.length === 0) {
                        this.ShowToastMessage('info', 'Customer Application Matrix Not Found');
                        this.closeQuickAction();
                    } else {
                        this.showTableProduct = data;
                        this.records = data ;
                        this.totalRecords = data.length;
                        this.pageSize = this.pageSizeOptions[0];
                        this.paginationHelper();
                    }
                })
                .catch(error => {
                    console.error('Error fetching data: ', error);
                    this.ShowToastMessage('error', 'Error fetching Customer Application Matrix');
                });
        
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.records));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.records = parseData;
        this.paginationHelper();
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        console.log('pageSize',this.pageSize);
        this.paginationHelper();
    }

    previousPage() {
        this.pageNumber--;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber++;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    paginationHelper() {
        let startIndex = (this.pageNumber - 1) * this.pageSize;
        // Slice the records to get the data for the current page
        this.showTableProduct = this.records.slice(startIndex, startIndex + this.pageSize);
        // Calculate the total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // Log the total pages
        console.log('totalPages', this.totalPages);
    }

    closeQuickAction() {
        // Close the quick action panel
        this.dispatchEvent(new CloseActionScreenEvent());

        // Navigate to the home page
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }

    ShowToastMessage(variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant,
                message: message,
                variant: variant,
            }),
        );
    }
}