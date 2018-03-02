Ext.define('Inventory.CommonIC', {
      /**
     * Add Inventory Item
     *
     * @param {String} item - Item Number of the Item
     *
     * @param {String} itemdesc - Item Description of the Item
     *
     * @param {Integer} lottrack - Lot Tracking( Yes Manual - '0' , Yes Serial - '1' and No - '2'
     *
     *@param {String} saleuom - Location Setup Sale UOM
     *
     * *@param {String} receiveuom - Location Receive Sale UOM
     *
     * @param {String} priceLC - Item Last Cost
     *
     * @param {String} priceLC - Item Standard Cost
     *
     *
     * @returns {iRely.TestEngine}
     */

    //Add Inventory Item Negative Inventory No
    addInventoryItem: function (t,next, item, itemdesc, category, commodity,lottrack, saleuom, receiveuom,priceLC, priceSC, priceAC) {
        new iRely.FunctionalTest().start(t, next)

            //.clickMenuFolder('Inventory','Folder')
            //.clickMenuScreen('Items','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .verifyScreenShown('icitem')

            .enterData('Text Field','ItemNo', item)
            .enterData('Text Field','Description', itemdesc)
            .selectComboBoxRowValue('Category', category, 'cboCategory',1)
            .selectComboBoxRowValue('Commodity', commodity, 'strCommodityCode',1)
            .selectComboBoxRowNumber('LotTracking', lottrack)

            .clickTab('Setup')
            .clickButton('AddRequiredAccounts')
            .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
            .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
            .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
            .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
            .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
            .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')

            .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')

            .addResult('======== Setup GL Accounts Successful ========')

            .clickTab('Location')
            .clickButton('AddLocation')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('Location',1,0)
//            .selectComboBoxRowNumber('SubLocation',4,0)
//            .selectComboBoxRowNumber('StorageLocation',1,0)
            .selectComboBoxRowValue('SubLocation', 'Raw Station', 'intSubLocationId',0)
            .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'intStorageLocationId',0)
            .selectComboBoxRowValue('IssueUom', saleuom, 'strUnitMeasure')
            .selectComboBoxRowValue('ReceiveUom', receiveuom, 'strUnitMeasure')
            .clickButton('Save')
            .waitUntilLoaded()
            .verifyStatusMessage('Saved')
            .clickButton('Close')

            .clickButton('AddLocation')
            .waitUntilLoaded('')
//            .selectComboBoxRowNumber('Location',2,0)
//            .selectComboBoxRowNumber('SubLocation',1,0)
//            .selectComboBoxRowNumber('StorageLocation',1,0)
            .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
            .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
            .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
            .selectComboBoxRowValue('IssueUom', saleuom, 'IssueUom',0)
            .selectComboBoxRowValue('ReceiveUom', receiveuom, 'ReceiveUom',0)
            .clickButton('Save')
            .waitUntilLoaded()
            .verifyStatusMessage('Saved')
            .clickButton('Close')

            .clickTab('Other')
            .clickCheckBox('TankRequired', true)
            .clickCheckBox('AvailableForTm', true)

            .displayText('===== Setup Item Pricing=====')
            .clickTab('Pricing')
            .waitUntilLoaded('').waitUntilLoaded('')
            .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
            .enterGridData('Pricing', 1, 'dblLastCost', priceLC)
            .enterGridData('Pricing', 1, 'dblStandardCost', priceSC)
            .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
            .enterGridData('Pricing', 1, 'dblAmountPercent', priceAC)

            .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
            .enterGridData('Pricing', 2, 'dblLastCost', priceLC)
            .enterGridData('Pricing', 2, 'dblStandardCost', priceSC)
            .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
            .enterGridData('Pricing', 2, 'dblAmountPercent', priceAC)
            .clickButton('Save')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            //.clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .displayText('===== Item Created =====')
            .done();

    },

    //Add Inventory Item Negative Inventory Yes
    addInventoryItemNegative: function (t,next, item, itemdesc, category, commodity,lottrack, saleuom, receiveuom,priceLC, priceSC, priceAC) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .verifyScreenShown('icitem')

            .enterData('Text Field','ItemNo', item)
            .enterData('Text Field','Description', itemdesc)
//            .selectComboBoxRowNumber('Category',9,0)
//            .selectComboBoxRowNumber('Commodity',12,0)
            .selectComboBoxRowValue('Category', category, 'cboCategory',1)
            .selectComboBoxRowValue('Commodity', commodity, 'strCommodityCode',1)
            .selectComboBoxRowNumber('LotTracking', lottrack)

            .clickTab('Setup')
            .clickButton('AddRequiredAccounts')
            .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
            .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
            .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
            .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
            .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
            .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')

            .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')

            .addResult('======== Setup GL Accounts Successful ========')

            .clickTab('Location')
            .clickButton('AddLocation')
            .waitUntilLoaded('icitemlocation')
            .selectComboBoxRowNumber('Location',1,0)
            .selectComboBoxRowNumber('SubLocation',4,0)
            .selectComboBoxRowNumber('StorageLocation',1,0)
            .selectComboBoxRowValue('SubLocation', 'Raw Station', 'intSubLocationId',0)
            .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'intStorageLocationId',0)
            .selectComboBoxRowValue('IssueUom', saleuom, 'strUnitMeasure')
            .selectComboBoxRowValue('ReceiveUom', receiveuom, 'strUnitMeasure')
            .selectComboBoxRowNumber('NegativeInventory',1,0)
            .clickButton('Save')
            .waitUntilLoaded()
            .verifyStatusMessage('Saved')
            .clickButton('Close')

            .clickButton('AddLocation')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('Location',2,0)
//            .selectComboBoxRowNumber('SubLocation',1,0)
//            .selectComboBoxRowNumber('StorageLocation',1,0)
            .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
            .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
            .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
            .selectComboBoxRowValue('IssueUom', saleuom, 'IssueUom',0)
            .selectComboBoxRowValue('ReceiveUom', receiveuom, 'ReceiveUom',0)
            .selectComboBoxRowNumber('NegativeInventory',1,0)
            .clickButton('Save')
            .waitUntilLoaded()
            .verifyStatusMessage('Saved')
            .clickButton('Close')

            .clickTab('Other')
            .clickCheckBox('TankRequired', true)
            .clickCheckBox('AvailableForTm', true)

            .displayText('===== Setup Item Pricing=====')
            .clickTab('Pricing')
            .waitUntilLoaded('')
            .verifyGridData('Pricing', 1, 'strLocationName', '0001-Fort Wayne')
            .enterGridData('Pricing', 1, 'dblLastCost', priceLC)
            .enterGridData('Pricing', 1, 'dblStandardCost', priceSC)
            .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
            .enterGridData('Pricing', 1, 'dblAmountPercent', priceAC)

            .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
            .enterGridData('Pricing', 2, 'dblLastCost', priceLC)
            .enterGridData('Pricing', 2, 'dblStandardCost', priceSC)
            .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
            .enterGridData('Pricing', 2, 'dblAmountPercent', priceAC)
            .clickButton('Save')
            .waitUntilLoaded()
            .verifyStatusMessage('Saved')
            .clickButton('Close')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .displayText('===== Item Created =====')
            .done();

    },





    /**
     * Add Commodity
     *
     * @param {String} commoditycode - Commodity Name
     *
     * @param {String} description - Commodity Descriptiion
     *
     */


    addCommodity: function (t,next, commoditycode, description) {
        new iRely.FunctionalTest().start(t, next)

            //region
            .displayText('===== Scenario 1. Add stock UOM first  =====')
            //.clickMenuFolder('Inventory','Folder')
            //.waitUntilLoaded()
            .clickMenuScreen('Inventory UOM','Screen')
            //.filterGridRecords('Search', 'From', commoditycode)
            .filterGridRecords('UOM', 'FilterGrid', 'Test_Pounds')
            .waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function (win,next) {
                    new iRely.FunctionalTest().start(t, next)
                    return win.down('#grdUOM').store.getCount() == 0;
                },

                success: function(next){
                     
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid')
                        .clickButton('InsertUOM')
                        .addFunction(function(next){
                            var win = Ext.WindowManager.getActive();
                            var recCount = win.down('#grdUOM').store.getCount();
                            new iRely.FunctionalTest().start(t, next)
                            .waitUntilLoaded().waitUntilLoaded()
                            .enterGridData('UOM', recCount, 'strUnitMeasure', 'Test_Pounds')
                            .enterGridData('UOM', recCount, 'strSymbol', 'Test_Pounds')
                            .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                            .clickButton('Save')
                            .waitUntilLoaded()
                            .verifyStatusMessage('Saved')
                            
                            .done()    
                    })
                        

                        .done()
                },
                continueOnFail: true
            })
            .clickButton('Close')
            .clearTextFilter('FilterGrid')
            .waitUntilLoaded()
            .displayText('===== Add stock UOM first Done  =====')
            //endregion


            //region
            .displayText('===== Scenario 2. Add Conversion UOMs =====')
            .clickMenuScreen('Inventory UOM','Screen')
            .filterGridRecords('UOM', 'FilterGrid', 'Test_50 lb bag')
            .waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function (win,next) {
                    new iRely.FunctionalTest().start(t, next)
                    return win.down('#grdUOM').store.getCount() == 0;
                },

                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid').waitUntilLoaded().waitUntilLoaded()
                        .clickButton('InsertUOM')
                        .addFunction(function(next){
                            var win = Ext.WindowManager.getActive();
                            var recCount = win.down('#grdUOM').store.getCount();
                            new iRely.FunctionalTest().start(t, next)
                            .enterGridData('UOM', recCount, 'strUnitMeasure', 'Test_50 lb bag')
                            .enterGridData('UOM', recCount, 'strSymbol', 'Test_50 lb bag')
                            .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','Test_Pounds','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 1, 'dblConversionToStock', '50 ')
                            .clickButton('Save')
                            .waitUntilLoaded()
                            .verifyStatusMessage('Saved')
                            .waitUntilLoaded()
                            .done()
                        })
                        .done();
                },
                continueOnFail: true
            })
            .clickButton('Close')
            //.clearTextFilter('FilterGrid')
            .waitUntilLoaded()

            //add another conversion
            .clickMenuScreen('Inventory UOM','Screen')
            .filterGridRecords('UOM', 'FilterGrid', 'Test_Bushels')
            .waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function (win,next) {
                    new iRely.FunctionalTest().start(t, next)
                    return win.down('#grdUOM').store.getCount() == 0;
                },

                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid')
                        .clickButton('InsertUOM')
                        .addFunction(function(next){
                            var win = Ext.WindowManager.getActive();
                            var recCount = win.down('#grdUOM').store.getCount();
                            new iRely.FunctionalTest().start(t, next)
                            .waitUntilLoaded('')
                            .enterGridData('UOM', recCount, 'strUnitMeasure', 'Test_Bushels')
                            .enterGridData('UOM', recCount, 'strSymbol', 'Test_Bushels')
                            .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','Test_Pounds','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 1, 'dblConversionToStock', '56 ')
                            .verifyStatusMessage('Edited')
                            .clickButton('Save')
                            .waitUntilLoaded()
                            .verifyStatusMessage('Saved')
                            .done()
                        })
                        .done();
                },
                continueOnFail: true
            })
            
            .clickButton('Close')
            //.clearTextFilter('FilterGrid')
            .waitUntilLoaded()

            //add another conversion
            .clickMenuScreen('Inventory UOM','Screen')
            .filterGridRecords('UOM', 'FilterGrid', 'Test_KG')
            .waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function (win,next) {
                    new iRely.FunctionalTest().start(t, next)
                    return win.down('#grdUOM').store.getCount() == 0;
                },

                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid')
                        .clickButton('InsertUOM')
                        .addFunction(function(next){
                            var win = Ext.WindowManager.getActive();
                            var recCount = win.down('#grdUOM').store.getCount();
                            new iRely.FunctionalTest().start(t, next)
                            .waitUntilLoaded('')
                            .enterGridData('UOM', recCount, 'strUnitMeasure', 'Test_KG')
                            .enterGridData('UOM', recCount, 'strSymbol', 'Test_KG')
                            .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','Test_Pounds','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 1, 'dblConversionToStock', '2.20462')
                            .verifyStatusMessage('Edited')
                            .clickButton('Save')
                            .waitUntilLoaded()
                            .verifyStatusMessage('Saved')
                            .done()
                        })
                        .done();
                },
                continueOnFail: true
            })
           
            .clickButton('Close')
            //.clearTextFilter('FilterGrid')
            .waitUntilLoaded()

            //add another conversion
            .clickMenuScreen('Inventory UOM','Screen')
            .filterGridRecords('UOM', 'FilterGrid', 'Test_60 KG bags')
            .waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function (win,next) {
                    new iRely.FunctionalTest().start(t, next)
                    return win.down('#grdUOM').store.getCount() == 0;
                },

                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid')
                        .clickButton('InsertUOM')
                        .addFunction(function(next){
                            var win = Ext.WindowManager.getActive();
                            var recCount = win.down('#grdUOM').store.getCount();
                            new iRely.FunctionalTest().start(t, next)
                            .waitUntilLoaded('')
                            .enterGridData('UOM', recCount, 'strUnitMeasure', 'Test_60 KG bags')
                            .enterGridData('UOM', recCount, 'strSymbol', 'Test_60 KG bags')
                            .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','Test_Pounds','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 1, 'dblConversionToStock', '132.2772')
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',2,'colConversionTo','Test_KG','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 2, 'dblConversionToStock', '60')
                            .verifyStatusMessage('Edited')
                            .clickButton('Save')
                            .waitUntilLoaded()
                            .verifyStatusMessage('Saved')
                            .done()
                        })
                        .done();
                },
                continueOnFail: true
            })
           
            .clickButton('Close')
            //.clearTextFilter('FilterGrid')
            .waitUntilLoaded()

            //add another conversion
            .clickMenuScreen('Inventory UOM','Screen')
            .filterGridRecords('UOM', 'FilterGrid', 'Test_25 KG bags')
            .waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function (win,next) {
                    new iRely.FunctionalTest().start(t, next)
                    return win.down('#grdUOM').store.getCount() == 0;
                },

                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid')
                        .clickButton('InsertUOM')
                        .addFunction(function(next){
                            var win = Ext.WindowManager.getActive();
                            var recCount = win.down('#grdUOM').store.getCount();
                            new iRely.FunctionalTest().start(t, next)
                            .waitUntilLoaded('')
                            .enterGridData('UOM', recCount, 'strUnitMeasure', 'Test_25 KG bags')
                            .enterGridData('UOM', recCount, 'strSymbol', 'Test_25 KG bags')
                            .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','Test_Pounds','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 1, 'dblConversionToStock', '55.1155')
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',2,'colConversionTo','Test_KG','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 2, 'dblConversionToStock', '25')
                            .verifyStatusMessage('Edited')
                            .clickButton('Save')
                            .waitUntilLoaded()
                            .verifyStatusMessage('Saved')
                            .done()
                        })
                        .done();
                },
                continueOnFail: true
            })

            .clickButton('Close')
            //.clearTextFilter('FilterGrid')
            .waitUntilLoaded()

            //add another conversion
            .clickMenuScreen('Inventory UOM','Screen')
            .filterGridRecords('UOM', 'FilterGrid', 'Test_50 KG bags')
            .waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function (win,next) {
                    new iRely.FunctionalTest().start(t, next)
                    return win.down('#grdUOM').store.getCount() == 0;
                },

                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid')
                        .clickButton('InsertUOM')
                        .addFunction(function(next){
                            var win = Ext.WindowManager.getActive();
                            var recCount = win.down('#grdUOM').store.getCount();
                            new iRely.FunctionalTest().start(t, next)
                            .waitUntilLoaded('')
                            .enterGridData('UOM', recCount, 'strUnitMeasure', 'Test_50 KG bags')
                            .enterGridData('UOM', recCount, 'strSymbol', 'Test_50 KG bags')
                            .selectGridComboBoxRowNumber('UOM',recCount,'strUnitType',6)
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',1,'colConversionTo','Test_Pounds','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 1, 'dblConversionToStock', '110.231')
                            .clickButton('InsertConversion')
                            .selectGridComboBoxRowValue('Conversion',2,'colConversionTo','Test_KG','strUnitMeasure',1)
                            .waitUntilLoaded()
                            .enterGridData('Conversion', 2, 'dblConversionToStock', '50')
                            .verifyStatusMessage('Edited')
                            .clickButton('Save')
                            .waitUntilLoaded()
                            .verifyStatusMessage('Saved')
                            .done()
                        })
                        .done();
                },
                continueOnFail: true
            })
            .clickButton('Close')    
            //.clearTextFilter('FilterGrid')
            .waitUntilLoaded()


            .displayText('===== Add Conversion UOM Done  =====')
            //endregion

        .displayText('===== Add Commodity =====')
        .clickMenuScreen('Commodities','Screen')
        ////////////////////////////////////////////////////////
         .filterGridRecords('Search', 'From', commoditycode)
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
                        .enterData('Text Field','CommodityCode', commoditycode)
                        .enterData('Text Field','Description', description)
                        .enterData('Text Field','DecimalsOnDpr','6.00')

                        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Test_Pounds','strUnitMeasure')
                        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'Test_Pounds', 'ysnStockUnit', true)
                        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','Test_50 lb bag','strUnitMeasure')
                        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Test_Bushels','strUnitMeasure')
                            .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','Test_25 KG bags','strUnitMeasure')
                        .selectGridComboBoxRowValue('Uom',5,'strUnitMeasure','Test_60 KG bags','strUnitMeasure')

                        .clickButton('Save')
                        .waitUntilLoaded()
                        .verifyStatusMessage('Saved')
                        .clickButton('Close')
                        .done();
                },
                continueOnFail: true
            })
        ////////////////////////////////////////////////////////

        
        
        .waitUntilLoaded('')
        .clickButton('Close')
        .displayText('===== Add Commodity Done =====')

        .done();

        },


    /**
     * Add Category
     *
     * @param {String} categorycode - Commodity Name
     *
     * @param {String} description - Commodity Descriptiion
     *
     * @param {Integer} inventorytype - Inventory Type of the Category
     * 1 = Bundle
     * 2 = Inventory
     * 3 = Kit
     * 4 = Finished Good
     * 5 = Non Inventory
     * 6 = Other Charge
     * 7 = Raw Material
     * 8 = Service
     * 9 = Software
     * 10 = Component
     *
     */


    addCategory: function (t,next, categorycode, description,inventorytype) {
        new iRely.FunctionalTest().start(t, next)

            .displayText('===== Add New Category - Inventory Type =====')
            //.clickMenuFolder('Inventory','Folder')
           // .clickMenuScreen('Categories','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .enterData('Text Field','CategoryCode', categorycode)
            .enterData('Text Field','Description', description)
            .selectComboBoxRowNumber('InventoryType',inventorytype,0)
            //.selectComboBoxRowNumber('CostingMethod',1,0)
            .selectGridComboBoxRowValue('Tax',1,'strTaxClass','State Sales Tax (SST)','strTaxClass')

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
            .waitUntilLoaded()
            .verifyStatusMessage('Saved')
            .clickButton('Close')
            // .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .displayText('===== Add New Category - Inventory Type Done =====')
            .done();
    },




      /**
     * Add Direct Inventory Receipt for Non Lotted Item
     *
     */


    addDirectIRNonLotted: function (t,next, vendor, location,itemno,receiptuom, qtytoreceive,cost ) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)


            .displayText('===== Creeating Direct IR for Non Lotted Item  =====')
            // .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('ReceiptType',4,0)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .selectComboBoxRowNumber('Location', location,0)
            .clickButton('Close')
            .clickButton('InsertInventoryReceipt')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo',itemno,'strItemNo')
            .waitUntilLoaded('')
            .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', qtytoreceive, receiptuom)
            .waitUntilLoaded('')
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .enterGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Test_Pounds')
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)

            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Close')
            .displayText('===== Creating Direct IR for Non Lotted Done =====')
            //.clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .waitUntilLoaded('')


            .done();
    },


    /**
     * Add Direct Inventory Receipt for Lotted Item
     *
     */


    addDirectIRLotted: function (t,next, vendor, location,itemno,receiptuom, qtytoreceive,cost,sublocation, storagelocation, lotno, lotuom) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)


            .displayText('===== Creeating Direct IR for Lotted Item  =====')
            // .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('ReceiptType',4,0)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .selectComboBoxRowNumber('Location',location,0)
            .clickButton('Close')
            .clickButton('InsertInventoryReceipt')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo',itemno,'strItemNo')
            .waitUntilLoaded('')
            .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', qtytoreceive, receiptuom)
            .waitUntilLoaded('')
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .enterGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Test_Pounds')
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Test_Pounds')
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName',sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName',storagelocation,'strSubLocationName')

            .enterGridData('LotTracking', 1, 'colLotId', lotno)
            .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure',lotuom,'strUnitMeasure')
            .enterGridData('LotTracking', 1, 'colLotQuantity', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM',lotuom)
            .verifyGridData('LotTracking', 1, 'colLotStorageLocation', storagelocation)


            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .displayText('===== Creating Direct IR for Non Lotted Done =====')
            //.clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .waitUntilLoaded('')


            .done();
    },




    /**
     * Add PO to IR Inventory Receipt for Non Lotted Item "Process Button"
     *
     */


    addPOtoIRProcessButtonNonLotted: function (t,next, vendor, location,itemno,receiptuom, qtytoreceive,cost ) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Purchasing (A/P)','Folder')
            .clickMenuScreen('Purchase Orders','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('VendorId', vendor , 'VendorId',1)
            .selectComboBoxRowValue('ShipTo', location , 'VendorId',1)
            .waitUntilLoaded('')
            .selectGridComboBoxRowValue('Items',1,'strItemNo',itemno,'strItemNo')
            .selectGridComboBoxRowValue('Items',1,'strUOM', receiptuom,'strUOM')
            .enterGridData('Items', 1, 'colQtyOrdered', qtytoreceive)
            .enterGridData('Items', 1, 'colCost', cost)
            .verifyGridData('Items', 1, 'colTotal', linetotal)
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Process')
            .addResult('Processing PO to IR',1000)
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .verifyData('Combo Box','ReceiptType','Purchase Order')
            .verifyData('Combo Box','Vendor', vendor)
            .verifyGridData('InventoryReceipt', 1, 'colItemNo', itemno)
            .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', qtytoreceive, receiptuom, 'equal')
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)


            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtTotal').value;
                if (total == linetotal) {
                    t.ok(true, 'Total is correct.');
                }
                else {
                    t.ok(false, 'Total is incorrect.');
                }
                next();
            })

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Open Post Preview Tab',2000)
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Open Post Preview Tab',2000)
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            //.clickMenuFolder('Purchasing (Accounts Payable)','Folder')
            .waitUntilLoaded('')

            .done();
    },


    /**
     * Add PO to IR Inventory Receipt for  Lotted Item "Process Button"
     *
     */


    addPOtoIRProcessButtonLotted: function (t,next, vendor, location,itemno,receiptuom, qtytoreceive,cost,sublocation, storagelocation, lotno, lotuom) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)


            .clickMenuFolder('Purchasing (A/P)','Folder')
            .clickMenuScreen('Purchase Orders','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('VendorId', vendor , 'VendorId',1)
            .selectComboBoxRowValue('ShipTo', location , 'VendorId',1)
            .waitUntilLoaded('')
            .selectGridComboBoxRowValue('Items',1,'strItemNo',itemno,'strItemNo')
            .selectGridComboBoxRowValue('Items',1,'strUOM', receiptuom,'strUOM')
            .enterGridData('Items', 1, 'colQtyOrdered', qtytoreceive)
            .enterGridData('Items', 1, 'colCost', cost)
            .verifyGridData('Items', 1, 'colTotal', linetotal)
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Process')
            .addResult('Processing PO to IR',1000)
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .verifyData('Combo Box','ReceiptType','Purchase Order')
            .verifyData('Combo Box','Vendor', vendor)
            .verifyGridData('InventoryReceipt', 1, 'colItemNo', itemno)
            .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', qtytoreceive, receiptuom, 'equal')
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM', receiptuom,'strWeightUOM')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName',sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName',storagelocation,'strSubLocationName')

            .enterGridData('LotTracking', 1, 'colLotId', lotno)
            .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure',lotuom,'strUnitMeasure')
            .enterGridData('LotTracking', 1, 'colLotQuantity', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM',lotuom)
            .verifyGridData('LotTracking', 1, 'colLotStorageLocation', storagelocation)
            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtGrossWgt').value;
                if (total == qtytoreceive) {
                    t.ok(true, 'Gross is correct.');
                }
                else {
                    t.ok(false, 'Grossl is incorrect.');
                }
                next();
            })
            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtNetWgt').value;
                if (total == qtytoreceive) {
                    t.ok(true, 'Net is correct.');
                }
                else {
                    t.ok(false, 'Net is incorrect.');
                }
                next();
            })
            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtTotal').value;
                if (total == linetotal) {
                    t.ok(true, 'Total is correct.');
                }
                else {
                    t.ok(false, 'Total is incorrect.');
                }
                next();
            })

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Open Post Preview Tab',2000)
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Open Post Preview Tab',2000)
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            //.clickMenuFolder('Purchasing (Accounts Payable)','Folder')
            .waitUntilLoaded('')

            .done();
    },



    /**
     * Add PO to IR Inventory Receipt for Non Lotted Item "Add Orders Button" for non lotted
     *
     */


    addPOtoIRAddOrdersButtonNonLotted: function (t,next, vendor, location,itemno,receiptuom, qtytoreceive,cost ) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Purchasing (A/P)','Folder')
            .clickMenuScreen('Purchase Orders','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('VendorId', vendor, 'VendorId',1)
            .selectComboBoxRowValue('ShipTo', location , 'VendorId',1)
            .waitUntilLoaded('')
            .selectGridComboBoxRowValue('Items',1,'strItemNo', itemno,'strItemNo')
            .selectGridComboBoxRowValue('Items',1,'strUOM', receiptuom,'strUOM')
            .enterGridData('Items', 1, 'colQtyOrdered', qtytoreceive)
            .enterGridData('Items', 1, 'colCost', cost)
            .verifyGridData('Items', 1, 'colTotal', linetotal)
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('ReceiptType',2,0)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .waitUntilLoaded('')
            .addResult('Opening Add Orders Screen',3000)
            .addResult('Opening Add Orders Screen',3000)
            .selectSearchRowNumber(1)
            .clickButton('OpenSelected')
            .waitUntilLoaded('icinventoryreceipt')
            .verifyData('Combo Box','ReceiptType','Purchase Order')
            .verifyData('Combo Box','Vendor','ABC Trucking')

            .verifyGridData('InventoryReceipt', 1, 'colItemNo', itemno)
            .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', qtytoreceive)
            .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', qtytoreceive, receiptuom, 'equal')
            .verifyGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtTotal').value;
                if (total == linetotal) {
                    t.ok(true, 'Total is correct.');
                }
                else {
                    t.ok(false, 'Total is incorrect.');
                }
                next();
            })

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Open Post Preview Tab',2000)
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Open Post Preview Tab',2000)
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .waitUntilLoaded('')
            .clickButton('Post')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            //.clickMenuFolder('Purchasing (Accounts Payable)','Folder')
            .waitUntilLoaded('')
            //.clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')

            .done();
    },



    /**
     * Add PO to IR Inventory Receipt for Non Lotted Item "Add Orders Button" for  lotted
     *
     */


    addPOtoIRAddOrdersButtonLotted: function (t,next, vendor, location,itemno,receiptuom, qtytoreceive,cost,sublocation, storagelocation, lotno, lotuom ) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Purchasing (A/P)','Folder')
            .clickMenuScreen('Purchase Orders','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('VendorId', vendor , 'VendorId',1)
            .selectComboBoxRowValue('ShipTo', location , 'VendorId',1)
            .waitUntilLoaded('')
            .selectGridComboBoxRowValue('Items',1,'strItemNo',itemno,'strItemNo')
            .selectGridComboBoxRowValue('Items',1,'strUOM', receiptuom,'strUOM')
            .enterGridData('Items', 1, 'colQtyOrdered', qtytoreceive)
            .enterGridData('Items', 1, 'colCost', cost)
            .verifyGridData('Items', 1, 'colTotal', linetotal)
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Purchasing (A/P)','Folder')

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('ReceiptType',2,0)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .waitUntilLoaded('')
            .selectSearchRowNumber(1)
            .clickButton('OpenSelected')
            .waitUntilLoaded('icinventoryreceipt')


            .verifyData('Combo Box','ReceiptType','Purchase Order')
            .verifyData('Combo Box','Vendor', vendor)
            .verifyGridData('InventoryReceipt', 1, 'colItemNo', itemno)
            .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', qtytoreceive, receiptuom, 'equal')
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM', receiptuom,'strWeightUOM')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName',sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName',storagelocation,'strSubLocationName')

            .enterGridData('LotTracking', 1, 'colLotId', lotno)
            .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure',lotuom,'strUnitMeasure')
            .enterGridData('LotTracking', 1, 'colLotQuantity', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM',lotuom)
            .verifyGridData('LotTracking', 1, 'colLotStorageLocation', storagelocation)
            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtGrossWgt').value;
                if (total == qtytoreceive) {
                    t.ok(true, 'Gross is correct.');
                }
                else {
                    t.ok(false, 'Grossl is incorrect.');
                }
                next();
            })
            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtNetWgt').value;
                if (total == qtytoreceive) {
                    t.ok(true, 'Net is correct.');
                }
                else {
                    t.ok(false, 'Net is incorrect.');
                }
                next();
            })
            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtTotal').value;
                if (total == linetotal) {
                    t.ok(true, 'Total is correct.');
                }
                else {
                    t.ok(false, 'Total is incorrect.');
                }
                next();
            })

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Open Post Preview Tab',2000)
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Open Post Preview Tab',2000)
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .waitUntilLoaded('')
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')

            .done();
    },


    /**
     * Add CT to IR Inventory Receipt for Non Lotted Item "Process Button"
     *
     */


    addCTtoIRAddOrdersButtonNonLotted: function (t,next, vendor, commodity, location,itemno,receiptuom, qtytoreceive,cost) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Contract Management','Folder')
            .clickMenuScreen('Contracts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
            .selectComboBoxRowValue('Customer', vendor, 'Customer',1)
            .selectComboBoxRowValue('Commodity', commodity, 'Commodity',1)
            .enterData('Text Field','Quantity', qtytoreceive)
            .selectComboBoxRowValue('CommodityUOM', receiptuom, 'CommodityUOM',1)
            .selectComboBoxRowValue('Position', 'Arrival', 'Position',1)
            .selectComboBoxRowValue('PricingType', 'Cash', 'PricingType',1)
            .selectComboBoxRowValue('Salesperson', 'Bob Smith', 'Salesperson',1)
            .clickButton('AddDetail')
            .waitUntilLoaded('ctcontractsequence')
            .waitUntilLoaded('')
            .addFunction (function (next){
            var date = new Date().toLocaleDateString();
            new iRely.FunctionalTest().start(t, next)
                .enterData('Date Field','EndDate', date, 0, 10)
                .done();
            })
            .selectComboBoxRowValue('Location', location , 'Location',1)
            .selectComboBoxRowValue('Item', itemno, 'Item',1)
            .selectComboBoxRowValue('NetWeightUOM', receiptuom, 'NetWeightUOM',1)
            .selectComboBoxRowValue('PriceCurrency', 'USD', 'PriceCurrency',1)
            .enterData('Text Field','CashPrice', cost)
            .selectComboBoxRowValue('CashPriceUOM', receiptuom, 'CashPriceUOM',1)
            .clickButton('Save')
            .waitUntilLoaded('ctcontract')
            .waitUntilLoaded('')
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Contract Management','Folder')

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('ReceiptType',1,0)
            .selectComboBoxRowValue('SourceType', 'None', 'Vendor',1)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .waitUntilLoaded('')
            .addResult('Successfully Opened',2000)
//            .doubleClickSearchRowValue(itemno, 1)
            .selectSearchRowNumber([1])
            .clickButton('OpenSelected')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Successfully Opened',2000)
            .waitUntilLoaded('')

            .verifyData('Combo Box','ReceiptType','Purchase Contract')
            .verifyData('Combo Box','Vendor',vendor)
            .verifyData('Combo Box','Currency','USD')
            .verifyGridData('InventoryReceipt', 1, 'colItemNo', itemno)
            .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', qtytoreceive)
            .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', qtytoreceive, receiptuom, 'equal')
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .verifyGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtTotal').value;
                if (total == linetotal) {
                    t.ok(true, 'Total is correct.');
                }
                else {
                    t.ok(false, 'Total is incorrect.');
                }
                next();
            })

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')

            .done();
    },


    /**
     * Add PO to IR Inventory Receipt for Non Lotted Item "Add Orders Button" for  lotted
     *
     */


    addCTtoIRAddOrdersButtonLotted: function (t,next, vendor, commodity, location,itemno,receiptuom, qtytoreceive,cost,sublocation, storagelocation, lotno, lotuom ) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Contract Management','Folder')
            .clickMenuScreen('Contracts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
            .selectComboBoxRowValue('Customer', vendor, 'Customer',1)
            .selectComboBoxRowValue('Commodity', commodity, 'Commodity',1)
            .enterData('Text Field','Quantity', qtytoreceive)
            .selectComboBoxRowValue('CommodityUOM', receiptuom, 'CommodityUOM',1)
            .selectComboBoxRowValue('Position', 'Arrival', 'Position',1)
            .selectComboBoxRowValue('PricingType', 'Cash', 'PricingType',1)
            .selectComboBoxRowValue('Salesperson', 'Bob Smith', 'Salesperson',1)
            .clickButton('AddDetail')
            .waitUntilLoaded('ctcontractsequence')
            .waitUntilLoaded('')
            .addFunction (function (next){
            var date = new Date().toLocaleDateString();
            new iRely.FunctionalTest().start(t, next)
                .enterData('Date Field','EndDate', date, 0, 10)
                .done();
        })
            .selectComboBoxRowValue('Location', location , 'Location',1)
            .selectComboBoxRowValue('Item', itemno, 'Item',1)
            .selectComboBoxRowValue('NetWeightUOM', receiptuom, 'NetWeightUOM',1)
            .selectComboBoxRowValue('PriceCurrency', 'USD', 'PriceCurrency',1)
            .enterData('Text Field','CashPrice', cost)
            .selectComboBoxRowValue('CashPriceUOM', receiptuom, 'CashPriceUOM',1)
            .clickButton('Save')
            .waitUntilLoaded('ctcontract')
            .waitUntilLoaded('')
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Contract Management','Folder')

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('ReceiptType',1,0)
            .selectComboBoxRowValue('SourceType', 'None', 'Vendor',1)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .waitUntilLoaded('')
//            .doubleClickSearchRowValue(itemno, 1)
            .selectSearchRowNumber(1)
            .clickButton('OpenSelected')
            .waitUntilLoaded('icinventoryreceipt')
            .waitUntilLoaded('')
            .addResult('Successfully Opened',2000)
            .waitUntilLoaded('')

            .verifyData('Combo Box','ReceiptType','Purchase Contract')
            .verifyData('Combo Box','Vendor',vendor)
            .verifyData('Combo Box','Currency','USD')
            .verifyGridData('InventoryReceipt', 1, 'colItemNo', itemno)
            .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', qtytoreceive)
            .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', qtytoreceive, receiptuom, 'equal')
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .verifyGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .selectGridRowNumber('InventoryReceipt', [1])
            .waitUntilLoaded('')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM',receiptuom,'strWeightUOM')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName',sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName', storagelocation,'strStorageLocationName')
            .waitUntilLoaded('')


            .enterGridData('LotTracking', 1, 'colLotId', lotno)
            .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure',lotuom,'strUnitMeasure')
            .enterGridData('LotTracking', 1, 'colLotQuantity', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotGrossWeight', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colLotNetWeight', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM', receiptuom)
            .verifyGridData('LotTracking', 1, 'colLotStorageLocation', storagelocation)

            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtTotal').value;
                if (total == linetotal) {
                    t.ok(true, 'Total is correct.');
                }
                else {
                    t.ok(false, 'Total is incorrect.');
                }
                next();
            })

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')

            .done();
    },



    /**
     * Add CT to IR Inventory Receipt for Non Lotted Item "Process Button"
     *
     */


    addCTtoIRProcessButtonNonLotted: function (t,next, vendor, commodity, location,itemno,receiptuom, qtytoreceive,cost) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Contract Management','Folder')
            .clickMenuScreen('Contracts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
            .selectComboBoxRowValue('Customer', vendor, 'Customer',1)
            .selectComboBoxRowValue('Commodity', commodity, 'Commodity',1)
            .enterData('Text Field','Quantity', qtytoreceive)
            .selectComboBoxRowValue('CommodityUOM', receiptuom, 'CommodityUOM',1)
            .selectComboBoxRowValue('Position', 'Arrival', 'Position',1)
            .selectComboBoxRowValue('PricingType', 'Cash', 'PricingType',1)
            .selectComboBoxRowValue('Salesperson', 'Bob Smith', 'Salesperson',1)
            .clickButton('AddDetail')
            .waitUntilLoaded('ctcontractsequence')
            .waitUntilLoaded('')
            .addFunction (function (next){
            var date = new Date().toLocaleDateString();
            new iRely.FunctionalTest().start(t, next)
                .enterData('Date Field','EndDate', date, 0, 10)
                .done();
             })
            .selectComboBoxRowValue('Location', location , 'Location',1)
            .selectComboBoxRowValue('Item', itemno, 'Item',1)
            .selectComboBoxRowValue('NetWeightUOM', receiptuom, 'NetWeightUOM',1)
            .selectComboBoxRowValue('PriceCurrency', 'USD', 'PriceCurrency',1)
            .enterData('Text Field','CashPrice', cost)
            .selectComboBoxRowValue('CashPriceUOM', receiptuom, 'CashPriceUOM',1)
            .clickButton('Save')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Process')
            .clickButton('IR')
            .waitUntilLoaded('')
            .clickMessageBoxButton('yes')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')

            .clickTab('Post Preview')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .verifyData('Combo Box','ReceiptType','Purchase Contract')
            .verifyData('Combo Box','Vendor',vendor)
            .verifyData('Combo Box','Currency','USD')
            .verifyGridData('InventoryReceipt', 1, 'colItemNo', itemno)
            .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', qtytoreceive)
            .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', qtytoreceive, receiptuom, 'equal')
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .verifyGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtTotal').value;
                if (total == linetotal) {
                    t.ok(true, 'Total is correct.');
                }
                else {
                    t.ok(false, 'Total is incorrect.');
                }
                next();
            })
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Contract Management','Folder')
            .waitUntilLoaded('')

            .done();
    },



    /**
     * Add CT to IR Inventory Receipt for  Lotted Item "Process Button"
     *
     */


    addCTtoIRProcessButtonLotted: function (t,next, vendor, commodity, location,itemno,receiptuom, qtytoreceive,cost,sublocation, storagelocation, lotno, lotuom ) {
        var linetotal =  qtytoreceive * cost;
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Contract Management','Folder')
            .clickMenuScreen('Contracts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Type', 'Purchase', 'Type',1)
            .selectComboBoxRowValue('Customer', vendor, 'Customer',1)
            .selectComboBoxRowValue('Commodity', commodity, 'Commodity',1)
            .enterData('Text Field','Quantity', qtytoreceive)
            .selectComboBoxRowValue('CommodityUOM', receiptuom, 'CommodityUOM',1)
            .selectComboBoxRowValue('Position', 'Arrival', 'Position',1)
            .selectComboBoxRowValue('PricingType', 'Cash', 'PricingType',1)
            .selectComboBoxRowValue('Salesperson', 'Bob Smith', 'Salesperson',1)
            .clickButton('AddDetail')
            .waitUntilLoaded('ctcontractsequence')
            .waitUntilLoaded('')
            .addFunction (function (next){
            var date = new Date().toLocaleDateString();
            new iRely.FunctionalTest().start(t, next)
                .enterData('Date Field','EndDate', date, 0, 10)
                .done();
        })
            .selectComboBoxRowValue('Location', location , 'Location',1)
            .selectComboBoxRowValue('Item', itemno, 'Item',1)
            .selectComboBoxRowValue('NetWeightUOM', receiptuom, 'NetWeightUOM',1)
            .selectComboBoxRowValue('PriceCurrency', 'USD', 'PriceCurrency',1)
            .enterData('Text Field','CashPrice', cost)
            .selectComboBoxRowValue('CashPriceUOM', receiptuom, 'CashPriceUOM',1)
            .clickButton('Save')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Process')
            .clickButton('IR')
            .waitUntilLoaded('')
            .clickMessageBoxButton('yes')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')

            .clickTab('FreightInvoice')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)

            .selectGridRowNumber('InventoryReceipt', [1])
            .waitUntilLoaded('')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM',receiptuom,'strWeightUOM')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName',sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName', storagelocation,'strStorageLocationName')
            .waitUntilLoaded('')


            .enterGridData('LotTracking', 1, 'colLotId', lotno)
            .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure',lotuom,'strUnitMeasure')
            .enterGridData('LotTracking', 1, 'colLotQuantity', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotGrossWeight', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colLotNetWeight', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM', receiptuom)
            .verifyGridData('LotTracking', 1, 'colLotStorageLocation', storagelocation)

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .clickTab('Details')
            .waitUntilLoaded('')
            .verifyData('Combo Box','ReceiptType','Purchase Contract')
            .verifyData('Combo Box','Vendor',vendor)
            .verifyData('Combo Box','Currency','USD')
            .verifyGridData('InventoryReceipt', 1, 'colItemNo', itemno)
            .verifyGridData('InventoryReceipt', 1, 'colOrderUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colQtyOrdered', qtytoreceive)
            .verifyUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', qtytoreceive, receiptuom, 'equal')
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .verifyGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .addFunction(function (next){
                var win =  Ext.WindowManager.getActive(),
                    total = win.down('#txtTotal').value;
                if (total == linetotal) {
                    t.ok(true, 'Total is correct.');
                }
                else {
                    t.ok(false, 'Total is incorrect.');
                }
                next();
            })
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colCredit', linetotal)
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Contract Management','Folder')
            .waitUntilLoaded('')

            .done();
    },


    /**
     * Add Direct Inventory Shipment for Non Lotted Item
     *
     */
    addDirectISNonLotted: function (t,next, customer, freight, currency,fromlocation,itemno,uom, quantity) {
        var linetotal =  quantity * 10;
        new iRely.FunctionalTest().start(t, next)


            .displayText('===== Creeating Direct IR for Non Lotted Item  =====')
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Shipments','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('OrderType',4,0)
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .selectComboBoxRowValue('FreightTerms', freight, 'FreightTerms',1)
            .selectComboBoxRowValue('Currency', currency, 'Currency',1)
            .selectComboBoxRowValue('ShipFromAddress', fromlocation, 'ShipFromAddress',1)
            .selectComboBoxRowNumber('ShipToAddress',1,0)

            .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo',itemno,'strItemNo')
            .enterUOMGridData('InventoryShipment', 1, 'colGumQuantity', 'strUnitMeasure', quantity, uom)

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colCredit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colDebit', linetotal)

            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',1500)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
            .clickMenuFolder('Inventory','Folder')

            .done();
    },


    /**
     * Add SO to Inventory Shipment for Non Lotted Item Shipment button
     *
     */
    addSalesOrderSNonLotted: function (t,next, customer, freight, currency,fromlocation,itemno,uom, quantity) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Sales (Accounts Receivable)','Folder')
            .clickMenuScreen('Sales Orders','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .enterData('Text Field','BOLNo','Test BOL - 01')
            .selectComboBoxRowValue('FreightTerm', freight, 'FreightTerm',1)
            .selectComboBoxRowValue('Currency', currency, 'Currency',1)
            .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo', itemno,'strItemNo')
            .selectGridComboBoxRowValue('SalesOrder',1,'strUnitMeasure', uom,'strUnitMeasure')
            .addResult('Item Selected',1500)
            .enterGridData('SalesOrder', 1, 'colOrdered', quantity)
            .clickButton('Save')
            .waitUntilLoaded('')
            .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
            .clickMessageBoxButton('ok')
            .waitUntilLoaded('')
            .clickButton('Ship')
            .waitUntilLoaded('')
            .addResult('Clicked Ship Button',3000)
            .waitUntilLoaded('')
            .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
            .clickMessageBoxButton('ok')
            .waitUntilLoaded('')
            .addResult('Open Inventory Shipment Screen',3000)
            .waitUntilLoaded('')
            .waitUntilLoaded('')

            .selectComboBoxRowValue('Currency', 'USD', 'Currency',1)
            .verifyData('Combo Box','OrderType','Sales Order')
            .verifyData('Combo Box','Customer', customer)
            .verifyData('Combo Box','FreightTerms', freight)
            .verifyGridData('InventoryShipment', 1, 'colItemNumber', itemno)
            .verifyGridData('InventoryShipment', 1, 'colOrderUOM', uom)

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',1500)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Sales (Accounts Receivable)','Folder')
            .displayText('===== Ship Button SO to IS for Non Lotted Done=====')

            .done();
    },


    /**
     * Add SO to Inventory Shipment for  Lotted Item Shipment button
     *
     */
    addSalesOrderSLotted: function (t,next, customer, freight, currency,fromlocation,itemno,uom, quantity, sublocation, storagelocation, lotno) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Sales (Accounts Receivable)','Folder')
            .clickMenuScreen('Sales Orders','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .enterData('Text Field','BOLNo','Test BOL - 01')
            .selectComboBoxRowValue('FreightTerm', freight, 'FreightTerm',1)
            .selectComboBoxRowValue('Currency', currency, 'Currency',1)
            .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo', itemno,'strItemNo')
            .selectGridComboBoxRowValue('SalesOrder',1,'strUnitMeasure', uom,'strUnitMeasure')
            .addResult('Item Selected',1500)
            .enterGridData('SalesOrder', 1, 'colOrdered', quantity)
            .clickButton('Save')
            .waitUntilLoaded('')
            .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
            .clickMessageBoxButton('ok')
            .waitUntilLoaded('')
            .clickButton('Ship')
            .waitUntilLoaded('')
            .addResult('Clicked Ship Button',3000)
            .waitUntilLoaded('')
            .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
            .clickMessageBoxButton('ok')
            .waitUntilLoaded('')
            .addResult('Open Inventory Shipment Screen',3000)
            .waitUntilLoaded('')
            .waitUntilLoaded('')

            .selectComboBoxRowValue('Currency', 'USD', 'Currency',1)
            .verifyData('Combo Box','OrderType','Sales Order')
            .verifyData('Combo Box','Customer', customer)
            .verifyData('Combo Box','FreightTerms', freight)
            .verifyGridData('InventoryShipment', 1, 'colItemNumber', itemno)
            .verifyGridData('InventoryShipment', 1, 'colOrderUOM', uom)

            .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName', sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName', storagelocation,'strStorageLocationName')

            .selectGridComboBoxRowValue('LotTracking',1,'strLotId', lotno,'strLotId')
            .enterGridData('LotTracking', 1, 'colShipQty', quantity)
            .verifyGridData('LotTracking', 1, 'colLotUOM', uom)
            .verifyGridData('LotTracking', 1, 'colGrossWeight', quantity)
            .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colNetWeight', quantity)
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM', uom)


            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',1500)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Sales (Accounts Receivable)','Folder')
            .waitUntilLoaded('')
            .displayText('===== Ship Button SO to IS for Non Lotted Done=====')

            .done();
    },


    /**
     * Add Direct Inventory Shipment for Lotted Item
     *
     */

    addDirectISLotted: function (t,next, customer, freight, currency,fromlocation,itemno,uom, quantity, lotno) {
        var linetotal =  quantity * 10;
        new iRely.FunctionalTest().start(t, next)


            .displayText('===== Creeating Direct IR for Non Lotted Item  =====')
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Shipments','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('OrderType',4,0)
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .selectComboBoxRowValue('FreightTerms', freight, 'FreightTerms',1)
            .selectComboBoxRowValue('Currency', currency, 'FreightTerms',1)
            .selectComboBoxRowValue('ShipFromAddress', fromlocation, 'ShipFromAddress',1)
            .selectComboBoxRowNumber('ShipToAddress',1,0)

            .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo',itemno,'strItemNo')
            .enterUOMGridData('InventoryShipment', 1, 'colGumQuantity', 'strUnitMeasure', quantity, uom)

            .selectGridComboBoxRowValue('LotTracking',1,'strLotId', lotno,'strLotId')
            .enterGridData('LotTracking', 1, 'colShipQty', '100')
            .verifyGridData('LotTracking', 1, 'colLotUOM', uom)
            .verifyGridData('LotTracking', 1, 'colGrossWeight', '100')
            .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colNetWeight', '100')
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM', uom)

            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .clickTab('Post Preview')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colCredit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colAccountId', '16050-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colDebit', linetotal)

            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',1500)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .displayText('===== Create Direct Inventory Shipment for Non Lotted Item Done=====')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')

            .done();
    },



    /**
     * Add SO to Inventory Shipment for Non Lotted Item Add Orders Screen
     *
     */
    addSOtoISAddORdersNonLotted: function (t,next, customer, currency,location,freight, itemno,uom, quantity) {
        new iRely.FunctionalTest().start(t, next)


            .clickMenuFolder('Sales (Accounts Receivable)','Folder')
            .clickMenuScreen('Sales Orders','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .selectComboBoxRowValue('CompanyLocation', location, 'CompanyLocation',1)
            .enterData('Text Field','BOLNo','Test BOL - 01')

            .selectComboBoxRowValue('FreightTerm', freight, 'FreightTerm',1)
            .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo', itemno,'strItemNo')
            .selectGridComboBoxRowValue('SalesOrder',1,'strUnitMeasure', uom,'strUnitMeasure')
            .addResult('Item Selected',1500)
            .enterGridData('SalesOrder', 1, 'colOrdered', quantity)
//            .addFunction (function (next){
//            var date = new Date().toLocaleDateString();
//            new iRely.FunctionalTest().start(t, next)
//                .enterData('Date Field','DueDate', date, 0, 10)
//                .done();
//            })



            .clickButton('Save')
//            .waitUntilLoaded('')
//            .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
//            .clickMessageBoxButton('ok')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Sales (Accounts Receivable)','Folder')

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Shipments','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('OrderType',2,0)
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .waitUntilLoaded()
//            .selectSearchRowNumber(1)
//            .clickButton('OpenSelected')
            .doubleClickSearchRowValue(itemno, 'strItemNo', 1)
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('FreightTerms', freight, 'FreightTerms',1)
            .selectComboBoxRowValue('Currency', currency, 'FreightTerms',1)
            .selectComboBoxRowValue('ShipFromAddress', location, 'ShipFromAddress',1)
            .selectComboBoxRowNumber('ShipToAddress',1,0)

            .verifyGridData('InventoryShipment', 1, 'colItemNumber', itemno)
//            .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName','Raw Station','strSubLocationName')
//            .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName','RM Storage','strStorageLocationName')
            .clickTab('PostPreview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',1500)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .displayText('===== Add Orders Button SO to IS for Non Lotted Done=====')
            //endregion

            .done();
    },



    /**
     * Add SO to Inventory Shipment for Lotted Item Add Orders Screen
     *
     */
    addSOtoISAddORdersLotted: function (t,next, customer, currency,location,freight, itemno,uom, quantity, sublocation, storagelocation, lotno) {
        new iRely.FunctionalTest().start(t, next)


            .clickMenuFolder('Sales (Accounts Receivable)','Folder')
            .clickMenuScreen('Sales Orders','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .selectComboBoxRowValue('CompanyLocation', location, 'CompanyLocation',1)
            .enterData('Text Field','BOLNo','Test BOL - 01')

            .selectComboBoxRowValue('FreightTerm', freight, 'FreightTerm',1)
            .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo', itemno,'strItemNo')
            .selectGridComboBoxRowValue('SalesOrder',1,'strUnitMeasure', uom,'strUnitMeasure')
            .addResult('Item Selected',1500)
            .enterGridData('SalesOrder', 1, 'colOrdered', quantity)
//            .addFunction (function (next){
//            var date = new Date().toLocaleDateString();
//            new iRely.FunctionalTest().start(t, next)
//                .enterData('Date Field','DueDate', date, 0, 10)
//                .done();
//             })


            .clickButton('Save')
//            .waitUntilLoaded('')
//            .verifyMessageBox('iRely i21','WARNING: Customer may exceed credit limit!','ok','information')
//            .clickMessageBoxButton('ok')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Sales (Accounts Receivable)','Folder')

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Shipments','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('OrderType',2,0)
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .waitUntilLoaded()
//            .selectSearchRowNumber(1)
//            .clickButton('OpenSelected')
            .doubleClickSearchRowValue(itemno, 'strItemNo', 1)
            .waitUntilLoaded('')
            .selectComboBoxRowValue('FreightTerms', freight, 'FreightTerms',1)
            .selectComboBoxRowValue('Currency', currency, 'FreightTerms',1)
            .selectComboBoxRowValue('ShipFromAddress', location, 'ShipFromAddress',1)
            .selectComboBoxRowNumber('ShipToAddress',1,0)

            .verifyGridData('InventoryShipment', 1, 'colItemNumber', itemno)
            .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName', sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName', storagelocation,'strStorageLocationName')

            .selectGridComboBoxRowValue('LotTracking',1,'strLotId', lotno,'strLotId')
            .enterGridData('LotTracking', 1, 'colShipQty', quantity)
            .verifyGridData('LotTracking', 1, 'colLotUOM', uom)
            .verifyGridData('LotTracking', 1, 'colGrossWeight', quantity)
            .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colNetWeight', quantity)
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM', uom)

            .clickTab('PostPreview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',1500)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .displayText('===== Add Orders Button SO to IS for Lotted Done=====')
            //endregion

            .done();
    },




    /**
     * Add Sales Contract to Inventory Shipment for Non Lotted Item Add Orders Screen
     *
     */
    addSCtoISAddORdersNonLotted: function (t,next, customer,itemno, commodity, quantity, uom, location, currency, price, freight) {
        var linetotal =  quantity * price;
        new iRely.FunctionalTest().start(t, next)

            .displayText('===== Ship Button SC to IS for Non Lotted =====')
            .clickMenuFolder('Contract Management','Folder')
            .clickMenuScreen('Contracts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Type', 'Sale', 'Type',1)
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .selectComboBoxRowValue('Commodity', commodity, 'Commodity',1)
            .enterData('Text Field','Quantity', quantity)
            .selectComboBoxRowValue('CommodityUOM', uom, 'CommodityUOM',1)
            .selectComboBoxRowValue('Position', 'Arrival', 'Position',1)
            .selectComboBoxRowValue('PricingType', 'Cash', 'PricingType',1)
            .selectComboBoxRowValue('Salesperson', 'Bob Smith', 'Salesperson',1)
            .clickButton('AddDetail')
            .waitUntilLoaded('ctcontractsequence')
            .addFunction (function (next){
            var date = new Date().toLocaleDateString();
            new iRely.FunctionalTest().start(t, next)
                .enterData('Date Field','EndDate', date, 0, 10)
                .done();
        })
            .selectComboBoxRowValue('Location', location, 'Location',1)
            .selectComboBoxRowValue('Item', itemno, 'Item',1)
            .selectComboBoxRowValue('NetWeightUOM', uom, 'NetWeightUOM',1)
            .verifyData('Combo Box','PricingType','Cash')
            .selectComboBoxRowValue('PriceCurrency', currency, 'PriceCurrency',1)
            .selectComboBoxRowValue('CashPriceUOM', uom, 'CashPriceUOM',1)
            .enterData('Text Field','CashPrice', price)
            .clickButton('Save')
            .waitUntilLoaded('ctcontract')
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Contract Management','Folder')


            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Shipments','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('OrderType',1,0)
            .selectComboBoxRowNumber('SourceType',1,0)
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .waitUntilLoaded()
//            .selectSearchRowNumber(1)
//            .clickButton('OpenSelected')
            .doubleClickSearchRowValue(itemno, 'strItemNo', 1)
            .waitUntilLoaded('')
            .selectComboBoxRowValue('FreightTerms', freight, 'FreightTerms',1)
            .selectComboBoxRowValue('Currency', currency, 'Currency',1)
            .selectComboBoxRowValue('ShipFromAddress', location, 'ShipFromAddress',1)
            .selectComboBoxRowNumber('ShipToAddress',1,0)

            .verifyGridData('InventoryShipment', 1, 'colItemNumber', itemno)
            .verifyGridData('InventoryShipment', 1, 'colUnitPrice', price)
            .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
            .verifyGridData('InventoryShipment', 1, 'colLineTotal', linetotal)

            .clickTab('PostPreview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',1500)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .displayText('===== Ship Button SC to IS for Non Lotted Done=====')


            .done();
    },


    /**
     * Add Sales Contract to Inventory Shipment for Lotted Item Add Orders Screen
     *
     */
    addSCtoISAddORdersLotted: function (t,next, customer,itemno, commodity, quantity, uom, location, currency, price, freight, sublocation, storagelocation, lotno) {
        var linetotal =  quantity * price;
        new iRely.FunctionalTest().start(t, next)

            .displayText('===== Ship Button SC to IS for Lotted =====')
            .clickMenuFolder('Contract Management','Folder')
            .clickMenuScreen('Contracts','Screen')
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Type', 'Sale', 'Type',1)
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .selectComboBoxRowValue('Commodity', commodity, 'Commodity',1)
            .enterData('Text Field','Quantity', quantity)
            .selectComboBoxRowValue('CommodityUOM', uom, 'CommodityUOM',1)
            .selectComboBoxRowValue('Position', 'Arrival', 'Position',1)
            .selectComboBoxRowValue('PricingType', 'Cash', 'PricingType',1)
            .selectComboBoxRowValue('Salesperson', 'Bob Smith', 'Salesperson',1)
            .clickButton('AddDetail')
            .waitUntilLoaded('ctcontractsequence')
            .addFunction (function (next){
            var date = new Date().toLocaleDateString();
            new iRely.FunctionalTest().start(t, next)
                .enterData('Date Field','EndDate', date, 0, 10)
                .done();
        })
            .selectComboBoxRowValue('Location', location, 'Location',1)
            .selectComboBoxRowValue('Item', itemno, 'Item',1)
            .selectComboBoxRowValue('NetWeightUOM', uom, 'NetWeightUOM',1)
            .verifyData('Combo Box','PricingType','Cash')
            .selectComboBoxRowValue('PriceCurrency', currency, 'PriceCurrency',1)
            .selectComboBoxRowValue('CashPriceUOM', uom, 'CashPriceUOM',1)
            .enterData('Text Field','CashPrice', price)
            .clickButton('Save')
            .waitUntilLoaded('ctcontract')
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Contract Management','Folder')


            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Shipments','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('OrderType',1,0)
            .selectComboBoxRowNumber('SourceType',1,0)
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .waitUntilLoaded()
//            .selectSearchRowNumber(1)
//            .clickButton('OpenSelected')
            .doubleClickSearchRowValue(itemno, 'strItemNo', 1)
            .waitUntilLoaded('')
            .selectComboBoxRowValue('FreightTerms', freight, 'FreightTerms',1)
            .selectComboBoxRowValue('Currency', currency, 'Currency',1)
            .selectComboBoxRowValue('ShipFromAddress', location, 'ShipFromAddress',1)
            .selectComboBoxRowNumber('ShipToAddress',1,0)

            .verifyGridData('InventoryShipment', 1, 'colItemNumber', itemno)
            .verifyGridData('InventoryShipment', 1, 'colUnitPrice', price)
            .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
            .verifyGridData('InventoryShipment', 1, 'colLineTotal', linetotal)

            .selectGridRowNumber('InventoryShipment', [1])
            .waitUntilLoaded('')
            .addResult('Selected',1500)
            .waitUntilLoaded('')
            .selectGridComboBoxRowValue('InventoryShipment',1,'strSubLocationName', sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryShipment',1,'strStorageLocationName', storagelocation,'strStorageLocationName')

            .selectGridComboBoxRowValue('LotTracking',1,'strLotId', lotno,'strLotId')
            .enterGridData('LotTracking', 1, 'colShipQty', quantity)
            .verifyGridData('LotTracking', 1, 'colLotUOM', uom)
            .verifyGridData('LotTracking', 1, 'colGrossWeight', quantity)
            .verifyGridData('LotTracking', 1, 'colTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colNetWeight', quantity)
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM', uom)

            .clickTab('PostPreview')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',1500)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .displayText('===== Ship Button SC to IS for Lotted Done=====')


            .done();
    },



    /**
     * Add Other Charge Item
     *
     * @param {String} item - Item Number of the Item
     *
     * @param {String} itemdesc - Item Description of the Item
     *
     * @param {String} itemshort - Item Short name
     *
     *
     */


    addDiscountItem: function (t,next, item, itemshort,itemdesc){
        var engine = new iRely.FunctionalTest();
        engine.start(t, next)

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded()
            .checkStatusMessage('Ready')

            .enterData('ItemNo', item)
            .selectComboRowByIndex('Type',5)
            .enterData('ShortName', itemshort)
            .enterData('Description', itemdesc)
            .selectComboBoxRowValue('Category', 'Other Charges', 500, 'cboCategory',0)
            .selectComboBoxRowValue('Commodity', 'Corn', 500, 'strCommodityCode',0)

            .enterGridData('UnitOfMeasure', 0, 'dblUnitQty', '1')
            .enterGridData('UnitOfMeasure', 1, 'dblUnitQty', '1')
            .enterGridData('UnitOfMeasure', 2, 'dblUnitQty', '1')
            .enterGridData('UnitOfMeasure', 3, 'dblUnitQty', '1')
            .enterGridData('UnitOfMeasure', 4, 'dblUnitQty', '1')
            .enterGridData('UnitOfMeasure', 5, 'dblUnitQty', '1')

            .waitUntilLoaded()

            .clickTab('Setup')

            .clickTab('Location')
            .clickButton('AddLocation')
            .waitUntilLoaded()
            .clickButton('Save')
            .checkStatusMessage('Saved')
            .clickButton('Close')

            .clickTab('Cost')
            .clickCheckBox('Price', true)
            .selectComboRowByIndex('CostType', 2)
            .selectComboRowByIndex('CostMethod', 0)
            .selectComboBoxRowValue('CostUOM', 'Bushels', 500, 'strUnitMeasure',0)
            .clickButton('Save')
            .checkStatusMessage('Saved')
            .displayText('Setup Item Pricing Successful')
            .clickButton('Close')
            .addResult('Crate Other Carge Discount Item Successful')
            .done();

        },


    addOtherChargeItem: function (t,next, item, description, location) {
        new iRely.FunctionalTest().start(t, next)


            //Add Other Charge Item
            .displayText('===== Adding Other Charge Item =====')
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .verifyScreenShown('icitem')



            .enterData('Text Field','ItemNo', item)
            .selectComboBoxRowNumber('Type',6,0)
            .enterData('Text Field','Description', description)
//            .selectComboBoxRowNumber('Category',4,0)
            .selectComboBoxRowValue('Category', 'Other Charges', 'Category',0)
            .displayText('===== Setup Item UOM=====')
            .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Test_Pounds','strUnitMeasure')
            .enterGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
            .clickGridCheckBox('UnitOfMeasure', 1,'strUnitMeasure', 'Test_Pounds', 'ysnStockUnit', true)
            .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
            .enterGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '1')
            .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Bushels','strUnitMeasure')
            .enterGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '1')
            .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
            .enterGridData('UnitOfMeasure', 4, 'colDetailUnitQty', '1')
            .selectGridComboBoxRowValue('UnitOfMeasure',5,'strUnitMeasure','KG','strUnitMeasure')
            .enterGridData('UnitOfMeasure', 5, 'colDetailUnitQty', '1')
            .waitUntilLoaded('')
            .clickTab('Setup')
            .waitUntilLoaded('')


            .clickTab('Location')
            .clickButton('AddLocation')
            .waitUntilLoaded('icitemlocation')
            .selectComboBoxRowValue('Location', location, 'Location',0)
            .clickButton('Save')
            .waitUntilLoaded()
            .verifyStatusMessage('Saved')
            .clickButton('Close')

            .clickButton('Save')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .clickButton('Close')
            .displayText('===== Other Charge Item Created =====')
            .done();

    },





    glGridFilter: function (t, next, filter){

        t.chain(
            { click: ">>#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab-sorted #grdSearch #tlbGridOptions #btnInsertCriteria"},
            { click: "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab-sorted #grdSearch #pnlFilter #con0 #cboColumns => .x-form-trigger"},
            { click: "#cboColumns.getPicker() => .x-boundlist-item:contains(Account Id)"},
            { click: "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab-sorted #grdSearch #pnlFilter #con0 #cboValueStoreFrom => .x-form-text"},
            { action: "type", options: { shiftKey: true}, text: filter + '[RETURN]'}
        );
        next();

    },

    gridClearFilter: function (t, next){

        t.chain(
            { click: "#pnlMain #pnlIntegratedDashboard #pnlIntegratedDashboardGridPanel #searchTabPanel #mainTab-sorted #grdSearch #pnlFilter #con0 #filterDeleteButton => .small-delete"}
        );
        next();

    },

//Codes by RCabangal
    addLocationToUser: function (t,next, user, location, defaultlocation, numberformat ) {
        new iRely.FunctionalTest().start(t, next)

            .displayText('===== Add Location to User =====')
            .clickMenuFolder('System Manager','Folder')
            .clickMenuScreen('Users','Screen')
            .waitUntilLoaded()
            .doubleClickSearchRowValue(user, 'strUsername', 1)
            //.waitUntilLoaded('ementity')
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .clickTab('User').waitUntilLoaded().waitUntilLoaded()
            .waitUntilLoaded()
            .clickTab('User Roles')

            .waitUntilLoaded()
            .filterGridRecords('UserRoleCompanyLocationRolePermission', 'FilterGrid', location)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() > 0;
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Location already exists.')
                        .addFunction(function(next){
                            t.chain(
                                { click : "#frmEntity #tabEntity #pnlUser #conEntityUserTab #tabUser #pnlUserRole #grdUserRoleCompanyLocationRolePermission #tlbGridOptions #txtFilterGrid => .x-form-trigger" }
                            );
                            next();
                        })
                        .clickTab('Detail')
                        .waitUntilLoaded()
                        .selectComboBoxRowValue('UserDefaultLocation', defaultlocation, 'strLocationName',1)
                        .waitUntilLoaded()
                        .clickButton('Save')
                        .waitUntilLoaded()

//                        .clickButton('Close')
//                        .waitUntilLoaded()
//                        .clickMessageBoxButton('no')
                        .waitUntilLoaded()
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdUserRoleCompanyLocationRolePermission').store.getCount() == 0;
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Location is not yet existing.')
                        .addFunction(function(next){
                            t.chain(
                                { click : "#frmEntity #tabEntity #pnlUser #conEntityUserTab #tabUser #pnlUserRole #grdUserRoleCompanyLocationRolePermission #tlbGridOptions #txtFilterGrid => .x-form-trigger" }
                            );
                            next();
                        })
                        .clickButton('UserRoleCompanyLocationAdd')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('UserRoleCompanyLocationRolePermission', 'Dummy','strLocationName', '0002 - Indianapolis','strLocationName', 1)
                        .selectGridComboBoxBottomRowValue('UserRoleCompanyLocationRolePermission', 'strUserRole', 'ADMIN', 'strUserRole', 5)
                        .clickTab('Detail')
                        .waitUntilLoaded()
                        .selectComboBoxRowValue('UserDefaultLocation', defaultlocation, 'strLocationName',1)
                        .waitUntilLoaded()
                        .selectComboBoxRowValue('UserNumberFormat', numberformat, 'UserNumberFormat',1)
                        .clickButton('Save')
                        .waitUntilLoaded()
//                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== Location added to user. =====')
                        .done()
                },
                continueOnFail: true
            })

            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
           // .clickMenuFolder('System Manager','Folder')
            .done();
    },

    assignDefaultARAccountCoConfig: function (t,next, araccountid) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('System Manager','Folder')
            .waitUntilLoaded('')
            .clickMenuScreen('Company Configuration','Screen')
            .waitUntilLoaded('smcompanypreference')
            .waitUntilLoaded('')
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .selectGridRowNumber('Settings',6)
            .waitUntilLoaded('')
            .selectComboBoxRowValue('ARAccount', araccountid,'ARAccount',1)
            .waitUntilLoaded('')
            .verifyData('Combo Box','ARAccount',araccountid)
            //.clickButton('Ok')
            .clickButton('Save')
            .waitUntilLoaded('')
            .clickButton('Close')
            //.clickMenuFolder('System Manager','Folder')
            .waitUntilLoaded()

            .done();
    },

    assignDefaultARandAPaccountCoLocation: function (t,next, location, araccountid, apaccountid) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Common Info','Folder')
            .waitUntilLoaded('')
            .clickMenuScreen('Company Locations','Screen')
            .doubleClickSearchRowValue(location, 1)
            .waitUntilLoaded('smcompanylocation')
            .clickTab('GL Accounts')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('ARAccount', araccountid, 'ARAccount',0)
            .waitUntilLoaded('')
            .verifyData('Combo Box','ARAccount',araccountid)
            .selectComboBoxRowValue('APAccount', apaccountid, 'APAccount',0)
            .waitUntilLoaded('')
            .verifyData('Combo Box','APAccount',apaccountid)
            .clickButton('Save')
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            //.clickMenuFolder('Common Info','Folder')
            .done();
    },

    addTaxClass: function (t,next, taxclass) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Common Info','Folder')
            .waitUntilLoaded('')
            .clickMenuScreen('Tax Class','Screen')
            .waitUntilLoaded()

            .filterGridRecords('GridTemplate', 'FilterGrid', taxclass)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdGridTemplate').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Tax Class already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdGridTemplate').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid')
                        .waitUntilLoaded()
                        .clickButton('Insert')
                        .enterGridData('GridTemplate', 1, 'colTaxClass', taxclass)
                        .clickButton('Save')
                        .waitUntilLoaded()
//                        .clickButton('Close')
//                        .waitUntilLoaded()
                        .displayText('===== Tax Class added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .clickButton('Close')
            .waitUntilLoaded()
            //.clickMenuFolder('Common Info','Folder')
            
            .done();
    },

    addTaxCode: function (t,next, taxclass, taxcode, taxdesc, taxaddress, taxzip, taxcity, taxstate, taxcountry, salestaxaccount, purchtaxaccount, taxcalcmethod, taxrate) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Common Info','Folder')
            .clickMenuScreen('Tax Codes','Screen')
            .waitUntilLoaded('')

            .filterGridRecords('Search', 'FilterGrid', taxcode)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Tax Code already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('smtaxcode')
                        .enterData('Text Field','TaxCode',taxcode)
                        .selectComboBoxRowValue('TaxClass',taxclass, 'TaxClass', 1)
                        .enterData('Text Field','Description',taxdesc)
                        .enterData('Text Field','Address',taxaddress)
                        .enterData('Text Field','ZipCode',taxzip)
                        .enterData('Text Field','City',taxcity)
                        .enterData('Text Field','State',taxstate)
                        .selectComboBoxRowValue('Country', taxcountry, 'Country',1)
                        .selectComboBoxRowValue('SalesTaxAccount', salestaxaccount,'SalesTaxAccount',1)
                        .selectComboBoxRowValue('PurchaseTaxAccount', purchtaxaccount,'PurchaseTaxAccount',1)
                        .addFunction (function (next){
                        var date = new Date().toLocaleDateString();
                        new iRely.FunctionalTest().start(t, next)
                            .selectGridComboBoxRowValue('TaxCodeRate',1,'colEffectiveDate',date,'dtmEffectiveDate', 0, 10)
                            .done();
                    })
                        .selectGridComboBoxRowValue('TaxCodeRate',1,'colCalculationMethod',taxcalcmethod,'strCalculationMethod',1)
                        .enterGridData('TaxCodeRate', 1, 'colRate', taxrate)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .displayText('===== Tax Code added. =====')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .done()
                },
                continueOnFail: true
            })
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .done();
    },

    addTaxGroup: function (t,next, taxgroup, taxgroupdesc, taxcode) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Common Info','Folder')
            .waitUntilLoaded('')
            .clickMenuScreen('Tax Groups','Screen')
            .waitUntilLoaded('')

            .filterGridRecords('Search', 'FilterGrid', taxgroup)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Tax Group already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .enterData('Text Field','TaxGroup',taxgroup)
                        .enterData('Text Field','Description',taxgroupdesc)
                        .selectGridComboBoxRowValue('TaxGroup',1,'colTaxCode',taxcode,'strTaxCode',1)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== Tax Group added. =====')
                        .done()
                },
                continueOnFail: true
            })

            .waitUntilLoaded()
            .waitUntilLoaded()
            .clickButton('Close')
            .done();

    },

    assignTaxCoLocation: function (t,next, location, taxgroup) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Common Info','Folder')
            .waitUntilLoaded('')
            .clickMenuScreen('Company Locations','Screen')
            .doubleClickSearchRowValue(location, 1)
            .waitUntilLoaded('smcompanylocation')
            .clickTab('Setup')
            .selectComboBoxRowValue('TaxGroup', taxgroup, 'TaxGroup',1)
            .waitUntilLoaded('')
            .verifyData('Combo Box','TaxGroup',taxgroup)
            .clickButton('Save')
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            .done();
    },

    addSubLocation: function (t,next, location, sublocation, sublocationdesc, classification) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Common Info','Folder')
            .waitUntilLoaded('')
            .clickMenuScreen('Company Locations','Screen')
            .doubleClickSearchRowValue(location, 1)
            .waitUntilLoaded('smcompanylocation') .waitUntilLoaded() .waitUntilLoaded() .waitUntilLoaded()
            .clickTab('Storage Location')
            .waitUntilLoaded('')

            .filterGridRecords('SubLocation', 'FilterGrid', sublocation)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSubLocation').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Sub Location already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSubLocation').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .enterGridNewRow('SubLocation', [
                            {column: 'strSubLocationName',data: sublocation},
                            {column: 'strSubLocationDescription',data: sublocationdesc},
                            {column: 'strClassification',data: classification}
                        ])
                        .clickButton('Save')
                        .waitUntilLoaded()
//                        .clickButton('Close')
//                        .waitUntilLoaded()
                        .displayText('===== Sub Location added. =====')
                        .done()
                },
                continueOnFail: true
            })

            .clickButton('Close')
            .waitUntilLoaded()
            .waitUntilLoaded()
            .clickButton('Close')
            .done();
    },

    addStorageLocation: function (t,next, storageloc, storagelocdesc, storageunittype, location, sublocation) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Storage Units','Screen')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', storageloc)
            .waitUntilLoaded()
.waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Storage Location already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('icstorageunit')
                        .enterData('Text Field','Name',storageloc)
                        .enterData('Text Field','Description',storagelocdesc)
                        .selectComboBoxRowValue('UnitType', storageunittype, 'UnitType',0)
                        .selectComboBoxRowValue('Location', location, 'Location',0)
                        .selectComboBoxRowValue('SubLocation', sublocation, 'SubLocation',0)
                       .clickButton('Save')
                        .waitUntilLoaded('')
                        .clickButton('Close')
                        .displayText('===== Storage Unit added =====')
                        .done()
                },
                continueOnFail: true
            })

            .waitUntilLoaded()
            .waitUntilLoaded()
            .clickButton('Close')
            .done();
    },

    addUOM: function (t,next, uom, symbol, unittype, decimals) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Inventory UOM','Screen')
            .waitUntilLoaded('')

            .filterGridRecords('Search', 'FilterGrid', uom)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('UOM already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .enterData('Text Field','UnitMeasure',uom)
                        .enterData('Text Field','Symbol',symbol)
                        .selectComboBoxRowNumber('UnitType',unittype,0)
//                        .selectComboBoxRowNumber('DecimalPlaces',decimals,0)
//                        .selectComboBoxRowValue('UnitType', unittype, 'UnitType',1)
//                        .selectComboBoxRowValue('Decimals', decimals, 'intDecimalPlaces', 1)
                        .selectComboBoxRowNumber('Decimals', decimals,0)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== UOM added =====')
                        .done()
                },
                continueOnFail: true
            })

            .waitUntilLoaded()
            .waitUntilLoaded()
            .clickButton('Close')
            .done();
    },

    addOtherUOM: function (t,next, uom, row, otheruom, conversionto) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Inventory UOM','Screen')
            .waitUntilLoaded('')

            .filterGridRecords('Search', 'FilterGrid', uom)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('===== Other UOM already exists. =====')
                        .doubleClickSearchRowValue (uom,'strUnitMeasure',1)
//                        .selectSearchRowValue(uom,'strUnitMeasure',1)
//                        .clickButton('Open')
                        .waitUntilLoaded()
                        .displayText('===== UOM record is opened. =====')
                        .clickButton('InsertConversion')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Conversion', row,'colOtherUOM', otheruom,'strUnitMeasure',1)
                        .enterGridData('Conversion', row, 'dblConversionToStock', conversionto)
                        .waitUntilLoaded()
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== Other UOM added =====')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('===== UOM does not exist. =====')
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .done()
                },
                continueOnFail: true
            })

            .waitUntilLoaded()
            .clickButton('Close')
            .done();
    },

    addItemCategory: function (t,next, categorycode, description, inventorytype, costingmethod, apclearing, inventory, cogs, sales, intransit, adj) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Inventory', 'Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Categories', 'Screen')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', categorycode)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Item Category already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('')
                        .enterData('Text Field', 'CategoryCode', categorycode)
                        .enterData('Text Field', 'Description', description)
                        .selectComboBoxRowNumber('InventoryType', inventorytype, 0)
                        .selectComboBoxRowNumber('CostingMethod', costingmethod, 0)

                        .clickTab('GL Accounts')
                        .clickButton('AddRequired')
                        .waitUntilLoaded()
                        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
                        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Inventory')
                        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Cost of Goods')
                        .verifyGridData('GlAccounts', 4, 'colAccountCategory', 'Sales Account')
                        .verifyGridData('GlAccounts', 5, 'colAccountCategory', 'Inventory In-Transit')
                        .verifyGridData('GlAccounts', 6, 'colAccountCategory', 'Inventory Adjustment')
                        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', apclearing, 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', inventory, 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', cogs, 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', sales, 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', intransit, 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', adj, 'strAccountId')

                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .displayText('===== Item Category added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .waitUntilLoaded('')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded('')
            .done();
    },

    addOtherChargeCategory: function (t,next, categorycode, description, inventorytype, costingmethod, apclearing, otherchargerev, otherchargeexp) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Inventory', 'Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Categories', 'Screen')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', categorycode)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Other Charge Category already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('')
                        .enterData('Text Field', 'CategoryCode', categorycode)
                        .enterData('Text Field', 'Description', description)
                        .selectComboBoxRowNumber('InventoryType', inventorytype, 0)
                        .selectComboBoxRowNumber('CostingMethod', costingmethod, 0)

                        .clickTab('GL Accounts')
                        .clickButton('AddRequired')
                        .waitUntilLoaded()
                        .verifyGridData('GlAccounts', 1, 'colAccountCategory', 'AP Clearing')
                        .verifyGridData('GlAccounts', 2, 'colAccountCategory', 'Other Charge Income')
                        .verifyGridData('GlAccounts', 3, 'colAccountCategory', 'Other Charge Expense')
                        .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', apclearing, 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', otherchargerev, 'strAccountId')
                        .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', otherchargeexp, 'strAccountId')
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .displayText('===== Other Charge Category added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .waitUntilLoaded('')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded('')
            .done();
    },

    addItemCommodity: function (t,next, commoditycode, description, row1, row2, row3, uom1, uom2, uom3, isstockunit, unitqty1, unitqty2, unitqty3) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Inventory', 'Folder')
            .waitUntilLoaded()
            .clickMenuScreen('Commodities', 'Screen')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', commoditycode)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Item Commodity already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded()
                        .enterData('Text Field','CommodityCode', commoditycode)
                        .enterData('Text Field','Description',description)
                        //.clickCheckBox('ExchangeTraded',true)
                        //.enterData('Text Field','DecimalsOnDpr','6.00')
                        //.enterData('Text Field','ConsolidateFactor','6.00')

                        .selectGridComboBoxRowValue('Uom', row1,'colUOMCode', uom1,'strUnitMeasure')
                        .clickGridCheckBox('Uom', row1,'colUOMStockUnit', uom1, 'ysnStockUnit', isstockunit)
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Uom', row2,'colUOMCode', uom2,'strUnitMeasure')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Uom',row3,'colUOMCode', uom3,'strUnitMeasure')
                        .waitUntilLoaded()

                        .verifyGridData('Uom', row1, 'colUOMUnitQty', unitqty1)
                        .verifyGridData('Uom', row2, 'colUOMUnitQty', unitqty2)
                        .verifyGridData('Uom', row3, 'colUOMUnitQty', unitqty3)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== Item Commodity added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .waitUntilLoaded('')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded('')
            .done();
    },

    addItem: function (t,next, item, itemtype, itemdesc, category, commodity, lottrack,
                       location1, costingmethod1, sublocation1, storagelocation1, saleuom1, receiveuom1, negativeinventory1,
                       location2, costingmethod2, sublocation2, storagelocation2, saleuom2, receiveuom2, negativeinventory2,
                       row1, priceLC1, priceSC1, pricingmethod1, rate1,
                       row2, priceLC2, priceSC2,pricingmethod2, rate2 ) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', item)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Item already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('')
                        .verifyScreenShown('icitem')
                        .enterData('Text Field','ItemNo', item)
                        .selectComboBoxRowNumber('Type', itemtype)
//                        .selectComboBoxRowValue('Type', itemtype, 'cboType',1)
                        .enterData('Text Field','Description', itemdesc)
                        .selectComboBoxRowValue('Category', category, 'cboCategory',1)
                        .selectComboBoxRowValue('Commodity', commodity, 'strCommodityCode',1)
                        .selectComboBoxRowNumber('LotTracking', lottrack)

                        .clickTab('Setup')
                        .clickTab('Location')
                        .clickButton('AddLocation')
                        .waitUntilLoaded('')
                        .selectComboBoxRowValue('Location', location1, 'intLocationId',0)
                        .selectComboBoxRowNumber('CostingMethod', costingmethod1, 0)
                        .selectComboBoxRowValue('SubLocation', sublocation1, 'intSubLocationId',0)
                        .selectComboBoxRowValue('StorageLocation', storagelocation1, 'intStorageLocationId',0)
                        .selectComboBoxRowValue('IssueUom', saleuom1, 'intUnitMeasure',0)
                        .selectComboBoxRowValue('ReceiveUom', receiveuom1, 'intUnitMeasure',0)
                        .selectComboBoxRowValue('NegativeInventory', negativeinventory1, 'intNegativeInventory',0)

                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')

                        .clickButton('AddLocation')
                        .waitUntilLoaded('')
                        .selectComboBoxRowValue('Location', location2, 'intLocationId',0)
                        .selectComboBoxRowNumber('CostingMethod', costingmethod2, 0)
                        .selectComboBoxRowValue('SubLocation', sublocation2, 'intSubLocationId',0)
                        .selectComboBoxRowValue('StorageLocation', storagelocation2, 'intStorageLocationId',0)
                        .selectComboBoxRowValue('IssueUom', saleuom2, 'intUnitMeasure',0)
                        .selectComboBoxRowValue('ReceiveUom', receiveuom2, 'intUnitMeasure',0)
                        .selectComboBoxRowValue('NegativeInventory', negativeinventory2, 'intNegativeInventory',0)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')

                        .displayText('===== Setup Item Pricing=====')
                        .clickTab('Pricing')
                        .waitUntilLoaded('')
                        .verifyGridData('Pricing', row1, 'strLocationName', '0001 - Fort Wayne')
                        .enterGridData('Pricing', row1, 'dblLastCost', priceLC1)
                        .enterGridData('Pricing', row1, 'dblStandardCost', priceSC1)
                        .selectGridComboBoxRowNumber('Pricing', row1, 'strPricingMethod', pricingmethod1)
                        .enterGridData('Pricing', row1, 'dblAmountPercent', rate1)

                        .verifyGridData('Pricing', row2, 'strLocationName', '0002 - Indianapolis')
                        .enterGridData('Pricing', row2, 'dblLastCost', priceLC2)
                        .enterGridData('Pricing', row2, 'dblStandardCost', priceSC2)
                        .selectGridComboBoxRowNumber('Pricing', row2, 'strPricingMethod',pricingmethod2)
                        .enterGridData('Pricing', row2, 'dblAmountPercent', rate2)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .displayText('===== Item added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .waitUntilLoaded()
            //.clickMenuFolder('Inventory','Folder')
             .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded('')
            .done();
    },

    addOtherChargeItem: function (t,next, item, itemtype, itemdesc, category, commodity,
                       location1, costingmethod1, sublocation1, storagelocation1, saleuom1, receiveuom1, negativeinventory1,
                       location2, costingmethod2, sublocation2, storagelocation2, saleuom2, receiveuom2, negativeinventory2,
                       inventorycost, accrue, price, costtype, costmethod, amount, uom
                       ) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', item)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Other Charge Item already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('')
                        .verifyScreenShown('icitem')
                        .enterData('Text Field','ItemNo', item)
                        .selectComboBoxRowNumber('Type', itemtype)
//                        .selectComboBoxRowValue('Type', itemtype, 'cboType',1)
                        .enterData('Text Field','Description', itemdesc)
                        .selectComboBoxRowValue('Category', category, 'cboCategory',1)
                        .selectComboBoxRowValue('Commodity', commodity, 'strCommodityCode',1)
//                        .selectComboBoxRowNumber('LotTracking', lottrack)

                        .displayText('===== Setup - Location tab =====')
                        .clickTab('Setup')
                        .clickTab('Location')
                        .clickButton('AddLocation')
                        .waitUntilLoaded('')
                        .selectComboBoxRowValue('Location', location1, 'intLocationId',0)
                        .selectComboBoxRowNumber('CostingMethod', costingmethod1, 0)
                        .selectComboBoxRowValue('SubLocation', sublocation1, 'intSubLocationId',0)
                        .selectComboBoxRowValue('StorageLocation', storagelocation1, 'intStorageLocationId',0)
                        .selectComboBoxRowValue('IssueUom', saleuom1, 'intUnitMeasure',0)
                        .selectComboBoxRowValue('ReceiveUom', receiveuom1, 'intUnitMeasure',0)
                        .selectComboBoxRowValue('NegativeInventory', negativeinventory1, 'intNegativeInventory',0)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')

                        .clickButton('AddLocation')
                        .waitUntilLoaded('')
                        .selectComboBoxRowValue('Location', location2, 'intLocationId',0)
                        .selectComboBoxRowNumber('CostingMethod', costingmethod2, 0)
                        .selectComboBoxRowValue('SubLocation', sublocation2, 'intSubLocationId',0)
                        .selectComboBoxRowValue('StorageLocation', storagelocation2, 'intStorageLocationId',0)
                        .selectComboBoxRowValue('IssueUom', saleuom2, 'intUnitMeasure',0)
                        .selectComboBoxRowValue('ReceiveUom', receiveuom2, 'intUnitMeasure',0)
                        .selectComboBoxRowValue('NegativeInventory', negativeinventory2, 'intNegativeInventory',0)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')

                        .displayText('===== Setup - Cost tab =====')
                        .clickTab('Cost')
                        .clickCheckBox('InventoryCost',inventorycost)
                        .clickCheckBox('Accrue', accrue)
                        .clickCheckBox('Price', price)
                        .selectComboBoxRowValue('CostType', costtype, 'strCostType',0)
                        //.selectComboBoxRowValue('OnCost', oncost, 'intOnCostTypeId',0)
                        .selectComboBoxRowValue('CostMethod', costmethod, 'strCostMethod',0)
                        .enterData('Text Field','Amount', amount)
                        .selectComboBoxRowValue('CostUOM', uom, 'intCostUOMId',0)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .displayText('===== Item added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .waitUntilLoaded()
            //.clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded()
             .waitUntilLoaded()
            .clickButton('Close')
            .done();
    },

    addVendor: function (t,next, vendor, contact, phone, email, address, city, state, zip, country, timezone, vendorlocation, terms, freightterms, currency) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Purchasing (A/P)')
            .waitUntilLoaded('')
            .clickMenuScreen('Vendors')
            .waitUntilLoaded('')

            .filterGridRecords('Search', 'FilterGrid', vendor)
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Vendor already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('emcreatenewentity')
                        .enterData('Text Field','Name', vendor)
                        .enterData('Text Field','Contact',contact)
                        .enterData('Text Field','Phone', phone)
                        .enterData('Text Field','Email', email)
                        .enterData('Text Field','Address',address)
                        .enterData('Text Field','City', city)
                        .enterData('Text Field','State', state)
                        .enterData('Text Field','ZipCode', zip)
                        .selectComboBoxRowValue('Country', country, 'intDefaultCountryId',0)
                        .selectComboBoxRowValue('Timezone', timezone, 'strTimezone',0)
                        .clickButton('Match')
                        .waitUntilLoaded('emduplicateentities')
                        .clickButton('Add')
                        .waitUntilLoaded()
                        .enterData('Text Field','Location', vendorlocation)

                        //.clickTab('Vendor')
                         .addFunction(function (next) {
                                t.chain(
                                    { click : "#frmEntity #tabEntity #pgeMainVendor => .x-tab-inner" }
                                )
                                next();
                            })
                        .waitUntilLoaded()
                        .selectComboBoxRowValue('VendorCurrency', currency, 'intCurrencyId',0)
                        .selectGridComboBoxRowValue('VendorTerm',1,'colVendorTerms', terms,'strTerm')
                        .selectComboBoxRowValue('VendorTerms', terms, 'intTermsId',5)

                        .displayText('===== Enter Vendor Location details. =====')
                        .clickTab('Locations')
                        .waitUntilLoaded()
                        .selectGridRowNumber('Location',1)
                        .clickButton('EditLoc')
//                        .clickButton('Location')
                        .waitUntilLoaded('ementitylocation')
                        .selectComboBoxRowValue('Terms', terms, 'intTermsId',5)
                        .selectComboBoxRowValue('FreightTerm', freightterms, 'intFreightTermId',0)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()

                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .waitUntilLoaded()
                        .displayText('===== Vendor added. =====')
                        .done()
                },
                continueOnFail: true
            })

            .waitUntilLoaded()
            //.clickMenuFolder('Purchasing (Accounts Payable)','Folder')
             .waitUntilLoaded('')
            .clickButton('Close')
            .done();
    },
    addCustomer: function (t,next, customer, customercontact, phone, email, address, city, state, zip, country, timezone,
                           customerlocation, terms, shipvia, taxgroup, location, freighterm) {
        new iRely.FunctionalTest().start(t, next)
            .clickMenuFolder('Sales (A/R)')
            .waitUntilLoaded()
            .clickMenuScreen('Customers')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', customer)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() > 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .displayText('Customer already exists.')
                        .done()
                },
                continueOnFail: true
            })

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdSearch').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clickButton('New')
                        .waitUntilLoaded('emcreatenewentity')
                        .enterData('Text Field','Name', customer)
                        .enterData('Text Field','Contact',customercontact)
                        .enterData('Text Field','Phone', phone)
                        .enterData('Text Field','Email', email)
                        .enterData('Text Field','Address', address)
                        .enterData('Text Field','City', city)
                        .enterData('Text Field','State', state)
                        .enterData('Text Field','ZipCode',zip)
                        .selectComboBoxRowValue('Country', country, 'intDefaultCountryId',0)
                        .selectComboBoxRowValue('Timezone', timezone, 'Timezone',0)
                        .clickButton('Match')
                        .waitUntilLoaded('emduplicateentities')
                        .clickButton('Add')
                        .enterData('Text Field','Location', customerlocation)

                        .addFunction(function (next) {
                            t.chain(
                                { click : "#frmEntityCustomer #tabEntity #pgeMainCustomer => .x-tab-inner" }
                            )
                            next();
                        })
                        .waitUntilLoaded('')
                        .selectComboBoxRowValue('CustomerTerms', terms, 'CustomerTerms',5)
                        .selectComboBoxRowNumber('CustomerSalesperson',1,0)

                        .displayText('===== Enter Vendor Location details. =====')
                        .clickTab('Locations')
                        .selectGridRowNumber('Location',1)
                        .clickButton('EditLoc')
                        .waitUntilLoaded('')
                        //.selectComboBoxRowValue('Country', country, 'Country',0)
                        .selectComboBoxRowValue('ShipVia', shipvia, 'intShipViaId',0)
                        .selectComboBoxRowValue('TaxGroup', taxgroup, 'intTaxGroupId',0)
                        .selectComboBoxRowValue('Terms', terms, 'intTermsId',5)
                        .selectComboBoxRowValue('Warehouse', location, 'intWarehouseId',0)
                        .selectComboBoxRowValue('FreightTerm', freighterm, 'intFreightTermId',0)
                        .clickButton('Save')
                        .waitUntilLoaded('')
                        .clickButton('Close')
                        .waitUntilLoaded('')
                        .clickButton('Save')
                        .waitUntilLoaded('')
                        .clickButton('Close')
                        .waitUntilLoaded('')
                        .displayText('===== Customer added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .waitUntilLoaded()
            //.clickMenuFolder('Sales (Accounts Receivable)')
             .waitUntilLoaded('')
            .clickButton('Close')
            .done();
    },

    addTaxClassToCategory: function (t,next, item, taxclass  ) {
        new iRely.FunctionalTest().start(t, next)

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .waitUntilLoaded()

            .doubleClickSearchRowValue(item, 1)
            .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
            .clickLabel('Category')
            .waitUntilLoaded()
            .filterGridRecords('Tax', 'FilterGrid', taxclass)
            .waitUntilLoaded()

            .continueIf({
                expected: true,
                actual: function(win){
                    return win.down('#grdTax').store.getCount() == 0
                },
                success: function(next){
                    new iRely.FunctionalTest().start(t, next)
                        .clearTextFilter('FilterGrid')
                        .clickButton('InsertTax')
                        .waitUntilLoaded()
                        .selectGridComboBoxRowValue('Tax',1,'colTaxClass', taxclass, 'strTaxClass',1)
                        .verifyGridData ('Tax', 1 ,'colTaxClass' , taxclass)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .displayText('===== Tax Class added. =====')
                        .done()
                },
                continueOnFail: true
            })
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            .waitUntilLoaded()
            .clickButton('Close')
            //.clickMenuFolder('Inventory','Folder')
            .waitUntilLoaded('')
            .done();
    },

    setupCostTab: function (t,next, item, inventorycost, accrue, price, costtype, costmethod, amount, uom) {
        new iRely.FunctionalTest().start(t, next)

            .displayText('===== 1. Other Charge setup  =====')
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .waitUntilLoaded()

            .filterGridRecords('Search', 'FilterGrid', item)
            .waitUntilLoaded()

            .doubleClickSearchRowNumber(1)
            .waitUntilLoaded()

            .displayText('===== Setup - Cost tab =====')
            .clickTab('Setup')
            .waitUntilLoaded()
            .clickTab('Cost')
            .waitUntilLoaded()
            .clickCheckBox('InventoryCost',inventorycost)
            .clickCheckBox('Accrue', accrue)
            .clickCheckBox('Price', price)
            .selectComboBoxRowValue('CostType', costtype, 'strCostType',0)
            //.selectComboBoxRowValue('OnCost', oncost, 'intOnCostTypeId',0)
            .selectComboBoxRowValue('CostMethod', costmethod, 'strCostMethod',0)
            .enterData('Text Field','Amount', amount)
            .selectComboBoxRowValue('CostUOM', uom, 'intCostUOMId',0)
            .clickButton('Save')
            .waitUntilLoaded()
            .clickButton('Close')
            //.clickMenuFolder('Inventory','Folder')
            
            .waitUntilLoaded('')
            .clickButton('Close')
            .done();
    },







////////////////////////////////////////////////////////////////////////
//Start Jerome Paul Fazon Codes
////////////////////////////////////////////////////////////////////////
 getNextItemNumber: function (t,next) {
        record=Math.floor((Math.random() * 1000000) + 1);
        new iRely.FunctionalTest().start(t, next)
        .enterData('Text Field','ItemNo', record)
        .done();
    },
 getGeneratedItemNumber: function (t,next) {
        new iRely.FunctionalTest().start(t, next)
        .selectGridComboBoxRowValue('ItemNo',1,'strItemNo', '', 'ItemNo',1)    
        .done();
    },   
 getGridComboColumnDefaults: function (t,next,gridID,itemID) {
        var grid = gridID;
        var column=itemID;
        var currentCount =1;
         //insertCategoryDefaultAccounts(currentCount,gridID,column);
      for(i=1;i<=6;i){
    
            var insertCategoryDefaultAccounts = function(){
                new iRely.FunctionalTest().start(t, next)
                //.selectGridComboBoxRowNumber(gridID,currentCount,itemID,1)
                .displayText(gridID)
                .displayText(i)
                .displayText(itemID)
                .selectGridComboBoxRowNumber('GlAccounts',i, 'colGLAccountId', 2 )
               
                .done()
            }
            
            setInterval(insertCategoryDefaultAccounts(t,next,i,'GlAccounts','colGLAccountId'),50000);  
           i++;
           
         }    
 },



insertInventoryItem: function(t,next,productID){
    new iRely.FunctionalTest().start(t, next)
        .clickMenuScreen('Items')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('')
            .enterData('Text Field','ItemNo', productID)
            .enterData('Text Field','Description', 'Sample Description')
            .selectComboBoxRowNumber('Commodity', 0)
            .selectComboBoxRowNumber('Category', 6)
            .selectComboBoxRowNumber('LotTracking', 0)
            // .enterData('Text Field','FilterGrid', 'Bushels[ENTER]')
            // .continueIf({
            //         expected: 0,
            //         actual: function(Integer){
            //             return gridUnitOfMeasure.getStore().count();
            //         },
            //         success: function(next){
            //             new iRely.FunctionalTest().start(t, next)
            //                 .clickButton('InsertUOM')
            //                 .done()
            //         },
            //         continueOnFail: true,
            //         successMessage : 'Bushels UOM Added',
            //         failMessage: 'Duplicate UOM (Not a Bug)'
            //     })


            .clickTab('Setup')    
            .clickButton('AddRequiredAccounts')
            .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
            .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
            .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
            .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
            .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
            .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
            .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
            .addResult('======== Setup GL Accounts Successful ========')
            .clickTab('Location') 
            .clickButton('AddLocation')
            .waitUntilLoaded('icitemlocation')
            .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)    
            .selectComboBoxRowValue('CostingMethod', 'AVG', 'CostingMethod',1)    
            .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',1)    
            .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',1)
            .selectComboBoxRowValue('IssueUom', 'Bushels', 'IssueUom',1)  
            .selectComboBoxRowValue('ReceiveUom', 'Bushels', 'ReceiveUom',1)  
            .selectComboBoxRowNumber('NegativeInventory',0)  
            
            .clickButton('Save')
            .clickButton('Close')
            .waitUntilLoaded('icitem')
            .clickButton('Save')
            .clickButton('Close')
           // .waitUntilLoaded()
            
            .done()
        
},
createPurchaseOrder: function (t,next,ProductID){
                new iRely.FunctionalTest().start(t, next)
                .displayText(ProductID)
                .clickMenuFolder('Purchasing (A/P)')
                .clickMenuScreen('Purchase Orders')
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded('')
                .waitUntilLoaded()
                .selectComboBoxRowValue('VendorId', 'ABC Trucking', 'VendorId',1)    
                .selectComboBoxRowValue('ShipTo', '0001 - Fort Wayne', 'ShipTo',1)
                .selectComboBoxRowValue('ShipFrom', 'Office', 'ShipFrom',1)
                .selectComboBoxRowValue('ShipVia1', 'Trucks', 'ShipVia1',1)
                
                .selectGridComboBoxRowValue('Items',1,'strItemNo', ProductID ,'strItemNo') 
                .enterGridData('Items',1,'dblQtyOrdered',100)
                .enterGridData('Items',1,'dblCost',10)
                .clickButton('Save')
                .done()
},

 /**
     * Add InventoryReceipt
     *
     * @param {Integer} itemQty - QTyOrdered
     *
     * @param {Bool} toPost - true or false
     *
     */

createInventoryReceipt: function (t,next,itemQty,toPost,cost) {
                new iRely.FunctionalTest().start(t, next)
                //.displayText(PONumber)
                
                .waitUntilLoaded()
                .clickMenuScreen('Inventory Receipts')
                .clickButton('New')
                .waitUntilLoaded('')
                .selectComboBoxRowNumber('ReceiptType',2) 
                .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1) 
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .waitUntilLoaded()
                .addResult('Processing PO to IR',3000)
                .selectSearchRowNumber(1)
                .clickButton('OpenSelected')
                .waitUntilLoaded('icinventoryreceipt')
//               .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',1)
                .selectGridRowNumber('InventoryReceipt', 1)
                .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure',itemQty, 'Bushels')
                 .waitUntilLoaded()
                .enterGridData('InventoryReceipt', 1, 'colUnitCost', cost)
                .selectGridComboBoxRowValue('InventoryReceipt',1,'colWeightUOM', 'Bushels' ,'strWeightUOM',1)
                .enterGridData('LotTracking',1,'colLotId','Sample Parent Lot [TAB]')
                .enterGridData('LotTracking',1,'colLotQuantity',itemQty)
                .selectGridRowNumber('InventoryReceipt', 1)                  
                .clickTab('PostPreview')
                .waitUntilLoaded()
                .clickButton('Save') 
                .waitUntilLoaded()
                .continueIf({
                    expected: true,
                    actual: function(Bool){
                        return toPost;
                    },
                    success: function(next){
                        new iRely.FunctionalTest().start(t, next)
                            .clickButton('Post')
                            .waitUntilLoaded('icinventoryreceipt')
                            .done()
                    },
                    continueOnFail: true,
                    successMessage : 'Transaction Posted.',
                    failMessage: 'Transaction should not Post, Save only. (Not a Bug)'
                })
                .clickButton('Close')
                .done() 
},
checkIfClosedPOShowsInIR: function (t,next,PONumber){
                new iRely.FunctionalTest().start(t, next)
                 .clickMenuFolder('Inventory')
                 .clickMenuScreen('Inventory Receipts')
                // .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded('')
                .selectComboBoxRowNumber('ReceiptType',2) 
                .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
                .waitUntilLoaded()
                .enterData('Text Field','FilterGrid', PONumber)
                .enterData('Text Field','FilterGrid', '[Enter]')
                .verifyGridRecordCount('Search', 0)
                .displayText('if grid count is correct, success!!!')
                .clickButton('Close') 
                .clickButton('Save')
                .waitUntilLoaded()
                .clickButton('Close') 
                // .clickMenuFolder('Inventory')
                // .clickMenuFolder('Purchasing (Accounts Payable)')
                .done()
}
,
buildAccount: function(t,next){
   //.addScenario('0','Add GL Accounts',1000)
   //.addFunction(function(next){
        var ysnBuildPrimaryAccount ="false";
        var ysn20022=false,ysn15012=false,ysn50012=false,ysn40012=false,ysn16012=false,ysn50022=false,ysn12012=false,ysn20012=false,ysn49012=false,ysn59012=false,ysn25012=false,ysn72512=false;
        var selectPrimarySegments = function(ysnSelectID,accountID){
            new iRely.FunctionalTest().start(t, next,ysnSelectID,accountID)
            .continueIf({
                expected: true,
                actual: function (bool) {
                    return ysnSelectID;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                
                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', accountID)
                    .waitUntilLoaded()
                    .waitUntilLoaded()
                    .addFunction(function (next) {
                        t.chain(
                            { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                        )
                        next();
                    })
                    .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                    .done()
                },
                    continueOnFail: true   
            })
            .done()   
        };
                     
        new iRely.FunctionalTest().start(t, next)
        .clickMenuFolder('General Ledger').waitUntilLoaded()
        .clickMenuScreen('GL Account Detail').waitUntilLoaded()
        .clickButton('Segments')
        .waitUntilLoaded('glsegmentaccounts').waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .selectGridRowNumber('SegmentName', 1)
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '20022' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 20022 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn20022=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 20022 does not exists.')
                    .addStep('Add Primary Account 20022' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '20022'}
                                                        ,{column: 'strDescription', data: 'AP Clearing'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '20022' +'[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Pending Payables' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'AP Clearing' ,'strAccountCategory',1) 
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '15012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 15012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn15012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 15012 does not exists.')
                    .addStep('Add Primary Account 15012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '15012'}
                                                        ,{column: 'strDescription', data: 'Inventories'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '15012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Inventories' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Inventory' ,'strAccountCategory',1) 
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '50012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                }, 
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 50012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn50012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 50012 does not exists.')
                    .addStep('Add Primary Account 50012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '50012'}
                                                        ,{column: 'strDescription', data: 'COGS'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '50012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Cost of Goods Sold' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Cost of Goods' ,'strAccountCategory',1) 
                    .done()    
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '40012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },   
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 40012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn40012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 40012 does not exists.')
                    .addStep('Add Primary Account 40012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '40012'}
                                                        ,{column: 'strDescription', data: 'Sales'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '40012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Sales' ,'strAccountGroup',2)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Sales Account' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '16012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },   
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 16012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn16012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 16012 does not exists.')
                    .addStep('Add Primary Account 16012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '16012'}
                                                        ,{column: 'strDescription', data: 'Inventory In Transit'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '16012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Inventories' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Inventory In-Transit' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '50022' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },  
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 50022 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn50022=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 50022 does not exists.')
                    .addStep('Add Primary Account 50022' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '50022'}
                                                        ,{column: 'strDescription', data: 'Inventory Adjustment'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '50022[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Cost of Goods Sold' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Inventory Adjustment' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '12012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },  
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 12012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn12012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 12012 does not exists.')
                    .addStep('Add Primary Account 12012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '12012'}
                                                        ,{column: 'strDescription', data: 'Accounts Receivable'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '12012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Receivables' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'AR Account' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '20012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },   
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 20012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn20012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 20012 does not exists.')
                    .addStep('Add Primary Account 20012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '20012'}
                                                        ,{column: 'strDescription', data: 'Accounts Payable'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '20012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Payables' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'AP Account' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '49012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },  
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 49012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn49012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 49012 does not exists.')
                    .addStep('Add Primary Account 49012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '49012'}
                                                        ,{column: 'strDescription', data: 'Other Charge Income'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '49012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Other Income' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Other Charge Income' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '59012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },  
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 59012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn59012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 59012 does not exists.')
                    .addStep('Add Primary Account 59012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '59012'}
                                                        ,{column: 'strDescription', data: 'Other Charge Expense'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '59012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Other Expense' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Other Charge Expense' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '25012' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },   
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 25012 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn25012=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 25012 does not exists.')
                    .addStep('Add Primary Account 25012' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '25012'}
                                                        ,{column: 'strDescription', data: 'Sales Tax Liability'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '25012[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Sales Tax Payables' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Sales Tax Account' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
         .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .filterGridRecords('SegmentAccounts', 'FilterGrid', '72512' +'[ENTER]')
        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
        .continueIf({
                expected: true,
                actual: function (win) {
                    return win.down('#grdSegmentAccounts').getStore().getCount() !== 0;
                },    
                success: function (next) {
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 72512 exists.')
                    .clearTextFilter('FilterGrid')
                    .done()
                },
                failure: function(next){
                    ysnBuildPrimaryAccount=true;
                    ysn72512=true;
                    new iRely.FunctionalTest().start(t, next)
                    .addResult('Primary Account 72512 does not exists.')
                    .addStep('Add Primary Account 72512' )
                    .clearTextFilter('FilterGrid')
                    .enterGridNewRow('SegmentAccounts', [{column: 'strCode', data: '72512'}
                                                        ,{column: 'strDescription', data: 'Tax Expense'}
                                                    ])
                    .filterGridRecords('SegmentAccounts', 'FilterGrid', '72512[ENTER]')                                   
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountGroup', 'Other Expenses' ,'strAccountGroup',1)
                    .selectGridComboBoxRowValue('SegmentAccounts',1,'colAccountCategory', 'Purchase Tax Account' ,'strAccountCategory',1) 
                    .done()
                },
                continueOnFail: true   
        })
        .continueIf({
                    expected: 'true',
                    actual: function (string) {
                        return ysnBuildPrimaryAccount.toString();
                    },
                    success: function (next) {
                        new iRely.FunctionalTest().start(t, next)
                        .clickButton('Save')
                        .waitUntilLoaded()
                        .clickButton('Build')
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .waitUntilLoaded()
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn20022;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '20022')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn15012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '15012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn50012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '50012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn40012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '40012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn16012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '16012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn50022;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '50022')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn12012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '12012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn20012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '20012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn49012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '49012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn59012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '59012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn25012;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '25012')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
        
                        .continueIf({
                            expected: true,
                            actual: function (bool) {
                                return ysn72512;
                            },
                            success: function (next) {
                                new iRely.FunctionalTest().start(t, next)
                            
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '72512')
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .addFunction(function (next) {
                                    t.chain(
                                        { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #grvPrimarySegment => .x-grid-row-checker" }
                                    )
                                    next();
                                })
                                .filterGridRecords('BuildAccountsPrimarySegment', 'FilterGrid', '')
                                .done()
                            },
                                continueOnFail: true   
                        })
                        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
                        .waitUntilLoaded().waitUntilLoaded().waitUntilLoaded().waitUntilLoaded()
                        .addFunction(function (next) {         
                            t.chain(
                                 { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsPrimarySegment #tlbGridOptions #txtFilterGrid => .x-form-trigger" }
                                )
                                next();
                            }) 
                        .waitUntilLoaded()
                        .waitUntilLoaded()           
                        .filterGridRecords('BuildAccountsSegment', 'FilterGrid', 'Grains')
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .addFunction(function (next) {
                            t.chain(
                                { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsSegment #grvSegment => .x-grid-row-checker" }
                            )
                            next();
                        })
                        .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '')
                        .filterGridRecords('BuildAccountsSegment', 'FilterGrid', 'Fort Wayne')
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .addFunction(function (next) {
                            t.chain(
                                { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsSegment #grvSegment => .x-grid-row-checker" }
                            )
                            next();
                        })
                        .filterGridRecords('BuildAccountsSegment', 'FilterGrid', '')
                        .filterGridRecords('BuildAccountsSegment', 'FilterGrid', 'Indianapolis')
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .addFunction(function (next) {
                            t.chain(
                                { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsSegment #grvSegment => .x-grid-row-checker" }
                            )
                            next();
                        })
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .addFunction(function (next) {
                            t.chain(
                                { click : "#frmBuildAccounts #tabBuildAccounts #grdBuildAccountsSegment #tlbGridOptions #txtFilterGrid => .x-form-trigger" }
                            )
                            next();
                        })
                        .clickButton('Build')
                        .waitUntilLoaded()
                        .clickButton('Commit')
                        .waitUntilLoaded()
                        .addFunction(function(next){
                            var msg = document.querySelector('.sweet-alert'),
                                message = msg.querySelector('p').innerHTML;
                            if (msg){
                                if(msg.querySelector('p').innerHTML === message){
                                new iRely.FunctionalTest().start(t, next)
                                .verifyMessageBox('iRely i21', msg.querySelector('p').innerHTML, 'ok', 'information')
                                .displayText(msg.querySelector('p').innerHTML)
                                .waitUntilLoaded()
                                .waitUntilLoaded()
                                .clickMessageBoxButton('ok')
                                .done()
                                }else{
                                    new iRely.FunctionalTest().start(t, next)
                                    .displayText('Skip message')
                                    .done()
                                }
                            
                            }
                        })
                        .waitUntilLoaded()
                        .waitUntilLoaded()
                        .clickButton('Close')
                        .done()
                    },
                    continueOnFail: true
         })                   
        .waitUntilLoaded()
        .waitUntilLoaded()
        .clickButton('Close')
        .clickButton('Close')
                           
        .done()
   

}

////////////////////////////////////////////////////////////////////////    
//End Jerome Paul Fazon Codes
////////////////////////////////////////////////////////////////////////






});