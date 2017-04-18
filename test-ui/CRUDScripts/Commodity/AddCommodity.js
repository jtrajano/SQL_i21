StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add new Commodity with No UOM and Attribute
        .displayText('===== Scenario 1: Add new Commodity with No UOM and Attribute =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','CommodityCode','AAA - Commodity 1')
        .enterData('Text Field','Description','Commodity with No UOM and Attribute')
        .clickCheckBox('ExchangeTraded',true)
        .clickButton('Save')
        .clickButton('Close')
        //endregion


        //region Scenario 2: Add new Commodity with UOM but NO Attribute setup
        .displayText('===== Scenario 2: Add new Commodity with UOM but NO Attribute setup =====')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','CommodityCode','AAA - Commodity 2')
        .enterData('Text Field','Description','Commodity with UOM and No Attribute Setup')
        .clickCheckBox('ExchangeTraded',true)
        .enterData('Text Field','DecimalsOnDpr','6.00')


        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','LB','strUnitMeasure')
        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','25 kg bag','strUnitMeasure')

        .verifyGridData('Uom', 1, 'colUOMCode', 'LB')
        .verifyGridData('Uom', 2, 'colUOMCode', '50 lb bag')
        .verifyGridData('Uom', 3, 'colUOMCode', 'Bushels')
        .verifyGridData('Uom', 4, 'colUOMCode', '25 kg bag')

        .verifyGridData('Uom', 1, 'colUOMUnitQty', 1)
        .verifyGridData('Uom', 2, 'colUOMUnitQty', 50)
        .verifyGridData('Uom', 3, 'colUOMUnitQty', 56)
        .verifyGridData('Uom', 4, 'colUOMUnitQty', 55.1156)



        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 3: Add new Commodity with UOM and Attribute setup
        .displayText('===== Scenario 3: Add new Commodity with UOM and Attribute setup =====')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','CommodityCode','AAA - Commodity 3')
        .enterData('Text Field','Description','Commodity with UOM and Attribute Setup')
        .clickCheckBox('ExchangeTraded',true)
        .enterData('Text Field','DecimalsOnDpr','6.00')

        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','LB','strUnitMeasure')
        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','25 kg bag','strUnitMeasure')

        .verifyGridData('Uom', 1, 'colUOMCode', 'LB')
        .verifyGridData('Uom', 2, 'colUOMCode', '50 lb bag')
        .verifyGridData('Uom', 3, 'colUOMCode', 'Bushels')
        .verifyGridData('Uom', 4, 'colUOMCode', '25 kg bag')

        .verifyGridData('Uom', 1, 'colUOMUnitQty', 1)
        .verifyGridData('Uom', 2, 'colUOMUnitQty', 50)
        .verifyGridData('Uom', 3, 'colUOMUnitQty', 56)
        .verifyGridData('Uom', 4, 'colUOMUnitQty', 55.1156)


        .clickTab('Attribute')
        .enterGridData('ProductType', 1, 'strDescription', 'Test Product Type')
        .enterGridData('Region', 1, 'strDescription', 'Test Region')
        .enterGridData('ClassVariant', 1, 'strDescription', 'Test Class and Variant')
        .enterGridData('Season', 1, 'strDescription', 'Test Season')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 4: Update Commodity
        .displayText('===== Scenario 4: Update Commodity =====')
        .doubleClickSearchRowValue('AAA - Commodity 1', 'strOrderType', 1)
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','Description','Updated Commodity')

        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','LB','strUnitMeasure')
        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','25 kg bag','strUnitMeasure')

        .verifyGridData('Uom', 1, 'colUOMCode', 'LB')
        .verifyGridData('Uom', 2, 'colUOMCode', '50 lb bag')
        .verifyGridData('Uom', 3, 'colUOMCode', 'Bushels')
        .verifyGridData('Uom', 4, 'colUOMCode', '25 kg bag')

        .verifyGridData('Uom', 1, 'colUOMUnitQty', 1)
        .verifyGridData('Uom', 2, 'colUOMUnitQty', 50)
        .verifyGridData('Uom', 3, 'colUOMUnitQty', 56)
        .verifyGridData('Uom', 4, 'colUOMUnitQty', 55.1156)
        
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .doubleClickSearchRowValue('AAA - Commodity 1', 'strOrderType', 1)
        .waitUntilLoaded('iccommodity')
        .verifyData('Text Field','Description','Updated Commodity')

        .verifyGridData('Uom', 1, 'colUOMCode', 'LB')
        .verifyGridData('Uom', 2, 'colUOMCode', '50 lb bag')
        .verifyGridData('Uom', 3, 'colUOMCode', 'Bushels')
        .verifyGridData('Uom', 4, 'colUOMCode', '25 kg bag')

        .verifyGridData('Uom', 1, 'colUOMUnitQty', 1)
        .verifyGridData('Uom', 2, 'colUOMUnitQty', 50)
        .verifyGridData('Uom', 3, 'colUOMUnitQty', 56)
        .verifyGridData('Uom', 4, 'colUOMUnitQty', 55.1156)
        
        .clickButton('Close')
        //endregion


        //region Scenario 5: Check Required Fields
        .displayText('===== Scenario 5: Check Required Fields =====')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .clickButton('Save')
        .clickButton('Close')
        //endregion

        //region Scenario 6: Save Duplicate Commodity Code
        .displayText('===== Scenario 6: Save Duplicate Commodity Code =====')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
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