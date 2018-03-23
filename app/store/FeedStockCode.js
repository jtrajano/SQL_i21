/**
 * Created by marahman on 19-09-2014.
 */
Ext.define('Inventory.store.FeedStockCode', {
    extend: 'Ext.data.Store',
    alias: 'store.icfeedstockcode',

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
                    read: './inventory/api/feedstock/get',
                    update: './inventory/api/feedstock/put',
                    create: './inventory/api/feedstock/post',
                    destroy: './inventory/api/feedstock/delete'
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
