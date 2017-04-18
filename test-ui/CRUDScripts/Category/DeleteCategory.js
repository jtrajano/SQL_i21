StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Delete Unused Category
        .displayText('=====  Scenario 1: Delete Unused Category =====')
        .displayText('=====  Create Category to Delete =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Delete - Category 1')
        .enterData('Text Field','Description','Test Inventory Category')
        .selectComboBoxRowNumber('InventoryType',2,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')
        .clickButton('Save')
        .clickButton('Close')

        .doubleClickSearchRowValue('Delete - Category 1', 1)
        .waitUntilLoaded('iccategory')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clearTextFilter('FilterGrid')
        .displayText('=====  Scenario 1: Delete Unused Category Done=====')
        //endregion

        //region Scenario 2: Delete Used Category
        .displayText('=====  Scenario 2: Delete Used Category =====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded('iccategory')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .verifyMessageBox('iRely i21','The record you are trying to delete is being used.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clearTextFilter('FilterGrid')
        .displayText('=====  Scenario 2: Delete Used Category Done=====')
        //endregion

        //region Scenario 3: Delete Multiple UnUsed Category
        .displayText('=====  Scenario 3: Delete Multiple UnUsed Category =====')
        .selectSearchRowNumber([78,79,80,81,82,83,84])
        .clickButton('OpenSelected')
        .waitUntilLoaded('iccategory')
        .waitUntilLoaded()
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .displayText('=====  Scenario 3: Delete Multiple UnUsed Category Done=====')
        //endregion




        .done();

})