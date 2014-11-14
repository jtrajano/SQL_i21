/**
 * Created by LZabala on 11/11/2014.
 */
Ext.define('Inventory.store.BufferedOriginAttribute', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedoriginattribute',

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
                    read: '../Inventory/api/CommodityAttribute/GetOriginAttributes'
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