({
    init : function(component, event, helper) {
        // Get the page reference
        const pageRef = component.get("v.pageReference");

        // Check if 'inContextOfRef' exists and remove it
        if (pageRef && pageRef.state && pageRef.state.inContextOfRef) {
            delete pageRef.state.inContextOfRef;
            component.set("v.pageReference", pageRef);
        }
        window.location.href='/lightning/n/New_Enquiry';
    },
    reInit : function(component, event, helper) { 
        console.log('This is fire');
        $A.get('e.force:refreshView').fire();
    }
})