StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        .displayText('===== Scenario 12: Direct IR for Lotted Item No Lot Details =====')
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
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 1000, 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', 10)
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '10000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strSubLocationName')

        .selectGridRowNumber('LotTracking', [1])
        .clickButton('RemoveLot')
        .waitUntilLoaded()
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .addResult('Successfully Clicked Tab',2000)
        .waitUntilLoaded('')
//        .verifyMessageBox('iRely i21','Lotted Item Direct - LTI - 01 should have lot(s) specified.','ok','error')
        .waitUntilLoaded('')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded()
        .clickTab('Details')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickButton('Close')
        //.clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .displayText('===== Scenario 12: Direct IR for Lotted Item No Lot Details Done=====')


        .displayText('===== Scenario 13: Lotted item,Receipt UOM: LB,Qty to receive: 2,204.62,Gross/net UOM: LB,Lot UOM: 25kg bags,Qty: 40, Gross/Net: 2,204.62 =====')
        .displayText('===== Creeating Direct IR for Non Lotted Item  =====')
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
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',  2204.62, 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', 10)
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Test_Pounds')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '2204.62')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '2204.62')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '22046.2')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strSubLocationName')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-03')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Test_25 KG bags' ,'strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', 40)
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '2204.62')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '2204.62')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM','Test_Pounds')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '22046.2')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '22046.2')
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
        .displayText('===== Scenario 13: Lotted item,Receipt UOM: LB,Qty to receive: 2,204.624,Gross/net UOM: LB,Lot UOM: 25kg bags,Qty: 40, Gross/Net: 2,204.624 Done=====')


        .done();

})