import { LightningElement, wire, track } from 'lwc';
import findProducts from '@salesforce/apex/AddProductPageEnq.findProduct';
import getProducts from '@salesforce/apex/AddProductPageEnq.getProducts';
import findRecentenqlineitem from '@salesforce/apex/AddProductPageEnq.findRecentenqlineitem';
import getproductfamily from '@salesforce/apex/AddProductPageEnq.getproductfamily';
import getItemCategory from '@salesforce/apex/AddProductPageEnq.getItemCategory';
import saveProducts from '@salesforce/apex/AddProductPageEnq.saveProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
const DELAY = 300;


const COLS = [
{ label: 'Item Name', fieldName: 'purl', type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
{ label: 'Item Code', fieldName: 'ProductCode', type: 'text' },
{ label: 'Item Category', fieldName: 'Itemcategory',type: 'Picklist' },
// { label: 'HSN Master', fieldName: 'hsnMasterCode', type: 'text' },
{ label: 'Product Series', fieldName: 'Family', type: 'text' },
//{ label: 'Product Main Group', fieldName: 'ProductMainGroup', type: 'Picklist' },
//{ label: 'Pack Size', fieldName: 'PackSize', type: 'text' },
//{ label: 'List Price', fieldName: 'Price', type: 'currency', cellAttributes: { alignment: 'left' } },
{ label: 'Item Description', fieldName: 'Description', type: 'text' }

];

const COLS1 = [
    { label: 'Customer', fieldName: 'EnquiryAccount' },
    { label: 'Enquiry Name', fieldName: 'EqName' },
    { label: 'Enquiry', fieldName: 'EnquiryName' },
    { label: 'Quantity', fieldName: 'Qty__c' },
    { label: 'Sales Price', fieldName: 'Sales_Price__c' }
];


import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class AddProductPageEnq extends NavigationMixin(LightningElement) {
cols = COLS;
@track cols1 = COLS1;

@track recId;
@wire(CurrentPageReference)
setCurrentPageReference(currentPageReference) {
    //console.log('currentPageReference', currentPageReference);
    //console.log('state', currentPageReference.attributes.attributes);
    this.currentPageReference = currentPageReference.state.c__refRecordId;
    //console.log('this.currentPageReference', this.currentPageReference.c__refRecordId);
    if (this.currentPageReference) {
        this.recId = this.currentPageReference;
        console.log('Enq Id', this.recId);
    }
}

@track SelectedRecordCount = 0;
@track isModalOpen = false;
@track ShowSelected = true;
@track PriceBook = '';
@track ShowTableData = [];
@track ShowTableData1 = [];

@track selectedProductCode = [];
@track AllProductData = [];
@track SelectedProductData = [];
@track lstResult = [];
@track hasRecords = true;
@track searchKey = '';
@track isSearchLoading = false;
@track delayTimeout;
@track isFirstPage = true;
@track isSecondPage = false;
@track selectedRows = [];
@track ShowViewAll = false;
@track datafilterval = false;
@track prodfamilylst = [];
@track prodMainGroup = [];
@track ItemBrand = [];   
@track itemcategory = [];
@track taxcode =[];
@track ValuesIn=[];
 @track FilterForm = { "ProductFamily": "", "ItemCategory": "","ItemBrand": "" };
    
@track isProductSelect = true;
mapIdQuantity;
mapIdSalesPrice;
mapIdDate;
mapIdDiscount;
mapIdLineDescription;
mapIdtaxcode;
mapIdAdditionalcost;
mapIdPackingcost;
@track showErrorMsg = false;
@track filteredData = [];
@track DisableNext = true;
@track showPopup = false;
@track selectedProductId;
@track showrecentEnqItems = [];


connectedCallback() {
    this.mapIdQuantity = new Map();
    this.mapIdSalesPrice = new Map();
    this.mapIdDate = new Map();
    this.mapIdDiscount = new Map();
    this.mapIdAdditionalcost = new Map();
    this.mapIdPackingcost = new Map();
    this.mapIdLineDescription = new Map();
    this.mapIdtaxcode = new Map();

    this.ShowTableData = [];
    this.ShowTableData = [];
    this.selectedProductCode = [];
    this.AllProductData = [];
    this.SelectedProductData = [];
    this.isModalOpen = true;
    console.log('connected call back called');
    

    this.getproductfamily();

    this.openModal();
 
    
}

getproductfamily() {
    //this.isModalOpen = true;
    getproductfamily().then(result => {

        for (let key in result) {
            if (key == 'Family') {
                this.prodfamilylst = result['Family'];
            } else if (key == 'ItemCategory') {
                this.ItemCategory = result['ItemCategory'];
            } else if(key == 'ItemBrand'){
                this.ItemBrand = result['ItemBrand'];
            }
        }
        


});
}get options() {
return this.prodfamilylst;
}

get options1() {
return this.prodMainGroup;
}

get options2() {
return this.prodSubGroup;
}
@track disabledApplayButton = true;
handleChange(event) {
    console.log('name', event.target.name);
    this.FilterForm[event.target.name] = event.detail.value;
    console.log('this.FilterForm', JSON.stringify(this.FilterForm));

    if ((this.FilterForm["ProductCode"] != undefined || this.FilterForm["ProductCode"] != '') &&
        (this.FilterForm["ProductFamily"] != undefined || this.FilterForm["ProductFamily"].length != 0)) {
        this.disabledApplayButton = false;
    } else
        if ((this.FilterForm["ProductCode"] == undefined || this.FilterForm["ProductCode"] == '') &&
            (this.FilterForm["ProductFamily"] == undefined || this.FilterForm["ProductFamily"].length == 0)) {
            this.disabledApplayButton = false; {
                this.disabledApplayButton = true;
            }
        }
}


@track selectedFamily = '';
@track selectedMainGroup = '';
@track selectedItemBrand = '';
@track selectedtaxcode = '';
@track selectedvalues = '';
@track selectedItemCategory ='';

@track taxCodeOptions = [];
@track valuesoptions =[];
@track error;


handleFamilyChange(event) {
    this.selectedFamily = event.target.value;
    //this.selectedMainGroup = '';
    //this.selectedSubGroup = '';
    this.filterData();
}
handleItemcategoryChange(event){
    this.selectedItemCategory = event.target.value;
    //this.selectedItemCategory = '';
    this.filterData();
}
handleItemBrandChange(event) {
    this.selectedItemBrand = event.target.value;
    this.filterData();
}




filterData() {
    console.log('filtervalues are' + ''+this.selectedItemCategory +' '+ this.selectedFamily + '  ' + this.searchKey);
    if (this.searchKey != '' && this.selectedItemCategory =='' && this.selectedFamily == '') {
        console.log('indside  1');
        this.ShowTableData = this.dataForFilter.filter(record =>
        (!this.searchKey || record.Name.toLowerCase().includes(this.searchKey.toLowerCase()) 
        //||record.ProductCode.toLowerCase().includes(this.searchKey.toLowerCase())
            //|| record.Family.toLowerCase().includes(this.searchKey.toLowerCase())
        )
        );
        this.showErrorMsg = false;

        this.isProductSelect = false;
        this.fillselectedRows();
        this.RecalculateselectedProductCode();

        this.paginiateData(JSON.stringify(this.ShowTableData));
        this.page = 1;
    } if (this.searchKey == '' && this.selectedItemCategory !='' &&  this.selectedFamily == '') {
        console.log('indside  itemcategoryfilter');
        this.ShowTableData = this.dataForFilter.filter(record =>
            (!this.selectedItemCategory || record.Itemcategory === this.selectedItemCategory) &&
            (!this.searchKey || record.Name.toLowerCase().includes(this.searchKey.toLowerCase()) ||
                record.ProductCode.toLowerCase().includes(this.searchKey.toLowerCase())
                //|| record.Family.toLowerCase().includes(this.searchKey.toLowerCase())
            )
        );
        this.showErrorMsg = false;

        this.isProductSelect = false;
        this.fillselectedRows();
        this.RecalculateselectedProductCode();

        this.paginiateData(JSON.stringify(this.ShowTableData));
        this.page = 1;
 }
 if(this.searchKey !='' && this.selectedItemCategory =='' && this.selectedFamily !=''){
    console.log('indside  itemfamily');
     this.ShowTableData = this.dataForFilter.filter(record =>
            (!this.selectedFamily || record.Family === this.selectedFamily) &&
            (!this.searchKey || record.Name.toLowerCase().includes(this.searchKey.toLowerCase()) ||
                record.ProductCode.toLowerCase().includes(this.searchKey.toLowerCase())
                //|| record.Family.toLowerCase().includes(this.searchKey.toLowerCase())
            )
        );
        this.showErrorMsg = false;

        this.isProductSelect = false;
        this.fillselectedRows();
        this.RecalculateselectedProductCode();

        this.paginiateData(JSON.stringify(this.ShowTableData));
        this.page = 1;

 }
 else if (this.searchKey == '' && this.selectedItemCategory =='' && this.selectedFamily != '') {
    console.log('indside  4');
    this.ShowTableData = this.dataForFilter.filter(record =>
        (!this.selectedFamily || record.Family === this.selectedFamily) &&
        (!this.searchKey || record.Name.toLowerCase().includes(this.searchKey.toLowerCase()) ||
            record.ProductCode.toLowerCase().includes(this.searchKey.toLowerCase())
            //record.Family.toLowerCase().includes(this.searchKey.toLowerCase())
        )
    );
    this.showErrorMsg = false;

    this.isProductSelect = false;
    this.fillselectedRows();
    this.RecalculateselectedProductCode();

    this.paginiateData(JSON.stringify(this.ShowTableData));
    this.page = 1;
}
else if (this.searchKey == '' && this.selectedItemCategory !='' && this.selectedFamily != '') {
    console.log('indside  5');
    this.ShowTableData = this.dataForFilter.filter(record =>
        (!this.selectedItemCategory || record.Itemcategory === this.selectedItemCategory) &&
        (!this.selectedFamily || record.Family === this.selectedFamily) &&
        (!this.searchKey || record.Name.toLowerCase().includes(this.searchKey.toLowerCase()) ||
            record.ProductCode.toLowerCase().includes(this.searchKey.toLowerCase())
            //record.Family.toLowerCase().includes(this.searchKey.toLowerCase())
        )
    );
    this.showErrorMsg = false;

    this.isProductSelect = false;
    this.fillselectedRows();
    this.RecalculateselectedProductCode();

    this.paginiateData(JSON.stringify(this.ShowTableData));
    this.page = 1;
}

else if (this.searchKey == '' && this.selectedFamily == '' && this.selectedItemCategory =='') {
    console.log('indside  17');
    this.allRecords = this.dataForFilter;
    this.showErrorMsg = false;

    this.isProductSelect = false;
    this.fillselectedRows();
    this.RecalculateselectedProductCode();

    this.paginiateData(JSON.stringify(this.allRecords));
    this.page = 1;
}
}
@track selectedPriority;
handlechangepriority(event) {
    this.selectedPriority = event.target.value;

    this.filterData();
}
// Filter data based on selected picklist value




@track getSubTypeProjectList = [];


handle1Change() {
    if (this.FilterForm["ProductMainGroup"] != undefined) {

    }
}


@track dataForFilter;
    openModal() {
        let CheckPb = false;
        //window.location.reload();
        this.isModalOpen = true;
        this.ShowTableData = [];
        this.selectedProductCode = [];
        this.AllProductData = [];
        this.SelectedProductData = [];
        findProducts({ recordId: this.recId, productFamily: [] }).then(result => {
            console.log(result);
            let dataObj = JSON.parse(result);
            
            this.PriceBook = dataObj.priceBook;

            console.log('Pricebook',dataObj.priceBook);

            if(dataObj.priceBook ==null){
                console.log('inisde if');
            this.closeAction();
            }
            if(dataObj.priceBook !=null){
            console.log(dataObj);
            console.log('inisde else if');
                this.AllProductData = dataObj.productList;
                this.ShowTableData = dataObj.productList;
        this.dataForFilter = dataObj.productList;
        this.paginiateData(JSON.stringify(this.AllProductData));

        }


            
            
        });
    }


    closeAction(){

    this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'Please Select Pricebook First',
            variant: 'error',
        }));

        this.dispatchEvent(new RefreshEvent());
      //this.goBackToRecord();
}

handleShowSelected() {

    this.ShowSelected = false;
    console.log('handleShowSelected called...');
    this.ShowTableData = this.AllProductData;
    this.ShowViewAll = true;
    this.fillselectedRows();
    this.RecalculateselectedProductCode();
    this.paginiateData(JSON.stringify(this.AllProductData));
    this.page = 1;
}



handleClose() {
    this.showPopup = false;
}



handleviewAll(event) {
    this.ShowSelected = true;
    this.ShowViewAll = false;
    this.SelectedProduct(this.tempEvent);
    this.fillselectedRows();
    this.RecalculateselectedProductCode();

    console.log('method view all');
    this.paginiateData(JSON.stringify(this.AllProductData));
    this.page = 1;
}

fillselectedRows() {
    this.selectedRows = []
    for (let i = 0; i < this.ShowTableData.length; i++) {
        if (this.selectedProductCode.includes(this.ShowTableData[i].Id)) {
            this.selectedRows.push(this.ShowTableData[i]);
        }
    }
}

RecalculateselectedProductCode() {
    this.selectedProductCode = [];
    for (let i = 0; i < this.SelectedProductData.length; i++) {
        this.selectedProductCode.push(this.SelectedProductData[i].Id);
    }
}

@track tempEvent;
SelectedProduct(event) {
    this.tempEvent = event;
    //console.log('SelectedProduct called..');
    if (true) {
        const selRows = event.detail.selectedRows;

        // console.log('selRows..', selRows.length);
        // console.log('All..', this.selectedRows.length);
        if (this.selectedRows.length < selRows.length) {
            //console.log('Selected');
            for (let i = 0; i < selRows.length; i++) {

                this.selectedProductCode.push(selRows[i].Id);
                //this.SelectedProductData.push(selRows[i]);
            }
        } else {

            var selectedRowsProductCode = [];
            var selProductCode = [];
            for (let i = 0; i < this.selectedRows.length; i++) {
                selectedRowsProductCode.push(this.selectedRows[i].Id);
            }
            // console.log('selectedRowsProductCode..159', selectedRowsProductCode.length);
            for (let i = 0; i < selRows.length; i++) {
                selProductCode.push(selRows[i].Id);
            }
            //console.log('selProductCode..162', selProductCode.length);
            //console.log('length', selectedRowsProductCode.filter(x => selProductCode.indexOf(x) === -1));
            var deselectedRecProductCode = selectedRowsProductCode.filter(x => selProductCode.indexOf(x) === -1);
            for (let i = 0; i < deselectedRecProductCode.length; i++) {
                this.selectedProductCode = this.selectedProductCode.filter(function (e) { return e !== deselectedRecProductCode[i] })
            }
        }
        this.selectedRows = selRows;
        this.selectedProductCode = [...new Set(this.selectedProductCode)];
        this.SelectedRecordCount = this.selectedProductCode.length;

        this.SelectedProductData = [];
        for (let i = 0; i < this.selectedProductCode.length; i++) {
            for (let j = 0; j < this.AllProductData.length; j++) {
                if (this.selectedProductCode.includes(this.AllProductData[j].Id)) {
                    this.SelectedProductData.push(this.AllProductData[j]);
                }
            }
        }
        this.SelectedProductData = [...new Set(this.SelectedProductData)];
        if (this.selectedProductCode.length > 0) {
            this.DisableNext = false;
        } else {
            this.DisableNext = true;
        }
    }
    //this.paginiateData(JSON.stringify(this.SelectedProductData));
    this.isProductSelect = true;

}

goBackToRecord() {
    setTimeout(() => {
        window.location.reload();
    }, 2000);

    this.isFirstPage = true;
    this.isSecondPage = false;
    this.SelectedProductData = [];
    this.selectedProductCode = [];
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recId,
            objectApiName: 'Enquiry__c',
            actionName: 'view',

        }
    });
    //this.isModalOpen = false;
}

closeModal() {
    this.isModalOpen = false;
    this.SelectedRecordCount = 0;

    this.PriceBook = '';
    this.ShowTableData = [];
    this.selectedProductCode = [];
    this.AllProductData = [];
    this.SelectedProductData = [];

    this.lstResult = [];
    this.hasRecords = true;
    this.searchKey = '';
    this.isSearchLoading = false;
    this.isFirstPage = true;
    this.isSecondPage = false;
    this.selectedRows = [];
    this.ShowViewAll = false;
    this.ShowSelected = true;
    this.showErrorMsg = false;
    this.filteredData = [];
    this.FilterForm = { "ProductFamily": "", "ItemCategory": "","ItemBrand": "" };
    this.datafilterval = false;
    this.DisableNext = true;

    //window.location.reload();

    // this[NavigationMixin.Navigate]({
    //     type: 'standard__recordPage',
    //     attributes: {
    //         recordId: this.recId,
    //         objectApiName: 'Opportunity',
    //         actionName: 'view',

    //     }
    // });
}

nextDetails() {
    this.isFirstPage = false;
    this.isSecondPage = true;
    this.SelectedProductData = [];
    for (let i = 0; i < this.selectedProductCode.length; i++) {
        //this.selectedProductCode[i].index = i;
        for (let j = 0; j < this.AllProductData.length; j++) {
            if (this.selectedProductCode.includes(this.AllProductData[j].Id)) {
                this.SelectedProductData.push(this.AllProductData[j]);
            }
        }

    }

    // //setTimeout(() => {
    //     console.log(this.selectedProductCode.length + '  --- ' + this.SelectedProductData.length);
    //     if (this.SelectedProductData.length > 0) {

    //         for (let j = 0; j < this.SelectedProductData.length; j++) {
    //             this.SelectedProductData[j].hindex = j;
    //             this.SelectedProductData[j].index = j;
    //         }

    //     }
    //console.log('selectedProductCode = ', JSON.stringify(this.selectedProductCode));
    this.SelectedProductData = [...new Set(this.SelectedProductData)];
    clearTimeout(this.timeoutId); // no-op if invalid id
    this.timeoutId = setTimeout(this.updateIndex.bind(this), 1000);
    //}, 600);



}

updateIndex() {

}

datafilter() {
    if (this.datafilterval) {
        this.datafilterval = false;
    } else {
        this.datafilterval = true;
    }
}

hadleDelete(event) {
    this.template.querySelectorAll('tr').forEach(ele => {
        console.log('ele-----------' + JSON.stringify(ele));
        console.log('event.target.value-----------' + JSON.stringify(event.target.value));
        if (ele.id.includes(event.target.value)) {
            ele.classList.add('slds-hide')
        }
    });
}


saveDetails() {
    var deletedProducts = []
    this.template.querySelectorAll('tr').forEach(ele => {
        if (ele.classList.value.includes('slds-hide') && !ele.id.includes('firstRow')) {
            var temp = ele.id.split('-');
            if (temp.length > 0) {
                deletedProducts.push(temp[0]);
            }
        }
    });
    // console.log('hiddendProducts = ', deletedProducts);
    for (var i = 0; i < this.SelectedProductData.length; i++) {
        var obj = this.SelectedProductData[i];
        for (var key in obj) {
            var value = obj[key];
            if (key === 'Id') {
                if (this.mapIdQuantity.get(value) != undefined) {
                    obj.Quantity = this.mapIdQuantity.get(value);
                }
                if (this.mapIdSalesPrice.get(value) != undefined) {
                    obj.Price = this.mapIdSalesPrice.get(value);
                }
                if (this.mapIdDate.get(value) != undefined) {
                    obj.PDate = this.mapIdDate.get(value);
                }
                if (this.mapIdLineDescription.get(value) != undefined) {
                    obj.LineDescription = this.mapIdLineDescription.get(value);
                }
                if (this.mapIdDiscount.get(value) != undefined) {
                    obj.Discount = this.mapIdDiscount.get(value);
                }
                if(this.mapIdAdditionalcost.get(value) != undefined){
                    obj.AdditionalCost = this.mapIdAdditionalcost.get(value);
                }
                if(this.mapIdPackingcost.get(value) != undefined){
                    obj.PackingCost = this.mapIdPackingcost.get(value);
                }

            }
        }
        this.SelectedProductData[i] = obj;
    }
    var DataToSave = this.SelectedProductData;
    this.SelectedProductData = [];
    var isValidate = true;
    for (var i = 0; i < DataToSave.length; i++) {
        if (!deletedProducts.includes(DataToSave[i]["Id"])) {
            this.SelectedProductData.push(DataToSave[i]);
        }
    }

    for (var i = 0; i < this.SelectedProductData.length; i++) {
        if (this.SelectedProductData[i]["Quantity"] == 0 || this.SelectedProductData[i]["Quantity"] == undefined) {
            isValidate = false;
            break;
        }
    }
    if (isValidate) {
        this.isFirstPage = false;
        console.log(' SelectedProductData ' + JSON.stringify(this.SelectedProductData));
        let str = JSON.stringify(this.SelectedProductData);
        saveProducts({ recordData: str, recId: this.recId }).then(result => {
            this.selectedRecord = [];


            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Product Added Successfully',
                variant: 'success',
            }));
            this.dispatchEvent(new RefreshEvent());
            this.goBackToRecord();




        })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Product Adding',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                this.updateRecordView();
                //this.closeModal();
            });
    } else {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'Quantity should be non-Zero',
            variant: 'error',
        }));
    }

}

handleback() {
    //this.ShowTableData = this.AllProductData;

    this.ShowSelected = true;
    this.isFirstPage = true;
    this.isSecondPage = false;
    mapIdQuantity = '';
    mapIdSalesPrice = '';
    mapIdDate = '';
    mapIdDiscount = '';
    mapIdAdditionalcost ='';
    mapIdPackingcost='';
    mapIdLineDescription = '';

    this.fillselectedRows();
    this.RecalculateselectedProductCode();
    this.paginiateData(JSON.stringify(this.AllProductData));
    this.page = 1;

}


showFilteredProducts(event) {
    // console.log('event.keyCode = ', event.keyCode);
    if (event.keyCode == 13) {
        this.isFirstPage = false;
        this.showErrorMsg = false;
        // findProducts({ recordId: this.recId, productFamily: [] }).then(result => {
        //     let dataObj = JSON.parse(result);
        //     //console.log(dataObj);
        //     this.ShowTableData = dataObj.productList;
        //     this.filteredData = dataObj.productList;
        //     this.fillselectedRows();
        //     this.isFirstPage = true;
        //     this.ShowViewAll = true;
        //     this.ShowSelected = true;
        //     /*const searchBoxWrapper = this.template.querySelector('.lookupContainer');
        //     searchBoxWrapper.classList.remove('slds-show');
        //     searchBoxWrapper.classList.add('slds-hide');*/
        // });
    } else {
        this.searchKey = event.target.value;
        this.filterData();
        //this.handleKeyChange(event);
        const searchBoxWrapper = this.template.querySelector('.lookupContainer');
        searchBoxWrapper.classList.add('slds-show');
        searchBoxWrapper.classList.remove('slds-hide');
    }
}

handleKeyChange(event) {

    this.isSearchLoading = true;
    this.searchKey = event.target.value;
    var data = [];
    for (var i = 0; i < this.AllProductData.length; i++) {
        if (this.AllProductData[i] != undefined && this.AllProductData[i].Name.toLowerCase().includes(this.searchKey.toLowerCase())) {
            data.push(this.AllProductData[i]);
        }
    }
    this.paginiateData(JSON.stringify(data));
    this.page = 1;
    this.recordPerPage(1, this.SelectedProductData, data);
}



toggleResult(event) {
    console.log('toggleResult called...');
    const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
    const clsList = lookupInputContainer.classList;
    const whichEvent = event.target.getAttribute('data-source');
    switch (whichEvent) {
        case 'searchInputField':
            clsList.add('slds-is-open');
            break;
        case 'lookupContainer':
            clsList.remove('slds-is-open');
            break;
    }
}

@track dupSelectedRecordDound = [];
handelSelectedRecord(event) {
    //console.log(' event.target.dataset ' + JSON.stringify(event.target.dataset));
    //console.log(' event.target ' + JSON.stringify(event.target));

    var objId = event.target.dataset.recid;
    //console.log(' objId ' + objId);
    const searchBoxWrapper = this.template.querySelector('.lookupContainer');
    searchBoxWrapper.classList.remove('slds-show');
    searchBoxWrapper.classList.add('slds-hide');
    this.selectedRecord = this.lstResult.find(data => data.Id === objId);
    this.selectedProductCode.push(this.selectedRecord.Id);
    this.dupSelectedRecordDound.push(this.selectedRecord.Id);
    this.SelectedRecordCount += 1;
    this.ShowTableData.push(this.selectedRecord);

    this.handleShowSelected();
}


handleButtonClick(event) {
    let itemMasterId = this.SelectedProductData[event.target.value].Product2Id;
    console.log('itemMasterId:', itemMasterId);
    if (!itemMasterId) {
        console.error('No Item Master ID found.');
        return;
    }

    findRecentenqlineitem({ productId: itemMasterId })
        .then(result => {
            console.log('Apex Result:', result);

            // Parse the result from JSON string to JavaScript array
            let parsedResult = JSON.parse(result);

            // Ensure parsedResult is an array
            if (Array.isArray(parsedResult)) {
                // Prepare the data for lightning-datatable
                let formattedData = parsedResult.map(item => {
                    return {
                        ...item,
                        EnquiryName: item.Enquiry__r ? item.Enquiry__r.Name : '',
                        EqName : item.Enquiry__r ? item.Enquiry__r.Enquiry_Name__c : '',
                        EnquiryAccount: item.Enquiry__r && item.Enquiry__r.Account__r ? item.Enquiry__r.Account__r.Name : ''
                    };
                });

                this.showrecentEnqItems = formattedData;
                console.log('Recent Enquiry Items:', this.showrecentEnqItems);
            } else {
                console.error('Parsed result is not an array:', parsedResult);
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });

    this.showPopup = true;
}


handleQuantityChange(event) {
    var selectedRow = event.currentTarget;
    var key = selectedRow.dataset.targetId;
    //console.log(' key ' + key + ' event.target.value ' + event.target.value);
    this.mapIdQuantity.set(key, event.target.value);
}

handleSalesPriceChange(event) {
    var selectedRow = event.currentTarget;
    var key = selectedRow.dataset.targetId;
    this.mapIdSalesPrice.set(key, event.target.value);
}

handleTaxCodeChange(event) {
    const selectedTaxCode = event.target.value;
    const index = parseInt(event.currentTarget.dataset.index);
    this.SelectedProductData[index].Taxcode = selectedTaxCode;
}

handleDateChange(event) {
    var selectedRow = event.currentTarget;
    var key = selectedRow.dataset.targetId;
    this.mapIdDate.set(key, event.target.value);
    this.mapIdDiscount.set(key, event.target.value);
}
handleValuesInChange(event){
    const selectedvalues = event.target.value;
    const index = parseInt(event.currentTarget.dataset.index);
    this.SelectedProductData[index].ValuesIn = selectedvalues;
}
handleAdditionalCostChange(event) {
    var selectedRow = event.currentTarget;
    var key = selectedRow.dataset.targetId;
   // this.mapIdDate.set(key, event.target.value);
    this.mapIdAdditionalcost.set(key, event.target.value);
}
handlePackingCostChange(event) {
    var selectedRow = event.currentTarget;
    var key = selectedRow.dataset.targetId;
   // this.mapIdDate.set(key, event.target.value);
    this.mapIdPackingcost.set(key, event.target.value);
}




handleLineDescriptionChange(event) {
    var selectedRow = event.currentTarget;
    var key = selectedRow.dataset.targetId;
    this.mapIdLineDescription.set(key, event.target.value);
}

@track showSpinner = false;

ApplyFilter() {
    const searchBox = this.template.querySelector('.searchBox');
    console.log('this.showSpinner 0', this.showSpinner);
    this.showSpinner = true;
    console.log('this.showSpinner 1', this.showSpinner);

    this.isFirstPage = true;
    setTimeout(() => {
        findProducts({ recordId: this.recId, productFamily: [] }).then(result => {
            let dataObj = JSON.parse(result);
            //console.log('filter code', this.FilterForm["ProductCode"]);
            //console.log('Family code', this.FilterForm["ProductFamily"]);
            this.ShowTableData = dataObj.productList;
            this.filteredData = dataObj.productList;
            this.fillselectedRows();
            this.isFirstPage = true;
            this.ShowViewAll = true;
            this.ShowSelected = true;

            //console.log('this.FilterForm["ProductFamily"]', this.FilterForm["ProductFamily"]);
            if (this.FilterForm["ProductCode"] != undefined && this.FilterForm["ProductCode"] != '') {
                console.log('inside 1 product code');
                var filteredProductData = [];
                for (let i = 0; i < this.filteredData.length; i++) {

                    if (this.filteredData[i].ProductCode != '' && this.filteredData[i].ProductCode != null) {
                        if (this.filteredData[i].ProductCode.toLowerCase().includes(this.FilterForm["ProductCode"].toLowerCase())) {
                            if (this.FilterForm["ProductFamily"] != undefined && this.FilterForm["ProductFamily"].length != 0) {
                                for (let j = 0; j < this.FilterForm["ProductFamily"].length; j++) {
                                    if (this.FilterForm["ProductFamily"][j] == this.filteredData[i].Family) {
                                        console.log('search key', this.searchKey);
                                        if (this.filteredData[i].Name.toLowerCase().includes(this.searchKey.toLowerCase())) {
                                            console.log('inside name key',);
                                            filteredProductData.push(this.filteredData[i]);
                                            break;
                                        } else {
                                            console.log('else name key',);
                                        }
                                    } else {
                                        console.log('family name key',);
                                        //filteredProductData.push(this.filteredData[i]);
                                    }
                                }
                            } else {
                                if (this.filteredData[i].Name.toLowerCase().includes(this.searchKey.toLowerCase())) {
                                    filteredProductData.push(this.filteredData[i]);
                                }
                            }

                        }
                    }
                }
                this.showErrorMsg = false;
                this.ShowTableData = filteredProductData;
                this.isProductSelect = false;
                this.fillselectedRows();
                this.RecalculateselectedProductCode();
                this.paginiateData(JSON.stringify(this.ShowTableData));
                this.page = 1;
                //this.showSpinner = false
                //console.log('filteredProductData = ', filteredProductData);
            }
            else if (this.FilterForm["ProductFamily"] != undefined && this.FilterForm["ProductFamily"].length != 0) {
                console.log('inside 2nd product code');
                var filteredProductData = [];
                for (let i = 0; i < this.filteredData.length; i++) {
                    for (let j = 0; j < this.FilterForm["ProductFamily"].length; j++) {
                        if (this.FilterForm["ProductFamily"][j] == this.filteredData[i].Family) {
                            if (this.filteredData[i].Name.toLowerCase().includes(this.searchKey.toLowerCase())) {
                                filteredProductData.push(this.filteredData[i]);
                                break;
                            }
                        }
                    }
                }
                this.showErrorMsg = false;
                this.ShowTableData = filteredProductData;
                this.isProductSelect = false;
                this.fillselectedRows();
                this.RecalculateselectedProductCode();

                this.paginiateData(JSON.stringify(this.ShowTableData));
                this.page = 1;
                //this.showSpinner = false
                //console.log('filteredProductData = ', filteredProductData);
            }
            else

                if (this.searchKey != '' && (this.FilterForm["ProductFamily"] == undefined
                    || this.FilterForm["ProductFamily"].length == 0) &&
                    (this.FilterForm["ProductCode"] == undefined || this.FilterForm["ProductCode"] == '')) {
                    console.log('inside 3 product search');
                    var filteredProductData = [];
                    for (let i = 0; i < this.filteredData.length; i++) {
                        //for (let j = 0; j < this.FilterForm["ProductFamily"].length; j++) {
                        //if (this.FilterForm["ProductFamily"][j] == this.filteredData[i].Family) {
                        if (this.filteredData[i].Name.toLowerCase().includes(this.searchKey.toLowerCase())) {
                            filteredProductData.push(this.filteredData[i]);
                            break;
                            //}
                            //}
                        }
                    }
                    this.showErrorMsg = false;
                    this.ShowTableData = filteredProductData;
                    this.isProductSelect = false;
                    this.fillselectedRows();
                    this.RecalculateselectedProductCode();

                    this.paginiateData(JSON.stringify(this.ShowTableData));
                    this.page = 1;
                    //this.showSpinner = false
                }
                else {
                    if (this.searchKey == '' && (this.FilterForm["ProductFamily"] == undefined
                        || this.FilterForm["ProductFamily"].length == 0) &&
                        (this.FilterForm["ProductCode"] == undefined || this.FilterForm["ProductCode"] == '')) {

                        this.showErrorMsg = false;
                        this.ShowTableData = this.AllProductData;
                        this.isProductSelect = false;
                        this.fillselectedRows();
                        this.RecalculateselectedProductCode();

                        this.paginiateData(JSON.stringify(this.AllProductData));
                        this.page = 1;
                    }
                }

        });
        this.showSpinner = false;

    }, 600);

    //}

    this.datafilterval = false;

}

clearFilter() {
    this.FilterForm = { "ProductFamily": "" };
    this.disabledApplayButton = true;
    this.datafilterval = false;

    this.fillselectedRows();
    this.RecalculateselectedProductCode();
    this.paginiateData(JSON.stringify(this.AllProductData));
    this.page = 1;
}


@track paginationDataList;
paginiateData(results) {
    let data = JSON.parse(results);
    this.paginationDataList = data;
    this.totalRecountCount = data.length;
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
    this.ShowTableData = this.paginationDataList.slice(0, this.pageSize);
    ////console.log('totalRecountCount ', this.totalRecountCount);
    this.endingRecord = this.pageSize;
    this.error = undefined;

}



page = 1;
items = [];
data = [];

startingRecord = 1;
endingRecord = 0;
pageSize = 10;
totalRecountCount = 0;
totalPage = 0;


get bDisableFirst() {
    return this.page == 1;
}
get bDisableLast() {
    return this.page == this.totalPage;
}


firstPage() {
    this.page = 1;

    this.recordPerPage(this.page, this.SelectedProductData, this.paginationDataList);
    //console.log('this.SelectedProductData 604', this.SelectedProductData.length);
    //this.template.querySelector('[data-id="datatable"]').selectedRows = this.SelectedProductData;

}

previousHandler() {
    if (this.page > 1) {
        this.page = this.page - 1;
        //console.log('this.SelectedProductData 611', this.SelectedProductData.length);
        this.recordPerPage(this.page, this.SelectedProductData, this.paginationDataList);
    }
    // this.template.querySelector('[data-id="datatable"]').selectedRows = this.SelectedProductData;

}

nextHandler() {
    if ((this.page < this.totalPage) && this.page !== this.totalPage) {
        this.page = this.page + 1;
        //console.log('this.SelectedProductData 619', this.SelectedProductData.length);
        this.recordPerPage(this.page, this.SelectedProductData, this.paginationDataList);
    }

    //console.log('json -->', JSON.parse(this.template.querySelector('[data-id="datatable"]').selectedRows));



}

lastPage() {

    this.page = this.totalPage;
    if (this.page > 1) {
        console.log('this.SelectedProductData 633', this.SelectedProductData.length);
        this.recordPerPage(this.page, this.SelectedProductData, this.paginationDataList);
    }
    //this.template.querySelector('[data-id="datatable"]').selectedRows = this.SelectedProductData;

}


recordPerPage(page, selectedRecords, data) {
    let tempdata = data;
    this.startingRecord = ((page - 1) * this.pageSize);
    this.endingRecord = (this.pageSize * page);
    this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;
    //this.fillselectedRows();
    this.ShowTableData = tempdata.slice(this.startingRecord, this.endingRecord);

    this.startingRecord = this.startingRecord + 1;
    console.log('this.selectedProductCode 664', this.selectedProductCode.length);
    this.fillselectedRows();
    this.RecalculateselectedProductCode();
    console.log('this.selectedProductCode 666', this.selectedProductCode.length);
    this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedProductCode;

}

}