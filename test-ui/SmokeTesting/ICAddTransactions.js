StartTest (function (t) {
    var commonICST = Ext.create('Inventory.CommonICSmokeTest');
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)



        //Create Direct IR for Lotted Item with other charges
        .displayText('===== Scenario 1: Direct IR for Lotted Item with other charges  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowNumber('Vendor',1,0)
        .selectComboBoxRowNumber('Location',1,0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'LB')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        //Calculate Charge Amount
        .clickTab('FreightInvoice')
        .selectGridComboBoxRowValue('Charges',1,'strItemNo','FRT','strItemNo')
        .selectGridComboBoxRowNumber('Charges',1,'colCostMethod',2)
        .selectGridComboBoxRowValue('Charges',1,'strCurrency','USD','strCurrency')
        .enterGridData('Charges', 1, 'colRate', '10')
        .clickGridCheckBox('Charges',0, 'strItemNo', 'FRT', 'ysnAccrue', true)

        .clickButton('CalculateCharges')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .addResult('Successfully Calculated',2000)
        .waitUntilLoaded()
        .waitUntilLoaded()
        .addResult('Successfully Calculated',2000)

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('FreightInvoice')
        .waitUntilLoaded('')
        .verifyGridData('Charges', 1, 'colChargeAmount', '100')
        .clickButton('Save')
        .waitUntilLoaded()

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickTab('FreightInvoice')
        .waitUntilLoaded('')
        .verifyGridData('Charges', 1, 'colChargeAmount', '100')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('=====  Scenario 1: Done: IR with Charges  =====')


        //Create Direct IR for Non Lotted Item
        .displayText('===== Scenario 2: Create Direct IR for Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'Smoke - NLTI - 01','LB', 1000, 10)
        })

        //Create Direct IR for Lotted Item
        .displayText('===== Scenario 3: Create Direct IR for Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'Smoke - LTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })

        //Create PO to IR for Non Lotted Item Add Orders Screen
        .displayText('===== Scenario 6: Create PO to IR for Non Lotted Item Add Orders Screen =====')
        .addFunction(function(next){
            commonIC.addPOtoIRAddOrdersButtonNonLotted (t,next, 'ABC Trucking', '0001 - Fort Wayne', 'Smoke - NLTI - 01','LB', 1000, 10)
        })

        //Create PO to IR for Lotted Item  Add Orders Screen
        .displayText('===== Scenario 7: Create PO to IR for Lotted Item  Add Orders Screen =====')
        .addFunction(function(next){
            commonIC.addPOtoIRAddOrdersButtonLotted (t,next, 'ABC Trucking', '0001 - Fort Wayne', 'Smoke - LTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })

        //Create CT to IR for Non Lotted Item Add Orders Button
        .displayText('===== Scenario 8: Create CT to IR for Non Lotted Item Add Orders Button =====')
        .addFunction(function(next){
            commonIC.addCTtoIRAddOrdersButtonNonLotted (t,next, 'ABC Trucking','SC - Commodity - 01','0001 - Fort Wayne', 'Smoke - NLTI - 01','LB', 1000, 10)
        })

        //Create CT to IR for Non Lotted Item Add Orders Button
        .displayText('===== Scenario 9: Create PO to IR for Lotted Item  Add Orders Button =====')
        .addFunction(function(next){
            commonIC.addCTtoIRAddOrdersButtonLotted (t,next, 'ABC Trucking', 'SC - Commodity - 01' ,'0001 - Fort Wayne', 'Smoke - LTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })

        //Create Direct IS for Non Lotted Item
        .displayText('===== Scenario 10: Create Direct IS for Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectISNonLotted (t,next, 'Apple Spice Sales', 'Truck', 'USD', '0001 - Fort Wayne','Smoke - NLTI - 01','LB', 100)
        })


        //Create Direct IS for Non Lotted Item
        .displayText('===== Scenario 11: Create Direct IS for Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectISLotted (t,next, 'Apple Spice Sales', 'Truck', 'USD', '0001 - Fort Wayne', 'Smoke - LTI - 01','LB', 100, 'LOT-01')
        })


        //region Scenario 6. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location
        .displayText('===== Scenario 6. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowNumber('ToLocation',2,0)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - NLTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
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
        .displayText('===== Scenario 6. Create Inventory Transfer for Non Lotted Item Shipment Not Required Location to Location Done=====')
        //endregion


        //region Scenario 7. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location
        .displayText('===== Scenario 7. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location=====')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowNumber('ToLocation',2,0)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
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
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 7. Create Inventory Transfer for Lotted Item Shipment Not Required Location to Location Done =====')
        //endregion


        //region Scenario 8. Create Inventory Transfer for Lotted Item Shipment Required Different Location
        .displayText('===== Scenario 8. Create Inventory Transfer for Lotted Item Shipment Required Location to Location =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventorytransfer')
        .verifyData('Combo Box','TransferType','Location to Location')
        .verifyData('Combo Box','FromLocation','0001 - Fort Wayne')
        .verifyData('Combo Box','SourceType','None')
        .selectComboBoxRowNumber('ToLocation',2,0)
        .clickCheckBox('ShipmentRequired', true)
        .enterData('Text Field','Description','Test Transfer')

        .selectGridComboBoxRowValue('InventoryTransfer',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromSubLocationName','Raw Station','strFromSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strFromStorageLocationName','RM Storage','strFromStorageLocationName')
        .verifyGridData('InventoryTransfer', 1, 'colOwnershipType', 'Own')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strLotNumber','LOT-01','strLotNumber')
        .verifyGridData('InventoryTransfer', 1, 'colAvailableUOM', 'LB')
        .enterGridData('InventoryTransfer', 1, 'colTransferQty', '100')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToSubLocationName','Indy','strToSubLocationName')
        .selectGridComboBoxRowValue('InventoryTransfer',1,'strToStorageLocationName','Indy Storage','strToStorageLocationName')

        .clickButton('PostPreview')
        .waitUntilLoaded('')
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

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',3,0)
        .selectComboBoxRowNumber('Transferor',1,0)
        .doubleClickSearchRowValue('Smoke - LTI - 01', 'strItemNo', 1)
        .waitUntilLoaded('')
        .verifyData('Combo Box','ReceiptType','Transfer Order')
        .verifyData('Combo Box','Transferor','0001 - Fort Wayne')
        .verifyData('Combo Box','Location','0002 - Indianapolis')
        .verifyData('Combo Box','Currency','USD')
        .verifyGridData('InventoryReceipt', 1, 'colItemNo', 'Smoke - LTI - 01')
        .verifyGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Indy')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'Indy Storage')

        .selectGridRowNumber('InventoryReceipt', [1])

        .waitTillLoaded()
        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', '100')
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'Indy Storage')


        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 8: Create Inventory Transfer for Non Lotted Item Shipment Required Location to Location Done =====')
        //endregion



        //region Scenario 9. Inventory Adjustment Quantity Change Non Lotted Item
        .displayText('===== Scenario 9. Inventory Adjustment Quantity Change Non Lotted Item=====')
        .clickMenuFolder('Inventory','Folder')
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
        .displayText('===== Scenario 9. Inventory Adjustment Quantity Change Non Lotted Item Done =====')
        //endregion

        //region Scenario 10. Inventory Adjustment Quantity Change Lotted Item
        .displayText('===== Scenario 10. Inventory Adjustment Quantity Change Lotted Item =====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowNumber('InventoryAdjustment',1,'colLotNumber',1)
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '100')
        .verifyGridData('InventoryAdjustment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryAdjustment', 1, 'colStorageLocation', 'RM Storage')
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
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 10. Inventory Adjustment Quantity Change Lotted Item =====')
        //endregion


         //region Scenario 11. Inventory Adjustment Lot Move Lotted Item
        .displayText('===== Scenario 11. Inventory Adjustment Quantity Change Lotted Item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',8,0)
        .enterData('Text Field','Description','Test Lot Move')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowNumber('InventoryAdjustment',1,'colLotNumber',1)
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '-100')
        .verifyGridData('InventoryAdjustment', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryAdjustment', 1, 'colStorageLocation', 'RM Storage')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewLocation','0002 - Indianapolis','strNewLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewSubLocation','Indy','strNewSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewStorageLocation','Indy Storage','strNewStorageLocation')

        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')

        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16000-0002-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 3, 'colRecapAccountId', '16040-0001-000')
        .verifyGridData('RecapTransaction', 3, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 4, 'colRecapAccountId', '16040-0002-000')
        .verifyGridData('RecapTransaction', 4, 'colRecapCredit', '1000')

        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',1000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 11. Inventory Adjustment Quantity Change Lotted Item Done =====')
        //endregion



        //region Scenario 12. Inventory Count - Lock Inventory
        .displayText('===== Scenario  12. Inventory Count - Lock Inventory =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowNumber('Category',1,0)
        .selectComboBoxRowNumber('Commodity',3,0)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', '87G')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('PrintCountSheets')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .isControlVisible('tlb',
        [
            'PrintVariance'
            , 'LockInventory'
            , 'Post'
            , 'Recap'
        ], true)
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowNumber('Vendor',1,0)
        .selectComboBoxRowNumber('Location',1,0)

        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','87G','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'Gallon')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Gallon')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')

        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Clicking Recap',3000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario  12. Inventory Count - Lock Inventory =====')
        //endregion


        //region Scenario 13. Add new Storage Measurement Reading with 1 item only.
        .displayText('===== Scenario 13. Add new Storage Measurement Reading with 1 item only. ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Measurement Reading','Screen')
        .waitUntilLoaded()
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowNumber('Location',1,0)
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strCommodity','SC - Commodity - 01','strCommodity')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strItemNo','Smoke - LTI - 01','strItemNo')
        .selectGridComboBoxRowValue('StorageMeasurementReading',1,'strStorageLocationName','RM Storage','strStorageLocationName')
        .waitUntilLoaded()
        .verifyGridData('StorageMeasurementReading', 1, 'colSubLocation', 'Raw Station')
        .enterGridData('StorageMeasurementReading', 1, 'dblAirSpaceReading', '20')
        .enterGridData('StorageMeasurementReading', 1, 'dblCashPrice', '14')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 13. Add new Storage Measurement Reading with 1 item only. Done ====')



        .done();

})