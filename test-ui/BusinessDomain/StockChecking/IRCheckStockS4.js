/**
 * Created by RQuidato on 5/11/2017.
 */

StartTest (function (t) {
//    var commonGL = Ext.create('GeneralLedger.commonGL');
    var commonIC = Ext.create('Inventory.CommonIC');

    new iRely.FunctionalTest().start(t)


        //Add Item
        .displayText('===== Scenario 4: Direct Inventory Receipt - Unposted =====')
        .displayText('===== 1. Create Item =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .waitUntilLoaded('',3000)
        .clickButton('New')
        .waitUntilLoaded('icitem',3000)
        .enterData('Text Field','ItemNo','Item StockCheckIR-4')
        .selectComboBoxRowNumber('Type',2,0)
        .enterData('Text Field','Description','Item StockCheckIR-4 desc')
        .selectComboBoxRowValue('Category', 'Item Category1', 'Category',1)
        .selectComboBoxRowValue('Commodity', 'Commodity1', 'Commodity',1)
        .selectComboBoxRowNumber('LotTracking',1,0)
        .verifyData('Combo Box','Tracking','Lot Level')

        .displayText('===== Setup Item UOM =====')
        .verifyGridData('UnitOfMeasure', 1, 'colDetailUnitQty', '1.000000')
        .verifyGridData('UnitOfMeasure', 2, 'colDetailUnitQty', '10.000000')
        .verifyGridData('UnitOfMeasure', 3, 'colDetailUnitQty', '2.204620')


        .displayText('===== Setup Item Location=====')
        .clickTab('Setup')
        .waitUntilLoaded('',3000)
        .clickTab('Location')
        .clickButton('AddLocation')
        .waitUntilLoaded('icitemlocation',3000)
        .selectComboBoxRowValue('SubLocation', 'Raw Station', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'RM Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'lb1', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'lb1', 'ReceiveUom',0)
        .clickButton('Save')
        .waitUntilLoaded('',3000)
        .clickButton('Close')
        .waitUntilLoaded('',3000)
        .displayText('===== Setup Item Location - 0001 Done=====')

        .clickButton('AddLocation')
        .waitUntilLoaded('icitemlocation',3000)
        .selectComboBoxRowValue('Location', '0002 - Indianapolis', 'Location',0)
        .selectComboBoxRowValue('SubLocation', 'Indy', 'SubLocation',0)
        .selectComboBoxRowValue('StorageLocation', 'Indy Storage', 'StorageLocation',0)
        .selectComboBoxRowValue('IssueUom', 'lb1', 'IssueUom',0)
        .selectComboBoxRowValue('ReceiveUom', 'lb1', 'ReceiveUom',0)
        .clickButton('Save')
        .waitUntilLoaded('',3000)
        .clickButton('Close')
        .waitUntilLoaded('',3000)
        .displayText('===== Setup Item Location - 0002 Done=====')

        .displayText('===== Setup Item Pricing=====')
        .clickTab('Pricing')
        .waitUntilLoaded('')

        //0001 - Fort Wayne
        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'strLocationName',text: 'Location'}])
        .verifyGridData('Pricing', 1, 'strLocationName', '0001 - Fort Wayne')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblLastCost',text: 'Last Cost'}])
        .enterGridData('Pricing', 1, 'dblLastCost', '10')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblStandardCost',text: 'Standard Cost'}])
        .enterGridData('Pricing', 1, 'dblStandardCost', '10')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblAverageCost',text: 'Average Cost'}])
        .verifyGridData('Pricing', 1, 'dblAverageCost', '0')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'strPricingMethod',text: 'Pricing Method'}])
        .selectGridComboBoxRowNumber('Pricing', 1, 'strPricingMethod',3)
        .waitUntilLoaded('')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblAmountPercent',text: 'Amount/Percent'}])
        .enterGridData('Pricing', 1, 'dblAmountPercent', '40')
        .waitUntilLoaded('')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblSalePrice',text: 'Retail Price'}])
        .verifyGridData('Pricing', 1, 'dblSalePrice', '14')
        .waitUntilLoaded('')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblMSRPPrice',text: 'MSRP'}])
        .verifyGridData('Pricing', 1, 'dblMSRPPrice', '0')

        //0002 - Indianapolis
        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'strLocationName',text: 'Location'}])
        .verifyGridData('Pricing', 2, 'strLocationName', '0002 - Indianapolis')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblLastCost',text: 'Last Cost'}])
        .enterGridData('Pricing', 2, 'dblLastCost', '10')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblStandardCost',text: 'Standard Cost'}])
        .enterGridData('Pricing', 2, 'dblStandardCost', '10')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblAverageCost',text: 'Average Cost'}])
        .verifyGridData('Pricing', 2, 'dblAverageCost', '0')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'strPricingMethod',text: 'Pricing Method'}])
        .selectGridComboBoxRowNumber('Pricing', 2, 'strPricingMethod',3)
        .waitUntilLoaded('')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblAmountPercent',text: 'Amount/Percent'}])
        .enterGridData('Pricing', 2, 'dblAmountPercent', '40')
        .waitUntilLoaded('')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblSalePrice',text: 'Retail Price'}])
        .verifyGridData('Pricing', 2, 'dblSalePrice', '14')
        .waitUntilLoaded('')

        .verifyGridColumnNames ('Pricing', [{ dataIndex: 'dblMSRPPrice',text: 'MSRP'}])
        .verifyGridData('Pricing', 2, 'dblMSRPPrice', '0')

        .clickButton('Save')
        .waitUntilLoaded('',3000)
        .clickButton('Close')
        .waitUntilLoaded('',3000)
        .displayText('===== Setup Item Pricing Done=====')
        .displayText('===== 1. Create Item DONE =====')
        .clickMenuFolder('Inventory','Folder')

        //Create Inventory Receipt
        .displayText('===== 2. Create Inventory Receipt  =====')
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
        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strItemNo',text: 'Item No.'}])
        .selectGridComboBoxRowValue('InventoryReceipt',1,'colItemNo','Item StockCheckIR-4','strItemNo',1)
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)

        .displayText('===== Inventory Receipt - Lot Tracking grid =====')
        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'dblOpenReceive',text: 'Qty to Receive'}])
        .enterUOMGridData('InventoryReceipt', 1, 'colUOMQtyToReceive', 'strUnitMeasure', 100, 'lb1')
        .waitUntilLoaded('')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strSubCurrency',text: 'Currency Unit'}])
        .verifyGridData('InventoryReceipt', 1, 'colItemSubCurrency', 'USD')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'dblUnitCost',text: 'Cost'}])
        .verifyGridData('InventoryReceipt', 1, 'colCostUOM', 'lb1')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strCostUOM',text: 'Cost UOM'}])
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'lb1')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strWeightUOM',text: 'Gross/Net UOM'}])
        .verifyGridData('InventoryReceipt', 1, 'colWeightUOM', 'lb1')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'dblGross',text: 'Gross'}])
        .verifyGridData('InventoryReceipt', 1, 'colGross', '100')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'dblNet',text: 'Net'}])
        .verifyGridData('InventoryReceipt', 1, 'colNet', '100')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'dblLineTotal',text: 'Line Total'}])
        .verifyGridData('InventoryReceipt', 1, 'dblLineTotal', '1000')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strTaxGroup',text: 'Tax Group'}])
        .verifyGridData('InventoryReceipt', 1, 'colItemTaxGroup', '')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'dblTax',text: 'Tax'}])
        .verifyGridData('InventoryReceipt', 1, 'dblTax', '0')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strForexRateType',text: 'Forex Rate Type'}])
        .isControlVisible('col',['ForexRateType'], false)

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'dblForexRate',text: 'Forex Rate'}])
        .isControlVisible('col',['ForexRate'], false)

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strSubLocationName',text: 'Sub Location'}])
        .verifyGridData('InventoryReceipt', 1, 'colSubLocation', 'Raw Station')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strStorageLocationName',text: 'Storage Location'}])
        .verifyGridData('InventoryReceipt', 1, 'colStorageLocation', 'RM Storage')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strOwnershipType',text: 'Ownership Type'}])
        .verifyGridData('InventoryReceipt', 1, 'colOwnershipType', 'Own')

        .verifyGridColumnNames ('InventoryReceipt', [{ dataIndex: 'strLotTracking',text: 'Lot Tracking'}])
        .verifyGridData('InventoryReceipt', 1, 'colLotTracking', 'Yes - Manual')

        .displayText('===== Inventory Receipt - Lot Tracking grid =====')
        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'strLotNumber',text: 'Lot Number'}])
        .enterGridData('LotTracking', 1, 'strLotNumber', 'LOT-1')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'strParentLotNumber',text: 'Parent Lot Number'}])
        .verifyGridData('LotTracking', 1, 'colLotParentLotId', '')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'strUnitMeasure',text: 'Lot UOM'}])
        .verifyGridData('LotTracking', 1, 'colLotUOM', 'lb1')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'dblQuantity',text: 'Quantity'}])
        .verifyGridData('LotTracking', 1, 'colLotQuantity', '100')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'dblGrossWeight',text: 'Gross'}])
        .verifyGridData('LotTracking', 1, 'colLotGrossWeight', '100')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'dblTareWeight',text: 'Tare'}])
        .verifyGridData('LotTracking', 1, 'colLotTareWeight', '0')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'dblNetWeight',text: 'Net'}])
        .verifyGridData('LotTracking', 1, 'colLotNetWeight', '100')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'strWeightUOM',text: 'Lot Wgt UOM'}])
        .verifyGridData('LotTracking', 1, 'colLotWeightUOM', 'lb1')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'strStorageLocation',text: 'Storage Location'}])
        .verifyGridData('LotTracking', 1, 'colLotStorageLocation', 'RM Storage')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'dtmExpiryDate',text: 'Expiry Date'}])
        .verifyGridData('LotTracking', 1, 'dtmExpiryDate', null)

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'strLotAlias',text: 'Lot Alias'}])
        .verifyGridData('LotTracking', 1, 'colLotAlias', '')

        .verifyGridColumnNames ('LotTracking', [{ dataIndex: 'dblTareWeight',text: 'Tare'}])
        .verifyGridData('LotTracking', 1, 'colLotUOM', 'lb1')


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
            if (total == '0') {
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
            if (total == '1000') {
                t.ok(true, 'Total is correct.');
            }
            else {
                t.ok(false, 'Total is incorrect.');
            }
            next();
        })

        .clickButton('Save')
        .waitUntilLoaded('',3000)
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Details')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Post Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .displayText('===== Verify GL entries when transaction is Posted =====')
        .verifyGridColumnNames ('RecapTransaction', [{ dataIndex: 'strAccountId',text: 'Account ID'}])
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '15012-0001-001')//Inventory

        .verifyGridColumnNames ('RecapTransaction', [{ dataIndex: 'dblDebit',text: 'Debit'}])
        .verifyGridData('RecapTransaction', 1, 'colDebit', '1000')

        .verifyGridColumnNames ('RecapTransaction', [{ dataIndex: 'strAccountId',text: 'Account ID'}])
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '20022-0001-001')//AP Clearing - Item

        .verifyGridColumnNames ('RecapTransaction', [{ dataIndex: 'dblCredit',text: 'Credit'}])
        .verifyGridData('RecapTransaction', 2, 'colCredit', '1000')
        .displayText('===== Verify GL entries when transaction is Posted DONE =====')

        .clickButton('Post')
        .waitUntilLoaded('')
        .addResult('Successfully Posted',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Unpost Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Details')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .clickTab('Unpost Preview')
        .waitUntilLoaded('',3000)
        .waitUntilLoaded('',3000)
        .displayText('===== Verify GL entries when transaction is Unposted =====')
        .verifyGridColumnNames ('RecapTransaction', [{ dataIndex: 'strAccountId',text: 'Account ID'}])
        .verifyGridData('RecapTransaction', 1, 'colAccountId', '15012-0001-001')//Inventory

        .verifyGridColumnNames ('RecapTransaction', [{ dataIndex: 'dblCredit',text: 'Credit'}])
        .verifyGridData('RecapTransaction', 1, 'colCredit', '1000')

        .verifyGridColumnNames ('RecapTransaction', [{ dataIndex: 'strAccountId',text: 'Account ID'}])
        .verifyGridData('RecapTransaction', 2, 'colAccountId', '20022-0001-001')//AP Clearing - Item

        .verifyGridColumnNames ('RecapTransaction', [{ dataIndex: 'dblDebit',text: 'Debit'}])
        .verifyGridData('RecapTransaction', 2, 'colDebit', '1000')
        .displayText('===== Verify GL entries when transaction is Unposted DONE =====')

        .clickButton('Unpost')
        .waitUntilLoaded('')
        .addResult('Successfully Unposted',3000)
        .waitUntilLoaded('',3000)
        .displayText('===== 2. Create Inventory Receipt DONE =====')

        .clickButton('Delete')
        .waitUntilLoaded('',3000)
        .clickMessageBoxButton('yes')
        .waitUntilLoaded('')
        .displayText('===== Delete Inventory Receipt DONE =====')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')


        //Verify Lot Details
        .displayText('=====  Verify Lot Details =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen ('Lot Details','Screen')
        .waitUntilLoaded('iclotdetail',3000)
        .waitUntilLoaded('iclotdetail',3000)
        .waitUntilLoaded('iclotdetail',3000)
        .waitUntilLoaded('iclotdetail',3000)
        .addResult('Opened Lot Detail',3000)
        .selectSearchRowValue('Item StockCheckIR-4','strItemNo',1,0)
        .waitUntilLoaded('',3000)
        .displayText('This counts the number of records in the search grid.')
        .verifyGridRecordCount('Search', 1)
        .waitTillLoaded('',3000)
        .waitTillLoaded('',3000)
        .waitTillLoaded('',3000)

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strItemNo',text: 'Item No'}])
        .verifyGridData('Search', 1, 'strItemNo', 'Item StockCheckIR-4')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strItemDescription',text: 'Description'}])
        .verifyGridData('Search', 1, 'strItemDescription', 'Item StockCheckIR-4 desc')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strProductType',text: 'Product Type'}])
        .verifyGridData('Search', 1, 'strProductType', null)

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strLocationName',text: 'Location Name'}])
        .verifyGridData('Search', 1, 'strLocationName', '0001 - Fort Wayne')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strSubLocationName',text: 'Sub Location'}])
        .verifyGridData('Search', 1, 'strSubLocationName', 'Raw Station')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strStorageLocation',text: 'Storage Location'}])
        .verifyGridData('Search', 1, 'strStorageLocation', 'RM Storage')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strLotNumber',text: 'Lot Number'}])
        .verifyGridData('Search', 1, 'strLotNumber', 'LOT-1')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblQty',text: 'Quantity'}])
        .verifyGridData('Search', 1, 'dblQty', '0.00')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strItemUOM',text: 'Quantity UOM'}])
        .verifyGridData('Search', 1, 'strItemUOM', 'lb1')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblWeight',text: 'Weight'}])
        .verifyGridData('Search', 1, 'dblQty', '0.00')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strWeightUOM',text: 'Weight UOM'}])
        .verifyGridData('Search', 1, 'strWeightUOM', 'lb1')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblWeightPerQty',text: 'Weight Per Qty'}])
        .verifyGridData('Search', 1, 'dblWeightPerQty', '1.00')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblLastCost',text: 'Last Cost'}])
        .verifyGridData('Search', 1, 'dblLastCost', '10.00')

        .verifyGridColumnNames ('Search', [{ dataIndex: 'strCostUOM',text: 'Cost UOM'}])
        .verifyGridData('Search', 1, 'strCostUOM', 'lb1')

        .displayText('=====  Verify Lot Details DONE =====')
        .clickMenuFolder('Inventory','Folder')

        //Verify Stock Details
        .displayText('=====  Verify Stock Details  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen ('Stock Details','Screen')
        .waitUntilLoaded('icstockdetail',3000)
        .addResult('Opened Stock Details',3000)
//        .selectSearchRowValue('Item StockCheckIR-4','strItemNo',1,2)
//        .waitUntilLoaded('',3000)
//
//        .displayText('This counts the number of records in the search grid.')
//        .verifyGridRecordCount('Search', 2)
//        .waitTillLoaded('',3000)
//
//
//        .displayText('=====  Verify Location: 0001 - Fort Wayne =====')
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strItemNo',text: 'Item No'}])
//        .verifyGridData('Search', 1, 'strItemNo', 'Item StockCheckIR-4')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strDescription',text: 'Description'}])
//        .verifyGridData('Search', 1, 'strDescription', 'Item StockCheckIR-4 desc')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strType',text: 'Item Type'}])
//        .verifyGridData('Search', 1, 'strType', 'Inventory')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strCommodityCode',text: 'Commodity'}])
//        .verifyGridData('Search', 1, 'strCommodityCode', 'Commodity1')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strCategoryCode',text: 'Category'}])
//        .verifyGridData('Search', 1, 'strCategoryCode', 'Item Category1')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strLocationName',text: 'Location'}])
//        .verifyGridData('Search', 1, 'strLocationName', '0001 - Fort Wayne')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strSubLocationName',text: 'Storage Location'}])
//        .verifyGridData('Search', 1, 'strSubLocationName', 'Raw Station')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strStorageLocationName',text: 'Storage Unit'}])
//        .verifyGridData('Search', 1, 'strStorageLocationName', 'RM Storage')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strStockUOM',text: 'Stock UOM'}])
//        .verifyGridData('Search', 1, 'strStockUOM', 'lb1')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblUnitOnHand',text: 'On Hand'}])
//        .verifyGridData('Search', 1, 'dblUnitOnHand', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblOnOrder',text: 'On Order'}])
//        .verifyGridData('Search', 1, 'dblOnOrder', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblOrderCommitted',text: 'Committed'}])
//        .verifyGridData('Search', 1, 'dblOrderCommitted', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblUnitReserved',text: 'Reserved'}])
//        .verifyGridData('Search', 1, 'dblUnitReserved', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblInTransitInbound',text: 'In Transit Inbound'}])
//        .verifyGridData('Search', 1, 'dblInTransitInbound', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblInTransitOutbound',text: 'In Transit Outbound'}])
//        .verifyGridData('Search', 1, 'dblInTransitOutbound', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblUnitStorage',text: 'On Storage'}])
//        .verifyGridData('Search', 1, 'dblUnitStorage', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblConsignedPurchase',text: 'Consigned Purchase'}])
//        .verifyGridData('Search', 1, 'dblConsignedPurchase', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblConsignedSale',text: 'Consigned Sale'}])
//        .verifyGridData('Search', 1, 'dblConsignedSale', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblAvailable',text: 'Available'}])
//        .verifyGridData('Search', 1, 'dblAvailable', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblReorderPoint',text: 'Reorder Point'}])
//        .verifyGridData('Search', 1, 'dblReorderPoint', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblLastCost',text: 'Last Cost'}])
//        .verifyGridData('Search', 1, 'dblLastCost', '10.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblAverageCost',text: 'Average Cost'}])
//        .verifyGridData('Search', 1, 'dblAverageCost', '10.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblStandardCost',text: 'Standard Cost'}])
//        .verifyGridData('Search', 1, 'dblStandardCost', '10.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblSalePrice',text: 'Retail Price'}])
//        .verifyGridData('Search', 1, 'dblSalePrice', '14.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblExtendedCost',text: 'Extended Cost'}])
//        .verifyGridData('Search', 1, 'dblExtendedCost', '0.00')
//        .displayText('=====  Verify Location: 0001 - Fort Wayne DONE =====')
//
//        .displayText('=====  Verify Location: 0002 - Indianapolis =====')
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strItemNo',text: 'Item No'}])
//        .verifyGridData('Search', 2, 'strItemNo', 'Item StockCheckIR-4')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strDescription',text: 'Description'}])
//        .verifyGridData('Search', 2, 'strDescription', 'Item StockCheckIR-4 desc')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strType',text: 'Item Type'}])
//        .verifyGridData('Search', 2, 'strType', 'Inventory')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strCommodityCode',text: 'Commodity'}])
//        .verifyGridData('Search', 2, 'strCommodityCode', 'Commodity1')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strCategoryCode',text: 'Category'}])
//        .verifyGridData('Search', 2, 'strCategoryCode', 'Item Category1')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strLocationName',text: 'Location'}])
//        .verifyGridData('Search', 2, 'strLocationName', '0002 - Indianapolis')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strSubLocationName',text: 'Storage Location'}])
//        .verifyGridData('Search', 2, 'strSubLocationName', 'Indy')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strStorageLocationName',text: 'Storage Unit'}])
//        .verifyGridData('Search', 2, 'strStorageLocationName', 'Indy Storage')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'strStockUOM',text: 'Stock UOM'}])
//        .verifyGridData('Search', 2, 'strStockUOM', 'lb1')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblUnitOnHand',text: 'On Hand'}])
//        .verifyGridData('Search', 2, 'dblUnitOnHand', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblOnOrder',text: 'On Order'}])
//        .verifyGridData('Search', 2, 'dblOnOrder', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblOrderCommitted',text: 'Committed'}])
//        .verifyGridData('Search', 2, 'dblOrderCommitted', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblUnitReserved',text: 'Reserved'}])
//        .verifyGridData('Search', 2, 'dblUnitReserved', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblInTransitInbound',text: 'In Transit Inbound'}])
//        .verifyGridData('Search', 2, 'dblInTransitInbound', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblInTransitOutbound',text: 'In Transit Outbound'}])
//        .verifyGridData('Search', 2, 'dblInTransitOutbound', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblUnitStorage',text: 'On Storage'}])
//        .verifyGridData('Search', 2, 'dblUnitStorage', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblConsignedPurchase',text: 'Consigned Purchase'}])
//        .verifyGridData('Search', 2, 'dblConsignedPurchase', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblConsignedSale',text: 'Consigned Sale'}])
//        .verifyGridData('Search', 2, 'dblConsignedSale', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblAvailable',text: 'Available'}])
//        .verifyGridData('Search', 2, 'dblAvailable', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblReorderPoint',text: 'Reorder Point'}])
//        .verifyGridData('Search', 2, 'dblReorderPoint', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblLastCost',text: 'Last Cost'}])
//        .verifyGridData('Search', 2, 'dblLastCost', '10.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblAverageCost',text: 'Average Cost'}])
//        .verifyGridData('Search', 2, 'dblAverageCost', '0.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblStandardCost',text: 'Standard Cost'}])
//        .verifyGridData('Search', 2, 'dblStandardCost', '10.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblSalePrice',text: 'Retail Price'}])
//        .verifyGridData('Search', 2, 'dblSalePrice', '14.00')
//
//        .verifyGridColumnNames ('Search', [{ dataIndex: 'dblExtendedCost',text: 'Extended Cost'}])
//        .verifyGridData('Search', 2, 'dblExtendedCost', '0.00')
//        .displayText('=====  Verify Location: 0002 - Indianapolis DONE =====')
        .displayText('=====  Verify Stock Details DONE =====')
        .clickMenuFolder('Inventory','Folder')
        .waitTillLoaded('')


        //Verify Item - Stock tab
        .displayText('=====  Verify Item - Stock tab  =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen('Items','Screen')
        .doubleClickSearchRowValue('Item StockCheckIR-4', 1)
        .waitUntilLoaded('icitem',3000)
        .clickTab('Stock')

        .displayText('This counts the number of records in the Stock grid.')
        .verifyGridRecordCount('Stock', 1)
        .waitTillLoaded('',3000)

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'strLocationName',text: 'Location'}])
        .verifyGridData('Stock', 1, 'strLocationName', '0001 - Fort Wayne')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'strUnitMeasure',text: 'UOM'}])
        .verifyGridData('Stock', 1, 'strUnitMeasure', 'lb1')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblOnOrder',text: 'On Order'}])
        .verifyGridData('Stock', 1, 'dblOnOrder', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblInTransitInbound',text: 'In Transit Inbound'}])
        .verifyGridData('Stock', 1, 'dblInTransitInbound', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblUnitOnHand',text: 'On Hand'}])
        .verifyGridData('Stock', 1, 'dblUnitOnHand', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblInTransitOutbound',text: 'In Transit Outbound'}])
        .verifyGridData('Stock', 1, 'dblInTransitOutbound', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblCalculatedBackOrder',text: 'Back Order'}])
        .verifyGridData('Stock', 1, 'dblCalculatedBackOrder', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblOrderCommitted',text: 'Committed'}])
        .verifyGridData('Stock', 1, 'dblOrderCommitted', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblUnitStorage',text: 'On Storage'}])
        .verifyGridData('Stock', 1, 'dblUnitStorage', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblConsignedPurchase',text: 'Consigned Purchase'}])
        .verifyGridData('Stock', 1, 'dblConsignedPurchase', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblConsignedSale',text: 'Consigned Sales'}])
        .verifyGridData('Stock', 1, 'dblConsignedSale', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblUnitReserved',text: 'Reserved'}])
        .verifyGridData('Stock', 1, 'dblUnitReserved', '0.00')

        .verifyGridColumnNames ('Stock', [{ dataIndex: 'dblAvailable',text: 'Available'}])
        .verifyGridData('Stock', 1, 'dblAvailable', '0.00')

        .displayText('=====  Verify Item - Stock tab DONE =====')
        .clickButton('Close')
        .clickMenuFolder('Inventory','Folder')
        .waitUntilLoaded('')


        //Verify Item1 - Inventory Valuation
        .displayText('=====  Verify Inventory Valuation =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen ('Inventory Valuation','Screen')
        .waitUntilLoaded('icinventoryvaluation',3000)
        .waitUntilLoaded('icinventoryvaluation',3000)
        .waitUntilLoaded('icinventoryvaluation',3000)
        .waitUntilLoaded('icinventoryvaluation',3000)
        .addResult('Opened Inventory Valuation',3000)
        .selectSearchRowValue('Item StockCheckIR-4','strItemNo',1,0)
        .waitUntilLoaded('',3000)
        .displayText('This counts the number of records in the search grid.')
        .verifyGridRecordCount('Search', 2)
        .waitTillLoaded('',3000)

        .displayText('=====  Row 1 =====')
        .verifyGridColumnNames ('Search', [{dataIndex: 'strItemNo',text: 'Item No'}])
        .verifyGridData('Search', 1, 'strItemNo', 'Item StockCheckIR-4')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strItemDescription',text: 'Description'}])
        .verifyGridData('Search', 1, 'strItemDescription', 'Item StockCheckIR-4 desc')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strCategory',text: 'Category'}])
        .verifyGridData('Search', 1, 'strCategory', 'Item Category1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strStockUOM',text: 'Stock UOM'}])
        .verifyGridData('Search', 1, 'strStockUOM', 'lb1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strLocationName',text: 'Location'}])
        .verifyGridData('Search', 1, 'strLocationName', '0001 - Fort Wayne')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strBOLNumber',text: 'BOL Number'}])
        .verifyGridData('Search', 1, 'strBOLNumber', null)

        .verifyGridColumnNames ('Search', [{dataIndex: 'strEntity',text: 'Entity'}])
        .verifyGridData('Search', 1, 'strEntity', null)

        .verifyGridColumnNames ('Search', [{dataIndex: 'strLotNumber',text: 'Lot Number'}])
        .verifyGridData('Search', 1, 'strLotNumber', 'LOT-1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strAdjustedTransaction',text: 'Adjusted Transaction'}])
        .verifyGridData('Search', 1, 'strAdjustedTransaction', null)

        .verifyGridColumnNames ('Search', [{dataIndex: 'strCostingMethod',text: 'Costing Method'}])
        .verifyGridData('Search', 1, 'strCostingMethod', 'LOT COST')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dtmDate',text: 'Date'}])
        .addFunction (function (next){
        var date = new Date().toLocaleDateString();
        new iRely.FunctionalTest().start(t, next)
            .verifyGridData('Search', 1, 'dtmDate', date)
            .done();})
        .verifyGridColumnNames ('Search', [{dataIndex: 'strTransactionType',text: 'Transaction Type'}])
        .verifyGridData('Search', 1, 'strTransactionType', 'Inventory Receipt')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strTransactionId',text: 'Transaction Id'}])
        .verifyGridData('Search', 1, 'strTransactionId', 'IR-', 'like')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblBeginningQtyBalance',text: 'Begin Qty'}])
        .verifyGridData('Search', 1, 'dblBeginningQtyBalance', '0.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblQuantityInStockUOM',text: 'Qty'}])
        .verifyGridData('Search', 1, 'dblQuantityInStockUOM', '100.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblRunningQtyBalance',text: 'Running Qty'}])
        .verifyGridData('Search', 1, 'dblRunningQtyBalance', '100.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblCostInStockUOM',text: 'Cost'}])
        .verifyGridData('Search', 1, 'dblCostInStockUOM', '10.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblBeginningBalance',text: 'Begin Value'}])
        .verifyGridData('Search', 1, 'dblBeginningBalance', '0.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblValue',text: 'Value'}])
        .verifyGridData('Search', 1, 'dblValue', '1000.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblRunningBalance',text: 'Running Value'}])
        .verifyGridData('Search', 1, 'dblRunningBalance', '1000.00')

        .displayText('=====  Row 2 =====')
        .verifyGridColumnNames ('Search', [{dataIndex: 'strItemNo',text: 'Item No'}])
        .verifyGridData('Search', 2, 'strItemNo', 'Item StockCheckIR-4')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strItemDescription',text: 'Description'}])
        .verifyGridData('Search', 2, 'strItemDescription', 'Item StockCheckIR-4 desc')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strCategory',text: 'Category'}])
        .verifyGridData('Search', 2, 'strCategory', 'Item Category1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strStockUOM',text: 'Stock UOM'}])
        .verifyGridData('Search', 2, 'strStockUOM', 'lb1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strLocationName',text: 'Location'}])
        .verifyGridData('Search', 2, 'strLocationName', '0001 - Fort Wayne')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strBOLNumber',text: 'BOL Number'}])
        .verifyGridData('Search', 2, 'strBOLNumber', null)

        .verifyGridColumnNames ('Search', [{dataIndex: 'strEntity',text: 'Entity'}])
        .verifyGridData('Search', 2, 'strEntity', null)

        .verifyGridColumnNames ('Search', [{dataIndex: 'strLotNumber',text: 'Lot Number'}])
        .verifyGridData('Search', 2, 'strLotNumber', 'LOT-1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strAdjustedTransaction',text: 'Adjusted Transaction'}])
        .verifyGridData('Search', 2, 'strAdjustedTransaction', null)

        .verifyGridColumnNames ('Search', [{dataIndex: 'strCostingMethod',text: 'Costing Method'}])
        .verifyGridData('Search', 2, 'strCostingMethod', 'LOT COST')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dtmDate',text: 'Date'}])
        .addFunction (function (next){
        var date = new Date().toLocaleDateString();
        new iRely.FunctionalTest().start(t, next)
            .verifyGridData('Search', 2, 'dtmDate', date)
            .done();})

        .verifyGridColumnNames ('Search', [{dataIndex: 'strTransactionType',text: 'Transaction Type'}])
        .verifyGridData('Search', 2, 'strTransactionType', 'Inventory Receipt')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strTransactionId',text: 'Transaction Id'}])
        .verifyGridData('Search', 2, 'strTransactionId', 'IR-', 'like')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblBeginningQtyBalance',text: 'Begin Qty'}])
        .verifyGridData('Search', 2, 'dblBeginningQtyBalance', '100.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblQuantityInStockUOM',text: 'Qty'}])
        .verifyGridData('Search', 2, 'dblQuantityInStockUOM', '-100.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblRunningQtyBalance',text: 'Running Qty'}])
        .verifyGridData('Search', 2, 'dblRunningQtyBalance', '0.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblCostInStockUOM',text: 'Cost'}])
        .verifyGridData('Search', 2, 'dblCostInStockUOM', '10.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblBeginningBalance',text: 'Begin Value'}])
        .verifyGridData('Search', 2, 'dblBeginningBalance', '1000.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblValue',text: 'Value'}])
        .verifyGridData('Search', 2, 'dblValue', '-1000.00')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblRunningBalance',text: 'Running Value'}])
        .verifyGridData('Search', 2, 'dblRunningBalance', '0.00')

        .displayText('=====  Verify Inventory Valuation DONE  =====')
        .clickMenuFolder('Inventory','Folder')

        //Verify Item1 - Inventory Valuation Summary
        .displayText('=====  Verify Inventory Valuation Summary =====')
        .clickMenuFolder('Inventory','Folder')
        .clickMenuScreen ('Inventory Valuation Summary','Screen')
        .waitUntilLoaded('icinventoryvaluationsummary',3000)
        .waitUntilLoaded('icinventoryvaluationsummary',3000)
        .waitUntilLoaded('icinventoryvaluationsummary',3000)
        .waitUntilLoaded('icinventoryvaluationsummary',3000)
        .addResult('Opened Inventory Valuation',3000)
        .selectSearchRowValue('Item StockCheckIR-4','strItemNo',1,0)
        .waitUntilLoaded('',3000)
        .displayText('This counts the number of records in the search grid.')
        .verifyGridRecordCount('Search', 1)
        .waitTillLoaded('',3000)

        .verifyGridColumnNames ('Search', [{dataIndex: 'strItemNo',text: 'Item No'}])
        .verifyGridData('Search', 1, 'strItemNo', 'Item StockCheckIR-4')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strItemDescription',text: 'Description'}])
        .verifyGridData('Search', 1, 'strItemDescription', 'Item StockCheckIR-4 desc')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strLocationName',text: 'Location'}])
        .verifyGridData('Search', 1, 'strLocationName', '0001 - Fort Wayne')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strSubLocationName',text: 'Sub Location'}])
        .verifyGridData('Search', 1, 'strSubLocationName', 'Raw Station')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strCategoryCode',text: 'Category'}])
        .verifyGridData('Search', 1, 'strCategoryCode', 'Item Category1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strCommodityCode',text: 'Commodity'}])
        .verifyGridData('Search', 1, 'strCommodityCode', 'Commodity1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'strStockUOM',text: 'Stock UOM'}])
        .verifyGridData('Search', 1, 'strStockUOM', 'lb1')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblQuantityInStockUOM',text: 'Stock Quantity'}])
        .verifyGridData('Search', 1, 'dblQuantityInStockUOM', '0')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblValue',text: 'Value'}])
        .verifyGridData('Search', 1, 'dblValue', '0')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblLastCost',text: 'Last Cost'}])
        .verifyGridData('Search', 1, 'dblLastCost', '0')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblStandardCost',text: 'Standard Cost'}])
        .verifyGridData('Search', 1, 'dblStandardCost', '0')

        .verifyGridColumnNames ('Search', [{dataIndex: 'dblAverageCost',text: 'Average Cost'}])
        .verifyGridData('Search', 1, 'dblAverageCost', '0')

        .displayText('=====  Verify Inventory Valuation Summary DONE  =====')
        .clickMenuFolder('Inventory','Folder')



        .done()
});
