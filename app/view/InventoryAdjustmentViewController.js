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
                {dataIndex: 'strAdjustmentType', text: 'Adjustment Type', flex: 1, dataType: 'string'},
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
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{uomUnitMeasure}'
                    }
                },
                colDescription: {
                    dataIndex: 'dblUnitQty'
                },
                colSubLocation: {
                    dataIndex: 'dblSellQty'
                },
                colStorageLocation: {
                    dataIndex: 'dblWeight'
                },
                colLotID: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: 'Weight',
                            conjunction: 'and'
                        }]
                    }
                },
                colNewLotID: 'strDescription',
                colQuantity: 'strUpcCode',
                colUOM: 'ysnStockUnit',
                colWeightPerUnit: 'ysnAllowSale',
                colUnitCost: 'ysnAllowPurchase',
                colNewQuantity: 'dblConvertToStock',
                colNewUOM: 'dblConvertFromStock',
                colNewItemNumber: 'dblLength',
                colNewItemDescription: 'dblWidth',
                colPhysicalCount: 'dblHeight',
                colNewPhysicalCount: {
                    dataIndex: 'strDimensionUOM',
                    editor: {
                        store: '{dimensionUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: '',
                            conjunction: 'and'
                        }]
                    }
                },
                colExpirationDate: 'dblVolume',
                colNewExpirationDate: {
                    dataIndex: 'strVolumeUOM',
                    editor: {
                        store: '{volumeUOM}',
                        defaultFilters: [{
                            column: 'strUnitType',
                            value: 'Volume',
                            conjunction: 'and'
                        }]
                    }
                },
                colStatus: 'dblMaxQty',
                colNewStatus: 'dblMaxQty',
                colGLAmount: 'dblMaxQty',
                colCreditAccount: 'dblMaxQty',
                colCreditAccountDescription: 'dblMaxQty',
                colDebitAccount: 'dblMaxQty',
                colDebitAccountDescription1: 'dblMaxQty'
            },

            grdNotes: {
                colNoteDescription: '',
                colNotes: ''
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Adjustment', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICInventoryAdjustmentDetails',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdInventoryAdjustment'),
                        deleteButton : win.down('#btnRemoveItem')
                    })
                },
                {
                    key: 'tblICInventoryAdjustmentNotes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
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
    }

//    init: function(application) {
//        this.control({
//            "#colStockUnit": {
//                beforecheckchange: this.onUOMStockUnitCheckChange
//            }
//        });
//    }
});
