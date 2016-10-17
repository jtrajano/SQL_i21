StartTest(function (t) {

    var engine = new iRely.TestEngine();
    var commonSM = Ext.create('SystemManager.CommonSM');
    var commonIC = Ext.create('i21.test.Inventory.CommonIC');

    engine.start(t)


        // LOG IN
        .displayText('Log In').wait(500)
        .addFunction(function (next) {
            commonSM.commonLogin(t, next); }).wait(100)
        .waitTillMainMenuLoaded('Login Successful').wait(500)

        .expandMenu('Inventory').wait(500)
        .markSuccess('Inventory successfully expanded').wait(300)
        .openScreen('Inventory UOM').wait(200)
        .waitTillLoaded('Open Category Search Screen Successful').wait(200)


        // 1. Add stock UOM first
        .displayText('====== Scenario 1. Add Stock UOM ======').wait(300)
        .clickButton('#btnNew').wait(100)
        .waitTillVisible('icinventoryuom','Open Inventory UOM  Successful').wait(200)
        .checkScreenShown('icinventoryuom').wait(100)
        .enterData('#txtUnitMeasure', 'Pound_1').wait(300)
        .enterData('#txtSymbol', 'Lb_1').wait(300)
        .selectComboRowByIndex('#cboUnitType', 5).wait(300)
        .checkStatusMessage('Edited').wait(100)
        .clickButton('#btnSave').wait(100)
        .displayText('====== Verify Record Added ======').wait(300)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 40, 'strUnitMeasure', 'Pound_1').wait(100)
        .checkGridData('#grdSearch', 40, 'strSymbol', 'Lb_1').wait(100)
        .markSuccess('====== Add Stock UOM Successful ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)

        // 2. Add conversion UOMs on each stock UOM
        .displayText('====== Scenario 2.1 Add Conversion UOM> 5 Lb Bag======').wait(300)
        .clickButton('#btnNew').wait(100).wait(100)
        .enterData('#txtUnitMeasure', '5 Lb Bag_1').wait(100)
        .enterData('#txtSymbol', '5 Lb Bag_1').wait(100)
        .selectComboRowByIndex('#cboUnitType', 5).wait(100)
        .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
        .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '5').wait(500)
        .clickButton('#btnSave').wait(100)
        .displayText('====== Verify Record Added ======').wait(300)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 41, 'strUnitMeasure', '5 Lb Bag_1').wait(100)
        .checkGridData('#grdSearch', 41, 'strSymbol', '5 Lb Bag_1').wait(100)
        .markSuccess('====== Add Conversion UOM> 5 Lb Bag ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)


        .displayText('====== Scenario 2.2 Add Conversion UOM> 10 Lb Bag======').wait(300)
        .clickButton('#btnNew').wait(100)
        .enterData('#txtUnitMeasure', '10 Lb Bag_1').wait(100)
        .enterData('#txtSymbol', '10 Lb Bag_1').wait(100)
        .selectComboRowByIndex('#cboUnitType', 5).wait(100)
        .selectGridComboRowByFilter('#grdConversion', 0, 'strUnitMeasure', 'Pound_1', 1000).wait(100)
        .enterGridData('#grdConversion', 0, 'colConversionToStockUOM', '10').wait(500)
        .clickButton('#btnSave').wait(100)
        .addFunction(function (next) { t.diag("Verify Record Added"); next(); }).wait(100)
        .clickButton('#btnSearch').wait(500)
        .waitTillLoaded('').wait(500)
        .checkGridData('#grdSearch', 42, 'strUnitMeasure', '10 Lb Bag_1').wait(100)
        .checkGridData('#grdSearch', 42, 'strSymbol', '10 Lb Bag_1').wait(100)
        .markSuccess('====== Add Conversion UOM> 10 Lb Bag Successful ======').wait(200)
        .clickButton('#btnClose').wait(100)
        .clickButton('#btnClose').wait(100)
        .checkIfScreenClosed('icinventoryuom').wait(100)

        // 3. Add another record, Click Close button Cancel - No, do NOT save the changes > New on Search
        .displayText('====== Scenario 3. Add another record, Click Close button, do NOT save the changes======').wait(300)
        .clickButton('#btnNew').wait(100)
        .waitTillVisible('icinventoryuom','Open Inventory UOM  Successful').wait(200)
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
        .checkGridRecordCount('#grdSearch', 43)
        .markSuccess('====== Add another record, Click Close button Cancel - No, do NOT save the changes > New on Search Successful ======').wait(200)

        .markSuccess('====== Add Inventory UOM Done and Successful! ======').wait(200)


    .done()

})