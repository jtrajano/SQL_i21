StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region Scenario 1. Create Direct Inventory Receipt for Non Lotted Item then Delete IR
        .displayText('=====  Scenario 1. Create Direct Inventory Receipt for Non Lotted Item then Delete IR =====')
        .displayText('=====  Creating Direct Inventory Receipt for DNLTI - 01 =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowNumber('Location', 1,0)
        //.selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','DNLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 100.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblNetWgt').text;
            if (total == 'Net: 100.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('=====  Creating Direct Inventory Receipt for DNLTI - 01 Done=====')

        //Check On Hand Stock of the Item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
//        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .waitUntilLoaded('')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .waitUntilLoaded('')
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        //endregion


        //region Scenario 2. Create Direct Inventory Receipt for Lotted Item then Delete IR
        .displayText('=====  Scenario Scenario 2. Create Direct Inventory Receipt for Lotted Item then Delete IR =====')
        .displayText('=====  Creating Direct Inventory Receipt for DLTI - 02 =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowNumber('Location', 1,0)
//        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','DLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100000')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 100,000.00') {
                t.ok(true, 'Gross is correct.');
            }
            else {
                t.ok(false, 'Gross is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblNetWgt').text;
            if (total == 'Net: 100,000.00') {
                t.ok(true, 'Net is correct.');
            }
            else {
                t.ok(false, 'Net is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')

        //Check On Hand Stock of the Item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100000')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
//        .doubleClickSearchRowValue('Direct', 'strOrderType', 1)
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DLTI - 02')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')
        .clickButton('Unpost')
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        //endregion


        //region Scenario 3. Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR.
        .displayText('=====  Scenario 3. Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR. =====')
        .clickMenuFolder('Purchasing','Folder')
        .clickMenuScreen('Purchase Orders','Screen')
        .clickButton('New')
        .waitUntilLoaded('appurchaseorder')
        .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)
        .waitUntilLoaded('')
        .selectGridComboBoxRowValue('Items',1,'strItemNo','DNLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('Items',1,'strUOM','LB','strUOM')
        .enterGridData('Items', 1, 'colQtyOrdered', '100')
        .verifyGridData('Items', 1, 'colTotal', '1000')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Process')
        .addResult('Processing PO to IR',1000)
        .waitUntilLoaded('icinventoryreceipt')
        .waitUntilLoaded('')
        .verifyData('Combo Box','ReceiptType','Purchase Order')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Purchasing','Folder')
        .displayText('===== Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button" Done=====')

        //Check On Hand Stock of the Item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
         .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .addResult('',2000)
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('=====  Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR. Done =====')
        //endregion


        //region Scenario 4. Create Purchase Order Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR.
        .displayText('=====  Scenario 4. Create Purchase Order Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR. =====')

//        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
//        .clickMenuScreen('Purchase Orders','Screen')
//        .clickButton('New')
//        .waitUntilLoaded('appurchaseorder')
//        .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)
//        .waitUntilLoaded('')
//        .selectGridComboBoxRowValue('Items',1,'strItemNo','DNLTI - 01','strItemNo')
//        .selectGridComboBoxRowValue('Items',1,'strUOM','LB','strUOM')
//        .enterGridData('Items', 1, 'colQtyOrdered', '100')
//        .verifyGridData('Items', 1, 'colTotal', '1000')
//        .clickButton('Save')
//        .waitUntilLoaded('')
//        .clickButton('Close')
//        .waitUntilLoaded('')
//        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',2,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .waitUntilLoaded('')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryreceipt')
        .verifyData('Combo Box','ReceiptType','Purchase Order')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Purchase Order Inventory Receipt for Non Lotted Item "Process Button" Done=====')

        //Check On Hand Stock of the Item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
//        .doubleClickSearchRowValue('Purchase Order', 'strOrderType', 1)
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .addResult('',2000)
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('=====  Create Purchase Order Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR. Done =====')
        //endregion


        //region Scenario 5. Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR
        .displayText('=====  Scenario 5. Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR  =====')
        .clickMenuFolder('Contract Management','Folder')
        .clickMenuScreen('Contracts','Screen')
        .clickButton('New')
        .waitUntilLoaded('ctcontract')
        .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('Commodity', 'TestCorn', 'Commodity',1)
        .enterData('Text Field','Quantity','100')
        .selectComboBoxRowValue('CommodityUOM', 'LB', 'CommodityUOM',1)
        .selectComboBoxRowValue('Position', 'Arrival', 'Position',1)
        .selectComboBoxRowValue('PricingType', 'Cash', 'PricingType',1)
        .selectComboBoxRowValue('Salesperson', 'Bob Smith', 'Salesperson',1)
        .clickButton('AddDetail')
        .waitUntilLoaded('ctcontractsequence')
        .addFunction (function (next){
        var date = new Date().toLocaleDateString();
        new iRely.FunctionalTest().start(t, next)
            .enterData('Date Field','EndDate', date, 0, 10)
            .done();
        })
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectComboBoxRowValue('Item', 'DNLTI - 01', 'Item',1)
        .selectComboBoxRowValue('NetWeightUOM', 'LB', 'NetWeightUOM',1)
        .verifyData('Text Field','NetWeight','100.0000')
        .verifyData('Combo Box','PricingType','Cash')
        .verifyData('Combo Box','PriceCurrency','USD')
        .verifyData('Combo Box','CashPriceUOM','LB')
        .enterData('Text Field','CashPrice','10')
        .clickButton('Save')
        .waitUntilLoaded('ctcontract')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Process')
        .waitUntilLoaded('icinventoryreceipt')
        .waitUntilLoaded('')

        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('ctcontract')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Contract Management','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" Done =====')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
         .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .addResult('',2000)
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Process Button" then Delete the IR Done =====')


        //region Scenario 6. Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR
        .displayText('===== 6. Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',1,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .waitUntilLoaded('')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryreceipt')


        .verifyData('Combo Box','ReceiptType','Purchase Contract')
        .verifyData('Combo Box','Vendor','ABC Trucking')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', '100')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','LB','strWeightUOM')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblTotal').text;
            if (total == 'Total: 1,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete IR
        .displayText('===== Delete Non Lotted Inventory Receipt  =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .addResult('Successfully Opened',4000)
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'DNLTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',2000)
        .clickButton('Delete')
        .waitUntilLoaded()
        .addResult('',2000)
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Non Lotted Item Successfully Deleted=====')
        .clearTextFilter('FilterGrid')

        //Check ON hand stock of the item
        .displayText('=====  Checking ON Hand Stock of the item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('DNLTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        //.verifyGridData('Stock', 1, 'colStockUOM', 'LB')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '100')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .displayText('=====  On Hand Stock is Correct! =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Purchase Contract Inventory Receipt for Non Lotted Item "Add Orders Button" then Delete the IR Done =====')

        .done();

})