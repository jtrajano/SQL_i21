StartTest (function (t) {
    var commonIC = Ext.create('i21.test.Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region Scenario 1. Inventory Count - Fetch Items
        .displayText('===== Scenario 1. Inventory Count - Fetch Items ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Count','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'Grains', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
        .clickCheckBox('IncludeZeroOnHand', true)
        .clickCheckBox('IncludeOnHand', true)
        .clickCheckBox('ScannedCountEntry', true)
        .clickCheckBox('CountByLots', true)
        .clickCheckBox('CountByPallets', true)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 1. Inventory Count - Fetch Items Done====')
        //endregion

        //region Scenario 2. Inventory Count - Print Count Sheets
        .displayText('===== Scenario  2. Inventory Count - Print Count Sheets =====')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'Grains', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'Corn', 'Commodity',1)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('PrintCountSheets')
        .waitUntilLoaded()
        .clickButton('Export')
        .clickButton('ExportExcel')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario  2. Inventory Count - Print Count Sheets Done =====')
        //endregion

        //region Scenario 3. Inventory Count - Lock Inventory
        .displayText('===== Scenario  3. Inventory Count - Lock Inventory =====')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'Gas', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'Gasoline', 'Commodity',1)
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
        .clickButton('Close')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','87G','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Gallon','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Gallon')
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

        .clickButton('Recap')
        .waitUntilLoaded('')
        .addResult('Clicking Recap',5000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','Inventory Count is ongoing for Item 87G and is locked under Location 0001 - Fort Wayne.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .displayText('===== Scenario 3. Inventory Count - Lock Inventory Done =====')
        //endregion

        //region Scenario 4: Update Inventory Count
        .displayText('===== Scenario 4: Update Inventory Count =====')
        .clickMenuScreen('Inventory Count','Screen')
        .doubleClickSearchRowValue('GAS', 'strCategory', 1)
        .waitUntilLoaded('')
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .displayText('===== Check Updated Fields =====')
        .doubleClickSearchRowValue('GAS', 'strCategory', 1)
        .isControlVisible('tlb',
        [
            'New'
            , 'LockInventory'
            , 'Save'
            , 'Delete'
            , 'Undo'
            , 'Close'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()

        .displayText('===== Check If User Can Create Transaction for the Unlocked Item=====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','87G','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Gallon','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Gallon')
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

        .clickButton('Recap')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')

        .displayText('===== Update Done=====')
        //endregion

        .done();


})