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
        //  .filterGridRecords('Search', 'FilterGrid', 'Indy Storage')
        //  .waitUntilLoaded('')
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
        .clickMenuScreen('Categories','Screen')
        .selectSearchRowValue('CRUD - Category','CategoryCode',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', 'CRUD - Category')
        // .waitUntilLoaded()
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
        .waitUntilLoaded('')
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
        .selectSearchRowValue('001 - DLTI','ItemNo',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', '001 - DLTI')
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
                    .displayText('===== Scenario 1: Add Lotted Item Serial =====')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            '001 - DLTI'
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
                    .done();
            },
            continueOnFail: true
        })

        .clickButton('Close')
        .waitUntilLoaded('')

        .clickMenuScreen('Items','Screen')
        .selectSearchRowValue('002 - DLTI','ItemNo',1,1)
        .waitUntilLoaded('')
        // .filterGridRecords('Search', 'FilterGrid', '002 - DLTI')
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
                    .displayText('===== Scenario 1: Add Lotted Item Serial =====')
                    .clickButton('Close')
                    .waitUntilLoaded('')
                    .addFunction(function(next){
                        commonIC.addInventoryItem
                        (t,next,
                            '002 - DLTI'
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
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')


        //region Secnario 1: Delete Unused Item
        .displayText('===== Scenario 1: Delete Unused Item =====')
        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded()
        .waitUntilLoaded('')
        .doubleClickSearchRowValue('001 - DLTI', 'strItemNo', 1)
        .waitUntilLoaded('')
        .clickButton('Delete')
//        .verifyMessageBox('iRely i21','Are you sure you want to delete Item 001 - DLTI?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded('')
        .clearTextFilter('FilterGrid')

        .waitUntilLoaded()
        .waitUntilLoaded('')
        .doubleClickSearchRowValue('002 - DLTI', 'strItemNo', 1)
        .waitUntilLoaded('')
        .clickButton('Delete')
//        .verifyMessageBox('iRely i21','Are you sure you want to delete Item 001 - DLTI?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded('')
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .displayText('===== Scenario 1: Delete Unused Item Done=====')
        //endregion

        //region Secnario 2: Delete Used Item
        .displayText('===== Scenario 2: Delete Used Item =====')
        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded('')
        .doubleClickSearchRowValue('87G', 'strItemNo', 1)
        .waitUntilLoaded('')
        .clickButton('Delete')
//        .verifyMessageBox('iRely i21','Are you sure you want to delete Item 87G?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','The record you are trying to delete is being used.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .waitTillLoaded('')
        .displayText('===== Scenario 2: Delete Used Item Done=====')
        //endregion


        .done();

})