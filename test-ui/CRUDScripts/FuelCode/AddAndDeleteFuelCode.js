StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Fuel Code - Add a Record

        .displayText('===== Scenario 1: Feed Stock - Add a Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded()
        .clickButton('FuelCode')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Code 1')
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
                    .displayText('===== Scenario 1: Fuel Code - Add a Record  =====')
                    .enterGridData('GridTemplate', 1, 'colRinFuelCode', 'Test Fuel Code 1')
                    .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Code 1')
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
     

        //region Scenario 2: Fuel Category - Add Multiple Records
        .displayText('===== Scenario 2: Feed Stock - Add Multiple Records  =====')
        .clickButton('FuelCode')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Code 2')
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
                    .displayText('===== Scenario 2: Fuel Category - Add Multiple Records  =====')
                    .enterGridData('GridTemplate', 2, 'colRinFuelCode', 'Test Fuel Code 2')
                    .enterGridData('GridTemplate', 2, 'colDescription', 'Test Description 2')
                    .enterGridData('GridTemplate', 3, 'colRinFuelCode', 'Test Fuel Code 3')
                    .enterGridData('GridTemplate', 3, 'colDescription', 'Test Description 3')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded('')

                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Code 2')
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
        .clickButton('FuelCode')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Code 4')
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
                    .enterGridData('GridTemplate', 4, 'colRinFuelCode', 'Test Fuel Code 4')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .verifyGridData('GridTemplate', 4, 'colRinFuelCode', '')
                    .verifyGridData('GridTemplate', 4, 'colDescription', '')
                    .clickButton('Close')
                    //endregion
            
            
                    //region Scenario 4: Add another record, click Close, Cancel
                    .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinFuelCode', 'Test Fuel Code 4')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('cancel') 
                    .verifyGridData('GridTemplate', 4, 'colRinFuelCode', 'Test Fuel Code 4')
                    .verifyGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    //endregion
            
            
                    //region Scenario 5: Fuel Category - Add duplicate Record
                    .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinFuelCode', 'Test Fuel Code 1')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save') 
                    .verifyMessageBox('iRely i21','Fuel Code must be unique.','ok','error')
                    .clickMessageBoxButton('ok')
                    .clickButton('Close')
                    //endregion
            
            
                    //region Scenario 6: Add Description only
                    .displayText('===== Scenario 6: Add Description only =====')
                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .clickButton('Close') 
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    //endregion
            
            
                    //region Scenario 7: Add Primary Key only
                    .displayText('===== Scenario 7: Add Primary Key only=====')
                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinFuelCode', 'Test Fuel Code 4')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close') 


                    .clickButton('FuelCode')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Code 4')
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


         //region Scenario 1: Delete Unused Fuel Code
         .displayText('===== NOTE!!! You can only execute this script when you finish executing Add Fuel Category up to Add Fuel type Script =====')
         .displayText('=====  Scenario 1: Delete Unused Fuel Code =====')
 
         .clickButton('FuelCode')
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
         .displayText('=====  Scenario 1: Delete Unused Fuel Code Done=====')
         //endregion
 
        //  //region Scenario 2: Delete Used Fuel Code
        //  .displayText('=====  Scenario 2: Delete Used Fuel Code =====')
 
        //  .clickButton('FuelCode')
        //  .waitUntilLoaded('')
        //  .selectGridRowNumber('GridTemplate',[2])
        //  .clickButton('Delete')
        //  //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        //  .clickMessageBoxButton('yes')
        //  .waitUntilLoaded('')
        //  .clickButton('Save')
        //  .waitUntilLoaded()
        //  .verifyMessageBox('iRely i21','The record you are trying to delete is being used.','ok','error')
        //  .clickMessageBoxButton('ok')
        //  .waitUntilLoaded('')
        //  .clickButton('Close')
        //  .waitUntilLoaded()
        //  .displayText('=====  Scenario 2: Delete Used Fuel Code Done=====')
        //  //endregion
 
         //region Scenario 3: Delete Multiple Fuel Code
         .displayText('=====  Scenario 3: Delete Multiple Fuel Code =====')
         .clickButton('FuelCode')
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
         .displayText('=====  Scenario 3: Delete Multiple Fuel Code Done=====')
         //endregion

        
        //endregion*/



        .done();

})