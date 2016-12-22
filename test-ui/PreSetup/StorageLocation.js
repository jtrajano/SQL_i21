StartTest (function (t) {
    var commonIC = Ext.create('i21.test.Inventory.CommonIC');
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


        .done();

})