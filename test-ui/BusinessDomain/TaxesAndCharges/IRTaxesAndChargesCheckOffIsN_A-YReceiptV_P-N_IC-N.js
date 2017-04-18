/**
 * Created by RQuidato on 4/5/2017.
 */
StartTest (function (t) {
    //var commonGL = Ext.create('GeneralLedger.commonGL');
    var commonIC = Ext.create('Inventory.CommonIC');

    new iRely.FunctionalTest().start(t)

        //Precondition: Run this first TaxesAndChargesSetup.

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
        .waitUntilLoaded('')
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
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Details')
        .waitUntilLoaded('')
        .clickTab('FreightInvoice')
        .waitUntilLoaded('')
        .verifyGridData('Charges', 1, 'colChargeAmount', '150.00')
        .verifyGridData('Charges', 1, 'colChargeTax', '0.4')
        .clickTab('Details')
        .waitUntilLoaded('')
        //.verifyData('Text Field','SubTotal','1000.00')
        //.verifyData('Text Field','Tax','40.40')
        //.verifyData('Text Field','Charges','150').waitUntilLoaded('')
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
        .waitUntilLoaded('',3000)
        .clickTab('Details')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
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
        .waitUntilLoaded('',3000)
        .displayText('===== Verify after Post > To UnPost entries =====')
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '15012-0001-001')//Inventory
        .verifyGridData('RecapTransaction', 1, 'colCredit', '1000')
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 2, 'colDebit', '1000')
        .verifyGridData('RecapTransaction', 3, 'colAccountId', '59012-0001-001')//Other Charge Expense
        .verifyGridData('RecapTransaction', 3, 'colCredit', '150')
        .verifyGridData('RecapTransaction', 4, 'colAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 4, 'colDebit', '150')
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
        .waitUntilLoaded('',3000)
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
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
        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('',3000)
        .displayText('===== Inventory Receipt Posted =====')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('',3000)


        .displayText('===== 2. Check Vouchers tab from Inventory Receipt search =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Inventory Receipts','Screen')
        .clickTab('Vouchers')
        .waitUntilLoaded()
        .addResult('Successfully Opened Vouchers tab',3000)
        .waitUntilLoaded()
        .clickButton('RefreshVoucher')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .displayText('===== Check the Other Charge  =====')
        .verifySearchGridData('Search', 5, 1, 'strAllVouchers', 'New Voucher')
        .verifySearchGridData('Search', 5, 1, 'strVendor', 'Item Vendor1', 'like')
        .verifySearchGridData('Search', 5, 1, 'strLocationName', '0001 - Fort Wayne')
        .verifySearchGridData('Search', 5, 1, 'strItemNo', 'Freight1')
        .verifySearchGridData('Search', 5, 1, 'strCurrency', 'USD')
        .verifySearchGridData('Search', 5, 1, 'dblUnitCost', '150.00')
        .verifySearchGridData('Search', 5, 1, 'strCostUOM', '')
        .verifySearchGridData('Search', 5, 1, 'dblReceiptQty', '1.00')
        .verifySearchGridData('Search', 5, 1, 'dblVoucherQty', '0.00')
        .verifySearchGridData('Search', 5, 1, 'strItemUOM', '')
        .verifySearchGridData('Search', 5, 1, 'dblReceiptLineTotal', '150.00')
        .verifySearchGridData('Search', 5, 1, 'dblVoucherLineTotal', '0.00')
        .verifySearchGridData('Search', 5, 1, 'dblReceiptTax', '0.40')
        .verifySearchGridData('Search', 5, 1, 'dblVoucherTax', '0.00')
        .verifySearchGridData('Search', 5, 1, 'dblOpenQty', '1.00')
        .verifySearchGridData('Search', 5, 1, 'dblItemsPayable', '150.00')
        .verifySearchGridData('Search', 5, 1, 'dblTaxesPayable', '0.40')

        .displayText('===== Check the Item =====')
        .verifySearchGridData('Search',5, 2, 'strAllVouchers', 'New Voucher')
        .verifySearchGridData('Search',5, 2, 'strVendor', 'Item Vendor1','like')
        .verifySearchGridData('Search',5, 2, 'strLocationName', '0001 - Fort Wayne')
        .verifySearchGridData('Search',5, 2, 'strItemNo', 'Item A1')
        .verifySearchGridData('Search',5, 2, 'strCurrency', 'USD')
        .verifySearchGridData('Search',5, 2, 'dblUnitCost', '10.00')
        .verifySearchGridData('Search',5, 2, 'strCostUOM', 'lb1')
        .verifySearchGridData('Search',5, 2, 'dblReceiptQty', '100.00')
        .verifySearchGridData('Search',5, 2, 'dblVoucherQty', '0.00')
        .verifySearchGridData('Search',5, 2, 'strItemUOM', 'lb1')
        .verifySearchGridData('Search',5, 2, 'dblReceiptLineTotal', '1000.00')
        .verifySearchGridData('Search',5, 2, 'dblVoucherLineTotal', '0.00')
        .verifySearchGridData('Search',5, 2, 'dblReceiptTax', '40.00')
        .verifySearchGridData('Search',5, 2, 'dblVoucherTax', '0.00')
        .verifySearchGridData('Search',5, 2, 'dblOpenQty', '100.00')
        .verifySearchGridData('Search',5, 2, 'dblItemsPayable', '1000.00')
        .verifySearchGridData('Search',5, 2, 'dblTaxesPayable', '40.00')
        .clickMenuFolder('Inventory','Folder')


        .displayText('===== 3. Check AP - Open Clearing Detail report =====')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Reports','Folder')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Open Clearing Detail','Screen')
        .waitUntilLoaded('srreportscreen',3000)
        .waitUntilLoaded('',3000)
        .selectGridComboBoxRowValue('Criteria',1,'colName','Vendor Id Name','FriendlyName',1)
        .selectGridComboBoxRowValue('Criteria',1,'colFrom','Item Vendor1','From',1)
        .clickButton('Apply')
        .addResult('Open Clearing Detail report opened',3000)
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .displayText('=====  Check Receipt Total =====')
        .verifyReportValue('cs5E52070B',1,10,'1,190.40')
        .displayText('=====  Check Voucher Amount =====')
        .verifyReportValue('cs5E52070B',1,11,'0.00')
        .displayText('=====  Check Current =====')
        .verifyReportValue('cs5E52070B',1,12,'0.00')
        .displayText('=====  Check Qty Received  =====')
        .verifyReportValue('cs5E52070B',1,13,'100.00')
        .displayText('=====  Check Qty Voucher =====')
        .verifyReportValue('cs5E52070B',1,14,'0.00')
        .displayText('=====  Check Qty To Voucher =====')
        .verifyReportValue('cs5E52070B',1,15,'100.00')
        .displayText('=====  Check Amount to Voucher =====')
        .verifyReportValue('cs5E52070B',1,16,'1,190.40')
        .displayText('=====  Check Days =====')
        .verifyReportValue('cs5E52070B',1,17,'0')
        .displayText('=====  Check Amount Due =====')
        .verifyReportValue('cs5E52070B',1,18,'0.00')
        .displayText('===== Check AP - Open Clearing Detail report DONE =====')
        .clickButton('Close')
        .clickMessageBoxButton('no')
        .clickMenuScreen('Reports','Folder')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')


        .displayText('===== 4. Check AP - Open Clearing report =====')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Reports','Folder')
        .waitUntilLoaded('',3000)
        .clickMenuScreen('Open Clearing','Screen')
        .waitUntilLoaded('srreportscreen',3000)
        .waitUntilLoaded('',3000)
        .selectGridComboBoxRowValue('Criteria',1,'colName','strVendorIdName','FriendlyName',1)
        .selectGridComboBoxRowValue('Criteria',1,'colFrom','Item Vendor1','From',1)
        .clickButton('Apply')
        .addResult('Open Clearing Detail report opened',3000)
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .displayText('=====  Check Receipt Total =====')
        .verifyReportValue('cs142A9109',0,2,'1,190.40')
        .displayText('=====  Check Voucher Amount =====')
        .verifyReportValue('cs142A9109',0,3,'0.00')
        .displayText('=====  Check Current =====')
        .verifyReportValue('cs142A9109',0,4,'0.00')
        .displayText('=====  Check 1-30 Days  =====')
        .verifyReportValue('cs142A9109',0,5,'0.00')
        .displayText('=====  Check 31-60 Days =====')
        .verifyReportValue('cs142A9109',0,6,'0.00')
        .displayText('=====  Check 61-90 Days =====')
        .verifyReportValue('cs142A9109',0,7,'0.00')
        .displayText('=====  Check Over 90 Days =====')
        .verifyReportValue('cs142A9109',0,8,'0.00')
        .displayText('=====  Check Bill Amount Due =====')
        .verifyReportValue('cs142A9109',0,9,'0.00')
        .clickButton('Close')
        .clickMessageBoxButton('no')
        .displayText('===== Check AP - Open Clearing report DONE =====')
        .clickMenuScreen('Reports','Folder')
        .clickMenuFolder('Purchasing (Accounts Payable)','Folder')



        .done()
});