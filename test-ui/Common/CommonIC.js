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
            .clickMenuFolder('Inventory','Folder')
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

        .enterUOMGridData('Uom', 1, 'colUnitQty', 'strUnitMeasure', 1, 'LB')
        .enterUOMGridData('Uom', 2, 'colUnitQty', 'strUnitMeasure', 50, '50 lb bag')
        .enterUOMGridData('Uom', 3, 'colUnitQty', 'strUnitMeasure', 56, 'Bushels')
        .enterUOMGridData('Uom', 4, 'colUnitQty', 'strUnitMeasure', 55.1156, '25 kg bag')
        .clickGridCheckBox('Uom',1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)

        .clickButton('Save')
        .waitUntilLoaded()
        .verifyStatusMessage('Saved')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')
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
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

//            .clickTab('Post Preview')
//            .waitUntilLoaded('')
//            .addResult('Open Post Preview',2000)
//            .waitUntilLoaded('')
//            .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
//            .verifyGridData('RecapTransaction', 1, 'colRecapDebit', linetotal)
//            .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
//            .verifyGridData('RecapTransaction', 2, 'colRecapCredit', linetotal)
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .displayText('===== Creating Direct IR for Non Lotted Done =====')
            .clickMenuFolder('Inventory','Folder')

            .done();
    },


    /**
     * Add Direct Inventory Receipt for Non Lotted Item
     *
     */


    addDirectIRLotted: function (t,next, vendor, location,itemno,receiptuom, qtytoreceive,cost,sublocation, storagelocation, lotno, lotuom) {
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
            .selectComboBoxRowNumber('Location',location,0)
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo',itemno,'strItemNo')
            .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', qtytoreceive, receiptuom)
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .enterGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName',sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName',storagelocation,'strSubLocationName')

            .enterGridData('LotTracking', 1, 'colLotId', lotno)
            .selectGridComboBoxRowValue('LotTracking',1,'strUnitMeasure',lotuom,'strUnitMeasure')
            .enterGridData('LotTracking', 1, 'colLotQuantity', qtytoreceive)
            .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')
            .verifyGridData('LotTracking', 1, 'colLotWeightUOM',lotuom)
            .verifyGridData('LotTracking', 1, 'colLotStorageLocation', storagelocation)

//
//            .clickTab('Post Preview')
//            .waitUntilLoaded('')
//            .addResult('Open Post Preview',2000)
//            .waitUntilLoaded('')
//            .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
//            .verifyGridData('RecapTransaction', 1, 'colRecapDebit', linetotal)
//            .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
//            .verifyGridData('RecapTransaction', 2, 'colRecapCredit', linetotal)
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .displayText('===== Creating Direct IR for Non Lotted Done =====')
            .clickMenuFolder('Inventory','Folder')

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
            .selectComboBoxRowValue('Currency', currency, 'FreightTerms',1)
            .selectComboBoxRowValue('ShipFromAddress', fromlocation, 'ShipFromAddress',1)
            .selectComboBoxRowNumber('ShipToAddress',1,0)

            .selectGridComboBoxRowValue('InventoryShipment',1,'strItemNo',itemno,'strItemNo')
            .enterUOMGridData('InventoryShipment', 1, 'colGumQuantity', 'strUnitMeasure', quantity, uom)

//            .clickButton('PostPreview')
//            .waitUntilLoaded('cmcmrecaptransaction')
//            .waitUntilLoaded('')
//            .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
//            .verifyGridData('RecapTransaction', 1, 'colRecapCredit', linetotal)
//            .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16050-0001-000')
//
//            .verifyGridData('RecapTransaction', 2, 'colRecapDebit', linetotal)
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

//            .clickButton('PostPreview')
//            .waitUntilLoaded('cmcmrecaptransaction')
//            .waitUntilLoaded('')
//            .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
//            .verifyGridData('RecapTransaction', 1, 'colRecapCredit', linetotal)
//            .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '16050-0001-000')
//
//            .verifyGridData('RecapTransaction', 2, 'colRecapDebit', linetotal)
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


    addOtherChargeItem: function (t,next, item, description) {
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
            .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','LB','strUnitMeasure')
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
            .displayText('===== Setup Item Location=====')
            .clickTab('Location')
            .clickButton('AddLocation')
            .waitUntilLoaded('')
            .clickButton('Save')
            .clickButton('Close')
            .clickButton('AddLocation')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('Location',2,0)
            .clickButton('Save')
            .clickButton('Close')
            .clickButton('Save')
            .clickButton('Close')
            .waitUntilLoaded()
            .clickMenuFolder('Inventory','Folder')
            .displayText('===== Other Charge Item Created =====')
            .done();

    }






});