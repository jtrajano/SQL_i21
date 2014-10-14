/**
 * Created by marahman on 19-09-2014.
 */
Ext.define('Inventory.store.FeedStockUom', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryfeedstockuom',

    requires: [
        'Inventory.model.FeedStockUom'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FeedStockUom',
            storeId: 'FeedStockUom',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/RinFeedStockUOM/GetRinFeedStockUOMs',
                    update: '../Inventory/api/RinFeedStockUOM/PutRinFeedStockUOMs',
                    create: '../Inventory/api/RinFeedStockUOM/PostRinFeedStockUOMs',
                    destroy: '../Inventory/api/RinFeedStockUOM/DeleteRinFeedStockUOMs'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    allowSingle: false
                }
            }
        }, cfg)]);
    }
});
