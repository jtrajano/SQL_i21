/**
 * Created by LZabala on 11/12/2014.
 */
Ext.define('Inventory.store.BufferedItemOwner', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemowner',

    requires: [
        'Inventory.model.AdjustItemOwner'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.AdjustItemOwner',
            storeId: 'BufferedItemOwner',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/SearchItemOwner'
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