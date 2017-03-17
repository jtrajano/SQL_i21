StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //Inventory Storage Locations
        .displayText('===== Scenario 1: Open Storage Locations Screen From Inventory Menu ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Locations','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .verifyGridColumnNames('Search', [
            {dataIndex: 'strName', text: 'Name'},
            {dataIndex: 'strDescription', text: 'Description'},
            {dataIndex: 'strStorageUnitType', text: 'Storage Unit Type'},
            {dataIndex: 'strLocationName', text: 'Location'},
            {dataIndex: 'strSubLocationName', text: 'Sub Location'},
            {dataIndex: 'strParentStorageLocationName', text: 'Parent Unit'},
            {dataIndex: 'strRestrictionCode', text: 'Restriction Type'}
        ])
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 1: Open Storage Locations Screen From Inventory Menu Done ====')

        .displayText('===== Scenario 2: Open Storage Locations Screen From Existing Record ====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Locations','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .clickButton('Search')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .clickButton('Close')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .displayText('===== Scenario 2: Open Storage Locations Screen From Existing Record Done ====')

        .done();

})