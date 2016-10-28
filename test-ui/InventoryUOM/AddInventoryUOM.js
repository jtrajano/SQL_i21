StartTest (function (t) {
    new iRely.FunctionalTest().start(t)


        //region Scenario 1. Add stock UOM first
        .displayText('===== Scenario 1. Add stock UOM first  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory UOM','Screen')
        .clickButton('New')
        .waitTillLoaded('icinventoryuom','')
        .enterData('textbox','UnitMeasure','Test_LB')
        .enterData('textbox','Symbol','Test_LB')
        .selectComboBoxRowNumber('UnitType',6,0)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close').wait(100)
        .markSuccess('===== Add Stock Uom successful  =====')
        //endregion


        //region Scenario 2. Add Conversion UOM's
        .displayText('===== Scenario 2. Add Conversion UOMs =====')
        .clickButton('New')
        .waitTillLoaded('icinventoryuom','')
        .enterData('textbox','UnitMeasure','Test_5 LB bag')
        .enterData('textbox','Symbol','Test_5 LB bag')
        .selectComboBoxRowNumber('UnitType',7,0)
        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Test_LB','strUnitMeasure')
        .enterGridData('Conversion', 0, 'dblConversionToStock', '5')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close').wait(100)
        .markSuccess('===== Add Stock Uom successful  =====')

        .displayText('===== Scenario 2. Add Conversion UOMs =====')
        .clickButton('New')
        .waitTillLoaded('icinventoryuom','')
        .enterData('textbox','UnitMeasure','Test_10 LB bag')
        .enterData('textbox','Symbol','Test_10 LB bag')
        .selectComboBoxRowNumber('UnitType',7,0)
        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Test_LB','strUnitMeasure')
        .enterGridData('Conversion', 0, 'dblConversionToStock', '10')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close').wait(100)
        .markSuccess('===== Add Conversion UOM successful  =====')
        //endregion

        //region Scenario 3. Update UOM
        .displayText('===== Scenario 3. Update UOM =====')
        .selectSearchRowValue('Test_10 LB bag',500,'strUnitMeasure')
        .clickButton('OpenSelected')
        .waitTillLoaded('icinventoryuom','')
        .enterData('textbox','UnitMeasure','Test_10 LB bag - Updated')
        .enterData('textbox','Symbol','Test_10 LB bag - Updated')
        .selectGridComboBoxRowValue('Conversion',2,'strUnitMeasure','KG','strUnitMeasure')
        .enterGridData('Conversion', 2, 'dblConversionToStock', '4.53592')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close').wait(100)
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitTillLoaded('icinventoryuom','')
        .verifyData('textbox','UnitMeasure','Test_10 LB bag - Updated')
        .verifyData('textbox','Symbol','Test_10 LB bag - Updated')
        .verifyGridData('Conversion', 1, 'colConversionStockUOM', 'KG')
        .verifyGridData('Conversion', 1, 'colConversionToStockUOM', '4.53592')
        .markSuccess('===== Update UOM Successful  =====')
        //endregion

        //region Scenario 4: Check Required Fields
        .displayText('===== Scenario 4: Check Required Fields =====')
        .clickButton('New')
        .waitTillLoaded('icinventoryuom','')
        .clickButton('Save')
        .clickButton('Close').wait(500)
        .markSuccess('===== Check required fields successful  =====')
        //endregion

        //region Scenario 5. Add duplicate Inventory UOM
        .displayText('===== Scenario 5. Add duplicate Inventory UOM  =====')
        .clickButton('New')
        .waitTillLoaded('icinventoryuom','')
        .enterData('textbox','UnitMeasure','Test_LB')
        .enterData('textbox','Symbol','Test_LB')
        .selectComboBoxRowNumber('UnitType',6,0)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyMessageBox('iRely i21','Unit Measure must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close').wait(100)
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no').wait(500)
        .markSuccess('===== Add duplicate Inventory UOM successful  =====')
        //endregion


        .done();

})