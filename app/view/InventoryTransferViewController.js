Ext.define('Inventory.view.InventoryTransferViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventorytransfer',

    config: {
        searchConfig: {
            title: 'Search Inventory Transfer',
            type: 'Inventory.InventoryTransfer',
            api: {
                read: '../Inventory/api/Transfer/SearchTransfers'
            },
            columns: [
                {dataIndex: 'intInventoryTransferId', text: "Inventory Transfer Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strTransferNo', text: 'Transfer No', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmTransferDate', text: 'Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strTransferType', text: 'Transfer Type', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'},
                {dataIndex: 'strFromLocation', text: 'From Location', flex: 1, dataType: 'string'},
                {dataIndex: 'strToLocation', text: 'To Location', flex: 1, dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Transfer - {current.strTransferNo}'
            },
            cboTransferType: {
                value: '{current.strTransferType}',
                store: '{transferTypes}'
            },
            cboTransferredBy: {
                value: '{current.intTransferredById}',
                store: '{userList}'
            },
            dtmTransferDate: '{current.dtmTransferDate}',
            chkShipmentRequired: '{current.ysnShipmentRequired}',
            txtTransferNumber: '{current.strTransferNo}',
            txtDescription: '{current.strDescription}',
            cboFromLocation: {
                value: '{current.intFromLocationId}',
                store: '{fromLocation}'
            },
            cboToLocation: {
                value: '{current.intToLocationId}',
                store: '{toLocation}'
            },
            cboShipVia: {
                value: '{current.intShipViaId}',
                store: '{shipVia}'
            },
            cboFreightUOM: {
                value: '{current.intFreightUOMId}',
                store: '{uom}'
            },
            cboAccountCategory: {
                value: '{current.intAccountCategoryId}',
                store: '{accountCategory}'
            },
            cboAccountId: {
                value: '{current.intAccountId}',
                store: '{glAccount}'
            },
            txtAccountDescription: '{current.strAccountDescription}',
            txtTaxAmount: '{current.dblTaxAmount}',

            grdInventoryTransfer: {
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{item}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colDescription: 'strItemDescription',
                colLotID: {
                    dataIndex: 'strLotNumber',
                    editor: {
                        store: '{lot}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colFromSubLocation: {
                    dataIndex: 'strFromSubLocationName',
                    editor: {
                        store: '{fromSubLocation}',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colFromStorage: {
                    dataIndex: 'strFromStorageLocationName',
                    editor: {
                        store: '{fromStorageLocation}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colToSubLocation: {
                    dataIndex: 'strToSubLocationName',
                    editor: {
                        store: '{toSubLocation}',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{current.intToLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colToStorage: {
                    dataIndex: 'strToStorageLocationName',
                    editor: {
                        store: '{fromStorageLocation}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intToLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colAvailableQty: 'dblAvailableQty',
                colAvailableUOM: 'strAvailableUOM',

                colTransferQty: 'dblQuantity',
                colTransferUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{itemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colGross: 'dblGrossWeight',
                colTare: 'dblTareWeight',
                colNet: 'dblNetWeight',
                colNewLotID: {
                    dataIndex: 'strNewLotNumber',
                    editor: {
                        store: '{newLot}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryTransfer.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colCost: 'dblCost',
                colCreditAccount: {
                    dataIndex: 'strCreditAccountId',
                    editor: {
                        store: '{creditGLAccount}'
                    }
                },
                colCreditAccountDescription: 'strCreditAccountDescription',
                colDebitAccount: {
                    dataIndex: 'strDebitAccountId',
                    editor: {
                        store: '{debitGLAccount}'
                    }
                },
                colDebitAccountDescription: 'strDebitAccountDescription',
                colTaxCode: {
                    dataIndex: 'strTaxCode',
                    editor: {
                        store: '{taxCode}'
                    }
                },
                colTaxAmount: 'dblTaxAmount',
                colFreightRate: 'dblFreightRate',
                colFreightAmount: 'dblFreightAmount'
            },

            grdNotes: {
                colNoteType: 'strNoteType',
                colNote: 'strNotes'
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
                        deleteButton : grdInventoryTransfer.down('#btnRemoveItem')
                    })
                },
                {
                    key: 'tblICInventoryTransferNotes',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdNotes'),
                        deleteButton : win.down('#btnRemoveNotes')
                    })
                }
            ]
        });

//        var cepItem = grdInventoryTransfer.getPlugin('cepItem');
//        if (cepItem){
//            cepItem.on({
//                validateedit: me.onEditDetails,
//                scope: me
//            });
//        }

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
        if (app.DefaultLocation > 0){
            record.set('intFromLocationId', app.DefaultLocation);
            record.set('intToLocationId', app.DefaultLocation);
        }
        if (app.EntityId > 0)
            record.set('intTransferredById', app.EntityId);
        record.set('dtmTransferDate', today);

        action(record);
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
            current.set('strItemDescription', records[0].get('strItemDescription'));
            current.set('strFromSubLocationName', records[0].get('strSubLocationName'));
            current.set('intFromSubLocationId', records[0].get('intSubLocationId'));
            current.set('strFromStorageLocationName', records[0].get('strStorageLocationName'));
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('dblAvailableQty', records[0].get('dblOnHand'));
            current.set('strAvailableUOM', records[0].get('strUnitMeasure'));
        }
        else if (combo.itemId === 'cboLot') {
            current.set('intLotId', records[0].get('intLotId'));
        }
        else if (combo.itemId === 'cboFromSubLocation') {
            current.set('intFromSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
        }
        else if (combo.itemId === 'cboFromStorage') {
            current.set('intFromStorageLocationId', records[0].get('intStorageLocationId'));
        }
        else if (combo.itemId === 'cboToSubLocation') {
            current.set('intToSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
        }
        else if (combo.itemId === 'cboToStorage') {
            current.set('intToStorageLocationId', records[0].get('intStorageLocationId'));
        }
        else if (combo.itemId === 'cboUOM') {
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboWeightUOM') {
            current.set('intItemWeightUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewLotID') {
            current.set('intNewLotId', records[0].get('intLotId'));
        }
        else if (combo.itemId === 'cboCreditAccount') {
            current.set('intCreditAccountId', records[0].get('intAccountId'));
            current.set('strCreditAccountDescription', records[0].get('strDescription'));
        }
        else if (combo.itemId === 'cboDebitAccount') {
            current.set('intDebitAccountId', records[0].get('intAccountId'));
            current.set('strDebitAccountDescription', records[0].get('strDescription'));
        }
        else if (combo.itemId === 'cboTaxCode') {
            current.set('intTaxCodeId', records[0].get('intTaxCodeId'));
        }
    },

    onAccountSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            current.set('strAccountDescription', records[0].get('strDescription'));
        }
    },

    onTransferTypeChange: function(obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var pnlFreight = win.down('#pnlFreight');
        var grdInventoryTransfer = win.down('#grdInventoryTransfer');
        var colCost = grdInventoryTransfer.columns[16];
        var colCreditAccount = grdInventoryTransfer.columns[17];
        var colCreditAccountDescription = grdInventoryTransfer.columns[18];
        var colDebitAccount = grdInventoryTransfer.columns[19];
        var colDebitAccountDescription = grdInventoryTransfer.columns[20];
        var colTaxCode = grdInventoryTransfer.columns[21];
        var colTaxAmount = grdInventoryTransfer.columns[22];

        var colFreightRate = grdInventoryTransfer.columns[23];
        var colFreightAmount = grdInventoryTransfer.columns[24];

        switch (newValue) {
            case 'Location to Location':
                pnlFreight.setHidden(false);

                colCost.setHidden(true);
                colCreditAccount.setHidden(true);
                colCreditAccountDescription.setHidden(true);
                colDebitAccount.setHidden(true);
                colDebitAccountDescription.setHidden(true);
                colTaxCode.setHidden(true);
                colTaxAmount.setHidden(true);

                colFreightRate.setHidden(false);
                colFreightAmount.setHidden(false);
                break
            case 'Storage to Storage':
                pnlFreight.setHidden(true);

                colCost.setHidden(true);
                colCreditAccount.setHidden(true);
                colCreditAccountDescription.setHidden(true);
                colDebitAccount.setHidden(true);
                colDebitAccountDescription.setHidden(true);
                colTaxCode.setHidden(true);
                colTaxAmount.setHidden(true);

                colFreightRate.setHidden(true);
                colFreightAmount.setHidden(true);
                break
            case 'Location to External':
                pnlFreight.setHidden(false);

                colCost.setHidden(false);
                colCreditAccount.setHidden(false);
                colCreditAccountDescription.setHidden(false);
                colDebitAccount.setHidden(false);
                colDebitAccountDescription.setHidden(false);
                colTaxCode.setHidden(false);
                colTaxAmount.setHidden(false);

                colFreightRate.setHidden(false);
                colFreightAmount.setHidden(false);
                break
        }
    },

    onEditDetails: function(editor, context, eOpts) {
//        if (context.field === 'dblTaxAmount')
//        {
//
//        }
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
            "#cboUOM": {
                select: this.onTransferDetailSelect
            },
            "#cboWeightUOM": {
                select: this.onTransferDetailSelect
            },
            "#cboNewLotID": {
                select: this.onTransferDetailSelect
            },
            "#cboCreditAccount": {
                select: this.onTransferDetailSelect
            },
            "#cboDebitAccount": {
                select: this.onTransferDetailSelect
            },
            "#cboTaxCode": {
                select: this.onTransferDetailSelect
            },
            "#cboTransferType": {
                change: this.onTransferTypeChange
            },
            "#cboAccountId": {
                select: this.onAccountSelect
            }
        });
    }
});
