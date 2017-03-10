StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add New Storage Location
        .displayText('===== Scenario 1: Add New Storage Location. =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Locations','Screen')
        .clickButton('New')
        .waitUntilLoaded('icstorageunit')
        .enterData('Text Field','Name','Indy Storage')
        .enterData('Text Field','Description','Indy Storage')
        .selectComboBoxRowNumber('UnitType',6,0)
        .selectComboBoxRowNumber('Location',2,0)
        .selectComboBoxRowNumber('SubLocation',1,0)
        .selectComboBoxRowNumber('ParentUnit',1,0)
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







        .done();

})