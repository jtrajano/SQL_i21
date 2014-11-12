/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedFeedStockUom', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedfeedstockuom',

    requires: [
        'Inventory.model.FeedStockUom'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FeedStockUom',
            storeId: 'BufferedFeedStockUom',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/RinFeedStockUOM/GetRinFeedStockUOMs'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        }, cfg)]);
    }
});
