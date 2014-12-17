/**
 * Created by LZabala on 11/11/2014.
 */
Ext.define('Inventory.store.BufferedProductTypeAttribute', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedproducttypeattribute',

    requires: [
        'Inventory.model.CommodityProductType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommodityProductType',
            storeId: 'BufferedProductTypeAttribute',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CommodityAttribute/GetProductTypeAttributes'
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