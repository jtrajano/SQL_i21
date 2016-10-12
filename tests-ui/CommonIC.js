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
            .selectComboRowByFilter('#cboCategory', commodity, 500, 'cboCategory').wait(500)
            .selectComboRowByFilter('#cboCommodity', category, 500, 'strCommodityCode').wait(500)
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
            //.selectGridComboRowByIndex('#grdPricing', 0, 'strPricingMethod','2', 'strPricingMethod').wait(100)
            //.enterGridData('#grdPricing', 0, 'dblAmountPercent', '40').wait(300)
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
            .selectComboRowByFilter('#cboCategory', 'Other Charges', 500, 'cboCategory').wait(500)
            .selectComboRowByFilter('#cboCommodity', 'Corn', 500, 'strCommodityCode').wait(500)


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
            .selectComboRowByFilter('#cboCostUOM', 'Bushel', 500, 'strUnitMeasure').wait(500)
            .clickButton('#btnSave').wait(200)
            .checkStatusMessage('Saved').wait(200)
            .displayText('Setup Item Pricing Successful').wait(500)
            .clickButton('#btnClose').wait(300)
            .markSuccess('Crate Other Carge Discount Item Successful')
            .done();
        }




    });