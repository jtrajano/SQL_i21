StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Delete Unused Feed Stock UOM
        .displayText('===== NOTE!!! You can only execute this script when you finish executing Add Fuel Category up to Add Fuel type Script =====')
        .displayText('=====  Scenario 1: Delete Unused Feed Stock UOM =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded()

        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 1: Delete Unused Feed Stock UOM Done=====')
        //endregion

        //region Scenario 2: Delete Used Feed Stock UOM
        .displayText('=====  Scenario 2: Delete Used Feed Stock UOM =====')

        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridRowNumber('GridTemplate',[2])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','The record you are trying to delete is being used.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 2: Delete Used Feed Stock UOM Done=====')
        //endregion

        //region Scenario 3: Delete Multiple Feed Stock UOM
        .displayText('=====  Scenario 3: Delete Multiple Feed Stock UOM =====')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridRowNumber('GridTemplate',[1,3])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 3 rows.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('=====  Scenario 3: Delete Multiple Feed Stock UOM Done=====')
        //endregion





        .done();

})