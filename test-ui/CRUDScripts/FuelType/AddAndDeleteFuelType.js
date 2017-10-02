StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add New Fuel Type
        .displayText('===== Scenario 1: Add New Fuel Type =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded('')
        .filterGridRecords('Search', 'FilterGrid', 'Test Fuel Category2')
        .waitUntilLoaded('')
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clearTextFilter('FilterGrid')
                    .waitUntilLoaded('')
                    .clickButton('New')
                    .waitUntilLoaded('')
                    .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category2', 'FuelCategory',0)
                    .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 2', 'FeedStock',0)
                    .enterData('Text Field','BatchNo','1')
                    .verifyData('Text Field','EquivalenceValue','Test Equivalence Value2')
                    .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 2', 'FuelCode',0)
                    .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 2', 'ProductionProcess',0)
                    .selectComboBoxRowValue('FeedStockUom', 'Test_KG', 'FeedStockUom',0)
                    .enterData('Text Field','FeedStockFactor','10')
                    .clickCheckBox('RenewableBiomass', true)
                    .enterData('Text Field','PercentOfDenaturant','25')
                    .clickCheckBox('DeductDenaturantFromRin', true)
                    .clickButton('Save')
                    .verifyStatusMessage('Saved')
                    .done();
            },
            continueOnFail: true
        })
        .clickButton('Close')
        .waitUntilLoaded('')
        
        //endregion


        // //region Scenario 2: Update Fuel Type
        // .displayText('===== Scenario 2: Update Fuel Type =====')
        // .selectSearchRowNumber(1)
        // .clickButton('OpenSelected')
        // .waitUntilLoaded('')
        // .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category2', 'FuelCategory',0)
        // .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 2', 'FeedStock',0)
        // .verifyData('Text Field','EquivalenceValue','Test Equivalence Value2')
        // .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 2', 'FuelCode',0)
        // .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 2', 'ProductionProcess',0)
        // .selectComboBoxRowValue('FeedStockUom', 'KG', 'FeedStockUom',0)
        // .clickButton('Save')
        // .verifyStatusMessage('Saved')
        // .clickButton('Close')
        // .selectSearchRowNumber(1)
        // .clickButton('OpenSelected')
        // .verifyData('Combo Box','FuelCategory','Test Fuel Category2')
        // .verifyData('Combo Box','FeedStock','Test Feed Stock 2')
        // .verifyData('Text Field','EquivalenceValue','Test Equivalence Value2')
        // .verifyData('Combo Box','FuelCode','Test Fuel Code 2')
        // .verifyData('Combo Box','ProductionProcess','Test Process Code 2')
        // .verifyData('Combo Box','FeedStockUom','KG')
        // .clickButton('Close')
        // //endregion


        //region Scenario 3: Check Required Fields
        .displayText('===== Scenario 3: Check Required Fields =====')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded('')
        .clickButton('New')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded('')
        .clickButton('Close')
        //endregion

        //region Scenario 4: Add Duplicate Fuel Type
        .displayText('===== Scenario 2: Add New Fuel Type =====')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded('')
        .clickButton('New')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('FuelCategory', 'Test Fuel Category2', 'FuelCategory',0)
        .selectComboBoxRowValue('FeedStock', 'Test Feed Stock 2', 'FeedStock',0)
        .enterData('Text Field','BatchNo','1')
        .verifyData('Text Field','EquivalenceValue','Test Equivalence Value2')
        .selectComboBoxRowValue('FuelCode', 'Test Fuel Code 2', 'FuelCode',0)
        .selectComboBoxRowValue('ProductionProcess', 'Test Process Code 2', 'ProductionProcess',0)
        .selectComboBoxRowValue('FeedStockUom', 'Test_KG', 'FeedStockUom',0)
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


        //region Scenario 1: Delete Unused Fuel Type
        .displayText('=====  Scenario 1: Delete Unused Fuel Type and Remaining Fuel Type Records =====')
        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded('')
        .selectSearchRowNumber([1])
        .clickButton('OpenSelected')
        .waitUntilLoaded('')
        .clickButton('Delete')
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
 

        .clickMenuScreen('Fuel Types','Screen')
        .waitUntilLoaded('')
        .clickButton('FuelCategory')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .waitUntilLoaded('')
        .clickButton('FeedStock')
        .waitUntilLoaded('icfeedstockcode')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .waitUntilLoaded('')
        .clickButton('FuelCode')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded()

        .waitUntilLoaded('')
        .clickButton('ProductionProcess')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .waitUntilLoaded('')
        .clickButton('FeedStockUOM')
        .waitUntilLoaded('')
        .selectGridRowNumber('GridTemplate',[1])
        .clickButton('Delete')
        //.verifyMessageBox('iRely i21','You are about to delete 1 row.<br/>Are you sure you want to continue?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .displayText('=====  Scenario 1: Delete Unused Fuel Type and Remaining Fuel Type Records Done =====')
 //endregion


        .done();

})