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

        .enterUOMGridData('Uom', 1, 'colUnitQty', 'strUnitMeasure', 1, 'LB')
        .enterUOMGridData('Uom', 2, 'colUnitQty', 'strUnitMeasure', 50, '50 lb bag')
        .enterUOMGridData('Uom', 3, 'colUnitQty', 'strUnitMeasure', 56, 'Bushels')
        .enterUOMGridData('Uom', 4, 'colUnitQty', 'strUnitMeasure', 55.1156, '25 kg bag')

        .clickGridCheckBox('Uom',1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)

		.verifyUOMGridData('Uom', 1, 'colUnitQty', 1, 'LB', 'equal')
		.verifyUOMGridData('Uom', 2, 'colUnitQty', 50, '50 lb bag', 'equal')
		.verifyUOMGridData('Uom', 3, 'colUnitQty', 56, 'Bushels', 'equal')
        .verifyUOMGridData('Uom', 4, 'colUnitQty', 55.1156, '25 kg bag', 'equal')
        
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
        
        .enterUOMGridData('Uom', 1, 'colUnitQty', 'strUnitMeasure', 1, 'LB')
        .enterUOMGridData('Uom', 2, 'colUnitQty', 'strUnitMeasure', 50, '50 lb bag')
        .enterUOMGridData('Uom', 3, 'colUnitQty', 'strUnitMeasure', 56, 'Bushels')
        .enterUOMGridData('Uom', 4, 'colUnitQty', 'strUnitMeasure', 55.1156, '25 kg bag')

        .clickGridCheckBox('Uom',1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)

		.verifyUOMGridData('Uom', 1, 'colUnitQty', 1, 'LB', 'equal')
		.verifyUOMGridData('Uom', 2, 'colUnitQty', 50, '50 lb bag', 'equal')
		.verifyUOMGridData('Uom', 3, 'colUnitQty', 56, 'Bushels', 'equal')
        .verifyUOMGridData('Uom', 4, 'colUnitQty', 55.1156, '25 kg bag', 'equal')

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
        
        .enterUOMGridData('Uom', 1, 'colUnitQty', 'strUnitMeasure', 1, 'LB')
        .enterUOMGridData('Uom', 2, 'colUnitQty', 'strUnitMeasure', 50, '50 lb bag')
        .enterUOMGridData('Uom', 3, 'colUnitQty', 'strUnitMeasure', 56, 'Bushels')
        .enterUOMGridData('Uom', 4, 'colUnitQty', 'strUnitMeasure', 55.1156, '25 kg bag')

        .clickGridCheckBox('Uom',1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)

		.verifyUOMGridData('Uom', 1, 'colUnitQty', 1, 'LB', 'equal')
		.verifyUOMGridData('Uom', 2, 'colUnitQty', 50, '50 lb bag', 'equal')
		.verifyUOMGridData('Uom', 3, 'colUnitQty', 56, 'Bushels', 'equal')
        .verifyUOMGridData('Uom', 4, 'colUnitQty', 55.1156, '25 kg bag', 'equal')
        
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .doubleClickSearchRowValue('AAA - Commodity 1', 'strOrderType', 1)
        .waitUntilLoaded('iccommodity')
        .verifyData('Text Field','Description','Updated Commodity')
        
        .verifyUOMGridData('Uom', 1, 'colUnitQty', 1, 'LB', 'equal')
		.verifyUOMGridData('Uom', 2, 'colUnitQty', 50, '50 lb bag', 'equal')
		.verifyUOMGridData('Uom', 3, 'colUnitQty', 56, 'Bushels', 'equal')
        .verifyUOMGridData('Uom', 4, 'colUnitQty', 55.1156, '25 kg bag', 'equal')
        
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