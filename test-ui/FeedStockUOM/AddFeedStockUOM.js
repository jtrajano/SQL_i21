StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Feed Stock UOM - Add a Record
        .displayText('===== Scenario 1: Feed Stock UOM - Add a Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .clickButton('Close')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridComboBoxRowValue('GridTemplate',1,'strUnitMeasure','LB','strUnitMeasure')
        .enterGridData('GridTemplate', 1, 'colRinFeedStockUOMCode', 'Test UOM Code 1')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion

        //region Scenario 2: Feed Stock UOM - Add Multiple Records
        .displayText('===== Scenario 2: Feed Stock UOM - Add Multiple Records  =====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridComboBoxRowValue('GridTemplate',2,'strUnitMeasure','KG','strUnitMeasure')
        .enterGridData('GridTemplate', 2, 'colRinFeedStockUOMCode', 'Test UOM Code2')
        .selectGridComboBoxRowValue('GridTemplate',3,'strUnitMeasure','60 Kg Bag','strUnitMeasure')
        .enterGridData('GridTemplate', 3, 'colRinFeedStockUOMCode', 'Test UOM Code3')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 3: Add another record, Click Close button, do NOT save the changes
        .displayText('===== Scenario 3:  Add another record, Click Close button, do NOT save the changes =====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridComboBoxRowValue('GridTemplate',4,'strUnitMeasure','50 kg bag','strUnitMeasure')
        .enterGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', 'Test UOM Code4')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .verifyGridData('GridTemplate', 4, 'colUOM', '')
        .verifyGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', '')
        .clickButton('Close')
        //endregion


        //region Scenario 4: Add another record, click Close, Cancel
        .displayText('===== Scenario 4: Add another record, click Close, Cancel  =====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridComboBoxRowValue('GridTemplate',4,'strUnitMeasure','50 kg bag','strUnitMeasure')
        .enterGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', 'Test UOM Code4')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('cancel') 
        .verifyGridData('GridTemplate', 4, 'colUOM', '50 kg bag')
        .verifyGridData('GridTemplate', 4, 'colRinFeedStockUOMCode', 'Test UOM Code4')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        //endregion


        //region Scenario 5: Fuel Category - Add duplicate Record
        .displayText('===== Scenario 5: Fuel Category - Add duplicate Record =====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridComboBoxRowValue('GridTemplate',4,'strUnitMeasure','LB','strUnitMeasure')
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
        .waitUntilLoaded('icfeedstockuom')
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
        .waitUntilLoaded('icfeedstockuom')
        .selectGridComboBoxRowValue('GridTemplate',4,'strUnitMeasure','50 kg bag','strUnitMeasure')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close') 
        //endregion*/



        .done();

})