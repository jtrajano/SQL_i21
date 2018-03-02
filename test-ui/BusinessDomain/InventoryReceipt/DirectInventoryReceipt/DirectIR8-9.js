StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        .displayText('===== Scenario 8: Create Direct Inventory Receipt Type. (Lotted Item) Check GL Entries =====')
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
        .addResult('Successfully Opened',2000)
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
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
        //.clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('').waitUntilLoaded('')
        .clickButton('Close')
        .displayText('===== Scenario 8: Creating Direct IR for Non Lotted Done =====')




        //Create Lotted Item Stock Unit Each
        .displayText('===== Add Commodity KG Stock Unit =====')
        //.clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
         .filterGridRecords('Search', 'From', 'DIR - Commodity - 02')
            .waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function (win,next) {
                    new iRely.FunctionalTest().start(t, next)
                    return win.down('#grdSearch').store.getCount() == 0;
                },

                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('')
                        .enterData('Text Field','CommodityCode', 'DIR - Commodity - 02')
                        .enterData('Text Field','Description', 'DIR - Commodity - 02')
                        .enterData('Text Field','DecimalsOnDpr','6.00')

                        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Each','strUnitMeasure')
                        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'Each', 'ysnStockUnit', true)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .verifyStatusMessage('Saved')
                        .clickButton('Close')
                        .waitUntilLoaded().waitUntilLoaded()
                        .clickButton('Close')
                        .done();
                },
                continueOnFail: true
            })
        ////////////////////////////////////////////////////////

        
        
        .waitUntilLoaded('')
        .clickButton('Close')
        .displayText('===== Add Commodity Done =====')
        
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'From', 'Direct - LTI - 03')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Commodity already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','ItemNo','Direct - LTI - 03')
                    .enterData('Text Field','Description','Direct - LTI - 03')
                    .selectComboBoxRowValue('Category', 'DIR - Category', 'Category',0)
                    .selectComboBoxRowValue('Commodity', 'DIR - Commodity - 02', 'Commodity',0)
                    .selectComboBoxRowNumber('LotTracking',3,0)
                    .clickCheckBox('LotWeightsRequired', false)
                    .verifyData('Combo Box','Tracking','Lot Level')

                    .displayText('===== Setup Item GL Accounts=====')
                    .clickTab('Setup')
                    .clickButton('AddRequiredAccounts')
                    .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
                    .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
                    .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
                    .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
                    .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
                    .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')

                    .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
                    .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')


                    .displayText('===== Setup Item Location=====')
                    .clickTab('Location')
                    .clickButton('AddLocation')
                    .waitUntilLoaded('')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'Each', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'Each', 'ReceiveUom',0)
                    .clickButton('Save')
                    .clickButton('Close')

                    .clickButton('AddLocation')
                    .waitUntilLoaded('')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'Each', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'Each', 'ReceiveUom',0)
                    .clickButton('Save')
                    .clickButton('Close')

                    .displayText('===== Setup Item Pricing=====')
                    .clickTab('Pricing')
                    .waitUntilLoaded('')
                    .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
                    .enterGridData('Pricing', 1, 'dblLastCost', '10')
                    .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                    .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                    .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

                    .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
                    .enterGridData('Pricing', 2, 'dblLastCost', '10')
                    .enterGridData('Pricing', 2, 'dblStandardCost', '10')
                    .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
                    .enterGridData('Pricing', 2, 'dblAmountPercent', '40')
                    .clickButton('Save')
                    .clickButton('Close')
                    .waitUntilLoaded('').waitUntilLoaded('').clickButton('Close')
                    .done();
            },
            continueOnFail: true
        })
        //.clickMenuFolder('Inventory','Folder')


        .displayText('===== Scenario 9:  Receipt Type: Direct Qty to Receive: 100 Receipt uom: Unit (quantity) Lotted item =====')
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
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo', 'Direct - LTI - 03','strItemNo')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'Each')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', 10)
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Each')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName','Raw Station','strSubLocationName')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName','RM Storage','strSubLocationName')

        .enterGridData('LotTracking', 1, 'colLotId', 'LOT-01')
        .waitUntilLoaded('')
        .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure','Each' ,'strUnitMeasure')
        .enterGridData('LotTracking', 1, 'colLotQuantity', 100)

        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',2000)
        .clickButton('Close')
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .clickButton('Close')
       //.clickMenuFolder('Inventory','Folder')
        .displayText('===== Creating Direct IR for Non Lotted Done =====')

        .done();

})