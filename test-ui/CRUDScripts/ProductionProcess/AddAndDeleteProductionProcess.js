StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Production Process - Add a Record
        .displayText('===== Scenario 1: Production Process - Add a Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded()
        .clickButton('ProductionProcess')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Process Code 1')
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
                    .enterGridData('GridTemplate', 1, 'colRinProcessCode', 'Test Process Code 1')
                    .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded('')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .clickButton('ProductionProcess')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Process Code 1')
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


        //region Scenario 2: Production Process - Add Multiple Records
        .displayText('===== Scenario 2: Production Process - Add Multiple Records  =====')
        .clickButton('ProductionProcess')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Process Code 2')
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
                    .enterGridData('GridTemplate', 2, 'colRinProcessCode', 'Test Process Code 2')
                    .enterGridData('GridTemplate', 2, 'colDescription', 'Test Description 2')
                    .enterGridData('GridTemplate', 3, 'colRinProcessCode', 'Test Process Code 3')
                    .enterGridData('GridTemplate', 3, 'colDescription', 'Test Description 3')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .clickButton('ProductionProcess')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Process Code 2')
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
        .clickButton('ProductionProcess')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Process Code 4')
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
                    .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickButton('ProductionProcess')
                    .waitUntilLoaded('')
                    .verifyGridData('GridTemplate', 4, 'colRinProcessCode', '')
                    .verifyGridData('GridTemplate', 4, 'colDescription', '')
                    .clickButton('Close')
                    //endregion
            
            
                    //region Scenario 4: Add another record, click Close, Cancel
                    .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
                    .clickButton('ProductionProcess')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('cancel') 
                    .verifyGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
                    .verifyGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    //endregion
            
            
                    //region Scenario 5: Fuel Category - Add duplicate Record
                    .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
                    .clickButton('ProductionProcess')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 1')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save') 
                    .verifyMessageBox('iRely i21','Production Process must be unique.','ok','error')
                    .clickMessageBoxButton('ok')
                    .clickButton('Close')
                    //endregion
            
            
                    //region Scenario 6: Add Description only
                    .displayText('===== Scenario 6: Add Description only =====')
                    .clickButton('ProductionProcess')
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
                    .clickButton('ProductionProcess')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close') 


                    .clickButton('ProductionProcess')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Process Code 4')
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

        //region Scenario 1: Delete Unused Production Process
        .displayText('=====  Scenario 1: Delete Unused Production Process =====')
        .clickButton('ProductionProcess')
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
        .displayText('=====  Scenario 1: Delete Unused Production Process Done=====')
        //endregion

        // //region Scenario 2: Delete Used Production Process
        // .displayText('=====  Scenario 2: Delete Used Production Process =====')

        // .clickButton('ProductionProcess')
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
        // .displayText('=====  Scenario 2: Delete Used Production Process Done=====')
        // //endregion

        //region Scenario 3: Delete Multiple Production Process
        .displayText('=====  Scenario 3: Delete Multiple Production Process =====')
        .clickButton('ProductionProcess')
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
        .displayText('=====  Scenario 3: Delete Multiple Production Process Done=====')
        //endregion




        .done();

})