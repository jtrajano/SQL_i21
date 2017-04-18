StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Delete Unused Storage Location
        .displayText('=====  Scenario 1: Delete Unused Storage Location =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Locations','Screen')
        .doubleClickSearchRowValue('Test SL - SH - 001', 'strUnitMeasure', 1)
        .waitUntilLoaded('icstorageunit')
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .displayText('=====  Scenario 1: Delete Unused Storage Location Done=====')
        //endregion

        //region Scenario 2: Delete Used Storage Location
        .displayText('=====  Scenario 2: Delete Unused Storage Location =====')
        .doubleClickSearchRowValue('RM Storage', 'strUnitMeasure', 1)
        .waitUntilLoaded('icstorageunit')
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

        //region Scenario 3: Delete Multiple Storage Location
        .displayText('=====  Scenario 3: Delete Multiple Storage Location =====')
        .selectSearchRowNumber([72,73])
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
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Delete Multiple Storage Location Done =====')
        //endregion

        .done();

})