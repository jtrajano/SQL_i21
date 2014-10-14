/**
 * Created by marahman on 19-09-2014.
 */
Ext.define('Inventory.store.FeedStockCode', {
    extend: 'Ext.data.Store',
    alias: 'store.inventoryfeedstockcode',

    requires: [
        'Inventory.model.FeedStockCode'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.FeedStockCode',
            storeId: 'FeedStockCode',
            pageSize: 50,
            batchActions: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/RinFeedStock/GetRinFeedStocks',
                    update: '../Inventory/api/RinFeedStock/PutRinFeedStocks',
                    create: '../Inventory/api/RinFeedStock/PostRinFeedStocks',
                    destroy: '../Inventory/api/RinFeedStock/DeleteRinFeedStocks'
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
