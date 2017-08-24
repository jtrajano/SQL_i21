StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //region
        .displayText('===== Scenario 1. Add stock UOM first  =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Inventory UOM','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Test_Pounds')
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
                    .enterData('Text Field','UnitMeasure','Test_Pounds')
                    .enterData('Text Field','Symbol','Test_Pounds')
                    .selectComboBoxRowNumber('UnitType',6,0)
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .displayText('===== Add stock UOM first Done  =====')
        //endregion


        //region
        .displayText('===== Scenario 2. Add Conversion UOMs =====')
        .clickMenuScreen('Inventory UOM','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Test_50 lb bag')
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
                    .enterData('Text Field','UnitMeasure','Test_50 lb bag')
                    .enterData('Text Field','Symbol','Test_50 lb bag')

                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM','Test_Pounds','strUnitMeasure',1)
//                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    .waitUntilLoaded()
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '50 ')
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

        //add another conversion
        .filterGridRecords('Search', 'FilterGrid', 'Test_Bushels')
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
                    .enterData('Text Field','UnitMeasure','Test_Bushels')
                    .enterData('Text Field','Symbol','Test_Bushels')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM','Test_Pounds','strUnitMeasure',1)
//                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '56 ')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //add another conversion
        .filterGridRecords('Search', 'FilterGrid', 'Test_KG')
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
                    .enterData('Text Field','UnitMeasure','Test_KG')
                    .enterData('Text Field','Symbol','Test_KG')
                    .selectComboBoxRowNumber('UnitType',5,0)
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM','Test_Pounds','strUnitMeasure',1)
//                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '2.20462')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //add another conversion
        .filterGridRecords('Search', 'FilterGrid', 'Test_60 KG bags')
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
                    .enterData('Text Field','UnitMeasure','Test_60 KG bags')
                    .enterData('Text Field','Symbol','Test_60 KG bags')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM','Test_Pounds','strUnitMeasure',1)
//                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '132.2772')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()

        //add another conversion
        .filterGridRecords('Search', 'FilterGrid', 'Test_25 KG bags')
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
                    .enterData('Text Field','UnitMeasure','Test_25 KG bags')
                    .enterData('Text Field','Symbol','Test_25 KG bags')
                    .selectComboBoxRowNumber('UnitType',7,0)
                    .selectGridComboBoxRowValue('Conversion',1,'colOtherUOM','Test_Pounds','strUnitMeasure',1)
//                    .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',7)
                    .enterGridData('Conversion', 1, 'dblConversionToStock', '55.1155')
                    .verifyStatusMessage('Edited')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .waitUntilLoaded()
        .displayText('===== Add Conversion UOM Done  =====')
        //endregion


        //Scenario 1: Add new Commodity with No UOM and Attribute
        .displayText('===== Scenario 1: Add new Commodity with No UOM and Attribute =====')
        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'AAA - Commodity 1')
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
                    .enterData('Text Field','CommodityCode','AAA - Commodity 1')
                    .enterData('Text Field','Description','Commodity with No UOM and Attribute')
                    .clickCheckBox('ExchangeTraded',true)
                    .clickButton('Save')
                    .clickButton('Close')
                    .done();
            },
            continueOnFail: true
        })



        //region Scenario 2: Add new Commodity with UOM but NO Attribute setup
        .displayText('===== Scenario 2: Add new Commodity with UOM but NO Attribute setup =====')
        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'AAA - Commodity 2')
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
                    .enterData('Text Field','CommodityCode','AAA - Commodity 2')
                    .enterData('Text Field','Description','Commodity with UOM and No Attribute Setup')
                    .clickCheckBox('ExchangeTraded',true)
                    .enterData('Text Field','DecimalsOnDpr','6.00')


                    .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Test_Pounds','strUnitMeasure')
                    .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'Test_Pounds', 'ysnStockUnit', true)
                    .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','Test_50 lb bag','strUnitMeasure')
                    .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Test_Bushels','strUnitMeasure')
                    .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','Test_25 KG bags','strUnitMeasure')

                    .verifyGridData('Uom', 1, 'colUOMCode', 'Test_Pounds')
                    .verifyGridData('Uom', 2, 'colUOMCode', 'Test_50 lb bag')
                    .verifyGridData('Uom', 3, 'colUOMCode', 'Test_Bushels')
                    .verifyGridData('Uom', 4, 'colUOMCode', 'Test_25 KG bags')

                    .verifyGridData('Uom', 1, 'colUOMUnitQty', 1)
                    .verifyGridData('Uom', 2, 'colUOMUnitQty', 50)
                    .verifyGridData('Uom', 3, 'colUOMUnitQty', 56)
                    .verifyGridData('Uom', 4, 'colUOMUnitQty', 55.1155)



                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .done();
            },
            continueOnFail: true
        })



        //region Scenario 3: Add new Commodity with UOM and Attribute setup
        .displayText('===== Scenario 3: Add new Commodity with UOM and Attribute setup =====')
        .clickMenuScreen('Commodities','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'AAA - Commodity 3')
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
                    .enterData('Text Field','CommodityCode','AAA - Commodity 3')
                    .enterData('Text Field','Description','Commodity with UOM and Attribute Setup')
                    .clickCheckBox('ExchangeTraded',true)
                    .enterData('Text Field','DecimalsOnDpr','6.00')

                    .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Test_Pounds','strUnitMeasure')
                    .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'Test_Pounds', 'ysnStockUnit', true)
                    .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','Test_50 lb bag','strUnitMeasure')
                    .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Test_Bushels','strUnitMeasure')
                    .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','Test_25 KG bags','strUnitMeasure')

                    .verifyGridData('Uom', 1, 'colUOMCode', 'Test_Pounds')
                    .verifyGridData('Uom', 2, 'colUOMCode', 'Test_50 lb bag')
                    .verifyGridData('Uom', 3, 'colUOMCode', 'Test_Bushels')
                    .verifyGridData('Uom', 4, 'colUOMCode', 'Test_25 KG bags')

                    .verifyGridData('Uom', 1, 'colUOMUnitQty', 1)
                    .verifyGridData('Uom', 2, 'colUOMUnitQty', 50)
                    .verifyGridData('Uom', 3, 'colUOMUnitQty', 56)
                    .verifyGridData('Uom', 4, 'colUOMUnitQty', 55.1155)


                    .clickTab('Attribute')
                    .enterGridData('ProductType', 1, 'strDescription', 'Test Product Type')
                    .enterGridData('Region', 1, 'strDescription', 'Test Region')
                    .enterGridData('ClassVariant', 1, 'strDescription', 'Test Class and Variant')
                    .enterGridData('Season', 1, 'strDescription', 'Test Season')
                    .clickButton('Save')
                    .waitUntilLoaded()
                    .verifyStatusMessage('Saved')
                    .clickButton('Close')
                    .done();
            },
            continueOnFail: true
        })

        .waitUntilLoaded()
        //region Scenario 4: Update Commodity
        .displayText('===== Scenario 4: Update Commodity =====')
        .doubleClickSearchRowValue('AAA - Commodity 1', 'strOrderType', 1)
        .waitUntilLoaded('')
        .enterData('Text Field','Description','Updated Commodity')

        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Test_Pounds','strUnitMeasure')
        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'Test_Pounds', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','Test_50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Test_Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','Test_25 KG bags','strUnitMeasure')

        .verifyGridData('Uom', 1, 'colUOMCode', 'Test_Pounds')
        .verifyGridData('Uom', 2, 'colUOMCode', 'Test_50 lb bag')
        .verifyGridData('Uom', 3, 'colUOMCode', 'Test_Bushels')
        .verifyGridData('Uom', 4, 'colUOMCode', 'Test_25 KG bags')

        .verifyGridData('Uom', 1, 'colUOMUnitQty', 1)
        .verifyGridData('Uom', 2, 'colUOMUnitQty', 50)
        .verifyGridData('Uom', 3, 'colUOMUnitQty', 56)
        .verifyGridData('Uom', 4, 'colUOMUnitQty', 55.1155)
        
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .doubleClickSearchRowValue('AAA - Commodity 1', 'strOrderType', 1)
        .waitUntilLoaded('')
        .verifyData('Text Field','Description','Updated Commodity')
        .clickButton('Close')
        //endregion


        //region Scenario 5: Check Required Fields
        .displayText('===== Scenario 5: Check Required Fields =====')
        .clickButton('New')
        .waitUntilLoaded('')
        .clickButton('Save')
        .clickButton('Close')
        //endregion

        //region Scenario 6: Save Duplicate Commodity Code
        .displayText('===== Scenario 6: Save Duplicate Commodity Code =====')
        .clickButton('New')
        .waitUntilLoaded('')
        .enterData('Text Field','CommodityCode','AAA - Commodity 1')
        .enterData('Text Field','Description','Commodity with No UOM and Attribute')
        .clickCheckBox('ExchangeTraded',true)
        .clickButton('Save')
        .clickMessageBoxButton('ok')
        .clickButton('Close')
        .clickMessageBoxButton('yes')
        .waitUntilLoaded()
        .clickMessageBoxButton('ok')
        .enterData('Text Field','CommodityCode','AAA - Commodity 4')
        .clickButton('Save')
        .clickButton('Close')

        //endregion


        .done();

})