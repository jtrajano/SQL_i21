StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add New Fuel Type
        .displayText('===== Scenario 1: Add New Fuel Type =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded('icfueltype')
        .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category1', 'FuelCategory',0)
        .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 1', 'FeedStock',0)
        .enterData('Text Field','BatchNo','1')
        .verifyData('Text Field','EquivalenceValue','Test Equivalence Value1')
        .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 1', 'FuelCode',0)
        .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 1', 'ProductionProcess',0)
        .selectComboBoxRowValue('FeedStockUom', 'LB', 'FeedStockUom',0)
        .enterData('Text Field','FeedStockFactor','10')
        .clickCheckBox('RenewableBiomass', true)
        .enterData('Text Field','PercentOfDenaturant','25')
        .clickCheckBox('DeductDenaturantFromRin', true)
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 2: Update Fuel Type
        .displayText('===== Scenario 2: Update Fuel Type =====')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icfueltype')
        .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category2', 'FuelCategory',0)
        .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 2', 'FeedStock',0)
        .verifyData('Text Field','EquivalenceValue','Test Equivalence Value2')
        .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 2', 'FuelCode',0)
        .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 2', 'ProductionProcess',0)
        .selectComboBoxRowValue('FeedStockUom', 'KG', 'FeedStockUom',0)
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .verifyData('Combo Box','FuelCategory','Test Fuel Category2')
        .verifyData('Combo Box','FeedStock','Test Feed Stock 2')
        .verifyData('Text Field','EquivalenceValue','Test Equivalence Value2')
        .verifyData('Combo Box','FuelCode','Test Fuel Code 2')
        .verifyData('Combo Box','ProductionProcess','Test Process Code 2')
        .verifyData('Combo Box','FeedStockUom','KG')
        .clickButton('Close')
        //endregion


        //region Scenario 3: Check Required Fields
        .displayText('===== Scenario 3: Check Required Fields =====')
        .clickButton('New')
        .clickButton('Save')
        .clickButton('Close')
        //endregion

        //region Scenario 4: Add Duplicate Fuel Type
        .displayText('===== Scenario 2: Add New Fuel Type =====')
        .clickButton('New')
        .waitUntilLoaded('icfueltype')
        .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category2', 'FuelCategory',0)
        .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 2', 'FeedStock',0)
        .enterData('Text Field','BatchNo','1')
        .verifyData('Text Field','EquivalenceValue','Test Equivalence Value2')
        .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 2', 'FuelCode',0)
        .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 2', 'ProductionProcess',0)
        .selectComboBoxRowValue('FeedStockUom', 'KG', 'FeedStockUom',0)
        .enterData('Text Field','FeedStockFactor','10')
        .clickCheckBox('RenewableBiomass', true)
        .enterData('Text Field','PercentOfDenaturant','25')
        .clickCheckBox('DeductDenaturantFromRin', true)
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Fuel Type must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .waitUntilLoaded()
        //endregion


        .done();

})