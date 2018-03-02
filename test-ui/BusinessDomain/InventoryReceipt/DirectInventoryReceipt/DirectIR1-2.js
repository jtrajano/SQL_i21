StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //Presetup
        //region
        // .displayText('===== Pre-setup =====')
        // /*====================================== Add Another Company Location for Irelyadmin User and setup default decimals ======================================*/
        // .displayText('===== 1. Add Indianapolis for Company Location for irelyadmin User =====')
        // .clickMenuFolder('System Manager','Folder')
        // .clickMenuScreen('Users','Screen')
        // .waitUntilLoaded()
        // .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        // .waitUntilLoaded('')
        // .waitUntilLoaded()
        // .selectComboBoxRowValue('Timezone', '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi', 'Timezone',0)
        // .clickTab('User')
        // .waitUntilLoaded()
        // .clickTab('User Roles')

        // .waitUntilLoaded()
        // .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
        // .waitUntilLoaded()

        // .continueIf({
        //     expected: true,
        //     actual: function (win,next) {
        //         new iRely.FunctionalTest().start(t, next)
        //             .displayText('Location already exists.')
        //         return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() == 0;
        //     },
        //     success: function(next){
        //         new iRely.FunctionalTest().start(t, next)

        //             .displayText('Location is not yet existing.')
        //             .clickButton('Close')
        //             .waitUntilLoaded()
        //             .clickMessageBoxButton('no')
        //             .waitUntilLoaded()
        //             .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        //             .waitUntilLoaded('')
        //             .clickTab('User')
        //             .waitUntilLoaded()
        //             .clickTab('User Roles')
        //             .waitUntilLoaded()
        //             .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 'Dummy','strLocationName', '0002 - Indianapolis','strLocationName', 1)
        //             .selectGridComboBoxBottomRowValue('UserRoleCompanyLocationRolePermission', 'strUserRole', 'ADMIN', 'strUserRole', 1)
        //             .clickTab('Detail')
        //             .waitUntilLoaded()
        //             .selectComboBoxRowValue('UserNumberFormat', '1,234,567.89', 'UserNumberFormat',1)
        //             .clickButton('Save')
        //             .waitUntilLoaded()
        //             .clickButton('Close')
        //             .waitUntilLoaded()
        //             .doubleClickSearchRowValue('irelyadmin', 'strUsername', 1)
        //             .waitUntilLoaded('')
        //             .clickTab('User')
        //             .waitUntilLoaded()
        //             .clickTab('User Roles')
        //             .waitUntilLoaded()
        //             .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', '0002 - Indianapolis')
        //             .waitUntilLoaded()
        //             .done();
        //     },
        //     continueOnFail: true
        // })
        // .continueIf({
        //     expected: true,
        //     actual: function (win,next) {
        //         new iRely.FunctionalTest().start(t, next)
        //             .displayText('Location already exists.')
        //         return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() != 0;
        //     },
        //     success: function(next){
        //         new iRely.FunctionalTest().start(t, next)
        //             .clickButton('Close')
        //             .waitUntilLoaded()
        //             .clickMessageBoxButton('yes')
        //             .waitUntilLoaded()
        //             //.clickMenuFolder('System Manager','Folder')
        //             .waitUntilLoaded()
        //             .done();
        //     },
        //     continueOnFail: true
        // })
        // .clickButton('Close')

        /*====================================== Add Storage Location for Indianapolis======================================*/
       .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Storage Units','Screen')
        .filterGridRecords('Search', 'From', 'Indy Storage')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        //.waitUntilGridLoaded('Search')
        .continueIf({
            expected: true,
            actual: function (win,next) {
                return win.down('#grdSearch').store.getCount() == 0;
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('===== Scenario 1: Add New Storage Location. =====')
                    //.clickMenuScreen('Storage Locations','Screen')
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
        .clickButton('Close')
        //.clickMenuFolder('Inventory','Folder')
        /*====================================== Add Category ======================================*/
        //region
        //.clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'From', 'DIR - Category')
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
                    //.clickMenuFolder('Inventory','Folder')
                   // .clickButton('New')
                    .addFunction(function(next){
                        commonIC.addCategory (t,next, 'DIR - Category', 'Test DIR - Category', 2)
                    })
                    //.clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')

        /*====================================== Add Commodity ======================================*/

        // .clickMenuScreen('Commodities','Screen')
        // .filterGridRecords('Search', 'From', 'DIR - Commodity')
        // .waitUntilLoaded()
        // .continueIf({
        //     expected: true,
        //     actual: function (win,next) {
        //         new iRely.FunctionalTest().start(t, next)
        //             .displayText('Commodity already exists.')
        //         return win.down('#grdSearch').store.getCount() == 0;
        //     },

        //     success: function(next){
        //         new iRely.FunctionalTest().start(t, next)
                    //.clickMenuFolder('Inventory','Folder')
                    //Add Commodity
                    //.clickButton('New')
                    .displayText('===== Scenario 6: Add Commodity =====')
                    .addFunction(function(next){
                        commonIC.addCommodity (t,next, 'DIR - Commodity', 'Test DIR - Commodity')
                     })
        //             //.clickMenuFolder('Inventory','Folder')
        //             .waitUntilLoaded('')
        //             .done();
        //     },
        //     continueOnFail: true
        // })
        .clickButton('Close')


        /*====================================== Add Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'From', 'Direct - LTI - 01')
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
                    //.clickMenuFolder('Inventory','Folder')
                    //.clickButton('New')
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
                    //.clickMenuFolder('Inventory','Folder')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')


        /*====================================== Add Non Lotted Item ======================================*/
        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'From', 'Direct - NLTI - 01')
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
                    //.clickMenuFolder('Inventory','Folder')
                    //.clickButton('New')
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
                    //.clickMenuFolder('Inventory','Folder')
                    .done();
            },
            continueOnFail: true
        })
        //.clickMenuFolder('Inventory','Folder')
        .clickButton('Close')



        //Create Lotted Item Stock Unit KG
        .displayText('===== Add Commodity KG Stock Unit =====')
        //.clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'From', 'DIR - Commodity - 01')
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
                    //.clickMenuScreen('Commodities','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','CommodityCode','DIR - Commodity - 01')
                    .enterData('Text Field','Description','Test Corn Commodity')
                    .enterData('Text Field','DecimalsOnDpr','6.00')

                    .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Test_KG','strUnitMeasure')
                    .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'Test_KG', 'ysnStockUnit', true)
                    .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','Test_25 KG bags','strUnitMeasure')
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
        .clickButton('Close')

        .clickMenuScreen('Items','Screen')
        .filterGridRecords('Search', 'From', 'Direct - LTI - 02')
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
                    .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
                    .enterGridData('Pricing', 1, 'dblLastCost', '10')
                    .enterGridData('Pricing', 1, 'dblStandardCost', '10')
                    .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
                    .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

                    .verifyGridData('Pricing', 2, 'strLocationName', '0002-Indianapolis')
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
         .clickButton('Close')
        //.clickMenuFolder('Inventory','Folder')
        .displayText('===== Pre-setup done =====')
        //endregion

        //Create Direct IR for Lotted Item
        .displayText('===== Scenario 1: Create Direct IR for Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'Direct - LTI - 01','Test_Pounds', 100, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'Test_Pounds')
        })
        .displayText('===== Adding Stocks to Created Done =====')


        //Create Direct IR for Non Lotted Item
        .displayText('===== Scenario 2: Create Direct IR for Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'Direct - NLTI - 01','Test_Pounds', 100, 10)
        })


        .done();

})