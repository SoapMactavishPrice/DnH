({
    navigateToLC: function (component, event, helper) {
  
      var device = $A.get("$Browser.formFactor");
      // alert("You are using a " + device);
      console.log('You are using a ' , device);


      // Call Apex method
      let action = component.get("c.getEnquiryDetails");
      let recordId = component.get("v.recordId"); // Assuming recordId is set in the component
      let accountId='';
      let recordTypeId='';
      // Pass parameters to Apex
      action.setParams({
          recId: recordId
      });

      // Set up callback
      action.setCallback(this, function (response) {
          let state = response.getState();
          console.log('response.getState() ',response.getState());
          console.log('response.getState() ',response.getReturnValue());
          
          if (state === "SUCCESS") {
            //   console.log("Enquiry Details: ", JSON.parse(response.getReturnValue()));
              let enquiryDetails = response.getReturnValue();
              console.log("Enquiry Details: ", enquiryDetails);
              accountId=enquiryDetails.Account__c;
              recordTypeId=enquiryDetails.RecordTypeId;
             console.log('accountId ',accountId);
             console.log('recordTypeId ',recordTypeId);

             if(device =='PHONE'){
                var nagigateLightning = component.find('navService');
                var pageReference = {
                    type: "standard__component",
                    attributes: {
                      componentName: "c__createSaleOrderCaller"
                    },
                    state: {
                      c__enquiryId: component.get("v.recordId"),
                      c__accountId: accountId,
                      c__recordtypeId: recordTypeId,
                    }
                  };

                  
                  //nagigateLightning.navigate(pageReference);

                  console.log('PARENT -> ',pageReference);
                    component.set("v.pageReference", pageReference);
                    const navService = component.find("navService");
                    const pageRef = component.get("v.pageReference");
                    const handleUrl = (url) => {
                      window.open(url);
                      //window.location.href=url;
                    };
                    const handleError = (error) => {
                      console.log('===========>',error);
                    };
                    console.log('PARENT -> ',pageReference);
                    navService.generateUrl(pageRef).then(handleUrl, handleError);
              }else{
                // var pageReference = {
                //     type: "standard__component",
                //     attributes: {
                //       componentName: "c__createSaleOrderCaller"
                //     },
                //     state: {
                //       c__refRecordId: component.get("v.recordId"),
                //       c__refaccountId: accountId,
                //       c__refrecordTypeId: recordTypeId,
                //     }
                //   };
                //   nagigateLightning.navigate(pageReference);
                    var pageReference = {
                      type: "standard__component",
                      attributes: {
                        componentName: "c__createSaleOrderCaller"
                      },
                      state: {
                        c__enquiryId: component.get("v.recordId"),
                      c__accountId: accountId,
                      c__recordtypeId: recordTypeId,
                      }
                    };
                    
                    console.log('PARENT -> ',pageReference);
                    component.set("v.pageReference", pageReference);
                    const navService = component.find("navService");
                    const pageRef = component.get("v.pageReference");
                    const handleUrl = (url) => {
                      //window.open(url);
                      window.location.href=url;
                    };
                    const handleError = (error) => {
                      console.log('===========>',error);
                    };
                    console.log('PARENT -> ',pageReference);
                    navService.generateUrl(pageRef).then(handleUrl, handleError);
              }
             
          } else if (state === "ERROR") {
              let errors = response.getError();
              if (errors && errors[0] && errors[0].message) {
                  console.error("Error message: " + errors[0].message);
              } else {
                  console.error("Unknown error");
              }
          }
      });

      // Enqueue the action
      $A.enqueueAction(action);

      
    }
  });