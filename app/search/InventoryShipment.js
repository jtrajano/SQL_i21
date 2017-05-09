Ext.define('Inventory.search.InventoryShipment', {
    alias: 'search.icinventoryshipment',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Inventory Shipment',
            type: 'Inventory.InventoryShipment',
            api: {
                read: '../Inventory/api/InventoryShipment/Search'
            },
            columns: [
                { dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewShipmentNo' },
                { dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int' },
                { dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int' },
                { dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerNo' },
                { dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerName' },
                { dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string' },
                { dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },

                { dataIndex: 'strReferenceNumber', text: 'Reference Number', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'dtmRequestedArrivalDate', text: 'Requested Arrival Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'strShipFromLocation', text: 'ShipFrom', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strShipToLocation', text: 'Ship To', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strFreightTerm', text: 'Freight Term', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strFobPoint', text: 'FOB Point', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strBOLNumber', text: 'BOL Number', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strShipVia', text: 'Ship Via', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strVessel', text: 'Vessel', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strProNumber', text: 'PRO Number', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strDriverId', text: 'Driver Id', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strSealNumber', text: 'Seal Number', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strDeliveryInstruction', text: 'Delivery Instruction', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'dtmAppointmentTime', text: 'Appointment Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'dtmDepartureTime', text: 'Departure Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'dtmArrivalTime', text: 'Arrival Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'dtmDeliveredDate', text: 'Delivered Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'dtmFreeTime', text: 'Free Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'strReceivedBy', text: 'Received By', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strComment', text: 'Comment', flex: 1, dataType: 'string', hidden: true }
            ]
        },
        {
            title: 'Details',
            api: {
                read: '../Inventory/api/InventoryShipment/SearchShipmentItems'
            },
            columns: [
                { dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Shipment', drillDownClick: 'onViewShipmentNo' },
                { dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int' },
                { dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int' },
                { dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Customer', drillDownClick: 'onViewCustomerNo', hidden: true },
                { dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Customer', drillDownClick: 'onViewCustomerName', hidden: true },
                { dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string' },
                { dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },

                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo' },
                { dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string' },

                { dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string' },
                { dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string' },
                { dataIndex: 'strUnitMeasure', text: 'Ship UOM', flex: 1, dataType: 'string' },

                { xtype: 'numbercolumn', dataIndex: 'dblQtyToShip', text: 'Quantity', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblPrice', text: 'Unit Price', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblLineTotal', text: 'Line Total', flex: 1, dataType: 'float' }
            ]
        },
        {
            title: 'Lots',
            api: {
                read: '../Inventory/api/InventoryShipment/SearchShipmentItemLots'
            },
            columns: [
                { dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewShipmentNo' },
                { dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int' },
                { dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int' },
                { dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerNo', hidden: true },
                { dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerName', hidden: true },
                { dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string' },
                { dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },

                { dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo' },
                { dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string' },
                { dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strUnitMeasure', text: 'Ship UOM', flex: 1, dataType: 'string', hidden: true },

                { dataIndex: 'strLotNumber', text: 'Lot Number', flex: 1, dataType: 'string' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Unit', flex: 1, dataType: 'string' },
                { dataIndex: 'strLotUOM', text: 'Lot UOM', flex: 1, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblLotQty', text: 'Lot Qty', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblGrossWeight', text: 'Gross Wgt', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblTareWeight', text: 'Tare Wgt', flex: 1, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblNetWeight', text: 'Net Wgt', flex: 1, dataType: 'float' }
            ]
        },
        {
            title: 'Invoices',
            api: {
                read: '../Inventory/api/InventoryShipment/SearchShipmentInvoice'
            },
            columns: [
                { dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, dataType: 'numeric', key: true, hidden: true},
                { dataIndex: 'intInventoryShipmentItemId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true},
                { dataIndex: 'intInventoryShipmentChargeId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true},
                { dataIndex: 'strAllVouchers', text: 'Invoice Nos.', width: 100, dataType: 'string', drillDownText: 'View Invoice', drillDownClick: 'onViewInvoice' },
                { dataIndex: 'strShipmentNumber', text: 'Shipment No.', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'string'},
                { dataIndex: 'dtmShipDate', text: 'Ship Date', width: 100, dataType: 'date', xtype: 'datecolumn'},
                { dataIndex: 'strCustomer', text: 'Customer', width: 300, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Ship From', width: 200, dataType: 'string' },
                { dataIndex: 'strDestination', text: 'Ship To', width: 200, dataType: 'string' },
                { dataIndex: 'strBOLNumber', text: 'Bill of Lading', width: 100, dataType: 'string' },
                { dataIndex: 'strOrderType', text: 'Order Type', width: 120, dataType: 'string' },
                { dataIndex: 'strItemNo', text: 'Item No.', width: 100, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblUnitCost', text: 'Cost', width: 100, dataType: 'float', xtype: 'numbercolumn'},
                { xtype: 'numbercolumn', dataIndex: 'dblShipmentQty', text: 'Shipped Qty', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                { xtype: 'numbercolumn', dataIndex: 'dblInTransitQty', text: 'In-Transit Qty', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                { xtype: 'numbercolumn', dataIndex: 'dblInvoiceQty', text: 'Invoiced Qty', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                { xtype: 'numbercolumn', dataIndex: 'dblShipmentLineTotal', text: 'Shipment Line Total', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},                        
                { xtype: 'numbercolumn', dataIndex: 'dblInvoiceLineTotal', text: 'Invoice Line Total', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                { xtype: 'numbercolumn', dataIndex: 'dblOpenQty', text: 'Uncleared Qty', width: 150, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                { xtype: 'numbercolumn', dataIndex: 'dblInTransitTotal', text: 'Uncleared Items Total', width: 150, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                { dataIndex: 'dtmLastInvoiceDate', text: 'Last Invoice Date', width: 120, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strFilterString', text: 'Voucher Nos.', flex: 1, dataType: 'string', required: true, hidden: true }               
                
            ],
            buttons: [
                {
                    text: 'Refresh Invoices',
                    itemId: 'btnRefreshInvoices',
                    clickHandler: 'onRefreshInvoicesClick',
                    width: 400
                }                        
            ]                                        
        }
    ],

    buttons: [
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
            text: 'Storage Units',
            itemId: 'btnStorageLocation',
            clickHandler: 'onStorageLocationClick',
            width: 110
        },
        {
            text: 'Customer',
            itemId: 'btnCustomer',
            clickHandler: 'onViewCustomerClick',
            width: 80

        }
    ],

    /*Support functions*/
    processShipmentToInvoice: function (shipmentId, callback) {
        ic.utils.ajax({
            url: '../Inventory/api/InventoryShipment/ProcessInvoice',
            params:{
                id: shipmentId
            },
            method: 'post'  
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

    /*Button Event Handlers*/
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

    onViewCustomerClick: function () {
        iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityCustomer', { action: 'view' });
    },
    
    onRefreshInvoicesClick: function (control) {
        ic.utils.ajax({
            url: '../Inventory/api/InventoryShipment/UpdateShipmentInvoice',
            method: 'post'  
        })
        .subscribe(
            function(successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                var panel = control.up('panel');
                var grdSearch = panel ? panel.query('#grdSearch') : null;

                if (grdSearch && grdSearch.length > 0){
                    grdSearch.forEach(function (grid) {
                        if (grid && grid.url == '../Inventory/api/InventoryShipment/SearchShipmentInvoice'){
                            var store = grid ? grid.getStore() : null;
                            if (store){
                                store.reload({
                                    callback: function(){
                                        grid.getView().refresh();
                                    }
                                });                    
                            }
                        }
                    }); 
                }                
            }
            , function(failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                iRely.Functions.showErrorDialog(jsonData.message.statusText);
            }
        );        
    },

    /* Drilldown Handlers */
    onViewShipmentNo: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'ShipmentNo');
    },

    onViewInvoice: function (value, record, dashboard) {
        var me = this;

        if (value === 'New Invoice') {
            if(record.get('strOrderType') === 'Transfer Order') {
                iRely.Functions.showErrorDialog('Invalid order type. An invoice is not applicable on transfer orders.');
                return;
            }

            me.processShipmentToInvoice(record.get('intInventoryShipmentId'), function(data) {
                iRely.Functions.openScreen('AccountsReceivable.view.Invoice', {
                    filters: [
                        {
                            column: 'intInvoiceId',
                            value: data.message.InvoiceId
                        }
                    ],
                    action: 'view',
                    listeners: {
                        close: function(e) {
                            dashboard.$initParent.grid.controller.reload();  
                        }
                    }
                });        
            });                        
        }
        else {
            var invoices = record.get('strFilterString');
            iRely.Functions.openScreen('AccountsReceivable.view.Invoice', {
                filters: [
                    {
                        column: 'intInvoiceId',
                        value: invoices
                    }
                ],
                action: 'view'
            });        
        }
    },

    onViewCustomerNo: function (value, record) {
        var strName = record.get('strCustomerName');
        i21.ModuleMgr.Inventory.showScreen(strName, 'CustomerName');
    },

    onViewCustomerName: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'CustomerName');
    },

    onViewItemNo: function(value, record) {
        var itemNo = record.get('strItemNo');
        i21.ModuleMgr.Inventory.showScreen(itemNo, 'ItemNo');
    }    
});