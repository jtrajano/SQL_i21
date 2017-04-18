/**
 * Created by RQuidato on 4/5/2017.
 */
StartTest (function (t) {
    //var commonGL = Ext.create('GeneralLedger.commonGL');
    var commonIC = Ext.create('Inventory.CommonIC');

    new iRely.FunctionalTest().start(t)

        //Create Inventory Receipt
        .displayText('===== 1. Create Inventory Receipt  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickButton('New')
        .waitUntilLoaded('icinventoryreceipt',3000)
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'Item Vendor1', 'Vendor',0)
        .waitUntilLoaded('',3000)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .verifyData('Combo Box','Currency','USD')
        .selectGridComboBoxRowValue('InventoryReceipt',1,'colItemNo','Item A1','strItemNo')
        .waitUntilLoaded('',3000)
        //.waitUntilLoaded('',3000)
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'lb1')
        //.enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'lb1')
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'lb1')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')

        .displayText('===== Check computed values in the Item grid =====')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colItemTaxGroup', 'Test Group 1')
        .verifyGridData('InventoryReceipt', 1, 'colTax', '40')
        .waitUntilLoaded()
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')
        .clickButton('TaxDetails')
        .waitUntilLoaded('icinventoryreceipttaxes',3000)
        .waitUntilLoaded('',3000)
        .verifyScreenWindow({
            alias: 'icinventoryreceipttaxes',
            title: 'Tax Details',
            collapse: true,
            maximize: true,
            minimize: false,
            restore: false,
            close: true
        })
        .displayText('===== Check Tax Details =====')
        .verifyGridData('GridTemplate', 1, 'colItemNo', 'Item A1')
        .verifyGridData('GridTemplate', 1, 'colTaxGroup', 'Test Group 1')
        .verifyGridData('GridTemplate', 1, 'colTaxClass', 'Tax Class A')
        .verifyGridData('GridTemplate', 1, 'colTaxCode', 'Tax 2')
        .verifyGridData('GridTemplate', 1, 'colCalculationMethod', 'Unit')
        .verifyGridData('GridTemplate', 1, 'colRate', '0.40')
        .verifyGridData('GridTemplate', 1, 'colTax', '40.00')
        .clickButton('Close')

        .displayText('===== Check Summary Total =====')
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtSubTotal').value;
            if (total == '1000') {
                t.ok(true, 'Sub Total is correct.');
            }
            else {
                t.ok(false, 'Sub Total is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtTax').value;
            if (total == '40') {
                t.ok(true, 'Tax is correct.');
            }
            else {
                t.ok(false, 'Tax is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtCharges').value;
            if (total == '0') {
                t.ok(true, 'Charges is correct.');
            }
            else {
                t.ok(false, 'Charges is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtGrossWgt').value;
            if (total == '100') {
                t.ok(true, 'Gross Wgt is correct.');
            }
            else {
                t.ok(false, 'Gross Wgt is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtNetWgt').value;
            if (total == '100') {
                t.ok(true, 'Net Wgt is correct.');
            }
            else {
                t.ok(false, 'Net Wgt is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtTotal').value;
            if (total == '1040') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickTab('FreightInvoice')
        .selectGridComboBoxRowValue('Charges',1,'colOtherCharge','Freight1','strItemNo')
        .verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
        .verifyGridData('Charges', 1, 'colOnCostType', '')
        .verifyGridData('Charges', 1, 'colCostMethod', 'Per Unit')
        .verifyGridData('Charges', 1, 'colChargeCurrency', 'USD')
        .verifyGridData('Charges', 1, 'colRate', '1.5')
        .verifyGridData('Charges', 1, 'colChargeUOM', 'lb1')
        .verifyGridData('Charges', 1, 'colChargeAmount', '0.00')
        .verifyGridData('Charges', 1, 'ysnAccrue', 'true')
        .verifyGridData('Charges', 1, 'colCostVendor', 'Item Vendor1')
        .verifyGridData('Charges', 1, 'ysnInventoryCost', 'false')
        .verifyGridData('Charges', 1, 'colAllocateCostBy', 'Unit')
        .verifyGridData('Charges', 1, 'ysnPrice', 'false')
        .verifyGridData('Charges', 1, 'colChargeTaxGroup', 'Test Group 1')
        .verifyGridData('Charges', 1, 'colChargeTax', '0')
        .clickButton('CalculateCharges')
        .waitUntilLoaded('')
        .verifyGridData('Charges', 1, 'colChargeAmount', '150')
        .verifyGridData('Charges', 1, 'colChargeTax', '0.4')
        //.selectGridRowNumber('Charges',1)
        //.clickButton('ChargeTaxDetails')
        //.waitUntilLoaded('search',3000)
        //.verifyGridData('Search', 1, 'colOtherCharge', 'Freight1')
        //.verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
        //.verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
        //.verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
        //.verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
        //.verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
        //.clickButton('Close')
        //.waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        //.verifyData('Text Field','SubTotal','1000.00')
        //.verifyData('Text Field','Tax','40.40')
        //.verifyData('Text Field','Charges','150')
        //.verifyData('Text Field','GrossWgt','0')
        //.verifyData('Text Field','NetWgt','0')
        //.verifyData('Text Field','Total','1190.40')

        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtSubTotal').value;
            if (total == '1000') {
                t.ok(true, 'Sub Total is correct.');
            }
            else {
                t.ok(false, 'Sub Total is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtTax').value;
            if (total == '40.40') {
                t.ok(true, 'Tax is correct.');
            }
            else {
                t.ok(false, 'Tax is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtCharges').value;
            if (total == '150') {
                t.ok(true, 'Charges is correct.');
            }
            else {
                t.ok(false, 'Charges is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtGrossWgt').value;
            if (total == '100') {
                t.ok(true, 'Gross Wgt is correct.');
            }
            else {
                t.ok(false, 'Gross Wgt is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtNetWgt').value;
            if (total == '100') {
                t.ok(true, 'Net Wgt is correct.');
            }
            else {
                t.ok(false, 'Net Wgt is incorrect.');
            }
            next();
        })
        .addFunction(function (next){
            var win =  Ext.WindowManager.getActive(),
                total = win.down('#txtTotal').value;
            if (total == '1190.40') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
        .clickTab('Post Preview',3000)
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('Post Preview',3000)
        .clickTab('Post Preview',3000)
        .waitUntilLoaded('')
        .displayText('===== Verify To Post entries =====')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '59012-0001-001')//Other Charge Expense
        .verifyGridData('RecapTransaction', 1, 'colDebit', '150')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 2, 'colCredit', '150')
        .verifyGridData('RecapTransaction', 3, 'colAccountId', '15012-0001-001')//Inventory
        .verifyGridData('RecapTransaction', 3, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 4, 'colAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 4, 'colCredit', '1000')
        .verifyGridData('RecapTransaction', 5, 'colAccountId', '72512-0001-001')//Tax Expense - Item A1
        .verifyGridData('RecapTransaction', 5, 'colDebit', '40')
        .verifyGridData('RecapTransaction', 6, 'colAccountId', '72512-0001-001')//Tax Expense - Freight1
        .verifyGridData('RecapTransaction', 6, 'colDebit', '0.4')
        .verifyGridData('RecapTransaction', 7, 'colAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 7, 'colCredit', '40')
        .verifyGridData('RecapTransaction', 8, 'colAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 8, 'colCredit', '0.4')
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Details')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
        .displayText('===== Verify after Post > To UnPost entries =====')
        .verifyGridData('RecapTransaction', 3, 'colAccountId', '15012-0001-001')//Inventory
        .verifyGridData('RecapTransaction', 3, 'colCredit', '1000')
        .verifyGridData('RecapTransaction', 4, 'colAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 4, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '59012-0001-001')//Other Charge Expense
        .verifyGridData('RecapTransaction', 1, 'colCredit', '150')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 2, 'colDebit', '150')
        .verifyGridData('RecapTransaction', 5, 'colAccountId', '72512-0001-001')//Tax Expense - Item A1
        .verifyGridData('RecapTransaction', 5, 'colCredit', '40')
        .verifyGridData('RecapTransaction', 6, 'colAccountId', '72512-0001-001')//Tax Expense - Freight1
        .verifyGridData('RecapTransaction', 6, 'colCredit', '0.40')
        .verifyGridData('RecapTransaction', 7, 'colAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 7, 'colDebit', '40')
        .verifyGridData('RecapTransaction', 8, 'colAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 8, 'colDebit', '0.4')
        .clickButton('Unpost')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .addResult('Successfully Unposted',3000)
        .clickTab('Details')
        .waitUntilLoaded('',3000)
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .displayText('===== Verify after Unpost > To Post entries =====')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '59012-0001-001')//Other Charge Expense
        .verifyGridData('RecapTransaction', 1, 'colDebit', '150')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 2, 'colCredit', '150')
        .verifyGridData('RecapTransaction', 3, 'colAccountId', '15012-0001-001')//Inventory
        .verifyGridData('RecapTransaction', 3, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 4, 'colAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 4, 'colCredit', '1000')
        .verifyGridData('RecapTransaction', 5, 'colAccountId', '72512-0001-001')//Tax Expense - Item A1
        .verifyGridData('RecapTransaction', 5, 'colDebit', '40')
        .verifyGridData('RecapTransaction', 6, 'colAccountId', '72512-0001-001')//Tax Expense - Freight1
        .verifyGridData('RecapTransaction', 6, 'colDebit', '0.4')
        .verifyGridData('RecapTransaction', 7, 'colAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 7, 'colCredit', '40')
        .verifyGridData('RecapTransaction', 8, 'colAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 8, 'colCredit', '0.4')


        .displayText('===== Inventory Receipt Posted =====')




        .done()
});