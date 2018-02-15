/**
 * Created by LZabala on 11/7/2014.
 */
Ext.define('Inventory.store.BufferedCommodity', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedcommodity',

    requires: [
        'Inventory.model.CompactCommodity'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CompactCommodity',
            storeId: 'BufferedCommodity',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/commodity/search'
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