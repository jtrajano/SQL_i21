StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add New Storage Location - Allow bin of the same name to be used in a different Sub Location.
        .displayText('===== Scenario 1: Add New Storage Location - Allow bin of the same name to be used in a different Sub Location. =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Locations','Screen')
        .clickButton('New')
        .waitTillLoaded('icstorageunit','')
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
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .clickButton('New')
        .waitTillLoaded('icstorageunit','')
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
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 2: Add New Storage Location - Allow bin of the same name to be used in a different Sub Location.
        .displayText('===== Scenario 2: Add New Storage Location - Allow bin of the same name to be used in a different Sub Location. =====')
        .clickButton('New')
        .waitTillLoaded('icstorageunit','')
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
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .clickButton('New')
        .waitTillLoaded('icstorageunit','')
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
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 3: Update Storage Location
        .displayText('===== Scenario 3: Update Storage Location =====')
        .doubleClickSearchRowValue('Test SL - SH - 001', 'strUnitMeasure', 1)
        .waitTillLoaded('icstorageunit','')
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
        .waitTillLoaded('icstorageunit','')
        .verifyData('Text Field','Description','Test SL - SH Updated')
        .verifyData('Combo Box','Location','0002 - Indianapolis')
        .verifyData('Combo Box','SubLocation','Indy')
        .verifyData('Text Field','Aisle','Test Aisle - Updated')
        .clickButton('Close')
        .clearTextFilter('FilterGrid')
        //endregion


        //region Scenario 4: Add Duplicate Storage Location
        .displayText('===== Scenario 4: Add Duplicate Storage Location =====')
        .clickButton('New')
        .waitTillLoaded('icstorageunit','')
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
        .waitTillLoaded('')
        //endregion


        //region Scenario 5: Check Required Fields
        .displayText('===== Scenario 5: Check Required Fields =====')
        .clickButton('New')
        .waitTillLoaded('icstorageunit','')
        .clickButton('Save')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        //endregion


        .done();

})