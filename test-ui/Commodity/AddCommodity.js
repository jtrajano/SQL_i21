StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add new Commodity with No UOM and Attribute
        .displayText('===== Scenario 1: Add new Commodity with No UOM and Attribute =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .clickButton('New')
        .waitTillLoaded('iccommodity','')
        .enterData('textbox','CommodityCode','AAA - Commodity 1')
        .enterData('textbox','Description','Commodity with No UOM and Attribute')
        .clickCheckBox('ExchangeTraded',true)
        .enterData('textbox','DecimalsOnDpr','6.00')
        .enterData('textbox','ConsolidateFactor','6.00')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 2: Add new Commodity with UOM but NO Attribute setup
        .displayText('===== Scenario 2: Add new Commodity with UOM but NO Attribute setup =====')
        .clickButton('New')
        .waitTillLoaded('iccommodity','')
        .enterData('textbox','CommodityCode','AAA - Commodity 2')
        .enterData('textbox','Description','Commodity with UOM and No Attribute Setup')
        .clickCheckBox('ExchangeTraded',true)
        .enterData('textbox','DecimalsOnDpr','6.00')
        .enterData('textbox','ConsolidateFactor','6.00')
        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','LB','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
        .clickGridCheckBox('Uom', 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .verifyGridData('Uom', 0, 'colUOMUnitQty', '1')
        .verifyGridData('Uom', 1, 'colUOMUnitQty', '50')
        .verifyGridData('Uom', 2, 'colUOMUnitQty', '56')
        .verifyGridData('Uom', 3, 'colUOMUnitQty', '55.1156')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 3: Add new Commodity with UOM and Attribute setup
        .displayText('===== Scenario 3: Add new Commodity with UOM and Attribute setup =====')
        .clickButton('New')
        .waitTillLoaded('iccommodity','')
        .enterData('textbox','CommodityCode','AAA - Commodity 3')
        .enterData('textbox','Description','Commodity with UOM and Attribute Setup')
        .clickCheckBox('ExchangeTraded',true)
        .enterData('textbox','DecimalsOnDpr','6.00')
        .enterData('textbox','ConsolidateFactor','6.00')
        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','LB','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
        .clickGridCheckBox('Uom', 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .verifyGridData('Uom', 0, 'colUOMUnitQty', '1')
        .verifyGridData('Uom', 1, 'colUOMUnitQty', '50')
        .verifyGridData('Uom', 2, 'colUOMUnitQty', '56')
        .verifyGridData('Uom', 3, 'colUOMUnitQty', '55.1156')

        .clickTab('Attribute')
        .enterGridData('Origin', 0, 'strDescription', 'Test Origin')
        .enterGridData('ProductType', 0, 'strDescription', 'Test Product Type')
        .enterGridData('Region', 0, 'strDescription', 'Test Region')
        .enterGridData('ClassVariant', 0, 'strDescription', 'Test Class and Variant')
        .enterGridData('Season', 0, 'strDescription', 'Test Season')
        .enterGridData('Grade', 0, 'strDescription', 'Test Grade')
        .enterGridData('ProductLine', 0, 'strDescription', 'Test Product Line')
        .clickGridCheckBox('ProductLine', 'strDescription', 'Test Product Line', 'ysnDeltaHedge', true)
        .enterGridData('ProductLine', 0, 'dblDeltaPercent', '10')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 4: Update Commodity
        .displayText('===== Scenario 4: Update Commodity =====')
        .selectSearchRowNumber(11)
        .clickButton('OpenSelected')
        .waitTillLoaded('iccommodity','')
        .enterData('textbox','Description','Updated Commodity')
        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','LB','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
        .clickGridCheckBox('Uom', 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .verifyGridData('Uom', 0, 'colUOMUnitQty', '1')
        .verifyGridData('Uom', 1, 'colUOMUnitQty', '50')
        .verifyGridData('Uom', 2, 'colUOMUnitQty', '56')
        .verifyGridData('Uom', 3, 'colUOMUnitQty', '55.1156')
        .verifyStatusMessage('Edited')
        .clickButton('Save').wait(1500)
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .selectSearchRowNumber(11)
        .clickButton('OpenSelected')
        .waitTillLoaded('iccommodity','')
        .verifyData('textbox','Description','Updated Commodity')
        .verifyGridData('Uom', 0, 'colUOMUnitQty', '1')
        .verifyGridData('Uom', 1, 'colUOMUnitQty', '50')
        .verifyGridData('Uom', 2, 'colUOMUnitQty', '56')
        .verifyGridData('Uom', 3, 'colUOMUnitQty', '55.1156')
        .clickButton('Close')
        //endregion


        //region Scenario 5: Check Required Fields
        .displayText('===== Scenario 5: Check Required Fields =====')
        .clickButton('New')
        .waitTillLoaded('iccommodity','')
        .clickButton('Save')
        .clickButton('Close').wait(500)
        //endregion

        //region Scenario 6: Save Duplicate Commodity Code
        .displayText('===== Scenario 6: Save Duplicate Commodity Code =====')
        .clickButton('New')
        .waitTillLoaded('iccommodity','')
        .enterData('textbox','CommodityCode','AAA - Commodity 1')
        .enterData('textbox','Description','Commodity with No UOM and Attribute')
        .clickCheckBox('ExchangeTraded',true)
        .enterData('textbox','DecimalsOnDpr','6.00')
        .enterData('textbox','ConsolidateFactor','6.00')
        .clickButton('Save')
        .verifyMessageBox('iRely i21','Commodity Code must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('yes').wait(1000)
        .verifyMessageBox('iRely i21','Commodity Code must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .enterData('textbox','CommodityCode','AAA - Commodity 4')
        .clickButton('Save')
        .clickButton('Close')

        //endregion


        .done();

})