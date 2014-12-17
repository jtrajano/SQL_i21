/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.store.BufferedSku', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedsku',

    requires: [
        'Inventory.model.Sku'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Sku',
            storeId: 'BufferedSku',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Sku/GetSkus'
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