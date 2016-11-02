StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Fuel Category - Add a Record
        .displayText('===== Scenario 1: Fuel Category - Add a Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .clickButton('Close')
        .clickButton('FuelCategory')
        .waitTillLoaded('icfuelcategory')
        .enterGridData('GridTemplate', 1, 'colRinFuelCategoryCode', 'Test Fuel Category1')
        .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
        .enterGridData('GridTemplate', 1, 'colEquivalenceValue', 'Test Equivalence Value1')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .logSuccess('===== Add a record successful  =====')

        //region Scenario 2: Fuel Category - Add Multiple Records
        .displayText('===== Scenario 2: Fuel Category - Add Multiple Records  =====')
        .clickButton('FuelCategory')
        .waitTillLoaded('icfuelcategory')
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
        .logSuccess('===== Add multiple record successful  =====')
        //endregion

        //region Scenario 3: Add another record, Click Close button, do NOT save the changes
        .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
        .clickButton('FuelCategory')
        .waitTillLoaded('icfuelcategory')
        .enterGridData('GridTemplate', 5, 'colRinFuelCategoryCode', 'Test Fuel Category5')
        .enterGridData('GridTemplate', 5, 'colDescription', 'Test Description 5')
        .enterGridData('GridTemplate', 5, 'colEquivalenceValue', 'Test Equivalence Value5')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitTillLoaded()
        .clickButton('FuelCategory')
        .verifyGridData('GridTemplate', 5, 'colRinFuelCategoryCode', '')
        .verifyGridData('GridTemplate', 5, 'colDescription', '')
        .verifyGridData('GridTemplate', 5, 'colEquivalenceValue', '')
        .clickButton('Close')
        .logSuccess('===== Click Close and not save record successful =====')
        //endregion

        //region Scenario 4: Add another record, click Close, Cancel
        .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
        .clickButton('FuelCategory')
        .waitTillLoaded('icfuelcategory')
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
        .waitTillLoaded()
        .logSuccess('===== Click close cancel record successful  =====')
        //endregion


        //region Scenario 5: Fuel Category - Add duplicate Record
        .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
        .clickButton('FuelCategory')
        .waitTillLoaded('icfuelcategory')
        .enterGridData('GridTemplate', 5, 'colRinFuelCategoryCode', 'Test Fuel Category1')
        .enterGridData('GridTemplate', 5, 'colDescription', 'Test Description 1')
        .enterGridData('GridTemplate', 5, 'colEquivalenceValue', 'Test Equivalence Value1')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyMessageBox('iRely i21','Fuel Category must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close')
        .logSuccess('===== Add Duplicate record scenario successful  =====')
        //endregion


        //region Scenario 6: Add Description or Equivalence Value Only
        .displayText('===== Scenario 6: Add Description or Equivalence Value Only =====')
        .clickButton('FuelCategory')
        .waitTillLoaded('icfuelcategory')
        .enterGridData('GridTemplate', 5, 'colDescription', 'Test Description 5')
        .enterGridData('GridTemplate', 5, 'colEquivalenceValue', 'Test Equivalence Value5')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitTillLoaded()
        .logSuccess('===== Add description or equivalence value only is successful =====')
        //endregion

        //region Scenario 7: Add Primary Key only
        .displayText('===== Scenario 7: Add Primary Key only=====')
        .clickButton('FuelCategory')
        .waitTillLoaded('icfuelcategory')
        .enterGridData('GridTemplate', 5, 'colRinFuelCategoryCode', 'Test Fuel Category5')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .logSuccess('===== Add primary key only successful  =====')
        //endregion



        .done();

})