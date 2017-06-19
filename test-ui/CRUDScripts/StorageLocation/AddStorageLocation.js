StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        /*====================================== Scenario 1: Add New Storage Location - Allow bin of the same name to be used in a different Sub Location. ======================================*/
        //region
        .displayText('===== Scenario 1: Add New Storage Location - Allow bin of the same name to be used in a different Sub Location. =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Storage Units','Screen')
        .waitUntilLoaded()
        .filterGridRecords('Search', 'FilterGrid', 'Test SL - SH - 001')
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
                    .enterData('Text Field','Name','Test SL - SH - 001')
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
                    .enterData('Text Field','Name','Test SL - SH - 001')
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
        .displayText('===== Add New Storage Location - Allow bin of the same name to be used in a different Sub Location Done=====')
        //endregion

        /*====================================== Scenario 2: Add New Storage Location - Allow bin of the same name to be used in a different Sub Location ======================================*/
        //region
        .displayText('===== Scenario 2: Add New Storage Location - Allow bin of the same name to be used in a different Sub Location. =====')
        .filterGridRecords('Search', 'FilterGrid', 'Test SL - SH - 002')
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
                    .enterData('Text Field','Name','Test SL - SH - 002')
                    .enterData('Text Field','Description','Test SL - SH - 002')
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
                    .enterData('Text Field','Name','Test SL - SH - 002')
                    .enterData('Text Field','Description','Test SL - SH - 002')
                    .selectComboBoxRowValue('UnitType', 'Bin', 'UnitType',0)
                    .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
                    .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
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
                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Add New Storage Location - Allow bin of the same name to be used in a different Sub Location Done=====')
        //endregion


        /*====================================== Scenario 3: Update Storage Location ======================================*/
        //region
        .displayText('===== Scenario 3: Update Storage Location =====')
        .doubleClickSearchRowValue('Test SL - SH - 001', 'strUnitMeasure', 1)
        .waitUntilLoaded('icstorageunit')
        .enterData('Text Field','Description','Test SL - SH Updated')
        .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
        .enterData('Text Field','Aisle','Test Aisle - Updated')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icstorageunit')
        .verifyData('Text Field','Description','Test SL - SH Updated')
        .verifyData('Combo Box','Location','0002 - Indianapolis')
        .verifyData('Combo Box','SubLocation','Indy')
        .verifyData('Text Field','Aisle','Test Aisle - Updated')
        .clickButton('Close')
        .clearTextFilter('FilterGrid')
        //endregion


        /*====================================== Scenario 4: Add Duplicate Storage Location ======================================*/
        //region
        .displayText('===== Scenario 4: Add Duplicate Storage Location =====')
        .clickButton('New')
        .waitUntilLoaded('icstorageunit')
        .enterData('Text Field','Name','Test SL - SH - 002')
        .enterData('Text Field','Description','Test SL - SH - 002')
        .selectComboBoxRowValue('UnitType', 'Bin', 'UnitType',0)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('ParentUnit', 'RM Storage', 'ParentUnit',0)
        .enterData('Text Field','Aisle','Test Aisle - 01')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyMessageBox('iRely i21','Storage Location must be unique per Location and Sub Location.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded('')
        //endregion

        /*====================================== Scenario 5: Check Required Fields ======================================*/
        //region
        .displayText('===== Scenario 5: Check Required Fields =====')
        .clickButton('New')
        .waitUntilLoaded('icstorageunit')
        .clickButton('Save')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        //endregion


        .done();

})