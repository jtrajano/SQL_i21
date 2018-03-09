StartTest (function (t) {
    var myDate = new Date();
    var randomNo=Math.floor((Math.random() * 1000000) + 1);
    var productID = 'NLTI-'  + randomNo + ' ' + myDate.toLocaleDateString('en-US') ;
    
    randomNo=Math.floor((Math.random() * 1000000) + 1);
    var productID2 = 'LTI-'  + randomNo + ' ' + myDate.toLocaleDateString('en-US') ; 
    
    new iRely.FunctionalTest().start(t)
   .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .addScenario('Duplicate LTI-01 to ' + productID2 ,'',1000)              
        .clickMenuFolder('Inventory')
        .waitUntilLoaded()
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .waitUntilLoaded()
        // .addFunction(function (next) {
        //                 t.chain(
        //                     { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch gridcolumn[text=Item No] => .x-column-header-text-wrapper" }
        //                 )
        //                 next();
        //             })
        // .waitUntilLoaded()
        // .waitUntilLoaded()
        // .waitUntilLoaded()
        // .addFunction(function (next) {
        //                 t.chain(
        //                 { click : "menu{isVisible()} #mnuFilter => .x-menu-item-text"}
        //                 )
        //                 next();
        //             })
        .waitUntilLoaded()
        .selectComboBoxRowNumber('Condition',2)             
        .enterData('Text Field','From','LTI-01' )
        .enterData('Text Field','From','[ENTER]' )
        .doubleClickSearchRowValue ('LTI-01','strItemNo',1)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Duplicate')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .enterData('Text Field','ItemNo',productID2)
        .enterData('Text Field','Description','Inventory ' + productID2 +' Desc' )
        .clickTab('Pricing')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
        .enterGridData('Pricing', 1, 'dblLastCost', '10')
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')
        .enterGridData('Pricing', 1, 'dblSalePrice', '14')
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        // .addFunction(function (next) {
        //             t.chain(
        //                 { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete" }
        //             )
        //             next();
        // })
        // .waitUntilLoaded()
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .enterData('Text Field','From','FREIGHT' )
        .enterData('Text Field','From','[ENTER]' )
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .doubleClickSearchRowValue ('FREIGHT','strItemNo',1)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .enterData('Text Field','FilterGrid','LB2' )
        .enterData('Text Field','FilterGrid','[ENTER]' )
        .waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdUnitOfMeasure').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('LB2 exists.')
                    .clickButton('Close')
                    .done();
                },
                failure: function(next){
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('UOM LB2 does not exists.')
                    .clearTextFilter('FilterGrid')
                    .enterData('Text Field','FilterGrid','[ENTER]' )
                    .clickButton('InsertUom')
                    .addFunction(function(next){
                        var win = Ext.WindowManager.getActive();
                        var recCount = win.down('#grdUnitOfMeasure').store.getCount();
                        new iRely.FunctionalTest().start(t, next)
                        .selectGridComboBoxRowValue('UnitOfMeasure',recCount,'colDetailUnitMeasure', 'LB2','strUnitMeasure',1) 
                        .enterGridData('UnitOfMeasure',recCount,'colDetailUnitQty','1' )
                        .done()
                    })
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded()
        .clickButton('Close') 
        .addScenario('7','Create Tax Class',1000)
        .clickMenuFolder('Common Info')
        .clickMenuScreen('Tax Class')
        .enterGridNewRow('GridTemplate', [{column: 'strTaxClass', data: 'Tax Class '  + randomNo}])
        .clickButton('Save')
        .clickButton('Close')
        .addScenario('7','Create Tax Codes',1000)
        .clickMenuScreen('Tax Codes')
        .clickButton('New')
        .waitUntilLoaded()
        .enterData('Text Field','TaxCode','Tax Code '  + randomNo)
        .selectComboBoxRowValue('TaxClass', 'Tax Class '  + randomNo, 'TaxClassID',1)
        .enterData('Text Field','Description','Tax Class Description')
        .selectComboBoxRowValue('TaxAgency', 'Fort Wayne', 'TaxAgencyID',1)
        .enterData('Text Field','Address','Sample Address')
        .enterData('Text Field','ZipCode','46801')
        .enterData('Text Field','City','Fort Wayne')
        .enterData('Text Field','State','Indiana')
        .selectComboBoxRowValue('Country', 'United States', 'Country',1)
        .verifyCheckboxValue('MatchTaxAddress', true )
        .selectComboBoxRowNumber('SalesTaxAccount',1)
        .selectComboBoxRowNumber('PurchaseTaxAccount',1)
        .enterGridNewRow('TaxCodeRate', [{column: 'colEffectiveDate', data: '1/1/2015'}])
        .selectGridComboBoxRowValue('TaxCodeRate',1,'colCalculationMethod', 'Percentage' ,'strCalculationMethod',1) 
        .enterGridData('TaxCodeRate',1,'colRate',10)
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .addScenario('7','Create Tax Group',1000)
        .clickMenuScreen('Tax Groups')
        .clickButton('New')
        .enterData('Text Field','TaxGroup','Tax Group ' + randomNo)
        .enterData('Text Field','Description','Tax Group Description')
        .selectGridComboBoxRowValue('TaxGroup',1,'colTaxCode', 'Tax Code '  + randomNo ,'strTaxCode',1) 
        .clickButton('Save')
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .addScenario('7','Tax Group for location',1000)
        //.clickMenuFolder('Common Info')
        .clickMenuScreen('Company Locations')
        .waitUntilLoaded()
        //.doubleClickSearchRowValue('0001 - Fort Wayne', 'strLocationName', 1)
        
        .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Company Locations]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
        .waitUntilLoaded()
        .doubleClickSearchRowValue('0001-Fort Wayne', 'strLocationName', 1)
        .waitUntilLoaded()
        .clickTab('Setup')
        .waitUntilLoaded()
        //.selectComboBoxRowValue('TaxGroup', 'IN', 'TaxGroupId',1)
        .selectComboBoxRowValue('TaxGroup', 'Tax Group ' + randomNo, 'TaxGroupId',1)
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close') 
         .waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .clickMenuFolder('Purchasing (A/P)')
        .waitUntilLoaded()
        .clickMenuScreen('Vendors')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('0001005057', 'strVendorID', 1)//ABC Trucking
        .waitUntilLoaded()
        .clickTab('Locations')
        .waitUntilLoaded()
        .selectGridRowNumber('Location',1)
        .waitUntilLoaded()
        .clickButton('EditLoc')
        .enterData('Text Field','PrintedName','Printed Name')
        .selectComboBoxRowValue('TaxGroup', 'Tax Group ' + randomNo, 'TaxGroupId',1)
        .selectComboBoxRowValue('FreightTerm', 'Deliver', 'FreightTermId',1)
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .done()
    })
   
   .addScenario('7','Create Inventory Receipt',1000)
   .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .waitUntilLoaded()
        .clickMenuFolder('Inventory')
        .waitUntilLoaded()
        .clickMenuScreen('Inventory Receipts')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4) 
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1) 
        .clickButton('InsertInventoryReceipt')
        .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colItemNo', productID2, 'strItemNo')
        .waitUntilLoaded()
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',100, 'LB2')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'colSubLocation', 'Raw Station','strSubLocationName',1) 
        .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage', 'strStorageLocationName')
        .selectGridRowNumber('InventoryReceipt', 1)
        .enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]')
        .enterGridData('LotTracking',1,'colLotQuantity',100 +'[ENTER]')
        .clickTab('FreightInvoice')
        .waitUntilLoaded()
        .selectGridComboBoxRowValue('Charges',1,'colOtherCharge', 'FREIGHT','strItemNo',1)
        .selectGridComboBoxRowValue('Charges',1,'colCostMethod', 'Per Unit','strCostMethod',1)  
        .selectGridComboBoxRowValue('Charges',1,'colChargeUOM', 'LB2','strCostUOM',1)        
        .enterGridData('Charges',1,'colRate',.15)
        .selectGridComboBoxRowValue('Charges',1,'colChargeTaxGroup', 'Tax Group ' + randomNo,'strTaxGroup',1)
        //.clickGridCheckBox('Charges',1 , 'strItemNo', 'FREIGHT', 'ysnAccrue', true)
        .selectGridComboBoxRowValue('Charges',1,'colCostVendor', 'ABC Trucking','strVendorName',1)
        .clickButton('CalculateCharges')
        .clickButton('Save').waitUntilLoaded()
        .clickTab('Post Preview').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .displayText('Other Expense')
        .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 15)
        .displayText('Other Payables')
        .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 15)
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 3 ,'dblDebit' , 1000)
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 4 ,'dblCredit' , 1000)
        .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
            })
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .doubleClickSearchRowValue (productID2,'strItemNo',1)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 100)
        .verifyGridData ('Stock', 1 ,'dblAvailable' , 100)
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .done()
    })
   .addScenario('7','Create Inventory Return',1000) 
   .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .waitUntilLoaded()
        .clickMenuScreen('Inventory Receipts')
        .waitUntilLoaded()
        .doubleClickSearchRowNumber (1)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Return')
        .addFunction(function(next){
                var msg = document.querySelector('.sweet-alert'),
                    message = msg.querySelector('p').innerHTML;
                if (msg){
                    if(msg.querySelector('p').innerHTML === message){
                    new iRely.FunctionalTest().start(t, next)
                    .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                    .displayText(msg.querySelector('p').innerHTML)
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickMessageBoxButton('yes')
                    .done()
                    }else{
                        new iRely.FunctionalTest().start(t, next)
                        .displayText('Skip message')
                        .done()
                    }
                
                }
        })
        .waitUntilLoaded()
        .addFunction(function(next){
                var msg = document.querySelector('.sweet-alert'),
                    message = msg.querySelector('p').innerHTML;
                if (msg){
                    if(msg.querySelector('p').innerHTML === message){
                    new iRely.FunctionalTest().start(t, next)
                    .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                    .displayText(msg.querySelector('p').innerHTML)
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickMessageBoxButton('yes')
                    .done()
                    }else{
                        new iRely.FunctionalTest().start(t, next)
                        .displayText('Skip message')
                        .done()
                    }
                
                }
        })
        .waitUntilLoaded()
        .selectGridRowNumber('InventoryReceipt', 1)
        .waitUntilLoaded()
        .verifyData('Combo Box', 'ReceiptType', 'Inventory Return', 'equal')
        .waitUntilLoaded()
        .verifyData('Combo Box', 'SourceType', 'None', 'equal')
        .waitUntilLoaded()
        .verifyData('Combo Box', 'Vendor', 'ABC Trucking', 'equal')
        .waitUntilLoaded()
        .verifyData('Combo Box', 'Location', '0001-Fort Wayne', 'equal')
        .waitUntilLoaded()
        .verifyData('Text Field','ReceiptNumber', 'RTN-','like')
        .waitUntilLoaded()
        .verifyGridData ('InventoryReceipt', 1 ,'dblOrderQty' , 0,'equal')
        .waitUntilLoaded()
        .verifyGridData ('InventoryReceipt', 1 ,'dblReceived' ,0,'equal')
        .waitUntilLoaded()
        .verifyUOMGridData('InventoryReceipt', 1, 'dblOpenReceive', 100, 'LB2', 'equal')
        .waitUntilLoaded()
        .verifyGridData ('InventoryReceipt', 1 ,'dblUnitCost' , 10,'equal')
        .selectGridRowNumber('InventoryReceipt', 1)
        .waitUntilLoaded()
        .verifyGridData ('LotTracking', 1 ,'dblQuantity' , 100,'equal')//100         
        .waitUntilLoaded()
        .verifyGridData ('LotTracking', 1 ,'dblGrossWeight' , 100,'equal')//100
        .waitUntilLoaded()
        .verifyGridData ('LotTracking', 1 ,'dblTareWeight' , 0,'equal')  
        .waitUntilLoaded()
        .verifyGridData ('LotTracking', 1 ,'dblNetWeight' ,100,'equal')//100
        .waitUntilLoaded()
        .verifyGridData ('InventoryReceipt', 2 ,'dblOrderQty' , 0,'equal')
        .waitUntilLoaded()
        // .addFunction(function (next){
        //     var today =  new Date().toLocaleDateString();
        //     var engine = new iRely.FunctionalTest();
        //     engine.start(t,next)
        //         .displayText('Checks if the Post Date is set to current system date.')
        //         .verifyData('Date Field', 'ReceiptDate', today, 'equal')
        //         .done()
        // })
        .isControlReadOnly('Combo Box',['ReceiptType','SourceType','Vendor','Location', 'Currency','Receiver','ShipFrom','ShipVia','FreightTerms'],true)
        .isControlReadOnly('Text Field',['ReceiptNumber','BillOfLadingNumber','VendorRefNumber','WarehouseRefNo', 'FobPoint','Vessel','ShiftNumber'],true)
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickTab('Post Preview')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000)
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 1000)
        .clickButton('Post')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Close')
        //.clickButton('DebitMemo')
        .waitUntilLoaded()
        .doubleClickSearchRowNumber (1)
        .waitUntilLoaded()
        //.clickButton('DebitMemo')
        .addFunction(function (next) {
                t.chain(
                    { 
                        click : "#frmInventoryReceipt #payBillsDetailToolbar #btnDebitMemo => .x-btn-inner-i21-button-toolbar-small" , offset : [13, 8]
                        
                    }//13,8
                )
                next();
            })
         
        .waitUntilLoaded()
        .waitUntilLoaded()
        .addFunction(function(next){
                var msg = document.querySelector('.sweet-alert'),
                    message = msg.querySelector('p').innerHTML;
                if (msg){
                    if(msg.querySelector('p').innerHTML === message){
                    new iRely.FunctionalTest().start(t, next)
                    .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                    .displayText(msg.querySelector('p').innerHTML)
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickMessageBoxButton('yes')
                    .done()
                    }else{
                        new iRely.FunctionalTest().start(t, next)
                        .displayText('Skip message')
                        .done()
                    }
                
                }
        })
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Post')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()        
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuScreen('Inventory Receipts')
        .waitUntilLoaded()
        .clickButton('Refresh')
        .waitUntilLoaded()
        .doubleClickSearchRowNumber (2)
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .verifyData('Text Field', 'Charges', '15.00', 'equal')
        // .getControlValue('Text Field', 'Charges','varcharge')

        // .addFunction(function (next){
        //         new iRely.FunctionalTest().start(t, next)
        //         window['varcharge']=15
            
        //         .done()
        // })
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .done() 
    })
   .addScenario('8','Create Inventory Receipt',1000)
   .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .waitUntilLoaded()
        .clickMenuScreen('Inventory Receipts')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4) 
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1) 
        .clickButton('InsertInventoryReceipt')
        .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colItemNo', productID2, 'strItemNo')
        .waitUntilLoaded()
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',100, 'LB2')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'colSubLocation', 'Raw Station','strSubLocationName',1) 
        .selectGridComboBoxRowValue('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage', 'strStorageLocationName')
        .selectGridRowNumber('InventoryReceipt', 1)
        .enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]')
        .enterGridData('LotTracking',1,'colLotQuantity',100 +'[ENTER]')
        .clickButton('Save').waitUntilLoaded()
        .clickTab('Post Preview').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000)
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 2 ,'dblCredit' , 1000)
        .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
         })
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .doubleClickSearchRowValue (productID2,'strItemNo',1)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 100)
        .verifyGridData ('Stock', 1 ,'dblAvailable' , 100)
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        
        .done()
   })
    .addScenario('8','Create Inventory Shipments',1000)
    .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .clickMenuScreen('Inventory Shipments')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowNumber('OrderType',4) 
        .selectComboBoxRowValue('Customer', 'Apple Spice', 'EntityCustomerId',1) 
        .selectComboBoxRowValue('FreightTerms', 'Deliver', 'FreightTermId',1) 
        .selectGridComboBoxRowValue('InventoryShipment', 1, 'colItemNumber', productID2, 'strItemNo')
         .waitUntilLoaded()
        .enterUOMGridData('InventoryShipment', 1, 'colGumQuantity', 'strUnitMeasure',20, 'LB2')
        .selectGridRowNumber('InventoryShipment', 1)
        //.enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]')
        .selectGridComboBoxRowValue('LotTracking', 1, 'colLotID','LOT-01', 'strLotId') 
        .enterGridData('LotTracking',1,'colShipQty',20)
        .clickButton('Save').waitUntilLoaded()
        .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        .addFunction(function (next) {
                t.chain(
                    { click : "#floatingPnlIntegratedDashboard #searchTabPanel panel[title=Items]#mainTab #grdSearch #pnlFilter #con0 #cboColumns => .x-form-text" }
                )
                next();
         })
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .doubleClickSearchRowValue (productID2,'strItemNo',1)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 80)
        .verifyGridData ('Stock', 1 ,'dblAvailable' , 80)
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .done()
      }) 
    .addScenario('8','Create Inventory Adjustments',1000)
    .addFunction(function(next){
            new iRely.FunctionalTest().start(t, next)
            .clickMenuScreen('Inventory Adjustments')
            .waitUntilLoaded()
            
            .waitUntilLoaded()
            .clickButton('New')
            .selectGridComboBoxRowValue('InventoryAdjustment', 1, 'colItemNumber', productID2, 'strItemNo')
            //.selectGridComboBoxRowValue('InventoryAdjustment', 1, 'colLotNumber', 'LOT-01' + '[TAB]', 'strLotNumber')
            .selectGridComboBoxRowValue('InventoryAdjustment', 1, 'colSubLocation', 'Raw Station', 'strSubLocation')
            .selectGridComboBoxRowValue('InventoryAdjustment', 1, 'colStorageLocation', 'RM Storage', 'strStorageLocation')
            .selectGridComboBoxRowValue('InventoryAdjustment', 1, 'colLotNumber','LOT-01', 'strLotNumber') 
           
            //.enterGridData('InventoryAdjustment',1,'colQuantity','dblQuantity' + '[TAB]')
            .enterGridData('InventoryAdjustment',1,'colAdjustByQuantity',-5)
            .waitUntilLoaded()
            .clickButton('Post')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            .done()
      })
    .addScenario('8','Create Inventory Return',1000) 
    .addFunction(function(next){
            new iRely.FunctionalTest().start(t, next)
            .waitUntilLoaded()
            .clickMenuScreen('Inventory Receipts')
            .waitUntilLoaded()
            .clickButton('Refresh')
            .waitUntilLoaded()
            .doubleClickSearchRowNumber (1)
            .waitUntilLoaded()
            .waitUntilLoaded()
            .clickButton('Return')
            .addFunction(function(next){
                    var msg = document.querySelector('.sweet-alert'),
                        message = msg.querySelector('p').innerHTML;
                    if (msg){
                        if(msg.querySelector('p').innerHTML === message){
                        new iRely.FunctionalTest().start(t, next)
                        .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                        .displayText(msg.querySelector('p').innerHTML)
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickMessageBoxButton('yes')
                        .done()
                        }else{
                            new iRely.FunctionalTest().start(t, next)
                            .displayText('Skip message')
                            .done()
                        }
                    
                    }
            })
            .waitUntilLoaded()
            .addFunction(function(next){
                    var msg = document.querySelector('.sweet-alert'),
                        message = msg.querySelector('p').innerHTML;
                    if (msg){
                        if(msg.querySelector('p').innerHTML === message){
                        new iRely.FunctionalTest().start(t, next)
                        .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'yesno', 'warning')
                        .displayText(msg.querySelector('p').innerHTML)
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickMessageBoxButton('yes')
                        .done()
                        }else{
                            new iRely.FunctionalTest().start(t, next)
                            .displayText('Skip message')
                            .done()
                        }
                    
                    }
            })
            .waitUntilLoaded()
            .selectGridRowNumber('InventoryReceipt', 1)
            .waitUntilLoaded()
             .waitUntilLoaded()
             .waitUntilLoaded()
             .waitUntilLoaded()
            .addFunction(function (next) {
                t.chain(
                    { click : "#frmInventoryReceipt #tabInventoryReceipt #pgeDetails #pnlItem #grdInventoryReceipt #grvInventoryReceipt => .x-grid-item:nth-of-type(1) .x-grid-cell-colUOMQtyToReceive .x-grid-cell-inner" }
                )
                next();
            })
            .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',80, 'LB2')
            .selectGridRowNumber('InventoryReceipt', 1).waitUntilLoaded()
           
            
            .waitUntilLoaded().waitUntilLoaded()
            .enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]')
            .enterGridData('LotTracking',1,'colLotQuantity',80 +'[ENTER]')
            .clickButton('Save').waitUntilLoaded()
            .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .waitUntilLoaded()

            .addFunction(function(next){
                var msg = document.querySelector('.sweet-alert'),
                    message = msg.querySelector('p').innerHTML;
                if (msg){
                    if(msg.querySelector('p').innerHTML === message){
                    new iRely.FunctionalTest().start(t, next)
                    .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'ok', 'error')
                    .displayText(msg.querySelector('p').innerHTML)
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .clickMessageBoxButton('ok')
                    .done()
                    }else{
                        new iRely.FunctionalTest().start(t, next)
                        .displayText('Skip message')
                        .done()
                    }
                
                }
            })
            .waitUntilLoaded()
            .selectGridRowNumber('InventoryReceipt', 1)
            .waitUntilLoaded()
             .addFunction(function (next) {
                t.chain(
                    { click : "#frmInventoryReceipt #tabInventoryReceipt #pgeDetails #pnlItem #grdInventoryReceipt #grvInventoryReceipt => .x-grid-item:nth-of-type(1) .x-grid-cell-colUOMQtyToReceive .x-grid-cell-inner" }
                )
                next();
            })
            .waitUntilLoaded().waitUntilLoaded()
            .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',75, 'LB2')
            .waitUntilLoaded()
            .selectGridRowNumber('InventoryReceipt', 1)
            .waitUntilLoaded()
           

            .waitUntilLoaded()
            .enterGridData('LotTracking',1,'colLotId','LOT-01' + '[TAB]')
            .enterGridData('LotTracking',1,'colLotQuantity',75 +'[ENTER]')
            .clickButton('Save').waitUntilLoaded()
            .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            .done()
     })

    // .clickMenuFolder('Inventory')
    // .clickMenuFolder('Common Info')
    // .clickMenuFolder('Purchasing (Accounts Payable)')
    .done()
})