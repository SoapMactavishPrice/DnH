({
    init : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        component.set("v.refRecordId", pageReference.state.c__refRecordId);
        component.set("v.refaccountId", pageReference.state.c__refaccountId);
        component.set("v.refrecordTypeId", pageReference.state.c__refrecordTypeId);
    },
    reInit : function(component, event, helper) { 
        console.log('This is fire');
        $A.get('e.force:refreshView').fire();
    }
})