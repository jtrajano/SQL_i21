StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region IROpenSearchScreen
        .displayText('===== Inventory Receipt Open Search Screen =====')
        .displayText('===== Scenario 1: Open New Inventory Receipt Screen from Search Screen =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .displayText('===== Open New IR Screen =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventorytransfer')
        .verifyScreenShown('icinventorytransfer')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 1: Open New Inventory Receipt Screen from Search Screen Done =====')


        .displayText('===== Scenario 2: Open Inventory Receipt Screen from Search Screen Existing Record =====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventorytransfer')
        .verifyScreenShown('icinventorytransfer')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 2: Open Inventory Receipt Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 3: Open Inventory Receipt Screen from Search Screen Existing Record New Button=====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventorytransfer')
        .verifyScreenShown('icinventorytransfer')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventorytransfer')
        .verifyScreenShown('icinventorytransfer')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 3: Open Inventory Receipt Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 4: Check Required Fields Purchase Order Type =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventorytransfer')
        .verifyScreenShown('icinventorytransfer')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 4: Check Required Fields Purchase Order Type =====')
        .displayText('===== Scenario 6: Check Required Fields Transfer Order Type =====')


        //endregion

        .done();


})