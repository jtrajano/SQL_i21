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
            cboTransferredBy: '{current.intTransferredById}',
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
            cboCarrier: {
                value: '{current.intCarrierId}'
//                ,
//                store: '{adjustmentTypes}'
            },
            cboFreightUOM: {
                value: '{current.intFreightUOMId}',
                store: '{uom}'
            },
            cboAccountCategory: {
                value: '{current.intAccountCategoryId}',
                store: '{accountCategory}'
            },
            cboAccountID: {
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
                colQuantity: 'dblQuantity',
                colUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{itemUOM}'
                    }
                },
                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        store: '{weightUOM}'
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
                        grid: win.down('#grdInventoryTransfer'),
                        deleteButton : win.down('#btnRemoveItem')
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

    init: function(application) {
        this.control({

        });
    }
});
