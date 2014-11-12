/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedFeedStockCode', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedfeedstockcode',

    requires: [
        'Inventory.model.FeedStockCode'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FeedStockCode',
            storeId: 'BufferedFeedStockCode',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/RinFeedStock/GetRinFeedStocks'
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
