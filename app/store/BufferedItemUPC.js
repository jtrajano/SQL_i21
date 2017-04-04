/**
 * Created by LZabala on 11/14/2014.
 */
Ext.define('Inventory.store.BufferedItemUPC', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.icbuffereditemupc',

    requires: [
        'Inventory.model.ItemUOM'
    ],

    constructor: function(cfg) {
        var me = this;
        cfg = cfg || {};
        me.callParent([Ext.apply({
            model: 'Inventory.model.ItemUOM',
            storeId: 'BufferedItemUPC',
            pageSize: 50,
            batchActions: true,
            remoteFilter: true,
            remoteSort: true,
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/SearchItemUPCs'
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