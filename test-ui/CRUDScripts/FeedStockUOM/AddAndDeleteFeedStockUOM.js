StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

   /*====================================== Pre-setup - Add Commodity ======================================*/
        //region
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'SC - Commodity - 01')
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
                        commonIC.addCommodity (t,next, 'SC - Commodity - 01', 'Test Smoke Commodity Description')
                    })
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')
        //endregion


        //region Scenario 1: Feed Stock UOM - Add a Record
        .displayText('===== Scenario 1: Feed Stock UOM - Add a Record  =====')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded()
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test_Pounds')
        .waitUntilLoaded('')
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdGridTemplate').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('GridTemplate',1,'strUnitMeasure','Test_Pounds','strUnitMeasure')
                    .enterGridData('GridTemplate', 1, 'colRinFeedStockUOMCode', 'Test UOM Code 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test_Pounds')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdGridTemplate').store.getCount() != 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        //endregion



        //region Scenario 2: Feed Stock UOM - Add Multiple Records
        .displayText('===== Scenario 2: Feed Stock UOM - Add Multiple Records  =====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test_KG')
        .waitUntilLoaded('')
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdGridTemplate').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('GridTemplate',2,'strUnitMeasure','Test_KG','strUnitMeasure')
                    .enterGridData('GridTemplate', 2, 'colRinFeedStockUOMCode', 'Test UOM Code2')
                    .selectGridComboBoxRowValue('GridTemplate',3,'strUnitMeasure','Test_60 KG bags','strUnitMeasure')
                    .enterGridData('GridTemplate', 3, 'colRinFeedStockUOMCode', 'Test UOM Code3')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test_KG')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdGridTemplate').store.getCount() != 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        //endregion



 /*====================================== Scenario 3-7 ======================================*/
        //region
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test_25 KG bags')
        .waitUntilLoaded('')
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdGridTemplate').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded('')

                    //region Scenario 3: Add another record, Click Close button, do NOT save the changes
                    .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
                    .selectGridComboBoxRowValue('GridTemplate',4,'strUnitMeasure','Test_25 KG bags','strUnitMeasure')
                    .enterGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', 'Test UOM Code4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .verifyGridData('GridTemplate', 4, 'colUOM', '')
                    .verifyGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', '')
                    .clickButton('Close')
                    //endregion


                    //region Scenario 4: Add another record, click Close, Cancel
                    .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('GridTemplate',4,'strUnitMeasure','Test_25 KG bags','strUnitMeasure')
                    .enterGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', 'Test UOM Code4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('cancel') 
                    .verifyGridData('GridTemplate', 4, 'colUOM', 'Test_25 KG bags')
                    .verifyGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', 'Test UOM Code4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    //endregion


                    //region Scenario 5: Fuel Category - Add duplicate Record
                    .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('GridTemplate',4,'strUnitMeasure','Test_Pounds','strUnitMeasure')
                    .enterGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', 'Test UOM Code 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save') 
                    .verifyMessageBox('iRely i21','Feed Stock UOM must be unique.','ok','error')
                    .clickMessageBoxButton('ok')
                    .clickButton('Close')

                    //endregion


                    //region Scenario 6: Add Description only
                    .displayText('===== Scenario 6: Add Description only =====')
                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', 'Test UOM Code 4')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .clickButton('Close') 
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    //endregion


                    //region Scenario 7: Add Primary Key only
                    .displayText('===== Scenario 7: Add Primary Key only=====')
                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .selectGridComboBoxRowValue('GridTemplate',4,'strUnitMeasure','Test_25 KG bags','strUnitMeasure')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close') 


                    .clickButton('FeedStockUOM')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test_25 KG bags')
                    .waitUntilLoaded('')
                    .done();
            },
            continueOnFail: true
        })
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdGridTemplate').store.getCount() != 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        //endregion*/


        //region Scenario 1: Delete Unused Feed Stock UOM
        .displayText('===== NOTE!!! You can only execute this script when you finish executing Add Fuel Category up to Add Fuel type Script =====')
        .displayText('=====  Scenario 1: Delete Unused Feed Stock UOM =====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 1: Delete Unused Feed Stock UOM Done=====')
        //endregion

        // //region Scenario 2: Delete Used Feed Stock UOM
        // .displayText('=====  Scenario 2: Delete Used Feed Stock UOM =====')

        // .clickButton('FeedStockUOM')
        // .waitUntilLoaded('')
        // .selectGridRowNumber('GridTemplate',[2])
        // .clickButton('Delete')
        // //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        // .clickMessageBoxButton('yes')
        // .waitUntilLoaded('')
        // .clickButton('Save')
        // .waitUntilLoaded()
        // .verifyMessageBox('iRely i21','The record you are trying to delete is being used.','ok','error')
        // .clickMessageBoxButton('ok')
        // .waitUntilLoaded('')
        // .clickButton('Close')
        // .waitUntilLoaded()
        // .displayText('=====  Scenario 2: Delete Used Feed Stock UOM Done=====')
        // //endregion

        //region Scenario 3: Delete Multiple Feed Stock UOM
        .displayText('=====  Scenario 3: Delete Multiple Feed Stock UOM =====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[1,3])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 3 rows.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 3: Delete Multiple Feed Stock UOM Done=====')
        //endregion


        .done();

})