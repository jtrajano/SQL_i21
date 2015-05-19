/**
 * Created by marahman on 19-09-2014.
 */
Ext.define('Inventory.store.FeedStockUom', {
    extend: 'Ext.data.Store',
    alias: 'store.icfeedstockuom',

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
                    read: '../Inventory/api/FeedStockUOM/Get',
                    update: '../Inventory/api/FeedStockUOM/Put',
                    create: '../Inventory/api/FeedStockUOM/Post',
                    destroy: '../Inventory/api/FeedStockUOM/Delete'
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
