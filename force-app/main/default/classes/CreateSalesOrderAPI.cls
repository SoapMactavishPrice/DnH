@RestResource(urlMapping = '/CreateStandardSalesOrder')
global class CreateSalesOrderAPI {
    @HttpPost
    global static void doPost() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String jSONRequestBody = request.requestBody.toString().replace('\n', '');

        // ------------------- API LOG to track the request -------------------
        API_Log__c api_log = new API_Log__c();
        api_log.Log_Name__c = 'Create_StandardSalesOrder';
        api_log.Request__c = jSONRequestBody;
        api_log.created_date__c = Datetime.now();

        JSON2ApexSaveWebToLead jsonObj = JSON2ApexSaveWebToLead.parse(jSONRequestBody);
        System.debug('======----->jsonObj' + jsonObj);

        try {
            // ------------------- Logic start from here -------------------

            if ((jsonObj.CustomerNo != null && jsonObj.CustomerNo != '')) {

                // Account Check
                List < Account > getExistingAcc = new List < Account > ();
                getExistingAcc = [
                    SELECT Id, Name FROM Account WHERE Id =: jsonObj.CustomerNo OR Customer_Code__c =: jsonObj.CustomerNo
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

                if (getExistingAcc.size() > 0) {

                    string objectname = 'Techno Commercial Offer';
                    List < Code_Master__c > codem = [SELECT Id, Name, Object__c, Display_Label__c, Current_Sequence__c, Starting_Sequence__c,
                        Backend_Current_Sequence__c, For_Display_Sequence__c FROM Code_Master__c
                        WHERE Object__c =: objectname AND Is_Active__c = true
                        LIMIT 1
                    ];
                    List<User> enggListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.EngineerID];
                    List<User> amListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.Area_Manager];
                    List<User> zonalListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.Zonal_Head];
                    List<Account> accListbyCode = [SELECT Id, Name, Customer_Code__c FROM Account WHERE Customer_Code__c =: jsonObj.SubmittedBy];
                    List<User> subInListbyCode = [SELECT Id, Name, Code__c FROM User WHERE Code__c =: jsonObj.SubmittedBy];

                    Enquiry__c enq = new Enquiry__c();
                    String Documentname = '';
                    if (codem.size() > 0) {
                        codem[0].Current_Sequence__c += 1;
                        Documentname = codem[0].Display_Label__c + '/' + String.valueOf(codem[0].For_Display_Sequence__c);
                        enq.Enquiry_Name__c = 'SF-'+Documentname;
                    }
                    enq.Account__c = getExistingAcc[0].Id;
                    if(enggListbyCode.size() > 0){
                        enq.Field_Staff_Code__c = enggListbyCode[0].Id;
                    }
                    if(amListbyCode.size() > 0){
                        enq.Area_Manager__c = amListbyCode[0].Id;
                    }
                    if(zonalListbyCode.size() > 0){
                        enq.Zonal_Head__c = zonalListbyCode[0].Id;
                    }
                    enq.Is_Created_From_TSD__c = true;
                    insert enq;

                    // Insert Header attachment


                    List < Enquiry_Line_Item__c > newEnqLli = new List < Enquiry_Line_Item__c > ();

                    if (jsonObj.LineItems != null) {
                        for (SalesOrderLineItemClass a: jsonObj.LineItems) {
                            Enquiry_Line_Item__c techCO = new Enquiry_Line_Item__c();
                            techCO.Enquiry__c = enq.Id;
                            List<Item_Master__c> itemMasterByNum = [
                                SELECT Id, Name, Item_Number__c FROM Item_Master__c
                                WHERE Item_Number__c =: a.Item_Number
                                AND Item_Type__c = 'Normal'
                            ];
                            if (itemMasterByNum.size() > 0) {                        
                                techCO.Item_Master__c = itemMasterByNum[0].Id;
                            }
                            if (a.Quantity != null && a.Quantity != '') {
                                techCO.Qty__c = Decimal.valueOf(a.Quantity);
                                techCO.RemainingQty__c = Decimal.valueOf(a.Quantity);
                            }
                            if (a.Sales_Price != null && a.Sales_Price != '') {
                                techCO.Dealer_Rate__c = Decimal.valueOf(a.Sales_Price);
                                techCO.Standard_Dealer_Rate__c = Decimal.valueOf(a.Sales_Price);
                                techCO.SuggestedDealerPrice__c = Decimal.valueOf(a.Sales_Price);
                                techCO.Required_Rate_by_AM__c = Decimal.valueOf(a.Sales_Price);
                            }
                            if (a.Conversion_Quantity != null && a.Conversion_Quantity != '') {
                                techCO.Conversion_Quantity__c = Decimal.valueOf(a.Conversion_Quantity);
                            }
                            techCO.Conversion_Factor__c = a.Conversion_Factor;
                            techCO.Item_No__c = a.Item_Number;
                            if (a.Variant_Code != null && a.Variant_Code != '') {
                                List<Item_Variant__c> itemVarListbyCode = [
                                    SELECT Id, Name, Code__c
                                    FROM Item_Variant__c
                                    WHERE Code__c =: a.Variant_Code
                                    AND Item_No__c =: a.Item_Number
                                ];
                                if (itemVarListbyCode.size() > 0) {                        
                                    techCO.Item_Variant__c = itemVarListbyCode[0].Id;
                                }
                            }


                            newEnqLli.add(techCO);
                        }
                        insert newEnqLli;
                    }









                    Sales_Order__c newSO = new Sales_Order__c();

                    newSO.Account__c = getExistingAcc[0].Id;
                    newSO.Enquiry__c = enq.Id;
                    newSO.Status__c = 'Pending';
                    newSO.Name = jsonObj.WebOrderNo;
                    if (jsonObj.Order_Booking_Date != null && jsonObj.Order_Booking_Date != '') {
                        newSO.Order_Booking_Date__c = Date.valueOf(jsonObj.Order_Booking_Date);
                    }
                    newSO.External_Doc_No_PO__c = jsonObj.External_Doc_No_PO;
                    newSO.Rate_Type__c = jsonObj.Rate_Type;
                    newSO.Internal_Remarks__c = jsonObj.Internal_Remarks;
                    newSO.External_Remarks__c = jsonObj.External_Remarks;
                    newSO.Freight_Terms__c = jsonObj.Freight_Terms;
                    // newSO.LR_Destination__c = jsonObj.LR_Destination;
                    List<LR_Destination__c> lrList = [SELECT Id, Name, Code__c FROM LR_Destination__c WHERE Code__c =: jsonObj.LR_Destination];
                    if (lrList.size() > 0) {
                        newSO.LR_Destination_2__c = lrList[0].Id;
                    }
                    newSO.LR_favour__c = jsonObj.LR_favour;
                    newSO.Delivery_Type__c = jsonObj.Delivery_Type;
                    // newSO.Transporter_Name__c = jsonObj.TransporterNo;
                    List<Transporter__c> trList = [SELECT Id, Name, Code__c FROM Transporter__c WHERE Name =: jsonObj.Transporter_Name];
                    if (trList.size() > 0) {
                        newSO.Transporter__c = trList[0].Id;
                    }

                    if (jsonObj.EngineerID != null && jsonObj.EngineerID != '') {
                        if (enggListbyCode.size() > 0) {                        
                            newSO.Sales_Person__c = enggListbyCode[0].Id;
                        }
                    }
                    if (jsonObj.Area_Manager != null && jsonObj.Area_Manager != '') {
                        
                        if (amListbyCode.size() > 0) {                        
                            newSO.Area_Manager__c = amListbyCode[0].Id;
                        }
                    }
                    if (jsonObj.End_Customer_Name != null && jsonObj.End_Customer_Name != '') {
                        newSO.End_Customer_Name__c = jsonObj.End_Customer_Name;
                    }
                    if (jsonObj.Zonal_Head != null && jsonObj.Zonal_Head != '') {
                        
                        if (zonalListbyCode.size() > 0) {                        
                            newSO.Zonal_Head__c = zonalListbyCode[0].Id;
                        }
                    }
                    if (jsonObj.Contact != null && jsonObj.Contact != '') {
                        newSO.Contact__c = jsonObj.Contact;
                    }
                    if (jsonObj.WebOrderDate != null && jsonObj.WebOrderDate != '') {
                        newSO.WebOrderDate__c = Date.valueOf(jsonObj.WebOrderDate);
                    }
                    newSO.Shipment__c = jsonObj.Shipment;
                    newSO.Shipmentaddress2__c = jsonObj.Shipmentaddress2;
                    newSO.Shipmentcity__c = jsonObj.Shipmentcity;
                    if (jsonObj.Postcode1 != null && jsonObj.Postcode1 != '') {
                        newSO.Postcode1__c = Decimal.valueOf(jsonObj.Postcode1);
                    }
                    newSO.TransporterNo__c = jsonObj.TransporterNo;
                    newSO.EngineerID__c = jsonObj.EngineerID;
                    if (jsonObj.IsSubmitted != null && jsonObj.IsSubmitted != '') {
                        newSO.IsSubmitted__c = Boolean.valueOf(jsonObj.IsSubmitted);
                    }
                    if (jsonObj.SubmittedBy != null && jsonObj.SubmittedBy != '') {
                        
                        if (accListbyCode.size() > 0) {                        
                            newSO.Submitted_By_Customer__c = accListbyCode[0].Id;
                            newSO.Inserted_By_Customer__c = accListbyCode[0].Id;
                        } else {
                            
                            if (subInListbyCode.size() > 0) {                        
                                newSO.SubmittedBy__c = subInListbyCode[0].Id;
                                newSO.Inserted_By_SP__c = subInListbyCode[0].Id;
                            }
                        }
                    }
                    if (jsonObj.SubmittedDate != null && jsonObj.SubmittedDate != '') {
                        newSO.SubmittedDate__c = Date.valueOf(jsonObj.SubmittedDate);
                    }
                    if (jsonObj.Deactive != null && jsonObj.Deactive != '') {
                        newSO.Deactive__c = Boolean.valueOf(jsonObj.Deactive);
                    }
                    if (jsonObj.IsPostedToNav != null && jsonObj.IsPostedToNav != '') {
                        newSO.IsPostedToNav__c = Boolean.valueOf(jsonObj.IsPostedToNav);
                    }
                    // newSO.TechnoDocNo__c = jsonObj.TechnoDocNo;
                    newSO.ShipmentCode__c = jsonObj.ShipmentCode;
                    newSO.Is_Created_From_TSD__c = true;
                    System.debug('HeaderAttachment:>>>> ' +jsonObj.HeaderAttachment);
                    if (jsonObj.HeaderAttachment != null && jsonObj.HeaderAttachment.size() > 0) {
                        List<Map <String, String>> headerAttMapList = new List<Map <String, String>>();
                        for (SalesOrderHeaderAttachments var : jsonObj.HeaderAttachment) {
                            // CreateSalesOrderWithTCO.downloadAndInsertHeaderAtt(var.Title,var.DocumentLink,newSO.Id);
                            if (var.Title != null && var.Title != '' && var.DocumentLink != null && var.DocumentLink != '') {
                                headerAttMapList.add(new Map<String,String>{'Title'=>var.Title,'DocumentLink'=>var.DocumentLink});
                            } else {
                                throw new IllegalArgumentException('Title and DocumentLink required');
                            }
                            newSO.Attachment_Link__c = json.serialize(headerAttMapList);
                        }
                    }

                    insert newSO;

                    List < Sales_Order_Line_Item__c > newSOLI = new List < Sales_Order_Line_Item__c > ();

                    if (jsonObj.LineItems != null) {
                        for (SalesOrderLineItemClass a: jsonObj.LineItems) {
                            Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c();
                            soli.Sales_Order__c = newSO.Id;
                            soli.Item_Number__c = a.Item_Number;
                            List<Item_Master__c> itemMasterByNum = [
                                SELECT Id, Name, Item_Number__c FROM Item_Master__c
                                WHERE Item_Number__c =: a.Item_Number
                                AND Item_Type__c = 'Normal'
                            ];
                            if (itemMasterByNum.size() > 0) {                        
                                soli.Item_Master__c = itemMasterByNum[0].Id;
                            }
                            soli.Item_Category__c = a.Item_Category;
                            // if (a.Cash_Discount != null && a.Cash_Discount != '') {
                            //     soli.Cash_Discount__c = Decimal.valueOf(a.Cash_Discount);
                            // }
                            if (a.Quantity != null && a.Quantity != '') {
                                soli.Quantity__c = Decimal.valueOf(a.Quantity);
                            }
                            soli.UOM__c = a.UOM;
                            if (a.Variant_Code != null && a.Variant_Code != '') {
                                List<Item_Variant__c> itemVarListbyCode = [
                                    SELECT Id, Name, Code__c
                                    FROM Item_Variant__c
                                    WHERE Code__c =: a.Variant_Code
                                    AND Item_No__c =: a.Item_Number
                                ];
                                if (itemVarListbyCode.size() > 0) {                        
                                    soli.Item_Variant__c = itemVarListbyCode[0].Id;
                                }
                            }
                            if (a.Sales_Price != null && a.Sales_Price != '') {
                                soli.Sales_Price__c = Decimal.valueOf(a.Sales_Price);
                            }
                            if (a.Item_Value != null && a.Item_Value != '') {
                                soli.Item_Value__c = Decimal.valueOf(a.Item_Value);
                            }
                            if (a.Conversion_Quantity != null && a.Conversion_Quantity != '') {
                                soli.Conversion_Quantity__c = Decimal.valueOf(a.Conversion_Quantity);
                            }
                            if (a.Shipment_Date != null && a.Shipment_Date != '') {
                                soli.Shipment_Date__c = Date.valueOf(a.Shipment_Date);
                            }
                            soli.Conversion_Factor__c = a.Conversion_Factor;
                            soli.OrderProcessingHeaderId__c = a.OrderProcessingHeaderId;
                            soli.Description__c = a.Description;
                            soli.Description2__c = a.Description2;
                            soli.Location__c = a.Location;
                            if (a.RequestDispatchDate != null && a.RequestDispatchDate != '') {
                                soli.RequestDispatchDate__c = Date.valueOf(a.RequestDispatchDate);
                            }
                            soli.Sale_Price_UOM__c = a.Sale_Price_UOM;
                            if (a.LineAmountExclTax != null && a.LineAmountExclTax != '') {
                                soli.LineAmountExclTax__c = Decimal.valueOf(a.LineAmountExclTax);
                            }
                            soli.Status__c = a.Status;
                            if (a.Is_SOR != null && a.Is_SOR != '') {
                                soli.Is_SOR__c = Boolean.valueOf(a.Is_SOR);
                            }
                            if (a.SORRemark != null && a.SORRemark != '') {
                                soli.SOR_Remark__c = a.SORRemark;
                            }
                            if (a.UnitPriceExcl != null && a.UnitPriceExcl != '') {
                                soli.UnitPriceExcl__c = Decimal.valueOf(a.UnitPriceExcl);
                            }
                            if (a.AvailableQuantity != null && a.AvailableQuantity != '') {
                                soli.AvailableQuantity__c = Decimal.valueOf(a.AvailableQuantity);
                            }
                            if (a.OrderQty != null && a.OrderQty != '') {
                                soli.OrderQty__c = Decimal.valueOf(a.OrderQty);
                            }
                            if (a.QuantityDiscount != null && a.QuantityDiscount != '') {
                                soli.QuantityDiscount__c = Decimal.valueOf(a.QuantityDiscount);
                            }
                            if (a.SpecialDiscount != null && a.SpecialDiscount != '') {
                                soli.Discount_In_Percentage__c = Decimal.valueOf(a.SpecialDiscount); // we are mapping special discount in Discount in percentage
                            }
                            if (a.LineDiscountAmount != null && a.LineDiscountAmount != '') {
                                soli.LineDiscountAmount__c = Decimal.valueOf(a.LineDiscountAmount);
                            }
                            soli.QuantityIntoSaleUOM__c = a.QuantityIntoSaleUOM;
                            if (a.AcceptedQuantity != null && a.AcceptedQuantity != '') {
                                soli.AcceptedQuantity__c = Boolean.valueOf(a.AcceptedQuantity);
                            }
                            if (a.Deactive != null && a.Deactive != '') {
                                soli.Deactive__c = Boolean.valueOf(a.Deactive);
                            }
                            soli.DocumentNo__c = a.DocumentNo;
                            soli.TempLineNo__c = a.TempLineNo;
                            soli.ItemDiscOn__c = a.ItemDiscOn;
                            soli.ItemDiscGroup__c = a.ItemDiscGroup;
                            soli.Special_Order_Type__c = a.SORType;
                            soli.WebOrderNo__c = a.WebOrderNo;
                            if (a.DefaultShipmentDate != null && a.DefaultShipmentDate != '') {
                                soli.DefaultShipmentDate__c = Date.valueOf(a.DefaultShipmentDate);
                            }
                            if (a.IsChangedShipDate != null && a.IsChangedShipDate != '') {
                                soli.IsChangedShipDate__c = Boolean.valueOf(a.IsChangedShipDate);
                            }
                            // soli.TechnoDocNo__c = a.TechnoDocNo;
                            if (a.ChangedShipmentDate != null && a.ChangedShipmentDate != '') {
                                soli.ChangedShipmentDate__c = Date.valueOf(a.ChangedShipmentDate);
                            }
                            soli.WebOrderLineNo__c = a.WebOrderLineNo;
                            soli.ProductGroupCode__c = a.ProductGroupCode;
                            if (a.LineAttachment != null && a.LineAttachment.size() > 0) {
                                List<Map <String, String>> lineAttMapList = new List<Map <String, String>>();
                                for (SalesOrderLineAttachments var : a.LineAttachment) {
                                    // CreateSalesOrderWithTCO.downloadAndInsertHeaderAtt(var.Title,var.DocumentLink,newSO.Id);
                                    if (var.Title != null && var.Title != '' && var.DocumentLink != null && var.DocumentLink != '') {
                                        lineAttMapList.add(new Map<String,String>{'Title'=>var.Title,'DocumentLink'=>var.DocumentLink});
                                    } else {
                                        throw new IllegalArgumentException('Title and DocumentLink required in Line Item');
                                    }
                                    soli.Attachment_Link__c = json.serialize(lineAttMapList);
                                }
                            }
    
                            newSOLI.add(soli);
                        }
    
                        insert newSOLI;
                    }

                    api_log.Sales_Order__c = newSO.Id;

                    System.debug('-->Data Saved Successfully');
                    // ------------------- Send the Success Response -------------------
                    Map < string, string > successResMap = new Map < string, string > ();
                    successResMap.put('status', 'success');
                    successResMap.put('message', 'Sales Order Created');
                    successResMap.put('SalesOrder_SFID', newSO.Id);
                    successResMap.put('CustomerNo_SFID', newSO.Account__c);
                    // successResMap.put('Enquiry_SFID', newSO.Enquiry__c);
                    String resp = JSON.serialize(successResMap);
                    response.responseBody = Blob.valueOf(resp);
                    response.addHeader('Content-Type', 'application/json');
                    response.statusCode = 200;

                    api_log.Log_Status__c = 'Success';
                    api_log.Response_Code__c = '200';
                    api_log.Response__c = String.valueOf(resp);
                    api_log.response_time__c = Datetime.now();

                    RecordType recordTypes = [
                        SELECT Id, Name 
                        FROM RecordType 
                        WHERE SObjectType = 'Enquiry__c'
                        AND Name = 'Normal Enquiry'
                    ];

                    String sURL = Label.Cust_URL+'/lightning/n/Create_Sales_Order?c__enquiryId='+enq.Id+'&c__accountId=' + newSO.Account__c + '&c__recordtypeId=' + recordTypes.Id + '&c__orderId=' + newSO.Id;
                    // String sURL = 'https://dream-inspiration-9915.lightning.force.com/lightning/n/Create_Sales_Order?c__accountId=' + newSO.Account__c + '&c__recordtypeId=' + recordTypes.Id + '&c__orderId=' + newSO.Id;

                    AddSalesOrder.sendEmailToAreaManager(newSO.Id, sURL);
                    
                } else {
                    // ------------------- Send the Success Response -------------------
                    Map < string, string > successResMap = new Map < string, string > ();
                    successResMap.put('message', 'No Customer found!!');
                    successResMap.put('status', 'fail');

                    String resp = JSON.serialize(successResMap);
                    response.responseBody = Blob.valueOf(resp);
                    response.addHeader('Content-Type', 'application/json');
                    response.statusCode = 404;

                    api_log.Log_Status__c = 'Failure';
                    api_log.Response_Code__c = '404';
                    api_log.Response__c = String.valueOf(resp);
                    api_log.response_time__c = Datetime.now();
                }

            } else {
                // ------------------- Send the Success Response -------------------
                Map < string, string > successResMap = new Map < string, string > ();
                successResMap.put('message', 'CustomerNo required');
                successResMap.put('status', 'fail');

                String resp = JSON.serialize(successResMap);
                response.responseBody = Blob.valueOf(resp);
                response.addHeader('Content-Type', 'application/json');
                response.statusCode = 400;

                api_log.Log_Status__c = 'Failure';
                api_log.Response_Code__c = '400';
                api_log.Response__c = String.valueOf(resp);
                api_log.response_time__c = Datetime.now();
            }

        } catch (Exception e) {
            System.debug('Catch Error' + e.getStackTraceString());
            System.debug('Catch Error' + e.getMessage());
            System.debug('Catch Error' + e.getlineNumber());

            // ------------------- Create Response Map -------------------
            Map < string, string > errorResMap = new Map < string, string > ();
            errorResMap.put('Message', 'Something went wrong');
            errorResMap.put('Error1', e.getMessage());
            errorResMap.put('Error2', '' + e.getlineNumber());
            errorResMap.put('Error3', '' + String.valueOf(e));

            // ------------------- Send Response Map -------------------
            String resp = JSON.serialize(errorResMap);
            response.responseBody = Blob.valueOf(resp);
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;

            api_log.Log_Status__c = 'Failure';
            api_log.Response_Code__c = '400';
            api_log.Exception_desc__c = 'Line Number : ' + e.getLineNumber() + ' \n\n ' + e.getMessage() + '\n\n' + e.getStackTraceString();
            api_log.response_time__c = Datetime.now();

        }

        insert api_log;

    }

    public class JSON2ApexSaveWebToLead {
        public String CustomerNo;
        public String WebOrderNo;
        public String Order_Booking_Date;
        public String External_Doc_No_PO;
        public String Rate_Type;
        public String Internal_Remarks;
        public String External_Remarks;
        public String Freight_Terms;
        public String LR_Destination;
        public String LR_favour;
        public String Delivery_Type;
        public String Transporter_Name;
        public String Area_Manager;
        public String End_Customer_Name;
        public String Zonal_Head;
        public String Contact;
        public String WebOrderDate;
        public String Shipment;
        public String Shipmentaddress2;
        public String Shipmentcity;
        public String Postcode1;
        public String TransporterNo;
        public String EngineerID;
        public String IsSubmitted;
        public String SubmittedBy;
        public String SubmittedDate;
        public String Deactive;
        public String IsPostedToNav;
        // public String TechnoDocNo;
        public String ShipmentCode;

        // public String Document_Status;
        // public String Sales_Person;
        // public String Contact_Name;
        // public String Techno_Commercial_Offer;
        // public String PO_No;
        // public String PO_Date;
        // public String Valid_from;
        // public String Valid_To;
        // public String Reqd_Del_Date;
        // public String Transaction_Type;
        // public String Commission_Type;
        // public String Commission_Value;
        // public String Approval_Status;
        // public String Shipment;
        // public String Other_Terms_Conditions;
        // public String Inco_Terms;
        // public String Payment_Terms;
        // public String Delivery_Terms;
        // public String Inco_Terms_Remark;
        // public String Other_Payment_Terms;
        // public String Other_Delivery_Terms;
        // public String Pricelist;
        public List < SalesOrderLineItemClass > LineItems;
        public List < SalesOrderHeaderAttachments > HeaderAttachment;
    }

    public class SalesOrderLineItemClass {
        public String Item_Number;
        public String Item_Category;
        public String Cash_Discount;
        public String Quantity;
        public String UOM;
        public String Variant_Code;
        public String Sales_Price;
        public String Item_Value;
        public String Conversion_Quantity;
        public String Shipment_Date;
        public String Conversion_Factor;
        public String OrderProcessingHeaderId;
        public String Description;
        public String Description2;
        public String Location;
        public String RequestDispatchDate;
        public String Sale_Price_UOM;
        public String LineAmountExclTax;
        public String Status;
        public String Is_SOR;
        public String UnitPriceExcl;
        public String AvailableQuantity;
        public String OrderQty;
        public String QuantityDiscount;
        public String SpecialDiscount;
        public String LineDiscountAmount;
        public String QuantityIntoSaleUOM;
        public String AcceptedQuantity;
        public String Deactive;
        public String DocumentNo;
        public String TempLineNo;
        public String ItemDiscOn;
        public String ItemDiscGroup;
        public String SORType;
        public String SORRemark;
        public String WebOrderNo;
        public String DefaultShipmentDate;
        public String IsChangedShipDate;
        // public String TechnoDocNo;
        public String ChangedShipmentDate;
        public String WebOrderLineNo;
        public String ProductGroupCode;
        public List < SalesOrderLineAttachments > LineAttachment;
    }

    public class SalesOrderHeaderAttachments {
        public String Title;
        public String DocumentLink;
    }

    public class SalesOrderLineAttachments {
        public String Title;
        public String DocumentLink;
    }

    public static JSON2ApexSaveWebToLead parse(String json) {
        return (JSON2ApexSaveWebToLead) System.JSON.deserialize(json, JSON2ApexSaveWebToLead.class);
    }

    // public static String handlerInsertNewAccount(JSON2ApexSaveWebToLead jsonObj) {

    //     Account newAcc = new Account();
    //     newAcc.Name = jsonObj.CustomerNo;
    //     newAcc.Email_Id__c = jsonObj.Email_Id;
    //     insert newAcc;
    //     return newAcc.Id;
    // }

    public static String handlerInsertNewEnquiry(JSON2ApexSaveWebToLead jsonObj, String AccId) {

        Enquiry__c newEnquiry = new Enquiry__c();
        newEnquiry.Account__c = AccId;
        insert newEnquiry;
        return newEnquiry.Id;
    }

    // @future(callout=true)
    // public static void downloadAndInsertHeaderAtt(String docName, String docLink, String SOId) {
    //     ContentVersion contentVersion = new ContentVersion();
    //     contentVersion.Title = docName; 
    //     contentVersion.PathOnClient = docName;
    //     contentVersion.VersionData = Blob.valueOf(docLink); // Store link as data
    //     contentVersion.IsMajorVersion = true;
    //     insert contentVersion;
        
    //     // Link File to Account
    //     ContentDocumentLink contentLink = new ContentDocumentLink();
    //     contentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
    //     contentLink.LinkedEntityId = SOId; // Attach to Account
    //     contentLink.ShareType = 'V'; // View Only
    //     insert contentLink;
    // }

}