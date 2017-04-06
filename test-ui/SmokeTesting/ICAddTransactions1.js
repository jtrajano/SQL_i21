StartTest (function (t) {
    var commonICST = Ext.create('Inventory.CommonICSmokeTest');
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)



        //Create CT to IR for  Non Lotted Item Process Button
        .displayText('===== Scenario 1: Create CT to IR for  Non Lotted Item Process Button =====')
        .addFunction(function(next){
            commonIC.addCTtoIRProcessButtonNonLotted (t,next, 'ABC Trucking','SC - Commodity - 01','0001 - Fort Wayne', 'Smoke - NLTI - 01','LB', 1000, 10)
        })

        //Create CT to IR for  Lotted Item Process Button
        .displayText('===== Scenario 2:  CT to IR for Non Lotted Item Process Button =====')
        .addFunction(function(next){
            commonIC.addCTtoIRProcessButtonLotted (t,next, 'ABC Trucking', 'SC - Commodity - 01' ,'0001 - Fort Wayne', 'Smoke - LTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })


        //Create PO to IR for Non Lotted Item Add Orders Screen
        .displayText('===== Scenario 3: Create PO to IR for Non Lotted Item Add Orders Screen =====')
        .addFunction(function(next){
            commonIC.addPOtoIRAddOrdersButtonNonLotted (t,next, 'ABC Trucking', '0001 - Fort Wayne', 'Smoke - NLTI - 01','LB', 1000, 10)
        })

        //Create PO to IR for Lotted Item  Add Orders Screen
        .displayText('===== Scenario 4: Create PO to IR for Lotted Item  Add Orders Screen =====')
        .addFunction(function(next){
            commonIC.addPOtoIRAddOrdersButtonLotted (t,next, 'ABC Trucking', '0001 - Fort Wayne', 'Smoke - LTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })


        //Create Direct IR for Lotted Item with other charges
        .displayText('===== Scenario 5: Direct IR for Lotted Item with other charges  =====')
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
        .selectGridComboBoxRowValue('Charges',1,'strItemNo','Smoke - Other Charge Item - 01','strItemNo')
        .selectGridComboBoxRowNumber('Charges',1,'colCostMethod',2)
        .selectGridComboBoxRowValue('Charges',1,'strCurrency','USD','strCurrency')
        .enterGridData('Charges', 1, 'colRate', '10')
        .clickGridCheckBox('Charges',0, 'strItemNo', 'Smoke - Other Charge Item - 01', 'ysnAccrue', true)

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
        .displayText('===== Scenario 6: Create Direct IR for Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'Smoke - NLTI - 01','LB', 1000, 10)
        })

        //Create Direct IR for Lotted Item
        .displayText('===== Scenario 7: Create Direct IR for Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'Smoke - LTI - 01','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })



        .done();

})