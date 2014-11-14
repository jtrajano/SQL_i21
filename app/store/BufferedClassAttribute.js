/**
 * Created by LZabala on 11/11/2014.
 */
Ext.define('Inventory.store.BufferedClassAttribute', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedclassattribute',

    requires: [
        'Inventory.model.CommodityClass'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CommodityClass',
            storeId: 'BufferedClassAttribute',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CommodityAttribute/GetClassAttributes'
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