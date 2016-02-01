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
    .checkScreenWindow({alias: 'icinvetoryuom',title: 'Inventory UOMs',collapse: true,maximize: true,minimize: false,restore: false,close: true}).wait(1000)
    .checkSearchToolbarButton({new: true, view: true, openselected: false, openall: false, refresh: true, export: true, close: true})

    .clickButton('#btnNew').wait(100)
    .checkScreenShown('icinventoryuom').wait(100)
    .checkToolbarButton({ new: true, save: true, search: true,refresh: false, delete: true, undo: true, close: true })
    .checkControlVisible(['#txtUnitMeasure', '#txtSymbol', '#cboUnitType'], true)
    .checkFieldLabel([
        {
            itemId: '#strUnitMeasure',
            label: 'Unit Measure'
        },
        {
            itemId: '#strSymbol',
            label: 'Symbol'
        },
        {
            itemId: '#strUnitType',
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
    .addFunction(function (next) { t.diag("Scenario 2.>1. Add stock UOM"); next(); }).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure', 'Pound_1')
    .enterData('#txtSymbol', 'Lb_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .checkStatusMessage('Edited')
    .clickButton('#btnSave').wait(100)
    .addFunction(function (next) { t.diag("Verify Record Added"); next(); }).wait(100)
    .clickButton('#btnSearch').wait(1000)
    .checkGridData('#grdSearch', 15, 'strUnitMeasure', 'Pound_1').wait(100)
    .checkGridData('#grdSearch', 15, 'strSymbol', 'Lb_1').wait(100)
    .clickButton('#btnClose').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('icinventoryuom').wait(100)

    /* 3. Add conversion UOMs on each stock UOM*/
    .addFunction(function (next) { t.diag("Scenario 3.>1. Add Conversion UOM> 5 Lb Bag"); next(); }).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure', '5 Lb Bag_1')
    .enterData('#txtSymbol', '5 Lb Bag_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
    .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '5').wait(500)
    .clickButton('#btnSave').wait(100)
    .addFunction(function (next) { t.diag("Verify Record Added"); next(); }).wait(100)
    .clickButton('#btnSearch').wait(1000)
    .checkGridData('#grdSearch', 16, 'strUnitMeasure', '5 Lb Bag_1').wait(100)
    .checkGridData('#grdSearch', 16, 'strSymbol', '5 Lb Bag_1').wait(100)
    .clickButton('#btnClose').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('icinventoryuom').wait(100)


    .addFunction(function (next) { t.diag("Scenario 3.>2. Add Conversion UOM> 50 Lb Bag"); next(); }).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure', '50 Lb Bag_1')
    .enterData('#txtSymbol', '50 Lb Bag_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
    .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '50').wait(500)
    .clickButton('#btnSave').wait(100)
    .addFunction(function (next) { t.diag("Verify Record Added"); next(); }).wait(100)
    .clickButton('#btnSearch').wait(1000)
    .checkGridData('#grdSearch', 17, 'strUnitMeasure', '50 Lb Bag_1').wait(100)
    .checkGridData('#grdSearch', 17, 'strSymbol', '50 Lb Bag_1').wait(100)
    .clickButton('#btnClose').wait(100)
    .clickButton('#btnClose').wait(100)
    .checkIfScreenClosed('icinventoryuom').wait(100)

    /*4. Add another record, Click Close button Cancel - No, do NOT save the changes > New on Search*/
    .addFunction(function (next) { t.diag("4. Add another record, Click Close button, do NOT save the changes"); next(); }).wait(100)
    .clickButton('#btnNew').wait(100)
    .enterData('#txtUnitMeasure', '70 Lb Bag_1')
    .enterData('#txtSymbol', '70 Lb Bag_1')
    .selectComboRowByIndex('#cboUnitType', 5).wait(100)
    .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
    .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '70').wait(500)
    .checkStatusMessage('Edited')
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
    .clickMessageBoxButton('cancel').wait(10)
    .clickButton('#btnClose').wait(100)
    .checkMessageBox('iRely i21', 'Do you want to save the changes you made?', 'yesnocancel', 'question')
    .clickMessageBoxButton('no').wait(500)
    .checkIfScreenClosed('icinventoryuom').wait(100)
    .checkGridRecordCount('#grdSearch', 18)


    .done()

})