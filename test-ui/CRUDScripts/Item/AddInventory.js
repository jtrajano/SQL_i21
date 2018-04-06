StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region
        .displayText('===== Pre-setup =====')
        /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
        .displayText('===== 1. Add Indianapolis for Company Location for irelyadmin User =====')
        .clickMenuFolder('System Manager','Folder')
        .clickMenuScreen('Users','Screen')
        .waitUntilLoaded('')
        .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Timezone', '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi', 'Timezone',0)
        .clickTab('User')
        .waitUntilLoaded('')
        .clickTab('User Roles')

        .waitUntilLoaded('')
        .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
        .waitUntilLoaded('')

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
                    .waitUntilLoaded('')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded('')
                    .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
                    .waitUntilLoaded('')
                    .clickTab('User')
                    .waitUntilLoaded('')
                    .clickTab('User Roles')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 'Dummy','strLocationName', '0002 - Indianapolis','strLocationName', 1)
                    .selectGridComboBoxBottomRowValue('UserRoleCompanyLocationRolePermission', 'strUserRole', 'ADMIN', 'strUserRole', 1)
                    .clickTab('Detail')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('UserNumberFormat', '1,234,567.89', 'UserNumberFormat',1)
                    .clickButton('Save')
                    .waitUntilLoaded('')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
                    .waitUntilLoaded('')
                    .clickTab('User')
                    .waitUntilLoaded('')
                    .clickTab('User Roles')
                    .waitUntilLoaded('')
                    .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
                    .waitUntilLoaded('')
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
                    .waitUntilLoaded('')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded('')
                    .clickMenuFolder('System Manager','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .waitUntilLoaded('')
        //endregion

      /*====================================== Add Storage Location for Indianapolis======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .clickMenuScreen('Storage Units','Screen')
        .selectSearchRowValue('Indy Storage','Name',1,1)
        .waitUntilLoaded('')
        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('===== Scenario 1: Add New Storage Location. =====')
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
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')
        //endregion

        
        /*====================================== Add Category ======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .selectSearchRowValue('CRUD - Category','CategoryCode',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', 'CRUD - Category')
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
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .displayText('===== Scenario 4: Add Category =====')
                    .addFunction(function(next){
                        commonIC.addCategory (t,next, 'CRUD - Category', 'Test Category', 2)
                    })
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')

        /*====================================== Add Commodity ======================================*/

        .clickMenuScreen('Commodities','Screen')
        .selectSearchRowValue('CRUD - Commodity','CommodityCode',1,1)
        // .filterGridRecords('Search', 'FilterGrid', 'SC - Commodity - 01')
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', 'CRUD - Commodity')
        // .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Commodity already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //Add Commodity
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .displayText('===== Scenario 6: Add Commodity =====')
                    .addFunction(function(next){
                        commonIC.addCommodity (t,next, 'CRUD - Commodity', 'Test Commodity')
                    })
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')

        /*====================================== Add Lotted Item Yes Serial ======================================*/
        .clickMenuScreen('Items','Screen')
        .selectSearchRowValue('CRUD - LTI - 01','ItemNo',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', 'CRUD - LTI - 01')
        // .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                .clickButton('Close')
                .waitUntilLoaded('')
                    .displayText('===== Scenario 1: Add Lotted Item Serial =====')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            'CRUD - LTI - 01'
                            , 'Test Lotted Item Serial'
                            , 'CRUD - Category'
                            , 'CRUD - Commodity'
                            , 2
                            , 'Test_Pounds'
                            , 'Test_Pounds'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')

        /*====================================== Add Lotted Item Yes Serial ======================================*/
        .clickMenuScreen('Items','Screen')
        .selectSearchRowValue('CRUD - LTI - 02','ItemNo',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', 'CRUD - LTI - 02')
        // .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('===== Scenario 2: Add Lotted Item =====')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            'CRUD - LTI - 02'
                            , 'Test Lotted Item Manual'
                            , 'CRUD - Category'
                            , 'CRUD - Commodity'
                            , 1
                            , 'Test_Pounds'
                            , 'Test_Pounds'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')

        /*====================================== Add Non Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .selectSearchRowValue('CRUD - NLTI - 01','ItemNo',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', 'CRUD - NLTI - 01')
        // .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                .clickButton('Close')
                .waitUntilLoaded('')
                    .displayText('===== Scenario 3: Add Non Lotted Item =====')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            'CRUD - NLTI - 01'
                            , 'Test Non Lotted Item Negative Inventory No'
                            , 'CRUD - Category'
                            , 'CRUD - Commodity'
                            , 4
                            , 'Test_Pounds'
                            , 'Test_Pounds'
                            , 10
                            , 10
                            , 40
                        )
                    })
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Pre-setup done =====')


        //region Scenario 4: Add Non Lotted Item - Negative Inventory Yes
        .displayText('===== Scenario 4: Add Non Lotted Item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .selectSearchRowValue('CRUD - NLTI - 02','ItemNo',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', 'CRUD - NLTI - 02')
        // .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('New')
                    .waitUntilLoaded('icitem')
                    .enterData('Text Field','ItemNo','CRUD - NLTI - 02')
                    .enterData('Text Field','Description','CRUD - NLTI - 01 Negative Inventroy Yes Item')
                    .selectComboBoxRowValue('Category', 'CRUD - Category', 'Category',0)
                    .selectComboBoxRowValue('Commodity', 'CRUD - Commodity', 'Commodity',0)
                    .selectComboBoxRowNumber('LotTracking',4,0)
                    .verifyData('Combo Box','Tracking','Item Level')

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
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'Test_Pounds', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'Test_Pounds', 'ReceiveUom',0)
                    .selectComboBoxRowNumber('NegativeInventory',1,0)
                    .waitTillLoaded('')
                    .clickMessageBoxButton('ok')
                    .waitUntilLoaded('')
                    .clickButton('Save')
                    .waitUntilLoaded('')
                    .clickButton('Close')

                    .clickButton('AddLocation')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
                    .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
                    .selectComboBoxRowValue('IssueUom', 'Test_Pounds', 'IssueUom',0)
                    .selectComboBoxRowValue('ReceiveUom', 'Test_Pounds', 'ReceiveUom',0)
                    .selectComboBoxRowNumber('NegativeInventory',1,0)
                    .waitTillLoaded('')
                    .clickMessageBoxButton('ok')
                    .waitUntilLoaded('')
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
                    .waitUntilLoaded('')
                    .displayText('===== Add Non Lotted Item - Negative Inventory Yes Done=====')
                    //endregion
                    .done();
            },
            continueOnFail: true
        })
        .waitUntilLoaded('')
        .clickButton('Close')

        //region Scenario 5: Update an Item
        .displayText('===== Scenario 5: Update an Item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('CRUD - LTI - 01', 'strOrderType', 1)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .enterData('Text Field','Description','Test Lotted Item Serial - Updated')
        .waitUntilLoaded('')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitTillLoaded('')
        .clickButton('Close')

        .displayText('===== Check Updated Fields Item =====')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('CRUD - LTI - 01', 'strOrderType', 1)
        .waitUntilLoaded('')
        .waitUntilLoaded('')
        .verifyData('Text Field','Description', 'Test Lotted Item Serial - Updated')
        .addResult('Successfully Updated',2000)
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Update an Item Done=====')
        //endregion

        //region Scenario 6: Duplicate an Item
        .displayText('===== Scenario 6: Duplicate an Item =====')
        .clickMenuScreen('Items','Screen')
        .selectSearchRowValue('CRUD - LTI - 01-copy','ItemNo',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', 'CRUD - LTI - 01-copy')
        // .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                    .displayText('Item already exists.')
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    .doubleClickSearchRowValue('CRUD - LTI - 01', 'strOrderType', 1)
                    .waitUntilLoaded('')
                    .waitUntilLoaded('')
                    .clickButton('Duplicate')
                    .waitUntilLoaded('')
                    .waitTillLoaded('')
                    .verifyData('Combo Box','LotTracking','Yes - Serial Number')
                    .verifyData('Combo Box','Category','CRUD - Category')
                    .verifyData('Combo Box','Commodity','CRUD - Commodity')

                    .clickTab('Setup')
                    .waitTillLoaded('')
                    .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'Inventory Adjustment')
                    .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory In-Transit')
                    .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Sales Account')
                    .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Cost of Goods')
                    .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory')
                    .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'AP Clearing')

                    .verifyGridData('GlAccounts', 6, 'colGLAccountId', '21000-0000-000')
                    .verifyGridData('GlAccounts', 5, 'colGLAccountId', '16000-0000-000')
                    .verifyGridData('GlAccounts', 4, 'colGLAccountId', '50000-0000-000')
                    .verifyGridData('GlAccounts', 3, 'colGLAccountId', '40010-0001-006')
                    .verifyGridData('GlAccounts', 2, 'colGLAccountId', '16050-0000-000')
                    .verifyGridData('GlAccounts', 1, 'colGLAccountId', '16040-0000-000')

                    .clickTab('Location')
                    .waitTillLoaded('')
                    .verifyGridData('LocationStore', 2, 'colLocationLocation', '0001-Fort Wayne')
                    .verifyGridData('LocationStore', 1, 'colLocationLocation', '0002 - Indianapolis')

                    .clickTab('Pricing')
                    .waitUntilLoaded('')
                    .verifyGridData('Pricing', 1, 'strLocationName', '0002 - Indianapolis')
                    .verifyGridData('Pricing', 1, 'strPricingMethod', 'Markup Standard Cost')
                    .verifyGridData('Pricing', 1, 'dblAmountPercent', '40')
                    .verifyGridData('Pricing', 2, 'strLocationName', '0001-Fort Wayne')
                    .verifyGridData('Pricing', 2, 'strPricingMethod', 'Markup Standard Cost')
                    .verifyGridData('Pricing', 2, 'dblAmountPercent', '40')
                    .displayText('===== Duplicate an Item Done=====')
                    //endregion
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitTillLoaded('')
        // .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        // .clickMessageBoxButton('yes')
        // .waitTillLoaded('')

        //region Scenario 7: Check Required Fields
        .displayText('===== Scenario 7: Check Required Fields =====')
        .clickMenuScreen('Items','Screen')
        .waitTillLoaded('')
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .waitTillLoaded('')
        .clickButton('Save')
        .waitTillLoaded('')
        .clickButton('Close')
        .waitTillLoaded('')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .displayText('===== Check Required Fields Done=====')
        //endregion

        //region Scenario 8: Save Duplicate Item No.
        .displayText('===== Scenario 8: Save Duplicate Item No. =====')
        .clickMenuScreen('Items','Screen')
        .waitTillLoaded('')
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .waitTillLoaded('')
        .enterData('Text Field','ItemNo','CRUD - LTI - 01')
        .enterData('Text Field','Description','001 - CRUD Lotted Item Serial')
        .selectComboBoxRowValue('Category', 'CRUD - Category', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'CRUD - Commodity', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',2,0)
        .clickButton('Close')
        .waitTillLoaded('')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .waitTillLoaded('')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','Item No must be unique.','ok','error')
        .waitTillLoaded('')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .enterData('Text Field','ItemNo','CRUD - LTI - 10')
        .enterData('Text Field','Description','CRUD - LTI - 010 Lotted Item Serial')
        .clickButton('Save')
        .waitTillLoaded('')
        .clickButton('Close')

        .displayText('===== Save Duplicate Item No. Done=====')
        //endregion

        .done();


})