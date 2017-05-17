StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        /*====================================== Scenario 1: Fuel Category - Add a Record  ======================================*/
        //region
        .displayText('===== Scenario 1: Fuel Category - Add a Record  =====')
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

        .clickButton('FuelCategory')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Category1')
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
                    .enterGridData('GridTemplate', 1, 'colRinFuelCategoryCode', 'Test Fuel Category1')
                    .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
                    .enterGridData('GridTemplate', 1, 'colEquivalenceValue', 'Test Equivalence Value1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .clickButton('FuelCategory')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Category1')
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


        /*====================================== Scenario 2: Fuel Category - Add Multiple Records  ======================================*/
        //region
        .displayText('===== Scenario 2: Fuel Category - Add Multiple Records  =====')
        .clickButton('FuelCategory')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Category2')
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
                    .enterGridData('GridTemplate', 2, 'colRinFuelCategoryCode', 'Test Fuel Category2')
                    .enterGridData('GridTemplate', 2, 'colDescription', 'Test Description 2')
                    .enterGridData('GridTemplate', 2, 'colEquivalenceValue', 'Test Equivalence Value2')
                    .enterGridData('GridTemplate', 3, 'colRinFuelCategoryCode', 'Test Fuel Category3')
                    .enterGridData('GridTemplate', 3, 'colDescription', 'Test Description 3')
                    .enterGridData('GridTemplate', 3, 'colEquivalenceValue', 'Test Equivalence Value3')
                    .enterGridData('GridTemplate', 4, 'colRinFuelCategoryCode', 'Test Fuel Category4')
                    .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
                    .enterGridData('GridTemplate', 4, 'colEquivalenceValue', 'Test Equivalence Value4')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .clickButton('FuelCategory')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Category2')
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

        .clickButton('FuelCategory')
        .waitUntilLoaded('')
        .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Category5')
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
                    //region
                    .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 5, 'colRinFuelCategoryCode', 'Test Fuel Category5')
                    .enterGridData('GridTemplate', 5, 'colDescription', 'Test Description 5')
                    .enterGridData('GridTemplate', 5, 'colEquivalenceValue', 'Test Equivalence Value5')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    .clickButton('FuelCategory')
                    .verifyGridData('GridTemplate', 5, 'colRinFuelCategoryCode', '')
                    .verifyGridData('GridTemplate', 5, 'colDescription', '')
                    .verifyGridData('GridTemplate', 5, 'colEquivalenceValue', '')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    //endregion

                    /*====================================== Scenario 4: Add another record, click Close, Cancel  ======================================*/
                    //region
                    .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
                    .clickButton('FuelCategory')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 5, 'colRinFuelCategoryCode', 'Test Fuel Category5')
                    .enterGridData('GridTemplate', 5, 'colDescription', 'Test Description 5')
                    .enterGridData('GridTemplate', 5, 'colEquivalenceValue', 'Test Equivalence Value5')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('cancel')
                    .verifyGridData('GridTemplate', 5, 'colRinFuelCategoryCode', 'Test Fuel Category5')
                    .verifyGridData('GridTemplate', 5, 'colDescription', 'Test Description 5')
                    .verifyGridData('GridTemplate', 5, 'colEquivalenceValue', 'Test Equivalence Value5')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()
                    //endregion


                    /*====================================== Scenario 5: Fuel Category - Add duplicate Record  ======================================*/
                    //region
                    .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
                    .clickButton('FuelCategory')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 5, 'colRinFuelCategoryCode', 'Test Fuel Category1')
                    .enterGridData('GridTemplate', 5, 'colDescription', 'Test Description 1')
                    .enterGridData('GridTemplate', 5, 'colEquivalenceValue', 'Test Equivalence Value1')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyMessageBox('iRely i21','Fuel Category must be unique.','ok','error')
                    .clickMessageBoxButton('ok')
                    .clickButton('Close')
                    //endregion

                    /*======================================  Scenario 6: Add Description or Equivalence Value Only  ======================================*/
                    .displayText('===== Scenario 6: Add Description or Equivalence Value Only =====')
                    .clickButton('FuelCategory')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 5, 'colDescription', 'Test Description 5')
                    .enterGridData('GridTemplate', 5, 'colEquivalenceValue', 'Test Equivalence Value5')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .clickButton('Close')
                    .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                    .clickMessageBoxButton('no')
                    .waitUntilLoaded()

                    /*======================================  Scenario 7: Add Primary Key only  ======================================*/
                    .displayText('===== Scenario 7: Add Primary Key only =====')
                    .clickButton('FuelCategory')
                    .waitUntilLoaded('')
                    .enterGridData('GridTemplate', 5, 'colRinFuelCategoryCode', 'Test Fuel Category5')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .clickButton('FuelCategory')
                    .waitUntilLoaded('')
                    .filterGridRecords('GridTemplate', 'FilterGrid', 'Test Fuel Category5')
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

        /*====================================== DELETE FUEL CATEGORY  ======================================*/
        //region
        .displayText('=====  DELETE FUEL CARTEGORY =====')
        .displayText('=====  Scenario 1: Delete Unused Fuel Category =====')

        .clickButton('FuelCategory')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 1: Delete Unused Fuel Category Done=====')
        //endregion

        //region Scenario 2: Delete Used Fuel Category
        .displayText('=====  Scenario 2: Delete Used Fuel Category =====')

        .clickButton('FuelCategory')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[3])
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
        .displayText('=====  Scenario 2: Delete Used Fuel Category Done=====')
        //endregion

        //region Scenario 3: Delete Multiple Fuel Category
        .displayText('=====  Scenario 3: Delete Multiple Fuel Category =====')
        .clickButton('FuelCategory')
        .waitUntilLoaded('icfuelcategory')
        .selectGridRowNumber('GridTemplate',[1,2,4])
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 3: Delete Multiple Fuel Category Done=====')
        //endregion



        .done();

})