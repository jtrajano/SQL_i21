StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //Inventory Commodities
        .displayText('===== Scenario 1: Open Commodities Screen From Inventory Menu ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strCommodityCode', text: 'Commodity Code'},
            {dataIndex: 'strDescription', text: 'Description'}
        ])
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 1: Open Commodities Screen From Inventory Menu Done ====')

        .displayText('===== Scenario 2: Open Commodities Screen From Existing Record ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .clickButton('Find')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 2: Open Commodities Screen From Existing Record Done ====')

        .done();

})