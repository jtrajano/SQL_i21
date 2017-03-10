StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region IROpenSearchScreen
        .displayText('===== Inventory Receipt Open Search Screen =====')
        .displayText('===== Scenario 1: Open from Inventory Menu =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .addResult('Successfully Opened Screen',3000)
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strTransferNo', text: 'Transfer No'},
            {dataIndex: 'dtmTransferDate', text: 'Transfer Date'},
            {dataIndex: 'strTransferType', text: 'Transfer Type'},
            {dataIndex: 'strDescription', text: 'Description'},
            {dataIndex: 'strFromLocation', text: 'From Location'},
            {dataIndex: 'strToLocation', text: 'To Location'},
            {dataIndex: 'strStatus', text: 'Status'},
            {dataIndex: 'ysnPosted', text: 'Posted'}
        ])
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 1 Done =====')


        .displayText('===== Scenario 2: Open Inventory Search Screen from Existing Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Transfers','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .clickButton('Search')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 2 Done  =====')


        .displayText('===== Scenario 3: Check IR Search Screen Toolbar Buttons =====')
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

        .displayText('===== Open Existing Record =====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventorytransfer')
        .verifyScreenShown('icinventorytransfer')
        .clickButton('Close')
        .waitUntilLoaded()

        .displayText('===== Check Toolbar Button "Item" =====')
        .clickButton('Item')
        .waitUntilLoaded()
        .waitUntilLoaded('icitem')
        .verifyScreenShown('icitem')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()

        .displayText('===== Check Toolbar Button "Category" =====')
        .clickButton('Category')
        .waitUntilLoaded()
        .waitUntilLoaded('iccategory')
        .verifyScreenShown('iccategory')
        .clickButton('Close')
        .waitUntilLoaded()

        .displayText('===== Check Toolbar Button "Commodity" =====')
        .clickButton('Commodity')
        .waitUntilLoaded()
        .waitUntilLoaded('iccommodity')
        .verifyScreenShown('iccommodity')
        .clickButton('Close')
        .waitUntilLoaded()

        .displayText('===== Check Toolbar Button "Location" =====')
        .clickButton('Location')
        .waitUntilLoaded()
        .waitUntilLoaded('smcompanylocation')
        .verifyScreenShown('smcompanylocation')
        .clickButton('Close')
        .waitUntilLoaded()

        .displayText('===== Check Toolbar Button "Storage Location" =====')
        .clickButton('StorageLocation')
        .waitUntilLoaded()
        .waitUntilLoaded('icstorageunit')
        .verifyScreenShown('icstorageunit')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 3 Done  =====')


        .displayText('===== Scenario 4: Open Search Tabs =====')
        .clickTab('Details')
        .waitUntilLoaded()
        .addResult('Successfully Opened Screen',3000)
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})

        .clickTab('Inventory Transfer')
        .waitUntilLoaded()
        .addResult('Successfully Opened Screen',3000)
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .displayText('===== Scenario 4: Open Search Tabs Done =====')
        .displayText('===== Inventory Receipt Open Search Screen Done =====')
        //endregion



        .done();

})