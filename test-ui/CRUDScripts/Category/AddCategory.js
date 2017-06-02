StartTest (function (t) {
new iRely.FunctionalTest().start(t)

        /*====================================== Scenario 1: Add New Category - Inventory Type ======================================*/
        //region
        .displayText('Scenario 1: Add New Category - Inventory Type')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Inventory Category - 001')
        .waitUntilLoaded()
        .continueIf({
            expected: true,
            actual: function (win,next) {
                new iRely.FunctionalTest().start(t, next)
                return win.down('#grdSearch').store.getCount() == 0;
            },

            success: function(next){
                new iRely.FunctionalTest().start(t, next)
                    .clickMenuScreen('Categories','Screen')
                    .clickButton('New')
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Inventory Category - 001')
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
                    .waitUntilLoaded()
                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 1: Add New Category - Inventory Type Done =====')
        //endregion



        /*====================================== Scenario 2: Add New Category - Bundle ======================================*/
        //region
        .displayText('===== Scenario 2: Add New Category - Bundle =====')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Bundle Category - 001')
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
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Bundle Category - 001')
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

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 2: Add New Category - Bundle Done=====')
        //endregion




        /*====================================== Scenario 2: Add New Category - Kit ======================================*/
        //region
        .displayText('===== Scenario 3: Add New Category - Kit =====')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Kit Category - 001')
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
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Kit Category - 001')
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
                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 3: Add New Category - Kit Done=====')
        //endregion



        /*====================================== Scenario 4: Add New Category - Finished Good Type ======================================*/
        //region
        .displayText('===== Scenario 4: Add New Category - Finished Good Type =====')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Finished Good Category - 001')
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
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Finished Good Category - 001')
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

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 4: Add New Category - Finished Good Type Done =====')
        //endregion


        /*====================================== Scenario 5: Add New Category - Non Inventory ======================================*/
        //region
        .displayText('===== Scenario 5: Add New Category - Non Inventory =====')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Non Inventory Category - 001')
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
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Non Inventory Category - 001')
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
                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 5: Add New Category - Non Inventory Done =====')
        //endregion



        /*====================================== Scenario 6: Add New Category - Other Charge Type ======================================*/
        //region
        .displayText('===== Scenario 6: Add New Category - Other Charge Type =====')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Other Charge Category - 001')
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
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Other Charge Category - 001')
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
                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 6: Add New Category - Other Charge Type Done=====')
        //endregion



        /*====================================== Scenario 7: Add New Category - Raw Material Type ======================================*/
        //region
        .displayText('===== Scenario 7: Add New Category - Raw Material Type =====')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Raw Material Category - 001')
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
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Raw Material Category - 001')
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

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 7: Add New Category - Raw Material Type Done =====')
        //endregion


        /*====================================== Scenario 8: Add New Category - Service ======================================*/
        //region
        .displayText('===== Scenario 8: Add New Category - Service =====')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Service Category - 001')
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
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Service Category - 001')
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

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 8: Add New Category - Service Done=====')
        //endregion





        /*======================================  Scenario 9: Add New Category - Software ======================================*/
        //region
        .displayText('===== Scenario 9: Add New Category - Software =====')
        .clickMenuScreen('Categories','Screen')
        .filterGridRecords('Search', 'FilterGrid', 'Software Category - 001')
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
                    .waitUntilLoaded('iccategory')
                    .enterData('Text Field','CategoryCode','Software Category - 001')
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
                    //endregion

                    .done();
            },
            continueOnFail: true
        })
        .clearTextFilter('FilterGrid')
        .displayText('===== Scenario 9: Add New Category - Software Done=====')
        //endregion


        /*======================================  Scenario 10: Update Category ======================================*/
        .displayText('===== Scenario 10: Update Category =====')
        .clickMenuScreen('Categories','Screen')
        .waitUntilLoaded()
        .doubleClickSearchRowValue('Inventory Category - 001', 'strCategoryCode', 1)
        .waitUntilLoaded()
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