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


Ext.define('i21.test.Inventory.CommonIC', {

    addInventoryItem: function (t,next, item, itemdesc, lottrack, category, commodity,saleuom, receiveuom, priceLC, priceSC, priceAC) {
        var engine = new iRely.TestEngine();
        engine.start(t, next)

            .expandMenu('Inventory').wait(500)
            .waitTillLoaded('Open Inventory Menu Successfull').wait(500)
            .openScreen('Items').wait(500)
            .waitTillLoaded('Open Items Search Screen Successful')
            .clickButton('#btnNew').wait(500)
            .waitTillVisible('icitem', 'Open New Item Screen Successful').wait(500)
            .checkScreenShown('icitem').wait(200)
            .checkStatusMessage('Ready')

            .enterData('#txtItemNo', item).wait(200)
            //.selectComboRowByIndex('#cboType',0).wait(200)
            .enterData('#txtDescription', itemdesc).wait(200)
            .selectComboRowByFilter('#cboCategory', commodity, 500, 'cboCategory',0).wait(500)
            .selectComboRowByFilter('#cboCommodity', category, 500, 'strCommodityCode',0).wait(500)
            .selectComboRowByIndex('#cboLotTracking', lottrack).wait(500)

            .clickButton('#btnLoadUOM').wait(300)
            .waitTillLoaded('Add UOM Successful')

            .clickTab('#cfgSetup').wait(100)
            .clickButton('#btnAddRequiredAccounts').wait(100)
            .checkGridData('#grdGlAccounts', 0, 'colGLAccountCategory', 'AP Clearing').wait(100)
            .checkGridData('#grdGlAccounts', 1, 'colGLAccountCategory', 'Inventory').wait(100)
            .checkGridData('#grdGlAccounts', 2, 'colGLAccountCategory', 'Cost of Goods').wait(100)
            .checkGridData('#grdGlAccounts', 3, 'colGLAccountCategory', 'Sales Account').wait(100)
            .checkGridData('#grdGlAccounts', 4, 'colGLAccountCategory', 'Inventory In-Transit').wait(100)
            .checkGridData('#grdGlAccounts', 5, 'colGLAccountCategory', 'Inventory Adjustment').wait(100)
            .checkGridData('#grdGlAccounts', 6, 'colGLAccountCategory', 'Auto-Variance').wait(100)

            .selectGridComboRowByFilter('#grdGlAccounts', 0, 'strAccountId', '21000-0000-000', 400, 'strAccountId').wait(100)
            .addFunction(function (next) {
                var t = this,
                    win = Ext.WindowManager.getActive();
                if (win) {
                    var grdGlAccounts = win.down('#grdGlAccounts');
                    grdGlAccounts.editingPlugin.completeEdit();
                }
                next();
            }).wait(1000)
            .selectGridComboRowByFilter('#grdGlAccounts', 1, 'strAccountId', '16000-0000-000', 400, 'strAccountId').wait(100)
            .selectGridComboRowByFilter('#grdGlAccounts', 2, 'strAccountId', '50000-0000-000', 400, 'strAccountId').wait(100)
            .selectGridComboRowByFilter('#grdGlAccounts', 3, 'strAccountId', '40010-0001-006', 400, 'strAccountId').wait(100)
            .selectGridComboRowByFilter('#grdGlAccounts', 4, 'strAccountId', '16050-0000-000', 400, 'strAccountId').wait(100)
            .selectGridComboRowByFilter('#grdGlAccounts', 5, 'strAccountId', '16040-0000-000', 400, 'strAccountId').wait(100)
            .selectGridComboRowByFilter('#grdGlAccounts', 6, 'strAccountId', '16010-0000-000', 400, 'strAccountId').wait(100)
            .markSuccess('======== Setup GL Accounts Successful ========').wait(500)

            .clickTab('#cfgLocation').wait(300)
            .clickButton('#btnAddLocation').wait(100)
            .waitTillVisible('icitemlocation', 'Add Item Location Screen Displayed', 60000).wait(500)
            .selectComboRowByFilter('#cboSubLocation', 'Raw Station', 600, 'intSubLocationId',0).wait(100)
            .selectComboRowByFilter('#cboStorageLocation', 'RM Storage', 600, 'intStorageLocationId',0).wait(100)
            .selectComboRowByFilter('#cboIssueUom', saleuom, 600, 'strUnitMeasure').wait(500)
            .selectComboRowByFilter('#cboReceiveUom', receiveuom, 600, 'strUnitMeasure').wait(500)
            .selectComboRowByIndex('#cboNegativeInventory', 1).wait(500)
            .clickButton('#btnSave').wait(300)
            .checkStatusMessage('Saved').wait(300)
            .clickButton('#btnClose').wait(300)

            .clickTab('#cfgOthers').wait(500)
            .clickCheckBox('#chkTankRequired', true).wait(300)
            .clickCheckBox('#chkAvailableForTm', true).wait(300)

            .clickTab('#cfgPricing').wait(300)
            .checkGridData('#grdPricing', 0, 'strLocationName', '0001 - Fort Wayne').wait(100)
            .enterGridData('#grdPricing', 0, 'dblLastCost', priceLC).wait(300)
            .enterGridData('#grdPricing', 0, 'dblStandardCost', priceSC).wait(300)
            .enterGridData('#grdPricing', 0, 'dblAverageCost', priceAC).wait(300)
            //.selectGridComboRowByFilter('#grdPricing', 0, 'strPricingMethod', 'Markup Standard Cost', 400, 'strPricingMethod').wait(100)
            .selectGridComboRowByIndex('#grdPricing', 0, 'strPricingMethod',2, 'strPricingMethod').wait(100)
            .enterGridData('#grdPricing', 0, 'dblAmountPercent', '40').wait(300)
            .checkStatusMessage('Edited').wait(200)
            .clickButton('#btnSave').wait(200)
            .checkStatusMessage('Saved').wait(200)
            .displayText('Setup Item Pricing Successful').wait(500)

            .clickButton('#btnClose').wait(300)
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
        var engine = new iRely.TestEngine();
        engine.start(t, next)

            .expandMenu('Inventory').wait(500)
            .waitTillLoaded('Open Inventory Menu Successfull').wait(500)
            .openScreen('Items').wait(500)
            .waitTillLoaded('Open Items Search Screen Successful')
            .clickButton('#btnNew').wait(500)
            .waitTillVisible('icitem','Open New Item Screen Successful').wait(500)
            .checkScreenShown('icitem').wait(200)
            .checkStatusMessage('Ready')

            .enterData('#txtItemNo', item).wait(200)
            .selectComboRowByIndex('#cboType',5).wait(200)
            .enterData('#txtShortName', itemshort).wait(200)
            .enterData('#txtDescription', itemdesc).wait(200)
            .selectComboRowByFilter('#cboCategory', 'Other Charges', 500, 'cboCategory',0).wait(500)
            .selectComboRowByFilter('#cboCommodity', 'Corn', 500, 'strCommodityCode',0).wait(500)


            .clickButton('#btnLoadUOM').wait(300)
            .enterGridData('#grdUnitOfMeasure', 0, 'dblUnitQty', '1').wait(500)
            .enterGridData('#grdUnitOfMeasure', 1, 'dblUnitQty', '1').wait(500)
            .enterGridData('#grdUnitOfMeasure', 2, 'dblUnitQty', '1').wait(500)
            .enterGridData('#grdUnitOfMeasure', 3, 'dblUnitQty', '1').wait(500)
            .enterGridData('#grdUnitOfMeasure', 4, 'dblUnitQty', '1').wait(500)
            .enterGridData('#grdUnitOfMeasure', 5, 'dblUnitQty', '1').wait(500)


            .waitTillLoaded('Add UOM Successful')

            .clickTab('#cfgSetup').wait(100)

            .clickTab('#cfgLocation').wait(300)
            .clickButton('#btnAddLocation').wait(100)
            .waitTillVisible('icitemlocation','Add Item Location Screen Displayed',60000).wait(500)
            //.selectComboRowByIndex('#cboNegativeInventory', 1).wait(500)
            .clickButton('#btnSave').wait(300)
            .checkStatusMessage('Saved').wait(300)
            .clickButton('#btnClose').wait(300)

            .clickTab('#cfgCost').wait(500)
            .clickCheckBox('#chkPrice', true).wait(300)
            .selectComboRowByIndex('#cboCostType', 2).wait(500)
            .selectComboRowByIndex('#cboCostMethod', 0).wait(500)
            .selectComboRowByFilter('#cboCostUOM', 'Bushels', 500, 'strUnitMeasure',0).wait(500)
            .clickButton('#btnSave').wait(200)
            .checkStatusMessage('Saved').wait(200)
            .displayText('Setup Item Pricing Successful').wait(500)
            .clickButton('#btnClose').wait(300)
            .markSuccess('Crate Other Carge Discount Item Successful')

        },

    /**
     * Add Inventory Item
     *
     * @param {String} item - Item Number of the Item
     *
     * @param {String} itemdesc - Item Description of the Item
     *
     * @param {Integer} lottrack - Lot Tracking( Yes Manual - '0' , Yes Serial - '1' and No - '2'
     *
     * @returns {iRely.TestEngine}
     */

//        .addFunction(function(next){
//            commonIC.addICNonLottedItem(t,next,'010 - CNLTI','010 - CNLTI','Grains','Corn','FG Station','FG Bin 3')
//        })
    addICNonLottedItem: function (t,next
        , item
        , itemdesc
        , category
        , commodity
        , sublocation
        , storagelocation
        ) {
        var engine = new iRely.FunctionalTest();
        engine.start(t, next)
            .displayText('===== Add Non Lot Item Start =====')
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .clickButton('New')
            .enterData('Text Field','ItemNo',item)
            .enterData('Text Field','Description',itemdesc)
            .selectComboBoxRowValue('Category', category, 'Category',0)
            .selectComboBoxRowValue('Commodity', commodity, 'Commodity',0)
            .selectComboBoxRowNumber('LotTracking',3,0)
            .verifyData('Combo Box','Tracking','Item Level')

            .displayText('===== Setup Item UOM=====')
            .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','LB','strUnitMeasure')
            .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
            .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Bushels','strUnitMeasure')
            .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
            .clickGridCheckBox('UnitOfMeasure',0, 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
            .waitUntilLoaded('')

            .displayText('===== Setup Item GL Accounts=====')
            .clickTab('Setup')
            .clickButton('AddRequiredAccounts')
            .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
            .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
            .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
            .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
            .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
            .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
            .verifyGridData('GlAccounts', 7, 'colGLAccountCategory', 'Auto-Variance')
            .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 7, 'strAccountId', '16010-0000-000', 'strAccountId')

            .displayText('===== Setup Item Location=====')
            .clickTab('Location')
            .clickButton('AddLocation')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('SubLocation', sublocation, 'SubLocation',0)
            .selectComboBoxRowValue('StorageLocation', storagelocation, 'StorageLocation',0)
            .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
            .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
            .clickButton('Save')
            .clickButton('Close')
            .waitUntilLoaded()

            .displayText('===== Setup Item Pricing=====')
            .clickTab('Pricing')
            .waitUntilLoaded('')
            .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')
            .enterGridData('Pricing', 1, 'dblLastCost', '10')
            .enterGridData('Pricing', 1, 'dblStandardCost', '10')
            .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
            .enterGridData('Pricing', 1, 'dblAmountPercent', '40')

            .clickButton('Save')
            .clickButton('Close')
            .waitUntilLoaded()
            .clickMenuFolder('Inventory','Folder')
            .displayText('===== Add Non Lot Item End =====')
            .done();

    },


    /**
     * Add Inventory Receipt
     *
     * @param {String} item - Item no of the non lotted item to Receive
     *
     * @param {String} receiptUOM - Receipt UOM of the item
     *
     * @param {Integer} receiveqty - Quantity to receive
     *
     *@param {String} unitcost - Cost of the item
     *
     * *@param {String} weightuom - Gross/Net UOM
     *
     *
     *
     *
     *
     *
     * @returns {iRely.TestEngine}
     */


//        .addFunction(function(next){
//            commonIC.addInventoryReceiptNonLotted(t,next,'010 - CNLTI','LB','1000','10','LB','FG Station','FG Bin 3')
//        })
    addInventoryReceiptNonLotted: function (t,next
        , item
        , receiptUOM
        , receiveqty
        , unitcost
        , weightuom
        , sublocation
        , storagelocation
        ) {
        var engine = new iRely.FunctionalTest()
            var x = unitcost*receiveqty;
        engine.start(t, next)

            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Inventory Receipts','Screen')
            .waitUntilLoaded()
            .clickButton('New')
            .waitUntilLoaded('icinventoryreceipt')
            .selectComboBoxRowNumber('ReceiptType',4,0)
            .selectComboBoxRowValue('Vendor', 'ABC Trucking', 'Vendor',1)
            .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strItemNo', item,'strItemNo')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strUnitMeasure',receiptUOM,'strUnitMeasure')
            .enterGridData('InventoryReceipt', 1, 'colQtyToReceive', receiveqty)
            .enterGridData('InventoryReceipt', 1, 'colUnitCost', unitcost)
            .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strWeightUOM',weightuom,'strWeightUOM')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strSubLocationName', sublocation,'strSubLocationName')
            .selectGridComboBoxRowValue('InventoryReceipt',1,'strStorageLocationName', storagelocation,'strStorageLocationName')
            .verifyGridData('InventoryReceipt', 1, 'colCostUOM', receiptUOM)
            .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', weightuom)
            .verifyGridData('InventoryReceipt', 1, 'colGross', receiveqty)
            .verifyGridData('InventoryReceipt', 1, 'colNet', receiveqty)
            .verifyGridData('InventoryReceipt', 1, 'colLineTotal', x)


            .clickButton('Recap')
            .waitUntilLoaded('cmcmrecaptransaction')
            .waitUntilLoaded('')
            .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '16000-0001-000')
            .verifyGridData('RecapTransaction', 1, 'colRecapDebit', x)
            .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '21000-0001-000')
            .verifyGridData('RecapTransaction', 2, 'colRecapCredit', x)
            .clickButton('Post')
            .waitUntilLoaded('')
            .addResult('Successfully Posted',2000)
            .waitUntilLoaded('')
            .clickButton('Close')
            .waitUntilLoaded('')
            .clickButton('Close')
            .clickMenuFolder('Inventory','Folder')
            .displayText('===== Create Direct Inventory Receipt for Non Lotted Item Done=====')
            .done();

    },

    /**
     * Add Inventory Item
     *
     * @param {String} item - Item Number of the Item
     *
     * @param {String} itemdesc - Item Description of the Item
     *
     * @param {Integer} lottrack - Lot Tracking( Yes Manual - '0' , Yes Serial - '1' and No - '2'
     *
     * @returns {iRely.TestEngine}
     */


    addICLottedItemManual: function (t,next
        , item
        , itemdesc
        , category
        , commodity
        ) {
        var engine = new iRely.FunctionalTest();
        engine.start(t, next)
            .displayText('===== Add Non Lot Item Start =====')
            .clickMenuFolder('Inventory','Folder')
            .clickMenuScreen('Items','Screen')
            .clickButton('New')
            .enterData('Text Field','ItemNo',item)
            .enterData('Text Field','Description',itemdesc)
            .selectComboBoxRowValue('Category', category, 'Category',0)
            .selectComboBoxRowValue('Commodity', commodity, 'Commodity',0)
            .selectComboBoxRowNumber('LotTracking',1,0)
            .verifyData('Combo Box','Tracking','Item Level')

            .displayText('===== Setup Item UOM=====')
//            .addFunction(function(next){
//
//                t.chain([
//                    function (next) {
//                        var currentExec = -1;
//                        for(var x = 0; x<=UOM.length-1;x) {
//                            if(currentExec != x) {
//                                t.waitForFn(function () {
//                                    if (currentExec != x) {
//                                        new iRely.FunctionalTest()
//                                            .start(t, next)
//                                            .selectGridComboBoxRowValue('UnitOfMeasure', x + 1, 'strUnitMeasure', UOM[x], 'strUnitMeasure')
//                                            .addFunction(function (next) {
//                                                x++;
//                                                next();
//                                            })
//                                            .done();
//                                    }
//                                }, function () {
//                                    next();
//                                }, this, 60000);
//
//                                currentExec == x;
//                            }
//                        }
//                    }
//                ])

//
//                for(var x = 0; x<=UOM.length-1;x++) {
//                    var executed = false;
//                    while(executed == false) {
//                        new iRely.FunctionalTest()
//                            .start(t, next)
//                            .selectGridComboBoxRowValue('UnitOfMeasure', x + 1, 'strUnitMeasure', UOM[x], 'strUnitMeasure')
//                            .addFunction(function(next){
//                                executed = true;
//                                next();
//                            })
//                            .done();
//                    }
//                }
//                next();
//            })
            .selectGridComboBoxRowValue('UnitOfMeasure',1,'strUnitMeasure','LB','strUnitMeasure')
            .selectGridComboBoxRowValue('UnitOfMeasure',2,'strUnitMeasure','50 lb bag','strUnitMeasure')
            .selectGridComboBoxRowValue('UnitOfMeasure',3,'strUnitMeasure','Bushels','strUnitMeasure')
            .selectGridComboBoxRowValue('UnitOfMeasure',4,'strUnitMeasure','25 kg bag','strUnitMeasure')
            .clickGridCheckBox('UnitOfMeasure',1, 'strUnitMeasure', 'LB', 'ysnStockUnit', true)
            .waitUntilLoaded('')

            .displayText('===== Setup Item GL Accounts=====')
            .clickTab('Setup')
            .clickButton('AddRequiredAccounts')
            .verifyGridData('GlAccounts', 1, 'colGLAccountCategory', 'AP Clearing')
            .verifyGridData('GlAccounts', 2, 'colGLAccountCategory', 'Inventory')
            .verifyGridData('GlAccounts', 3, 'colGLAccountCategory', 'Cost of Goods')
            .verifyGridData('GlAccounts', 4, 'colGLAccountCategory', 'Sales Account')
            .verifyGridData('GlAccounts', 5, 'colGLAccountCategory', 'Inventory In-Transit')
            .verifyGridData('GlAccounts', 6, 'colGLAccountCategory', 'Inventory Adjustment')
            .verifyGridData('GlAccounts', 7, 'colGLAccountCategory', 'Auto-Variance')
            .selectGridComboBoxRowValue('GlAccounts', 1, 'strAccountId', '21000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 2, 'strAccountId', '16000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 3, 'strAccountId', '50000-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 4, 'strAccountId', '40010-0001-006', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 5, 'strAccountId', '16050-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 6, 'strAccountId', '16040-0000-000', 'strAccountId')
            .selectGridComboBoxRowValue('GlAccounts', 7, 'strAccountId', '16010-0000-000', 'strAccountId')

            .displayText('===== Setup Item Location=====')
            .clickTab('Location')
            .clickButton('AddLocation')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
            .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
            .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
            .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
            .clickButton('Save')
            .clickButton('Close')

            .clickButton('AddLocation')
            .waitUntilLoaded('')
            .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
            .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
            .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
            .selectComboBoxRowValue('IssueUom', 'LB', 'IssueUom',0)
            .selectComboBoxRowValue('ReceiveUom', 'LB', 'ReceiveUom',0)
            .clickButton('Save')
            .clickButton('Close')
            .waitUntilLoaded()
            .clickMenuFolder('Inventory','Folder')
            .done();

    }





});