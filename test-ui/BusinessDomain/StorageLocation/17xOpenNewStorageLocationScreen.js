StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region Open New Storage Location Screen
        .displayText('===== Scenario 1: Open New Storage Location Screen from Search Screen =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Storage Locations','Screen')
        .waitUntilLoaded()
        .displayText('===== Open New Storage Location Screen =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icstorageunit')
        .verifyScreenShown('icstorageunit')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 1: Open New Storage Location Screen from Search Screen Done =====')


        .displayText('===== Scenario 2: Open Storage Location Screen from Search Screen Existing Record =====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icstorageunit')
        .verifyScreenShown('icstorageunit')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 2: Open Storage Location Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 3: Open Storage Location Screen from Search Screen Existing Record New Button=====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('icstorageunit')
        .verifyScreenShown('icstorageunit')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icstorageunit')
        .verifyScreenShown('icstorageunit')
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 3: Open Storage Location Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 4: Check Required Fields =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('icstorageunit')
        .verifyScreenShown('icstorageunit')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 4: Check Required Fields Done =====')


        .displayText('===== Scenario 5: Open New Storage Location Screen and Check Fields =====')
        .clickMenuScreen('Storage Locations','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .clickButton('New')
        .waitUntilLoaded('icstorageunit')
        .isControlVisible('btn',
        [
            'New'
            ,'Save'
            ,'Search'
            ,'Delete'
            ,'Undo'
            ,'Close'
            ,'Help'
            ,'Support'
            ,'FieldName'
            ,'EmailUrl'
        ], true)
        .isControlVisible('txt',
        [
            'Name'
            ,'Description'
            ,'Aisle'
            ,'MinBatchSize'
            ,'BatchSize'
            ,'PackFactor'
            ,'EffectiveDepth'
            ,'UnitsPerFoot'
            ,'ResidualUnits'
            ,'Sequence'
            ,'XPosition'
            ,'YPosition'
            ,'ZPosition'
        ], true)
        .isControlVisible('cbo',
        [
            'UnitType'
            ,'Location'
            ,'SubLocation'
            ,'ParentUnit'
            ,'RestrictionType'
            ,'BatchSizeUom'
            ,'Commodity'
        ], true)
        .isControlVisible('chk',
        [
            'AllowConsume'
            ,'AllowMultipleItems'
            ,'AllowMultipleLots'
            ,'MergeOnMove'
            ,'CycleCounted'
            ,'DefaultWarehouseStagingUnit'
        ], true)

        //Storage Location Measurement Tab
        .clickTab('Measurement')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddMeasurement'
            ,'DeleteMeasurement'
        ], true)
        .isControlVisible('col',
        [
            'Measurement'
            ,'ReadingPoint'
            ,'Active'
        ], true)

        //Storage Location Item Categories Allowed Tab
        .clickTab('Item Categories Allowed')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'DeleteItemCategoryAllowed'
        ], true)
        .isControlVisible('col',
        [
            'Category'
        ], true)

        //Storage Location Container Tab
        .clickTab('Container')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'DeleteContainer'
        ], true)
        .isControlVisible('col',
        [
            'Container'
            ,'ExternalSystem'
            ,'ContainerType'
            ,'LastUpdateby'
            ,'LastUpdateOn'
        ], true)

        //Storage Location SKU Tab
        .clickTab('SKU')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            '#btnDeleteSKU'
        ], true)
        .isControlVisible('col',
        [
            'Item'
            ,'Sku'
            ,'Qty'
            ,'Container'
            ,'LotSerial'
            ,'Expiration'
            ,'Status'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        .waitUntilLoaded()
        .displayText('===== Scenario 5: Open New Storage Location Screen and Check Fields Done =====')
        //endregion

        .done();


})