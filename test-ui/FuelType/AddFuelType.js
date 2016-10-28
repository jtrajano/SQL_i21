StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add New Fuel Type
        .displayText('===== Scenario 1: Add New Fuel Type =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Fuel Types','Screen')
        .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category1', 'FuelCategory',0)
        .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 1', 'FeedStock',0)
        .enterData('textbox','BatchNo','1')
        .verifyData('textbox','EquivalenceValue','Test Equivalence Value1')
        .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 1', 'FuelCode',0)
        .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 1', 'ProductionProcess',0)
        .selectComboBoxRowValue('FeedStockUom', 'LB', 'FeedStockUom',0)
        .enterData('textbox','FeedStockFactor','10')
        .clickCheckBox('RenewableBiomass', true)
        .enterData('textbox','PercentOfDenaturant','25')
        .clickCheckBox('DeductDenaturantFromRin', true)
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 2: Update Fuel Type
        .displayText('===== Scenario 2: Update Fuel Type =====')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category2', 'FuelCategory',0)
        .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 2', 'FeedStock',0)
        .verifyData('textbox','EquivalenceValue','Test Equivalence Value2')
        .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 2', 'FuelCode',0)
        .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 2', 'ProductionProcess',0)
        .selectComboBoxRowValue('FeedStockUom', 'KG', 'FeedStockUom',0)
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .verifyData('combobox','FuelCategory','Test Fuel Category2')
        .verifyData('combobox','FeedStock','Test Feed Stock 2')
        .verifyData('textbox','EquivalenceValue','Test Equivalence Value2')
        .verifyData('combobox','FuelCode','Test Fuel Code 2')
        .verifyData('combobox','ProductionProcess','Test Process Code 2')
        .verifyData('combobox','FeedStockUom','KG')
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
        .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category2', 'FuelCategory',0)
        .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 2', 'FeedStock',0)
        .enterData('textbox','BatchNo','1')
        .verifyData('textbox','EquivalenceValue','Test Equivalence Value2')
        .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 2', 'FuelCode',0)
        .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 2', 'ProductionProcess',0)
        .selectComboBoxRowValue('FeedStockUom', 'LB', 'FeedStockUom',0)
        .enterData('textbox','FeedStockFactor','10')
        .clickCheckBox('RenewableBiomass', true)
        .enterData('textbox','PercentOfDenaturant','25')
        .clickCheckBox('DeductDenaturantFromRin', true)
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        .done();

})