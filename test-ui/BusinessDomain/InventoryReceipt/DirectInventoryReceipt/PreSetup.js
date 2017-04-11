StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)


        //Presetup

        //Add Category
        .displayText('===== Create Category =====')
        .addFunction(function(next){
            commonIC.addCategory (t,next, 'DIR - Category', 'Test Category Description', 2)
        })
        .displayText('===== Create Category Done =====')

        //Add Commodity
        .displayText('===== Create Commodity =====')
        .addFunction(function(next){
            commonIC.addCommodity (t,next, 'DIR - Commodity', 'Test Commodity Description')
        })
        .displayText('===== Create Commodity Done =====')


        //Add Non Lotted Item
        .displayText('===== Create Non Lotted Item =====')
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Direct - NLTI - 01'
                , 'Test Non Lotted Item Description'
                , 'DIR - Category'
                , 'DIR - Commodity'
                , 4
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })
        .displayText('===== Create Non Lotted Item Done =====')

        //Add Lotted Item - Manual
        .displayText('===== Create Lotted Item =====')
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'Direct - LTI - 01'
                , 'Test Lotted Item Description'
                , 'DIR - Category'
                , 'DIR - Commodity'
                , 3
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })
        .displayText('===== Create Non Lotted Item Done =====')


        .displayText('=====  Add Inventory UOM =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory UOM','Screen')
        .clickButton('New')
        .waitUntilLoaded('')
        .enterData('Text Field','UnitMeasure','Test_25 KG Bag')
        .enterData('Text Field','Symbol','Test_25 KG Bag')
        .selectComboBoxRowNumber('UnitType',7,0)

        .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',11)
        .enterGridData('Conversion', 1, 'dblConversionToStock', '25')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')

        .clickButton('New')
        .waitUntilLoaded('icinventoryuom')
        .enterData('Text Field','UnitMeasure','Test_50 KG Bag')
        .enterData('Text Field','Symbol','Test_50 KG Bag')
        .selectComboBoxRowNumber('UnitType',7,0)

        .selectGridComboBoxRowNumber('Conversion',1,'colOtherUOM',11)
        .enterGridData('Conversion', 1, 'dblConversionToStock', '50')
        .verifyStatusMessage('Edited')
        .clickButton('Save')
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')


        .displayText('===== Add Commodity KG Stock Unit =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','CommodityCode','DIR - Commodity - 01')
        .enterData('Text Field','Description','Test Corn Commodity')
        .enterData('Text Field','DecimalsOnDpr','6.00')

        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','KG','strUnitMeasure')
        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'KG', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','Test_25 KG Bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Test_50 KG Bag','strUnitMeasure')
        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')


        .displayText('===== Create Lotted Item Stock Unit KG =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .enterData('Text Field','ItemNo','Direct - LTI - 02')
        .enterData('Text Field','Description','Test Lotted Item Direct - LTI - 01')
        .selectComboBoxRowValue('Category', 'DIR - Category', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'DIR - Commodity - 01', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',3,0)
        .verifyData('Combo Box','Tracking','Lot Level')

        .displayText('===== Setup Item GL Accounts=====')
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


        .displayText('===== Setup Item Location=====')
        .clickTab('Location')
        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'KG', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'KG', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'KG', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'KG', 'ReceiveUom',0)
        .clickButton('Save')
        .clickButton('Close')

        .displayText('===== Setup Item Pricing=====')
        .clickTab('Pricing')
        .waitUntilLoaded('')
        .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
        .enterGridData('Pricing', 1, 'dblLastCost', '10')
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

        .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')
        .enterGridData('Pricing', 2, 'dblLastCost', '10')
        .enterGridData('Pricing', 2, 'dblStandardCost', '10')
        .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
        .enterGridData('Pricing', 2, 'dblAmountPercent', '40')
        .clickButton('Save')
        .clickButton('Close')

        .done();

})