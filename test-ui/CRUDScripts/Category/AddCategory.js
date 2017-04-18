StartTest (function (t) {
new iRely.FunctionalTest().start(t)

        //region Scenario 1: Add New Category - Inventory Type
        .displayText('===== Scenario 1: Add New Category - Inventory Type =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Categories','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Inventory Category')
        .enterData('Text Field','Description','Test Inventory Category')
        .selectComboBoxRowNumber('InventoryType',2,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Inventory')
        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Cost of Goods')
        .verifyGridData('GlAccounts', 4, 'colAccountCategory', 'Sales Account')
        .verifyGridData('GlAccounts', 5, 'colAccountCategory', 'Inventory In-Transit')
        .verifyGridData('GlAccounts', 6, 'colAccountCategory', 'Inventory Adjustment')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 1: Add New Category - Inventory Type Done =====')
        //endregion


        //region Scenario 2: Add New Category - Bundle
        .displayText('===== Scenario 2: Add New Category - Bundle =====')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Bundle Category')
        .enterData('Text Field','Description','Test Bundle Category')
        .selectComboBoxRowNumber('InventoryType',1,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Use Tax Gasoline','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'Sales Account')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '40000-0000-001', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 2: Add New Category - Bundle Done=====')
        //endregion


        //region Scenario 3: Add New Category - Kit
        .displayText('===== Scenario 3: Add New Category - Kit =====')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Kit Category')
        .enterData('Text Field','Description','Test Kit Category')
        .selectComboBoxRowNumber('InventoryType',3,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'Sales Account')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '40000-0000-001', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 3: Add New Category - Kit Done=====')
        //endregion

        //region Scenario 4: Add New Category - Finished Good Type
        .displayText('===== Scenario 4: Add New Category - Finished Good Type =====')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Finished Good Category')
        .enterData('Text Field','Description','Test Finished Good Category')
        .selectComboBoxRowNumber('InventoryType',4,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'Inventory')
        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Cost of Goods')
        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Sales Account')
        .verifyGridData('GlAccounts', 4, 'colAccountCategory', 'Inventory In-Transit')
        .verifyGridData('GlAccounts', 5, 'colAccountCategory', 'Inventory Adjustment')
        .verifyGridData('GlAccounts', 6, 'colAccountCategory', 'Work In Progress')

        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '16000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '50000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '40010-0001-006', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '16050-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16040-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16060-0000-000', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 4: Add New Category - Finished Good Type Done =====')
        //endregion

        //region Scenario 5: Add New Category - Non Inventory
        .displayText('===== Scenario 5: Add New Category - Non Inventory =====')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Non Inventory Category')
        .enterData('Text Field','Description','Test Non Inventory Category')
        .selectComboBoxRowNumber('InventoryType',5,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'General')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '10003-0000-000', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 5: Add New Category - Non Inventory Done =====')
        //endregion


        //region Scenario 6: Add New Category - Other Charge Type
        .displayText('===== Scenario 6: Add New Category - Other Charge Type =====')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Other Charge Category')
        .enterData('Text Field','Description','Test Inventory Category')
        .selectComboBoxRowNumber('InventoryType',6,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Other Charge Income')
        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Other Charge Expense')

        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '10003-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '10003-0007-000', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 6: Add New Category - Other Charge Type Done=====')
        //endregion


        //region Scenario 7: Add New Category - Raw Material Type
        .displayText('===== Scenario 7: Add New Category - Raw Material Type =====')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Raw Material Category')
        .enterData('Text Field','Description','Test Raw Material Category')
        .selectComboBoxRowNumber('InventoryType',7,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Inventory')
        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Cost of Goods')
        .verifyGridData('GlAccounts', 4, 'colAccountCategory', 'Sales Account')
        .verifyGridData('GlAccounts', 5, 'colAccountCategory', 'Inventory In-Transit')
        .verifyGridData('GlAccounts', 6, 'colAccountCategory', 'Inventory Adjustment')
        .verifyGridData('GlAccounts', 7, 'colAccountCategory', 'Work In Progress')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 7, 'strAccountId', '16060-0000-000', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 7: Add New Category - Raw Material Type Done =====')
        //endregion


        //region Scenario 8: Add New Category - Service
        .displayText('===== Scenario 8: Add New Category - Service =====')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Service Category')
        .enterData('Text Field','Description','Test Non Inventory Category')
        .selectComboBoxRowNumber('InventoryType',8,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'General')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '10003-0000-000', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 8: Add New Category - Service Done=====')
        //endregion


        //region Scenario 9: Add New Category - Software
        .displayText('===== Scenario 9: Add New Category - Software =====')
        .clickButton('New')
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','CategoryCode','Software Category')
        .enterData('Text Field','Description','Test Non Inventory Category')
        .selectComboBoxRowNumber('InventoryType',9,0)
        .selectComboBoxRowNumber('CostingMethod',1,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')

        .displayText('===== Setup GL Accounts=====')
        .clickTab('GL Accounts')
        .clickButton('AddRequired')
        .waitUntilLoaded()
        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'General')
        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Maintenance Sales')
        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '10003-0000-000', 'strAccountId')
        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '42002-0007-000', 'strAccountId')

        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .displayText('===== Scenario 9: Add New Category - Software Done=====')
        //endregion


        //region Scenario 10: Update Category
        .displayText('===== Scenario 10: Update Category =====')
        .clickMenuScreen('Categories','Screen')
        .doubleClickSearchRowValue('Inventory Category', 'strCategoryCode', 1)
        .waitUntilLoaded('iccategory')
        .enterData('Text Field','Description','Updated Test Category Code')
        .selectComboBoxRowNumber('CostingMethod',2,0)
        .selectGridComboBoxRowValue('Tax',1,'strTaxClass','Checkoff','strTaxClass')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')


        .selectSearchRowNumber(1)
        .clickButton('OpenSelected')
        .waitUntilLoaded('iccategory')
        .verifyData('Text Field','Description','Updated Test Category Code')
        .clickButton('Close')
        .displayText('===== Scenario 10: Update Category Done=====')
        //endregion


        .done();

})