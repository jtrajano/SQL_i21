/**
 * Created by CCallado
 */
StartTest (function (t) {

    var engine = new iRely.TestEngine();

engine.start(t)

    /* 1. Open screen Inventory UOM Screen>New and check default control's state*/
    .login('irelyadmin','i21by2015','01').wait(1500)
    .addFunction(function(next){t.diag("Scenario 1. Open screen and check default controls' state"); next();}).wait(100)
    .expandMenu('Inventory').wait(100)
    .openScreen('Inventory UOM').wait(200)
    .checkScreenShown ('icinventoryuom').wait(100)
    .checkScreenWindow({alias: 'icinvetoryuom',title: 'Inventory UOMs',collapse: true,maximize: true,minimize: false,restore: false,close: true}).wait(1000)
    .checkSearchToolbarButton({new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: true})
    //checkGridColumns not working in 15.3.
   /* .checkGridColumns('#grdGridTemplate', [
        {
            dataIndex: 'strUOMName',
            text: 'UOM Name'
        },

        {
            dataIndex: 'strSymbol',
            text: 'Symbol'
        },

        {
            dataIndex: 'strUnitType',
            text: 'Unit Type'
        }

    ])*/
    .clickButton('#btnNew').wait(100)
    .checkScreenShown('icinventoryuom').wait(100)
    .checkScreenWindow({ alias: 'icinventoryuom', title: 'Inventory UOM -', collapse: true, maximize: true, minimize: false, restore: false, close: true })
    .checkToolbarButton({ new: true, save: true, search: true, delete: true, undo: true, close: true })
    .checkControlVisible(['#txtUnitMeasure', '#txtSymbol', '#cboUnitType'], true)
    .checkFieldLabel([
        {
            itemId: '#txtUnitMeasure',
            label: 'Unit Measure'
        },
        {
            itemId: '#txtSymbol',
            label: 'Symbol'
        },
        {
            itemId: '#cboUnitType',
            label: 'Unit Type'
        }

    ])

    .checkControlVisible(['#btnInsertConversion','#btnDeleteConversion', '#btnGridLayout', '#btnInsertCriteria', '#txtFilterGrid'], true)
    .checkControlVisible(['#colConversionStockUOM', '#colConversionToStockUOM'], true)
    .checkControlVisible(['#btnHelp', '#btnSupport', '#btnFieldName', '#btnEmailUrl'], true)
    .checkStatusMessage('Ready')
    .clickButton('#btnClose')


    /* 2. Add stock UOM first*/
    .openScreen('Inventory UOM').wait(200)
    .addFunction(function(next){t.diag("Scenario 2.>1. Add stock UOM"); next();}).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure','Pound_1')
    .enterData('#txtSymbol','Lb_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .checkStatusMessage('Edited')
    .clickButton('#btnSave').wait(100)
    .addFunction(function(next){t.diag("Verify Record Added"); next();}).wait(100)
    .clickButton('#btnSearch').wait(1000)
    .checkGridData('#grdSearch', 12, 'strUnitMeasure', 'Pound_1').wait(100)
    .checkGridData('#grdSearch', 12, 'strUnitType', 'Lb_1').wait(100)
    .clickButton('#btnClose').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('icinventoryuom').wait(100)

    /* 3. Add conversion UOMs on each stock UOM*/
    .addFunction(function(next){t.diag("Scenario 3.>1. Add Conversion UOM> 5 Lb Bag"); next();}).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure','5 Lb Bag_1')
    .enterData('#txtSymbol','5 Lb Bag_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .selectGridComboRowByFilter('#grdConversion', 0,'strUnitMeasure','Pound_1', 1000).wait(100)
    .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '5').wait(500)
    .selectGridComboRowByFilter('#grdConversion', 1,'strUnitMeasure','Kilogram', 1000).wait(100)
    .enterGridData('#grdConversion', 1, 'colConversionToStockUOM', '2.26796').wait(500)
    .clickButton('#btnSave').wait(100)
    .addFunction(function(next){t.diag("Verify Record Added"); next();}).wait(100)
    .clickButton('#btnSearch').wait(1000)
    .checkGridData('#grdSearch', 13, 'strUnitMeasure', '5 Lb Bag_1').wait(100)
    .checkGridData('#grdSearch', 13, 'strUnitType', '5 Lb Bag_1').wait(100)
    .clickButton('#btnClose').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('icinventoryuom').wait(100)


    .addFunction(function(next){t.diag("Scenario 3.>2. Add Conversion UOM> 50 Lb Bag"); next();}).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure','50 Lb Bag_1')
    .enterData('#txtSymbol','50 Lb Bag_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .selectGridComboRowByFilter('#grdConversion', 0,'strUnitMeasure','Pound_1', 1000).wait(100)
    .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '50').wait(500)
    .clickButton('#btnSave').wait(100)
    .addFunction(function(next){t.diag("Verify Record Added"); next();}).wait(100)
    .clickButton('#btnSearch').wait(1000)
    .checkGridData('#grdSearch', 13, 'strUnitMeasure', '50 Lb Bag_1').wait(100)
    .checkGridData('#grdSearch', 13, 'strUnitType', '50 Lb Bag_1').wait(100)
    .clickButton('#btnClose').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('icinventoryuom').wait(100)

    /*4. Add another record, Click Close button Cancel - No, do NOT save the changes > New on Search*/
    .addFunction(function(next){t.diag("4. Add another record, Click Close button, do NOT save the changes"); next();}).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure','70 Lb Bag_1')
    .enterData('#txtSymbol','70 Lb Bag_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .selectGridComboRowByFilter('#grdConversion', 0,'strUnitMeasure','Pound_1', 1000).wait(100)
    .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '70').wait(500)
    .checkStatusMessage('Edited')
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
    .clickMessageBoxButton('cancel').wait(10)
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
    .clickMessageBoxButton('no').wait(10)
    .checkIfScreenClosed('icinventoryuom').wait(100)
    .checkGridRecordCount('#grdSearch', 15)

    /*5. Add another record, Click Close button, SAVE the changes > New on Search */
    .addFunction(function(next){t.diag("4. Add another record, Click Close button, do NOT save the changes"); next();}).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure','70 Lb Bag_1')
    .enterData('#txtSymbol','70 Lb Bag_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .selectGridComboRowByFilter('#grdConversion', 0,'strUnitMeasure','Pound_1', 1000).wait(100)
    .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '70').wait(500)
    .checkStatusMessage('Edited')
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
    .clickMessageBoxButton('yes').wait(10)
    .checkIfScreenClosed('icinventoryuom').wait(100)
    .checkGridData('#grdSearch', 15, 'strUnitMeasure', '70 Lb Bag_1').wait(100)
    .checkGridData('#grdSearch', 15, 'strUnitType', '70').wait(100)


    /*6. Add duplicate record > New on existing record
    .addFunction(function (next) { t.diag("6. Add duplicate record > New on existing record "); next(); }).wait(100)
    .clickButton('#btnNew')
    .enterData('#txtUnitMeasure','Pound_1')
    .enterData('#txtSymbol','Lb_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .checkStatusMessage('Edited')
    .clickButton('#btnSave').wait(100)
    .checkMessageBox('iRely i21', 'Inventory UOM already exists.', 'ok', 'error')
    .clickMessageBoxButton('ok').wait(10)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('icinventoryuom').wait(100)*//* exluded because of this issue -> IC-1557 */


    /*7. Add primary key only then SAVE > New from existing record then Search*/
    .addFunction(function (next) { t.diag("7. Add primary key only then SAVE > New from existing record then Search"); next(); }).wait(100)
    .clickButton('#btnNew')
    .enterData('#txtUnitMeasure','Pound_2')
    .clickButton('#btnSave')
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
    .clickMessageBoxButton('no').wait(100)
    .checkIfScreenClosed('icinventoryuom').wait(100)
    .addFunction(function (next) { t.diag("Check if data was not saved"); next(); }).wait(100)
    .checkGridRecordCount('#grdSearch', 16)


    /*Add conversion UOMs on each stock UOM - Issue on filter box 15.3, will do this in 15.4
    .selectGridRow('#grdSearch', [12]).wait(1000)
    .clickButton('#btnOpenSelected').wait(500)
    //.selectGridComboRowByFilter('#grdConversion', 0,'strUnitMeasure','5 Lb Bag_1', 1000).wait(100)
    .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '0.2').wait(500)
   // .selectGridComboRowByFilter('#grdConversion', 1,'strUnitMeasure','50 Lb Bag_1', 1000).wait(100)
    .enterGridData('#grdConversion', 1, 'colConversionToStockUOM', '0.02').wait(500)
   // .selectGridComboRowByFilter('#grdAppliances', 2, 'strApplianceType', 'H HOTTUB', 1000).wait(500)*/

    .done()

})