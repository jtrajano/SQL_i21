Ext.define('Inventory.search.InventoryReceipt', {
    alias: 'search.icinventoryreceipt',
    singleton: true,
    searchConfigs: [
        {
            title: 'Search Inventory Receipt',
            type: 'Inventory.InventoryReceipt',
            api: {
                read: '../Inventory/api/InventoryReceipt/Search'
            },
            columns: [
                { dataIndex: 'intInventoryReceiptId', text: "Receipt Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo' },
                { dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strVendorName', text: 'Vendor Name', flex: 1, dataType: 'string', drillDownText: 'View Vendor', drillDownClick: 'onViewVendorName' },
                { dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocationName' },
                { dataIndex: 'strBillOfLading', text: 'Bill Of Lading No', flex: 1, dataType: 'string' },
                { dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string' },
                { dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },

                { dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strVendorId', text: 'Vendor Id', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strTransferor', text: 'Transferor', flex: 1, dataType: 'string', hidden: true },

                { dataIndex: 'intBlanketRelease', text: 'Blanket Release', flex: 1, dataType: 'int', hidden: true },
                { dataIndex: 'strVendorRefNo', text: 'Vendor Reference No', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strWarehouseRefNo', text: 'Warehouse Reference No', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strShipVia', text: 'Ship Via', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strShipFrom', text: 'Ship From', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strReceiver', text: 'Receiver', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strVessel', text: 'Vessel', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strFreightTerm', text: 'Freight Term', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strFobPoint', text: 'Fob Point', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'intShiftNumber', text: 'Shift Number', flex: 1, dataType: 'int', hidden: true },
                { dataIndex: 'dblInvoiceAmount', text: 'Invoice Amount', flex: 1, dataType: 'float', hidden: true },
                { dataIndex: 'ysnPrepaid', text: 'Prepaid', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'ysnInvoicePaid', text: 'Invoice Paid', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'intCheckNo', text: 'Check No', flex: 1, dataType: 'int', hidden: true },
                { dataIndex: 'dtmCheckDate', text: 'Check Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'intTrailerTypeId', text: 'Trailer Type Id', flex: 1, dataType: 'int', hidden: true },
                { dataIndex: 'dtmTrailerArrivalDate', text: 'Trailer Arrival Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'dtmTrailerArrivalTime', text: 'Trailer Arrival Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'strSealNo', text: 'Seal No', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strSealStatus', text: 'Seal Status', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'dtmReceiveTime', text: 'Receive Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'dblActualTempReading', text: 'Actual Temp Reading', flex: 1, dataType: 'float', hidden: true },
                { dataIndex: 'strEntityName', text: 'Entity Name', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strActualCostId', text: 'Actual Cost Id', flex: 1, dataType: 'string', hidden: true },

                { xtype: 'numbercolumn', dataIndex: 'dblSubTotal', text: 'Sub Total', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblTotalTax', text: 'Tax', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblTotalCharges', text: 'Charges', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblTotalGross', text: 'Gross', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblTotalNet', text: 'Net', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblGrandTotal', text: 'Total', flex: 1, dataType: 'float' },
            ]
        },
        {
            title: 'Details',
            api: {
                read: '../Inventory/api/InventoryReceipt/SearchReceiptItems'
            },
            columns: [
                { dataIndex: 'intInventoryReceiptId', text: "Receipt Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo' },
                { dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo' },
                { dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string' },
                { dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string', drillDownText: 'View Order', drillDownClick: 'onViewOrder' },
                { dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string', drillDownText: 'View Source', drillDownClick: 'onViewSource' },
                { dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string' },
                { dataIndex: 'strUnitMeasure', text: 'Receipt UOM', flex: 1, dataType: 'string' },

                { xtype: 'numbercolumn', dataIndex: 'dblQtyToReceive', text: 'Qty to Receive', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', format: '0,000.000##', dataIndex: 'dblUnitCost', text: 'Cost', flex: 1, dataType: 'float', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.000##' },
                { xtype: 'numbercolumn', dataIndex: 'dblTax', text: 'Tax', flex: 1, dataType: 'float', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00' },
                { xtype: 'numbercolumn', dataIndex: 'dblLineTotal', text: 'Line Total', flex: 1, dataType: 'float', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00' },

                { dataIndex: 'strCostUOM', text: 'Cost UOM', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'strVendorName', text: 'Vendor Name', flex: 1, dataType: 'string', drillDownText: 'View Vendor', drillDownClick: 'onViewVendorName', hidden: true },
                { dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocationName', hidden: true },
                { dataIndex: 'strBillOfLading', text: 'Bill Of Lading No', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: false },
                { dataIndex: 'strVendorRefNo', text: 'Vendor Reference No.', flex: 1, dataType: 'string', hidden: false },
                { dataIndex: 'strShipFrom', text: 'Ship From', flex: 1, dataType: 'string', hidden: false },
                { dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'string', hidden: false },
                { dataIndex: 'ysnExported', text: 'Exported', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'dtmExportedDate', text: 'Exported Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true }
            ]
        },
        {
            title: 'Charges',
            api: {
                read: '../Inventory/api/InventoryReceipt/SearchReceiptCharges'
            },
            columns: [
                { dataIndex: 'intInventoryReceiptId', text: "Receipt Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo' },
                { dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strReceiptVendor', text: 'Receipt Vendor', flex: 1, dataType: 'string' },
                { dataIndex: 'strBillOfLading', text: 'BOL No.', flex: 1, dataType: 'string' },
                { dataIndex: 'strContractNumber', text: 'Contract No.', flex: 1, dataType: 'string' },
                { dataIndex: 'strItemNo', text: 'Other Charges', flex: 1, dataType: 'string' },
                { dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string' },
                { dataIndex: 'strOnCostType', text: 'On Cost', flex: 1, dataType: 'string' },
                { dataIndex: 'strCostMethod', text: 'Cost Method', flex: 1, dataType: 'string' },
                { dataIndex: 'strCurrency', text: 'Cost Currency', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblRate', text: 'Rate', flex: 1, dataType: 'float' },
                { dataIndex: 'strCostUOM', text: 'UOM', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblAmount', text: 'Amount', flex: 1, dataType: 'float' },
                { dataIndex: 'ysnAccrue', text: 'Accrue', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'strVendorName', text: 'Other Charge Vendor', flex: 1, dataType: 'string' },
                { dataIndex: 'ysnInventoryCost', text: 'Inventory Cost', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'strAllocateCostBy', text: 'Allocate Cost By', flex: 1, dataType: 'string' },
                { dataIndex: 'ysnPrice', text: 'Price Down', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'strTaxGroup', text: 'Tax Group', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblTax', text: 'Tax', flex: 1, dataType: 'float' }
            ]
        },
        {
            title: 'Lots',
            api: {
                read: '../Inventory/api/InventoryReceipt/SearchReceiptItemLots'
            },
            columns: [
                { dataIndex: 'intInventoryReceiptId', text: "Receipt Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo' },
                { dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo' },
                { dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string' },

                { dataIndex: 'strLotNumber', text: 'Lot Number', flex: 1, dataType: 'string' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Unit', flex: 1, dataType: 'string' },
                { dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string' },
                { dataIndex: 'strUnitMeasure', text: 'Lot UOM', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblQuantity', text: 'Lot Qty', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblGrossWeight', text: 'Gross Wgt', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblTareWeight', text: 'Tare Wgt', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblNetWeight', text: 'Net Wgt', flex: 1, dataType: 'float' },
                { dataIndex: 'dtmExpiryDate', text: 'Expiry Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },

                { dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strItemUOM', text: 'Receipt UOM', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocationName', hidden: true },
                { dataIndex: 'strBillOfLading', text: 'Bill Of Lading No', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true }
            ]
        },
        {
            title: 'Vouchers',
            api: {
                read: '../Inventory/api/InventoryReceipt/SearchReceiptVouchers'
            },
            columns: [
                { dataIndex: 'intInventoryReceiptId', text: 'Inventory Receipt Id', flex: 1, dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'intInventoryReceiptItemId', text: 'Inventory Receipt Item Id', flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'strAllVouchers', text: 'Voucher Nos.', width: 100, dataType: 'string', drillDownText: 'View Voucher', drillDownClick: 'onViewVoucher' },
                { dataIndex: 'dtmReceiptDate', text: 'Receipt Date', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strVendor', text: 'Vendor', width: 300, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Destination', width: 200, dataType: 'string' },
                { dataIndex: 'strReceiptNumber', text: 'Receipt No', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'string' },
                { dataIndex: 'strBillOfLading', text: 'BOL', width: 100, dataType: 'string' },
                { dataIndex: 'strReceiptType', text: 'Order Type', width: 120, dataType: 'string' },
                { dataIndex: 'strOrderNumber', text: 'Order No', width: 100, dataType: 'string' },
                { dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string' },
                { dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string' },                
                { dataIndex: 'dblUnitCost', text: 'Unit Cost', width: 120, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'strCostUOM', text: 'Cost UOM', width: 80, dataType: 'string' },
                { dataIndex: 'dblReceiptQty', text: 'Receipt Qty', width: 120, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblVoucherQty', text: 'Voucher Qty', width: 120, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'strItemUOM', text: 'UOM', width: 80, dataType: 'string' },
                { dataIndex: 'dblReceiptLineTotal', text: 'Receipt Line Total', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00' },
                { dataIndex: 'dblVoucherLineTotal', text: 'Voucher Line Total', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00' },
                { dataIndex: 'dblReceiptTax', text: 'Receipt Tax', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00' },
                { dataIndex: 'dblVoucherTax', text: 'Voucher Tax', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00' },
                { dataIndex: 'dblOpenQty', text: 'Uncleared Qty', width: 120, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblItemsPayable', text: 'Uncleared Items Total', width: 150, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00' },
                { dataIndex: 'dblTaxesPayable', text: 'Uncleared Taxes Total', width: 150, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00' },
                { dataIndex: 'dtmLastVoucherDate', text: 'Last Voucher Date', width: 120, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strFilterString', text: 'Voucher Nos.', flex: 1, dataType: 'string', required: true, hidden: true }
            ]
        }
    ],
    buttons: [
        {
            text: 'Refresh Vouchers',
            itemId: 'btnRefreshVoucher',
            clickHandler: 'onRefreshVoucherClick',
            width: 400
        },
        {
            text: 'Items',
            itemId: 'btnItem',
            clickHandler: 'onItemClick',
            width: 80
        },
        {
            text: 'Categories',
            itemId: 'btnCategory',
            clickHandler: 'onCategoryClick',
            width: 100
        },
        {
            text: 'Commodities',
            itemId: 'btnCommodity',
            clickHandler: 'onCommodityClick',
            width: 100
        },
        {
            text: 'Locations',
            itemId: 'btnLocation',
            clickHandler: 'onLocationClick',
            width: 100
        },
        {
            text: 'Storage Locations',
            itemId: 'btnStorageLocation',
            clickHandler: 'onStorageLocationClick',
            width: 110
        },
        {
            text: 'Vendor',
            itemId: 'btnVendor',
            clickHandler: 'onBtnVendorClick',
            width: 80
        }
    ],

    processReceiptToVoucher: function (receiptId, callback) {
        ic.utils.ajax({
            url: '../Inventory/api/InventoryReceipt/ProcessBill',
            params:{
                id: receiptId
            },
            method: 'get'  
        })
        .subscribe(
            function(successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                callback(jsonData);
            }
            ,function(failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                var message = jsonData.message; 
                iRely.Functions.showErrorDialog(message.statusText);
            }
        );          
    },    

    onRefreshVoucherClick: function (control) {
        ic.utils.ajax({
            url: '../Inventory/api/InventoryReceipt/UpdateReceiptVoucher',
            method: 'post'
        })
            .subscribe(
            function (successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                var panel = control.up('panel');
                var grdSearch = panel ? panel.query('#grdSearch') : null;

                if (grdSearch && grdSearch.length > 0) {
                    grdSearch.forEach(function (grid) {
                        if (grid && grid.url == '../Inventory/api/InventoryReceipt/SearchReceiptVouchers') {
                            var store = grid ? grid.getStore() : null;
                            if (store) {
                                store.reload({
                                    callback: function () {
                                        grid.getView().refresh();
                                    }
                                });
                            }
                        }
                    });
                }
            }
            , function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                iRely.Functions.showErrorDialog(jsonData.message.statusText);
            }
            );
    },

    onItemClick: function () {
        iRely.Functions.openScreen('Inventory.view.Item', { action: 'new', viewConfig: { modal: true } });
    },

    onCategoryClick: function () {
        iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true } });
    },

    onCommodityClick: function () {
        iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true } });
    },

    onLocationClick: function () {
        iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true } });
    },

    onStorageLocationClick: function () {
        iRely.Functions.openScreen('Inventory.view.StorageUnit', { action: 'new', viewConfig: { modal: true } });
    },

    onBtnVendorClick: function () {
        iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new', viewConfig: { modal: true } });
    },

    /* Drill down handlers */
    onViewReceiptNo: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'ReceiptNo');
    },

    onViewVendorName: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'VendorName');
    },

    onViewLocationName: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'LocationName');
    },

    onViewItemNo: function (value, record) {
        var itemId = record.get('intItemId');
        i21.ModuleMgr.Inventory.showScreen(itemId, 'ItemId');
    },

    onViewOrder: function (value, record) {
        var orderType = record.get('strReceiptType');

        if (orderType === 'Purchase Contract') {
            iRely.Functions.openScreen('ContractManagement.view.Contract', {
                filters: [{
                    column: 'intContractTypeId',
                    value: 1,
                    conjunction: 'and'
                },
                {
                    column: 'strContractNumber',
                    value: value,
                    conjunction: 'and'
                }]
            });
        }

        else if (orderType === 'Purchase Order') {
            i21.ModuleMgr.Inventory.showScreen(value, 'PONumber');
        }

        else if (orderType === 'Transfer Order') {
            i21.ModuleMgr.Inventory.showScreen(value, 'TransferNo');
        }
    },

    onViewSource: function (value, record) {
        var sourceType = record.get('strSourceType');

        if (sourceType === 'Scale') {
            var scaleStore = Ext.create('Grain.store.ScaleTicket'),
                filter = [{
                    column: 'strTicketNumber',
                    value: value,
                    condition: 'eq',
                    conjunction: 'or'
                }];

            scaleStore.setRemoteFilter(true);
            scaleStore.clearFilter();
            scaleStore.addFilter(filter, false);
            scaleStore.load({
                callback: function (records, operation, success) {
                    iRely.Functions.openScreen('Grain.view.ScaleStationSelection', {
                        action: 'edit', filters: filter, data: records
                    });
                }
            });
        }

        else if (sourceType === 'Inbound Shipment') {
            iRely.Functions.openScreen('Logistics.view.ShipmentSchedule', {
                filters: [{
                    column: 'strLoadNumber',
                    value: value,
                    conjunction: 'and'
                }]
            });
        }

        else if (sourceType === 'Transport') {
            iRely.Functions.openScreen('Transports.view.TransportLoads', {
                filters: [{
                    column: 'strTransaction',
                    value: value,
                    conjunction: 'and'
                }]
            });
        }
    },

    onViewVoucher: function (value, record, dashboard) {
        var me = this;

        if (value === 'New Voucher') {
            if (record.get('strReceiptType') === 'Transfer Order') {
                iRely.Functions.showErrorDialog('Invalid receipt type. A voucher is not applicable to transfer orders.');
                return;
            }

            Ext.Ajax.request({
                timeout: 120000,
                url: '../Inventory/api/InventoryReceipt/GetStatusUnitCost?id=' + record.get('intInventoryReceiptId'),
                method: 'get',
                success: function (response) {
                    var jsonData = Ext.decode(response.responseText);
                    if (jsonData.success)
                        var receiptStatusId = jsonData.message.receiptItemsStatusId;

                    var createNewVoucher = function () {
                        me.processReceiptToVoucher(record.get('intInventoryReceiptId'), function (data) {
                            iRely.Functions.openScreen('AccountsPayable.view.Voucher', {
                                filters: [
                                    {
                                        column: 'intBillId',
                                        value: data.message.BillId
                                    }
                                ],
                                action: 'view',
                                showAddReceipt: false,
                                listeners: {
                                    close: function (e) {
                                        dashboard.$initParent.grid.controller.reload();
                                    }
                                }
                            });
                        });
                    }

                    //All items have zero cost
                    if (receiptStatusId == 1) {
                        iRely.Functions.showCustomDialog('information', 'ok', 'Cannot process voucher for items with zero cost.');
                    }

                    //Some items have zero cost
                    else if (receiptStatusId == 2) {
                        var buttonAction = function (button) {
                            if (button == 'yes') {
                                // Create Voucher for receipt containing items with cost and ignore items with zero cost
                                createNewVoucher();
                            }
                        }

                        iRely.Functions.showCustomDialog('question', 'yesno', 'Items with zero cost will not be processed to voucher. Continue?', buttonAction);
                    }

                    //No items have zero cost
                    else if (receiptStatusId == 3) {
                        // Create voucher for receipt containing cost for all items
                        createNewVoucher();
                    }

                },
                failure: function (response) {
                    var jsonData = Ext.decode(response.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                }
            });
        }
        else {
            var vouchers = record.get('strFilterString');
            iRely.Functions.openScreen('AccountsPayable.view.Voucher', {
                filters: [
                    {
                        column: 'intBillId',
                        value: vouchers
                    }
                ],
                action: 'view',
                showAddReceipt: false
            });
        }
    }
});