StartTest (function (t) {
    var commonIC = Ext.create('Inventory.CommonIC');
    new iRely.FunctionalTest().start(t)

        //region Preseteup

        //Add Category
        .addFunction(function(next){
            commonIC.addCategory (t,next, 'TestGrains3', 'Test Category Description', 2)
        })

        .displayText('=== Creating Commodity ===')
        .addFunction(function(next){
            commonIC.addCommodity (t,next, 'TestCorn3', 'Test Commodity Description')
        })
        .displayText('=== Commodity Created ===')

        //Add Non Lotted Item
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'ITNLTI - 01'
                , 'Test Non Lotted Item Description'
                , 'TestGrains3'
                , 'TestCorn3'
                , 4
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })

        //Add Lotted Item - Manual
        .addFunction(function(next){
            commonIC.addInventoryItem
            (t,next,
                'ITLTI - 01'
                , 'Test Lotted Item Description'
                , 'TestGrains3'
                , 'TestCorn3'
                , 3
                , 'LB'
                , 'LB'
                , 10
                , 10
                , 40
            )
        })

        //region Add Non Lotted Item - Negative Inventory Yes
        .displayText('===== Add Non Lotted Item Negative Inventory Yes =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded()
        .clickButton('New')
        .waitUntilLoaded('icitem')
        .enterData('Text Field','ItemNo','ITNLTI - 02')
        .enterData('Text Field','Description','001 - CRUD Non Lotted Item')
        .selectComboBoxRowValue('Category', 'TestGrains3', 'Category',0)
        .selectComboBoxRowValue('Commodity', 'TestCorn3', 'Commodity',0)
        .selectComboBoxRowNumber('LotTracking',4,0)
        .verifyData('Combo Box','Tracking','Item Level')

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
        .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
        .selectComboBoxRowNumber('NegativeInventory',1,0)
        .clickButton('Save')
        .clickButton('Close')

        .clickButton('AddLocation')
        .waitUntilLoaded('')
        .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
        .selectComboBoxRowNumber('NegativeInventory',1,0)
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
        .waitUntilLoaded()
        .clickButton('Close')
        .waitUntilLoaded()
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded()
        .displayText('===== Add Non Lotted Item - Negative Inventory Yes Done=====')
        //endregion


        //Adding Stock to Items
        .displayText('===== Adding Stocks to Created items =====')
        .addFunction(function(next){
            commonIC.addDirectIRNonLotted (t,next, 'ABC Trucking', 1, 'ITNLTI - 01','LB', 10000, 10)
        })

        .addFunction(function(next){
            commonIC.addDirectIRLotted (t,next, 'ABC Trucking', 1, 'ITLTI - 01','LB', 10000, 10, 'Raw Station', 'RM Storage', 'LOT-01', 'LB')
        })
        .displayText('===== Adding Stocks to Created Done =====')


        .displayText('===== Pre-setup done =====')


        endregion

        .done();

})
//endregion