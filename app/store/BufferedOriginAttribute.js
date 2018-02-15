/**
 * Created by LZabala on 11/11/2014.
 */
Ext.define('Inventory.store.BufferedOriginAttribute', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedoriginattribute',

    requires: [
        'Inventory.model.CommodityOrigin'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommodityOrigin',
            storeId: 'BufferedOriginAttribute',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/commodityattribute/searchoriginattributes'
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