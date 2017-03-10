StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //Inventory Categories
        .displayText('===== Scenario 1: Open Categories Screen From Inventory Menu ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strCategoryCode', text: 'Category Code'},
            {dataIndex: 'strDescription', text: 'Description'},
            {dataIndex: 'strInventoryType', text: 'Inventory Type'}
        ])
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 1: Open Categories Screen From Inventory Menu Done ====')

        .displayText('===== Scenario 2: Open Categories Screen From Existing Record ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
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
        .displayText('===== Scenario 2: Open Categories Screen From Existing Record Done ====')

        .done();

})