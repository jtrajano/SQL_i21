StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        /*======================================  Scenario 1: Feed Stock - Add a Record  ======================================*/
        //region
        .displayText('===== Scenario 1: Feed Stock - Add a Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded()
        .continueIf({
            expected: 'icfueltype',
            actual: function(win){
                return win.alias[0].replace('widget.', '');
            },
            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })

        .clickButton('FeedStock')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Feed Stock 1')
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
                    .waitUntilLoaded()
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 1, 'colRinFeedStockCode', 'Test Feed Stock 1')
                    .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Feed Stock 1')
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

        /*====================================== Scenario 2: Feed Stock - Add Multiple Records   ======================================*/
        //region
        .displayText('===== Scenario 2: Feed Stock - Add Multiple Records  =====')
        .clickButton('FeedStock')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Feed Stock 2')
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
                    .waitUntilLoaded()
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 2, 'colRinFeedStockCode', 'Test Feed Stock 2')
                    .enterGridData('GridTemplate', 2, 'colDescription', 'Test Description 2')
                    .enterGridData('GridTemplate', 3, 'colRinFeedStockCode', 'Test Feed Stock 3')
                    .enterGridData('GridTemplate', 3, 'colDescription', 'Test Description 3')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Feed Stock 2')
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
        .clickButton('FeedStock')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Feed Stock 4')
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

                    /*====================================== Scenario 3: Add another record, Click Close button, do NOT save the changes  ======================================*/
                    .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 4')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .verifyGridData('GridTemplate', 4, 'colRinFeedStockCode', '')
                    .verifyGridData('GridTemplate', 4, 'colDescription', '')
                    .clickButton('Close')

                    /*====================================== Scenario 4: Add another record, click Close, Cancel  ======================================*/
                    .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 4')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('cancel')
                    .verifyGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 4')
                    .verifyGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()

                    /*====================================== Scenario 5: Fuel Category - Add duplicate Record  ======================================*/
                    .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 1')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyMessageBox('iRely i21','Feed Stock must be unique.','ok','error')
                    .clickMessageBoxButton('ok')
                    .clickButton('Close')

                    /*====================================== Scenario 6: Add Description only  ======================================*/
                    .displayText('===== Scenario 6: Add Description only =====')
                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()

                    /*====================================== Scenario 7: Add Primary Key only  ======================================*/
                    .displayText('===== Scenario 7: Add Primary Key only=====')
                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 4')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')


                    .clickButton('FeedStock')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Feed Stock 4')
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


        //region Scenario 1: Delete Unused Feed Stock
        .clickButton('FeedStock')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 1: Delete Unused Feed Stock Done=====')
        //endregion

        //region Scenario 2: Delete Used Feed Stock
        .displayText('=====  Scenario 2: Delete Used Feed Stock =====')
        .clickButton('FeedStock')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[2])
        .clickButton('Delete')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','The record you are trying to delete is being used.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 2: Delete Used Feed Stock Done=====')
        //endregion

        //region Scenario 3: Delete Multiple Feed Stock
        .displayText('=====  Scenario 3: Delete Multiple Feed Stock =====')
        .clickButton('FeedStock')
        .waitUntilLoaded('icfeedstockcode')
        .selectGridRowNumber('GridTemplate',[1,3])
        .clickButton('Delete')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 3: Delete Multiple Feed Stock Done=====')
        //endregion

        .done();

})