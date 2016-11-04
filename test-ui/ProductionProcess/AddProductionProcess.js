StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Production Process - Add a Record
        .displayText('===== Scenario 1: Production Process - Add a Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .clickButton('Close')
        .clickButton('ProductionProcess')
        .waitUntilLoaded('icprocesscode')
        .enterGridData('GridTemplate', 1, 'colRinProcessCode', 'Test Process Code 1')
        .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //region Scenario 2: Production Process - Add Multiple Records
        .displayText('===== Scenario 2: Production Process - Add Multiple Records  =====')
        .clickButton('ProductionProcess')
        .waitUntilLoaded('icprocesscode')
        .enterGridData('GridTemplate', 2, 'colRinProcessCode', 'Test Process Code 2')
        .enterGridData('GridTemplate', 2, 'colDescription', 'Test Description 2')
        .enterGridData('GridTemplate', 3, 'colRinProcessCode', 'Test Process Code 3')
        .enterGridData('GridTemplate', 3, 'colDescription', 'Test Description 3')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 3: Add another record, Click Close button, do NOT save the changes
        .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
        .clickButton('ProductionProcess')
        .waitUntilLoaded('icprocesscode')
        .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
        .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .clickButton('ProductionProcess')
        .waitUntilLoaded('icprocesscode')
        .verifyGridData('GridTemplate', 4, 'colRinProcessCode', '')
        .verifyGridData('GridTemplate', 4, 'colDescription', '')
        .clickButton('Close')
        //endregion


        //region Scenario 4: Add another record, click Close, Cancel
        .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
        .clickButton('ProductionProcess')
        .waitUntilLoaded('icprocesscode')
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
        .waitUntilLoaded('icprocesscode')
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
        .waitUntilLoaded('icprocesscode')
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
        .waitUntilLoaded('icprocesscode')
        .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close') 
        //endregion*/



        .done();

})