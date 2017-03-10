StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region IROpenSearchScreen
        .displayText('===== Inventory Receipt Open Search Screen =====')
        .displayText('===== Scenario 1: Open New Inventory Receipt Screen from Search Screen =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .displayText('===== Open New IR Screen =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .verifyScreenShown('icinventoryreceipt')
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
        .waitUntilLoaded('icinventoryreceipt')
        .verifyScreenShown('icinventoryreceipt')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 2: Open Inventory Receipt Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 3: Open Inventory Receipt Screen from Search Screen Existing Record New Button=====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .verifyScreenShown('icinventoryreceipt')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .verifyScreenShown('icinventoryreceipt')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 3: Open Inventory Receipt Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 4: Check Required Fields Purchase Order Type =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .verifyScreenShown('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',2,0)
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 4: Check Required Fields Purchase Order Type =====')


        .displayText('===== Scenario 5: Check Required Fields Direct Type =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .verifyScreenShown('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 5: Check Required Fields Direct Type =====')


        .displayText('===== Scenario 6: Check Required Fields Transfer Order Type =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .verifyScreenShown('icinventoryreceipt')
        .selectComboBoxRowNumber('ReceiptType',3,0)
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 6: Check Required Fields Transfer Order Type =====')


        //endregion

         .done();


})