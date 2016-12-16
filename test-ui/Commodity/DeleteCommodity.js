StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Delete Unused Commodity
        .displayText('=====  Scenario 1: Delete Unused Commodity =====')
        .displayText('=====  Create Commodity to Delete =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','CommodityCode','Delete - Commodity 1')
        .enterData('Text Field','Description','Commodity with No UOM and Attribute')
        .clickCheckBox('ExchangeTraded',true)
        .enterData('Text Field','DecimalsOnDpr','6.00')
        .enterData('Text Field','ConsolidateFactor','6.00')
        .clickButton('Save')
        .clickButton('Close')

        .doubleClickSearchRowValue('Delete - Commodity 1', 1)
        .waitUntilLoaded('iccommodity')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno','question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clearTextFilter('FilterGrid')
        .displayText('=====  Scenario 1: Delete Unused Commodity Done=====')
        //endregion

        //region Scenario 2: Delete Used Commodity
        .displayText('=====  Scenario 2: Delete Used Commodity =====')
        .doubleClickSearchRowValue('Corn', 1)
        .waitUntilLoaded('iccommodity')
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
        .displayText('=====  Scenario 2: Delete Used Commodity Done=====')
        //endregion



        .done();

})