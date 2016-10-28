StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Feed Stock - Add a Record
        .displayText('===== Scenario 1: Production Process - Add a Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .clickButton('Close')
        .clickButton('ProductionProcess')
        .waitTillLoaded('icprocesscode')
        .enterGridData('GridTemplate', 1, 'colRinProcessCode', 'Test Process Code 1')
        .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .markSuccess('===== Add a record successful  =====')

        //region Scenario 2: Fuel Category - Add Multiple Records
        .displayText('===== Scenario 2: Fuel Category - Add Multiple Records  =====')
        .clickButton('ProductionProcess')
        .waitTillLoaded('icprocesscode')
        .enterGridData('GridTemplate', 2, 'colRinProcessCode', 'Test Process Code 2')
        .enterGridData('GridTemplate', 2, 'colDescription', 'Test Description 2')
        .enterGridData('GridTemplate', 3, 'colRinProcessCode', 'Test Process Code 3')
        .enterGridData('GridTemplate', 3, 'colDescription', 'Test Description 3')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .markSuccess('===== Add multiple records successful  =====')
        //endregion


        //region Scenario 3: Add another record, Click Close button, do NOT save the changes
        .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
        .clickButton('ProductionProcess')
        .waitTillLoaded('icprocesscode')
        .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
        .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no').wait(500)
        .clickButton('ProductionProcess')
        .waitTillLoaded('icprocesscode')
        .verifyGridData('GridTemplate', 3, 'colRinProcessCode', '')
        .verifyGridData('GridTemplate', 3, 'colDescription', '')
        .clickButton('Close')
        .markSuccess('===== Click Close and not save record successful =====')
        //endregion


        //region Scenario 4: Add another record, click Close, Cancel
        .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
        .clickButton('ProductionProcess')
        .waitTillLoaded('icprocesscode')
        .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
        .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('cancel').wait(500)
        .verifyGridData('GridTemplate', 3, 'colRinProcessCode', 'Test Process Code 4')
        .verifyGridData('GridTemplate', 3, 'colDescription', 'Test Description 4')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no').wait(500)
        .markSuccess('===== Click close cancel record successful  =====')
        //endregion


        //region Scenario 5: Fuel Category - Add duplicate Record
        .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
        .clickButton('ProductionProcess')
        .waitTillLoaded('icprocesscode')
        .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 1')
        .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 1')
        .verifyStatusMessage('Edited')
        .clickButton('Save').wait(500)
        .verifyMessageBox('iRely i21','Production Process must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close')
        .markSuccess('===== Add Duplicate record scenario successful  =====')
        //endregion


        //region Scenario 6: Add Description only
        .displayText('===== Scenario 6: Add Description only =====')
        .clickButton('ProductionProcess')
        .waitTillLoaded('icprocesscode')
        .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .clickButton('Close').wait(500)
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no').wait(500)
        .markSuccess('===== Add description or equivalence value only is successful =====')
        //endregion


        //region Scenario 7: Add Primary Key only
        .displayText('===== Scenario 7: Add Primary Key only=====')
        .clickButton('ProductionProcess')
        .waitTillLoaded('icprocesscode')
        .enterGridData('GridTemplate', 4, 'colRinProcessCode', 'Test Process Code 4')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close').wait(500)
        .markSuccess('===== Add primary key only successful  =====')
        //endregion*/



        .done();

})