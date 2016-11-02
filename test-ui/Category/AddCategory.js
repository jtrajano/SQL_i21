StartTest (function (t) {
    new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add New Category - Inventory Type
        .displayText('===== Scenario 1: Add New Category - Inventory Type =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','001 - Inventory Category')
        .enterData('Text Field','Description','Test Inventory Category')
        .selectComboBoxRowNumber('InventoryType',2,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','LB','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '50')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '56')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 2: Add New Category - Bundle
        .displayText('===== Scenario 2: Add New Category - Bundle =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','002 - Bundle Category')
        .enterData('Text Field','Description','Test Bundle Category')
        .selectComboBoxRowNumber('InventoryType',1,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Use Tax Gasoline','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Each','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 'strUnitMeasure', 'Each', 'ysnStockUnit', true)
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 3: Add New Category - Kit
        .displayText('===== Scenario 3: Add New Category - Kit =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','003 - Kit Category')
        .enterData('Text Field','Description','Test Kit Category')
        .selectComboBoxRowNumber('InventoryType',3,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Each','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 'strUnitMeasure', 'Each', 'ysnStockUnit', true)
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion

        //region Scenario 4: Add New Category - Finished Good Type
        .displayText('===== Scenario 4: Add New Category - Finished Good Type =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','004 - Finished Good Category')
        .enterData('Text Field','Description','Test Finished Good Category')
        .selectComboBoxRowNumber('InventoryType',4,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','KG','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','60 Kg Bag','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 'strUnitMeasure', 'KG', 'ysnStockUnit', true)
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '60')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion

        //region Scenario 5: Add New Category - Non Inventory
        .displayText('===== Scenario 5: Add New Category - Non Inventory =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','005 - Non Inventory Category')
        .enterData('Text Field','Description','Test Non Inventory Category')
        .selectComboBoxRowNumber('InventoryType',5,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Each','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 'strUnitMeasure', 'Each', 'ysnStockUnit', true)
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 6: Add New Category - Other Charge Type
        .displayText('===== Scenario 6: Add New Category - Other Charge Type =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','006 - Other Charge Category')
        .enterData('Text Field','Description','Test Inventory Category')
        .selectComboBoxRowNumber('InventoryType',6,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','LB','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .enterGridData('UnitOfMeasure', 1, 'dblUnitQty', '1')
        .enterGridData('UnitOfMeasure', 2, 'dblUnitQty', '1')
        .enterGridData('UnitOfMeasure', 3, 'dblUnitQty', '1')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 7: Add New Category - Raw Material Type
        .displayText('===== Scenario 7: Add New Category - Raw Material Type =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','007 - Raw Material Category')
        .enterData('Text Field','Description','Test Raw Material Category')
        .selectComboBoxRowNumber('InventoryType',7,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','LB','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '50')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '56')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 8: Add New Category - Service
        .displayText('===== Scenario 8: Add New Category - Service =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','008 - Service Category')
        .enterData('Text Field','Description','Test Non Inventory Category')
        .selectComboBoxRowNumber('InventoryType',8,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Each','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 'strUnitMeasure', 'Each', 'ysnStockUnit', true)
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 9: Add New Category - Software
        .displayText('===== Scenario 9: Add New Category - Software =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','009 - Software Category')
        .enterData('Text Field','Description','Test Non Inventory Category')
        .selectComboBoxRowNumber('InventoryType',9,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Each','strUnitMeasure')
        .clickGridCheckBox('UnitOfMeasure', 'strUnitMeasure', 'Each', 'ysnStockUnit', true)
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        //endregion


        //region Scenario 10: Update Category
        .displayText('===== Scenario 4: Update Category =====')
        .clickMenuScreen('Categories','Screen')
        .doubleClickSearchRowValue('001 - Inventory Category', 'strCategoryCode', 1)
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','Description','Updated Test Category Code')
        .selectComboBoxRowNumber('CostingMethod',2,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','25 kg bag','strUnitMeasure')
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '50')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '55.1156')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitTillLoaded('iccategory','')
        .verifyData('Text Field','Description','Updated Test Category Code')
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '50')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '55.1156')
        .clickButton('Close')
        //endregion


        //region Scenario 11: Check Required Fields
        .displayText('===== Scenario 5: Check Required Fields =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .clickButton('Save')
        .clickButton('Close')
        //endregion


        //region Scenario 12: Save Duplicate Category Code
        .displayText('===== Scenario 12: Save Duplicate Category Code =====')
        .clickButton('New')
        .waitTillLoaded('iccategory','')
        .enterData('Text Field','CategoryCode','001 - Inventory Category')
        .enterData('Text Field','Description','Test Inventory Category')
        .selectComboBoxRowNumber('InventoryType',2,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .clickButton('Save')
        .verifyMessageBox('iRely i21','Category must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .clickButton('Close')
        .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
        .clickMessageBoxButton('yes')
        .waitTillLoaded()
        .verifyMessageBox('iRely i21','Category must be unique.','ok','error')
        .clickMessageBoxButton('ok')
        .enterData('Text Field','CategoryCode','010 - Inventory Category')
        .clickButton('Save')
        .clickButton('Close')


        .done();

})