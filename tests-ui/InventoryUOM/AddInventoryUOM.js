/**
 * Created by RQuidato on 10/30/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();

engine.start(t)

    /* 1. Open screen and check default control's state*/
    .login('ssiadmin','summit','ag').wait(1500)
    .addFunction(function(next){t.diag("Scenario 1. Add new records > 1. Open screen and check default controls' state"); next();}).wait(100)
    .expandMenu('Inventory').wait(100)
    .expandMenu('Maintenance').wait(200)
    .openScreen('Inventory UOM').wait(200)
    .checkScreenShown ('inventoryuom').wait(100)
    .checkScreenWindow({alias: 'inventoryuom',title: 'Inventory UOM',collapse: true,maximize: true,minimize: false,restore: false,close: true})
    .checkToolbarButton({new: false, save: true, search: false, delete: false, undo: true, close: true})
    .checkControlVisible(['#txtUnitMeasure', '#txtSymbol', '#cboUnitType', '#chkDefault'], true)
    .checkFieldLabel([
        {
            itemId : '#txtUnitMeasure',
            label: 'Unit Measure'
        },
        {
            itemId : '#txtSymbol',
            label: 'Symbol'
        },
        {
            itemId : '#cboUnitType',
            label: 'Unit Type'
        },
        {
            itemId : '#chkDefault',
            label: 'Default'
        }
    ])
    .checkControlVisible(['#btnDeleteConversion', '#txtFilterGrid'], true)
    .checkControlVisible(['#colConversionStockUOM', '#colConversionToStockUOM', '#colConversionFromStockUOM'], true)
    .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
    .checkStatusBar()
    .checkStatusMessage('Ready')
    .checkControlVisible(['#first', '#prev', '#inputItem', '#next', '#last', '#refresh'], true)


    /*2. Add data*/
    .addFunction(function(next){t.diag("2. Add data"); next();}).wait(100)
    .enterData('#txtUnitMeasure','gram').wait(100)
    .enterData('#txtSymbol','g').wait(100)
//    .selectComboRowByFilter('cboUnitType','Weight')
    .clickCheckBox('#chkDefault')
//    .selectGridComboRowByFilter()
    .checkStatusMessage('Edited')
    .clickButton('#btnSave').wait(100)
    .checkStatusMessage('Saved').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('inventoryuom').wait(100)

//        Verify record added
    .openScreen('Inventory UOM').wait(200)
//        search screen name
    .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
    .checkScreenShown ('search').wait(200)
    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
    .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
    .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
    .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
    .checkStatusBar()
    .checkStatusMessage('Ready')
    .selectSearchRowByFilter('gram')
    .clickButton('#btnOpenSelected').wait(100)
    .checkScreenShown ('Inventory UOM').wait(200)
    .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
    .checkControlData('#txtUnitMeasure','gram')
    .checkControlData('#txtSymbol','g')
//    .checkControlData('#cboUnitType','Weight')
    .checkCheckboxValue('#chkDefault',true)
    .checkStatusMessage('Ready')
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('inventoryuom').wait(100)


    /*3. Add another record, Click Close button, do NOT save the changes > New on Search*/
    .addFunction(function(next){t.diag("3. Add another record, Click Close button, do NOT save the changes > New on Search"); next();}).wait(100)
    .expandMenu('Inventory').wait(100)
    .expandMenu('Maintenance').wait(200)
    .openScreen('Inventory UOM').wait(500)
    .checkScreenShown ('search').wait(200)
    .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .clickButton('#btnNew')
    .checkScreenShown ('Inventory UOM').wait(300)
    .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'inventoryuom', title: 'Inventory UOM', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
    .enterData('#txtUnitMeasure','kilogram').wait(100)
    .enterData('#txtSymbol','kg').wait(100)
//    .selectComboRowByFilter('cboUnitType','Weight')
//    .selectGridComboRowByFilter()
    .checkStatusMessage('Edited')
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
    .clickMessageBoxButton('no').wait(10)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('inventoryuom').wait(100)


    /*4. Add another record, click Close, Cancel > New on Search*/
    .addFunction(function(next){t.diag("4. Add another record, click Close, Cancel > New on Search"); next();}).wait(100)
    .expandMenu('Inventory').wait(100)
    .expandMenu('Maintenance').wait(200)
    .openScreen('Manufacturer').wait(500)
    .checkScreenShown ('search').wait(200)
    .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .clickButton('#btnNew')
    .checkScreenShown ('inventoryuom').wait(200)
    .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'inventoryuom', title: 'Inventory UOM', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
    .enterData('#txtUnitMeasure','kilogram').wait(100)
    .enterData('#txtSymbol','kg').wait(100)
//    .selectComboRowByFilter('cboUnitType','Weight')
//    .selectGridComboRowByFilter()
    .checkStatusMessage('Edited')
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
    .clickMessageBoxButton('cancel').wait(10)
    .clickButton('#btnClose').wait(100)
    .clickButton('#btnClose').wait(100)


    /*5. Add another record, Click Close button, SAVE the changes > New on Search */
    .addFunction(function(next){t.diag("5. Add another record, Click Close button, SAVE the changes > New on Search"); next();}).wait(100)
    .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
    .clickMessageBoxButton('yes').wait(500)
    .checkIfScreenClosed('inventoryuom').wait(100) /*issue - FRM-1547*/

//        Verify record added
    .openScreen('Inventory UOM').wait(500)
//        search screen name
    .checkScreenShown ('search').wait(200)
    .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
    .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
//        check columns shown
//        check column headers
    .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName'], true)
    .checkStatusBar()
    .checkStatusMessage('Ready')
    .selectSearchRowByFilter('kilogram')
    .clickButton('#btnOpenSelected').wait(100)
    .checkScreenShown ('Inventory UOM').wait(200)
    .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
    .checkControlData('#txtUnitMeasure','kilogram')
    .checkControlData('#txtSymbol','kg')
    .checkControlData('#cboUnitType','Weight')
    .checkCheckboxValue('#chkDefault',false)
    .checkStatusMessage('Ready')
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('inventoryuom').wait(100)

    /*6. Add duplicate record > New on existing record */
    .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record "); next();}).wait(100)
    .expandMenu('Inventory').wait(100)
    .expandMenu('Maintenance').wait(200)
    .openScreen('Inventory UOM').wait(500)
    .checkScreenShown ('search').wait(200)
    .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .selectSearchRowByFilter('gram')
    .clickButton('#btnOpenSelected').wait(100)
    .checkScreenShown ('inventoryuom').wait(200)
    .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'packtype', title: 'Inventory UOM', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
    .clickButton('#btnNew')
    .checkControlData('#txtUnitMeasure','')
    .checkControlData('#txtSymbol','')
    .checkControlData('#txtSymbol','')
    .checkControlData('#cboUnitType','')
    .checkControlData('#chkDefault',false)
    .enterData('#txtUnitMeasure','kilogram').wait(100)
    .enterData('#txtSymbol','hr').wait(100)
//    .selectComboRowByFilter('cboUnitType','Time')
//    .selectGridComboRowByFilter()
    .checkStatusMessage('Edited')
    .clickButton('#btnSave').wait(100)
    .checkMessageBox('iRely i21','Manufacturer already exists.','ok','error') /* IC-84 */
    .clickMessageBoxButton('ok').wait(10)

//        Modify duplicate record to correct it
    .addFunction(function(next){t.diag("6. Add duplicate record > New on existing record > Modify duplicate record to correct it "); next();}).wait(100)
    .enterData('#txtUnitMeasure','hour').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
    .clickMessageBoxButton('yes').wait(500)
    .checkIfScreenClosed('inventoryuom').wait(100)

    /*7. Add primary key only then SAVE > New from existing record then Search*/
    .addFunction(function(next){t.diag("7. Add primary key only then SAVE > New from existing record then Search"); next();}).wait(100)
    .openScreen('Inventory UOM').wait(500)
    //search screen name
    .checkScreenShown ('search').wait(200)
    .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .selectSearchRowByFilter('gram')
    .clickButton('#btnOpenSelected').wait(100)
    .checkScreenShown ('inventoryuom').wait(200)
    .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'inventoryuom', title: 'Inventory UOM', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkToolbarButton({new: true, save: true, search: true, delete: true, undo: true, close: true})
    .clickButton('#btnSearch')
    .checkScreenShown ('search').wait(200)
    .addFunction(function(next){t.diag("Opens Search screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .clickButton('#btnNew')
    .checkScreenShown ('inventoryuom').wait(200)
    .addFunction(function(next){t.diag("Opens screen"); next();}).wait(100)
    .checkScreenWindow({alias: 'packtype', title: 'Inventory UOM', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkControlData('#txtUnitMeasure','')
    .checkControlData('#txtSymbol','')
    .checkControlData('#txtSymbol','')
    .checkControlData('#cboUnitType','')
    .checkControlData('#chkDefault',false)
    .enterData('#txtUnitMeasure','meter').wait(100)
    .checkStatusMessage('Edited')
    .clickButton('#btnSave').wait(100)
    .checkIfScreenClosed('inventoryuom').wait(100)


    .done()
})