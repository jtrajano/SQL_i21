StartTest (function (t) {
    var commonICST = Ext.create('Inventory.CommonICSmokeTest');
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region Scenario 1: Add New Storage Location
        .displayText('===== Scenario 1: Adding New Storage Location. =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Locations','Screen')
        .clickButton('New')
        .waitUntilLoaded('icstorageunit')
        .enterData('Text Field','Name','Smoke Storage')
        .enterData('Text Field','Description','Test Smoke Storage')
        .selectComboBoxRowNumber('UnitType',6,0)
        .selectComboBoxRowNumber('Location',1,0)
        .selectComboBoxRowNumber('SubLocation',6,0)
        .selectComboBoxRowNumber('ParentUnit',1,0)
        .enterData('Text Field','Aisle','Test Aisle - 01')
        .clickCheckBox('AllowConsume', true)
        .clickCheckBox('AllowMultipleItems', true)
        .clickCheckBox('AllowMultipleLots', true)
        .clickCheckBox('CycleCounted', true)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Storage Location Created =====')
        //endregion


        //region Scenario 2. Add Inventory UOM
        .displayText('===== Scenario 2. Add Inventory UOM =====')
        .clickMenuScreen('Inventory UOM','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Smoke_LB')
        .enterData('Text Field','Symbol','Test_LB')
        .selectComboBoxRowNumber('UnitType',6,0)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')


        //Add Inventory UOM with Conversion 5 lb bag
        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Smoke 5 LB bag')
        .enterData('Text Field','Symbol','Smoke 5 LB bag')
        .selectComboBoxRowNumber('UnitType',7,0)
        .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
        //.selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('Conversion', 1, 'dblConversionToStock', '5')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')


        //Add Inventory UOM with Conversion 10 lb bag
        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Smoke 10 LB bag')
        .enterData('Text Field','Symbol','Smoke 10 LB bag')
        .selectComboBoxRowNumber('UnitType',7,0)
        .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
        //.selectGridComboBoxRowValue('Conversion',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Inventory UOM Created =====')
        //endregion


        //region Fuel Category
        .displayText('===== Scenario 3: Add New Fuel Type, Fuel Category, Feed Stock, Fuel Code, Production Process, Feed Stock UOM =====')
        .clickMenuScreen('Fuel Types','Screen')
        .clickButton('Close')
        .clickButton('FuelCategory')
        .waitUntilLoaded('icfuelcategory')
        .enterGridData('GridTemplate', 1, 'colRinFuelCategoryCode', 'ICSmokeFuelCategory')
        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFuelCategoryDesc')
        .enterGridData('GridTemplate', 1, 'colEquivalenceValue', 'ICSmokeFuelCategory_EV')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //Feed Stock
        .clickButton('FeedStock')
        .waitUntilLoaded('')
        .enterGridData('GridTemplate', 1, 'colRinFeedStockCode', 'ICSmokeFeedStock')
        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFeedStockDesc')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //FuelCode
        .clickButton('FuelCode')
        .waitUntilLoaded('icfuelcode')
        .enterGridData('GridTemplate', 1, 'colRinFuelCode', 'ICSmokeFuelCode')
        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeFuelCodeDesc')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //Production Process
        .clickButton('ProductionProcess')
        .waitUntilLoaded('icprocesscode')
        .enterGridData('GridTemplate', 1, 'colRinProcessCode', 'ICSmokeProductionProcess')
        .enterGridData('GridTemplate', 1, 'colDescription', 'ICSmokeProductionProcessDesc')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //Feed Stock UOM
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('icfeedstockuom')
        .selectGridComboBoxRowValue('GridTemplate',1,'strUnitMeasure','Smoke_LB','strUnitMeasure')
        .enterGridData('GridTemplate', 1, 'colRinFeedStockUOMCode', 'Test UOM Code 1')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        //Fuel Type
        .clickButton('New')
        .selectComboBoxRowNumber('FuelCategory',1,0)
        //.selectComboBoxRowValue('FuelCategory', 'ICSmokeFuelCategory', 'FuelCategory',0)
        .selectComboBoxRowNumber('FeedStock',1,0)
        //.selectComboBoxRowValue('FeedStock', 'ICSmokeFeedStock', 'FeedStock',0)
        .enterData('Text Field','BatchNo','1')
        .verifyData('Text Field','EquivalenceValue','ICSmokeFuelCategory_EV')
        .selectComboBoxRowNumber('FuelCode',1,0)
        //.selectComboBoxRowValue('FuelCode', 'ICSmokeFuelCode', 'FuelCode',0)
        .selectComboBoxRowNumber('ProductionProcess',1,0)
        //.selectComboBoxRowValue('ProductionProcess', 'ICSmokeProductionProcess', 'ProductionProcess',0)
        .selectComboBoxRowNumber('FeedStockUom',1,0)
        //.selectComboBoxRowValue('FeedStockUom', 'Smoke_LB', 'FeedStockUom',0)
        .enterData('Text Field','FeedStockFactor','10')
        .clickCheckBox('RenewableBiomass', true)
        .enterData('Text Field','PercentOfDenaturant','25')
        .clickCheckBox('DeductDenaturantFromRin', true)
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Add Fuel Type Done =====')
        //endregion


        //Add Category
        .displayText('===== Scenario 4: Add Category =====')
        .addFunction(function(next){
            commonIC.addCategory (t,next, 'SC - Category - 01', 'Test Smoke Category Description', 2)
        })

        //Add Commodity
        .displayText('===== Scenario 6: Add Commodity =====')
        .addFunction(function(next){
            commonIC.addCommodity (t,next, 'SC - Commodity - 01', 'Test Smoke Commodity Description')
        })

        //Add Lotted Item
        .displayText('===== Scenario 5: Add Lotted Item =====')
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Smoke - LTI - 01'
                , 'Test Lotted Item For Other Smoke Testing'
                , 'SC - Category - 01'
                , 'SC - Commodity - 01'
                , 3
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })

        //Add Non Lotted Item
        .displayText('===== Scenario 6: Add Lotted Item =====')
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Smoke - NLTI - 01'
                , 'Test Non Lotted Item Smoke Testing'
                , 'SC - Category - 01'
                , 'SC - Commodity - 01'
                , 4
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })

        .done();

})