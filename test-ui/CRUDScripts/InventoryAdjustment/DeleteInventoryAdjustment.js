StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
        //region
        .displayText('===== 1. Add Indianapolis for Company Location for irelyadmin User =====')
        .clickMenuFolder('System Manager','Folder')
        .clickMenuScreen('Users','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        .waitUntilLoaded('ementity')
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
                    .waitUntilLoaded('ementity')
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
                    .waitUntilLoaded('ementity')
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

        //endregion


        /*====================================== Add Storage Location for Indianapolis======================================*/
        //region
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
                    .waitUntilLoaded('icstorageunit')
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
        //endregion

        //region
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'TestGrains1')
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
                    .displayText('===== Add Category =====')
                    .clickMenuFolder('Inventory','Folder')
                    .addFunction(function(next){
                        commonIC.addCategory (t,next, 'TestGrains1', 'Test Smoke Category Description', 2)
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')
        //endregion


        /*====================================== Add Commodity ======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'TestCorn1')
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
                    .displayText('=====  Add Commodity =====')
                    .addFunction(function(next){
                        commonIC.addCommodity (t,next, 'TestCorn1', 'Test Smoke Commodity Description')
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        //endregion
        .clickMenuFolder('Inventory','Folder')

        /*====================================== Add Lotted Item ======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'ALTI - 108')
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
                            'ALTI - 108'
                            , 'Test Item for Adjustment'
                            , 'TestGrains1'
                            , 'TestCorn1'
                            , 3
                            , 'LB'
                            , 'LB'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')
        //endregion


        /*======================= Create inventory Receipt for Stock ==========================*/
        .displayText('=====  Creating Direct Inventory Receipt =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'ALTI - 108','LB', 1000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Create Direct Inventory Receipt for Lotted Item Done =====')

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        .displayText('===== Creating Inventory Adjustment Quantity Change Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',1,0)
        .enterData('Text Field','Description','Test Quantity Change')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','ALTI - 108','strItemNo')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strSubLocation','Raw Station','strSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strStorageLocation','RM Storage','strStorageLocation')
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

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1100')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1100')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Unpost Inventory Adjustment
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Quantity Change', 'strAdjustmentType', 1)
        .waitUntilLoaded()
        .clickButton('Unpost')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Delete Inventory Adjustment
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Quantity Change', 'strAdjustmentType', 1)
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .addResult('Successfully Deleted',2000)
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 1, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '1000')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .displayText('===== Create Inventory Adjustment for Lotted Item Delete IA Done =====')
        //endregion

        //region Scenario 2. Create Inventory Adjustment Split Lot for Lotted Item Delete IA
        .displayText('=====  Scenario 2. Create Inventory Adjustment Split Lot for Lotted Item Delete IA =====')
        .displayText('===== Creating Inventory Adjustment Split Lot Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',5,0)
        .enterData('Text Field','Description','Test Split Lot')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','ALTI - 108','strItemNo')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strSubLocation','Raw Station','strSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strStorageLocation','RM Storage','strStorageLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('InventoryAdjustment', 1, 'colNewLotNumber', 'LOT-01')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '-100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewSubLocation','Indy','strNewSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewStorageLocation','Indy Storage','strNewStorageLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strNewItemUOM','LB','strNewSubLocation')
        .enterGridData('InventoryAdjustment', 1, 'colNewSplitLotQuantity', '100')

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

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 2, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 2, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 2, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 2, 'colStockOnHand', '900')
        .verifyGridData('Stock', 2, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 2, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 2, 'colStockCommitted', '0')
        .verifyGridData('Stock', 2, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 2, 'colStockReserved', '0')
        .verifyGridData('Stock', 2, 'colStockAvailable', '900')

        .verifyGridData('Stock', 1, 'colStockLocation', '0002 - Indianapolis')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '100')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Unpost Inventory Adjustment
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Split Lot', 'strAdjustmentType', 1)
        .waitUntilLoaded()
        .clickButton('Unpost')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 2, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 2, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 2, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 2, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 2, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 2, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 2, 'colStockCommitted', '0')
        .verifyGridData('Stock', 2, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 2, 'colStockReserved', '0')
        .verifyGridData('Stock', 2, 'colStockAvailable', '1000')

        .verifyGridData('Stock', 1, 'colStockLocation', '0002 - Indianapolis')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '0')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete Inventory Adjustment
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Split Lot', 'strAdjustmentType', 1)
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .addResult('Successfully Deleted',2000)
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 2, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 2, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 2, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 2, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 2, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 2, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 2, 'colStockCommitted', '0')
        .verifyGridData('Stock', 2, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 2, 'colStockReserved', '0')
        .verifyGridData('Stock', 2, 'colStockAvailable', '1000')

        .verifyGridData('Stock', 1, 'colStockLocation', '0002 - Indianapolis')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '0')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .displayText('=====  Create Inventory Adjustment Split Lot for Lotted Item Delete IA Done =====')
        //endregion


        //region Scenario 3. Create Inventory Adjustment Lot Move for Lotted Item Delete IA
        .displayText('=====  Scenario 3. Create Inventory Adjustment Lot Move for Lotted Item Delete IA =====')
        .displayText('===== Creating Inventory Adjustment Lot Move Lotted Item=====')
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryadjustment')
        .verifyData('Combo Box','Location','0001 - Fort Wayne')
        .selectComboBoxRowNumber('AdjustmentType',8,0)
        .enterData('Text Field','Description','Test Lot Move')

        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strItemNo','ALTI - 108','strItemNo')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strSubLocation','Raw Station','strSubLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strStorageLocation','RM Storage','strStorageLocation')
        .selectGridComboBoxRowValue('InventoryAdjustment',1,'strLotNumber','LOT-01','strLotNumber')
        .enterGridData('InventoryAdjustment', 1, 'colNewLotNumber', 'LOT-01')
        .enterGridData('InventoryAdjustment', 1, 'colAdjustByQuantity', '-100')
        .verifyGridData('InventoryAdjustment', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryAdjustment', 1, 'colNewUnitCost', '10')
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

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 2, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 2, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 2, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 2, 'colStockOnHand', '900')
        .verifyGridData('Stock', 2, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 2, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 2, 'colStockCommitted', '0')
        .verifyGridData('Stock', 2, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 2, 'colStockReserved', '0')
        .verifyGridData('Stock', 2, 'colStockAvailable', '900')

        .verifyGridData('Stock', 1, 'colStockLocation', '0002 - Indianapolis')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '100')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '100')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Unpost Inventory Adjustment
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Lot Move', 'strAdjustmentType', 1)
        .waitUntilLoaded()
        .clickButton('Unpost')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 2, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 2, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 2, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 2, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 2, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 2, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 2, 'colStockCommitted', '0')
        .verifyGridData('Stock', 2, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 2, 'colStockReserved', '0')
        .verifyGridData('Stock', 2, 'colStockAvailable', '1000')

        .verifyGridData('Stock', 1, 'colStockLocation', '0002 - Indianapolis')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '0')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Delete Inventory Adjustment
        .clickMenuScreen('Inventory Adjustments','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Lot Move', 'strAdjustmentType', 1)
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .addResult('Successfully Deleted',2000)
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()


        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('ALTI - 108', 'strItemNo', 1)
        .waitUntilLoaded('icitem')
        .clickTab('Stock')
        .waitUntilLoaded()
        .verifyGridData('Stock', 2, 'colStockLocation', '0001 - Fort Wayne')
        .verifyGridData('Stock', 2, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 2, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 2, 'colStockOnHand', '1000')
        .verifyGridData('Stock', 2, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 2, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 2, 'colStockCommitted', '0')
        .verifyGridData('Stock', 2, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 2, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 2, 'colStockReserved', '0')
        .verifyGridData('Stock', 2, 'colStockAvailable', '1000')

        .verifyGridData('Stock', 1, 'colStockLocation', '0002 - Indianapolis')
        .verifyGridData('Stock', 1, 'colStockOnOrder', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitInbound', '0')
        .verifyGridData('Stock', 1, 'colStockOnHand', '0')
        .verifyGridData('Stock', 1, 'colStockInTransitOutbound', '0')
        .verifyGridData('Stock', 1, 'colStockBackOrder', '0')
        .verifyGridData('Stock', 1, 'colStockCommitted', '0')
        .verifyGridData('Stock', 1, 'colStockOnStorage', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedPurchase', '0')
        .verifyGridData('Stock', 1, 'colStockConsignedSale', '0')
        .verifyGridData('Stock', 1, 'colStockReserved', '0')
        .verifyGridData('Stock', 1, 'colStockAvailable', '0')
        .displayText('=====  Item Stock Checking Done =====')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        //endregion


        .done();

})