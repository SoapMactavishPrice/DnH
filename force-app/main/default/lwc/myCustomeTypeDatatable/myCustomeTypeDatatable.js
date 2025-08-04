//import { LightningElement } from 'lwc';
import lightningDatatable from 'lightning/datatable';
import customPicklistTemplate from './customPicklist.html'; 
import customPicklistEditTemplate from './customPicklistEdit.html';

export default class MyCustomeTypeDatatable extends lightningDatatable {
    static customTypes ={
        customPicklist:{
             template:customPicklistTemplate,
             editTemplate:customPicklistEditTemplate,
             standardCellLayout:true,
             typeAttributes:['label','placeholder','options','value','context']
        }
    }
}