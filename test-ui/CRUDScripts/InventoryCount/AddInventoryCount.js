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
        .filterGridRecords('Search', 'FilterGrid', 'IC - Category - 11')
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
                        commonIC.addCategory (t,next, 'IC - Category - 11', 'Test Category Description', 2)
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })


        /*====================================== Add Commodity ======================================*/

        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IC - Commodity - 11')
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
                        commonIC.addCommodity (t,next, 'IC - Commodity - 11', 'Test Commodity Description')
                    })
                    .clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })



        /*====================================== Add Non Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'IC - NLTI - 11')
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
                    .enterData('Text Field','ItemNo','IC - NLTI - 11')
                    .enterData('Text Field','Description','Non Lotted for Delete IC')
                    .selectComboBoxRowValue('Category', 'IC - Category - 11', 'Category',0)
                    .selectComboBoxRowValue('Commodity', 'IC - Commodity - 11', 'Commodity',0)
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
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'IC - NLTI - 11','LB', 1000, 10)
        })

        //region Scenario 1. Inventory Count - Fetch Items
        .displayText('===== Scenario 1. Inventory Count - Fetch Items ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Count','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded()
        .selectComboBoxRowValue('Category', 'IC - Category - 11', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'IC - Commodity - 11', 'Commodity',1)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'RM Bin 2', 'StorageLocation',0)
        .waitUntilLoaded()
        .clickButton('Fetch')
        .waitUntilLoaded()
        .verifyGridData('PhysicalCount', 1, 'colItem', 'IC - NLTI - 11')
        .verifyGridData('PhysicalCount', 1, 'colSystemCount', 1000)
        .verifyGridData('PhysicalCount', 1, 'colLastCost', 10)
        .verifyGridData('PhysicalCount', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('PhysicalCount', 1, 'colStorageLocation', 'RM Bin 2')
        .clickButton('Save')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .displayText('===== Scenario 1. Inventory Count - Fetch Items Done====')
        //endregion

        //region Scenario 2. Inventory Count - Print Count Sheets
        .clickButton('PrintCountSheets')
        .waitUntilLoaded()
        .waitUntilLoaded()
        .addResult('Successfully Opened Print Count Sheets',3000)
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .displayText('===== Scenario  2. Inventory Count - Print Count Sheets Done =====')
        //endregion

        //region Scenario 3. Inventory Count - Lock Inventory
        .displayText('===== Scenario  3. Inventory Count - Lock Inventory =====')
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo', 'IC - NLTI - 11','strItemNo')

        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100000, 'LB')

        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100000')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000000')

        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Clicking Post Button',2000)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','Inventory Count is ongoing for Item IC - NLTI - 11 and is locked under Location 0001 - Fort Wayne.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .displayText('===== Scenario 3. Inventory Count - Lock Inventory Done =====')
        //endregion

        //region Scenario 4: Update Inventory Count
        .displayText('===== Scenario 4: Update Inventory Count =====')
        .clickMenuScreen('Inventory Count','Screen')
        .doubleClickSearchRowValue('IC - Category - 11', 'strCategory', 1)
        .waitUntilLoaded('')
        .clickButton('LockInventory')
        .waitUntilLoaded()
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')

        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'IC - NLTI - 11','LB', 1000, 10)
        })

        .displayText('===== Update Done=====')
        //endregion

        .done();


})