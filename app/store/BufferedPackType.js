/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedPackType', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedpacktype',

    requires: [
        'Inventory.model.PackType'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.PackType',
            storeId: 'BufferedPackType',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/PackType/GetPackTypes'
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