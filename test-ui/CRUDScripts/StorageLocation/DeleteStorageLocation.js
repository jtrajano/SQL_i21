StartTest (function (t) {
    new iRely.FunctionalTest().start(t)


        /*====================================== Scenario 1: Delete Unused Storage Location ======================================*/
        //region
        .displayText('===== Scenario 1: Delete Unused Storage Location. =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Storage Units','Screen')
        .waitUntilLoaded()
        .filterGridRecords('Search', 'FilterGrid', 'Test SL - SH - 010')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .displayText('=====  Scenario 1: Delete Unused Storage Location =====')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','Name','Test SL - SH - 010')
                    .enterData('Text Field','Description','Test SL - SH - 010')
                    .selectComboBoxRowValue('UnitType', 'Bin', 'UnitType',0)
                    .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('ParentUnit', 'RM Storage', 'ParentUnit',0)
                    .enterData('Text Field','Aisle','Test Aisle - 01')
                    .clickCheckBox('AllowConsume', true)
                    .clickCheckBox('AllowMultipleItems', true)
                    .clickCheckBox('AllowMultipleLots', true)
                    .clickCheckBox('CycleCounted', true)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    //endregion

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .clickMenuScreen('Storage Units','Screen')
        .doubleClickSearchRowValue('Test SL - SH - 010', 'strUnitMeasure', 1)
        .waitUntilLoaded('')
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 1: Delete Unused Storage Location done. =====')
        //endregion


        /*====================================== Scenario 2: Delete Used Storage Location ======================================*/
        //region
        .displayText('=====  Scenario 2: Delete Unused Storage Location =====')
        .doubleClickSearchRowValue('RM Storage', 'strUnitMeasure', 1)
        .waitUntilLoaded('')
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','The record you are trying to delete is being used.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .displayText('=====  Scenario 2: Delete Used Storage Location Done=====')
        //endregion


        /*====================================== Scenario 3: Delete Multiple Storage Location ======================================*/
        .displayText('=====  Scenario 3: Delete Multiple Storage Location =====')
        .clickMenuScreen('Storage Units','Screen')
        .waitUntilLoaded()
        .filterGridRecords('Search', 'FilterGrid', 'DELETE SL - SH')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','Name','DELETE SL - SH - 010')
                    .enterData('Text Field','Description','Test SL - SH - 001')
                    .selectComboBoxRowValue('UnitType', 'Bin', 'UnitType',0)
                    .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
                    .selectComboBoxRowValue('ParentUnit', 'RM Storage', 'ParentUnit',0)
                    .enterData('Text Field','Aisle','Test Aisle - 01')
                    .clickCheckBox('AllowConsume', true)
                    .clickCheckBox('AllowMultipleItems', true)
                    .clickCheckBox('AllowMultipleLots', true)
                    .clickCheckBox('CycleCounted', true)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .clickButton('New')
                    .waitUntilLoaded('icstorageunit')
                    .enterData('Text Field','Name','DELETE SL - SH - 002')
                    .enterData('Text Field','Description','Test SL - SH - 001')
                    .selectComboBoxRowValue('UnitType', 'Bin', 'UnitType',0)
                    .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'FG Station', 'SubLocation',0)
                    .selectComboBoxRowValue('ParentUnit', 'RM Storage', 'ParentUnit',0)
                    .enterData('Text Field','Aisle','Test Aisle - 01')
                    .clickCheckBox('AllowConsume', true)
                    .clickCheckBox('AllowMultipleItems', true)
                    .clickCheckBox('AllowMultipleLots', true)
                    .clickCheckBox('CycleCounted', true)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .waitUntilLoaded()
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')

        .displayText('=====  Scenario 3: Delete Multiple Storage Location =====')
        .filterGridRecords('Search', 'FilterGrid', 'DELETE SL - SH')
        .selectSearchRowNumber([1,2])
        .clickButton('OpenSelected')
        .waitUntilLoaded('icstorageunit')
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .displayText('=====  Delete Multiple Storage Location Done =====')
        //endregion

        .done();

})