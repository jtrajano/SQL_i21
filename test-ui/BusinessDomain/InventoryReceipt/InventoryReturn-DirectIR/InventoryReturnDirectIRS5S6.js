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
        //.clickTab('Item')
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        // .waitUntilLoaded()
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
        // .addFunction(function (next) {
        //             t.chain(
        //                 { click : "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete" }
        //             )
        //             next();
        // })
        .clickButton('Close')
        .done()
    })
   
   .addScenario('5','Create Inventory Receipt',1000)
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
        .clickButton('InsertInventoryReceipt')
        .selectGridComboBoxRowValue('InventoryReceipt', 2, 'colItemNo', productID2, 'strItemNo')
        .waitUntilLoaded()
        .enterUOMGridData('InventoryReceipt', 2, 'colUOMQtyToReceive', 'strUnitMeasure',100, 'LB2')
        .selectGridComboBoxRowValue('InventoryReceipt',2,'colSubLocation', 'Raw Station','strSubLocationName',1) 
        .selectGridComboBoxRowValue('InventoryReceipt', 2, 'colStorageLocation', 'RM Storage', 'strStorageLocationName')
        .selectGridRowNumber('InventoryReceipt', 2)
        .enterGridData('LotTracking',1,'colLotId','LOT-02' + '[TAB]')
        .enterGridData('LotTracking',1,'colLotQuantity',100 +'[ENTER]')
        .clickButton('Save').waitUntilLoaded()
        .clickTab('Post Preview').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000)
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 2 ,'dblDebit' , 1000)
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 3 ,'dblCredit' , 1000)
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 4 ,'dblCredit' , 1000)
        .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        //.clickTab('Item')
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
        .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 200)
        .verifyGridData ('Stock', 1 ,'dblAvailable' , 200)
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .done()
    })
   .addScenario('5','Create Inventory Return',1000) 
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
        .verifyGridData ('InventoryReceipt', 2 ,'dblReceived' ,0,'equal')
        .waitUntilLoaded()
        .verifyUOMGridData('InventoryReceipt', 2, 'dblOpenReceive', 100, 'LB2', 'equal')
        .waitUntilLoaded()
        .verifyGridData ('InventoryReceipt', 2 ,'dblUnitCost' , 10,'equal')
        .selectGridRowNumber('InventoryReceipt', 2)
        .waitUntilLoaded()
        .verifyGridData ('LotTracking', 1 ,'dblQuantity' , 100,'equal')//100         
        .waitUntilLoaded()
        .verifyGridData ('LotTracking', 1 ,'dblGrossWeight' , 100,'equal')//100
        .waitUntilLoaded()
        .verifyGridData ('LotTracking', 1 ,'dblTareWeight' , 0,'equal')  
        .waitUntilLoaded()
        .verifyGridData ('LotTracking', 1 ,'dblNetWeight' ,100,'equal')//100
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
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 2 ,'dblDebit' , 1000)
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 3 ,'dblCredit' , 1000)
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 4 ,'dblCredit' , 1000)
        .clickButton('Post')
        .waitUntilLoaded()
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
        .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 0)
        .verifyGridData ('Stock', 1 ,'dblAvailable' , 0)
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .done() 
    })
   .addScenario('6','Create Inventory Receipt 2',1000) 
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
        .clickButton('InsertInventoryReceipt')
        .selectGridComboBoxRowValue('InventoryReceipt', 2, 'colItemNo', productID2, 'strItemNo')
        .waitUntilLoaded()
        .enterUOMGridData('InventoryReceipt', 2, 'colUOMQtyToReceive', 'strUnitMeasure',100, 'LB2')
        .selectGridComboBoxRowValue('InventoryReceipt',2,'colSubLocation', 'Raw Station','strSubLocationName',1) 
        .selectGridComboBoxRowValue('InventoryReceipt', 2, 'colStorageLocation', 'RM Storage', 'strStorageLocationName')
        .selectGridRowNumber('InventoryReceipt', 2)
        .enterGridData('LotTracking',1,'colLotId','LOT-02' + '[TAB]')
        .enterGridData('LotTracking',1,'colLotQuantity',100 +'[ENTER]')
        .clickButton('Save').waitUntilLoaded()
        .clickTab('Post Preview').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 1 ,'dblDebit' , 1000)
        .displayText('Inventory Account')
        .verifyGridData ('RecapTransaction', 2 ,'dblDebit' , 1000)
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 3 ,'dblCredit' , 1000)
        .displayText('AP Clearing Account')
        .verifyGridData ('RecapTransaction', 4 ,'dblCredit' , 1000)
        .clickButton('Post').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
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
        .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 200)
        .verifyGridData ('Stock', 1 ,'dblAvailable' , 200)
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .done()
    })
   .addScenario('6','Create Inventory Return 2',1000) 
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
        .waitUntilLoaded()
        .addFunction(function (next) {
            t.chain(
                { click : "#frmInventoryReceipt #tabInventoryReceipt #pgeDetails #pnlItem #grdInventoryReceipt #grvInventoryReceipt => .x-grid-item:nth-of-type(1) .x-grid-cell-colUOMQtyToReceive .x-grid-cell-inner" }
            )
            next();
        })
        .waitUntilLoaded().waitUntilLoaded()
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',100, 'LB2')
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
        .selectGridRowNumber('InventoryReceipt', 2)
        .waitUntilLoaded()
        .clickButton('RemoveInventoryReceipt')
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
        .clickButton('Close') 
        .waitUntilLoaded()
        .clickButton('Close') 
        .waitUntilLoaded()
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
   .addScenario('6','Create Inventory Return 3',1000) 
   .addFunction(function(next){
        new iRely.FunctionalTest().start(t, next)
        .waitUntilLoaded()
        .clickMenuScreen('Inventory Receipts')
        .waitUntilLoaded()
        .clickButton('Refresh')
        .waitUntilLoaded()
        .doubleClickSearchRowNumber (2)
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
        .selectGridRowNumber('InventoryReceipt',1)
        .waitUntilLoaded()
        .addFunction(function (next) {
            t.chain(
                { click : "#frmInventoryReceipt #tabInventoryReceipt #pgeDetails #pnlItem #grdInventoryReceipt #grvInventoryReceipt => .x-grid-item:nth-of-type(1) .x-grid-cell-colUOMQtyToReceive .x-grid-cell-inner" }
            )
            next();
        })
        .waitUntilLoaded().waitUntilLoaded()
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',100, 'LB2')
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
        .clickButton('Close') 
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Close')
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
        .verifyGridData ('Stock', 1 ,'dblUnitOnHand' , 0)
        .verifyGridData ('Stock', 1 ,'dblAvailable' , 0)
        .waitUntilLoaded()
        .clickButton('Close')
         .waitUntilLoaded()
        .clickButton('Close')
        .done() 
    })
    //.clickMenuFolder('Inventory')
    .done()
})