StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        .displayText('===== Scenario 14: Lot Tracked Manual Same Lot Number different Lot UOM =====')

        .displayText('===== Creeating Direct IR for Non Lotted Item  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking' , 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
        .clickButton('Close')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo', 'Direct - LTI - 01','strItemNo')
        .waitUntilLoaded('')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'Test_Bushels')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', 10)
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Test_Pounds')


        .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM','Test_Bushels','strWeightUOM')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '56000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strSubLocationName')

//      .selectGridComboBoxRowValue('LotTracking',1,'strLotNumber','LOT-02','strLotNumber')
        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-07')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Test_Bushels' ,'strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', 100)
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM','Test_Bushels')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '56000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '56000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickButton('Close')//.clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')

        //.clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking' , 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
        .clickButton('Close')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo', 'Direct - LTI - 01','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', 10)
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Test_Pounds')


//      .selectGridComboBoxRowValue('LotTracking',1,'strLotNumber','LOT-02','strLotNumber')
        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-07')
        .enterGridData('LotTracking', 1, 'colLotQuantity', 100)
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM','Test_Pounds')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickMessageBoxButton('ok')
        .clickTab('Details')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickButton('Close')//.clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .displayText('===== Scenario 14: Lot Tracked Manual Same Lot Number different Lot UOM Done =====')




        .displayText('===== Scenario 15: Lotted item Receipt UOM: LB, Qty to receive: 100, Gross/net UOM: Blank ,Cost UOM: Blank, Cost:10 =====')

        //.clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking' , 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
        .clickButton('Close')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo', 'Direct - LTI - 01','strItemNo')
        .waitUntilLoaded('')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 1000, 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', 10)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'colCostUOM',"[DELETE][ENTER]",'colCostUOM',1)
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '10000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strSubLocationName')

        //.selectGridComboBoxRowValue('LotTracking',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Test_Pounds' ,'strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', 1000)
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '1000')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '1000')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM','Test_Pounds')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '10000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '10000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .clickButton('Close')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickButton('Close')//.clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .displayText('===== Scenario 15: Lotted item Receipt UOM: LB, Qty to receive: 100, Gross/net UOM: Blank ,Cost UOM: Blank, Cost:10 Done =====')


        .done();

})