StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

         //region Scenario 1: Feed Stock - Add a Record
         .displayText('===== Scenario 1: Feed Stock - Add a Record  =====')
         .clickMenuFolder('Inventory','Folder')
         .clickMenuScreen('Fuel Types','Screen')
         .clickButton('Close')
         .clickButton('FeedStock')
         .waitTillLoaded('icfeedstock')
         .enterGridData('GridTemplate', 1, 'colRinFeedStockCode', 'Test Feed Stock 1')
         .enterGridData('GridTemplate', 1, 'colDescription', 'Test Description 1')
         .verifyStatusMessage('Edited')
         .clickButton('Save')
         .verifyStatusMessage('Saved')
         .clickButton('Close')
         .markSuccess('===== Add a record successful  =====')

         //region Scenario 2: Fuel Category - Add Multiple Records
         .displayText('===== Scenario 2: Fuel Category - Add Multiple Records  =====')
         .clickButton('FeedStock')
         .waitTillLoaded('icfeedstock')
         .enterGridData('GridTemplate', 2, 'colRinFeedStockCode', 'Test Feed Stock 2')
         .enterGridData('GridTemplate', 2, 'colDescription', 'Test Description 2')
         .enterGridData('GridTemplate', 3, 'colRinFeedStockCode', 'Test Feed Stock 3')
         .enterGridData('GridTemplate', 3, 'colDescription', 'Test Description 3')
         .verifyStatusMessage('Edited')
         .clickButton('Save')
         .verifyStatusMessage('Saved')
         .clickButton('Close')
         .markSuccess('===== Add multiple records successful  =====')
         //endregion


         //region Scenario 3: Add another record, Click Close button, do NOT save the changes
         .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
         .clickButton('FeedStock')
         .waitTillLoaded('icfeedstock')
         .enterGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 4')
         .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
         .clickButton('Close')
         .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
         .clickMessageBoxButton('no').wait(500)
         .clickButton('FeedStock')
         .waitTillLoaded('icfeedstock')
         .verifyGridData('GridTemplate', 3, 'colRinFeedStockCode', '')
         .verifyGridData('GridTemplate', 3, 'colDescription', '')
         .clickButton('Close')
         .markSuccess('===== Click Close and not save record successful =====')
         //endregion


         //region Scenario 4: Add another record, click Close, Cancel
         .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
         .clickButton('FeedStock')
         .waitTillLoaded('icfeedstock')
         .enterGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 4')
         .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 4')
         .clickButton('Close')
         .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
         .clickMessageBoxButton('cancel').wait(500)
         .verifyGridData('GridTemplate', 3, 'colRinFeedStockCode', 'Test Feed Stock 4')
         .verifyGridData('GridTemplate', 3, 'colDescription', 'Test Description 4')
         .clickButton('Close')
         .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
         .clickMessageBoxButton('no').wait(500)
         .markSuccess('===== Click close cancel record successful  =====')
         //endregion


         //region Scenario 5: Fuel Category - Add duplicate Record
         .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
         .clickButton('FeedStock')
         .waitTillLoaded('icfeedstock')
         .enterGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 1')
         .enterGridData('GridTemplate', 4, 'colDescription', 'Test Description 1')
         .verifyStatusMessage('Edited')
         .clickButton('Save').wait(500)
         .verifyMessageBox('iRely i21','Feed Stock must be unique.','ok','error')
         .clickMessageBoxButton('ok')
         .clickButton('Close')
         .markSuccess('===== Add Duplicate record scenario successful  =====')
         //endregion


         //region Scenario 6: Add Description only
         .displayText('===== Scenario 6: Add Description only =====')
         .clickButton('FeedStock')
         .waitTillLoaded('icfeedstock')
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
         .clickButton('FeedStock')
         .waitTillLoaded('icfeedstock')
         .enterGridData('GridTemplate', 4, 'colRinFeedStockCode', 'Test Feed Stock 4')
         .verifyStatusMessage('Edited')
         .clickButton('Save')
         .verifyStatusMessage('Saved')
         .clickButton('Close').wait(500)
         .markSuccess('===== Add primary key only successful  =====')
         //endregion*/



        .done();

})