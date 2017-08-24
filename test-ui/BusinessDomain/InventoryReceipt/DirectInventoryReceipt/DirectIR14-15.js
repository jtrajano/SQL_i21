StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //Presetup
        //region
        .displayText('===== Pre-setup =====')
        /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
        .displayText('===== 1. Add Indianapolis for Company Location for irelyadmin User =====')
        .clickMenuFolder('System Manager','Folder')
        .clickMenuScreen('Users','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        .waitUntilLoaded('')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Timezone', '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi', 'Timezone',0)
        .clickTab('User')
        .waitUntilLoaded()
        .clickTab('User Roles')

        .waitUntilLoaded()
        .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
        .waitUntilLoaded()

        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    .displayText('Location is not yet existing.')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
                    .waitUntilLoaded('')
                    .clickTab('User')
                    .waitUntilLoaded()
                    .clickTab('User Roles')
                    .waitUntilLoaded()
                    .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 'Dummy','strLocationName', '0002 - Indianapolis','strLocationName', 1)
                    .selectGridComboBoxBottomRowValue('UserRoleCompanyLocationRolePermission', 'strUserRole', 'ADMIN', 'strUserRole', 1)
                    .clickTab('Detail')
                    .waitUntilLoaded()
                    .selectComboBoxRowValue('UserNumberFormat', '1,234,567.89', 'UserNumberFormat',1)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
                    .waitUntilLoaded('')
                    .clickTab('User')
                    .waitUntilLoaded()
                    .clickTab('User Roles')
                    .waitUntilLoaded()
                    .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Location already exists.')
                return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() != 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickMenuFolder('System Manager','Folder')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Storage Location for Indianapolis======================================*/
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Storage Locations','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Indy Storage')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('===== Scenario 1: Add New Storage Location. =====')
                    .clickMenuScreen('Storage Locations','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','Name','Indy Storage')
                    .enterData('Text Field','Description','Indy Storage')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .selectComboBoxRowNumber('Location',2,0)
                    .selectComboBoxRowNumber('SubLocation',1,0)
                    .selectComboBoxRowNumber('ParentUnit',1,0)
                    .enterData('Text Field','Aisle','Test Aisle - 01')
                    .clickCheckBox('AllowConsume', true)
                    .clickCheckBox('AllowMultipleItems', true)
                    .clickCheckBox('AllowMultipleLots', true)
                    .clickCheckBox('CycleCounted', true)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')
        /*====================================== Add Category ======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'DIR - Category')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Category already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //Add Category
                    .displayText('===== Scenario 4: Add Category =====')
                    .clickMenuFolder('Inventory','Folder')
                    .addFunction(function(next){
                        commonIC.addCategory (t,next, 'DIR - Category', 'Test DIR - Category', 2)
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Commodity ======================================*/

        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'DIR - Commodity')
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
                    .clickMenuFolder('Inventory','Folder')
                    //Add Commodity
                    .displayText('===== Scenario 6: Add Commodity =====')
                    .addFunction(function(next){
                        commonIC.addCommodity (t,next, 'DIR - Commodity', 'Test DIR - Commodity')
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Direct - LTI - 01')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuFolder('Inventory','Folder')
                    .displayText('===== Scenario 5: Add Lotted Item =====')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            'Direct - LTI - 01'
                            , 'Test Lotted Item Description'
                            , 'DIR - Category'
                            , 'DIR - Commodity'
                            , 3
                            , 'Test_Pounds'
                            , 'Test_Pounds'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Non Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Direct - NLTI - 01')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuFolder('Inventory','Folder')
                    .displayText('===== Scenario 6: Add Non Lotted Item =====')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            'Direct - NLTI - 01'
                            , 'Test Non Lotted Item Description'
                            , 'DIR - Category'
                            , 'DIR - Commodity'
                            , 4
                            , 'Test_Pounds'
                            , 'Test_Pounds'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .waitUntilLoaded('')
                    .clickMenuFolder('Inventory','Folder')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')



        //Create Lotted Item Stock Unit KG
        .displayText('===== Add Commodity KG Stock Unit =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'DIR - Commodity - 01')
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
                    .clickMenuScreen('Commodities','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','CommodityCode','DIR - Commodity - 01')
                    .enterData('Text Field','Description','Test Corn Commodity')
                    .enterData('Text Field','DecimalsOnDpr','6.00')

                    .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Test_KG','strUnitMeasure')
                    .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'Test_KG', 'ysnStockUnit', true)
                    .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','Test_Test_25 KG bagss','strUnitMeasure')
                    .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Test_50 KG bags','strUnitMeasure')
                    .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','Test_60 KG bags','strUnitMeasure')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .displayText('===== Create Commodity Stock Unit Test KG =====')
                    .done();
            },
            continueOnFail: true
        })

        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Direct - LTI - 02')
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
                    .enterData('Text Field','ItemNo','Direct - LTI - 02')
                    .enterData('Text Field','Description','Test Lotted Item Direct - LTI - 02')
                    .selectComboBoxRowValue('Category', 'DIR - Category', 'Category',0)
                    .selectComboBoxRowValue('Commodity', 'DIR - Commodity - 01', 'Commodity',0)
                    .selectComboBoxRowNumber('LotTracking',3,0)
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
                    .selectComboBoxRowValue('IssueUom', 'Test_KG', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'Test_KG', 'ReceiveUom',0)
                    .clickButton('Save')
                    .clickButton('Close')

                    .clickButton('AddLocation')
                    .waitUntilLoaded('')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'Test_KG', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'Test_KG', 'ReceiveUom',0)
                    .clickButton('Save')
                    .clickButton('Close')

                    .displayText('===== Setup Item Pricing=====')
                    .clickTab('Pricing')
                    .waitUntilLoaded('')
                    .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
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
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Pre-setup done =====')
        //endregion

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
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')

        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking' , 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
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
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .displayText('===== Scenario 14: Lot Tracked Manual Same Lot Number different Lot UOM Done =====')




        .displayText('===== Scenario 15: Lotted item Receipt UOM: LB, Qty to receive: 100, Gross/net UOM: Blank ,Cost UOM: Blank, Cost:10 =====')

        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking' , 'Vendor',1)
        .selectComboBoxRowNumber('Location',1,0)
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

        .selectGridComboBoxRowValue('LotTracking',1,'strLotNumber','LOT-01','strLotNumber')
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
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .displayText('===== Scenario 15: Lotted item Receipt UOM: LB, Qty to receive: 100, Gross/net UOM: Blank ,Cost UOM: Blank, Cost:10 Done =====')


        .done();

})