/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.store.BufferedReadingPoint', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedreadingpoint',

    requires: [
        'Inventory.model.ReadingPoint'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ReadingPoint',
            storeId: 'BufferedReadingPoint',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/ReadingPoint/GetReadingPoints'
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