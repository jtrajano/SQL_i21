StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region Open New Commodity Screen
        .displayText('===== Scenario 1: Open New Commodity Screen from Search Screen =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .waitUntilLoaded()
        .displayText('===== Open New Commodity Screen =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('iccommodity')
        .verifyScreenShown('iccommodity')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 1: Open New Commodity Screen from Search Screen Done =====')


        .displayText('===== Scenario 2: Open Commodity Screen from Search Screen Existing Record =====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('iccommodity')
        .verifyScreenShown('iccommodity')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 2: Open Commodity Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 3: Open Commodity Screen from Search Screen Existing Record New Button=====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('iccommodity')
        .verifyScreenShown('iccommodity')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('iccommodity')
        .verifyScreenShown('iccommodity')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 3: Open Commodity Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 4: Check Required Fields =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('iccommodity')
        .verifyScreenShown('iccommodity')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 4: Check Required Fields Done =====')


        .displayText('===== Scenario 5: Open New Commodity Screen and Check Fields =====')
        .clickMenuScreen('Commodities','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .isControlVisible('btn',
        [
            'New'
            ,'Save'
            ,'Find'
            ,'Delete'
            ,'Undo'
            ,'Close'
            ,'DeleteUom'
            ,'GridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'CommodityCode'
            ,'Description'
            ,'DecimalsOnDpr'
            ,'ConsolidateFactor'
            ,'PriceChecksMin'
            ,'PriceChecksMax'
            ,'EdiCode'
            ,'FilterGrid'
        ], true)
        .isControlVisible('chk',
        [
            'ExchangeTraded'
            ,'FxExposure'
        ], true)
        .isControlVisible('cbo',
        [
            'FutureMarket'
            ,'DefaultScheduleStore'
            ,'DefaultScheduleDiscount'
            ,'ScaleAutoDistDefault'
        ], true)
        .isControlVisible('dtm',
        [
            'CropEndDateCurrent'
            ,'CropEndDateNew'
        ], true)
        .clickTab('Attribute')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'DeleteOrigins'
            ,'MoveUpOrigins'
            ,'MoveDownOrigins'
            ,'GridLayout'
            ,'DeleteProductTypes'
            ,'MoveUpProductTypes'
            ,'MoveDownProductTypes'
            ,'DeleteRegions'
            ,'MoveUpRegions'
            ,'MoveDownRegions'
            ,'DeleteClasses'
            ,'MoveUpClasses'
            ,'MoveDownClasses'
            ,'DeleteSeasons'
            ,'MoveUpSeasons'
            ,'MoveDownSeasons'
            ,'DeleteGrades'
            ,'MoveUpGrades'
            ,'MoveDownGrades'
            ,'DeleteProductLines'
            ,'MoveUpProductLines'
            ,'MoveDownProductLines'
        ], true)
        .isControlVisible('col',
        [
            'Origin'
            ,'ProductType'
            ,'Region'
            ,'ClassVariant'
            ,'Season'
            ,'Grade'
            ,'ProductLine'
            ,'DeltaHedge'
            ,'DeltaPercent'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 5: Open New Commodity Screen and Check Fields Done =====')
        //endregion

        .done();


})