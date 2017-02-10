StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        .displayText('=====  Scenario 1. Create Inveentory Count  for Non Lotted Item then Delete Inventory Count =====')
        //Create NON Lotted Item.
        .displayText('===== Creating Non Lotted Item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .clickButton('New')
        .enterData('Text Field','ItemNo','ICNLTI - 05')
        .enterData('Text Field','Description','Non Lotted for Delete IC')
        .selectComboBoxRowValue('Category', 'Grains', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',3,0)
        .verifyData('Combo Box','Tracking','Item Level')

        .displayText('===== Setup Item UOM=====')
        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','LB','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure',0, 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .waitUntilLoaded('')
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '50')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '56')
        .verifyGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '55.1156')

        .displayText('===== Setup Item Location=====')
        .clickTab('Setup')
        .clickTab('Location')
        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'RM Bin 3', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')
        .waitUntilLoaded()

        .clickTab('Pricing')
        .waitUntilLoaded('')
        .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
        .enterGridData('Pricing', 1, 'dblLastCost', '10')
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== None Lotted Item Created =====')

        //Create inventory Receipt for Stock
        .displayText('=====  Creating Direct Inventory Receipt for SNLTI - 13 for Stock=====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','ICNLTI - 05','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '10000')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 1,000.00') {
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
            if (total == 'Net: 1,000.00') {
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
            if (total == 'Total: 10,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '10000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '10000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('=====  Creating Direct Inventory Receipt for Non Lotted Item Done=====')

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ICNLTI - 05', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Create Inventory Count
        .displayText('===== Scenario  3. Inventory Count - Lock Inventory =====')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'Grains', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',1)
        .selectComboBoxRowValue('StorageLocation', 'RM Bin 3', 'StorageLocation',1)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', '87G')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('PrintCountSheets')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .isControlVisible('tlb',
        [
            'PrintVariance'
            , 'LockInventory'
            , 'Post'
            , 'Recap'
        ], true)
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .doubleClickSearchRowValue('0001 - Fort Wayne', 'strLocationName', 1)
        .waitUntilLoaded()
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','ICNLTI - 05','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '10000')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 1,000.00') {
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
            if (total == 'Net: 1,000.00') {
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
            if (total == 'Total: 10,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '10000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '10000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('=====  Creating Direct Inventory Receipt for Non Lotted Item Done=====')
        .displayText('===== Create Inveentory Count  for Non Lotted Item then Delete Inventory Count Done =====')
        //endregion


        .displayText('=====  Scenario 2. Create Inveentory Count for Lotted Item then Delete Inventory Count =====')
        //Create NON Lotted Item.
        .displayText('===== Creating Lotted Item =====')
        .clickMenuScreen('Items','Screen')
        .clickButton('New')
        .enterData('Text Field','ItemNo','ICLTI - 06')
        .enterData('Text Field','Description','Non Lotted for Delete IC')
        .selectComboBoxRowValue('Category', 'Grains', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',1,0)
        .verifyData('Combo Box','Tracking','Lot Level')

        .displayText('===== Setup Item UOM=====')
        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','LB','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure',0, 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .waitUntilLoaded('')
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '50')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '56')
        .verifyGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '55.1156')

        .displayText('===== Setup Item Location=====')
        .clickTab('Setup')
        .clickTab('Location')
        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'RM Bin 3', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')
        .waitUntilLoaded()

        .clickTab('Pricing')
        .waitUntilLoaded('')
        .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
        .enterGridData('Pricing', 1, 'dblLastCost', '10')
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== None Lotted Item Created =====')

        //Create inventory Receipt for Stock
        .displayText('=====  Creating Direct Inventory Receipt for for Stock=====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','ICLTI - 06','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '10000')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '1000')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '1000')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '1000')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 1,000.00') {
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
            if (total == 'Net: 1,000.00') {
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
            if (total == 'Total: 10,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '10000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '10000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('=====  Creating Direct Inventory Receipt for Non Lotted Item Done=====')

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ICLTI - 06', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Create Inventory Count
        .displayText('===== Scenario  3. Inventory Count - Lock Inventory =====')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'Grains', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',1)
        .selectComboBoxRowValue('StorageLocation', 'RM Bin 3', 'StorageLocation',1)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', '87G')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('PrintCountSheets')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .isControlVisible('tlb',
        [
            'PrintVariance'
            , 'LockInventory'
            , 'Post'
            , 'Recap'
        ], true)
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .doubleClickSearchRowValue('0001 - Fort Wayne', 'strLocationName', 1)
        .waitUntilLoaded()
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','ICNLTI - 03','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '10000')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#lblGrossWgt').text;
            if (total == 'Gross: 1,000.00') {
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
            if (total == 'Net: 1,000.00') {
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
            if (total == 'Total: 10,000.00') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '10000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '10000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('=====  Creating Direct Inventory Receipt for Non Lotted Item Done=====')
        .displayText('===== Create Inveentory Count  for Lotted Item then Delete Inventory Count Done =====')

        //endregion
        .done();

})