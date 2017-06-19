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

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('icitem')
            .verifyScreenShown('icitem')
            .verifyStatusMessage('Ready')

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
            .waitUntilLoaded('icitemlocation')
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
            .waitUntilLoaded('')
            .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
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
            .clickMenuFolder('Inventory','Folder')
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
            .waitUntilLoaded('icitem')
            .verifyScreenShown('icitem')
            .verifyStatusMessage('Ready')

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
            .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
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

        .displayText('===== Add Commodity =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Commodities','Screen')
        .clickButton('New')
        .waitUntilLoaded('iccommodity')
        .enterData('Text Field','CommodityCode', commoditycode)
        .enterData('Text Field','Description', description)
        .enterData('Text Field','DecimalsOnDpr','6.00')

        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','Pounds','strUnitMeasure')
        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'Pounds', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','25 kg bag','strUnitMeasure')

        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')
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
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Categories','Screen')
            .clickButton('New')
            .waitUntilLoaded('iccategory')
            .enterData('Text Field','CategoryCode', categorycode)
            .enterData('Text Field','Description', description)
            .selectComboBoxRowNumber('InventoryType',inventorytype,0)
            .selectComboBoxRowNumber('CostingMethod',1,0)
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
            .clickMenuFolder('Inventory','Folder')
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
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('icinventoryreceipt')
            .selectComboBoxRowNumber('ReceiptType',4,0)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .selectComboBoxRowNumber('Location', location,0)
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo',itemno,'strItemNo')
            .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', qtytoreceive, receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .enterGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Pounds')
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
            .displayText('===== Creating Direct IR for Non Lotted Done =====')
            .clickMenuFolder('Inventory','Folder')
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
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('icinventoryreceipt')
            .selectComboBoxRowNumber('ReceiptType',4,0)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .selectComboBoxRowNumber('Location',location,0)
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo',itemno,'strItemNo')
            .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', qtytoreceive, receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .enterGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'Pounds')
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'Pounds')
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
            .clickMenuFolder('Inventory','Folder')
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

            .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
            .clickMenuScreen('Purchase Orders','Screen')
            .clickButton('New')
            .waitUntilLoaded('appurchaseorder')
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
            .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
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


            .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
            .clickMenuScreen('Purchase Orders','Screen')
            .clickButton('New')
            .waitUntilLoaded('appurchaseorder')
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
            .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
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

            .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
            .clickMenuScreen('Purchase Orders','Screen')
            .clickButton('New')
            .waitUntilLoaded('appurchaseorder')
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
            .waitUntilLoaded('frmfloatingsearch')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
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
            .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
            .waitUntilLoaded('')
            .clickMenuFolder('Inventory','Folder')
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

            .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
            .clickMenuScreen('Purchase Orders','Screen')
            .clickButton('New')
            .waitUntilLoaded('appurchaseorder')
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
            .clickMenuFolder('Purchasing (Accounts Payable)','Folder')

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .clickButton('New')
            .waitUntilLoaded('icinventoryreceipt')
            .selectComboBoxRowNumber('ReceiptType',2,0)
            .selectComboBoxRowValue('Vendor', vendor, 'Vendor',1)
            .waitUntilLoaded('frmfloatingsearch')
            .waitUntilLoaded('')
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
            .waitUntilLoaded('ctcontract')
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
            .waitUntilLoaded('icinventoryreceipt')
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
            .waitUntilLoaded('ctcontract')
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
            .waitUntilLoaded('icinventoryreceipt')
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
            .waitUntilLoaded('ctcontract')
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
            .waitUntilLoaded('ctcontract')
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
            .waitUntilLoaded('')
            .clickMessageBoxButton('yes')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')

            .clickTab('FreightInvoice')
            .waitUntilLoaded('')
            .clickTab('Details')
            .waitUntilLoaded('')
            .addResult('Successfully Opened Tab',2000)
            .selectGridRowNumber('InventoryReceipt', 1)
//            .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName',sublocation,'strSubLocationName')
//            .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName', storagelocation,'strStorageLocationName')
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
            .waitUntilLoaded('icinventoryshipment')
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
            .waitUntilLoaded('arsalesorder')
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
            .waitUntilLoaded('arsalesorder')
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
            .waitUntilLoaded('icinventoryshipment')
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
            .waitUntilLoaded('arsalesorder')
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .selectComboBoxRowValue('CompanyLocation', location, 'CompanyLocation',1)
            .enterData('Text Field','BOLNo','Test BOL - 01')

            .selectComboBoxRowValue('FreightTerm', freight, 'FreightTerm',1)
            .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo', itemno,'strItemNo')
            .selectGridComboBoxRowValue('SalesOrder',1,'strUnitMeasure', uom,'strUnitMeasure')
            .addResult('Item Selected',1500)
            .enterGridData('SalesOrder', 1, 'colOrdered', quantity)

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
//            .selectComboBoxRowValue('ShipFromAddress', location, 'ShipFromAddress',1)
//            .selectComboBoxRowNumber('ShipToAddress',1,0)

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
            .waitUntilLoaded('arsalesorder')
            .selectComboBoxRowValue('Customer', customer, 'Customer',1)
            .selectComboBoxRowValue('CompanyLocation', location, 'CompanyLocation',1)
            .enterData('Text Field','BOLNo','Test BOL - 01')

            .selectComboBoxRowValue('FreightTerm', freight, 'FreightTerm',1)
            .selectGridComboBoxRowValue('SalesOrder',1,'strItemNo', itemno,'strItemNo')
            .selectGridComboBoxRowValue('SalesOrder',1,'strUnitMeasure', uom,'strUnitMeasure')
            .addResult('Item Selected',1500)
            .enterGridData('SalesOrder', 1, 'colOrdered', quantity)

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
//            .selectComboBoxRowValue('ShipFromAddress', location, 'ShipFromAddress',1)
//            .selectComboBoxRowNumber('ShipToAddress',1,0)

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
            .waitUntilLoaded('ctcontract')
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
            .waitUntilLoaded('icinventoryshipment')
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
//            .selectComboBoxRowValue('ShipFromAddress', location, 'ShipFromAddress',1)
//            .selectComboBoxRowNumber('ShipToAddress',1,0)

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
            .waitUntilLoaded('ctcontract')
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
            .waitUntilLoaded('icinventoryshipment')
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
//            .selectComboBoxRowValue('ShipFromAddress', location, 'ShipFromAddress',1)
//            .selectComboBoxRowNumber('ShipToAddress',1,0)

            .verifyGridData('InventoryShipment', 1, 'colItemNumber', itemno)
            .verifyGridData('InventoryShipment', 1, 'colUnitPrice', price)
            .verifyGridData('InventoryShipment', 1, 'colOwnershipType', 'Own')
            .verifyGridData('InventoryShipment', 1, 'colLineTotal', linetotal)

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
            .checkScreenShown('icitem')
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
            .clickButton('New')
            .waitUntilLoaded('icitem')
            .enterData('Text Field','ItemNo', item)
            .selectComboBoxRowNumber('Type',6,0)
            .enterData('Text Field','Description', description)
//            .selectComboBoxRowNumber('Category',4,0)
            .selectComboBoxRowValue('Category', 'Other Charges', 'Category',0)
            .displayText('===== Setup Item UOM=====')
            .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','Pounds','strUnitMeasure')
            .enterGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1')
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
            .clickMenuFolder('Inventory','Folder')
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
        .waitUntilLoaded('icitem')
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
                .clickMenuFolder('Purchasing (Accounts Payable)')
                .clickMenuScreen('Purchase Orders')
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded('appurchaseorder')
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
                .waitUntilLoaded('icinventoryreceipt')
                .selectComboBoxRowNumber('ReceiptType',2) 
                .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1) 
                .waitUntilLoaded()
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
                .waitUntilLoaded('icinventoryreceipt')
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


////////////////////////////////////////////////////////////////////////    
//End Jerome Paul Fazon Codes
////////////////////////////////////////////////////////////////////////






});