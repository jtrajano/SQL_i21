StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Fuel Code - Add a Record
        .displayText('===== Scenario 1: Fuel Code - Add a Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .clickButton('Close')
        .clickButton('FuelCode')
        .waitUntilLoaded('icfuelcode')
        .enterGridData('GridTemplate', 1, 'colRinFuelCode', 'Test Fuel Code 1')
        .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //region Scenario 2: Fuel Category - Add Multiple Records
        .displayText('===== Scenario 2: Fuel Category - Add Multiple Records  =====')
        .clickButton('FuelCode')
        .waitUntilLoaded('icfuelcode')
        .enterGridData('GridTemplate', 2, 'colRinFuelCode', 'Test Fuel Code 2')
        .enterGridData('GridTemplate', 2, 'colDescription', 'Test Description 2')
        .enterGridData('GridTemplate', 3, 'colRinFuelCode', 'Test Fuel Code 3')
        .enterGridData('GridTemplate', 3, 'colDescription', 'Test Description 3')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 3: Add another record, Click Close button, do NOT save the changes
        .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
        .clickButton('FuelCode')
        .waitUntilLoaded('icfuelcode')
        .enterGridData('GridTemplate', 4, 'colRinFuelCode', 'Test Fuel Code 4')
        .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .clickButton('FuelCode')
        .waitUntilLoaded('icfuelcode')
        .verifyGridData('GridTemplate', 4, 'colRinFuelCode', '')
        .verifyGridData('GridTemplate', 4, 'colDescription', '')
        .clickButton('Close')
        //endregion


        //region Scenario 4: Add another record, click Close, Cancel
        .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
        .clickButton('FuelCode')
        .waitUntilLoaded('icfuelcode')
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
        .waitUntilLoaded('icfuelcode')
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
        .waitUntilLoaded('icfuelcode')
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
        .waitUntilLoaded('icfuelcode')
        .enterGridData('GridTemplate', 4, 'colRinFuelCode', 'Test Fuel Code 4')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close') 
        //endregion*/



        .done();

})