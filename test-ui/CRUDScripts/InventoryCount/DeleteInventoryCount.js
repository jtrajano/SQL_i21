StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region
        .displayText('===== Pre-setup =====')
        /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
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
        /*====================================== Add Category ======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IC - Category - 04')
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
                        commonIC.addCategory (t,next, 'IC - Category - 04', 'Test Category Description', 2)
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Commodity ======================================*/

        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IC - Commodity - 04')
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
                        commonIC.addCommodity (t,next, 'IC - Commodity - 04', 'Test Commodity Description')
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })



        /*====================================== Add Non Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IC - NLTI - 04')
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
                    
                    //Create NON Lotted Item.
                    .displayText('===== Creating Non Lotted Item =====')
                    .clickMenuScreen('Items','Screen')
                    .clickButton('New')
                    .enterData('Text Field','ItemNo','IC - NLTI - 04')
                    .enterData('Text Field','Description','Non Lotted for Delete IC')
                    .selectComboBoxRowValue('Category', 'IC - Category - 04', 'Category',0)
                    .selectComboBoxRowValue('Commodity', 'IC - Commodity - 04', 'Commodity',0)
                    .selectComboBoxRowNumber('LotTracking',4,0)
                    .verifyData('Combo Box','Tracking','Item Level')

                    .displayText('===== Setup Item Location=====')
                    .clickTab('Setup')
                    .clickTab('Location')
                    .clickButton('AddLocation')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'RM Bin 2', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
                    .clickButton('Save')
                    .clickButton('Close')
                    .waitUntilLoaded()

                    .clickTab('Pricing')
                    .waitUntilLoaded('')
                    .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
                    .enterGridData('Pricing', 1, 'dblLastCost', '10')
                    .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                    .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                    .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .displayText('===== None Lotted Item Created =====')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')


        //Adding Stock to Items
        .displayText('===== Adding Stocks to Created items =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'IC - NLTI - 04','LB', 1000, 10)
        })

        //Check Stock of the Item
         .clickMenuFolder('Inventory','Folder')
        .displayText('=====  Checking Item Stock =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('IC - NLTI - 04', 'strItemNo', 1)
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

        //Create Inventory Count
        .displayText('===== Scenario  3. Inventory Count - Lock Inventory =====')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'IC - Category - 04', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'IC - Commodity - 04', 'Commodity',1)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',1)
        .selectComboBoxRowValue('StorageLocation', 'RM Bin 2', 'StorageLocation',1)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', 'IC - NLTI - 04')
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
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .doubleClickSearchRowValue('0001 - Fort Wayne', 'strLocationName', 1)
        .waitUntilLoaded()
        .clickButton('Unpost')
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()

        .displayText('=====  Scenario 2. Create Inventory Count for Lotted Item then Delete Inventory Count =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'IC - NLTI - 04','LB', 1000, 10)
        })


        .displayText('===== Create Inveentory Count  for Non Lotted Item then Delete Inventory Count Done =====')
        //endregion

        /*====================================== Add Lotted Item ======================================*/
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IC - LTI - 04')
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
                    .displayText('===== Creating Lotted Item =====')
                    .clickMenuScreen('Items','Screen')
                    .clickButton('New')
                    .enterData('Text Field','ItemNo','IC - LTI - 04')
                    .enterData('Text Field','Description','Non Lotted for Delete IC')
                    .selectComboBoxRowValue('Category', 'IC - Category - 04', 'Category',0)
                    .selectComboBoxRowValue('Commodity', 'IC - Commodity - 04', 'Commodity',0)
                    .selectComboBoxRowNumber('LotTracking',3,0)
                    .verifyData('Combo Box','Tracking','Lot Level')

                    .displayText('===== Setup Item Location=====')
                    .clickTab('Setup')
                    .clickTab('Location')
                    .clickButton('AddLocation')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'RM Bin 3', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
                    .clickButton('Save')
                    .clickButton('Close')
                    .waitUntilLoaded()

                    .clickTab('Pricing')
                    .waitUntilLoaded('')
                    .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
                    .enterGridData('Pricing', 1, 'dblLastCost', '10')
                    .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                    .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                    .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

                    .clickButton('Save')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .displayText('===== None Lotted Item Created =====')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickMenuFolder('Inventory','Folder')

        //Create inventory Receipt for Stock
        .displayText('=====  Creating Direct Inventory Receipt for for Stock=====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'IC - LTI - 04','LB', 1000, 10, 'Raw Station', 'RM Bin 3', 'LOT-01', 'LB')
        })
        .displayText('=====  Creating Direct Inventory Receipt for Lotted Item Done=====')

        //Check Stock of the Item
        .displayText('=====  Checking Item Stock =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('IC - LTI - 04', 'strItemNo', 1)
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

        //Create Inventory Count
        .displayText('===== Scenario  3. Inventory Count - Lock Inventory =====')
        .clickMenuScreen('Inventory Count','Screen')
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'IC - Category - 04', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'IC - Commodity - 04', 'Commodity',1)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',1)
        .selectComboBoxRowValue('StorageLocation', 'RM Bin 3', 'StorageLocation',1)
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', 'IC - LTI - 04')
        .waitUntilLoaded()
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
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .doubleClickSearchRowValue('0001 - Fort Wayne', 'strLocationName', 1)
        .waitUntilLoaded()
        .clickButton('Post')
        .waitUntilLoaded()
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('===== Create Inventory Count  for Lotted Item then Delete Inventory Count Done =====')

        //endregion
        .done();

})