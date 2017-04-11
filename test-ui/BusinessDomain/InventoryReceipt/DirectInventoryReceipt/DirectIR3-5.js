StartTest (function (t) {
        var commonIC = Ext.create('Inventory.CommonIC');
        new iRely.FunctionalTest().start(t)


        //Scenario 3: Check Gross/Net UOM and Line Total where Receipt UOM and Gross/Net UOM is the same
        .displayText('===== Scenario 3: Check Gross/Net UOM and Line Total where Receipt UOM and Gross/Net UOM is the same =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'Direct - LTI - 01','LB', 100, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })


        //Create Direct IR for Non Lotted Item
        .displayText('===== Scenario 4: Check Gross/Net UOM and Line Total where Receipt UOM and Gross/Net UOM are different =====')

        .displayText('===== Creeating Direct IR for Non Lotted Item  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking' , 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo', 'Direct - LTI - 01','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, '50 lb bag')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', 10)
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '5000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '5000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '50000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strSubLocationName')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-02')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','LB' ,'strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', 5000)
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '5000')
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '5000')
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM','LB')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')


        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '50000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '50000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Creating Direct IR for Non Lotted Done =====')
        .clickMenuFolder('Inventory','Folder')


        .displayText('===== Scenario 5: Receipt UOM 50 KG Bags Net Weight is Less than Gross Weight =====')
        .displayText('===== Creeating Direct IR for Non Lotted Item  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking' , 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo', 'Direct - LTI - 02','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'Test_50 KG Bag')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', 10)
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'KG')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'KG')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '5000')
        .enterGridData('InventoryReceipt', 1, 'colNet', 4900)

        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '49000')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strSubLocationName')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-02')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Test_50 KG Bag' ,'strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', 100)
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '5000')
        .enterGridData('LotTracking', 1, 'colLotTareWeight', 100)
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM','KG')
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')


        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '49000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '49000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Creating Direct IR for Non Lotted Done =====')
        .clickMenuFolder('Inventory','Folder')



        .done();

})