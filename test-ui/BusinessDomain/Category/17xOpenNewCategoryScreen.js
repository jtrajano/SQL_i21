StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region Open New Category Screen
        .displayText('===== Scenario 1: Open New Category Screen from Search Screen =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .waitUntilLoaded()
        .displayText('===== Open New Category Screen =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('iccategory')
        .verifyScreenShown('iccategory')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 1: Open New Category Screen from Search Screen Done =====')


        .displayText('===== Scenario 2: Open Category Screen from Search Screen Existing Record =====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('iccategory')
        .verifyScreenShown('iccategory')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 2: Open Category Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 3: Open Category Screen from Search Screen Existing Record New Button=====')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded()
        .waitUntilLoaded('iccategory')
        .verifyScreenShown('iccategory')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('iccategory')
        .verifyScreenShown('iccategory')
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 3: Open Category Screen from Search Screen Existing Record Done =====')


        .displayText('===== Scenario 4: Check Required Fields =====')
        .clickButton('New')
        .waitUntilLoaded()
        .waitUntilLoaded('iccategory')
        .verifyScreenShown('iccategory')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 4: Check Required Fields Done =====')


        .displayText('===== Scenario 5: Open New Category Screen and Check Fields =====')
        .clickMenuScreen('Categories','Screen')
        .waitUntilLoaded()
        .verifySearchToolbarButton({openselected: false, openall: false, close: false, export: false})
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .isControlVisible('btn',
        [
            'New'
            ,'Save'
            ,'Find'
            ,'Delete'
            ,'Undo'
            ,'Close'
            ,'InsertTax'
            ,'DeleteTax'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'DeleteUom'
            ,'ridLayout'
            ,'InsertCriteria'
        ], true)
        .isControlVisible('txt',
        [
            'CategoryCode'
            ,'Description'
            ,'GlDivisionNumber'
            ,'SalesAnalysisByTon'
            ,'StandardQty'
            ,'FilterGrid'
        ], true)
        .isControlVisible('cbo',
        [
            'InventoryType'
            ,'LineOfBusiness'
            ,'CostingMethod'
            ,'InventoryValuation'
            ,'StandardUOM'
        ], true)

        //Categories Location tab
        .clickTab('Point of Sale')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddLocation'
            ,'EditLocation'
            ,'DeleteLocation'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'LocationId'
            ,'LocationCashRegisterDept'
            ,'LocationTargetGrossProfit'
            ,'LocationTargetInventoryCost'
            ,'LocationCostInventoryBOM'
        ], true)
        //Categories GL Accounts tab
        .clickTab('GL Accounts')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'AddRequired'
            ,'DeleteGlAccounts'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
        ], true)
        .isControlVisible('txt',
        [
            ,'FilterGrid'
        ], true)
        .isControlVisible('col',
        [
            'AccountCategory'
            ,'AccountId'
            ,'AccountDescription'
        ], true)
        //Categories Vendor Category Xref tab
        .clickTab('Vendor Category Xref')
        .waitUntilLoaded()
        .isControlVisible('btn',
        [
            'DeleteVendorCategoryXref'
            ,'GridLayout'
            ,'InsertCriteria'
            ,'MaximizeGrid'
        ], true)
        .isControlVisible('col',
        [
            'VendorLocation'
            ,'VendorId'
            ,'VendorDepartment'
            ,'VendorAddOrderUPC'
            ,'VendorUpdateExisting'
            ,'VendorAddNew'
            ,'VendorUpdatePrice'
            ,'VendorFamily'
            ,'VendorOrderClass'
        ], true)
        //Categories Manufacturing tab
        .clickTab('Manufacturing')
        .waitUntilLoaded()
        .isControlVisible('txt',
        [
            'ERPItemClass'
            ,'LifeTime'
            ,'BOMItemShrinkage'
            ,'BOMItemUpperTolerance'
            ,'BOMItemLowerTolerance'
            ,'ConsumptionMethod'
            ,'BOMItemType'
            ,'ShortName'
            ,'LaborCost'
            ,'OverHead'
            ,'Percentage'
            ,'CostDistributionMethod'
        ], true)
        .isControlVisible('chk',
        [
            'Scaled'
            ,'OutputItemMandatory'
            ,'Sellable'
            ,'YieldAdjustment'
            ,'TrackedInWarehouse'
        ], true)
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Scenario 5: Open New Category Screen and Check Fields Done =====')
        //endregion

        .done();


})