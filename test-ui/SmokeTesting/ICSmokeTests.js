StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region Scenario 3. Add IC Transactions
        .displayText('=====   Scenario 3. Add IC Transactions ====')

        //region Scenario 3.1: Add Direct IR for Non Lotted Item
        .displayText('=====  Scenario 3.1: Add Direct IR for Non Lotted Item =====')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')

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
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Non Lotted Item Done=====')

        //region Scenario 3.2. Create Direct Inventory Receipt for Lotted Item
        .displayText('=====  Scenario 3.2. Create Direct IR for Lotted Item  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Smoke_LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'ICSmoke - SL')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100000')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100000')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'Smoke_LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'ICSmoke - SL')

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
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')


        //region Scenario 3.3. Create Direct Inventory Shipment for Non Lotted Item
        .displayText('=====  Scenario 3.3. Create Direct Inventory Shipment for Non Lotted Item  =====')
        .clickMenuScreen('Inventory Shipments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryShipment', 1, 'colQuantity', '100')


        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'ICSmoke - SL')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')


        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion

        //region Scenario 3.4. Create Direct Inventory Shipment for Lotted Item
        .displayText('=====  Scenario 3.4. Create Direct Inventory Shipment for Lotted Item  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryshipment')
        .selectComboBoxRowNumber('OrderType',4,0)
        .selectComboBoxRowValue('Customer', 'ABC Trucking', 'Customer',1)
        .selectComboBoxRowValue('FreightTerms', 'Truck', 'FreightTerms',1)
        .selectComboBoxRowValue('ShipFromAddress', '0001 - Fort Wayne', 'ShipFromAddress',1)
        .selectComboBoxRowNumber('ShipToAddress',1,0)

        .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryShipment',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('InventoryShipment', 1, 'colQuantity', '100')
        .verifyGridData('InventoryShipment', 1, 'colUnitPrice', '14')
        .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryShipment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryShipment', 1, 'colStorageLocation', 'ICSmoke - SL')
        .verifyGridData('InventoryShipment', 1, 'colLineTotal', '1400')

        .selectGridComboBoxRowValue('LotTracking',1,'strLotId','LOT-01','strLotId')
        .enterGridData('LotTracking', 1, 'colShipQty', '100')
        .verifyGridData('LotTracking', 1, 'colLotUOM', 'Smoke_LB')
        .verifyGridData('LotTracking', 1, 'colGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'Smoke_LB')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
        //endregion


        //region Scenario 3.5. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location
        .displayText('===== Scenario 3.5. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location =====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','ICSmoke - SL','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Smoke_LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1500)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion

//        //region Scenario 3.6. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location
//        .displayText('===== Scenario 3.6. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location=====')
//        .clickMenuScreen('Inventory Transfers','Screen')
//        .waitUntilLoaded()
//        .clickButton('New')
//        .waitUntilLoaded('icinventorytransfer')
//        .verifyData('Combo Box','TransferType','Location to Location')
//        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
//        .verifyData('Combo Box','SourceType','None')
//        .selectComboBoxRowValue('ToLocation', '0002 - Indianapolis', 'ToLocation',1)
//        .enterData('Text Field','Description','Test Transfer')
//
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - LTI - 01','strItemNo')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','ICSmoke - SL','strFromStorageLocationName')
//        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
//        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'Smoke_LB')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
//        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
//        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')
//
//        .clickButton('PostPreview')
//        .waitUntilLoaded('cmcmrecaptransaction')
//        .waitUntilLoaded('')
//        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
//        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
//        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
//        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
//        .clickButton('Post')
//        .waitUntilLoaded('')
//        .addResult('Successfully Posted',1500)
//        .waitUntilLoaded('')
//        .clickButton('Close')
//        .waitUntilLoaded('')
//        .displayText('===== Create Inventory Transfer for Lotted Item Shipment Not Required Done =====')
//        //endregion



        //region Scenario 3.7. Inventory Adjustment Quantity Change Non Lotted Item
        .displayText('===== Scenario 3.7. Inventory Adjustment Quantity Change Non Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16040-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion

        //region Scenario 3.8. Inventory Adjustment Quantity Change Lotted Item
        .displayText('===== Scenario 3.8. Inventory Adjustment Quantity Change Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strSubLocation','Raw Station','strSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strStorageLocation','ICSmoke - SL','strStorageLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16040-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Inventory Transfer for Non Lotted Item Shipment Not Required Done =====')
        //endregion




        //region Scenario 9. Inventory Count - Lock Inventory
        .displayText('===== Scenario  9. Inventory Count - Lock Inventory =====')
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
            , 'PostPreview'
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

        .clickButton('PostPreview')
        .waitUntilLoaded('')
        .addResult('Clicking Recap',5000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','Inventory Count is ongoing for Item 87G and is locked under Location 0001 - Fort Wayne.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .displayText('===== Scenario 8. Inventory Count - Lock Inventory Done =====')
//        //endregion

        //region Scenario 9. Add new Storage Measurement Reading with 1 item only.
        .displayText('===== Scenario 1. Add new Storage Measurement Reading with 1 item only. ====')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .waitUntilLoaded()
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','Smoke Commodity','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','ICSmoke - SL','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Add new Storage Measurement Reading with 1 item only Done. ====')


        .displayText('=====  Add IC Transactions Done====')
        .done();

})
