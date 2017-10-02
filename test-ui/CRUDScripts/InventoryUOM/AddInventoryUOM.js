StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        /*====================================== Scenario 1: Add stock UOM first ======================================*/
        //region
        .displayText('===== Scenario 1. Add stock UOM first  =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Inventory UOM','Screen')
        .waitUntilLoaded()
        .filterGridRecords('Search', 'FilterGrid', 'Test_LB')
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
                    .enterData('Text Field','UnitMeasure','Test_LB')
                    .enterData('Text Field','Symbol','Test_LB')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Add stock UOM first Done  =====')
        //endregion


        /*====================================== Scenario 2. Add Conversion UOM's ======================================*/
        //region
        .displayText('===== Scenario 2. Add Conversion UOMs =====')
        .clickMenuScreen('Inventory UOM','Screen')
        .waitUntilLoaded()
        .filterGridRecords('Search', 'FilterGrid', 'Test_5 LB bag')
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
                    .enterData('Text Field','UnitMeasure','Test_5 LB bag')
                    .enterData('Text Field','Symbol','Test_5 LB bag')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '5')
                    .clickButton('Save')
                    .waitUntilLoaded()
                  

                    .done();
            },
            continueOnFail: true
        })

        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()

        .clickMenuScreen('Inventory UOM','Screen')
        .waitUntilLoaded()
        .filterGridRecords('Search', 'FilterGrid', 'Test_10 LB bag')
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
                    .enterData('Text Field','UnitMeasure','Test_10 LB bag')
                    .enterData('Text Field','Symbol','Test_10 LB bag')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '10')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .displayText('===== Add Conversion UOM Done  =====')
        //endregion


        /*====================================== Scenario 3. Update UOM ======================================*/
        //region
        .displayText('===== Scenario 3. Update UOM =====')
        .clickMenuScreen('Inventory UOM','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Test_10 LB bag', 'strUnitMeasure', 1)
        .waitUntilLoaded('')
        .enterData('Text Field','UnitMeasure','Test_10 LB bag - Updated')
        .enterData('Text Field','Symbol','Test_10 LB bag - Updated')
        .selectGridComboBoxRowNumber('Conversion',2,'colOtherUOM',11)
        .enterGridData('Conversion', 2, 'dblConversionToStock', '4.53592')
        .selectGridComboBoxRowNumber('Conversion',3,'colOtherUOM',8)
        .enterGridData('Conversion', 3, 'dblConversionToStock', '50')
        .clickButton('Save')
        .waitUntilLoaded()
        .clickButton('Close') 

        .clickMenuScreen('Inventory UOM','Screen')
        .waitUntilLoaded()
        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('')
        .verifyData('Text Field','UnitMeasure','Test_10 LB bag - Updated')
        .verifyData('Text Field','Symbol','Test_10 LB bag - Updated')
        .verifyGridData('Conversion', 2, 'colConversionStockUOM', 'KG')
        .verifyGridData('Conversion', 2, 'colConversionToStockUOM', '4.53592')
        .clickButton('Close')
        .clearTextFilter('FilterGrid')
        //endregion

        /*====================================== Scenario 4: Check Required Fields ======================================*/
        //region
        .displayText('===== Scenario 4: Check Required Fields =====')
        .clickMenuScreen('Inventory UOM','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .clickButton('Save')
        .clickButton('Close')
        //endregion

        /*====================================== Scenario 5. Add duplicate Inventory UOM ======================================*/
        .displayText('===== Scenario 5. Add duplicate Inventory UOM  =====')
        .clickMenuScreen('Inventory UOM','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
        .enterData('Text Field','UnitMeasure','Test_LB')
        .enterData('Text Field','Symbol','Test_LB')
        .selectComboBoxRowNumber('UnitType',6,0)
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyMessageBox('iRely i21','Unit Measure must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close') 
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('no')
        //endregion


        .done();

})