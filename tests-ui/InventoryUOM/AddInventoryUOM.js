/**
 * Created by RQuidato on 10/30/14.
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();

engine.start(t)

    /*Scenario 1. Add new records */
    /* 1. Open screen and check default controls' state */
    .login('ssiadmin','summit','eo').wait(1500)
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


    /* 2. Data entry */
    .addFunction(function(next){t.diag("Scenario 1. Add new records > 2. Data entry"); next();}).wait(100)
    .enterData('#txtUnitMeasure','gram').wait(100)
    .enterData('#txtSymbol','g').wait(100)
//    .selectComboRowByFilter('cboUnitType','Weight')
    .clickCheckBox('#chkDefault')
    .checkStatusMessage('Edited')
    .clickButton('#btnSave').wait(100)
    .checkStatusMessage('Saved').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('inventoryuom').wait(100)

    /* 3. Verify record added*/
    .addFunction(function(next){t.diag("Scenario 1. Add new records > 3. Verify records added"); next();}).wait(100)
    .openScreen('Inventory UOM').wait(200)
    .addFunction(function(next){t.diag("Scenario 1. Add new records > 3.a Check Search screen "); next();}).wait(100)
    .checkScreenShown ('search').wait(200)
    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
    .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
//        no checking if correct icon is used
//        no checking if button label is correct
    .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
    .selectSearchRowByFilter('gram')
    .clickButton('#btnOpenSelected').wait(100)
    .addFunction(function(next){t.diag("3.a Opens selected record = Passed"); next();}).wait(100)
    .checkControlData('#txtUnitMeasure','gram')
    .checkControlData('#txtSymbol','g')
//    .checkControlData('#cboUnitType','Weight')
    .checkCheckboxValue('#chkDefault',true)
    .checkStatusMessage('Ready')
    .addFunction(function(next){t.diag("3.b Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('inventoryuom').wait(100)

//
//    /* Scenario 2. Add another record, click Close button, do NOT save the changes */
//    /* 1. Data entry. */
//    .addFunction(function(next){t.diag("Scenario 2. Add another record, click Close button, do NOT save the changes"); next();}).wait(100)
//    .openScreen('Inventory UOM').wait(200)
//    .checkScreenShown ('search').wait(200)
//    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
//    .clickButton('#btnNew').wait(100)
//    .enterData('#txtUnitMeasure','hour').wait(100)
//    .enterData('#txtSymbol','hr').wait(100)
//    //        .selectComboRowByIndex('cboUnitType',5)
//    .clickButton('#btnClose').wait(100)
//    .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//    .clickMessageBoxButton('no').wait(10)
//    .clickButton('#btnClose').wait(100)
//    .checkIfScreenClosed('inventoryuom').wait(100)
//
//
//    /* Scenario 3. Add another record, click Close button, Cancel*/
//    /* 1. Data entry. */
//    .addFunction(function(next){t.diag("Scenario 3. Add another record, click Close button, Cancel"); next();}).wait(100)
//    .openScreen('Inventory UOM').wait(200)
//    .checkScreenShown ('search').wait(200)
//    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
//    .clickButton('#btnNew').wait(100)
//    .enterData('#txtUnitMeasure','hour').wait(100)
//    .enterData('#txtSymbol','hr').wait(100)
//    //        .selectComboRowByIndex('cboUnitType',5)
//    .clickButton('#btnClose').wait(100)
//    .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//    .clickMessageBoxButton('cancel').wait(10)
//    .clickButton('#btnClose').wait(100)
//
//
//    /* Scenario 4. Add another record, click Close button, SAVE the changes*/
//    .addFunction(function(next){t.diag("Scenario 4. Add another record, click Close button, SAVE the changes"); next();}).wait(100)
//    .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question')
//    .clickMessageBoxButton('yes').wait(500)
//    .checkIfScreenClosed('inventoryuom').wait(100) /*issue - FRM-1547 or TS-445 or FRM-1560*/
//
//    /* 2. Verify record added*/
//    .addFunction(function(next){t.diag("Scenario 4. Add another record, SAVE the changes > 2. Verify record added"); next();}).wait(100)
//    .openScreen('Inventory UOM').wait(200)
//    .addFunction(function(next){t.diag("Scenario 4. Add new records > 3.a Check Search screen "); next();}).wait(100)
//    .checkScreenShown ('search').wait(200)
//    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
//    .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
//    .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
////        no checking if correct icon is used
////        no checking if button label is correct
//    .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
//    .selectSearchRowByFilter('hour')
//    .clickButton('#btnOpenSelected').wait(100)
//    .addFunction(function(next){t.diag("3.a Opens selected record = Passed"); next();}).wait(100)
//    .checkControlData('#txtUnitMeasure','hour')
//    .checkControlData('#txtSymbol','hr')
//    .checkCheckboxValue('#chkDefault',false)
////         need to add select combo box
//    .checkStatusMessage('Ready')
//    .addFunction(function(next){t.diag("3.b Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
//    .clickButton('#btnClose').wait(100)
//    .checkIfScreenClosed('inventoryuom').wait(100)
//
//
//    /*Scenario 5. Add duplicate record */
//    .addFunction(function(next){t.diag("Scenario 5. Add duplicate record "); next();}).wait(100)
//    .openScreen('Inventory UOM').wait(200)
//    .checkScreenShown ('search').wait(200)
//    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
//    .clickButton('#btnNew').wait(100)
//    .enterData('#txtUnitMeasure','hour').wait(100)
//    .enterData('#txtSymbol','doz').wait(100)
//    //        .selectComboRowByIndex('cboUnitType',5)
//    .clickButton('#btnSave').wait(100)
//    .clickButton('#btnClose').wait(100)
//    .checkMessageBox('iRely i21','Inventory UOM already exists.','ok','error') /*issue - IC-84 */
//    .clickMessageBoxButton('ok').wait(10)
//
//    /*Scenario 6. Modify duplicate record to correct it*/
//    .addFunction(function(next){t.diag("Scenario 6. Modify duplicate record to correct it"); next();}).wait(100)
//    .enterData('#txtUnitMeasure','dozen').wait(100)
//    .clickButton('#btnClose').wait(100)
//    .checkMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel', 'question').wait(100)
//    .clickMessageBoxButton('yes').wait(10)
//    .checkIfScreenClosed('inventoryuom').wait(100)
//
//
//
//    /* 2. Verify record added*/
//    .addFunction(function(next){t.diag("Scenario 6. Modify duplicate record to correct it > 2. Verify record added"); next();}).wait(100)
//    .openScreen('Inventory UOM').wait(200)
//    .addFunction(function(next){t.diag("6.a Check Search screen "); next();}).wait(100)
//    .checkScreenShown ('search').wait(200)
//    .checkScreenWindow({alias: 'search', title: 'Search Inventory UOMs', collapse: true, maximize: true, minimize: false, restore: false, close: true })
//    .checkToolbarButton({new: true, save: false, search: false, delete: false, undo: false, close: true})
//    .checkControlVisible(['#btnOpenSelected', '#btnRefresh'], true)
////        no checking if correct icon is used
////        no checking if button label is correct
//    .checkControlVisible(['#btnInsertCriteria', '#txtFilterGrid','#lblTotalRecords'],true)
//    .selectSearchRowByFilter('dozen')
//    .clickButton('#btnOpenSelected').wait(100)
//    .addFunction(function(next){t.diag("6.b Opens selected record = Passed"); next();}).wait(100)
//    .checkControlData('#txtUnitMeasure','dozen')
//    .checkControlData('#txtSymbol','doz')
//    .checkCheckboxValue('#chkDefault',false)
////         need to add select combo box
//    .checkStatusMessage('Ready')
//    .addFunction(function(next){t.diag("6.c Correct record is selected and data entered is intact = Passed"); next();}).wait(100)
//    .checkIfScreenClosed('fuelcode').wait(100)
//
////        .enterDummyRowData('#grdFuelCategory', [{ column: 'strRinFuelTypeCode', data: '10Et'}, {column: 'strDescription', data: '10-Ethanol'}]) /*issue - FRM-1535 or TS-446 or FRM-1559*/
//
////        /*Scenario 7. Add records > Fuel Code */
////        .addFunction(function(next){t.diag("Scenario 7. Add records "); next();}).wait(100)
////        .openScreen('Fuel Code').wait(200)
////        .checkScreenShown ('fuelcode').wait(100)
////        .enterGridData('#grdGridTemplate', 4, 'colRinFuelCode', 'f05').wait(100)
////        .enterGridData('#grdGridTemplate', 4, 'colDescription', 'fuel 05').wait(100)
////        .enterGridData('#grdGridTemplate', 5, 'colRinFuelCode', 'f06').wait(100)
////        .enterGridData('#grdGridTemplate', 5, 'colDescription', 'fuel 06').wait(100)
////        .enterGridData('#grdGridTemplate', 6, 'colRinFuelCode', 'f07').wait(100)
////        .enterGridData('#grdGridTemplate', 6, 'colDescription', 'fuel 07').wait(100)
////        .clickButton('#btnSave').wait(100)
////        .checkStatusMessage('Edited')
////        .clickButton('#btnClose').wait(100)
////        .checkIfScreenClosed('fuelcode').wait(100)

    .done()
})