/**
 * Created by LZabala on 11/11/2014.
 */
Ext.define('Inventory.store.BufferedProductLineAttribute', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedproductlineattribute',

    requires: [
        'Inventory.model.CommodityProductLine'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommodityProductLine',
            storeId: 'CommodityProductLine',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CommodityAttribute/GetProductLineAttributes'
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