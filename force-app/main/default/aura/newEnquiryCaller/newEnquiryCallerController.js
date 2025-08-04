({
    init : function(component, event, helper) {
       
        component.set("v.isEnquiryVisible", false);
        var pageReference = component.get("v.pageReference");
        component.set("v.refRecordId", pageReference.state.c__refRecordId);

        // Delay showing the child component by 3 seconds
        setTimeout(function () {
            component.set("v.isEnquiryVisible", true);
        }, 2000);
    },
    reInit : function(component, event, helper) { 
        console.log('This is fire');
        $A.get('e.force:refreshView').fire();
    }
})