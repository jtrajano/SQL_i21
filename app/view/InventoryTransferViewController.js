Ext.define('Inventory.view.InventoryTransferViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventorytransfer',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        searchConfig: {
            title: 'Search Inventory Transfer',
            type: 'Inventory.InventoryTransfer',
            api: {
                read: '../Inventory/api/InventoryTransfer/Search'
            },
            columns: [

                {dataIndex: 'intInventoryTransferId', text: 'Inventory Transfer Id', flex: 1, dataType: 'numeric', defaultSort: true, sortOrder: 'DESC', key: true, hidden: true },
                {dataIndex: 'strTransferNo', text: 'Transfer No', flex: 1, dataType: 'string', drillDownText: 'View Transfer', drillDownClick: 'onViewTransfer' },
                {dataIndex: 'dtmTransferDate', text: 'Transfer Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                {dataIndex: 'strTransferType', text: 'Transfer Type', flex: 1, dataType: 'string' },
                {dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strTransferredBy', text: 'Transferred By', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string' },
                {dataIndex: 'strFromLocation', text: 'From Location', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation'  },
                {dataIndex: 'strToLocation', text: 'To Location', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation'  },
                {dataIndex: 'ysnShipmentRequired', text: 'Shipment Required', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                {dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string' },
                {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                {dataIndex: 'strName', text: 'User', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'intSort', text: 'Sort', flex: 1, dataType: 'numeric', hidden: true }
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
                    text: 'Storage Locations',
                    itemId: 'btnStorageLocation',
                    clickHandler: 'onStorageLocationClick',
                    width: 110
                }
            ],
            searchConfig: [
                {
                    title: 'Details',
                    api: {
                        read: '../Inventory/api/InventoryTransfer/SearchTransferDetails'
                    },
                    columns: [
                        {dataIndex: 'intInventoryTransferId', text: 'InventoryTransferId', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                        {dataIndex: 'intInventoryTransferDetailId', text: 'InventoryTransferDetailId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'intFromLocationId', text: 'FromLocationId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'intToLocationId', text: 'ToLocationId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strTransferNo', text: 'TransferNo', width: 100, dataType: 'string', drillDownText: 'View Transfer', drillDownClick: 'onViewTransfer' },
                        {dataIndex: 'intSourceId', text: 'SourceId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strSourceNumber', text: 'SourceNumber', width: 100, dataType: 'string' },
                        {dataIndex: 'intItemId', text: 'ItemId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strItemNo', text: 'ItemNo', width: 100, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                        {dataIndex: 'strItemDescription', text: 'ItemDescription', width: 100, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                        {dataIndex: 'strLotTracking', text: 'LotTracking', width: 100, dataType: 'string' },
                        {dataIndex: 'intCommodityId', text: 'CommodityId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strLotNumber', text: 'LotNumber', width: 100, dataType: 'string' },
                        {dataIndex: 'intLifeTime', text: 'LifeTime', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strLifeTimeType', text: 'LifeTimeType', width: 100, dataType: 'string' },
                        {dataIndex: 'intFromSubLocationId', text: 'FromSubLocationId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strFromSubLocationName', text: 'FromSubLocationName', width: 100, dataType: 'string' },
                        {dataIndex: 'intToSubLocationId', text: 'ToSubLocationId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strToSubLocationName', text: 'ToSubLocationName', width: 100, dataType: 'string' },
                        {dataIndex: 'intFromStorageLocationId', text: 'FromStorageLocationId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strFromStorageLocationName', text: 'FromStorageLocationName', width: 100, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                        {dataIndex: 'intToStorageLocationId', text: 'ToStorageLocationId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strToStorageLocationName', text: 'ToStorageLocationName', width: 100, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                        {dataIndex: 'intItemUOMId', text: 'ItemUOMId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strUnitMeasure', text: 'UnitMeasure', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                        {dataIndex: 'dblItemUOMCF', text: 'ItemUOMCF', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'intWeightUOMId', text: 'WeightUOMId', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strWeightUOM', text: 'WeightUOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                        {dataIndex: 'dblWeightUOMCF', text: 'WeightUOMCF', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'strAvailableUOM', text: 'AvailableUOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                        {dataIndex: 'dblLastCost', text: 'LastCost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblOnHand', text: 'OnHand', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblOnOrder', text: 'OnOrder', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblReservedQty', text: 'ReservedQty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblAvailableQty', text: 'AvailableQty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblQuantity', text: 'Quantity', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'intOwnershipType', text: 'OwnershipType', width: 100, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strOwnershipType', text: 'OwnershipType', width: 100, dataType: 'string' },
                        {dataIndex: 'ysnPosted', text: 'Posted', width: 100, dataType: 'boolean', xtype: 'checkcolumn' }
                    ]
                }
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Transfer - {current.strTransferNo}'
            },
            btnSave: {
                disabled: '{current.ysnPosted}'
            },
            btnDelete: {
                disabled: '{current.ysnPosted}'
            },
            btnUndo: {
                disabled: '{current.ysnPosted}'
            },
            btnPost: {
                text: '{getPostButtonText}',
                iconCls: '{getPostButtonIcon}',
                hidden: '{checkTransportPosting}'
            },

            txtTransferNumber: '{current.strTransferNo}',
            dtmTransferDate: {
                value: '{current.dtmTransferDate}',
                readOnly: '{current.ysnPosted}'
            },
            cboTransferType: {
                value: '{current.strTransferType}',
                store: '{transferTypes}',
                readOnly: '{current.ysnPosted}'
            },
            cboSourceType: {
                value: '{current.intSourceType}',
                store: '{sourceTypes}',
                readOnly: '{current.ysnPosted}'
            },
            cboTransferredBy: {
                value: '{current.intTransferredById}',
                store: '{userList}'
            },
            txtDescription: {
                value: '{current.strDescription}',
                readOnly: '{current.ysnPosted}'
            },
            cboFromLocation: {
                value: '{current.intFromLocationId}',
                store: '{fromLocation}',
                readOnly: '{current.ysnPosted}'
            },
            cboToLocation: {
                value: '{current.intToLocationId}',
                store: '{toLocation}',
                readOnly: '{current.ysnPosted}'
            },
            chkShipmentRequired: {
                value: '{current.ysnShipmentRequired}',
                readOnly: '{current.ysnPosted}'
            },
            cboStatus: {
                value: '{current.intStatusId}',
                store: '{status}',
                readOnly: '{current.ysnPosted}'
            },

//            cboShipVia: {
//                value: '{current.intShipViaId}',
//                store: '{shipVia}',
//                readOnly: '{current.ysnPosted}'
//            },
//            cboFreightUOM: {
//                value: '{current.intFreightUOMId}',
//                store: '{uom}',
//                readOnly: '{current.ysnPosted}'
//            },
//            txtTaxAmount: '{current.dblTaxAmount}',
//
//            pnlFreight: {
//                hidden: '{hideOnStorageToStorage}'
//            },

            grdInventoryTransfer: {
                readOnly: '{current.ysnPosted}',
                colSourceNumber: {
                    dataIndex: 'strSourceNumber',
                    hidden: '{checkHideSourceNo}'
                },
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{item}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intFromLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colDescription: 'strItemDescription',
                colFromSubLocation: {
                    dataIndex: 'strFromSubLocationName',    
                    editor: {
                        store: '{fromSubLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'dblOnHand',
                            value: '0',
                            conjunction: 'and',
                            condition: 'gt'
                        },{
                            column: 'ysnStockUnit',
                            value: true,
                            conjunction: 'and',
                            condition: 'eq'
                        }
                        ]
                    }
                },
                colFromStorage: {
                    dataIndex: 'strFromStorageLocationName',
                    editor: {
                        store: '{fromStorageLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intSubLocationId',
                            value: '{grdInventoryTransfer.selection.intFromSubLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'dblOnHand',
                            value: '0',
                            conjunction: 'and',
                            condition: 'gt'
                        }]
                    }
                },
                colLotID: {
                    dataIndex: 'strLotNumber',
                    editor: {
                        store: '{lot}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intSubLocationId',
                            value: '{grdInventoryTransfer.selection.intFromSubLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intStorageLocationId',
                            value: '{grdInventoryTransfer.selection.intFromStorageLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intOwnershipType',
                            value: '{grdInventoryTransfer.selection.intOwnershipType}',
                            conjunction: 'and'
                        }]
                    }
                },
                colAvailableQty: 'dblAvailableQty',
                colAvailableUOM: 'strAvailableUOM',
                colToSubLocation: {
                    dataIndex: 'strToSubLocationName',
                    editor: {
                        store: '{toSubLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [
                            {
                                column: 'intCompanyLocationId',
                                value: '{current.intToLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colToStorage: {
                    dataIndex: 'strToStorageLocationName',
                    editor: {
                        store: '{toStorageLocation}',
                        readOnly: '{readOnlyInventoryTransferField}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intToLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intSubLocationId',
                                value: '{grdInventoryTransfer.selection.intToSubLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colOwnershipType: {
                    dataIndex: 'strOwnershipType',
                    editor: {
                        readOnly: '{readOnlyInventoryTransferField}',
                        origValueField: 'intOwnershipType',
                        origUpdateField: 'intOwnershipType',
                        store: '{ownershipTypes}'
                    }
                },
                colTransferQty: 'dblQuantity',
                //colTransferUOM: {
                //    dataIndex: 'strUnitMeasure',
                //    editor: {
                //        readOnly: '{checkLotExists}',
                //        store: '{itemUOM}',
                //        defaultFilters: [{
                //            column: 'intItemId',
                //            value: '{grdInventoryTransfer.selection.intItemId}',
                //            conjunction: 'and'
                //        }]
                //    }
                //},
                colNewLotID: {
                    dataIndex: 'strNewLotId'
                },
                colCost: 'dblCost'
//                colTaxCode: {
//                    dataIndex: 'strTaxCode',
//                    editor: {
//                        store: '{taxCode}'
//                    }
//                },
//                colTaxAmount: 'dblTaxAmount',
//                colFreightRate: {
//                    dataIndex: 'dblFreightRate',
//                    hidden: '{hideOnStorageToStorage}'
//                },
//                colFreightAmount: {
//                    dataIndex: 'dblFreightAmount',
//                    hidden: '{hideOnStorageToStorage}'
//                }
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Transfer', { pageSize: 1 });

        var grdInventoryTransfer = win.down('#grdInventoryTransfer');

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            enableComment: true,
            enableAudit: true,
            include: 'tblICInventoryTransferDetails.vyuICGetInventoryTransferDetail',
            createRecord : me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.InventoryTransfer',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryTransferDetails',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdInventoryTransfer,
                        deleteButton : grdInventoryTransfer.down('#btnRemoveItem'),
                        createRecord : me.createDetailRecord
                    })
                }
            ]
        });
        return win.context;

    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intInventoryTransferId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    createRecord: function(config, action) {
        var today = new Date();
        var record = Ext.create('Inventory.model.Transfer');
        record.set('strTransferType', 'Location to Location');
        record.set('intSourceType', 0);
        if (app.DefaultLocation > 0){
            record.set('intFromLocationId', app.DefaultLocation);
            record.set('intToLocationId', app.DefaultLocation);
        }
        if (app.EntityId > 0)
            record.set('intTransferredById', app.EntityId);
        record.set('dtmTransferDate', today);
        record.set('intStatusId', 1);
        action(record);
    },

    createDetailRecord: function(config, action) {
        var today = new Date();
        var record = Ext.create('Inventory.model.TransferDetail');
        record.set('intOwnershipType', 1);
        record.set('strOwnershipType', 'Own');
        action(record);
    },

    AvailableQtyRenderer: function (value, metadata, record) {
        if (!metadata) return value;
        var grid = metadata.column.up('grid');
        var win = grid.up('window');
        var items = win.viewModel.storeInfo.itemStock;
        var currentMaster = win.viewModel.data.current;

        if (currentMaster) {
            if (record) {
                if (items) {
                    var index = items.data.findIndexBy(function (row) {
                        if (row.get('intItemId') === record.get('intItemId') &&
                            row.get('intLocationId') === currentMaster.get('intFromLocationId') &&
                            row.get('intSubLocationId') === record.get('intFromSubLocationId') &&
                            row.get('intStorageLocationId') === record.get('intFromStorageLocationId')) {
                            return true;
                        }
                    });
                    if (index >= 0) {
                        var stockUOM = items.getAt(index);
                        return stockUOM.get('dblOnHand');
                    }
                }
            }
        }

        return value;
    },

    AvailableUOMRenderer: function (value, metadata, record) {
        if (!metadata) return value;
        var grid = metadata.column.up('grid');
        var win = grid.up('window');
        var items = win.viewModel.storeInfo.itemStock;
        var currentMaster = win.viewModel.data.current;

        if (currentMaster) {
            if (record) {
                if (items) {
                    var index = items.data.findIndexBy(function (row) {
                        if (row.get('intItemId') === record.get('intItemId') &&
                            row.get('intLocationId') === currentMaster.get('intFromLocationId') &&
                            row.get('intSubLocationId') === record.get('intFromSubLocationId') &&
                            row.get('intStorageLocationId') === record.get('intFromStorageLocationId')) {
                            return true;
                        }
                    });
                    if (index >= 0) {
                        var stockUOM = items.getAt(index);
                        return stockUOM.get('strUnitMeasure');
                    }
                }
            }
        }
        return value;
    },

    onTransferDetailSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboItem') {
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('intItemUOMId', records[0].get('intStockUOMId'));
            current.set('dblAvailableQty', records[0].get('dblAvailable'));
            current.set('strAvailableUOM', records[0].get('strStockUOM'));
            current.set('dblOriginalAvailableQty', records[0].get('dblAvailable'));
            current.set('dblOriginalStorageQty', records[0].get('dblStorageQty'));

        }
        else if (combo.itemId === 'cboLot') {
            current.set('intLotId', records[0].get('intLotId'));
            current.set('dblAvailableQty', records[0].get('dblQty'));
            current.set('strAvailableUOM', records[0].get('strItemUOM'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));

            current.set('dblOriginalAvailableQty', records[0].get('dblQty'));
            current.set('dblOriginalStorageQty', records[0].get('dblQty'));

        }
        else if (combo.itemId === 'cboFromSubLocation') {
            current.set('intFromSubLocationId', records[0].get('intSubLocationId'));
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));

            current.set('strFromStorageLocationName', records[0].get('strStorageLocationName'));

            current.set('strAvailableUOM', records[0].get('strUnitMeasure'));

            current.set('dblOriginalAvailableQty', records[0].get('dblAvailableQty'));
            current.set('dblOriginalStorageQty', records[0].get('dblStorageQty'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));

            switch (current.get('intOwnershipType')) {
                case 1:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
                    break;
                case 2:
                    current.set('dblAvailableQty', current.get('dblOriginalStorageQty'));
                    break;
                default:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
            }
        }
        else if (combo.itemId === 'cboFromStorage') {
            current.set('intFromSubLocationId', records[0].get('intSubLocationId'));
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));

            current.set('strFromSubLocationName', records[0].get('strSubLocationName'));

            current.set('strAvailableUOM', records[0].get('strUnitMeasure'));

            current.set('dblOriginalAvailableQty', records[0].get('dblAvailableQty'));
            current.set('dblOriginalStorageQty', records[0].get('dblStorageQty'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));

            switch (current.get('intOwnershipType')) {
                case 1:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
                    break;
                case 2:
                    current.set('dblAvailableQty', current.get('dblOriginalStorageQty'));
                    break;
                default:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
            }
        }
        else if (combo.itemId === 'cboOwnershipType'){
            switch (records[0].get('intOwnershipType')) {
                case 1:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
                    break;
                case 2:
                    current.set('dblAvailableQty', current.get('dblOriginalStorageQty'));
                    break;
                default:
                    current.set('dblAvailableQty', current.get('dblOriginalAvailableQty'));
            }
        }
        else if (combo.itemId === 'cboToSubLocation') {
            current.set('intToSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
            current.set('intToStorageLocationId', null);
            current.set('strToStorageLocationName', null);
        }
        else if (combo.itemId === 'cboToStorage') {
            current.set('intToStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('intToSubLocationId', records[0].get('intSubLocationId'));
            current.set('strToSubLocationName', records[0].get('strSubLocationName'));
        }
        //else if (combo.itemId === 'cboUOM') {
        //    current.set('intItemUOMId', records[0].get('intItemUOMId'));
        //}
        else if (combo.itemId === 'cboWeightUOM') {
            current.set('intItemWeightUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewLotID') {
            current.set('intNewLotId', records[0].get('intLotId'));
        }
        else if (combo.itemId === 'cboTaxCode') {
            current.set('intTaxCodeId', records[0].get('intTaxCodeId'));
        }

        win.viewModel.data.currentDetailItem = current;
    },

    onDetailSelectionChange: function(selModel, selected, eOpts) {
        if (selModel) {
            var win = selModel.view.grid.up('window');
            var vm = win.viewModel;

            if (selected.length > 0) {
                var current = selected[0];
                if (current.dummy) {
                    vm.data.currentDetailItem = null;
                }
                else {
                    vm.data.currentDetailItem = current
                }
            }
            else {
                vm.data.currentDetailItem = null;
            }
        }
    },

    onViewItemClick: function(button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryTransfer');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Inventory.view.Item', current.get('intItemId'));
            }
            else {
                iRely.Functions.showErrorDialog('Please select an Item to view.');
            }
        }
        else {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
        }
    },

    onPostClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function() {
            var strTransferNo = win.viewModel.data.current.get('strTransferNo');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL             : '../Inventory/api/InventoryTransfer/PostTransaction',
                strTransactionId    : strTransferNo,
                isPost              : !posted,
                isRecap             : false,
                callback            : me.onAfterReceive,
                scope               : me
            };

            CashManagement.common.BusinessRules.callPostRequest(options);
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
            doPost();
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doPost();
            }
        });
    },

    onRecapClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doRecap = function(recapButton, currentRecord){

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/InventoryTransfer/PostTransaction',
                strTransactionId: currentRecord.get('strTransferNo'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function(){
                    // If data is generated, show the recap screen.
                    var showPostButton = true;
                    if (currentRecord.get('intSourceType') === 3){
                        showPostButton = false;
                    }

                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strTransferNo'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmTransferDate'),
                        strCurrencyId: null,
                        dblExchangeRate: 1,
                        scope: me,
                        showPostButton: showPostButton,
                        showUnpostButton: showPostButton,
                        postCallback: function(){
                            me.onPostClick(recapButton);
                        },
                        unpostCallback: function(){
                            me.onPostClick(recapButton);
                        }
                    });
                },
                failure: function(message){
                    // Show why recap failed.
                    var msgBox = iRely.Functions;
                    msgBox.showCustomDialog(
                        msgBox.dialogType.ERROR,
                        msgBox.dialogButtonType.OK,
                        message
                    );
                }
            });
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
            doRecap(button, win.viewModel.data.current);
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doRecap(button, win.viewModel.data.current);
            }
        });
    },

    onAfterReceive: function(success, message) {
        if (success === true) {
            var me = this;
            var win = me.view;
            win.context.data.load();
        }
        else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, message);
        }
    },

    onItemClick: function () {
        iRely.Functions.openScreen('Inventory.view.Item', { action: 'new', viewConfig: { modal: true }});
    },

    onCategoryClick: function () {
        iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true }});
    },

    onCommodityClick: function () {
        iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true }});
    },

    onLocationClick: function () {
        iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true }});
    },

    onStorageLocationClick: function () {
        iRely.Functions.openScreen('Inventory.view.StorageUnit', { action: 'new', viewConfig: { modal: true }});
    },

    onViewTransfer: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'TransferNo');
    },

    onViewTransaction: function (value, record) {
        var intSourceType = record.get('intSourceType');
        switch (intSourceType) {
            case 1:
                i21.ModuleMgr.Inventory.showScreen(value, 'Scale');
                break;
            case 2:
                i21.ModuleMgr.Inventory.showScreen(value, 'Inbound Shipment');
                break;
            case 3:
                i21.ModuleMgr.Inventory.showScreen(value, 'Transport');
                break;
        }
    },

    onViewItem: function (value, record) {
        var ItemId = record.get('intItemId');
        i21.ModuleMgr.Inventory.showScreen(ItemId, 'ItemId');
    },

    onViewLocation: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'LocationName');
    },

    onViewStorageLocation: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'StorageLocation');
    },

    onViewUOM: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'UOM');
    },

    init: function(application) {
        this.control({
            "#cboItem": {
                select: this.onTransferDetailSelect
            },
            "#cboLot": {
                select: this.onTransferDetailSelect
            },
            "#cboFromSubLocation": {
                select: this.onTransferDetailSelect
            },
            "#cboFromStorage": {
                select: this.onTransferDetailSelect
            },
            "#cboToSubLocation": {
                select: this.onTransferDetailSelect
            },
            "#cboToStorage": {
                select: this.onTransferDetailSelect
            },
            //"#cboUOM": {
            //    select: this.onTransferDetailSelect
            //},
            "#cboWeightUOM": {
                select: this.onTransferDetailSelect
            },
            "#cboNewLotID": {
                select: this.onTransferDetailSelect
            },
            "#cboTaxCode": {
                select: this.onTransferDetailSelect
            },
            "#cboOwnershipType": {
                select: this.onTransferDetailSelect
            },
            "#btnPost": {
                click: this.onPostClick
            },
            "#btnRecap": {
                click: this.onRecapClick
            },
            "#btnViewItem": {
                click: this.onViewItemClick
            },
            "#grdInventoryTransfer": {
                selectionchange: this.onDetailSelectionChange
            }
        });
    }
});
