StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        /*====================================== Scenario 1: Delete Unused Category ======================================*/
        //region
        .displayText('=====  Scenario 1: Delete Unused Category =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Delete - Category 1')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    //region
                    .displayText('=====  Create Category to Delete =====')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .waitUntilLoaded('')
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

                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
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


        .done();

})