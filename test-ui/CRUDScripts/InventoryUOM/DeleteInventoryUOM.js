StartTest (function (t) {
    new iRely.FunctionalTest().start(t)
        /*====================================== Scenario 1: Delete Unused Inventory UOM ======================================*/
        //region
        .displayText('=====  Scenario 1: Delete Unused Inventory UOM =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Inventory UOM','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'DELETE LB')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','UnitMeasure','DELETE LB')
                    .enterData('Text Field','Symbol','DELETE LB')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .doubleClickSearchRowValue('DELETE LB', 'strUnitMeasure', 1)
                    .waitUntilLoaded('')
                    .clickButton('Delete')
                    .waitUntilLoaded()
                    .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
                    .clickMessageBoxButton('yes')
                    .waitUntilLoaded()
                    .clearTextFilter('FilterGrid')
                    .displayText('=====  Scenario 1: Delete Unused Inventory UOM Done=====')
                    //endregion

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .displayText('===== Add stock UOM first Done  =====')
        //endregion


        /*====================================== Scenario 2: Delete Used Inventory UOM ======================================*/
        //region
        .displayText('===== Scenario 2: Delete Used Inventory UOM  =====')
        .doubleClickSearchRowValue('KG', 'strUnitMeasure', 1)
        .waitUntilLoaded('icinventoryuom')
        .clickButton('Delete')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','Are you sure you want to delete this record?','yesno', 'question')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .verifyMessageBox('iRely i21','The record you are trying to delete is being used.','ok','error')
        .clickMessageBoxButton('ok')
        .waitUntilLoaded('')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .displayText('=====  Scenario 2: Delete Used Inventory UOM Done=====')
        //endregion


        /*====================================== Scenario 3: Delete a single Inventory UOM conversion record. ======================================*/
        //region
        .displayText('===== Scenario 3: Delete a single Inventory UOM conversion record. =====')
        .filterGridRecords('Search', 'FilterGrid', 'Delete 10LB Bag')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)

                    .clickButton('New')
                    .waitUntilLoaded('')
                    .enterData('Text Field','UnitMeasure','Delete 10LB Bag')
                    .enterData('Text Field','Symbol','Test_10 LB bag')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
                    .selectGridComboBoxRowNumber('Conversion',2,'colOtherUOM',11)
                    .enterGridData('Conversion', 2, 'dblConversionToStock', '4.53592')
                    .selectGridComboBoxRowNumber('Conversion',3,'colOtherUOM',8)
                    .enterGridData('Conversion', 3, 'dblConversionToStock', '50')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        //endregion

        .doubleClickSearchRowValue('Delete 10LB Bag', 'strUnitMeasure', 1)
        .waitUntilLoaded('')
        .selectGridRowNumber('Conversion',[1])
        .clickButton('DeleteConversion')
        .waitUntilLoaded()
        .clickMessageBoxButton('yes')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('')
        .verifyData('Text Field','Symbol','Test_10 LB bag - Updated')
        .verifyGridData('Conversion', 1, 'colConversionStockUOM', 'KG')
        .verifyGridData('Conversion', 1, 'colConversionToStockUOM', '4.53592')
        .verifyGridData('Conversion', 2, 'colConversionStockUOM', '50 lb bag')
        .clickButton('Close')
        .displayText('===== Scenario 3: Delete a single Inventory UOM conversion record Done =====')

        .displayText('===== Scenario 4: Delete multiple Inventory UOM conversion record. =====')
        .doubleClickSearchRowValue('Test_10 LB bag - Updated', 'strUnitMeasure', 1)
        .waitUntilLoaded('icinventoryuom')
        .selectGridRowNumber('Conversion',[1,2])
        .clickButton('DeleteConversion')
        .waitUntilLoaded()
        .clickMessageBoxButton('yes')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close')
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('icinventoryuom')
        .clickButton('Close')
        .waitUntilLoaded()
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 4: Delete multiple Inventory UOM conversion record Done =====')

        .done();

})