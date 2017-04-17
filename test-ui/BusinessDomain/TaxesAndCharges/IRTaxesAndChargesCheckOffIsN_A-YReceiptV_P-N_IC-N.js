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
        .selectComboBoxRowNumber('ReceiptType',4,0)
        .selectComboBoxRowValue('Vendor', 'Item Vendor1', 'Vendor',0)
        .selectComboBoxRowValue('Location', '0001 - Fort Wayne', 'Location',0)
        .selectGridComboBoxRowValue('InventoryReceipt',1,'colItemNo','Item A1','strItemNo')
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'lb1')
        //.enterGridData('InventoryReceipt', 1, 'colUnitCost', '10')
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'lb1')
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'lb1')
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')
        .verifyGridData('InventoryReceipt', 1, 'colLineTotal', '1000')
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')
        .verifyData('Text Field','SubTotal','1000')
        .verifyData('Text Field','Tax','40')
        .verifyData('Text Field','Charges','0')
        .verifyData('Text Field','GrossWgt','0')
        .verifyData('Text Field','NetWgt','0')
        .verifyData('Text Field','Total','0')
        .clickTab('Charges & Invoice')
        .selectGridComboBoxRowValue('Charges',1,'colOtherCharge','Freight1','strItemNo')
        .verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
        .verifyGridData('Charges', 1, 'colCostMethod', 'Per Unit')
        .verifyGridData('Charges', 1, 'colChargeCurrency', 'USD')
        .verifyGridData('Charges', 1, 'colRate', '1.50')
        .verifyGridData('Charges', 1, 'colChargeUOM', 'lb1')
        .verifyGridData('Charges', 1, 'colChargeAmount', '0')
        .verifyGridData('Charges', 1, 'colAccrue', 'true')
        .verifyGridData('Charges', 1, 'colCostVendor', 'Item Vendor1')
        .verifyGridData('Charges', 1, 'colInventoryCost', 'false')
        .verifyGridData('Charges', 1, 'colAllocateCostBy', 'Unit')
        .verifyGridData('Charges', 1, 'colPrice', 'false')
        .verifyGridData('Charges', 1, 'colChargeTaxGroup', 'Test Group 1')
        .verifyGridData('Charges', 1, 'colChargeTax', '0')
        .clickButton('CalculateCharges')
        .verifyGridData('Charges', 1, 'colChargeAmount', '150')
        .verifyGridData('Charges', 1, 'colChargeTax', '0.40')
        .selectGridRowNumber('Charges',1)
        .clickButton('ChargeTaxDetails')
        .waitUntilLoaded('search',3000)
//        .verifyGridData('Search', 1, 'colOtherCharge', 'Freight1')
//        .verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
//        .verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
//        .verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
//        .verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
//        .verifyGridData('Charges', 1, 'colOtherCharge', 'Freight1')
        .clickButton('Close')
        .waitUntilLoaded('')
        .clickTab('Details')
        .waitUntilLoaded('')
        .verifyData('Text Field','SubTotal','1000')
        .verifyData('Text Field','Tax','40.40')
        .verifyData('Text Field','Charges','150')
        .verifyData('Text Field','GrossWgt','0')
        .verifyData('Text Field','NetWgt','0')
        .verifyData('Text Field','Total','1190.40')
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .displayText('===== Verify To Post entries =====')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '59012-0001-001')//Other Charge Expense
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '150')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '150')
        .verifyGridData('RecapTransaction', 3, 'colRecapAccountId', '15012-0001-001')//Inventory
        .verifyGridData('RecapTransaction', 3, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 4, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 4, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 5, 'colRecapAccountId', '72512-0001-001')//Tax Expense - Item A1
        .verifyGridData('RecapTransaction', 5, 'colRecapDebit', '40')
        .verifyGridData('RecapTransaction', 6, 'colRecapAccountId', '72512-0001-001')//Tax Expense - Freight1
        .verifyGridData('RecapTransaction', 6, 'colRecapDebit', '0.40')
        .verifyGridData('RecapTransaction', 7, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 7, 'colRecapCredit', '40')
        .verifyGridData('RecapTransaction', 8, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 8, 'colRecapCredit', '0.40')
        .clickButton('Post')
        .addResult('Successfully Posted',3000)
        .addResult('Successfully Posted',3000)
        .addResult('Successfully Posted',3000)
        .clickTab('Details')
        .clickTab('UnPost Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .displayText('===== Verify Posted entries =====')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '59012-0001-001')//Other Charge Expense
        .verifyGridData('RecapTransaction', 1, 'colRecapCredit', '150')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 2, 'colRecapDebit', '150')
        .verifyGridData('RecapTransaction', 3, 'colRecapAccountId', '15012-0001-001')//Inventory
        .verifyGridData('RecapTransaction', 3, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 4, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 4, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 5, 'colRecapAccountId', '72512-0001-001')//Tax Expense - Item A1
        .verifyGridData('RecapTransaction', 5, 'colRecapCredit', '40')
        .verifyGridData('RecapTransaction', 6, 'colRecapAccountId', '72512-0001-001')//Tax Expense - Freight1
        .verifyGridData('RecapTransaction', 6, 'colRecapCredit', '0.40')
        .verifyGridData('RecapTransaction', 7, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 7, 'colRecapDebit', '40')
        .verifyGridData('RecapTransaction', 8, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 8, 'colRecapDebit', '0.40')
        .clickButton('Unpost')
        .displayText('===== Verify after Unpost entries = To Post entries =====')
        .verifyGridData('RecapTransaction', 1, 'colRecapAccountId', '59012-0001-001')//Other Charge Expense
        .verifyGridData('RecapTransaction', 1, 'colRecapDebit', '150')
        .verifyGridData('RecapTransaction', 2, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 2, 'colRecapCredit', '150')
        .verifyGridData('RecapTransaction', 3, 'colRecapAccountId', '15012-0001-001')//Inventory
        .verifyGridData('RecapTransaction', 3, 'colRecapDebit', '1000')
        .verifyGridData('RecapTransaction', 4, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 4, 'colRecapCredit', '1000')
        .verifyGridData('RecapTransaction', 5, 'colRecapAccountId', '72512-0001-001')//Tax Expense - Item A1
        .verifyGridData('RecapTransaction', 5, 'colRecapDebit', '40')
        .verifyGridData('RecapTransaction', 6, 'colRecapAccountId', '72512-0001-001')//Tax Expense - Freight1
        .verifyGridData('RecapTransaction', 6, 'colRecapDebit', '0.40')
        .verifyGridData('RecapTransaction', 7, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Item A1
        .verifyGridData('RecapTransaction', 7, 'colRecapCredit', '40')
        .verifyGridData('RecapTransaction', 8, 'colRecapAccountId', '20022-0001-001')//AP Clearing - Freight1
        .verifyGridData('RecapTransaction', 8, 'colRecapCredit', '0.40')


        .displayText('===== Inventory Receipt Posted =====')




        .done()
});