({
    navigateToLC: function (component, event, helper) {

        var device = $A.get("$Browser.formFactor");
        // alert("You are using a " + device);
        console.log('You are using a ', device);

        if (device == 'PHONE') {
            var nagigateLightning = component.find('navService');
            var pageReference = {
                type: "standard__component",
                attributes: {
                    componentName: "c__editService5Caller"
                },
                state: {
                    c__recId: component.get("v.recordId"),
                }
            };


            //nagigateLightning.navigate(pageReference);

            console.log('PARENT -> ', pageReference);
            component.set("v.pageReference", pageReference);
            const navService = component.find("navService");
            const pageRef = component.get("v.pageReference");
            const handleUrl = (url) => {
                window.open(url);
                //window.location.href=url;
            };
            const handleError = (error) => {
                console.log('===========>', error);
            };
            console.log('PARENT -> ', pageReference);
            navService.generateUrl(pageRef).then(handleUrl, handleError);
        } else {
            var pageReference = {
                type: "standard__component",
                attributes: {
                    componentName: "c__editService19Caller"
                },
                state: {
                    c__recId: component.get("v.recordId"),
                }
            };

            console.log('PARENT -> ', pageReference);
            component.set("v.pageReference", pageReference);
            const navService = component.find("navService");
            const pageRef = component.get("v.pageReference");
            const handleUrl = (url) => {
                //window.open(url);
                window.location.href = url;
            };
            const handleError = (error) => {
                console.log('===========>', error);
            };
            console.log('PARENT -> ', pageReference);
            navService.generateUrl(pageRef).then(handleUrl, handleError);
        }


    }
});