Ext.define('Inventory.view.InventoryAdjustmentViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryadjustment',

    config: {
        searchConfig: {
            title: 'Search Inventory Adjustment',
            type: 'Inventory.InventoryAdjustment',
            api: {
                read: '../Inventory/api/Adjustment/SearchAdjustments'
            },
            columns: [
                {dataIndex: 'intInventoryAdjustmentId', text: "Inventory Adjustment Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strAdjustmentNo', text: 'Adjustment No', flex: 1, dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location Id', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'},
//                {dataIndex: 'strAdjustmentType', text: 'Adjustment Type', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmAdjustmentDate', text: 'Date', flex: 1, dataType: 'date', xtype: 'datecolumn'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Adjustment - {current.strAdjustmentNo}'
            },
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
            dtmDate: '{current.dtmAdjustmentDate}',
            cboAdjustmentType: {
                value: '{current.intAdjustmentType}',
                store: '{adjustmentTypes}'
            },
            txtAdjustmentNumber: '{current.strAdjustmentNo}',
            txtDescription: '{current.strDescription}',

            grdInventoryAdjustment: {
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{item}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colDescription: 'strItemDescription',
                colSubLocation: {
                    dataIndex: 'strSubLocation',
                    editor: {
                        store: '{subLocation}',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'strClassification',
                            value: 'Inventory',
                            conjunction: 'and'
                        }]
                    }
                },
                colStorageLocation: {
                    dataIndex: 'strStorageLocation',
                    editor: {
                        store: '{storageLocation}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colLotID: {
                    dataIndex: 'strLotNumber',
                    editor: {
                        store: '{lot}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryAdjustment.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colNewLotID: {
                    dataIndex: 'strNewLotNumber',
                    editor: {
                        store: '{newLot}'
                    }
                },
                colQuantity: 'dblLotQty',
                colUOM: 'strItemUOM',
                colWeightPerUnit: 'dblLotWeightPerUnit',
                colUnitCost: 'dblLotUnitCost',
                colNewQuantity: 'dblNewQuantity',
                colNewUOM: {
                    dataIndex: 'strNewItemUOM',
                    editor: {
                        store: '{newItemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryAdjustment.selection.intItemId}',
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
                            value: '{grdInventoryAdjustment.selection.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colNetWeight: 'dblNetWeight',
                colNewWeightPerUnit: 'dblNewWeightPerUnit',
                colNewItemNumber: {
                    dataIndex: 'strNewItemNo',
                    editor: {
                        store: '{newItem}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colNewItemDescription: 'strNewItemDescription',
                colExpirationDate: 'dtmExpiryDate',
                colNewExpirationDate: 'dtmNewExpiryDate',
                colStatus: 'strLotStatus',
                colNewStatus: {
                    dataIndex: 'strNewLotStatus',
                    editor: {
                        store: '{newLotStatus}'
                    }
                },
                colGLAmount: 'dblGLAmount',
                colAccountCategory: {
                    dataIndex: 'strAccountCategory',
                    editor: {
                        store: '{accountCategory}',
                        defaultFilters: [{
                            column: 'strAccountCategoryGroupCode',
                            value: 'INV'
                        }]
                    }
                },
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
                colDebitAccountDescription: 'strDebitAccountDescription'
            },

            grdNotes: {
                colNoteDescription: 'strDescription',
                colNotes: 'strNotes'
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Adjustment', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.InventoryAdjustment',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryAdjustmentDetails',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdInventoryAdjustment'),
                        deleteButton : win.down('#btnRemoveItem')
                    })
                },
                {
                    key: 'tblICInventoryAdjustmentNotes',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdNotes'),
                        deleteButton : win.down('#btnRemoveNotes')
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
                        column: 'intInventoryAdjustmentId',
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
        var record = Ext.create('Inventory.model.Adjustment');
        record.set('intAdjustmentType', '1');
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        record.set('dtmAdjustmentDate', today);
        action(record);
    },

    onAdjustmentDetailSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var me = win.controller;
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboItemNo')
        {
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
        }
        else if (combo.itemId === 'cboNewItemNo')
        {
            current.set('intNewItemId', records[0].get('intItemId'));
            current.set('strNewItemDescription', records[0].get('strDescription'));
        }
        else if (combo.itemId === 'cboSubLocation')
        {
            current.set('intSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
        }
        else if (combo.itemId === 'cboStorageLocation')
        {
            current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
        }
        else if (combo.itemId === 'cboLotId')
        {
            current.set('intLotId', records[0].get('intLotId'));
            current.set('dblLotQty', records[0].get('dblQty'));
            current.set('dblLotUnitCost', records[0].get('dblLastCost'));
            current.set('dblLotWeightPerUnit', records[0].get('dblWeightPerQty'));
            current.set('strItemUOM', records[0].get('strItemUOM'));
            current.set('strWeightUOM', records[0].get('strWeightUOM'));
            current.set('intWeightUOMId', records[0].get('intWeightUOMId'));
            current.set('strLotStatus', records[0].get('strLotStatus'));
            current.set('intLotStatusId', records[0].get('intLotStatusId'));
            current.set('dtmExpiryDate', records[0].get('dtmExpiryDate'));
            current.set('dblNetWeight', records[0].get('dblWeight'));
        }
        else if (combo.itemId === 'cboNewUOM')
        {
            current.set('intNewItemUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboWeightUOM')
        {
            current.set('intWeightUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboNewStatus')
        {
            current.set('intNewLotStatusId', records[0].get('intLotStatusId'));
        }
        else if (combo.itemId === 'cboAccountCategory')
        {
            current.set('intAccountCategoryId', records[0].get('intAccountCategoryId'));
        }
        else if (combo.itemId === 'cboCreditAccount')
        {
            current.set('intCreditAccountId', records[0].get('intAccountId'));
            current.set('strCreditAccountDescription', records[0].get('strDescription'));
        }
        else if (combo.itemId === 'cboDebitAccount')
        {
            current.set('intDebitAccountId', records[0].get('intAccountId'));
            current.set('strDebitAccountDescription', records[0].get('strDescription'));
        }
    },

    onAdjustmentTypeChange: function(obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
        var colNewLot = grdInventoryAdjustment.columns[5];
        var colNewQty = grdInventoryAdjustment.columns[10];
        var colNewUOM = grdInventoryAdjustment.columns[11];
        var colWeightUOM = grdInventoryAdjustment.columns[12];
        var colNetWeight = grdInventoryAdjustment.columns[13];
        var colNewWeightPerUnit = grdInventoryAdjustment.columns[14];
        var colNewItemId = grdInventoryAdjustment.columns[15];
        var colNewItemDesc = grdInventoryAdjustment.columns[16];
        var colExpiry = grdInventoryAdjustment.columns[17];
        var colNewExpiry = grdInventoryAdjustment.columns[18];
        var colStatus = grdInventoryAdjustment.columns[19];
        var colNewStatus = grdInventoryAdjustment.columns[20];

        switch (newValue) {
            case 1:
                colNewLot.setHidden(true);
                colNewQty.setHidden(false);
                colNewUOM.setHidden(true);
                colWeightUOM.setHidden(false);
                colNetWeight.setHidden(false);
                colNewWeightPerUnit.setHidden(false);
                colNewItemId.setHidden(true);
                colNewItemDesc.setHidden(true);
                colExpiry.setHidden(true);
                colNewExpiry.setHidden(true);
                colStatus.setHidden(true);
                colNewStatus.setHidden(true);
                break;
            case 2:
                colNewLot.setHidden(true);
                colNewQty.setHidden(true);
                colNewUOM.setHidden(false);
                colWeightUOM.setHidden(false);
                colNetWeight.setHidden(false);
                colNewWeightPerUnit.setHidden(false);
                colNewItemId.setHidden(true);
                colNewItemDesc.setHidden(true);
                colExpiry.setHidden(true);
                colNewExpiry.setHidden(true);
                colStatus.setHidden(true);
                colNewStatus.setHidden(true);
                break;
            case 3:
                colNewLot.setHidden(true);
                colNewQty.setHidden(true);
                colNewUOM.setHidden(true);
                colWeightUOM.setHidden(true);
                colNetWeight.setHidden(true);
                colNewWeightPerUnit.setHidden(true);
                colNewItemId.setHidden(false);
                colNewItemDesc.setHidden(false);
                colExpiry.setHidden(true);
                colNewExpiry.setHidden(true);
                colStatus.setHidden(true);
                colNewStatus.setHidden(true);
                break;
            case 4:
                colNewLot.setHidden(true);
                colNewQty.setHidden(true);
                colNewUOM.setHidden(true);
                colWeightUOM.setHidden(true);
                colNetWeight.setHidden(true);
                colNewWeightPerUnit.setHidden(true);
                colNewItemId.setHidden(true);
                colNewItemDesc.setHidden(true);
                colExpiry.setHidden(true);
                colNewExpiry.setHidden(true);
                colStatus.setHidden(false);
                colNewStatus.setHidden(false);
                break;
            case 5:
                colNewLot.setHidden(false);
                colNewQty.setHidden(false);
                colNewUOM.setHidden(false);
                colWeightUOM.setHidden(false);
                colNetWeight.setHidden(false);
                colNewWeightPerUnit.setHidden(false);
                colNewItemId.setHidden(true);
                colNewItemDesc.setHidden(true);
                colExpiry.setHidden(true);
                colNewExpiry.setHidden(true);
                colStatus.setHidden(true);
                colNewStatus.setHidden(true);
                break;
            case 6:
                colNewLot.setHidden(true);
                colNewQty.setHidden(true);
                colNewUOM.setHidden(true);
                colWeightUOM.setHidden(true);
                colNetWeight.setHidden(true);
                colNewWeightPerUnit.setHidden(true);
                colNewItemId.setHidden(true);
                colNewItemDesc.setHidden(true);
                colExpiry.setHidden(false);
                colNewExpiry.setHidden(false);
                colStatus.setHidden(true);
                colNewStatus.setHidden(true);
                break;
        }
    },

    init: function(application) {
        this.control({
            "#cboItemNo": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboNewItemNo": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboStorageLocation": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboLotId": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboSubLocation": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboNewUOM": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboWeightUOM": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboNewStatus": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboAccountCategory": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboCreditAccount": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboDebitAccount": {
                select: this.onAdjustmentDetailSelect
            },
            "#cboAdjustmentType": {
                change: this.onAdjustmentTypeChange
            }
        });
    }
});
