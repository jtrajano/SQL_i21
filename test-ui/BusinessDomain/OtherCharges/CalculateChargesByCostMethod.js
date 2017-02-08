StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region Pre-Setup Create Lotted Item and Other Charge Item


        .displayText('===== Pre-setup Add New Other Charge Item=====')
        .addFunction(function(next){
            commonIC.addOtherChargeItem (t,next, 'OtherCharge - 04', 'Test Other Charge Item')
        })


        //Add Lotted Item
        .displayText('===== Pre-setup Add Lot Tracked Item =====')
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'OC - LTI - 04'
                , 'Test Lotted Item For Other Charges'
                , 3
//                , 'Grains'
//                , 'OC - Commodity - 01'
//                , 'LB'
//                , 'LB'
                , 10
                , 10
                , 40
            )
        })

        //region Cost Method is Percentage - Inventory Cost unchecked
        .displayText('=====  Scenario 1. Create Direct IR for Lotted Item Cost Method is Percentage - Inventory Cost unchecked  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowNumber('Vendor',1,0)
//        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
        //.selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','OC - LTI - 04','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
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
        .selectGridComboBoxRowValue('Charges',1,'strItemNo','OtherCharge - 04','strItemNo')
        .selectGridComboBoxRowNumber('Charges',1,'colCostMethod',2)
        .selectGridComboBoxRowValue('Charges',1,'strCurrency','USD','strCurrency')
        .enterGridData('Charges', 1, 'colRate', '10')
        .clickGridCheckBox('Charges',0, 'strItemNo', 'OtherCharge - 04', 'ysnAccrue', true)
        .clickButton('CalculateCharges')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .verifyGridData('Charges', 1, 'colChargeAmount', '100')


        //Post IR
        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-012')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')
        .displayText('=====  Cost Method Percentage Done  =====')

        //Costh Method Per Unit
        .displayText('=====  Scenario 2. Create Direct IR for Lotted Item Cost Method is Per unit - Inventory Cost unchecked  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowNumber('Vendor',1,0)
        //.selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
        //.selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','OC - LTI - 04','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
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
        .selectGridComboBoxRowValue('Charges',1,'strItemNo','OtherCharge - 04','strItemNo')
        .selectGridComboBoxRowNumber('Charges',1,'colCostMethod',1)
        .selectGridComboBoxRowValue('Charges',1,'strCurrency','USD','strCurrency')
        .enterGridData('Charges', 1, 'colRate', '0.5')
        .selectGridComboBoxRowValue('Charges',1,'strCostUOM','LB','strCostUOM')
        .selectGridComboBoxRowNumber('Charges',1,'colChargeUOM',1)
        .clickGridCheckBox('Charges',0, 'strItemNo', 'OtherCharge - 04', 'ysnAccrue', true)
        .clickButton('CalculateCharges')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .verifyGridData('Charges', 1, 'colChargeAmount', '50')


        //Post IR
        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-012')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')
        .displayText('=====  Cost Method Per Unit Done  =====')


        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowNumber('Vendor',1,0)
        //.selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
        //.selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo','OC - LTI - 04','strItemNo')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', '100')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
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
        .selectGridComboBoxRowValue('Charges',1,'strItemNo','OtherCharge - 04','strItemNo')
        .selectGridComboBoxRowNumber('Charges',1,'colCostMethod',3)
        .selectGridComboBoxRowValue('Charges',1,'strCurrency','USD','strCurrency')
        .enterGridData('Charges', 1, 'colChargeAmount', '30')
        .clickGridCheckBox('Charges',0, 'strItemNo', 'OtherCharge - 04', 'ysnAccrue', true)
        .clickButton('CalculateCharges')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .waitUntilLoaded()
        .verifyGridData('Charges', 1, 'colChargeAmount', '30')


        //Post IR
        .clickButton('PostPreview')
        .waitUntilLoaded('cmcmrecaptransaction')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-012')
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Create Direct Inventory Receipt for Lotted Item=====')
        .displayText('=====  Cost Method Per Unit Done  =====')

        .done();

        //endregion

})