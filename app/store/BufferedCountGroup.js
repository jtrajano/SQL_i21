/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedCountGroup', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.inventorybufferedcountgroup',

    requires: [
        'Inventory.model.CountGroup'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.CountGroup',
            storeId: 'BufferedCountGroup',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/CountGroup/GetCountGroups'
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