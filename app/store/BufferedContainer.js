/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.store.BufferedContainer', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbufferedcontainer',

    requires: [
        'Inventory.model.Container'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.Container',
            storeId: 'BufferedContainer',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: './inventory/api/container/search'
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