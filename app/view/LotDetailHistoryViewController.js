Ext.define('Inventory.view.LotDetailHistoryViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iclotdetailhistory',

    config: {
        binding: {
            
        }
    },

    setupContext: function (options) {
        "use strict";

        var me = this;
        var win = options.window;
        var store = Ext.create('Inventory.store.LotDetailHistory', { pageSize: 50 });

        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            binding: me.config.binding
        });
        return win.context;
    },

    show: function (config) {
        "use strict";
        var me = this;
        var win = me.getView();
        var grid = win.down('#grdLogHistory');

        if(config) {
            win.show();
            var context = me.setupContext({ window: win });

            if (config.id) {
                config.filters = [
                    {
                        column: 'intLotId',
                        value: config.id,
                        conjunction: 'and',
                        condition: 'eq'
                    }
                ];
            }
            context.data.store.on({
                // beforeload: function(store, operation) {
                //     operation.filter = config.filters;
                //     if(store.filters) {
                //         var filter = [];
                //         store.filters.clear();
                //         filter.push(config.filters[0]);
                //         if(store.filters.items.length > 0) {
                //             filter.push({
                //                 column: "strTransactionId|^|strTransactionType|^|strLotNumber|^|strParentLotNumber|^|strLotUOM|^|dblWeightPerQty|^|dtmExpiryDate|^|strEntityName|^|dtmDate|^|dblQty|^|dblCost|^|dblAmount|^|dblWeight|^|strLocationName|^|strStorageLocationName|^|",
                //                 value: store.filters.items[0].getValue(),
                //                 condition: 'ct',
                //                 conjunction: 'or'
                //             });
                //         }
                //         operation.filter = filter;
                //         store.filters = filter;
                //     }
                // },
                load: function(store, records, successful) {
                    if (successful && (records && records.length === 0) && !config.singleGridMgr) {
                        iRely.Msg.showInfo("There's no transaction for this lot.", function(button) {
                            win.close();
                        });
                    }
                }
            });
            grid.reconfigure(context.data.store);
            grid.defaultFilters = config.filters;
            context.data.store.load({filters: config.filters});
        }
    },

    onViewTransaction: function (value, record) {
        var transactionType = null;
        switch (record.get('strTransactionType')) {
            case 'Inventory Receipt':
                transactionType = 'ReceiptNo';
                break;

            case 'Inventory Shipment':
                transactionType = 'ShipmentNo';
                break;

            case 'Inventory Transfer with Shipment':
            case 'Inventory Transfer':
                transactionType = 'TransferNo';
                break;

            case 'Inventory Adjustment - Quantity Change':
            case 'Inventory Adjustment - UOM Change':
            case 'Inventory Adjustment - Item Change':
            case 'Inventory Adjustment - Lot Status Change':
            case 'Inventory Adjustment - Split Lot':
            case 'Inventory Adjustment - Expiry Date Change':
            case 'Inventory Adjustment - Lot Merge':
            case 'Inventory Adjustment - Lot Move':
                transactionType = 'AdjustmentNo';
                break;

            case 'Purchase Order':
                transactionType = 'PONumber';
                break;

            case 'Sales Order':
                transactionType = 'SONumber';
                break;
            case 'Invoice':
                transactionType = 'Invoice';
                break;
            default:
                iRely.Functions.showInfoDialog('This transaction is not viewable on a screen.');
                break;
        }
        i21.ModuleMgr.Inventory.showScreen(value, transactionType);
    }
});
