StartTest (function (t) {
    new iRely.FunctionalTest().start(t)


        //region Scenario 1. Add stock UOM first
        .displayText('===== Scenario 1. Add stock UOM first  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory UOM','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Test_LB')
        .enterData('Text Field','Symbol','Test_LB')
        .selectComboBoxRowNumber('UnitType',6,0)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 2. Add Conversion UOM's
        .displayText('===== Scenario 2. Add Conversion UOMs =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Test_5 LB bag')
        .enterData('Text Field','Symbol','Test_5 LB bag')
        .selectComboBoxRowNumber('UnitType',7,0)
//        .selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Test_LB','strUnitMeasure')
        .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
        //.selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('Conversion', 1, 'dblConversionToStock', '5')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .waitUntilLoaded()

        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Test_10 LB bag')
        .enterData('Text Field','Symbol','Test_10 LB bag')
        .selectComboBoxRowNumber('UnitType',7,0)
        //.selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Test_LB','strUnitMeasure')
        .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
        .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion

        //region Scenario 3. Update UOM
        .displayText('===== Scenario 3. Update UOM =====')
        .doubleClickSearchRowValue('Test_10 LB bag', 'strUnitMeasure', 1)
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Test_10 LB bag - Updated')
        .enterData('Text Field','Symbol','Test_10 LB bag - Updated')
        .selectGridComboBoxRowNumber('Conversion',2,'colOtherUOM',11)
        .enterGridData('Conversion', 2, 'dblConversionToStock', '4.53592')
        .selectGridComboBoxRowNumber('Conversion',3,'colOtherUOM',8)
        .enterGridData('Conversion', 3, 'dblConversionToStock', '50')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close') 
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryuom')
        .verifyData('Text Field','UnitMeasure','Test_10 LB bag - Updated')
        .verifyData('Text Field','Symbol','Test_10 LB bag - Updated')
        .verifyGridData('Conversion', 2, 'colConversionStockUOM', 'KG')
        .verifyGridData('Conversion', 2, 'colConversionToStockUOM', '4.53592')
        .clickButton('Close')
        .clearTextFilter('FilterGrid')
        //endregion

        //region Scenario 4: Check Required Fields
        .displayText('===== Scenario 4: Check Required Fields =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .clickButton('Save')
        .clickButton('Close')
        //endregion

        //region Scenario 5. Add duplicate Inventory UOM
        .displayText('===== Scenario 5. Add duplicate Inventory UOM  =====')
        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Test_LB')
        .enterData('Text Field','Symbol','Test_LB')
        .selectComboBoxRowNumber('UnitType',6,0)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyMessageBox('iRely i21','Unit Measure must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close') 
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        //endregion


        .done();

})