/**
 * Created by LZabala on 1/20/2015.
 */
Ext.define('Inventory.store.BufferedItemLocation', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemlocation',

    requires: [
        'Inventory.model.ItemLocation'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemLocation',
            storeId: 'BufferedItemLocation',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ItemLocation/GetItemLocations'
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