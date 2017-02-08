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


    addInventoryItem: function (t,next, item, itemdesc, lottrack, priceLC, priceSC, priceAC) {
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
            .selectComboBoxRowNumber('Category',9,0)
            .selectComboBoxRowNumber('Commodity',12,0)
            //.selectComboBoxRowValue('Category', category, 'cboCategory',1)
            //.selectComboBoxRowValue('Commodity', commodity, 'strCommodityCode',1)
            .selectComboBoxRowNumber('LotTracking', lottrack)

            .clickTab('Setup')
//            .clickButton('AddRequiredAccounts')
//            .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
//            .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
//            .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
//            .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
//            .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
//            .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
//
//            .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
//            .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
//            .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
//            .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
//            .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
//            .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')

            .addResult('======== Setup GL Accounts Successful ========')

            .clickTab('Location')
            .clickButton('AddLocation')
            .waitUntilLoaded('icitemlocation')
            .selectComboBoxRowNumber('Location',1,0)
            .selectComboBoxRowNumber('SubLocation',4,0)
            .selectComboBoxRowNumber('StorageLocation',1,0)
//            .selectComboBoxRowValue('SubLocation', 'Raw Station', 'intSubLocationId',0)
//            .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'intStorageLocationId',0)
//            .selectComboBoxRowValue('IssueUom', saleuom, 'strUnitMeasure')
//            .selectComboBoxRowValue('ReceiveUom', receiveuom, 'strUnitMeasure')
            .clickButton('Save')
            .waitUntilLoaded()
            .verifyStatusMessage('Saved')
            .clickButton('Close')

            .clickButton('AddLocation')
            .waitUntilLoaded('')
            .selectComboBoxRowNumber('Location',2,0)
            .selectComboBoxRowNumber('SubLocation',1,0)
            .selectComboBoxRowNumber('StorageLocation',1,0)
//            .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
//            .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
//            .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
//            .selectComboBoxRowValue('IssueUom', saleuom, 'IssueUom',0)
//            .selectComboBoxRowValue('ReceiveUom', receiveuom, 'ReceiveUom',0)
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

        .selectGridComboBoxRowValue('Uom',1,'strUnitMeasure','LB','strUnitMeasure')
        .clickGridCheckBox('Uom', 1,'strUnitMeasure', 'LB', 'ysnStockUnit', true)
        .selectGridComboBoxRowValue('Uom',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',3,'strUnitMeasure','Bushels','strUnitMeasure')
        .selectGridComboBoxRowValue('Uom',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
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
            .selectComboBoxRowValue('Vendor', 'ABC Trucking', vendor,1)
            .selectComboBoxRowValue('Location', location, 'Location',0)
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo',itemno,'strItemNo')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure',receiptuom,'strUnitMeasure')
            .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', qtytoreceive)
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .enterGridData('InventoryReceipt', 1, 'colUnitCost', cost)
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'LB')
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'LB')
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', linetotal)

            .clickButton('PostPreview')
            .waitUntilLoaded('cmcmrecaptransaction')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colRecapDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colRecapCredit', linetotal)
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
            .selectComboBoxRowValue('Vendor', 'ABC Trucking', vendor,1)
            .selectComboBoxRowValue('Location', location, 'Location',0)
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo',itemno,'strItemNo')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure',receiptuom,'strUnitMeasure')
            .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', qtytoreceive)
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


            .clickButton('PostPreview')
            .waitUntilLoaded('cmcmrecaptransaction')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colRecapDebit', linetotal)
            .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colRecapCredit', linetotal)
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
            .selectComboBoxRowNumber('Category',4,0)
//            .selectComboBoxRowValue('Category', 'Other Charges', 'Category',0)
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

    },




        /**
         * IC Open Screens
         */

        openICScreens: function (t,next) {
            new iRely.FunctionalTest().start(t, next)

                //Open IC screens
                .displayText('=====  Scenario 1. Open IC Screens and check fields. ====')
                .displayText('=====  1.1 Open Inventory Receipt and Check Screen Fields ====')
                //IR Search Screen
                .clickMenuFolder('Inventory','Folder')
                .clickMenuScreen('Inventory Receipts','Screen')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
                    { dataIndex: 'dtmReceiptDate', text: 'Receipt Date'},
                    { dataIndex: 'strReceiptType', text: 'Order Type'},
                    { dataIndex: 'strVendorName', text: 'Vendor Name'},
                    { dataIndex: 'strLocationName', text: 'Location Name'},
                    { dataIndex: 'strBillOfLading', text: 'Bill Of Lading No'},
                    { dataIndex: 'ysnPosted', text: 'Posted'}
                ])
                .clickTab('Details')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
                    { dataIndex: 'strReceiptType', text: 'Order Type'},
                    { dataIndex: 'ysnPosted', text: 'Posted'},
                    { dataIndex: 'strShipFrom', text: 'Ship From'}

                ])
                .clickTab('Charges')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()

                .clickTab('Lots')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    { dataIndex: 'strReceiptNumber', text: 'Receipt No'},
                    { dataIndex: 'strReceiptType', text: 'Order Type'}

                ])
                .clickTab('Vouchers')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    { dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string' },
                    { dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                    { dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string' }
                ])
                //IR New Screen
                .clickTab('Inventory Receipt')
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded('icinventoryreceipt')
                .isControlVisible('tlb',
                [
                    'New'
                    ,'Save'
                    ,'Search'
                    ,'Delete'
                    ,'Undo'
                    ,'Print'
                    ,'Receive'
                    ,'PostPreview'
                    ,'Close'
                ], true)
                .isControlVisible('cbo',
                [
                    'ReceiptType'
                    ,'SourceType'
                    ,'Vendor'
                    ,'Location'
                    ,'Currency'
                    ,'Receiver'
                    ,'FreightTerms'
                    ,'TaxGroup'
                    ,'ShipFrom'
                    ,'ShipVia'
                ], true)
                .isControlVisible('txt',
                [
                    ,'ReceiptNumber'
                    ,'BillOfLadingNumber'
                    ,'VendorRefNumber'
                    ,'FobPoint'
                    ,'ShiftNumber'
                    ,'BlanketReleaseNumber'
                    ,'Vessel'
                ], true)
                .isControlVisible('btn',
                [
                    ,'InsertInventoryReceipt'
                    ,'Quality'
                    ,'TaxDetails'
                    ,'RemoveInventoryReceipt'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                .isControlVisible('col',
                [
                    ,'ItemNo'
                    ,'Description'
                    ,'UOM'
                    ,'QtyToReceive'
                    ,'ItemSubCurrency'
                    ,'UnitCost'
                    ,'WeightUOM'
                    ,'Gross'
                    ,'Net'
                    ,'LineTotal'
                    ,'Tax'
                    ,'SubLocation'
                    ,'StorageLocation'
                    ,'Grade'
                    ,'DiscountSchedule'
                    ,'UnitRetail'
                    ,'GrossMargin'
                    ,'OwnershipType'
                    ,'LotTracking'
                ], true)
                //IR Charges Tab
                .clickTab('FreightInvoice')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertCharge'
                    ,'RemoveCharge'
                    ,'CalculateCharges'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('col',
                [
                    ,'OtherCharge'
                    ,'OnCostType'
                    ,'CostMethod'
                    ,'ChargeCurrency'
                    ,'Rate'
                    ,'ChargeUOM'
                    ,'ChargeAmount'
                    ,'Accrue'
                    ,'CostVendor'
                    ,'InventoryCost'
                    ,'AllocateCostBy'
                    ,'Price'
                    ,'ChargeTax'
                ], true)
                //IR Incoming Inspection Tab
                .clickTab('Incoming Inspection')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'SelectAll'
                    ,'ClearAll'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('col',
                [
                    ,'Inspect'
                    ,'QualityPropertyName'
                ], true)
                //IR EDI Tab
                .clickTab('EDI')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    ,'TrailerArrivalDate'
                    ,'TrailerArrivalTime'
                    ,'SealNo'
                    ,'ReceiveTime'
                    ,'ActualTempReading'
                ], true)
                .isControlVisible('cbo',
                [
                    'ReceiptType'
                    ,'SourceType'
                    ,'Vendor'
                    ,'Location'
                    ,'Currency'
                    ,'Receiver'
                    ,'FreightTerms'
                    ,'TaxGroup'
                    ,'ShipFrom'
                    ,'ShipVia'
                ], true)
                .isControlVisible('btn',
                [
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                //IR Comments Tab
                //.clickTab('Comments')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    ,'Created'
                    ,'Start'
                    ,'Category'
                ], true)
                .isControlVisible('btn',
                [
                    'OpenActivity'
                    ,'NewEvent'
                    ,'NewTask'
                    ,'NewComment'
                    ,'LogCall'
                    ,'SendEmail'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                //.clickTab('Attachments')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddAttachment'
                    ,'OpenAttachment'
                    ,'EditAttachment'
                    ,'DownloadAttachment'
                    ,'DeleteAttachment'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                //.clickTab('AuditLog')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertCriteria'
                ], true)
                .waitUntilLoaded('')
                .clickButton('Close')
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded('')
                .displayText('=====  1.1 Open Inventory Receipt and Check Screen Fields Done ====')


                //Inventory Shipment Search Screen
                .displayText('=====  1.2 Open Inventory Shipments and Check Screen Fields ====')
                .clickMenuScreen('Inventory Shipments','Screen')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    {dataIndex: 'strShipmentNumber', text: 'Shipment Number'},
                    {dataIndex: 'dtmShipDate', text: 'Ship Date'},
                    {dataIndex: 'strOrderType', text: 'Order Type'},
                    {dataIndex: 'strSourceType', text: 'Source Type'},
                    {dataIndex: 'strCustomerNumber', text: 'Customer'},
                    {dataIndex: 'strCustomerName', text: 'Customer Name'},
                    {dataIndex: 'ysnPosted', text: 'Posted'}
                ])
                .clickTab('Details')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})

                .clickTab('Lots')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})

                //New IS Screen
                .clickTab('Inventory Shipment')
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded('icinventoryshipment')
                .isControlVisible('tlb',
                [
                    'New'
                    ,'Save'
                    ,'Search'
                    ,'Delete'
                    ,'Undo'
                    ,'Print'
                    ,'PrintBOL'
                    ,'Ship'
                    ,'PostPreview'
                    ,'Customer'
                    ,'WarehouseInstruction'
                    ,'Close'
                ], true)
                .isControlVisible('cbo',
                [
                    'OrderType'
                    ,'SourceType'
                    ,'Customer'
                    ,'#cboFreightTerms'
                    ,'#cboShipFromAddress'
                    ,'#cboShipToAddress'
                ], true)
                .isControlVisible('txt',
                [
                    ,'#txtReferenceNumber'
                    ,'#txtShipmentNo'
                    ,'#txtShipFromAddress'
                    ,'#txtShipToAddress'
                    ,'#txtDeliveryInstructions'
                    ,'#txtComments'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertItem'
                    ,'ViewItem'
                    ,'Quality'
                    ,'RemoveItem'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('col',
                [
                    ,'ItemNo'
                    ,'Description'
                    ,'CustomerStorage'
                    ,'UOM'
                    ,'Quantity'
                    ,'UnitPrice'
                    ,'UnitCost'
                    ,'LineTotal'
                    ,'WeightUOM'
                    ,'OwenerShipType'
                    ,'SubLocation'
                    ,'StorageLocation'
                    ,'Grade'
                    ,'DiscountSchedule'
                    ,'DockDoor'
                    ,'Notes'
                ], true)
                .isControlVisible('dtm',
                [
                    'ShipDate'
                    ,'RequestedArrival'
                ], true)
                //IS ShippingCompany Tab
                .waitUntilLoaded()
                .clickTab('Shipping Company')
                .isControlVisible('txt',
                [
                    'BOLNo'
                    ,'ProNumber'
                    ,'DriverID'
                    ,'VesselVehicle'
                    ,'SealNumber'
                ], true)
                .isControlVisible('cbo',
                [
                    , 'ShipVia'
                ], true)

                //IS Delivery Tab
                .clickTab('Delivery')
                .isControlVisible('txt',
                [
                    'AppointmentTime'
                    ,'Delivered'
                    ,'DepartureTime'
                    ,'ArrivalTime'
                    ,'ReceivedBy'
                ], true)
                .isControlVisible('dtm',
                [
                    'FreeTime'
                ], true)

                //IS Charges Tab
                .clickTab('Charges')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertCharge'
                    ,'RemoveCharge'
                    ,'CalculateCharges'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('col',
                [
                    ,'OtherCharge'
                    ,'OnCostType'
                    ,'CostMethod'
                    ,'ChargeCurrency'
                    ,'Rate'
                    ,'CostUOM'
                    ,'ChargeAmount'
                    ,'Accrue'
                    ,'CostVendor'
                    ,'Price'
                    ,'AllocatePriceBy'
                ], true)

                //IS Comments Tab
                //.clickTab('Comments')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    ,'Created'
                    ,'Start'
                    ,'Category'
                ], true)
                .isControlVisible('btn',
                [
                    'OpenActivity'
                    ,'NewEvent'
                    ,'NewTask'
                    ,'NewComment'
                    ,'LogCall'
                    ,'SendEmail'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                //IS Attachments Tab
                //.clickTab('Attachments')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddAttachment'
                    ,'OpenAttachment'
                    ,'EditAttachment'
                    ,'DownloadAttachment'
                    ,'DeleteAttachment'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                //IS Audit Log Tab
                //.clickTab('AuditLog')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertCriteria'
                ], true)
                .clickButton('Close')
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded()
                .displayText('=====  1.2 Open Inventory Shipments and Check Screen Fields ====')

                //Inventory Transfers Search Screen
                .displayText('=====  1.3 Open Inventory Transfers and Check Screen Fields ====')
                .clickMenuScreen('Inventory Transfers','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    {dataIndex: 'strTransferNo', text: 'Transfer No'},
                    {dataIndex: 'dtmTransferDate', text: 'Transfer Date'},
                    {dataIndex: 'strTransferType', text: 'Transfer Type'},
                    {dataIndex: 'strDescription', text: 'Description'},
                    {dataIndex: 'strFromLocation', text: 'From Location'},
                    {dataIndex: 'strToLocation', text: 'To Location'},
                    {dataIndex: 'strStatus', text: 'Status'},
                    {dataIndex: 'ysnPosted', text: 'Posted'}
                ])
                .clickTab('Details')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})

                .clickTab('Inventory Transfer')
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded('icinventorytransfer')
                .isControlVisible('tlb',
                [
                    'New'
                    ,'Save'
                    ,'Search'
                    ,'Delete'
                    ,'Undo'
                    ,'Print'
                    ,'Post'
                    ,'PostPreview'
                    ,'Close'
                ], true)
                .isControlVisible('cbo',
                [
                    'TransferType'
                    ,'SourceType'
                    ,'TransferredBy'
                    ,'FromLocation'
                    ,'ToLocation'
                    ,'Status'
                ], true)
                .isControlVisible('txt',
                [
                    'TransferNumber'
                    ,'Description'
                    ,'FilterGrid'
                ], true)
                .isControlVisible('dtm',
                [
                    'TransferDate'
                ], true)
                .isControlVisible('btn',
                [
                    ,'AddItem'
                    ,'ViewItem'
                    ,'RemoveItem'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                //IT Comments Tab
                //.clickTab('Comments')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    ,'Created'
                    ,'Start'
                    ,'Category'
                ], true)
                .isControlVisible('btn',
                [
                    'OpenActivity'
                    ,'NewEvent'
                    ,'NewTask'
                    ,'NewComment'
                    ,'LogCall'
                    ,'SendEmail'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                //IT Attachments Tab
                //.clickTab('Attachments')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddAttachment'
                    ,'OpenAttachment'
                    ,'EditAttachment'
                    ,'DownloadAttachment'
                    ,'DeleteAttachment'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                //IT Audit Log Tab
                //.clickTab('AuditLog')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertCriteria'
                ], true)
                .clickButton('Close')
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded()
                .displayText('=====  1.3 Open Inventory Transfers and Check Screen Fields Done====')


                //Inventory Adjustments Search Screen
                .displayText('=====  1.4 Open Inventory Adjustments and Check Screen Fields ====')
                .clickMenuScreen('Inventory Adjustments','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [

                    {dataIndex: 'strLocationName', text: 'Location Name'},
                    {dataIndex  : 'dtmAdjustmentDate', text: 'Adjustment Date'},
                    {dataIndex: 'intAdjustmentType', text: 'Adjustment Type'},
                    {dataIndex: 'strAdjustmentType', text: 'Adjustment Type'},
                    {dataIndex: 'strAdjustmentNo', text: 'Adjustment No'},
                    {dataIndex: 'strDescription', text: 'Description'},
                    {dataIndex: 'ysnPosted', text: 'Posted'}
                ])
                .clickTab('Details')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .clickTab('Inventory Adjustment')
                .waitUntilLoaded()

                .clickButton('New')
                .waitUntilLoaded('icinventoryadjustment')
                .isControlVisible('tlb',
                [
                    'New'
                    ,'Save'
                    ,'Search'
                    ,'Delete'
                    ,'Undo'
                    ,'Print'
                    ,'Post'
                    ,'PostPreview'
                    ,'Close'
                ], true)
                .isControlVisible('cbo',
                [
                    ,'#cboLocation'
                    ,'#cboAdjustmentType'
                ], true)
                .isControlVisible('txt',
                [
                    'AdjustmentNumber'
                    ,'Description'
                    ,'FilterGrid'
                ], true)
                .isControlVisible('dtm',
                [
                    'Date'
                ], true)
                //IA Comments Tab
                //.clickTab('Comments')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    ,'Created'
                    ,'Start'
                    ,'Category'
                ], true)
                .isControlVisible('btn',
                [
                    'OpenActivity'
                    ,'NewEvent'
                    ,'NewTask'
                    ,'NewComment'
                    ,'LogCall'
                    ,'SendEmail'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                //IA Attachments Tab
                //.clickTab('Attachments')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddAttachment'
                    ,'OpenAttachment'
                    ,'EditAttachment'
                    ,'DownloadAttachment'
                    ,'DeleteAttachment'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                //IA Audit Log Tab
                //.clickTab('AuditLog')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertCriteria'
                ], true)
                .clickButton('Close')
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded()
                .displayText('=====  1.4 Open Inventory Adjustments and Check Screen Fields Done ====')


                //Inventory Count Search Screen
                .displayText('=====  1.5 Open Inventory Count and Check Screen Fields ====')
                .clickMenuScreen('Inventory Count','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    {dataIndex: 'strCountNo', text: 'Count No'},
                    {dataIndex: 'strLocationName', text: 'Location'},
                    {dataIndex: 'strCategory', text: 'Category'},
                    {dataIndex: 'strCommodity', text: 'Commodity'},
                    {dataIndex: 'strCountGroup', text: 'Count Group'},
                    {dataIndex: 'dtmCountDate', text: 'Count Date'},
                    {dataIndex: 'strSubLocationName', text: 'Sub Location'},
                    {dataIndex: 'strStorageLocationName', text: 'Storage Location'},
                    {dataIndex: 'strStatus', text: 'Status'}

                ])
                .clickButton('New')
                .waitUntilLoaded('')
                .isControlVisible('tlb',
                [
                    'New'
                    ,'Save'
                    ,'Delete'
                    ,'Undo'
                    ,'PrintCountSheets'
                    ,'Close'
                ], true)
                .isControlVisible('cbo',
                [
                    'Location'
                    ,'Category'
                    ,'Commodity'
                    ,'CountGroup'
                    ,'SubLocation'
                    ,'StorageLocation'
                    ,'Status'
                ], true)
                .isControlVisible('chk',
                [
                    'IncludeZeroOnHand'
                    ,'IncludeOnHand'
                    ,'ScannedCountEntry'
                    ,'CountByLots'
                    ,'CountByPallets'
                    ,'RecountMismatch'
                    ,'External'
                    ,'Recount'
                ], true)
                .isControlVisible('txt',
                [
                    'CountNumber'
                    ,'Description'
                    ,'ReferenceCountNo'
                    ,'FilterGrid'
                ], true)
                .isControlVisible('btn',
                [
                    'Fetch'
                    ,'Insert'
                    ,'Remove'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('col',
                [
                    'Item'
                    ,'Description'
                    ,'Category'
                    ,'SubLocation'
                    ,'StorageLocation'
                    ,'SystemCount'
                    ,'LastCost'
                    ,'CountLineNo'
                    ,'PhysicalCount'
                    ,'UOM'
                    ,'PhysicalCountStockUnit'
                    ,'Variance'
                    ,'Recount'
                    ,'EnteredBy'
                ], true)


                //IC Comments Tab
                //.clickTab('Comments')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    ,'Created'
                    ,'Start'
                    ,'Category'
                ], true)
                .isControlVisible('btn',
                [
                    'OpenActivity'
                    ,'NewEvent'
                    ,'NewTask'
                    ,'NewComment'
                    ,'LogCall'
                    ,'SendEmail'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)

                //IC Attachments Tab
                //.clickTab('Attachments')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddAttachment'
                    ,'OpenAttachment'
                    ,'EditAttachment'
                    ,'DownloadAttachment'
                    ,'DeleteAttachment'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .clickButton('Close')
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded()
                .displayText('=====  1.5 Open Inventory Count and Check Screen Fields Done====')


                //Inventory Storage Measurement Reading Screen
                .displayText('=====  1.6 Open Storage Measurement Reading and Check Screen Fields ====')

                .clickMenuScreen('Storage Measurement Reading','Screen')
                .waitUntilLoaded()
                .clickButton('Close')
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    {dataIndex: 'strLocationName',text: 'Location'},
                    {dataIndex: 'dtmDate', text: 'Date'},
                    {dataIndex: 'strReadingNo', text: 'Reading No'}
                ])
                .clickButton('New')
                .waitUntilLoaded()
                .isControlVisible('tlb',
                [
                    'New'
                    ,'Save'
                    ,'Search'
                    ,'Delete'
                    ,'Undo'
                    ,'Close'
                ], true)
                .isControlVisible('txt',
                [
                    'ReadingNumber'
                    ,'FilterGrid'
                ], true)
                .isControlVisible('cbo',
                [
                    'Location'
                ], true)
                .isControlVisible('dtm',
                [
                    ,'Date'
                ], true)
                .isControlVisible('btn',
                [
                    'Insert'
                    ,'Remove'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('col',
                [
                    'Commodity'
                    ,'Item'
                    ,'StorageLocation'
                    ,'SubLocation'
                    ,'EffectiveDepth'
                    ,'AirSpaceReading'
                    ,'CashPrice'
                    ,'DiscountSchedule'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded()
                .displayText('=====  1.6 Open Storage Measurement Reading and Check Screen Fields Done====')



                //Inventory Items Screen
                .displayText('=====  1.7 Open Items and Check Screen Fields ====')
                .clickMenuScreen('Items','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .clickTab('Locations')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .clickTab('Pricing')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .clickTab('Item UOM')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .clickTab('Item')
                .waitUntilLoaded()
                .addResult('Successfully Opened Screen',3000)
                .waitUntilLoaded()
                .clickButton('New')
                .waitUntilLoaded('icitem')
                .isControlVisible('tlb',
                [
                    'New'
                    ,'Save'
                    ,'Search'
                    ,'Delete'
                    ,'Undo'
                    ,'Duplicate'
                    ,'Close'
                ], true)
                .isControlVisible('txt',
                [
                    'ItemNo'
                    ,'ShortName'
                    ,'Description'
                    ,'ModelNo'
                    ,'FilterGrid'
                ], true)
                .isControlVisible('cbo',
                [
                    'Type'
                    ,'Manufacturer'
                    ,'Status'
                    ,'Commodity'
                    ,'LotTracking'
                    ,'Brand'
                    ,'Category'
                    ,'Tracking'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertUom'
                    ,'DeleteUom'
                    ,'LoadUOM'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('col',
                [
                    'DetailUnitMeasure'
                    ,'DetailUnitQty'
                    ,'DetailShortUPC'
                    ,'DetailUpcCode'
                    ,'StockUnit'
                    ,'AllowPurchase'
                    ,'AllowSale'
                    ,'DetaiLength'
                    ,'DetailWidth'
                    ,'DetailHeight'
                    ,'DetailDimensionUOM'
                    ,'DetailVolume'
                    ,'DetailVolumeUOM'
                    ,'DetailWeight'
                    ,'DetailWeightUOM'
                    ,'DetailMaxQty'
                ], true)
                //Item Setup Tab - GL Accounts
                .clickTab('Setup')
                .isControlVisible('cfg',
                [
                    'Location'
                    ,'Sales'
                    ,'POS'
                    ,'Contract'
                    ,'Xref'
                    ,'MotorFuelTax'
                    ,'Others'
                ], true)
                .isControlVisible('btn',
                [
                    'AddRequiredAccounts'
                    ,'InsertGlAccounts'
                    ,'DeleteGlAccounts'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('col',
                [
                    'GLAccountCategory'
                    ,'GLAccountId'
                    ,'Description'
                ], true)
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                //Item Setup Tab - Location
                .clickTab('Location')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddLocation'
                    ,'AddMultipleLocation'
                    ,'EditLocation'
                    ,'DeleteLocation'
                    ,'CopyLocation'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('col',
                [
                    'LocationLocation'
                    ,'LocationPOSDescription'
                    ,'LocationVendor'
                    ,'LocatioCostingMethod'
                ], true)
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                //Item Setup Tab - Sales
                .clickTab('Sales')
                .waitUntilLoaded()
                .isControlVisible('chk',
                [
                    'StockedItem'
                    ,'DyedFuel'
                    ,'MsdsRequired'
                    ,'InboundTax'
                    ,'OutboundTax'
                    ,'RestrictedChemical'
                    ,'FuelItem'
                    ,'TonnageTax'
                    ,'LoadTracking'
                    ,'HandAddIngredients'
                    ,'ExtendOnPickTicket'
                    ,'ExportEdi'
                    ,'HazardMaterial'
                    ,'MaterialFee'
                    ,'AutoBlend'
                ], true)
                .isControlVisible('txt',
                [
                    'EpaNumber'
                    ,'PercentDenaturant'
                    ,'MixOrder'
                    ,'VolumeRebateGroup'
                    ,'UserGroupFee'
                    ,'WgtTolerance'
                    ,'OverReceiveTolerance'
                    ,'MaintenanceCalculationMethod'
                    ,'MaintenanceRate'
                ], true)
                .isControlVisible('cbo',
                [
                    'BarcodePrint'
                    ,'FuelInspectionFee'
                    ,'RinRequired'
                    ,'FuelCategory'
                    ,'MedicationTag'
                    ,'IngredientTag'
                    ,'PhysicalItem'
                ], true)
                //Items - Point of Sale Tab
                .clickTab('Point of Sale')
                .waitUntilLoaded()
                .isControlVisible('pnl',
                [
                    'General'
                    ,'InventorySetup'
                    ,'CommissionDetail'
                ], true)
                .isControlVisible('txt',
                [
                    'NacsCategory'
                    ,'LeadTime'
                    ,'Keywords'
                    ,'CaseQty'
                    ,'TaxExempt'
                ], true)
                .isControlVisible('cbo',
                [
                    'CountCode'
                ], true)
                .isControlVisible('chk',
                [
                    'ReceiptCommentReq'
                    ,'LandedCost'
                    ,'Taxable'
                    ,'DropShip'
                    ,'Commissionable'
                    ,'SpecialCommission'
                ], true)
                .isControlVisible('dtm',
                [
                    'DateShip'
                ], true)
                .isControlVisible('dtm',
                [
                    'POSCategoryName'
                    ,'POSSLAContract'
                    ,'POSSLAPrice'
                    ,'POSSLAWarranty'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertCategories'
                    ,'DeleteCategories'
                    ,'InsertSLA'
                    ,'DeleteSLA'
                ], true)
                //Items - Contract Item Tab
                .clickTab('Contract Item')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'InsertContractItem'
                    ,'DeleteContractItem'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'InsertDocumentAssociation'
                    ,'DeleteDocumentAssociation'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'InsertCertification'
                    ,'DeleteCertification'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    ,'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'ContractLocation'
                    ,'ContractItemName'
                    ,'ContractOrigin'
                    ,'ContractGrade'
                    ,'ContractGradeType'
                    ,'ContractGarden'
                    ,'ContractYield'
                    ,'ContractTolerance'
                    ,'ContractFranchise'
                    ,'Document'
                    ,'Certification'
                ], true)
                //Items - Xref Tab
                .clickTab('Xref')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'InsertContractItem'
                    ,'DeleteContractItem'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    ,'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    ,'CustomerXrefLocation'
                    ,'CustomerXrefCustomer'
                    ,'CustomerXrefProduct'
                    ,'CustomerXrefDescription'
                    ,'CustomerXrefPickTicketNotes'
                    ,'VendorXrefLocation'
                    ,'VendorXrefVendor'
                    ,'VendorXrefProduct'
                    ,'VendorXrefDescription'
                    ,'VendorXrefConversionFactor'
                    ,'VendorXrefUnitMeasure'
                ], true)
                //Items - Motor Fuel Tax Tab
                .clickTab('Motor Fuel Tax')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'InsertContractItem'
                    ,'DeleteContractItem'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    ,'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    ,'MFTTaxAuthorityCode'
                    ,'MFTTaxDescription'
                    ,'MFTProductCode'
                    ,'MFTProductCodeDescription'
                    ,'MFTProductCodeGroup'
                ], true)
                //Items - Others Tab
                .clickTab('Other')
                .waitUntilLoaded()
                .isControlVisible('pnl',
                [
                    'Comments'
                    ,'TankManagement'
                    ,'Patronage'
                ], true)
                .isControlVisible('txt',
                [
                    'InvoiceComments'
                    ,'PickListComments'
                    ,'DefaultPercentFull'
                ], true)
                .isControlVisible('chk',
                [
                    'TankRequired'
                    , 'AvailableForTm'
                ], true)
                .isControlVisible('cbo',
                [
                    'Patronage'
                    ,'PatronageDirect'
                ], true)
                //Items - Pricing Tab
                .clickTab('Pricing')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'InsertPricingLevel'
                    ,'DeletePricingLevel'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    ,'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'PricingLocation'
                    ,'PricingLastCost'
                    ,'PricingStandardCost'
                    ,'PricingAverageCost'
                    ,'PricingMethod'
                    ,'PricingAmount'
                    ,'PricingMSRP'

                    ,'PricingLevelLocation'
                    ,'PricingLevelPriceLevel'
                    ,'PricingLevelUOM'
                    ,'PricingLevelUPC'
                    ,'PricingLevelUnits'
                    ,'PricingLevelMin'
                    ,'PricingLevelMax'
                    ,'PricingLevelMethod'
                    ,'PricingLevelAmount'
                    ,'PricingLevelUnitPrice'
                    ,'PricingLevelCommissionOn'
                    ,'PricingLevelCommissionRate'

                ], true)
                //Items - Stock Tab
                .clickTab('Stock')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    ,'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'StockLocation'
                    ,'StockUOM'
                    ,'StockOnOrder'
                    ,'StockInTransitInbound'
                    ,'StockOnHand'
                    ,'StockInTransitOutbound'
                    ,'StockBackOrder'
                    ,'StockCommitted'
                    ,'StockOnStorage'
                    ,'StockConsignedPurchase'
                    ,'StockConsignedSale'
                    ,'StockReserved'
                    ,'StockAvailable'
                ], true)
                //Items Comments Tab
                //.clickTab('Comments')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    ,'Created'
                    ,'Start'
                    ,'Category'
                ], true)
                .isControlVisible('btn',
                [
                    'OpenActivity'
                    ,'NewEvent'
                    ,'NewTask'
                    ,'NewComment'
                    ,'LogCall'
                    ,'SendEmail'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                //Items Attachments Tab
                //.clickTab('Attachments')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddAttachment'
                    ,'OpenAttachment'
                    ,'EditAttachment'
                    ,'DownloadAttachment'
                    ,'DeleteAttachment'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                //Items AuditLog Tab
                //.clickTab('AuditLog')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('btn',
                [
                    'InsertCriteria'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded()
                .displayText('=====  1.7 Open Items and Check Screen Fields Done====')


                //Inventory Commodities Screen
                .displayText('=====  1.8 Open Commodities and Check Screen Fields ====')
                .clickMenuScreen('Commodities','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    {dataIndex: 'strCommodityCode', text: 'Commodity Code'},
                    {dataIndex: 'strDescription', text: 'Description'}
                ])
                .clickButton('New')
                .waitUntilLoaded('iccommodity')
                .isControlVisible('btn',
                [
                    'New'
                    ,'Save'
                    ,'Find'
                    ,'Delete'
                    ,'Undo'
                    ,'Close'
                    ,'DeleteUom'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    'CommodityCode'
                    ,'Description'
                    ,'DecimalsOnDpr'
                    ,'ConsolidateFactor'
                    ,'PriceChecksMin'
                    ,'PriceChecksMax'
                    ,'EdiCode'
                    ,'FilterGrid'
                ], true)
                .isControlVisible('chk',
                [
                    'ExchangeTraded'
                    ,'FxExposure'
                ], true)
                .isControlVisible('cbo',
                [
                    'FutureMarket'
                    ,'DefaultScheduleStore'
                    ,'DefaultScheduleDiscount'
                    ,'ScaleAutoDistDefault'
                ], true)
                .isControlVisible('dtm',
                [
                    'CropEndDateCurrent'
                    ,'CropEndDateNew'
                ], true)
                .clickTab('Attribute')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'DeleteOrigins'
                    ,'MoveUpOrigins'
                    ,'MoveDownOrigins'
                    ,'GridLayout'
                    ,'DeleteProductTypes'
                    ,'MoveUpProductTypes'
                    ,'MoveDownProductTypes'
                    ,'DeleteRegions'
                    ,'MoveUpRegions'
                    ,'MoveDownRegions'
                    ,'DeleteClasses'
                    ,'MoveUpClasses'
                    ,'MoveDownClasses'
                    ,'DeleteSeasons'
                    ,'MoveUpSeasons'
                    ,'MoveDownSeasons'
                    ,'DeleteGrades'
                    ,'MoveUpGrades'
                    ,'MoveDownGrades'
                    ,'DeleteProductLines'
                    ,'MoveUpProductLines'
                    ,'MoveDownProductLines'
                ], true)
                .isControlVisible('col',
                [
                    'Origin'
                    ,'ProductType'
                    ,'Region'
                    ,'ClassVariant'
                    ,'Season'
                    ,'Grade'
                    ,'ProductLine'
                    ,'DeltaHedge'
                    ,'DeltaPercent'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .displayText('=====  1.8 Open Commodities and Check Screen Fields Done ====')


                //Inventory Fuel Types Screen
                .displayText('=====  1.9 Open Fuel Types and Check Screen Fields ====')
                .clickMenuScreen('Categories','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    {dataIndex: 'strCategoryCode', text: 'Category Code'},
                    {dataIndex: 'strDescription', text: 'Description'},
                    {dataIndex: 'strInventoryType', text: 'Inventory Type'}
                ])
                .clickButton('New')
                .waitUntilLoaded('iccategory')
                .isControlVisible('btn',
                [
                    'New'
                    ,'Save'
                    ,'Find'
                    ,'Delete'
                    ,'Undo'
                    ,'Close'
                    ,'InsertTax'
                    ,'DeleteTax'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'DeleteUom'
                    ,'ridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    'CategoryCode'
                    ,'Description'
                    ,'GlDivisionNumber'
                    ,'SalesAnalysisByTon'
                    ,'StandardQty'
                    ,'FilterGrid'
                ], true)
                .isControlVisible('cbo',
                [
                    'InventoryType'
                    ,'LineOfBusiness'
                    ,'CostingMethod'
                    ,'InventoryValuation'
                    ,'StandardUOM'
                ], true)
                //Categories Location tab
                .clickTab('Locations')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddLocation'
                    ,'EditLocation'
                    ,'DeleteLocation'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                ], true)
                .isControlVisible('txt',
                [
                    ,'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'LocationId'
                    ,'LocationCashRegisterDept'
                    ,'LocationTargetGrossProfit'
                    ,'LocationTargetInventoryCost'
                    ,'LocationCostInventoryBOM'
                ], true)
                //Categories GL Accounts tab
                .clickTab('GL Accounts')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddRequired'
                    ,'DeleteGlAccounts'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                ], true)
                .isControlVisible('txt',
                [
                    ,'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'AccountCategory'
                    ,'AccountId'
                    ,'AccountDescription'
                ], true)
                //Categories Vendor Category Xref tab
                .clickTab('Vendor Category Xref')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'DeleteVendorCategoryXref'
                    ,'GridLayout'
                    ,'InsertCriteria'
                    ,'MaximizeGrid'
                ], true)
                .isControlVisible('col',
                [
                    'VendorLocation'
                    ,'VendorId'
                    ,'VendorDepartment'
                    ,'VendorAddOrderUPC'
                    ,'VendorUpdateExisting'
                    ,'VendorAddNew'
                    ,'VendorUpdatePrice'
                    ,'VendorFamily'
                    ,'VendorOrderClass'
                ], true)
                //Categories Manufacturing tab
                .clickTab('Vendor Category Xref')
                .waitUntilLoaded()
                .isControlVisible('txt',
                [
                    'ERPItemClass'
                    ,'LifeTime'
                    ,'BOMItemShrinkage'
                    ,'BOMItemUpperTolerance'
                    ,'BOMItemLowerTolerance'
                    ,'ConsumptionMethod'
                    ,'BOMItemType'
                    ,'ShortName'
                    ,'LaborCost'
                    ,'OverHead'
                    ,'Percentage'
                    ,'CostDistributionMethod'
                ], true)
                .isControlVisible('chk',
                [
                    'Scaled'
                    ,'OutputItemMandatory'
                    ,'Sellable'
                    ,'YieldAdjustment'
                    ,'TrackedInWarehouse'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()


                //Inventory Fuel Types Screen
                .displayText('=====  1.10 Open Fuel Types and Check Screen Fields ====')
                .clickMenuScreen('Fuel Types','Screen')
                .waitUntilLoaded()
                .clickButton('Close')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    {dataIndex: 'strRinFuelTypeCodeId', text: 'Fuel Type'},
                    {dataIndex: 'strRinFeedStockId', text: 'Feed Stock'},
                    {dataIndex: 'strRinFuelId', text: 'Fuel Code'},
                    {dataIndex: 'strRinProcessId', text: 'Process Code'}
                ])
                .clickButton('New')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'New'
                    ,'Save'
                    ,'Search'
                    ,'Delete'
                    ,'Undo'
                    ,'Close'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('cbo',
                [
                    'FuelCategory'
                    ,'FeedStock'
                    ,'FuelCode'
                    ,'ProductionProcess'
                    ,'FeedStockUom'
                ], true)
                .isControlVisible('txt',
                [
                    'BatchNo'
                    ,'EndingRinGallonsForBatch'
                    ,'EquivalenceValue'
                    ,'FeedStockFactor'
                    ,'PercentOfDenaturant'
                    ,'FilterGrid'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()


                //Inventory Fuel Category Screen
                .displayText('=====  1.11 Open Fuel Category and Check Screen Fields ====')
                .clickButton('FuelCategory')
                .waitUntilLoaded('icfuelcategory')
                .isControlVisible('btn',
                [
                    'Save'
                    ,'Undo'
                    ,'Close'
                    ,'Insert'
                    ,'Delete'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'RinFuelCategoryCode'
                    ,'Description'
                    ,'EquivalenceValue'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .displayText('=====  1.11 Open Fuel Category and Check Screen Fields Done ====')


                //Inventory Feed Stock Screen
                .displayText('=====  1.12 Open Feed Stock and Check Screen Fields ====')
                .clickButton('FeedStock')
                .waitUntilLoaded('icfeedstockcode')
                .isControlVisible('btn',
                [
                    'Save'
                    ,'Undo'
                    ,'Close'
                    ,'Insert'
                    ,'Delete'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'RinFeedStockCode'
                    ,'Description'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .displayText('=====  1.12 Open Feed Stock and Check Screen Fields Done ====')

                //Inventory Fuel Code Screen
                .displayText('=====  1.13 Open Fuel Code and Check Screen Fields ====')
                .clickButton('FuelCode')
                .waitUntilLoaded('icfuelcode')
                .isControlVisible('btn',
                [
                    'Save'
                    ,'Undo'
                    ,'Close'
                    ,'Insert'
                    ,'Delete'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'RinFuelCode'
                    ,'Description'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .displayText('=====  1.13 Open Fuel Code and Check Screen Fields Done ====')


                //Inventory Production Process Screen
                .displayText('=====  1.14 Open Production Process and Check Screen Fields ====')
                .clickButton('ProductionProcess')
                .waitUntilLoaded('icprocesscode')
                .isControlVisible('btn',
                [
                    'Save'
                    ,'Undo'
                    ,'Close'
                    ,'Insert'
                    ,'Delete'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'RinProcessCode'
                    ,'Description'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .displayText('=====  1.14 Open Production Process and Check Screen Fields Done====')

                //Inventory Feed Stock UOM Screen
                .displayText('=====  1.15 Open Feed Stock UOM and Check Screen Fields ====')
                .clickButton('FeedStockUOM')
                .waitUntilLoaded('icfeedstockuom')
                .isControlVisible('btn',
                [
                    'Save'
                    ,'Undo'
                    ,'Close'
                    ,'Insert'
                    ,'Delete'
                    ,'GridLayout'
                    ,'InsertCriteria'
                ], true)
                .isControlVisible('txt',
                [
                    'FilterGrid'
                ], true)
                .isControlVisible('col',
                [
                    'UOM'
                    ,'RinFeedStockUOMCode'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .displayText('=====  1.15 Open Feed Stock UOM and Check Screen Fields ====')


                //Inventory Storage Locations Screen
                .displayText('=====  1.16 Open Storage Locations and Check Screen Fields ====')
                .clickMenuScreen('Storage Locations','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    {dataIndex: 'strName', text: 'Name'},
                    {dataIndex: 'strDescription', text: 'Description'},
                    {dataIndex: 'strStorageUnitType', text: 'Storage Unit Type'},
                    {dataIndex: 'strLocationName', text: 'Location'},
                    {dataIndex: 'strSubLocationName', text: 'Sub Location'},
                    {dataIndex: 'strParentStorageLocationName', text: 'Parent Unit'},
                    {dataIndex: 'strRestrictionCode', text: 'Restriction Type'}
                ])
                .clickButton('New')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'New'
                    ,'Save'
                    ,'Search'
                    ,'Delete'
                    ,'Undo'
                    ,'Close'
                    ,'Help'
                    ,'Support'
                    ,'FieldName'
                    ,'EmailUrl'
                ], true)
                .isControlVisible('txt',
                [
                    'Name'
                    ,'Description'
                    ,'Aisle'
                    ,'MinBatchSize'
                    ,'BatchSize'
                    ,'PackFactor'
                    ,'EffectiveDepth'
                    ,'UnitsPerFoot'
                    ,'ResidualUnits'
                    ,'Sequence'
                    ,'XPosition'
                    ,'YPosition'
                    ,'ZPosition'
                ], true)
                .isControlVisible('cbo',
                [
                    'UnitType'
                    ,'Location'
                    ,'SubLocation'
                    ,'ParentUnit'
                    ,'RestrictionType'
                    ,'BatchSizeUom'
                    ,'Commodity'
                ], true)
                .isControlVisible('chk',
                [
                    'AllowConsume'
                    ,'AllowMultipleItems'
                    ,'AllowMultipleLots'
                    ,'MergeOnMove'
                    ,'CycleCounted'
                    ,'DefaultWarehouseStagingUnit'
                ], true)

                //Storage Location Measurement Tab
                .clickTab('Measurement')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'AddMeasurement'
                    ,'DeleteMeasurement'
                ], true)
                .isControlVisible('col',
                [
                    'Measurement'
                    ,'ReadingPoint'
                    ,'Active'
                ], true)

                //Storage Location Item Categories Allowed Tab
                .clickTab('Item Categories Allowed')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'DeleteItemCategoryAllowed'
                ], true)
                .isControlVisible('col',
                [
                    'Category'
                ], true)

                //Storage Location Container Tab
                .clickTab('Container')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    'DeleteContainer'
                ], true)
                .isControlVisible('col',
                [
                    'Container'
                    ,'ExternalSystem'
                    ,'ContainerType'
                    ,'LastUpdateby'
                    ,'LastUpdateOn'
                ], true)

                //Storage Location SKU Tab
                .clickTab('SKU')
                .waitUntilLoaded()
                .isControlVisible('btn',
                [
                    '#btnDeleteSKU'
                ], true)
                .isControlVisible('col',
                [
                    'Item'
                    ,'Sku'
                    ,'Qty'
                    ,'Container'
                    ,'LotSerial'
                    ,'Expiration'
                    ,'Status'
                ], true)
                .clickButton('Close')
                .waitUntilLoaded()
                .verifyMessageBox('iRely i21','Do you want to save the changes you made?','yesnocancel','question')
                .clickMessageBoxButton('no')
                .waitUntilLoaded()
                .displayText('=====  1.16 Open Storage Locations and Check Screen Fields ====')


                //Open Inventory Stock Details
                .displayText('=====  1.17 Open Stock Details and Check Screen Fields ====')
                .clickMenuScreen('Stock Details','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({new: false, open: false, openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    { dataIndex: 'strItemNo', text: 'Item No'},
                    { dataIndex: 'strDescription', text: 'Description'},
                    { dataIndex: 'strType', text: 'Item Type'},
                    { dataIndex: 'strCategoryCode', text: 'Category'},
                    { dataIndex: 'strLocationName', text: 'Location Name'},
                    { dataIndex: 'dblUnitOnHand', text: 'On Hand'},
                    { dataIndex: 'dblOnOrder', text: 'On Order'},
                    { dataIndex: 'dblOrderCommitted', text: 'Committed'},
                    { dataIndex: 'dblUnitReserved', text: 'Reserved'},
                    { dataIndex: 'dblInTransitInbound', text: 'In Transit Inbound'},
                    { dataIndex: 'dblInTransitOutbound', text: 'In Transit Outbound'},
                    { dataIndex: 'dblUnitStorage', text: 'On Storage'},
                    { dataIndex: 'dblConsignedPurchase', text: 'Consigned Purchase'},
                    { dataIndex: 'dblConsignedSale', text: 'Consigned Sale'},
                    { dataIndex: 'dblAvailable', text: 'Available'},
                    { dataIndex: 'dblReorderPoint', text: 'Reorder Point'},
                    { dataIndex: 'dblLastCost', text: 'Last Cost'},
                    { dataIndex: 'dblAverageCost', text: 'Average Cost'},
                    { dataIndex: 'dblStandardCost', text: 'Standard Cost'},
                    { dataIndex: 'dblSalePrice', text: 'Retail Price'},
                    { dataIndex: 'dblExtendedCost', text: 'Extended Cost'}
                ])
                .clickTab('Storage Bins')
                .waitUntilLoaded()
                .displayText('=====  1.17 Open Stock Details and Check Screen Fields Done====')

                //Open Inventory Lot Details
                .displayText('=====  1.18 Open Lot Details and Check Screen Fields ====')
                .clickMenuScreen('Lot Details','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({new: false, open: false, openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    { dataIndex: 'strItemNo', text: 'Item No'},
                    { dataIndex: 'strItemDescription', text: 'Description'},
                    { dataIndex: 'strLocationName', text: 'Location Name'},
                    { dataIndex: 'strSubLocationName', text: 'Sub Location'},
                    { dataIndex: 'strStorageLocation', text: 'Storage Location'},
                    { dataIndex: 'strLotNumber', text: 'Lot Number'},
                    { dataIndex: 'dblQty', text: 'Quantity'},
                    { dataIndex: 'dblWeight', text: 'Weight'},
                    { dataIndex: 'strItemUOM', text: 'UOM'},
                    { dataIndex: 'dblWeightPerQty', text: 'Weight Per Qty'},
                    { dataIndex: 'dblLastCost', text: 'Last Cost'}

                ])
                .displayText('=====  1.18 Open Lot Details and Check Screen Fields Done====')


                //Open Inventory Valuation
                .displayText('=====  1.19 Open Inventory Valuation and Check Screen Fields ====')
                .clickMenuScreen('Inventory Valuation','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({new: false, open: false, openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    { dataIndex: 'strItemNo', text: 'Item No'},
                    { dataIndex: 'strItemDescription', text: 'Description'},
                    { dataIndex: 'strCategory', text: 'Category'},
                    { dataIndex: 'strStockUOM', text: 'Stock UOM'},
                    { dataIndex: 'strLocationName', text: 'Location'},
                    { dataIndex: 'strSubLocationName', text: 'Sub Location'},
                    { dataIndex: 'strStorageLocationName', text: 'Storage Location'},
                    { dataIndex: 'strBOLNumber', text: 'BOL Number'},
                    { dataIndex: 'strEntity', text: 'Entity'},
                    { dataIndex: 'strLotNumber', text: 'Lot Number'},
                    { dataIndex: 'strAdjustedTransaction', text: 'Adjusted Transaction'},
                    { dataIndex: 'strCostingMethod', text: 'Costing Method'},
                    { dataIndex: 'dtmDate', text: 'Date'},
                    { dataIndex: 'strTransactionType', text: 'Transaction Type'},
                    { dataIndex: 'strTransactionId', text: 'Transaction Id'},
                    { dataIndex: 'dblBeginningQtyBalance', text: 'Begin Qty'},
                    { dataIndex: 'dblQuantityInStockUOM', text: 'Qty'},
                    { dataIndex: 'dblRunningQtyBalance', text: 'Running Qty'},
                    { dataIndex: 'dblCostInStockUOM', text: 'Cost'},
                    { dataIndex: 'dblBeginningBalance', text: 'Begin Value'},
                    { dataIndex: 'dblValue', text: 'Value'},
                    { dataIndex: 'dblRunningBalance', text: 'Running Value'},
                    { dataIndex: 'strBatchId', text: 'Batch Id'}
                ])
                .displayText('=====  1.19 Open Inventory Valuation and Check Screen Fields Done====')

                //Open Inventory Valuation Summary
                .displayText('=====  1.20 Open Inventory Valuation Summary and Check Screen Fields ====')
                .clickMenuScreen('Inventory Valuation Summary','Screen')
                .waitUntilLoaded()
                .verifySearchToolbarButton({new: false, open: false, openselected: false, openall: false, close: false})
                .verifyGridColumnNames('Search', [
                    { dataIndex: 'strItemNo', text: 'Item No'},
                    { dataIndex: 'strItemDescription', text: 'Description'},
                    { dataIndex: 'strLocationName', text: 'Location'},
                    { dataIndex: 'strSubLocationName', text: 'Sub Location'},
                    { dataIndex: 'dblValue', text: 'Value'},
                    { dataIndex: 'dblLastCost', text: 'Last Cost'},
                    { dataIndex: 'dblStandardCost', text: 'Standard Cost'},
                    { dataIndex: 'dblAverageCost', text: 'Average Cost'}
                ])
                .clickMenuFolder('Inventory','Folder')
                .displayText('===== Open Inventory Valuation Summary and Check Screen Fields Done====')


                .done();

        }










});