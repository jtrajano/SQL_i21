StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region IROpenSearchScreen
        .displayText('===== Inventory Receipt Open Search Screen =====')
        .displayText('===== Scenario 1: Open from Inventory Menu =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .addResult('Successfully Opened Screen',3000)
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
            { dataIndex: 'dtmReceiptDate', text: 'Receipt Date'},
            { dataIndex: 'strReceiptType', text: 'Order Type'},
            { dataIndex: 'strVendorName', text: 'Vendor Name'},
            { dataIndex: 'strLocationName', text: 'Location Name'},
            { dataIndex: 'strBillOfLading', text: 'Bill Of Lading No'},
            { dataIndex: 'ysnPosted', text: 'Posted'}
        ])
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 1 Done =====')


        .displayText('===== Scenario 2: Open Inventory Search Screen from Existing Record  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .clickButton('Search')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 2 Done  =====')


        .displayText('===== Scenario 3: Check IR Search Screen Toolbar Buttons =====')
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

        .displayText('===== Open Existing Record =====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icinventoryreceipt')
        .verifyScreenShown('icinventoryreceipt')
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

        .displayText('===== Check Toolbar Button "Vendor" =====')
        .clickButton('Vendor')
        .waitUntilLoaded()
        .waitUntilLoaded('emcreatenewentity')
        .verifyScreenShown('emcreatenewentity')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 3 Done  =====')


        .displayText('===== Scenario 4: Open Search Tabs =====')
        .clickTab('Details')
        .waitUntilLoaded()
        .addResult('Successfully Opened Screen',3000)
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
            { dataIndex: 'strReceiptType', text: 'Order Type'},
            { dataIndex: 'ysnPosted', text: 'Posted'},
            { dataIndex: 'strShipFrom', text: 'Ship From'}

        ])
        .clickTab('Charges')
        .waitUntilLoaded()
        .addResult('Successfully Opened Screen',3000)
        .waitUntilLoaded()

        .clickTab('Lots')
        .waitUntilLoaded()
        .addResult('Successfully Opened Screen',3000)
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
            { dataIndex: 'strReceiptType', text: 'Order Type'}

        ])
        .clickTab('Vouchers')
        .waitUntilLoaded()
        .addResult('Successfully Opened Screen',3000)
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false})
        .verifyGridColumnNames('Search', [
            { dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string' },
            { dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
            { dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string' }
        ])
        .displayText('===== Scenario 4: Open Search Tabs Done =====')

        .displayText('===== Inventory Receipt Open Search Screen Done =====')
        //endregion



        .done();

})